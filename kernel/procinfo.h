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
  char proc_name[PROC_NAME_LEN];
  int current_state;
  int last_pid;
  int last_state;
  uint64 active_ticks;
  uint64 context_eip;
  uint64 context_esp;
  int busy_percent;
};

struct proc_stats {
  uint64 current_count[PROC_STATE_COUNT];
  uint64 unique_count[PROC_STATE_COUNT];
  uint64 total_created;
  uint64 total_exited;
};

struct lock_info {
  char lock_name[32]; // اسم القفل
  int  pid;           // رقم العملية اللي ماسكته
  uint hold_time;     // وقت الحجز
  uint acq_count;
  char proc_name[16];
  int  cpu_id;
  uint contention;
};
#endif
