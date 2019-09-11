#include <stdio.h>
#include <stdlib.h>
#include <time.h>
#include <string.h>
#include "print_arrays.h"
#include "layers/conv.h"
#include "layers/activations.h"
#include "types.h"
#include "tensor_utils.h"

int main(){
    // Convolve with skipping computations
    const int H = 48, W = 32; // Input size
    const int Co = 64,  Ci = 64/32, Ci0 = 1; // Output/Input channels
    struct Dim2d kernel_size = {.x = 3, .y = 3}; // Kernel
    struct Dim2d padding_size = {.x = 1, .y = 1}; // Padding

    /*** QLayer 0; fixed point precision conv + binary activation ***/
    struct Int16Tensor *l0_input = int16tensor_from_file(1, Ci0, H, W, "../data/input/48x32.bin");
    struct Int16Tensor *float_weights = int16tensor_from_file(Co, Ci0, kernel_size.y, kernel_size.x, "../data/weights/conv0.bin");
    struct IntTensor *int_output = conv2d(l0_input, float_weights, &kernel_size, &padding_size);
    struct FloatTensor *float_output = floattensor_init(1, Co, H, W, 0);
    
    for(int y = 0; y < float_output->H; y++) {
        for(int x = 0; x < float_output->W; x++) {
            for(int z = 0; z < float_output->C; z++) {
                *IND3T(float_output, y, x, z) = (float)(*IND3T(int_output, y, x, z)) * 3.725290298461914e-09;
            }
        }
    }
    floattensor_to_file(float_output, "../data/output/conv0.bin"); // Write output to file

    // struct UIntTensor *output2 = sign_from_int(output);
    // uinttensor_to_file(output2, "../data/output/act0.bin");  // Write output to file
    
    // /*** Layer 0; full precision conv + binary activation ***/
    // struct FloatTensor *l0_input = floattensor_from_file(1, Ci0, H, W, "../data/input/5x5.bin");
    // struct FloatTensor *float_weights = floattensor_from_file(Co, Ci0, kernel_size.y, kernel_size.x, "../data/weights/conv0.bin");
    // struct FloatTensor *float_output = conv2d_skip1(l0_input, float_weights, &kernel_size, &padding_size);
    // floattensor_to_file(float_output, "../data/output/conv0.bin"); // Write output to file

    // // struct UIntTensor *output = sign_from_float(float_output);
    // // uinttensor_to_file(output, "../data/output/act0.bin");  // Write output to file
    
    /*** Layer 1-15; binary conv + activation ***/
    struct UIntTensor *weights, *thresholds, *output;
    char path[100];
    for (int i = 1; i < 16; i++){
        if (i == 1){
            // output = sign_from_float(float_output);
            output = sign_from_int(int_output);
        }else{
            sprintf(path, "../data/thresholds/act%d_uint32.bin", i-1);
            thresholds = uinttensor_from_file(1, 1, 1, Co, path);
            output = sign_from_uint(output, thresholds);
        }
        sprintf(path, "../data/output/act%d.bin", i-1);
        uinttensor_to_file(output, path);  // Write output to file

        sprintf(path, "../data/weights/conv%d.bin", i);
        weights = uinttensor_from_file(Co, Ci, kernel_size.y, kernel_size.x, path);
        output = binconv2d_skip(output, weights, &kernel_size, &padding_size);
        sprintf(path, "../data/output/conv%d.bin", i);
        uinttensor_to_file(output, path);  // Write output to file        
    }

    // /*** Layer 16; relu + output conv ***/
    // struct FloatTensor *a = floattensor_from_file(1, 1, 1, Co, "../data/thresholds/act15_a.bin");
    // struct FloatTensor *b = floattensor_from_file(1, 1, 1, Co, "../data/thresholds/act15_b.bin");
    // float_output = relu(output, a, b);
    // floattensor_to_file(float_output, "../data/output/act15.bin"); // Write output to file
    // // fp conv
    // float_weights = floattensor_from_file(Ci0, Co, kernel_size.y, kernel_size.x, "../data/weights/conv16.bin");
    // float_output = conv2d_skip2(float_output, float_weights, &kernel_size, &padding_size);
    // floattensor_to_file(float_output, "../data/output/conv16.bin"); // Write output to file

    /*** QLayer 16; relu + output fixed point conv ***/
    struct Int16Tensor *a = int16tensor_from_file(1, 1, 1, Co, "../data/thresholds/act15_a.bin");
    struct Int16Tensor *b = int16tensor_from_file(1, 1, 1, Co, "../data/thresholds/act15_b.bin");
    struct Int16Tensor *routput = intrelu(output, a, b);

    float_output = floattensor_init(1, Co, H, W, 0);
    for(int y = 0; y < float_output->H; y++) {
        for(int x = 0; x < float_output->W; x++) {
            for(int z = 0; z < float_output->C; z++) {
                *IND3T(float_output, y, x, z) = (float)(*IND3T(routput, y, x, z)) * 1.52587890625e-05; //2^-16
            }
        }
    }
    floattensor_to_file(float_output, "../data/output/act15.bin"); // Write output to file
    // int16tensor_to_file(routput, "../data/output/act15i2.bin"); // Write output to file
    free_floattensor(float_output);
    // // fp conv
    struct Int16Tensor *int_weights = int16tensor_from_file(Ci0, Co, kernel_size.y, kernel_size.x, "../data/weights/conv16.bin");
    int_output  = conv2d(routput, int_weights, &kernel_size, &padding_size);

    float_output = floattensor_init(1, Ci0, H, W, 0);
    for(int y = 0; y < float_output->H; y++) {
        for(int x = 0; x < float_output->W; x++) {
            for(int z = 0; z < float_output->C; z++) {
                *IND3T(float_output, y, x, z) = (float)(*IND3T(int_output, y, x, z)) * 1.52587890625e-05 * 1.52587890625e-05; //2^-32
            }
        }
    }
    floattensor_to_file(float_output, "../data/output/conv16.bin"); // Write output to file

    // // free mem
    free_inttensor(int_output);
    free_floattensor(float_output);

    return 0;
}