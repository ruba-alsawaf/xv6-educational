#include "kernel/types.h"
#include "user/user.h"

int main(void){
  struct cs_event ev[32];
  while(1){
    int n = csread(ev, 32);
    for(int i=0;i<n;i++){
      if(ev[i].type != CS_RUN_START) continue;
      printf("seq=%ld tick=%d cpu=%d pid=%d name=%s state=%d\n",
        ev[i].seq, ev[i].ticks, ev[i].cpu, ev[i].pid, ev[i].name, ev[i].state);
    }
  }
}
