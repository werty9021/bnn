#ifndef __LAYERS_CONV__
#define __LAYERS_CONV__
#include "types.h"

struct FloatTensor* conv2d_skip1(struct FloatTensor2 *input, struct FloatTensor2 *weights, struct Dim2d *kernel_size, struct Dim2d *padding_size);
struct FloatTensor* conv2d_skip2(struct FloatTensor *input, struct FloatTensor2 *weights, struct Dim2d *kernel_size, struct Dim2d *padding_size);
struct UIntTensor* binconv2d_skip(struct UIntTensor *input, struct UIntTensor2 *weights, struct Dim2d *kernel_size, struct Dim2d *padding_size);

#endif