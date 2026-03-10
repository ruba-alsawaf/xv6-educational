#pragma once
#include "types.h"
#include "spinlock.h"

#define CS_N   512
#define CS_NM  16

enum {
  CS_RUN_START = 1,
  CS_RUN_END   = 2,
};

struct cs_event {
  uint64 seq;
  uint  ticks;
  int   cpu;
  int   type;
  int   pid;
  int   state;
  char  name[CS_NM];
};

struct cs_ring {
  struct spinlock lk;
  uint head, tail, count;
  struct cs_event buf[CS_N];
};

struct proc;

void cslog_init(void);
void cslog_push(struct cs_event *e);
void cslog_run_start(struct proc *p);
int  cslog_read_many(struct cs_event *out, int max);
