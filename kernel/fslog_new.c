#include "types.h"
#include "riscv.h"
#include "param.h"
#include "spinlock.h"
#include "defs.h"
#include "proc.h"
#include "sleeplock.h"  
#include "fs.h"        
#include "file.h"
#include "ringbuf.h"
#include "fslog.h"

static struct ringbuf fs_rb;
static uint64 fs_seq = 0;

/**
 * تحضير حقول الحدث العامة
 * تملأ هذه الدالة المعلومات الأساسية لكل حدث:
 * - الوقت الحالي (ticks)
 * - معرف العملية الحالية (pid)
 */
static void
fill_fs_common(struct fs_event *e)
{
  memset(e, 0, sizeof(*e));
  e->ticks = ticks;
  e->pid = myproc() ? myproc()->pid : 0;
}

/**
 * fslog_init: تهيئة نظام تسجيل الأحداث
 * يُستدعى مرة واحدة عند بدء النواة
 * ينشئ ring buffer لتخزين الأحداث بكفاءة
 */
void
fslog_init(void)
{
  ringbuf_init(&fs_rb, "fslog", sizeof(struct fs_event));
  printf("FS sizeof(fs_event)=%ld RB_MAX_ELEM=%d\n", sizeof(struct fs_event), RB_MAX_ELEM);
}

/**
 * fslog_push: دفع حدث جديد إلى ring buffer
 * يعطي الحدث رقم تسلسلي فريد ثم يُضيفه إلى الـ buffer
 */
void
fslog_push(struct fs_event *e)
{
  e->seq = ++fs_seq;
  ringbuf_push(&fs_rb, e);
}

/**
 * fslog_read_many: قراءة عدة أحداث من ring buffer
 * تُستخدم من قبل برنامج المستخدم (csexport)
 * تنسخ الأحداث إلى مساحة المستخدم بأمان
 */
int
fslog_read_many(struct fs_event *out, int max)
{
  struct fs_event e;
  int count = 0;
  struct proc *p = myproc();
  
  while(count < max){
    if(ringbuf_pop(&fs_rb, &e) != 0)
      break;

    uint64 dst = (uint64)out + count * sizeof(struct fs_event);

    if(copyout(p->pagetable, dst, (char *)&e, sizeof(struct fs_event)) < 0)
      break;

    count++;
  }

  return count;
}

/* ============================================================================
 * أحداث Buffer Cache (bio.c)
 * هذه الدوال تسجل جميع العمليات على البفرات
 * ============================================================================
 */

/**
 * fslog_bread_req: تسجيل طلب قراءة بلوك
 * يُستدعى عند بداية bread() - قبل أي بحث في الـ cache
 */
void
fslog_bread_req(int dev, int blockno)
{
  struct fs_event e;
  fill_fs_common(&e);
  e.type = FS_BREAD_REQ;
  e.dev = dev;
  e.blockno = blockno;
  safestrcpy(e.name, "BCACHE", FS_NM);
  fslog_push(&e);
}

/**
 * fslog_bget_scan: تسجيل خطوة مسح من خطوات البحث
 * يُستدعى لكل بفر يتم فحصه أثناء البحث
 * يوضح اتجاه البحث (forward=1 من MRU أو backward=-1 من LRU)
 */
void
fslog_bget_scan(int dev, int blockno, int buf_id,
                int refcnt, int valid, int lru_pos,
                int scan_dir, int scan_step, int found)
{
  struct fs_event e;
  fill_fs_common(&e);
  e.type = FS_BGET_SCAN;
  e.dev = dev;
  e.blockno = blockno;
  e.buf_id = buf_id;
  e.ref_before = refcnt;
  e.ref_after = refcnt;
  e.valid_before = valid;
  e.valid_after = valid;
  e.lru_before = lru_pos;
  e.lru_after = lru_pos;
  e.scan_dir = scan_dir;
  e.scan_step = scan_step;
  e.found = found;
  safestrcpy(e.name, "BCACHE", FS_NM);
  fslog_push(&e);
}

/**
 * fslog_bget_hit: تسجيل إصابة في الـ Cache (HIT)
 * يعني أننا وجدنا البلوك المطلوب وهو موجود بالفعل في الذاكرة
 * هذا هو الحالة المثالية - بدون حاجة لقراءة من القرص
 */
void
fslog_bget_hit(int dev, int blockno, int buf_id,
               int ref_before, int ref_after,
               int valid,
               int lru_pos)
{
  struct fs_event e;
  fill_fs_common(&e);
  e.type = FS_BGET_HIT;
  e.dev = dev;
  e.blockno = blockno;
  e.buf_id = buf_id;
  e.ref_before = ref_before;
  e.ref_after = ref_after;
  e.valid_before = valid;
  e.valid_after = valid;
  e.locked_before = 0;
  e.locked_after = 1;
  e.lru_before = lru_pos;
  e.lru_after = lru_pos;
  e.found = 1;
  safestrcpy(e.name, "BCACHE", FS_NM);
  fslog_push(&e);
}

/**
 * fslog_bget_miss: تسجيل إخفاق في الـ Cache (MISS)
 * لم نجد البلوك في الـ Cache
 * نحتاج إلى استخدام بفر قديم (من نهاية LRU)
 */
void
fslog_bget_miss(int dev, int blockno, int old_blockno, int buf_id,
                int old_valid,
                int lru_pos)
{
  struct fs_event e;
  fill_fs_common(&e);
  e.type = FS_BGET_MISS;
  e.dev = dev;
  e.blockno = blockno;
  e.old_blockno = old_blockno;  // البلوك القديم الذي كان موجوداً في هذا البفر
  e.buf_id = buf_id;
  e.ref_before = 0;
  e.ref_after = 1;
  e.valid_before = old_valid;
  e.valid_after = 0;  // إلغاء صحة البفر القديم
  e.locked_before = 0;
  e.locked_after = 1;  // قفل البفر للاستخدام
  e.lru_before = lru_pos;
  e.lru_after = lru_pos;
  e.found = 1;
  safestrcpy(e.name, "BCACHE", FS_NM);
  fslog_push(&e);
}

/**
 * fslog_bread_fill: تسجيل ملء البفر من القرص
 * يُستدعى بعد قراءة البيانات من القرص الصلب
 * البفر الآن يحتوي على البيانات الصحيحة
 */
void
fslog_bread_fill(int dev, int blockno, int buf_id,
                 int refcnt, int lru_pos)
{
  struct fs_event e;
  fill_fs_common(&e);
  e.type = FS_BREAD_FILL;
  e.dev = dev;
  e.blockno = blockno;
  e.buf_id = buf_id;
  e.ref_before = refcnt;
  e.ref_after = refcnt;
  e.valid_before = 0;
  e.valid_after = 1;  // البفر الآن صحيح (valid)
  e.locked_before = 1;
  e.locked_after = 1;  // لا يزال مقفولاً
  e.lru_before = lru_pos;
  e.lru_after = lru_pos;
  safestrcpy(e.name, "BCACHE", FS_NM);
  fslog_push(&e);
}

/**
 * fslog_bwrite_ev: تسجيل كتابة البفر إلى القرص
 * يُستدعى عند bwrite() - عندما تريد العملية حفظ التغييرات
 */
void
fslog_bwrite_ev(int dev, int blockno, int buf_id,
                int refcnt, int valid, int lru_pos)
{
  struct fs_event e;
  fill_fs_common(&e);
  e.type = FS_BWRITE;
  e.dev = dev;
  e.blockno = blockno;
  e.buf_id = buf_id;
  e.ref_before = refcnt;
  e.ref_after = refcnt;
  e.valid_before = valid;
  e.valid_after = valid;
  e.locked_before = 1;
  e.locked_after = 1;  // يبقى مقفولاً
  e.lru_before = lru_pos;
  e.lru_after = lru_pos;
  safestrcpy(e.name, "BCACHE", FS_NM);
  fslog_push(&e);
}

/**
 * fslog_brelease_ev: تسجيل إفراغ البفر
 * يُستدعى عند brelse() - عندما تنتهي العملية من استخدام البفر
 * تقليل reference count وتحديث موضع LRU
 */
void
fslog_brelease_ev(int dev, int blockno, int buf_id,
                  int ref_before, int ref_after,
                  int valid,
                  int lru_before, int lru_after)
{
  struct fs_event e;
  fill_fs_common(&e);
  e.type = FS_BRELEASE;
  e.dev = dev;
  e.blockno = blockno;
  e.buf_id = buf_id;
  e.ref_before = ref_before;
  e.ref_after = ref_after;
  e.valid_before = valid;
  e.valid_after = valid;
  e.locked_before = 1;
  e.locked_after = 0;  // فتح البفر (قفله)
  e.lru_before = lru_before;
  e.lru_after = lru_after;  // قد يتغير موضع LRU
  safestrcpy(e.name, "BCACHE", FS_NM);
  fslog_push(&e);
}

/* ============================================================================
 * أحداث نظام السجل (Log System)
 * تسجيل عمليات الـ Journaling في نظام الملفات
 * ============================================================================
 */

/**
 * fslog_begin: بداية عملية (Transaction Begin)
 * تُستدعى عند begin_op() - قبل بدء أي عملية تعديل على الملفات
 */
void fslog_begin(int before, int after){
  struct fs_event e;
  fill_fs_common(&e);
  e.type = FS_LOG_BEGIN;
  e.ref_before = before;
  e.ref_after = after;
  safestrcpy(e.name, "LOG", FS_NM);
  fslog_push(&e);
}

/**
 * fslog_write: تسجيل كتابة في السجل
 * عندما تُضاف عملية إلى السجل (Log)
 */
void fslog_write(int blockno, int existed, int n_before, int n_after){
  struct fs_event e;
  fill_fs_common(&e);
  e.type = FS_LOG_WRITE;
  e.blockno = blockno;
  e.ref_before = n_before;
  e.ref_after = n_after;
  e.found = existed;
  safestrcpy(e.name, "LOG", FS_NM);
  fslog_push(&e);
}

/**
 * fslog_end: نهاية عملية
 * تُستدعى عند end_op() - بعد انتهاء العملية
 * will_commit يشير إلى ما إذا كان سيتم تأكيد التغييرات
 */
void fslog_end(int before, int after, int will_commit){
  struct fs_event e;
  fill_fs_common(&e);
  e.type = FS_LOG_END;
  e.ref_before = before;
  e.ref_after = after;
  e.found = will_commit;
  safestrcpy(e.name, "LOG", FS_NM);
  fslog_push(&e);
}

/**
 * fslog_writelog: تسجيل كتابة السجل إلى القرص
 */
void fslog_writelog(int blockno, int idx){
  struct fs_event e;
  fill_fs_common(&e);
  e.type = FS_LOG_WLOG;
  e.blockno = blockno;
  e.lru_after = idx;
  safestrcpy(e.name, "LOG", FS_NM);
  fslog_push(&e);
}

/**
 * fslog_writehead: كتابة رأس السجل (Commit)
 * هذه اللحظة الحرجة التي تُثبت جميع التغييرات
 */
void fslog_writehead(int n){
  struct fs_event e;
  fill_fs_common(&e);
  e.type = FS_LOG_WHEAD;
  e.ref_after = n;
  safestrcpy(e.name, "LOG", FS_NM);
  fslog_push(&e);
}

/**
 * fslog_install: تثبيت التغييرات
 * نسخ البيانات من السجل إلى مكانها الدائم
 */
void fslog_install(int blockno){
  struct fs_event e;
  fill_fs_common(&e);
  e.type = FS_LOG_INSTALL;
  e.blockno = blockno;
  safestrcpy(e.name, "LOG", FS_NM);
  fslog_push(&e);
}

/* ============================================================================
 * أحداث تخصيص/تحرير البلوكات (Block Allocation)
 * ============================================================================
 */

/**
 * fslog_balloc: تسجيل تخصيص بلوك جديد
 * عندما تحتاج العملية إلى مساحة جديدة على القرص
 */
void fslog_balloc(int block_allocated) {
    struct fs_event e;
    fill_fs_common(&e);
    e.type = FS_BLOCK_ALLOC;
    e.blockno = block_allocated;
    safestrcpy(e.name, "BALLOC", FS_NM);
    fslog_push(&e);
}

/**
 * fslog_bfree: تسجيل تحرير بلوك
 * عندما يتم حذف ملف وتحرير مساحته
 */
void fslog_bfree(int block_freed) {
    struct fs_event e;
    fill_fs_common(&e);
    e.type = FS_BLOCK_FREE;
    e.blockno = block_freed;
    safestrcpy(e.name, "BFREE", FS_NM);
    fslog_push(&e);
}

/* ============================================================================
 * أحداث الـ Inodes (معالجات الملفات)
 * ============================================================================
 */

/**
 * fslog_ialloc: تسجيل إنشاء inode جديد
 * عندما يتم إنشاء ملف أو مجلد جديد
 */
void fslog_ialloc(int inum, short type) {
    struct fs_event e;
    fill_fs_common(&e);
    e.type = FS_INODE_ALLOC;
    e.inum = inum;
    e.i_type = type;  // نوع الملف
    safestrcpy(e.name, "IALLOC", FS_NM);
    fslog_push(&e);
}

/**
 * fslog_iget: تسجيل جلب inode
 * عندما تريد عملية الوصول إلى معلومات ملف
 */
void fslog_iget(int inum, int ref_before, int ref_after) {
    struct fs_event e;
    fill_fs_common(&e);
    e.type = FS_INODE_GET;
    e.inum = inum;
    e.ref_before = ref_before;
    e.ref_after = ref_after;
    safestrcpy(e.name, "IGET", FS_NM);
    fslog_push(&e);
}

/**
 * fslog_ilock: تسجيل قفل inode
 * قفل معلومات الملف لضمان عدم تعديلها من عمليات أخرى
 */
void fslog_ilock(int inum, int locked) {
    struct fs_event e;
    fill_fs_common(&e);
    e.type = FS_INODE_LOCK;
    e.inum = inum;
    e.locked_after = locked;
    e.ref_after = 1;
    safestrcpy(e.name, "ILOCK", FS_NM);
    fslog_push(&e);
}

/**
 * fslog_iunlock: تسجيل فتح قفل inode
 */
void fslog_iunlock(int inum, int locked) {
    struct fs_event e;
    fill_fs_common(&e);
    e.type = FS_INODE_UNLOCK;
    e.inum = inum;
    e.locked_after = locked;
    safestrcpy(e.name, "IUNLOCK", FS_NM);
    fslog_push(&e);
}

/**
 * fslog_iupdate: تسجيل تحديث معلومات inode
 * عندما يتم تغيير حجم الملف أو الروابط
 */
void fslog_iupdate(struct inode *ip) {
    struct fs_event e;
    fill_fs_common(&e);
    e.type = FS_INODE_UPDATE;
    e.inum = ip->inum;
    e.i_type = ip->type;
    e.i_size = ip->size;
    e.nlink = ip->nlink;
    e.ref_after = ip->ref;
    for(int i=0; i<13; i++) 
        e.addrs[i] = ip->addrs[i];
    safestrcpy(e.name, "IUPDATE", FS_NM);
    fslog_push(&e);
}

/**
 * fslog_iput: تسجيل تحرير inode
 * عندما تنتهي العملية من استخدام الملف
 */
void
fslog_iput(int inum, int old_ref, int new_ref)
{
  struct fs_event e;
  fill_fs_common(&e);
  e.type = FS_INODE_PUT;
  e.inum = inum;
  e.ref_before = old_ref;
  e.ref_after = new_ref;
  safestrcpy(e.name, "IPUT", FS_NM);
  fslog_push(&e);
}

/**
 * fslog_ibmap: تسجيل البحث عن البلوك المرتبط بـ inode
 * عندما تحتاج العملية لمعرفة أين يقع البلوك على القرص
 */
void fslog_ibmap(int inum, uint bn, uint addr) {
    struct fs_event e;
    fill_fs_common(&e);
    e.type = FS_INODE_BMAP;
    e.inum = inum;
    e.blockno = bn;
    e.lru_after = addr;
    safestrcpy(e.name, "IBMAP", FS_NM);
    fslog_push(&e);
}
