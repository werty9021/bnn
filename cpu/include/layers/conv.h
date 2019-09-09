#ifndef __LAYERS_CONV__
#define __LAYERS_CONV__
#include "types.h"

void conv2d_pad(int H, int W, int Do, int Di, int Dy, int Dx, int Ky, int Kx, int Py, int Px, float *input, float *weights, float *output);
void conv2d_skip(int H, int W, int Do, int Di, int Dy, int Dx, int Ky, int Kx, int Py, int Px, float *input, float *weights, float *output);

struct IntTensor* conv2d(struct Int16Tensor *input, struct Int16Tensor *weights, struct Dim2d *kernel_size, struct Dim2d *padding_size);

struct FloatTensor* conv2d_skip1(struct FloatTensor *input, struct FloatTensor *weights, struct Dim2d *kernel_size, struct Dim2d *padding_size);
struct FloatTensor* conv2d_skip2(struct FloatTensor *input, struct FloatTensor *weights, struct Dim2d *kernel_size, struct Dim2d *padding_size);
struct UIntTensor* binconv2d_skip(struct UIntTensor *input, struct UIntTensor *weights, struct Dim2d *kernel_size, struct Dim2d *padding_size);

#endif