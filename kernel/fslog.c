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
static void
fill_fs_common(struct fs_event *e)
{
  memset(e, 0, sizeof(*e));
  e->ticks = ticks;
  e->pid = myproc() ? myproc()->pid : 0;
}

void
fslog_init(void)
{
  ringbuf_init(&fs_rb, "fslog", sizeof(struct fs_event));
  printf("FS sizeof(fs_event)=%ld RB_MAX_ELEM=%d\n", sizeof(struct fs_event), RB_MAX_ELEM);
}

void
fslog_push(struct fs_event *e)
{ e->seq = ++fs_seq;
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

    uint64 dst = (uint64)out + count * sizeof(struct fs_event);

    if(copyout(p->pagetable, dst, (char *)&e, sizeof(struct fs_event)) < 0)
      break;

    count++;
  }

  return count;
}
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
  e.old_blockno = old_blockno;
  e.buf_id = buf_id;
  e.ref_before = 0;
  e.ref_after = 1;
  e.valid_before = old_valid;
  e.valid_after = 0;
  e.locked_before = 0;
  e.locked_after = 1;
  e.lru_before = lru_pos;
  e.lru_after = lru_pos;
  e.found = 1;
  safestrcpy(e.name, "BCACHE", FS_NM);
  fslog_push(&e);
}
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
  e.valid_after = 1;
  e.locked_before = 1;
  e.locked_after = 1;
  e.lru_before = lru_pos;
  e.lru_after = lru_pos;
  safestrcpy(e.name, "BCACHE", FS_NM);
  fslog_push(&e);
}
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
  e.locked_after = 1;
  e.lru_before = lru_pos;
  e.lru_after = lru_pos;
  safestrcpy(e.name, "BCACHE", FS_NM);
  fslog_push(&e);
}
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
  e.locked_after = 0;
  e.lru_before = lru_before;
  e.lru_after = lru_after;
  safestrcpy(e.name, "BCACHE", FS_NM);
  fslog_push(&e);
}
void fslog_begin(int before, int after){
  struct fs_event e;
  fill_fs_common(&e);

  e.type = FS_LOG_BEGIN;
  e.ref_before = before;
  e.ref_after = after;

  safestrcpy(e.name, "LOG", FS_NM);
  fslog_push(&e);
}
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
void fslog_writelog(int blockno, int idx){
  struct fs_event e;
  fill_fs_common(&e);
  e.type = FS_LOG_WLOG;
  e.blockno = blockno;
  e.lru_after = idx;
  safestrcpy(e.name, "LOG", FS_NM);
  fslog_push(&e);
}

void fslog_writehead(int n){
  struct fs_event e;
  fill_fs_common(&e);
  e.type = FS_LOG_WHEAD;
  e.ref_after = n;
  safestrcpy(e.name, "LOG", FS_NM);
  fslog_push(&e);
}

void fslog_install(int blockno){
  struct fs_event e;
  fill_fs_common(&e);
  e.type = FS_LOG_INSTALL;
  e.blockno = blockno;
  safestrcpy(e.name, "LOG", FS_NM);
  fslog_push(&e);
}
void fslog_balloc(int block_allocated) {
    struct fs_event e;
    fill_fs_common(&e);
    e.type = FS_BLOCK_ALLOC;
    e.blockno = block_allocated; // البلوك الذي تم حجزه فعلياً
    safestrcpy(e.name, "BALLOC", FS_NM);
    fslog_push(&e);
}
void fslog_bfree(int block_freed) {
    struct fs_event e;
    fill_fs_common(&e);
    e.type = FS_BLOCK_FREE;
    e.blockno = block_freed; // البلوك الذي تم تحريره
    safestrcpy(e.name, "BFREE", FS_NM);
    fslog_push(&e);
}
void fslog_ialloc(int inum, short type) {
    struct fs_event e;
    fill_fs_common(&e);
    e.type = FS_INODE_ALLOC;
    e.inum = inum;
    e.i_type = type;
    safestrcpy(e.name, "IALLOC", FS_NM);
    fslog_push(&e);
}

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
// في ملف kernel/fslog.c

void fslog_ilock(int inum, int locked) {
    struct fs_event e;
    fill_fs_common(&e);
    e.type = FS_INODE_LOCK;
    e.inum = inum;
    e.locked_after = locked; // 1 للـ Lock و 0 للـ Unlock
    e.ref_after = 1; // لضمان بقاء السطر في الواجهة
    safestrcpy(e.name, "ILOCK", FS_NM);
    fslog_push(&e);
}

void fslog_iupdate(struct inode *ip) {
    struct fs_event e;
    fill_fs_common(&e);
    e.type = FS_INODE_UPDATE;
    e.inum = ip->inum;
    e.i_type = ip->type;
    e.i_size = ip->size;
    e.nlink = ip->nlink;
    e.ref_after = ip->ref; // مهم جداً للواجهة
    for(int i=0; i<13; i++) e.addrs[i] = ip->addrs[i];
    safestrcpy(e.name, "IUPDATE", FS_NM);
    fslog_push(&e);
}
// داخل ملف kernel/fslog.c

void
fslog_iput(int inum, int old_ref, int new_ref)
{
  struct fs_event e;
  fill_fs_common(&e);
  e.type = FS_INODE_PUT; // تأكدي أن هذا الرقم (مثلاً 42) معرف في الـ Header
  e.inum = inum;
  e.ref_before = old_ref;
  e.ref_after = new_ref;
  safestrcpy(e.name, "IPUT", FS_NM);
  fslog_push(&e);
}