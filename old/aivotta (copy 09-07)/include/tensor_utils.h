#ifndef __TENSOR_UTILS__
#define __TENSOR_UTILS__
#include <stdbool.h>
#include "types.h"


// Simple indexing
#define IND1(tensor, i) (tensor->data + i)
#define IND2(tensor, j, i) (tensor->data + j*tensor->W + i)
#define IND3(tensor, k, j, i) (tensor->data + (k*tensor->H + j)*tensor->W + i)
#define IND3T(tensor, j, i, k) (tensor->data + (j*tensor->W + i)*tensor->C + k)
#define IND4(tensor, l, k, j, i) (tensor->data + ((l*tensor->C + k)*tensor->H + j)*tensor->W + i)
#define IND4T(tensor, j, i, k, l) (tensor->data + ((j*tensor->W + i)*tensor->C + k)*tensor->N + l)

// Size calculation
#define TENSORSIZE(tensor) (unsigned int) tensor->N * tensor->C * tensor->H * tensor->W

//init tensor
struct FloatTensor* floattensor_init(int N, int C, int H, int W, bool zeros);
struct UIntTensor* uinttensor_init(int N, int C, int H, int W, bool zeros);
struct UInt16Tensor* uint16tensor_init(int N, int C, int H, int W, bool zeros);
struct IntTensor* inttensor_init(int N, int C, int H, int W, bool zeros);
struct Int16Tensor* int16tensor_init(int N, int C, int H, int W, bool zeros);

//tensor from file
struct FloatTensor* floattensor_from_file(int N, int C, int H, int W, char *path);
struct FloatTensor2* floattensor2_from_file(int N, int C, int H, int W, char *path);
struct UIntTensor2* uinttensor_from_file(int N, int C, int H, int W, char *path);
struct UInt16Tensor2* uint16tensor_from_file(int N, int C, int H, int W, char *path);
struct Int16Tensor* int16tensor_from_file(int N, int C, int H, int W, char *path);
struct Int16Tensor2* int16tensor2_from_file(int N, int C, int H, int W, char *path);

//tensor to file
void floattensor_to_file(struct FloatTensor *tensor, char *path);
void uinttensor_to_file(struct UIntTensor *tensor, char *path);
void uint16tensor_to_file(struct UInt16Tensor *tensor, char *path);
void int16tensor_to_file(struct Int16Tensor *tensor, char *path);

//free tensor memory
void free_floattensor(struct FloatTensor *tensor);
void free_uinttensor(struct UIntTensor *tensor);
void free_uint16tensor(struct UInt16Tensor *tensor);
void free_inttensor(struct IntTensor *tensor);
void free_int16tensor(struct Int16Tensor *tensor);

#endif
