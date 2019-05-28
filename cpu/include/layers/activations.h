#ifndef __LAYERS_ACTIVATIONS__
#define __LAYERS_ACTIVATIONS__
#include "types.h"

struct FloatTensor * relu(struct UIntTensor *tensor, struct FloatTensor *a, struct FloatTensor *b);
struct UIntTensor* sign_from_float(struct FloatTensor *tensor);
struct UIntTensor* sign_from_uint(struct UIntTensor *tensor, struct UIntTensor *threshold);

#endif