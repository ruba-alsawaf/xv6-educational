#include "kernel/types.h"
#include "user/user.h"
#include "kernel/fslog.h"

#define OUTBUF_SZ 2048

static struct cs_event cs_ev[8];
static struct fs_event fs_ev[8];

static void append_char(char *buf, int *pos, char c) {
  if (*pos < OUTBUF_SZ - 1)
    buf[(*pos)++] = c;
}

static void append_str(char *buf, int *pos, const char *s) {
    while (*s && *pos < OUTBUF_SZ - 1) buf[(*pos)++] = *s++;
}

static void append_uint(char *buf, int *pos, uint x) {
    char tmp[16]; int n = 0;
    if (x == 0) { buf[(*pos)++] = '0'; return; }
    while (x > 0) { tmp[n++] = '0' + (x % 10); x /= 10; }
    while (n > 0) buf[(*pos)++] = tmp[--n];
}

static void append_int(char *buf, int *pos, int x) {
  if (x < 0) {
    append_char(buf, pos, '-');
    x = -x;
  }
  append_uint(buf, pos, (uint)x);
}

static void append_json_string(char *buf, int *pos, const char *s) {
  while (*s && *pos < OUTBUF_SZ - 1) {
    char c = *s++;
    if (c == '"' || c == '\\') {
      append_char(buf, pos, '\\');
      append_char(buf, pos, c);
    } else if (c >= 32 && c < 127) {
      append_char(buf, pos, c);
    }
  }
}

// دالة طباعة أحداث الفايل سستم
static void print_fs_event(const struct fs_event *e) {
  char buf[OUTBUF_SZ];
  int pos = 0;
  memset(buf, 0, sizeof(buf));

  append_str(buf, &pos, "EV {\"type\":\"FS\"");
  append_str(buf, &pos, ",\"seq\":"); append_uint(buf, &pos, (uint)e->seq);
  append_str(buf, &pos, ",\"tick\":"); append_uint(buf, &pos, e->ticks);
  append_str(buf, &pos, ",\"fs_type\":"); append_int(buf, &pos, e->type);
  append_str(buf, &pos, ",\"pid\":"); append_int(buf, &pos, e->pid);

  append_str(buf, &pos, ",\"dev\":"); append_int(buf, &pos, e->dev);
  append_str(buf, &pos, ",\"block\":"); append_int(buf, &pos, e->blockno);
  append_str(buf, &pos, ",\"old_block\":"); append_int(buf, &pos, e->old_blockno);
  append_str(buf, &pos, ",\"buf_id\":"); append_int(buf, &pos, e->buf_id);

  append_str(buf, &pos, ",\"ref_before\":"); append_int(buf, &pos, e->ref_before);
  append_str(buf, &pos, ",\"ref_after\":"); append_int(buf, &pos, e->ref_after);

  append_str(buf, &pos, ",\"valid_before\":"); append_int(buf, &pos, e->valid_before);
  append_str(buf, &pos, ",\"valid_after\":"); append_int(buf, &pos, e->valid_after);

  append_str(buf, &pos, ",\"locked_before\":"); append_int(buf, &pos, e->locked_before);
  append_str(buf, &pos, ",\"locked_after\":"); append_int(buf, &pos, e->locked_after);

  append_str(buf, &pos, ",\"lru_before\":"); append_int(buf, &pos, e->lru_before);
  append_str(buf, &pos, ",\"lru_after\":"); append_int(buf, &pos, e->lru_after);

  append_str(buf, &pos, ",\"scan_dir\":"); append_int(buf, &pos, e->scan_dir);
  append_str(buf, &pos, ",\"scan_step\":"); append_int(buf, &pos, e->scan_step);
  append_str(buf, &pos, ",\"found\":"); append_int(buf, &pos, e->found);

  append_str(buf, &pos, ",\"size\":"); append_uint(buf, &pos, e->size);

  append_str(buf, &pos, ",\"name\":\"");
  append_json_string(buf, &pos, e->name);
  append_str(buf, &pos, "\"}\n");

  write(1, buf, pos);
}
// دالة طباعة أحداث المعالج (القديمة)
static void print_cs_event(const struct cs_event *e) {
    printf("EV {\"seq\":%ld,\"tick\":%d,\"cpu\":%d,\"pid\":%d,\"name\":\"%s\",\"state\":%d,\"type\":\"ON_CPU\"}\n",
           e->seq, e->ticks, e->cpu, e->pid, e->name, e->state);
}

int main(void) {

    while (1) {

        int n_cs = csread(cs_ev, 8);
        for (int i = 0; i < n_cs; i++) {
            if (cs_ev[i].type == 1)
                print_cs_event(&cs_ev[i]);
        }

        int n_fs = fsread(fs_ev, 8);
        for (int i = 0; i < n_fs; i++) {
            print_fs_event(&fs_ev[i]);
        }

        pause(2);
    }

    return 0;
}