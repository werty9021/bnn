#include "layers/activations.h"
#include "tensor_utils.h"
#include "assert.h"
#include <stdio.h>

#define MAX(a, b) (a > b ? a : b)
#define SIGN(a, t) (a >= t ? 1 : 0)
#define SET_BIT(var, pos, val) var |= (val << pos) // variable, position, value

struct FloatTensor * relu(struct UIntTensor *tensor, struct FloatTensor *a, struct FloatTensor *b){
    struct FloatTensor *output = floattensor_init(tensor->N, tensor->C, tensor->H, tensor->W, 1);

    for(int l = 0; l < tensor->N; l++){
        for(int k = 0; k < tensor->C; k++){
            for(int j = 0; j < tensor->H; j++){
                for(int i = 0; i < tensor->W; i++){
                    int32_t T = 9*64;
                    if (i==0 || i==tensor->W-1){
                        T -= 3*64;
                    }
                    if (j==0 || j==tensor->H-1){
                        T -= 3*64;
                    }
                    if ((j==0 && i==0) || (j==tensor->H-1 && i==0) || (j==0 && i==tensor->W-1) || (j==tensor->H-1 && i==tensor->W-1)){
                        T += 1*64;
                    }

                    // uint32_t thres = *IND1(threshold, k) - T/2;
                    float A = *IND1(a, k);
                    float B = *IND1(b, k);
                    uint32_t p = *IND4(tensor, l, k, j, i);
                    float num = (float)(2 * (int32_t)p - T);
                    float y = A * num + B;
                    *IND4(output, l, k, j, i) = MAX(y, 0);
                }
            }
        }
    }

    free_uinttensor(tensor);
    free_floattensor(a);
    free_floattensor(b);

    return output;
}

/*
Float32 -> bitpacked ints
int -> bitpacked ints
*/

struct UIntTensor* sign_from_float(struct FloatTensor *tensor){
    assert(tensor->C % 32 == 0);

    struct UIntTensor *output = uinttensor_init(tensor->N, tensor->C / 32, tensor->H, tensor->W, 1);

    for(int l = 0; l < tensor->N; l++){
        for(int k = 0; k < tensor->C / 32; k++){
            for(int pos = 0; pos < 32; pos++){
                for(int j = 0; j < tensor->H; j++){
                    for(int i = 0; i < tensor->W; i++){
                        SET_BIT(*IND4(output, l, k, j, i), (31 - pos), SIGN(*IND4(tensor, l, (k*32 + pos), j, i), 0));
                    }
                }
            }
        }
    }

    free_floattensor(tensor);

    return output;
}

struct UIntTensor* sign_from_uint(struct UIntTensor *tensor, struct UIntTensor *threshold){
    assert(tensor->C % 32 == 0);
    assert(tensor->C == threshold->W);

    struct UIntTensor *output = uinttensor_init(tensor->N, tensor->C/32, tensor->H, tensor->W, 1); // /32

    for(int l = 0; l < tensor->N; l++){
        for(int k = 0; k < tensor->C/32; k++){ // /32
            
            for(int j = 0; j < tensor->H; j++){
                for(int i = 0; i < tensor->W; i++){
                    uint32_t T = 0;
                    if (i==0 || i==tensor->W-1){
                        T += 3*64;
                    }
                    if (j==0 || j==tensor->H-1){
                        T += 3*64;
                    }
                    if ((j==0 && i==0) || (j==tensor->H-1 && i==0) || (j==0 && i==tensor->W-1) || (j==tensor->H-1 && i==tensor->W-1)){
                        T -= 1*64;
                    }
                    for(int pos = 0; pos < 32; pos++){
                        // uint32_t t = *IND1(threshold, k);
                        // uint32_t thres = t > T ? t - T : 0;
                        // uint32_t a = 2* *IND4(tensor, l, k, j, i);
                        // *IND4(output, l, k, j, i) = SIGN(a, thres);

                        uint32_t t = *IND1(threshold, (k*32 + pos));
                        uint32_t thres = t > T ? t - T : 0;
                        uint32_t a = 2* *IND4(tensor, l, (k*32 + pos), j, i);
                        SET_BIT(*IND4(output, l, k, j, i), (31 - pos), SIGN(a, thres));
                    }
                }
            }
        }
    }

    free_uinttensor(tensor);
    free_uinttensor(threshold);

    return output;
}