// kernel/procinfo.h
#ifndef XV6_PROCINFO_H
#define XV6_PROCINFO_H

#include "types.h"
#include "param.h"

#define PROC_STATE_COUNT 6
#define PROC_NAME_LEN 16

struct cpu_info {
  int cpu;
  int active;
  int current_pid;
  int current_state;
  char current_name[PROC_NAME_LEN];
  int last_pid;
  int last_state;
  char last_name[PROC_NAME_LEN];
  uint64 active_ticks;
  int busy_percent;
};

struct proc_stats {
  uint64 current_count[PROC_STATE_COUNT];
  uint64 unique_count[PROC_STATE_COUNT];
  uint64 total_created;
  uint64 total_exited;
};

#endif
