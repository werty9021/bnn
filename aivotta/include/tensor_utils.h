#ifndef __TENSOR_UTILS__
#define __TENSOR_UTILS__
#include <stdbool.h>
#include "types.h"


// Simple indexing
#define IND1(tensor, i) (tensor->data + i)
#define IND2(tensor, j, i) (tensor->data + j*tensor->W + i)
#define IND3(tensor, k, j, i) (tensor->data + (k*tensor->H + j)*tensor->W + i)
#define IND4(tensor, l, k, j, i) (tensor->data + ((l*tensor->C + k)*tensor->H + j)*tensor->W + i)

// Size calculation
#define TENSORSIZE(tensor) (unsigned int) tensor->N * tensor->C * tensor->H * tensor->W

//init tensor
struct FloatTensor* floattensor_init(int N, int C, int H, int W, bool zeros);
struct UIntTensor* uinttensor_init(int N, int C, int H, int W, bool zeros);
struct IntTensor* inttensor_init(int N, int C, int H, int W, bool zeros);

//tensor from ptr
struct FloatTensor* floattensor_from_ptr(int N, int C, int H, int W, float *data);
struct UIntTensor* uinttensor_from_ptr(int N, int C, int H, int W, uint32_t *data);
struct IntTensor* inttensor_from_ptr(int N, int C, int H, int W, int *data);

//free tensor memory
void free_floattensor(struct FloatTensor *tensor);
void free_uinttensor(struct UIntTensor *tensor);
void free_inttensor(struct IntTensor *tensor);

#endif