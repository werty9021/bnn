#ifndef __TENSOR__
#define __TENSOR__
#include <stdint.h>

struct Dim2d { 
   int x, y; 
}; 

struct Dim3d { 
   int x, y, z; 
}; 
typedef float float16 __attribute__((vector_size (64)));

struct FloatTensor {
   int N, C, H, W; // Dimensions of data
   float *data __attribute__((aligned(16))); // Storage
};

struct UIntTensor {
   int N, C, H, W; // Dimensions of data
   uint32_t *data; // Storage
};

struct IntTensor {
   int N, C, H, W; // Dimensions of data
   int *data; // Storage
};

struct Int16Tensor {
   int N, C, H, W; // Dimensions of data
   int16_t *data; // Storage
};

#endif