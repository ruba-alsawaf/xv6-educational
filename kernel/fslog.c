#include "types.h"
#include "riscv.h"
#include "param.h"
#include "spinlock.h"
#include "defs.h"
#include "proc.h"
#include "fslog.h"

static struct ringbuf fs_rb;
static uint64 fs_seq = 0;

void
fslog_init(void)
{
  // تهيئة الـ ring buffer الخاص بـ أحداث نظام الملفات
  ringbuf_init(&fs_rb, "fslog", sizeof(struct fs_event));
}

void
fslog_push(struct fs_event *e)
{
  // إضافة رقم تسلسلي لكل حدث لترتيبها في الواجهة الرسومية
  e->seq = ++fs_seq;
  ringbuf_push(&fs_rb, e);
}

int
fslog_read_many(struct fs_event *out, int max)
{
  struct fs_event e;
  int count = 0;
  struct proc *p = myproc();
  
  while(count < max){
    if(ringbuf_pop(&fs_rb, &e) != 0)
      break;

    // نقل البيانات من مساحة النواة إلى مساحة المستخدم (User Space) ليعرضها الـ GUI
    uint64 dst = (uint64)out + count * sizeof(struct fs_event);
    if(copyout(p->pagetable, dst, (char *)&e, sizeof(struct fs_event)) < 0)
      break;
    count++;
  }
  return count;
}