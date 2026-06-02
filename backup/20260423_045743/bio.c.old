// Buffer cache.
//
// The buffer cache is a linked list of buf structures holding
// cached copies of disk block contents.  Caching disk blocks
// in memory reduces the number of disk reads and also provides
// a synchronization point for disk blocks used by multiple processes.
//
// Interface:
// * To get a buffer for a particular disk block, call bread.
// * After changing buffer data, call bwrite to write it to disk.
// * When done with the buffer, call brelse.
// * Do not use the buffer after calling brelse.
// * Only one process at a time can use a buffer,
//     so do not keep them longer than necessary.


#include "types.h"
#include "param.h"
#include "spinlock.h"
#include "sleeplock.h"
#include "riscv.h"
#include "defs.h"
#include "fs.h"
#include "fslog.h"
#include "buf.h"

struct {
  struct spinlock lock;
  struct buf buf[NBUF];

  // Linked list of all buffers, through prev/next.
  // Sorted by how recently the buffer was used.
  // head.next is most recent, head.prev is least.
  struct buf head;
} bcache;
static int buf_id(struct buf *b);
static int buf_lru_pos(struct buf *target);

void
binit(void)
{
  struct buf *b;

  initlock(&bcache.lock, "bcache");

  // Create linked list of buffers
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

// Look through buffer cache for block on device dev.
// If not found, allocate a buffer.
// In either case, return locked buffer.
static struct buf*
bget(uint dev, uint blockno)
{
  struct buf *b;
  int step = 0;

  acquire(&bcache.lock);

  // search from MRU side
  for(b = bcache.head.next; b != &bcache.head; b = b->next){
    fslog_bget_scan(dev, blockno, buf_id(b),
                    b->refcnt, b->valid, buf_lru_pos(b),
                    1, step,
                    (b->dev == dev && b->blockno == blockno));

    if(b->dev == dev && b->blockno == blockno){
      int old_ref = b->refcnt;
      int lru = buf_lru_pos(b);

      b->refcnt++;
      release(&bcache.lock);
      acquiresleep(&b->lock);

      fslog_bget_hit(dev, blockno, buf_id(b),
                     old_ref, b->refcnt,
                     b->valid, lru);
      return b;
    }
    step++;
  }

  // recycle from LRU side
  step = 0;
  for(b = bcache.head.prev; b != &bcache.head; b = b->prev){
    fslog_bget_scan(dev, blockno, buf_id(b),
                    b->refcnt, b->valid, buf_lru_pos(b),
                    -1, step,
                    (b->refcnt == 0));

    if(b->refcnt == 0) {
      int old_block = b->blockno;
      int old_valid = b->valid;
      int lru = buf_lru_pos(b);

      b->dev = dev;
      b->blockno = blockno;
      b->valid = 0;
      b->refcnt = 1;

      release(&bcache.lock);
      acquiresleep(&b->lock);

      fslog_bget_miss(dev, blockno, old_block, buf_id(b),
                      old_valid, lru);
      return b;
    }
    step++;
  }

  panic("bget: no buffers");
}

// Return a locked buf with the contents of the indicated block.
struct buf*
bread(uint dev, uint blockno)
{
  struct buf *b;

  fslog_bread_req(dev, blockno);

  b = bget(dev, blockno);
  if(!b->valid) {
    virtio_disk_rw(b, 0);
    b->valid = 1;
    fslog_bread_fill(b->dev, b->blockno, buf_id(b), b->refcnt, buf_lru_pos(b));
  }
  return b;
}

// Write b's contents to disk.  Must be locked.
void
bwrite(struct buf *b)
{
  if(!holdingsleep(&b->lock))
    panic("bwrite");

  virtio_disk_rw(b, 1);

  fslog_bwrite_ev(b->dev, b->blockno, buf_id(b),
                  b->refcnt, b->valid, buf_lru_pos(b));
}

// Release a locked buffer.
// Move to the head of the most-recently-used list.
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

  if (b->refcnt == 0) {
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

  fslog_brelease_ev(dev_now, blockno_now, bufid_now,
                    old_ref, new_ref,
                    valid_now,
                    old_lru, new_lru);
}
void
bpin(struct buf *b) {
  acquire(&bcache.lock);
  b->refcnt++;
  release(&bcache.lock);
}

void
bunpin(struct buf *b) {
  acquire(&bcache.lock);
  b->refcnt--;
  release(&bcache.lock);
}

static int
buf_id(struct buf *b)
{
  return (int)(b - bcache.buf);
}

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
