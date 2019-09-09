#include "layers/conv.h"
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include "types.h"
#include "tensor_utils.h"
#include "tceops.h"
#include "tce_vector.h"

//typedef uint32_t uint32x32 __attribute__((__ext_vector_type__(32)));
typedef uint32 uint32x32;


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

struct UIntTensor* binconv2d_skip(struct UIntTensor *input, struct UIntTensor2 *weights, struct Dim2d *kernel_size, struct Dim2d *padding_size){
    // Short variable names
    const int H = input->H, W = input->W; // Input size
    const int Ky = kernel_size->y, Kx = kernel_size->x; // Kernel size
    const int Py = padding_size->y, Px = padding_size->x; // Padding size
    const int Do = weights->N, Di = input->C; // Output/Input channels
    // Compute output size
    const int Dy = (H - Ky + 2*Py) + 1, Dx = (W - Kx + 2*Px) + 1; // Stride=1

    // Create output
    struct UIntTensor *output = uinttensor_init(1, Do, Dy, Dx, 1);
    
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
                        uint32x32 vinput = {0, 0};
                        _TCE_VBCAST32X32(*IND3T(input, (y - Py + k), (x - Px + l), i), vinput);
                        for(int z = 0; z < Do; z+=32){
                            // if (z==0 && x==0 && y==0) {
                            //     int popcnt = __builtin_popcount(~(*IND3((*input), i, (y - Py + k), (x - Px + l)) ^ *IND4((*weights), z, i, k, l)));
                            //     printf("%u \n", popcnt);
                            // }
                            
                            // *IND3(output, z, y, x) += __builtin_popcount(~(*IND3(input, i, (y - Py + k), (x - Px + l)) ^ *IND4(weights, z, i, k, l)));

                            // uint32_t xnor = ~(*IND3(input, i, (y - Py + k), (x - Px + l)) ^ *IND4(weights, z, i, k, l));
                            
                            /* Opt 1 */
                            // uint32_t popcnt = 0;
                            // _TCE_POPCOUNT(xnor, popcnt);
                            // *IND3(output, z, y, x) += popcnt;

                            /* Opt 2 */
                            // _TCE_POPCOUNTACC(xnor, *IND3(output, z, y, x), *IND3(output, z, y, x));

                            /* Opt 3 */
                            // _TCE_XNORPOPCOUNTACC(*IND3(input, i, (y - Py + k), (x - Px + l)), *IND4(weights, z, i, k, l), *IND3(output, z, y, x), *IND3(output, z, y, x));

                            // _TCE_XNORPOPCOUNTACC(*IND3T(input, (y - Py + k), (x - Px + l), i), *IND4T(weights, k, l, i, z), *IND3T(output, y, x, z), *IND3T(output, y, x, z));

                            // ld input, ld weights, ld output, st output
                            uint32x32 vweights = {0, 0};
                            _TCEFU_LD32X32("vLSU_inp", IND4T(weights, k, l, i, z), vweights);
                            // if (z==0 && i == 0 && x==0 && y==0) {
                            //     printf("%lu %lu | %lu %lu\n", vweights[0], vweights[1], *IND4T(weights, k, l, i, z), *IND4T(weights, k, l, i, z+1));
                            // }

                            uint32x32 voutput = {0, 0};
                            _TCEFU_LD32X32("vLSU", IND3T(output, y, x, z), voutput);
                            _TCE_XNORPOPCOUNTACC32X32(vinput, vweights, voutput, voutput);
                            _TCEFU_ST32X32("vLSU", IND3T(output, y, x, z), voutput);
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
