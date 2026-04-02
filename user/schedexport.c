#include "kernel/types.h"
#include "kernel/schedlog.h"
#include "user/user.h"

static void
print_sched_event(const struct sched_event *e)
{
  if(e->event_type == SCHED_EV_INFO){
    printf("EV {\"seq\":%d,\"tick\":%d,\"type\":\"SCHED_INFO\",\"scheduler\":\"%s\",\"cpus\":%d,\"time_slice\":%d}\n",
      e->seq, e->ticks, e->scheduler_name, e->num_cpus, e->time_slice);
  } else if(e->event_type == SCHED_EV_ON_CPU){
    printf("EV {\"seq\":%d,\"tick\":%d,\"type\":\"ON_CPU\",\"cpu\":%d,\"pid\":%d,\"name\":\"%s\",\"state\":%d}\n",
      e->seq, e->ticks, e->cpu, e->pid, e->name, e->state);
  } else if(e->event_type == SCHED_EV_OFF_CPU){
    printf("EV {\"seq\":%d,\"tick\":%d,\"type\":\"OFF_CPU\",\"cpu\":%d,\"pid\":%d,\"name\":\"%s\",\"state\":%d,\"reason\":%d}\n",
      e->seq, e->ticks, e->cpu, e->pid, e->name, e->state, e->reason);
  }
}

int
main(void)
{
  struct sched_event ev[16];

  for(int round = 0; round < 5; round++){
    int n = schedread(ev, 16);
    printf("round=%d n=%d\n", round, n);

    for(int i = 0; i < n; i++){
      print_sched_event(&ev[i]);
    }

    pause(10);
  }

  exit(0);
}