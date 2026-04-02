#pragma once
#include "types.h"

#define MEM_NM 16

enum mem_event_type {
  MEM_GROW = 1,
  MEM_SHRINK,
  MEM_FAULT,
  MEM_MAP,
  MEM_UNMAP,
  MEM_ALLOC,
  MEM_FREE
};

enum mem_event_source {
  SRC_NONE = 0,
  SRC_KALLOC,
  SRC_KFREE,
  SRC_MAPPAGES,
  SRC_UVMUNMAP,
  SRC_UVMALLOC,
  SRC_UVMDEALLOC,
  SRC_VMFAULT
};

enum mem_page_kind {
  PAGE_UNKNOWN = 0,
  PAGE_USER,
  PAGE_PAGETABLE,
  PAGE_KERNEL
};

struct mem_event {
  uint64 seq;        // event sequence number
  uint   ticks;      // system ticks at event time
  int    cpu;        // cpu id
  int    type;       // mem_event_type
  int    pid;        // process id
  int    state;      // process state if available
  char   name[MEM_NM];

  uint64 va;         // virtual address
  uint64 pa;         // physical address
  uint64 oldsz;      // old process size
  uint64 newsz;      // new process size
  uint64 len;        // length or page size
  int    perm;       // page permissions
  int    source;     // mem_event_source
  int    kind;       // mem_page_kind
};