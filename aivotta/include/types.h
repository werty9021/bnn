#pragma once
#include <stdint.h>

struct Dim2d { 
   int x, y; 
}; 

struct FloatTensor {
   int N, C, H, W; // Dimensions of data
   float *data; // Storage
};

struct UIntTensor {
   int N, C, H, W; // Dimensions of data
   uint32_t *data; // Storage
};

struct IntTensor {
   int N, C, H, W; // Dimensions of data
   int *data; // Storage
};
