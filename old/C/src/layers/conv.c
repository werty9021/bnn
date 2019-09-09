#include "layers/conv.h"
// #include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include "types.h"
#include "tensor_utils.h"
#include "tceops.h"
#include "tce_vector.h"

//typedef uint32_t uint32x32 __attribute__((__ext_vector_type__(32)));
typedef uint32 uint32x32;

struct IntTensor* conv2d(struct Int16Tensor *input, struct Int16Tensor2 *weights, struct Dim2d *kernel_size, struct Dim2d *padding_size){
    // Short variable names
    const int H = input->H, W = input->W; // Input size
    const int Ky = kernel_size->y, Kx = kernel_size->x; // Kernel size
    const int Py = padding_size->y, Px = padding_size->x; // Padding size
    const int Do = weights->N, Di = input->C; // Output/Input channels
    // Compute output size
    const int Dy = (H - Ky + 2*Py) + 1, Dx = (W - Kx + 2*Px) + 1; // Stride=1

    // Create output
    struct IntTensor* output = inttensor_init(1, Do, Dy, Dx, 1);

    int l_start, l_end, k_start, k_end;
    for(int y = 0; y < Dy; y++) {
        for(int x = 0; x < Dx; x++) {
            k_start = (y < Py) ? (Py - y) : 0;
            k_end = (y >= Dy - Py) ? (Ky - Py - 1 + Dy - y) : Ky;
            for(int k = k_start; k < k_end; k++) {
                l_start = (x < Px) ? (Px - x) : 0;
                l_end = (x >= Dx - Px) ? (Kx - Px -1 + Dx -x) : Kx;
                for(int l = l_start; l < l_end; l++) {
                    for(int i = 0; i < Di; i++) {
                        short32 vinput = {0};
                        _TCE_VBCAST16X32(*IND2(input, (y - Py + k), (x - Px + l)), vinput);
                        //broadcast
                        for(int z = 0; z < Do; z+=32){
                            // *IND3T(output, y, x, z) += *IND2(input, (y - Py + k), (x - Px + l)) * *IND4T(weights, k, l, i, z);
                            short32 vweights = {0};
                            // _TCEFU_LD16X32("vLSU_inp", IND4T(weights, k, l, i, z), vweights);
                            _TCEAS_LD16X32("parameters", IND4T(weights, k, l, i, z), vweights);
                            
                            int32 voutput = {0};
                            // _TCEFU_LD32X32("vLSU", IND3T(output, y, x, z), voutput);
                            _TCEAS_LD32X32("data", IND3T(output, y, x, z), voutput);
                            _TCE_MAC16X32TO32X32(vinput, vweights, voutput, voutput);
                            // _TCEFU_ST32X32("vLSU", IND3T(output, y, x, z), voutput);
                            _TCEAS_ST32X32("data", IND3T(output, y, x, z), voutput);
                        }
                    }
                }
            }
        }
    }

    #if __PLATFORM == _TCE
    // free(input);
    free(weights);
    #else
    free_floattensor(input);
    free_floattensor(weights);
    #endif

    return output;
}

struct IntTensor* conv2d_2(struct Int16Tensor *input, struct Int16Tensor2 *weights, struct Dim2d *kernel_size, struct Dim2d *padding_size){
    // Short variable names
    const int H = input->H, W = input->W; // Input size
    const int Ky = kernel_size->y, Kx = kernel_size->x; // Kernel size
    const int Py = padding_size->y, Px = padding_size->x; // Padding size
    const int Do = weights->N, Di = input->C; // Output/Input channels
    // Compute output size
    const int Dy = (H - Ky + 2*Py) + 1, Dx = (W - Kx + 2*Px) + 1; // Stride=1

    // Create output
    struct IntTensor* output = inttensor_init(1, Do, Dy, Dx, 1);

    int l_start, l_end, k_start, k_end;
    for(int y = 0; y < Dy; y++) {
        for(int x = 0; x < Dx; x++) {
            k_start = (y < Py) ? (Py - y) : 0;
            k_end = (y >= Dy - Py) ? (Ky - Py - 1 + Dy - y) : Ky;
            for(int k = k_start; k < k_end; k++) {
                l_start = (x < Px) ? (Px - x) : 0;
                l_end = (x >= Dx - Px) ? (Kx - Px -1 + Dx -x) : Kx;
                for(int l = l_start; l < l_end; l++) {
                    for(int i = 0; i < Di; i+=32) { // +=32
                        short32 vinput = {0};
                        // _TCEFU_LD16X32("vLSU", IND3T(input, (y - Py + k), (x - Px + l), i), vinput);
                        _TCEAS_LD16X32("data", IND3T(input, (y - Py + k), (x - Px + l), i), vinput);
                        for(int z = 0; z < Do; z++){ // =1
                            short32 vweights = {0,0};
                            // NOTE: WEIGHTS DATA LAYOUT DIFFERENT!
                            // _TCEFU_LD16X32("vLSU_inp", (weights->data + ((k*weights->W + l)*weights->N + z)*weights->C + i), vweights);
                            _TCEAS_LD16X32("parameters", (weights->data + ((k*weights->W + l)*weights->N + z)*weights->C + i), vweights);
                            int32 voutput = {0};
                            _TCE_MAC16X32TO32X32(vinput, vweights, voutput, voutput);
                            
                            int32_t vec = *IND3T(output, y, x, z);
                            _TCE_VREDUCE32X32(voutput, *IND3T(output, y, x, z));
                            *IND3T(output, y, x, z) += vec;
                            // Vector sum not working?
                            // for (int r = 0; r < 32; r++)
                            //     *IND3T(output, y, x, z) += voutput[r];
                            
                            // *IND3T(output, y, x, z) += *IND3T(input, (y - Py + k), (x - Px + l), i) * *IND4T(weights, k, l, z, i);
                        }
                    }
                }
            }
        }
    }

    #if __PLATFORM == _TCE
    free_int16tensor(input);
    free(weights);
    #else
    free_floattensor(input);
    free_floattensor(weights);
    #endif

    return output;
}

struct FloatTensor* conv2d_skip1(struct FloatTensor *input, struct FloatTensor2 *weights, struct Dim2d *kernel_size, struct Dim2d *padding_size){
    // Short variable names
    const int H = input->H, W = input->W; // Input size
    const int Ky = kernel_size->y, Kx = kernel_size->x; // Kernel size
    const int Py = padding_size->y, Px = padding_size->x; // Padding size
    const int Do = weights->N, Di = input->C; // Output/Input channels
    // Compute output size
    const int Dy = (H - Ky + 2*Py) + 1, Dx = (W - Kx + 2*Px) + 1; // Stride=1

    // Create output
    struct FloatTensor* output = floattensor_init(1, Do, Dy, Dx, 1);

    int l_start, l_end, k_start, k_end;
    for(int y = 0; y < Dy; y++) {
        for(int x = 0; x < Dx; x++) {
            k_start = (y < Py) ? (Py - y) : 0;
            k_end = (y >= Dy - Py) ? (Ky - Py - 1 + Dy - y) : Ky;
            for(int k = k_start; k < k_end; k++) {
                l_start = (x < Px) ? (Px - x) : 0;
                l_end = (x >= Dx - Px) ? (Kx - Px -1 + Dx -x) : Kx;
                for(int l = l_start; l < l_end; l++) {
                    for(int i = 0; i < Di; i++) {
                        // float32 vinput = {0, 0};
                        // _TCE_VBCAST32X32(*IND2(input, (y - Py + k), (x - Px + l)), vinput);
                        //broadcast
                        for(int z = 0; z < Do; z++){ // +=32
                            // *(output.data + z*Dy*Dx + y*Dx + x) += *(input->data + i*H*W + (y - Py + k)*W + (x - Px + l)) * *(weights->data + z*Di*Ky*Kx + i*Ky*Kx + k*Kx + l);
                            // *IND3(output, z, y, x) += *IND3(input, i, (y - Py + k), (x - Px + l)) * *IND4(weights, z, i, k, l);
                            
                            *IND3T(output, y, x, z) += *IND2(input, (y - Py + k), (x - Px + l)) * *IND4T(weights, k, l, i, z);

                            // float32 vweights = {0,0};
                            // _TCEFU_LD32X32("vLSU_inp", IND4T(weights, k, l, i, z), vweights);

                            // float32 voutput = {0, 0};
                            // _TCEFU_LD32X32("vLSU", IND3T(output, y, x, z), voutput);
                            // voutput += vinput * vweights;
                            // _TCEFU_ST32X32("vLSU", IND3T(output, y, x, z), voutput);
                        }
                    }
                }
            }
        }
    }

    #if __PLATFORM == _TCE
    free(weights);
    #else
    free_floattensor(input);
    free_floattensor(weights);
    #endif

    return output;
}

struct FloatTensor* conv2d_skip2(struct FloatTensor *input, struct FloatTensor2 *weights, struct Dim2d *kernel_size, struct Dim2d *padding_size){
    // Short variable names
    const int H = input->H, W = input->W; // Input size
    const int Ky = kernel_size->y, Kx = kernel_size->x; // Kernel size
    const int Py = padding_size->y, Px = padding_size->x; // Padding size
    const int Do = weights->N, Di = input->C; // Output/Input channels
    // Compute output size
    const int Dy = (H - Ky + 2*Py) + 1, Dx = (W - Kx + 2*Px) + 1; // Stride=1

    // Create output
    struct FloatTensor* output = floattensor_init(1, Do, Dy, Dx, 1);

    int l_start, l_end, k_start, k_end;
    for(int y = 0; y < Dy; y++) {
        for(int x = 0; x < Dx; x++) {
            k_start = (y < Py) ? (Py - y) : 0;
            k_end = (y >= Dy - Py) ? (Ky - Py - 1 + Dy - y) : Ky;
            for(int k = k_start; k < k_end; k++) {
                l_start = (x < Px) ? (Px - x) : 0;
                l_end = (x >= Dx - Px) ? (Kx - Px -1 + Dx -x) : Kx;
                for(int l = l_start; l < l_end; l++) {
                    for(int i = 0; i < Di; i++) {
                        for(int z = 0; z < Do; z++){
                            // *(output.data + z*Dy*Dx + y*Dx + x) += *(input->data + i*H*W + (y - Py + k)*W + (x - Px + l)) * *(weights->data + z*Di*Ky*Kx + i*Ky*Kx + k*Kx + l);
                            // *IND3(output, z, y, x) += *IND3(input, i, (y - Py + k), (x - Px + l)) * *IND4(weights, z, i, k, l);

                            *IND3T(output, y, x, z) += *IND3T(input, (y - Py + k), (x - Px + l), i) * *IND4T(weights, k, l, i, z);
                        }
                    }
                }
            }
        }
    }

    free_floattensor(input);
    #if __PLATFORM == _TCE
    free(weights);
    #else
    free_floattensor(weights);
    #endif

    return output;
}

struct UInt16Tensor* binconv2d_skip(struct UIntTensor *input, struct UIntTensor2 *weights, struct Dim2d *kernel_size, struct Dim2d *padding_size){
    // Short variable names
    const int H = input->H, W = input->W; // Input size
    const int Ky = kernel_size->y, Kx = kernel_size->x; // Kernel size
    const int Py = padding_size->y, Px = padding_size->x; // Padding size
    const int Do = weights->N, Di = input->C; // Output/Input channels
    // Compute output size
    const int Dy = (H - Ky + 2*Py) + 1, Dx = (W - Kx + 2*Px) + 1; // Stride=1

    // Create output
    struct UInt16Tensor *output = uint16tensor_init(1, Do, Dy, Dx, 1);
    
    int l_start, l_end, k_start, k_end;        
    for(int y = 0; y < Dy; y++) {
        for(int x = 0; x < Dx; x++) {
            k_start = (y < Py) ? (Py - y) : 0;
            k_end = (y >= Dy - Py) ? (Ky - Py - 1 + Dy - y) : Ky;
            for(int k = k_start; k < k_end; k++) {
                l_start = (x < Px) ? (Px - x) : 0;
                l_end = (x >= Dx - Px) ? (Kx - Px -1 + Dx -x) : Kx;
                for(int l = l_start; l < l_end; l++) {
                    for(int i = 0; i < Di; i++) {
                        uint32 vinput = {0, 0};
                        _TCE_VBCAST32X32(*IND3T(input, (y - Py + k), (x - Px + l), i), vinput);
                        for(int z = 0; z < Do; z+=32){
                            /* Opt 3 */
                            // _TCE_XNORPOPCOUNTACC(*IND3T(input, (y - Py + k), (x - Px + l), i), *IND4T(weights, k, l, i, z), *IND3T(output, y, x, z), *IND3T(output, y, x, z));

                            // ld input, ld weights, ld output, st output
                            uint32 vweights = {0, 0};
                            // _TCEFU_LD32X32("vLSU_inp", IND4T(weights, k, l, i, z), vweights);
                            _TCEAS_LD32X32("parameters", IND4T(weights, k, l, i, z), vweights);

                            ushort32 voutput = {0, 0};
                            // _TCEFU_LD16X32("vLSU", IND3T(output, y, x, z), voutput);
                            _TCEAS_LD16X32("data", IND3T(output, y, x, z), voutput);
                            _TCE_XNORPOPCOUNTACC32X32(vinput, vweights, voutput, voutput);
                            // _TCEFU_ST16X32("vLSU", IND3T(output, y, x, z), voutput);
                            _TCEAS_ST16X32("data", IND3T(output, y, x, z), voutput);
                        }
                    }
                }
            }
        }
    }

    free_uinttensor(input);

    #if __PLATFORM == _TCE
    free(weights);
    #else
    free_uinttensor(weights);
    #endif

    return output;
}
