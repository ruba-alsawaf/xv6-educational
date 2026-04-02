#pragma once
#include "memevent.h"

void memlog_init(void);
void memlog_push(struct mem_event *e);
int  memlog_read_many(struct mem_event *out, int max);