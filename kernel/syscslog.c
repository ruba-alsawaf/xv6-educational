#include "types.h"
#include "riscv.h"
#include "param.h"     // ✅ لازم قبل proc.h
#include "defs.h"
#include "proc.h"
#include "cslog.h"


uint64
sys_csread(void)
{
  uint64 uaddr = 0;
  int max = 0;

  // ✅ عندك argaddr/argint void، فبنستدعيهم بدون if
  argaddr(0, &uaddr);
  argint(1, &max);

  if(max <= 0) return 0;
  if(max > 64) max = 64;

  struct cs_event tmp[64];
  int n = cslog_read_many(tmp, max);

  int bytes = n * (int)sizeof(struct cs_event);
  if(copyout(myproc()->pagetable, uaddr, (char*)tmp, bytes) < 0)
    return -1;

  return n;
}
