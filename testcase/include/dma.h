#pragma once
#include "tceops.h"

#define AXI_BUS_WIDTH 4
#define MAX_BURST_LENGTH (256*AXI_BUS_WIDTH)
#define MAX_UNALIGNED_BURST_LENGTH ((256-1)*AXI_BUS_WIDTH)
#define AXI_AS_BOUNDARY (1024*4)

void dma_queue_bursts(unsigned from, unsigned to, const unsigned elements, const unsigned bytes);


__attribute__((noinline)) void dma_wait();