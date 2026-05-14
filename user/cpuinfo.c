#include "user/user.h"
#include "kernel/procinfo.h"

static const char *state_names[PROC_STATE_COUNT] = {
  "UNUSED", "USED", "SLEEPING", "RUNNABLE", "RUNNING", "ZOMBIE"
};

int
main(void)
{
  struct cpu_info cpus[NCPU];
  struct proc_stats stats;
  int n;

  n = getcpuinfo(cpus, NCPU);
  if (n < 0 || getprocstats(&stats) < 0) {
    printf("Error fetching system info\n");
    exit(1);
  }

  printf("CPU {\"timestamp\":\"now\",\"system\":{");
  printf("\"total_created\":%lu,\"total_exited\":%lu,", stats.total_created, stats.total_exited);
  printf("\"ever_running\":%lu,\"ever_sleeping\":%lu,\"ever_zombie\":%lu},", 
          stats.unique_count[4], stats.unique_count[2], stats.unique_count[5]);

  printf("\"cpus\":[");
  for (int i = 0; i < n; i++) {
    printf("{\"cpu_id\":\"cpu%d\",\"active\":%d,\"current_pid\":%d,\"current_state\":\"%s\",\"busy_percent\":%d}",
           cpus[i].cpu, cpus[i].active, cpus[i].current_pid,
           cpus[i].current_state < PROC_STATE_COUNT ? state_names[cpus[i].current_state] : "UNK",
           cpus[i].busy_percent);
    
    if (i < n - 1) printf(",");
  }
  printf("]}\n");

  exit(0);
}
