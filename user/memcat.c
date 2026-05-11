#include "kernel/types.h"
#include "kernel/stat.h"
#include "kernel/memevent.h"
#include "user/user.h"

static char*
etype(int t)
{
  switch(t){
    case MEM_GROW:   return "GROW";
    case MEM_SHRINK: return "SHRINK";
    case MEM_FAULT:  return "FAULT";
    case MEM_MAP:    return "MAP";
    case MEM_UNMAP:  return "UNMAP";
    case MEM_ALLOC:  return "ALLOC";
    case MEM_FREE:   return "FREE";
    default:         return "UNKNOWN";
  }
}

static char*
permstr(int perm)
{
  static char buf[8];
  int i = 0;
  
  if(perm & (1 << 1)) buf[i++] = 'R';
  if(perm & (1 << 2)) buf[i++] = 'W';
  if(perm & (1 << 3)) buf[i++] = 'X';
  if(perm & (1 << 4)) buf[i++] = 'U';
  buf[i] = '\0';
  
  return buf;
}

static char*
kindstr(int kind)
{
  switch(kind){
    case PAGE_USER:      return "USER";
    case PAGE_PAGETABLE: return "PAGETABLE";
    case PAGE_KERNEL:    return "KERNEL";
    default:             return "UNKNOWN";
  }
}

static char*
esrc(int s)
{
  switch(s){
    case SRC_NONE:       return "NONE";
    case SRC_KALLOC:     return "KALLOC";
    case SRC_KFREE:      return "KFREE";
    case SRC_MAPPAGES:   return "MAPPAGES";
    case SRC_UVMUNMAP:   return "UVMUNMAP";
    case SRC_UVMALLOC:   return "UVMALLOC";
    case SRC_UVMDEALLOC: return "UVMDEALLOC";
    case SRC_VMFAULT:    return "VMFAULT";
    default:             return "UNKNOWN";
  }
}

int
main(void)
{
  struct mem_event ev[16];
  int n, i;

  for(;;){
    n = memread(ev, 16);
    if(n <= 0)
      break;

    for(i = 0; i < n; i++){
     
    
      printf("#%d seq=%d tick=%d cpu=%d pid=%d type=%s src=%s va=%p pa=%p perm=%s kind=%s name=%s old=%p new=%p\n",
        i,
        (int)ev[i].seq,
        ev[i].ticks,
        ev[i].cpu,
        ev[i].pid,
        etype(ev[i].type),
        esrc(ev[i].source),
        (void*)ev[i].va,
        (void*)ev[i].pa,
        permstr(ev[i].perm),
        kindstr(ev[i].kind),
        ev[i].name,
        (void*)ev[i].oldsz,
        (void*)ev[i].newsz);
    }
  }

 

  exit(0);
}