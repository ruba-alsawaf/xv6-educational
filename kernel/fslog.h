#pragma once
#include "types.h"
#include "ringbuf.h"

#define FS_NM 16

enum {
  FS_BREAD_REQ  = 1,
  FS_BGET_SCAN  = 2,
  FS_BGET_HIT   = 3,
  FS_BGET_MISS  = 4,
  FS_BREAD_FILL = 5,
  FS_BWRITE     = 6,
  FS_BRELEASE   = 7,
  FS_LOG_BEGIN  =   20,
  FS_LOG_WRITE   =  21,
  FS_LOG_END    =   22,
  FS_LOG_WLOG   =   23,
  FS_LOG_WHEAD   =  24,
  FS_LOG_INSTALL =  25 ,
  FS_BLOCK_ALLOC = 30, 
  FS_BLOCK_FREE  = 31 ,
  FS_INODE_ALLOC   = 40, 
  FS_INODE_GET     = 41,
  FS_INODE_PUT     = 42,
  FS_INODE_LOCK    = 43,
  FS_INODE_UNLOCK  = 44,
  FS_INODE_UPDATE  = 45,
  FS_INODE_BMAP    = 46 
};

struct fs_event {
  uint64 seq;
  uint   ticks;
  int    type;
  int    pid;

  int    dev;
  int    blockno;
  int    old_blockno;

  int    buf_id;

  int    ref_before;
  int    ref_after;

  int    valid_before;
  int    valid_after;

  int    locked_before;
  int    locked_after;

  int    lru_before;
  int    lru_after;

  int    scan_dir;   // 1 forward, -1 backward
  int    scan_step;
  int    found;

  uint   size;
  char   name[FS_NM];
  int log_index;

  int lh_n;
  int outstanding;
  int inum;          // رقم الـ Inode
  short i_type;      // نوع الملف (File, Dir, Dev)
  int nlink;         // عدد الروابط
  uint i_size;       // حجم الملف
  int addrs[13];     // مصفوفة البلوكات (12 Direct + 1 Indirect)
};

void fslog_init(void);
void fslog_push(struct fs_event *e);
int  fslog_read_many(struct fs_event *out, int max);

// wrappers جاهزين للاستدعاء من bio.c
void fslog_bread_req(int dev, int blockno);
void fslog_bget_scan(int dev, int blockno, int buf_id,
                     int refcnt, int valid, int lru_pos,
                     int scan_dir, int scan_step, int found);

void fslog_bget_hit(int dev, int blockno, int buf_id,
                    int ref_before, int ref_after,
                    int valid,
                    int lru_pos);

void fslog_bget_miss(int dev, int blockno, int old_blockno, int buf_id,
                     int old_valid,
                     int lru_pos);

void fslog_bread_fill(int dev, int blockno, int buf_id,
                      int refcnt, int lru_pos);

void fslog_bwrite_ev(int dev, int blockno, int buf_id,
                     int refcnt, int valid, int lru_pos);

void fslog_brelease_ev(int dev, int blockno, int buf_id,
                       int ref_before, int ref_after,
                       int valid,
                       int lru_before, int lru_after);
                       void log_begin_op_ev(int outstanding);
void fslog_begin(int before, int after);               
void fslog_write(int blockno, int existed, int n_before, int n_after);
void fslog_end(int before, int after, int will_commit);
void fslog_writelog(int blockno, int idx);
void fslog_writehead(int n);
void fslog_install(int blockno);
void fslog_balloc(int block_allocated);
void fslog_bfree(int block_freed);
void fslog_ialloc(int inum, short type);
void fslog_iget(int inum, int ref_before, int ref_after);
void fslog_iput(int inum, int ref_before, int ref_after);
void fslog_ilock(int inum, int locked);
void fslog_iunlock(int inum, int locked);
#ifndef USER
struct inode;
void fslog_iupdate(struct inode *ip);
#endif
void fslog_ibmap(int inum, uint bn, uint addr);