#pragma once
#include "types.h"

#define CS_NM 16

enum {
  CS_RUN_START = 1,
  CS_RUN_END   = 2,
};

struct cs_event {
  uint64 seq;
  uint  ticks;
  int   cpu;
  int   type;
  int   pid;
  int   state;
  char  name[CS_NM];
};
