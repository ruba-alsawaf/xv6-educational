#include "user/user.h"
#include "kernel/procinfo.h"
#include "kernel/types.h"
#include "kernel/fslog.h"

#define OUTBUF_SZ 1024  

// المصفوفات العالمية لحماية الـ Stack
static struct cpu_info cpus[NCPU];
static struct proc_stats stats;
static struct cs_event cs_ev[256];
static struct fs_event fs_ev[256];

static const char *state_names[PROC_STATE_COUNT] = {
  "UNUSED",
  "USED",
  "SLEEPING",
  "RUNNABLE",
  "RUNNING",
  "ZOMBIE",
};

int
main(void)
{
  struct cpu_info cpus[NCPU];
  struct proc_stats stats;
  int n;

  n = getcpuinfo(cpus, NCPU);
  if (n < 0) {
    printf("getcpuinfo failed\n");
    exit(1);
  }

  int active = 0;
  for (int i = 0; i < n; i++) {
    if (cpus[i].active)
      active++;
  }

  printf("CPUs returned: %d active: %d\n", n, active);
  for (int i = 0; i < n; i++) {
    printf("CPU {\"cpu\":%d,\"active\":%d,\"current_pid\":%d,\"current_state\":\"%s\",\"last_pid\":%d,\"last_state\":\"%s\",\"busy_percent\":%d,\"active_ticks\":%lu}\n",
           cpus[i].cpu,
           cpus[i].active,
           cpus[i].current_pid,
           cpus[i].current_state >= 0 && cpus[i].current_state < PROC_STATE_COUNT ? state_names[cpus[i].current_state] : "UNKNOWN",
           cpus[i].last_pid,
           cpus[i].last_state >= 0 && cpus[i].last_state < PROC_STATE_COUNT ? state_names[cpus[i].last_state] : "UNKNOWN",
           cpus[i].busy_percent,
           cpus[i].active_ticks);
  }

  if (getprocstats(&stats) < 0) {
    printf("getprocstats failed\n");
    exit(1);
  }

  printf("\nprocess stats:\n");
  printf(" total created = %lu\n", stats.total_created);
  printf(" total exited  = %lu\n", stats.total_exited);
  for (int i = 0; i < PROC_STATE_COUNT; i++) {
    printf(" current %s = %lu  unique %s = %lu\n",
           state_names[i], stats.current_count[i],
           state_names[i], stats.unique_count[i]);
  }

    // 2. قراءة أحداث المعالج - اقرأ 256 حدث بنسخة واحدة
    int n_cs = csread(cs_ev, 256);
    for (int i = 0; i < n_cs; i++) {
        if (cs_ev[i].type == 1) 
            print_cs_event(&cs_ev[i]);
    }

    // 3. قراءة أحداث نظام الملفات - اقرأ 256 حدث بنسخة واحدة
    int n_fs = fsread(fs_ev, 256);
    for (int i = 0; i < n_fs; i++) {
        if (fs_ev[i].seq != 0) {
            print_fs_event(&fs_ev[i]);
        }
    }
    
    exit(0); 
}
