#include "types.h"
#include "riscv.h"
#include "param.h"
#include "defs.h"
#include "proc.h"
#include "memevent.h"
#include "memlog.h"

uint64
sys_memread(void)
{
  uint64 uaddr = 0;
  int max = 0;

  argaddr(0, &uaddr);
  argint(1, &max);

  if(max <= 0)
    return 0;
  if(max > 64)
    max = 64;

  struct mem_event tmp[64];
  int n = memlog_read_many(tmp, max);

  int bytes = n * (int)sizeof(struct mem_event);
  if(copyout(myproc()->pagetable, uaddr, (char *)tmp, bytes) < 0)
    return -1;

  return n;
}