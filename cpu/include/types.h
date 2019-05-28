#ifndef __TENSOR__
#define __TENSOR__
#include <stdint.h>

struct Dim2d { 
   int x, y; 
}; 

struct Dim3d { 
   int x, y, z; 
}; 

struct FloatTensor {
   int N, C, H, W; // Dimensions of data
   float *data; // Storage
};

struct UIntTensor {
   int N, C, H, W; // Dimensions of data
   __uint32_t *data; // Storage
};

struct IntTensor {
   int N, C, H, W; // Dimensions of data
   int *data; // Storage
};

#endif