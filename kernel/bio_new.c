// Buffer cache - محسّن مع تسجيل تفصيلي للأحداث
//
// نظام Buffer Cache يخزن نسخ مؤقتة من بلوكات القرص الصلب
// يقلل هذا من عدد الوصولات للقرص (الذي يكون بطيئاً)
// كما يوفر نقطة تزامن (synchronization point) للعمليات التي تشارك نفس البلوك
//

#include "types.h"
#include "param.h"
#include "spinlock.h"
#include "sleeplock.h"
#include "riscv.h"
#include "defs.h"
#include "fs.h"
#include "fslog.h"
#include "buf.h"

/**
 * هيكل البفر Cache:
 * - يحتوي على 30 بفر (NBUF)
 * - مرتبة في قائمة مرتبطة: head.next (الأحدث) ... head.prev (الأقدم)
 * - كل بفر يحتوي على بيانات بلوك واحد
 * - يستخدم reference counting لتتبع استخدامات البفر
 * - يستخدم LRU (Least Recently Used) لحذف البفرات القديمة
 */
struct {
  struct spinlock lock;
  struct buf buf[NBUF];

  // قائمة مرتبطة لجميع البفرات، مرتبة حسب الاستخدام الأخير
  // head.next هو الأحدث استخداماً (Most Recently Used)
  // head.prev هو الأقدم استخداماً (Least Recently Used)
  struct buf head;
} bcache;

static int buf_id(struct buf *b);
static int buf_lru_pos(struct buf *target);

/**
 * binit: تهيئة البفر كاش
 * تُستدعى مرة واحدة عند بدء النواة
 * تنشئ قائمة مرتبطة من البفرات والقفل والـ Sleeplock لكل بفر
 */
void
binit(void)
{
  struct buf *b;

  initlock(&bcache.lock, "bcache");

  // إنشاء قائمة مرتبطة من البفرات
  bcache.head.prev = &bcache.head;
  bcache.head.next = &bcache.head;
  
  for(b = bcache.buf; b < bcache.buf+NBUF; b++){
    b->next = bcache.head.next;
    b->prev = &bcache.head;
    initsleeplock(&b->lock, "buffer");
    bcache.head.next->prev = b;
    bcache.head.next = b;
  }
}

/**
 * bget: البحث عن بفر لبلوك معين
 * 
 * الخوارزمية:
 * 1. البحث من الأحدث (MRU) نحو الأقدم - ربما نجد البلوك (HIT)
 * 2. إذا لم نجده، ابحث من الأقدم (LRU) عن بفر فارغ (refcnt == 0)
 * 3. استخدم ذلك البفر القديم (MISS)
 * 
 * العائد: بفر مقفول (locked) وجاهز للاستخدام
 */
static struct buf*
bget(uint dev, uint blockno)
{
  struct buf *b;
  int step = 0;

  acquire(&bcache.lock);

  // ============ المرحلة الأولى: البحث من الأحدث (MRU) ============
  // هنا نبحث عما إذا كان البلوك موجوداً بالفعل
  for(b = bcache.head.next; b != &bcache.head; b = b->next){
    
    // تسجيل كل خطوة بحث (مفيد للتتبع)
    fslog_bget_scan(dev, blockno, buf_id(b),
                    b->refcnt, b->valid, buf_lru_pos(b),
                    1, step,  // scan_dir=1 (forward من MRU)
                    (b->dev == dev && b->blockno == blockno));

    // وجدنا البلوك!
    if(b->dev == dev && b->blockno == blockno){
      int old_ref = b->refcnt;
      int lru = buf_lru_pos(b);

      b->refcnt++;  // زيادة عدد المراجع
      release(&bcache.lock);
      acquiresleep(&b->lock);  // قفل البفر

      // تسجيل الإصابة (HIT)
      fslog_bget_hit(dev, blockno, buf_id(b),
                     old_ref, b->refcnt,
                     b->valid, lru);
      return b;
    }
    step++;
  }

  // ============ المرحلة الثانية: البحث من الأقدم (LRU) ============
  // البلوك غير موجود، نحتاج لبفر فارغ (refcnt == 0)
  step = 0;
  for(b = bcache.head.prev; b != &bcache.head; b = b->prev){
    
    // تسجيل المسح
    fslog_bget_scan(dev, blockno, buf_id(b),
                    b->refcnt, b->valid, buf_lru_pos(b),
                    -1, step,  // scan_dir=-1 (backward من LRU)
                    (b->refcnt == 0));

    // وجدنا بفراً فارغاً!
    if(b->refcnt == 0) {
      int old_block = b->blockno;
      int old_valid = b->valid;
      int lru = buf_lru_pos(b);

      // إعادة استخدام هذا البفر
      b->dev = dev;
      b->blockno = blockno;
      b->valid = 0;  // سيتم ملء البفر لاحقاً
      b->refcnt = 1;

      release(&bcache.lock);
      acquiresleep(&b->lock);

      // تسجيل الإخفاق (MISS)
      fslog_bget_miss(dev, blockno, old_block, buf_id(b),
                      old_valid, lru);
      return b;
    }
    step++;
  }

  panic("bget: no buffers");
}

/**
 * bread: قراءة محتويات بلوك من القرص
 * 
 * الخطوات:
 * 1. احصل على بفر (قد يكون HIT أو MISS)
 * 2. إذا لم يكن البفر صالحاً (valid)، اقرأه من القرص
 * 3. أعد البفر جاهزاً للاستخدام
 */
struct buf*
bread(uint dev, uint blockno)
{
  struct buf *b;

  // تسجيل طلب القراءة
  fslog_bread_req(dev, blockno);

  b = bget(dev, blockno);
  
  // إذا كان البفر جديداً (غير صالح)، اقرأ البيانات من القرص
  if(!b->valid) {
    virtio_disk_rw(b, 0);  // قراءة من القرص (0 = read)
    b->valid = 1;  // الآن البفر صالح
    
    // تسجيل ملء البفر
    fslog_bread_fill(b->dev, b->blockno, buf_id(b), b->refcnt, buf_lru_pos(b));
  }
  
  return b;
}

/**
 * bwrite: كتابة محتويات بفر إلى القرص
 * 
 * يجب أن يكون البفر مقفولاً (locked)
 * سيكتب البيانات إلى القرص الصلب مباشرة
 */
void
bwrite(struct buf *b)
{
  if(!holdingsleep(&b->lock))
    panic("bwrite");

  virtio_disk_rw(b, 1);  // كتابة إلى القرص (1 = write)

  // تسجيل الكتابة
  fslog_bwrite_ev(b->dev, b->blockno, buf_id(b),
                  b->refcnt, b->valid, buf_lru_pos(b));
}

/**
 * brelse: إفراغ البفر
 * 
 * الخطوات:
 * 1. قلل reference count
 * 2. إذا أصبح refcnt = 0، انقل البفر إلى رأس القائمة (الأحدث)
 * 3. هذا يضمن استخدام LRU بشكل صحيح
 */
void
brelse(struct buf *b)
{
  int old_ref, new_ref;
  int old_lru, new_lru;
  int dev_now, blockno_now, bufid_now, valid_now;

  if(!holdingsleep(&b->lock))
    panic("brelse");

  old_ref = b->refcnt;
  old_lru = buf_lru_pos(b);

  releasesleep(&b->lock);

  acquire(&bcache.lock);
  b->refcnt--;

  // إذا لم تعد أي عملية تستخدم هذا البفر
  if (b->refcnt == 0) {
    // انقله إلى رأس القائمة (الأحدث)
    b->next->prev = b->prev;
    b->prev->next = b->next;
    b->next = bcache.head.next;
    b->prev = &bcache.head;
    bcache.head.next->prev = b;
    bcache.head.next = b;
  }

  new_ref = b->refcnt;
  new_lru = buf_lru_pos(b);
  dev_now = b->dev;
  blockno_now = b->blockno;
  bufid_now = buf_id(b);
  valid_now = b->valid;

  release(&bcache.lock);

  // تسجيل الإفراغ
  fslog_brelease_ev(dev_now, blockno_now, bufid_now,
                    old_ref, new_ref,
                    valid_now,
                    old_lru, new_lru);
}

/**
 * bpin: تثبيت البفر (منع حذفه)
 * تُستخدم عندما تريد العملية التأكد من بقاء البفر
 * زيادة reference count
 */
void
bpin(struct buf *b) {
  acquire(&bcache.lock);
  b->refcnt++;
  release(&bcache.lock);
}

/**
 * bunpin: إلغاء تثبيت البفر
 * تقليل reference count
 */
void
bunpin(struct buf *b) {
  acquire(&bcache.lock);
  b->refcnt--;
  release(&bcache.lock);
}

/**
 * buf_id: الحصول على رقم البفر (الفهرس في المصفوفة)
 * مفيد للتتبع والتسجيل
 */
static int
buf_id(struct buf *b)
{
  return (int)(b - bcache.buf);
}

/**
 * buf_lru_pos: الحصول على موضع البفر في قائمة LRU
 * 0 = الأحدث (MRU)
 * NBUF-1 = الأقدم (LRU)
 */
static int
buf_lru_pos(struct buf *target)
{
  int pos = 0;
  struct buf *b;

  for(b = bcache.head.next; b != &bcache.head; b = b->next){
    if(b == target)
      return pos;
    pos++;
  }
  return -1;
}
