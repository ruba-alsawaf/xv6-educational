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
  FS_BRELEASE   = 7
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