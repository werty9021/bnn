#ifndef __LAYERS_ACTIVATIONS__
#define __LAYERS_ACTIVATIONS__
#include "types.h"

struct Int16Tensor * intrelu(struct UIntTensor *tensor, struct Int16Tensor *a, struct Int16Tensor *b);
struct FloatTensor * relu(struct UIntTensor *tensor, struct FloatTensor *a, struct FloatTensor *b);
struct UIntTensor* sign_from_int(struct IntTensor *tensor);
struct UIntTensor* sign_from_float(struct FloatTensor *tensor);
struct UIntTensor* sign_from_uint(struct UIntTensor *tensor, struct UIntTensor *threshold);

#endif