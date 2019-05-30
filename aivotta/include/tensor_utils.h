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

//tensor from file
struct FloatTensor2* floattensor_from_file(int N, int C, int H, int W, char *path);
struct UIntTensor2* uinttensor_from_file(int N, int C, int H, int W, char *path);

//tensor to file
void floattensor_to_file(struct FloatTensor *tensor, char *path);
void uinttensor_to_file(struct UIntTensor *tensor, char *path);

//free tensor memory
void free_floattensor(struct FloatTensor *tensor);
void free_uinttensor(struct UIntTensor *tensor);

#endif