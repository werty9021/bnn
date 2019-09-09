#include <stdint.h>
#include <stdlib.h>
#include <stdio.h>
#include "types.h"
#include "tensor_utils.h"
#include "layers/conv.h"
#include "layers/activations.h"
#include "settings.h"

int main(){
    // Convolve with skipping computations
    struct Dim2d kernel_size = {.x = Kx, .y = Ky}; // Kernel
    struct Dim2d padding_size = {.x = 1, .y = 1}; // Padding
    
    /*** Layer 0; full precision conv + binary activation ***/
    struct FloatTensor *l0_input = floattensor_from_file(1, 1, Hin, Win, "../data/input.bin");
    struct FloatTensor2 *float_weights = floattensor2_from_file(Co, 1, kernel_size.y, kernel_size.x, "../data/weights/conv0.bin");
    struct FloatTensor *float_output = conv2d_skip1(l0_input, float_weights, &kernel_size, &padding_size);
    floattensor_to_file(float_output, "../data/output/conv0.bin"); // Write output to file

    struct UIntTensor2 *weights, *thresholds;
    struct UIntTensor *output;
    /** Layer 1 **/
    output = sign_from_float(float_output);
    uinttensor_to_file(output, "../data/output/act0.bin");  // Write output to file

    weights = uinttensor_from_file(Co, Ci, kernel_size.y, kernel_size.x, "../data/weights/conv1.bin");
    output = binconv2d_skip(output, weights, &kernel_size, &padding_size);
    uinttensor_to_file(output, "../data/output/conv1.bin");  // Write output to file

    /** Layer 2 **/
    thresholds = uinttensor_from_file(1, 1, 1, Co, "../data/thresholds/act1.bin");
    output = sign_from_uint(output, thresholds);
    uinttensor_to_file(output, "../data/output/act1.bin");  // Write output to file

    weights = uinttensor_from_file(Co, Ci, kernel_size.y, kernel_size.x, "../data/weights/conv2.bin");
    output = binconv2d_skip(output, weights, &kernel_size, &padding_size);
    uinttensor_to_file(output, "../data/output/conv2.bin");  // Write output to file

    /** Layer 3 **/
    thresholds = uinttensor_from_file(1, 1, 1, Co, "../data/thresholds/act2.bin");
    output = sign_from_uint(output, thresholds);
    uinttensor_to_file(output, "../data/output/act2.bin");  // Write output to file

    weights = uinttensor_from_file(Co, Ci, kernel_size.y, kernel_size.x, "../data/weights/conv3.bin");
    output = binconv2d_skip(output, weights, &kernel_size, &padding_size);
    uinttensor_to_file(output, "../data/output/conv3.bin");  // Write output to file
    
    /** Layer 4 **/
    thresholds = uinttensor_from_file(1, 1, 1, Co, "../data/thresholds/act3.bin");
    output = sign_from_uint(output, thresholds);
    uinttensor_to_file(output, "../data/output/act3.bin");  // Write output to file

    weights = uinttensor_from_file(Co, Ci, kernel_size.y, kernel_size.x, "../data/weights/conv4.bin");
    output = binconv2d_skip(output, weights, &kernel_size, &padding_size);
    uinttensor_to_file(output, "../data/output/conv4.bin");  // Write output to file
    
    /** Layer 5 **/
    thresholds = uinttensor_from_file(1, 1, 1, Co, "../data/thresholds/act4.bin");
    output = sign_from_uint(output, thresholds);
    uinttensor_to_file(output, "../data/output/act4.bin");  // Write output to file

    weights = uinttensor_from_file(Co, Ci, kernel_size.y, kernel_size.x, "../data/weights/conv5.bin");
    output = binconv2d_skip(output, weights, &kernel_size, &padding_size);
    uinttensor_to_file(output, "../data/output/conv5.bin");  // Write output to file
    
    /** Layer 6 **/
    thresholds = uinttensor_from_file(1, 1, 1, Co, "../data/thresholds/act5.bin");
    output = sign_from_uint(output, thresholds);
    uinttensor_to_file(output, "../data/output/act5.bin");  // Write output to file

    weights = uinttensor_from_file(Co, Ci, kernel_size.y, kernel_size.x, "../data/weights/conv6.bin");
    output = binconv2d_skip(output, weights, &kernel_size, &padding_size);
    uinttensor_to_file(output, "../data/output/conv6.bin");  // Write output to file
    
    /** Layer 7 **/
    thresholds = uinttensor_from_file(1, 1, 1, Co, "../data/thresholds/act6.bin");
    output = sign_from_uint(output, thresholds);
    uinttensor_to_file(output, "../data/output/act6.bin");  // Write output to file

    weights = uinttensor_from_file(Co, Ci, kernel_size.y, kernel_size.x, "../data/weights/conv7.bin");
    output = binconv2d_skip(output, weights, &kernel_size, &padding_size);
    uinttensor_to_file(output, "../data/output/conv7.bin");  // Write output to file
    
    /** Layer 8 **/
    thresholds = uinttensor_from_file(1, 1, 1, Co, "../data/thresholds/act7.bin");
    output = sign_from_uint(output, thresholds);
    uinttensor_to_file(output, "../data/output/act7.bin");  // Write output to file
    
    weights = uinttensor_from_file(Co, Ci, kernel_size.y, kernel_size.x, "../data/weights/conv8.bin");
    output = binconv2d_skip(output, weights, &kernel_size, &padding_size);
    uinttensor_to_file(output, "../data/output/conv8.bin");  // Write output to file
    
    /** Layer 9 **/
    thresholds = uinttensor_from_file(1, 1, 1, Co, "../data/thresholds/act8.bin");
    output = sign_from_uint(output, thresholds);
    uinttensor_to_file(output, "../data/output/act8.bin");  // Write output to file

    weights = uinttensor_from_file(Co, Ci, kernel_size.y, kernel_size.x, "../data/weights/conv9.bin");
    output = binconv2d_skip(output, weights, &kernel_size, &padding_size);
    uinttensor_to_file(output, "../data/output/conv9.bin");  // Write output to file
    
    /** Layer 10 **/
    thresholds = uinttensor_from_file(1, 1, 1, Co, "../data/thresholds/act9.bin");
    output = sign_from_uint(output, thresholds);
    uinttensor_to_file(output, "../data/output/act9.bin");  // Write output to file

    weights = uinttensor_from_file(Co, Ci, kernel_size.y, kernel_size.x, "../data/weights/conv10.bin");
    output = binconv2d_skip(output, weights, &kernel_size, &padding_size);
    uinttensor_to_file(output, "../data/output/conv10.bin");  // Write output to file
    
    /** Layer 11 **/
    thresholds = uinttensor_from_file(1, 1, 1, Co, "../data/thresholds/act10.bin");
    output = sign_from_uint(output, thresholds);
    uinttensor_to_file(output, "../data/output/act10.bin");  // Write output to file

    weights = uinttensor_from_file(Co, Ci, kernel_size.y, kernel_size.x, "../data/weights/conv11.bin");
    output = binconv2d_skip(output, weights, &kernel_size, &padding_size);
    uinttensor_to_file(output, "../data/output/conv11.bin");  // Write output to file
    
    /** Layer 12 **/
    thresholds = uinttensor_from_file(1, 1, 1, Co, "../data/thresholds/act11.bin");
    output = sign_from_uint(output, thresholds);
    uinttensor_to_file(output, "../data/output/act11.bin");  // Write output to file

    weights = uinttensor_from_file(Co, Ci, kernel_size.y, kernel_size.x, "../data/weights/conv12.bin");
    output = binconv2d_skip(output, weights, &kernel_size, &padding_size);
    uinttensor_to_file(output, "../data/output/conv12.bin");  // Write output to file
    
    /** Layer 13 **/
    thresholds = uinttensor_from_file(1, 1, 1, Co, "../data/thresholds/act12.bin");
    output = sign_from_uint(output, thresholds);
    uinttensor_to_file(output, "../data/output/act12.bin");  // Write output to file

    weights = uinttensor_from_file(Co, Ci, kernel_size.y, kernel_size.x, "../data/weights/conv13.bin");
    output = binconv2d_skip(output, weights, &kernel_size, &padding_size);
    uinttensor_to_file(output, "../data/output/conv13.bin");  // Write output to file
    
    /** Layer 14 **/
    thresholds = uinttensor_from_file(1, 1, 1, Co, "../data/thresholds/act13.bin");
    output = sign_from_uint(output, thresholds);
    uinttensor_to_file(output, "../data/output/act13.bin");  // Write output to file

    weights = uinttensor_from_file(Co, Ci, kernel_size.y, kernel_size.x, "../data/weights/conv14.bin");
    output = binconv2d_skip(output, weights, &kernel_size, &padding_size);
    uinttensor_to_file(output, "../data/output/conv14.bin");  // Write output to file

    /** Layer 15 **/
    thresholds = uinttensor_from_file(1, 1, 1, Co, "../data/thresholds/act14.bin");
    output = sign_from_uint(output, thresholds);
    uinttensor_to_file(output, "../data/output/act14.bin");  // Write output to file

    weights = uinttensor_from_file(Co, Ci, kernel_size.y, kernel_size.x, "../data/weights/conv15.bin");
    output = binconv2d_skip(output, weights, &kernel_size, &padding_size);
    uinttensor_to_file(output, "../data/output/conv15.bin");  // Write output to file

    /*** Layer 16; relu + output conv ***/
    struct FloatTensor2 *a = floattensor2_from_file(1, 1, 1, Co, "../data/thresholds/act15_a.bin");
    struct FloatTensor2 *b = floattensor2_from_file(1, 1, 1, Co, "../data/thresholds/act15_b.bin");
    float_output = relu(output, a, b);
    floattensor_to_file(float_output, "../data/output/act15.bin"); // Write output to file
    // fp conv
    float_weights = floattensor2_from_file(1, Co, kernel_size.y, kernel_size.x, "../data/weights/conv16.bin");
    float_output = conv2d_skip2(float_output, float_weights, &kernel_size, &padding_size);
    floattensor_to_file(float_output, "../data/output/conv16.bin"); // Write output to file

    // free mem
    free_floattensor(float_output);
    // free_uinttensor(output);

    return 0;
}

