#include <stdint.h>
#include "types.h"
#include "tensor_utils.h"
#include "layers/conv.h"
#include "tceops.h"

// Some settings; dont really like it this way
// Input size
#define H 481
#define W 321
// Output/Input channels
#define Co 64
#define Ci 64/32
// Kernel size
#define Kx 3 //==Ky

// Data input
#define __dataBuf __attribute__((address_space(0)))
float input_data[H][W] __dataBuf __attribute__((aligned(32)));
float l0_weights[Co][Kx][Kx] __dataBuf __attribute__((aligned(32)));

int main(){
    struct Dim2d kernel_size = {.x = Kx, .y = Kx}; // Kernel
    struct Dim2d padding_size = {.x = 1, .y = 1}; // Padding
    
    struct FloatTensor *input = floattensor_from_ptr(1, 1, H, W, input_data);
    struct FloatTensor *float_weights = floattensor_from_ptr(Co, 1, kernel_size.y, kernel_size.x, l0_weights);
    struct FloatTensor *float_output = conv2d_skip2(input, float_weights, &kernel_size, &padding_size);

    free_floattensor(float_output);

    return 0;
}

