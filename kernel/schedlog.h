// kernel/schedlog.h
#ifndef XV6_SCHEDLOG_H
#define XV6_SCHEDLOG_H

#include "types.h"

#define SCHED_NAME_LEN 16
#define PROC_NAME_LEN  16

enum sched_event_type {
  SCHED_EV_INFO = 1,
  SCHED_EV_ON_CPU,
  SCHED_EV_OFF_CPU,
};

enum sched_offcpu_reason {
  SCHED_OFF_UNKNOWN = 0,
  SCHED_OFF_QUANTUM,
  SCHED_OFF_SLEEP,
  SCHED_OFF_YIELD,
  SCHED_OFF_EXIT,
};

struct sched_event {
  uint seq;
  uint ticks;

  int event_type;

  // system-wide scheduler info
  char scheduler_name[SCHED_NAME_LEN];
  int num_cpus;
  int time_slice;

  // per-process runtime info
  int cpu;
  int pid;
  char name[PROC_NAME_LEN];
  int state;
  int reason;
};

void schedlog_init(void);
void schedlog_emit(struct sched_event *e);
int schedread(struct sched_event *dst, int max);

#endif