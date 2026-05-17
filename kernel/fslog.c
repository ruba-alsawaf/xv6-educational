#include "types.h"
#include "riscv.h"
#include "param.h"
#include "spinlock.h"
#include "defs.h"
#include "proc.h"
#include "ringbuf.h"
#include "fslog.h"
#include "defs.h"

static struct ringbuf fs_rb;
static uint64 fs_seq = 0;

void fslog_init(void) {
  ringbuf_init(&fs_rb, "fslog", sizeof(struct fs_event));
}

void fslog_push(int type, int inum, int bno, uint size, char* name) {
  struct fs_event e;
  memset(&e, 0, sizeof(e));
  e.seq = ++fs_seq;
  e.ticks = ticks;
  e.type = type;
  e.pid = myproc() ? myproc()->pid : 0;
  e.inum = inum;
  e.blockno = bno;
  e.size = size;
  if(name) safestrcpy(e.name, name, FS_NM);
  ringbuf_push(&fs_rb, &e);
}
int
fslog_read_many(struct fs_event *out, int max)
{
  // 1. تعريف بافر مؤقت في الكيرنل يتسع لـ max من الأحداث
  // تم وضع حد أقصى 32 للأمان التام وتجنب فيضان الذاكرة
  if (max > 32) max = 32;
  
  struct fs_event local_buf[32];
  memset(local_buf, 0, sizeof(local_buf));

  // 2. القراءة الآمنة والدفعية من الـ Ring Buffer تحت قفل واحد مستمر
  // الدالة تعيد العدد الحقيقي للأحداث التي نجحت قراءتها (مثلاً n)
  int n = ringbuf_read_many(&fs_rb, local_buf, max);
  if (n <= 0) {
    return 0; // البافر فارغ تماماً، توقف فوراً ولا تطبع مخلفات
  }

  // 3. الآن نقوم بنسخ الأحداث الحقيقية فقط (الـ n حدث) إلى ذاكرة المستخدم (User space)
  int copied = 0;
  while (copied < n) {
    uint64 dst_addr = (uint64)out + (copied * sizeof(struct fs_event));
    
    if (copyout(myproc()->pagetable, dst_addr, (char *)&local_buf[copied], sizeof(struct fs_event)) < 0) {
      break; // توقف إذا فشل نسخ الذاكرة لليوزر
    }
    copied++;
  }

  return copied; // إرجاع عدد الأحداث السليمة والمكتوبة كلياً
}
