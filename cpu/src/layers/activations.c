#include "layers/activations.h"
#include "tensor_utils.h"
#include "assert.h"
#include <stdio.h>
#include "print_arrays.h"

#define MAX(a, b) (a > b ? a : b)
#define SET_BIT(var, pos) var |= (1 << (31 - pos)) // variable, position

struct Int16Tensor * intrelu(struct UIntTensor *tensor, struct Int16Tensor *a, struct Int16Tensor *b){
    struct Int16Tensor *output = int16tensor_init(tensor->N, tensor->C, tensor->H, tensor->W, 1);

    for(int j = 0; j < tensor->H; j++){
        for(int i = 0; i < tensor->W; i++){
            int16_t T = 9*64;
            if (i==0 || i==tensor->W-1){
                T -= 3*64;
            }
            if (j==0 || j==tensor->H-1){
                T -= 3*64;
            }
            if ((j==0 && i==0) || (j==tensor->H-1 && i==0) || (j==0 && i==tensor->W-1) || (j==tensor->H-1 && i==tensor->W-1)){
                T += 1*64;
            }
            for(int k = 0; k < tensor->C; k++){
                int16_t A = *IND1(a, k);
                int16_t B = *IND1(b, k);
                uint32_t p = *IND3T(tensor, j, i, k);
                int16_t num = (2 * (int16_t)p - T);
                int16_t y = A * num + B;
                *IND3T(output, j, i, k) = MAX(y, 0);
            }
        }
    }

    free_uinttensor(tensor);
    free_int16tensor(a);
    free_int16tensor(b);

    return output;
}

struct FloatTensor * relu(struct UIntTensor *tensor, struct FloatTensor *a, struct FloatTensor *b){
    struct FloatTensor *output = floattensor_init(tensor->N, tensor->C, tensor->H, tensor->W, 1);

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
            for(int k = 0; k < tensor->C; k++){
                float A = *IND1(a, k);
                float B = *IND1(b, k);
                uint32_t p = *IND3T(tensor, j, i, k);
                float num = (float)(2 * (int32_t)p - T);
                float y = A * num + B;
                *IND3T(output, j, i, k) = MAX(y, 0);
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
struct UIntTensor* sign_from_int(struct IntTensor *tensor){
    assert(tensor->C % 32 == 0);

    struct UIntTensor *output = uinttensor_init(tensor->N, tensor->C / 32, tensor->H, tensor->W, 1);
    
    for(int j = 0; j < tensor->H; j++){
        for(int i = 0; i < tensor->W; i++){
            for(int l = 0; l < tensor->N; l++){
                for(int k = 0; k < tensor->C / 32; k++){
                    for(int pos = 0; pos < 32; pos++){
                        if (*IND4T(tensor, j, i, l, (k*32 + pos)) >= 0){
                            SET_BIT(*IND4T(output, j, i, l, k), pos);
                        }
                    }
                }
            }
        }
    }

    free_inttensor(tensor);

    return output;
}

struct UIntTensor* sign_from_float(struct FloatTensor *tensor){
    assert(tensor->C % 32 == 0);

    struct UIntTensor *output = uinttensor_init(tensor->N, tensor->C / 32, tensor->H, tensor->W, 1);
    
    for(int j = 0; j < tensor->H; j++){
        for(int i = 0; i < tensor->W; i++){
            for(int l = 0; l < tensor->N; l++){
                for(int k = 0; k < tensor->C / 32; k++){
                    for(int pos = 0; pos < 32; pos++){
                        if (*IND4T(tensor, j, i, l, (k*32 + pos)) >= 0){
                            SET_BIT(*IND4T(output, j, i, l, k), pos);
                        }
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
            for(int k = 0; k < tensor->C/32; k++){ // /32
                for(int pos = 0; pos < 32; pos++){
                    // uint32_t t = *IND1(threshold, k);
                    // uint32_t thres = t > T ? t - T : 0;
                    // uint32_t a = 2* *IND4(tensor, l, k, j, i);
                    // *IND4(output, l, k, j, i) = SIGN(a, thres);

                    uint32_t t = *IND1(threshold, (k*32 + pos));
                    uint32_t thres = t > T ? t - T : 0;
                    uint32_t a = 2* *IND3T(tensor, j, i, (k*32 + pos));
                    if (a >= thres){
                        SET_BIT(*IND3T(output, j, i, k), pos);
                    }
                }
            }
        }
    }

    free_uinttensor(tensor);
    free_uinttensor(threshold);

    return output;
}