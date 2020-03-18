#pragma once

#define _pmem __attribute__((address_space(1))) // PMEM
// #define _global __attribute__((address_space(2))) // AXI

#define FPGA 1
#if FPGA
#define DMEM_OFFSET 0x43c80000 //0x43C40000
#define PMEM_OFFSET 0x43cc0000 //0x43C60000
#else
#define DMEM_OFFSET 0x0
#define PMEM_OFFSET 0x0
#endif

#define ZPAD 1
#define DMA_sw 1

// global
#define O_y 48 // Output map height
#define O_x 32 // Output map width
#define O_n 1 // Batch size

// Conv properties
// Kernel size
#define K_y 3
#define K_x 3
// Padding size
#define P_y 1
#define P_x 1 

// Pointer meth macro's
#define IND2(j, i, I) (j*I + i)
#define IND3(k, j, J, i, I) IND2(IND2(k, j, J), i, I)
#define IND4(l, k, K, j, J, i, I) IND2(IND3(l, k, K, j, J), i, I)

#define AXI_BUS_WIDTH 4
#define MAX_BURST_LENGTH (256*AXI_BUS_WIDTH)
#define MAX_UNALIGNED_BURST_LENGTH ((256-1)*AXI_BUS_WIDTH)
#define AXI_AS_BOUNDARY (1024*4)