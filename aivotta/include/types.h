#pragma once
#include <stdint.h>

struct Dim2d { 
   int x, y; 
}; 

struct FloatTensor {
   int N, C, H, W; // Dimensions of data
   float *data; // Storage
};
#define __dataBufAligned __attribute__((address_space(1), aligned(32)))

struct FloatTensor2 {
   int N, C, H, W; // Dimensions of data
   float __dataBufAligned *data; // Storage
};

struct UIntTensor {
   int N, C, H, W; // Dimensions of data
   uint32_t *data; // Storage
};

struct UIntTensor2 {
   int N, C, H, W; // Dimensions of data
   uint32_t __dataBufAligned *data; // Storage
};
