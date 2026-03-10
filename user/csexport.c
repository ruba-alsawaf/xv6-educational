#include "kernel/types.h"
#include "user/user.h"

// لازم يكون struct cs_event و CS_RUN_START معرفين عندك عبر user/user.h
// (أو عبر header مشترك إذا عملتيه)

static void
print_json_event(struct cs_event *e)
{
  // JSONL + Prefix ثابت للـ host parser
  // لاحظي: منخلي type نصي ثابت لأنه حاليا بس RUN_START
  printf("EV {\"seq\":%d,\"tick\":%d,\"cpu\":%d,\"pid\":%d,"
         "\"name\":\"%s\",\"state\":%d,\"type\":\"ON_CPU\"}\n",
         (uint)e->seq, e->ticks, e->cpu, e->pid, e->name, e->state);
}

int
main(void)
{
  struct cs_event ev[64];

  while(1){
    int n = csread(ev, 64);
    for(int i = 0; i < n; i++){
      if(ev[i].type != CS_RUN_START)
        continue;

      print_json_event(&ev[i]);
    }

    // بدون sleep حاليا مثل ما طلبتي، بس إذا صار spam كبير ضيفيه لاحقًا
    // sleep(1);
  }
}
