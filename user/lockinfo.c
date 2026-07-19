#include "user/user.h"
#include "kernel/procinfo.h"
#include "kernel/types.h"

#define OUTBUF_SZ 1024  
#define MAX_LOCKS 128

// المصفوفة العالمية لحماية الـ Stack
static struct lock_info sys_locks[MAX_LOCKS];

// دوال المساعدة للـ JSON (نفسها تماماً)
static void append_str(char *buf, int *pos, const char *s) {
    while (*s && *pos < OUTBUF_SZ - 50) { 
        buf[(*pos)++] = *s++;
    }
}

static void append_uint(char *buf, int *pos, uint x) {
    char tmp[16]; 
    int n = 0;
    if (*pos >= OUTBUF_SZ - 20) return; 
    if (x == 0) { buf[(*pos)++] = '0'; return; }
    while (x > 0) { tmp[n++] = '0' + (x % 10); x /= 10; }
    while (n > 0) buf[(*pos)++] = tmp[--n];
}

static void append_int(char *buf, int *pos, int x) {
    if (*pos >= OUTBUF_SZ - 20) return;
    if (x < 0) {
        buf[(*pos)++] = '-';
        x = -x;
    }
    append_uint(buf, pos, (uint)x);
}

// دالة مخصصة لطباعة معلومات القفل كـ JSON Line
static void print_lock_event(const struct lock_info *lk) {
    char buf[OUTBUF_SZ];
    int pos = 0;
    memset(buf, 0, OUTBUF_SZ);

    append_str(buf, &pos, "LOCK_EV {\"name\":\"");
    append_str(buf, &pos, lk->lock_name);
    append_str(buf, &pos, "\",\"last_pid\":");       // صلحنا علامة التنصيص هون
    append_int(buf, &pos, lk->pid);
    append_str(buf, &pos, ",\"proc_name\":\"");
    append_str(buf, &pos, lk->proc_name);
    append_str(buf, &pos, "\",\"cpu_id\":");
    append_int(buf, &pos, lk->cpu_id);
    append_str(buf, &pos, ",\"last_hold_time\":");
    append_uint(buf, &pos, lk->hold_time);
    append_str(buf, &pos, ",\"acq_count\":");
    append_uint(buf, &pos, lk->acq_count);
    append_str(buf, &pos, ",\"contention\":");
    append_uint(buf, &pos, lk->contention);
    append_str(buf, &pos, "}\n");                   // شلنا علامة التنصيص الزايدة من هون

    write(1, buf, pos);
}
int
main(void)
{
    int n;

    // تصفير المصفوفة قبل الاستخدام
    memset(sys_locks, 0, sizeof(sys_locks));

    // استدعاء السستم كول الخاصة بالأقفال
    n = getlockinfo(sys_locks, MAX_LOCKS);
    if (n < 0) {
        printf("Error fetching lock info\n");
        exit(1);
    }
    
    // DEBUG: طباعة عدد الأقفال المكتشفة
    printf("[DEBUG] getlockinfo returned %d locks\n", n);

    for (int i = 0; i < n; i++) {
        if (sys_locks[i].lock_name[0] != '\0') {
            print_lock_event(&sys_locks[i]);
        }
    }
    
    exit(0); 
}
