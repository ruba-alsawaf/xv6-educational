// kernel/schedlog.c
#include "types.h"
#include "param.h"
#include "memlayout.h"
#include "riscv.h"
#include "spinlock.h"
#include "defs.h"
#include "ringbuf.h"
#include "schedlog.h"

static struct ringbuf sched_rb;

void
schedlog_init(void)
{
  ringbuf_init(&sched_rb, "schedlog", sizeof(struct sched_event));
}

void
schedlog_emit(struct sched_event *e)
{
  struct sched_event copy;

  memmove(&copy, e, sizeof(copy));
  copy.seq = sched_rb.seq++;
  ringbuf_push(&sched_rb, &copy);
}

int
schedread(struct sched_event *dst, int max)
{
  return ringbuf_read_many(&sched_rb, dst, max);
}