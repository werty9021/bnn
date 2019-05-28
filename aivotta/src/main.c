#include <stdint.h>
#include "types.h"
#include "tensor_utils.h"
#include "layers/conv.h"
#include "layers/activations.h"
#include "tceops.h"

// Some settings; dont really like it this way
// Input size
#define Hin 5
#define Win 5
// Output/Input channels
#define Co 64
#define Ci 2 //64/32
// Kernel size
#define Kx 3 //==Ky

// Data input
#define __dataBuf __attribute__((address_space(0)))
#define __dataBufAligned __dataBuf __attribute__((aligned(32)));
float input_data[Hin][Win] __dataBufAligned;
float l0_weights[Co][Kx][Kx] __dataBufAligned;
uint32_t l1_weights[Co][Ci][Kx][Kx] __dataBufAligned;
volatile uint32_t output_data[Ci][Hin][Win] __dataBufAligned;

int main(){
    struct Dim2d kernel_size = {.x = Kx, .y = Kx}; // Kernel
    struct Dim2d padding_size = {.x = 1, .y = 1}; // Padding
    
    /* Conv 0 */
    struct FloatTensor *input = floattensor_from_ptr(1, 1, Hin, Win, input_data);
    struct FloatTensor *float_weights = floattensor_from_ptr(Co, 1, kernel_size.y, kernel_size.x, l0_weights);
    struct FloatTensor *float_output = conv2d_skip2(input, float_weights, &kernel_size, &padding_size);

    /* Act 0 */
    struct UIntTensor *output = sign_from_float(float_output);

    /* Conv 1 */
    struct UIntTensor *weights = uinttensor_from_ptr(Co, Ci, kernel_size.y, kernel_size.x, l1_weights);
    output = binconv2d_skip(output, weights, &kernel_size, &padding_size);

    for (int z = 0; z < Co; z++){
        for (int j = 0; j < Hin; j++){
            for (int i = 0; i < Win; i++){
                output_data[z][j][i] = *IND3(output, z, j, i);
            }
        }
    }

    free_uinttensor(output);

    return 0;
}

