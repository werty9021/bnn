#pragma once
#include "tceops.h"
#include "settings.h"

int dma_queue_bursts(unsigned from, unsigned to, const unsigned elements, const unsigned bytes);

inline void dma_wait(){
    // wait until transfer finishes
    volatile unsigned int status = 0;
    while (status == 0) {
        _TCE_STATUS_BC(status, status);
    }
}