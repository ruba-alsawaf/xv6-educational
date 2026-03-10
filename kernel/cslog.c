#include "types.h"
#include "riscv.h"
#include "param.h"        
#include "spinlock.h"
#include "defs.h"
#include "proc.h"
#include "cslog.h"
#include "evproto.h"

static struct cs_ring g_csrb;
static uint64 cs_seq = 0;   

static void
csrb_init(struct cs_ring *rb, char *name)
{
  initlock(&rb->lk, name);
  rb->head = rb->tail = rb->count = 0;
}

static int
csrb_read_many(struct cs_ring *rb, struct cs_event *out, int max)
{
  int n = 0;
  acquire(&rb->lk);
  while(n < max && rb->count > 0){
    out[n] = rb->buf[rb->tail];
    rb->tail = (rb->tail + 1) % CS_N;
    rb->count--;
    n++;
  }
  release(&rb->lk);
  return n;
}

void
cslog_init(void)
{
  uartev_init();          // <-- ضيفي هالسطر
  csrb_init(&g_csrb, "cslog");
}

static void
ev_send(struct evrec *e)
{
  uint32 magic = EV_MAGIC;
  uint16 len = sizeof(*e);
  uartev_write(&magic, sizeof(magic));
  uartev_write(&len, sizeof(len));
  uartev_write(e, sizeof(*e));
}

void
cslog_push(struct cs_event *e)
{
  struct cs_event copy;

  acquire(&g_csrb.lk);

  e->seq = ++cs_seq;

  if(g_csrb.count == CS_N){
    g_csrb.tail = (g_csrb.tail + 1) % CS_N;
    g_csrb.count--;
  }

  g_csrb.buf[g_csrb.head] = *e;
  g_csrb.head = (g_csrb.head + 1) % CS_N;
  g_csrb.count++;

  copy = *e;   // snapshot
  release(&g_csrb.lk);

  // send خارج القفل
  struct evrec out = {0};
  out.seq = copy.seq;
  out.tick = copy.ticks;
  out.cpu = copy.cpu;
  out.type = copy.type;
  out.pid = copy.pid;
  out.state = copy.state;
  safestrcpy(out.name, copy.name, sizeof(out.name));
  ev_send(&out);
}


int
cslog_read_many(struct cs_event *out, int max)
{
  if(max <= 0) return 0;
  if(max > 128) max = 128; 
  return csrb_read_many(&g_csrb, out, max);
}

static void
fill_from_proc(struct cs_event *e, struct proc *p)
{
  memset(e, 0, sizeof(*e));
  e->ticks = ticks;
  e->cpu   = cpuid();

  e->pid   = p->pid;
  e->state = p->state;
  safestrcpy(e->name, p->name, CS_NM);
}



void
cslog_run_start(struct proc *p)
{
  if(p == 0) return;
  if(p->pid <= 0) return;
  if(p->name[0] == 0) return; 
  if(strncmp(p->name, "cscat", 5) == 0) return;
  if(strncmp(p->name, "csexport", 8) == 0) return;


  struct cs_event e;
  fill_from_proc(&e, p);
  e.type = CS_RUN_START;
  cslog_push(&e);
}

