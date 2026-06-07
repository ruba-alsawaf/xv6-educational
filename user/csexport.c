#include "kernel/types.h"
#include "user/user.h"

// نحن نحتاج فقط لهيكل أحداث المعالج هنا
static struct cs_event cs_ev[8];

#define OUTBUF_SZ 512

// دوال المساعدة للـ JSON (نفس اللي عندك مع تعديلات طفيفة)
static void append_str(char *buf, int *pos, const char *s) {
    while (*s && *pos < OUTBUF_SZ - 1) buf[(*pos)++] = *s++;
}

static void append_uint(char *buf, int *pos, uint x) {
    char tmp[16]; int n = 0;
    if (x == 0) { buf[(*pos)++] = '0'; return; }
    while (x > 0) { tmp[n++] = '0' + (x % 10); x /= 10; }
    while (n > 0) buf[(*pos)++] = tmp[--n];
}

// دالة طباعة أحداث الفايل سستم
static void print_fs_event(const struct fs_event *e) {
    char buf[OUTBUF_SZ];
    int pos = 0;
    memset(buf, 0, OUTBUF_SZ);

    append_str(buf, &pos, "EV {\"seq\":");
    append_uint(buf, &pos, (uint)e->seq);
    append_str(buf, &pos, ",\"tick\":");
    append_uint(buf, &pos, e->ticks);
    append_str(buf, &pos, ",\"type\":\"FS\",\"fs_type\":");
    append_uint(buf, &pos, e->type);
    append_str(buf, &pos, ",\"pid\":");
    append_uint(buf, &pos, e->pid);
    append_str(buf, &pos, ",\"inum\":");
    append_uint(buf, &pos, e->inum);
    append_str(buf, &pos, ",\"block\":");
    append_uint(buf, &pos, e->blockno);
    append_str(buf, &pos, ",\"name\":\"");
    append_str(buf, &pos, e->name);
    append_str(buf, &pos, "\"}\n");

    write(1, buf, pos);
}

// دالة طباعة أحداث المعالج (القديمة)
static void print_cs_event(const struct cs_event *e) {
    // نستخدم printf العادية هنا لأن أحداث المعالج ليست بكثافة أحداث الـ FS
    printf("EV {\"seq\":%ld,\"tick\":%d,\"cpu\":%d,\"pid\":%d,\"name\":\"%s\",\"state\":%d,\"type\":\"ON_CPU\"}\n",
           e->seq, e->ticks, e->cpu, e->pid, e->name, e->state);
}

int main(void) {
    // تنبيه لبدء البرنامج
    printf("CS Export (Context Switch) starting...\n");

    while (1) {
        // قراءة أحداث المعالج فقط
        int n_cs = csread(cs_ev, 8);
        for (int i = 0; i < n_cs; i++) {
            // نوع الحدث 1 عادة ما يرمز لتغيير السياق (Context Switch)
            if (cs_ev[i].type == 1)
                print_cs_event(&cs_ev[i]);
        }
        
        // استخدام sleep أو pause لتقليل استهلاك المعالج
        pause(2); 
    }

    return 0;
}
