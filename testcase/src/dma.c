#include "dma.h"
#include "tceops.h"

static inline unsigned minu(unsigned arg0, unsigned arg1) {
    return arg0 < arg1 ? arg0 : arg1;
}

__attribute__((__noinline__))
void dma_queue_bursts(unsigned from, unsigned to, const unsigned elements, const unsigned bytes) {
    unsigned length = elements * bytes;
    while (length != 0) {
        // Figure out the longest burst possible within AXI constraints
        // Burst may not cross 4 KB address boundary
        const unsigned src_boundary_distance = AXI_AS_BOUNDARY - (to & (AXI_AS_BOUNDARY-1));
        const unsigned dst_boundary_distance = AXI_AS_BOUNDARY - (from & (AXI_AS_BOUNDARY-1));
        const unsigned boundary_check_max = minu(src_boundary_distance, dst_boundary_distance);
        // Burst may not exceed 256 words, but unaligned 256-word transfers
        // might take 1 word extra
        unsigned burst_len;
        if (((from | to) & 3) == 0) {
            burst_len = minu(MAX_BURST_LENGTH, length);
        } else {
            burst_len = minu(MAX_UNALIGNED_BURST_LENGTH, length);
        }
        burst_len = minu(boundary_check_max, burst_len);
        unsigned burst_len_actual = burst_len - 1;
        _TCE_BURST_BC(burst_len_actual, from, to);
        length -= burst_len;
        from += burst_len;
        to += burst_len;
    }
}

__attribute__((noinline))
void dma_wait(){
    // wait until transfer finishes
    volatile unsigned int status = 0;
    while (status == 0) {
        _TCE_STATUS_BC(status, status);
    }
}