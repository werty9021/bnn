#include "layers/conv.h"
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include "types.h"
#include "tensor_utils.h"

// void conv2d(int Do, int Di, int Dy, int Dx, int Ky, int Kx, float input[Di][(Dy - 1) + Ky][(Dx - 1) + Kx], float weights[Do][Di][Ky][Kx], float output[Do][Dy][Dx]){
void conv2d_pad(int H, int W, int Do, int Di, int Dy, int Dx, int Ky, int Kx, int Py, int Px, float *input, float *weights, float *output){
    // Pad the input array
    float *temp = calloc(Di*(H+2*Py)*(W+2*Px), sizeof(float)); // Init temp to zero
    // Copy input values to temp
    for(int i = 0; i < Di; i++){
        for(int y = 0; y < H; y++){
            memcpy((temp + i*(H+2*Py)*(W+2*Px) + (y+Py)*(W+2*Px) + Px), (input + i*H*W + y*W), W*sizeof(float));
        }
    }
    // Padded convolution
    for(int z = 0; z < Do; z++){
        for(int i = 0; i < Di; i++) {
            for(int y = 0; y < Dy; y++) {
                for(int x = 0; x < Dx; x++) {
                    for(int k = 0; k < Ky; k++) {
                        for(int l = 0; l < Kx; l++) {
                            // printf("%f * %f + %f=", input[i][y + k][x + l], weights[z][i][k][l], output[z][y][x]);
                            // output[z][y][x] += input[i][y + k][x + l] * weights[z][i][k][l];
                            // printf("%f; y=%d, x=%d, k=%d, l=%d\n", output[z][y][x], y, x, k, l);
                            *(output + z*Dy*Dx + y*Dx + x) += *(temp + i*(H+2*Py)*(W+2*Px) + (y + k)*(W+2*Px) + (x + l)) * *(weights + z*Di*Ky*Kx + i*Ky*Kx + k*Kx + l);
                        }
                    }
                }
            }
        }
    }

    free(temp);
}

void conv2d_skip(int H, int W, int Do, int Di, int Dy, int Dx, int Ky, int Kx, int Py, int Px, float *input, float *weights, float *output){
    int l_start, l_end, k_start, k_end;
    for(int z = 0; z < Do; z++){
        for(int i = 0; i < Di; i++) {
            for(int y = 0; y < Dy; y++) {
                for(int x = 0; x < Dx; x++) {
                    k_start = (y < Py) ? (Py - y) : 0;
                    k_end = (y >= Dy - Py) ? (Ky - Py - 1 + Dy - y) : Ky;
                    for(int k = k_start; k < k_end; k++) {
                        l_start = (x < Px) ? (Px - x) : 0;
                        l_end = (x >= Dx - Px) ? (Kx - Px -1 + Dx -x) : Kx;
                        for(int l = l_start; l < l_end; l++) {
                            //*(output + z*Dy*Dx + y*Dx + x) += *(input + i*H*W + (y - Py + k)*W + (x - Px + l)) * *(weights + z*Di*Ky*Kx + i*Ky*Kx + k*Kx + l);
                            *(output) += *(input + i*H*W + (y - Py + k)*W + (x - Px + l)) * *(weights + z*Di*Ky*Kx + i*Ky*Kx + k*Kx + l);
                        }
                    }
                    output++;
                }
            }
        }
    }
}

struct FloatTensor* conv2d_skip2(struct FloatTensor *input, struct FloatTensor *weights, struct Dim2d *kernel_size, struct Dim2d *padding_size){
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
    for(int z = 0; z < Do; z++){
        for(int i = 0; i < Di; i++) {
            for(int y = 0; y < Dy; y++) {
                for(int x = 0; x < Dx; x++) {
                    k_start = (y < Py) ? (Py - y) : 0;
                    k_end = (y >= Dy - Py) ? (Ky - Py - 1 + Dy - y) : Ky;
                    for(int k = k_start; k < k_end; k++) {
                        l_start = (x < Px) ? (Px - x) : 0;
                        l_end = (x >= Dx - Px) ? (Kx - Px -1 + Dx -x) : Kx;
                        for(int l = l_start; l < l_end; l++) {
                            // *(output.data + z*Dy*Dx + y*Dx + x) += *(input->data + i*H*W + (y - Py + k)*W + (x - Px + l)) * *(weights->data + z*Di*Ky*Kx + i*Ky*Kx + k*Kx + l);
                            *IND3(output, z, y, x) += *IND3(input, i, (y - Py + k), (x - Px + l)) * *IND4(weights, z, i, k, l);
                        }
                    }
                }
            }
        }
    }

    free_floattensor(input);
    free_floattensor(weights);

    return output;
}

struct UIntTensor* binconv2d_skip(struct UIntTensor *input, struct UIntTensor *weights, struct Dim2d *kernel_size, struct Dim2d *padding_size){
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
    for(int z = 0; z < Do; z++){
        for(int i = 0; i < Di; i++) {
            for(int y = 0; y < Dy; y++) {
                for(int x = 0; x < Dx; x++) {
                    k_start = (y < Py) ? (Py - y) : 0;
                    k_end = (y >= Dy - Py) ? (Ky - Py - 1 + Dy - y) : Ky;
                    for(int k = k_start; k < k_end; k++) {
                        l_start = (x < Px) ? (Px - x) : 0;
                        l_end = (x >= Dx - Px) ? (Kx - Px -1 + Dx -x) : Kx;
                        for(int l = l_start; l < l_end; l++) {
                            // if (z==0 && x==0 && y==0) {
                            //     int popcnt = __builtin_popcount(~(*IND3((*input), i, (y - Py + k), (x - Px + l)) ^ *IND4((*weights), z, i, k, l)));
                            //     printf("%u \n", popcnt);
                            // }
                            
                            *IND3(output, z, y, x) += __builtin_popcount(~(*IND3(input, i, (y - Py + k), (x - Px + l)) ^ *IND4(weights, z, i, k, l)));
                        }
                    }
                }
            }
        }
    }

    free_uinttensor(input);
    free_uinttensor(weights);

    return output;
}
