#pragma once
#include "types.h"

#define EV_MAGIC 0x31545645u  // 'EVT1'

struct evrec {
  uint64 seq;
  uint32 tick;
  uint16 cpu;
  uint16 type;
  int    pid;
  int    state;
  char   name[16];
};
