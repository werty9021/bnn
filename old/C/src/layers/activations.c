#include "layers/activations.h"
#include "tensor_utils.h"
#include "assert.h"
// #include <stdio.h>
#include <stdlib.h>
#include "tce_vector.h"

#define MAX(a, b) (a > b ? a : b)
#define SIGN(a, t) (a >= t ? 1 : 0)
#define SET_BIT(var, pos, val) var |= (val << pos) // variable, position, value

struct Int16Tensor * intrelu(struct UInt16Tensor *tensor, struct Int16Tensor2 *a, struct Int16Tensor2 *b){
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
            T = -T;
            short32 vT = {0};
            _TCE_VBCAST16X32(T, vT);


            for(int k = 0; k < tensor->C; k+=32){ // multiple van 32
                short32 vA = {0};
                // _TCEFU_LD16X32("vLSU_inp", IND1(a, k), vA);
                _TCEAS_LD16X32("parameters", IND1(a, k), vA);
                short32 vB = {0};
                // _TCEFU_LD16X32("vLSU_inp", IND1(b, k), vB);
                _TCEAS_LD16X32("parameters", IND1(b, k), vB);
                
                // y = vB*1+0
                int32 y = {0};
                short32 ones = {0};
                _TCE_VBCAST16X32(1, ones);
                _TCE_MAC16X32TO32X32(vB, ones, y, y);
                // y = vA*vT + y
                _TCE_MAC16X32TO32X32(vA, vT, y, y);
                // y = 2*vA*X + y
                vA <<= 1;
                short32 X = {0}; // signed vs unsigned problem?
                // _TCEFU_LD16X32("vLSU", IND3T(tensor, j, i, k), X);
                _TCEAS_LD16X32("data", IND3T(tensor, j, i, k), X);
                _TCE_MAC16X32TO32X32(vA, X, y, y);
                _TCE_TRUNCWH32X32(y,X);
                // MAX(vY,0)
                short32 zeros = {0};
                _TCE_MAX16X32(X, zeros, X);

                // _TCEFU_ST16X32("vLSU", IND3T(output, j, i, k), X);
                _TCEAS_ST16X32("data", IND3T(output, j, i, k), X);
                
                // int16_t A = *IND1(a, k); // alle kanalen
                // int16_t B = *IND1(b, k); // alle kanalen?
                // int16_t y = 2 * A * (int16_t)*IND3T(tensor, j, i, k) - A * T + B;
                // *IND3T(output, j, i, k) = MAX(y, 0);
            }
        }
    }

    free_uint16tensor(tensor);
    free(a);
    free(b);

    return output;
}

struct FloatTensor * relu(struct UIntTensor *tensor, struct FloatTensor2 *a, struct FloatTensor2 *b){
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
                // uint32_t thres = *IND1(threshold, k) - T/2;
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
    #if __PLATFORM == _TCE
    free(a);
    free(b);
    #else
    free_floattensor(a);
    free_floattensor(b);
    #endif

    return output;
}

/*
Float32 -> bitpacked ints
int -> bitpacked ints
*/

struct UIntTensor* sign_from_float(struct FloatTensor *tensor){
    assert(tensor->C % 32 == 0);

    struct UIntTensor *output = uinttensor_init(tensor->N, tensor->C / 32, tensor->H, tensor->W, 1);

    for(int j = 0; j < tensor->H; j++){
        for(int i = 0; i < tensor->W; i++){
            for(int k = 0; k < tensor->C / 32; k++){
                for(int pos = 0; pos < 32; pos++){
                    // SET_BIT(*IND4(output, l, k, j, i), (31 - pos), SIGN(*IND4(tensor, l, (k*32 + pos), j, i), 0));

                    if (*IND3T(tensor, j, i, (k*32 + pos)) >= 0) {
                        // _TCE_SET_BIT(pos, *IND3T(output, j, i, k), *IND3T(output, j, i, k));
                        SET_BIT(*IND3T(output, j, i, k), (31-pos), 1);
                    }
                }
            }
        }
    }

    free_floattensor(tensor);

    return output;
}

struct UIntTensor* sign_from_int(struct IntTensor *tensor){
    // assert(tensor->C % 32 == 0);

    struct UIntTensor *output = uinttensor_init(tensor->N, tensor->C / 32, tensor->H, tensor->W, 1);
    
    for(int j = 0; j < tensor->H; j++){
        for(int i = 0; i < tensor->W; i++){
            for(int k = 0; k < tensor->C / 32; k++){
                int32 vthresholds;// = {0};
                int32 vinput;
                // _TCEFU_LD32X32("vLSU", IND3T(tensor, j, i, k*32), vinput);
                _TCEAS_LD32X32("data", IND3T(tensor, j, i, k*32), vinput);
                _TCE_GE32X32TO32X1(vinput, vthresholds, *IND3T(output, j, i, k));
                // for(int pos = 0; pos < 32; pos++){
                //     if (*IND3T(tensor, j, i, (k*32 + pos)) >= 0){
                //         SET_BIT(*IND3T(output, j, i, k), (31-pos), 1);
                //     }
                // }
            }
        }
    }

    free_inttensor(tensor);

    return output;
}

struct UIntTensor* sign_from_uint(struct UInt16Tensor *tensor, struct UInt16Tensor2 *threshold){
    // assert(tensor->C % 32 == 0);
    // assert(tensor->C == threshold->W);

    struct UIntTensor *output = uinttensor_init(tensor->N, tensor->C/32, tensor->H, tensor->W, 1); // /32


    for(int j = 0; j < tensor->H; j++){
        for(int i = 0; i < tensor->W; i++){
            uint16_t T = 0;
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
                ushort32 vthresholds;
                for(int pos = 0; pos < 32; pos++){
                    // uint32_t t = *IND1(threshold, k);
                    // uint32_t thres = t > T ? t - T : 0;
                    // uint32_t a = 2* *IND4(tensor, l, k, j, i);
                    // *IND4(output, l, k, j, i) = SIGN(a, thres);

                    uint16_t t = *IND1(threshold, (k*32 + pos));
                    uint16_t thres = t > T ? t - T : 0;
                    _TCE_INSERTELEM16X32(vthresholds, thres, pos, vthresholds);
                    // uint32_t a = 2* *IND3T(tensor, j, i, (k*32 + pos));
                    // SET_BIT(*IND4(output, l, k, j, i), (31 - pos), SIGN(a, thres));


                    // if (a >= thres) {
                    //     _TCE_SET_BIT(pos, *IND3T(output, j, i, k), *IND3T(output, j, i, k));
                    // }
                }
                ushort32 vinput;
                // _TCEFU_LD16X32("vLSU", IND3T(tensor, j, i, (k*32)), vinput);
                _TCEAS_LD16X32("data", IND3T(tensor, j, i, (k*32)), vinput);
                vinput <<= 1;
                _TCE_GEU16X32TO32X1(vinput, vthresholds, *IND3T(output, j, i, k));
            }
        }
    }

    free_uint16tensor(tensor);
    #if __PLATFORM == _TCE
    free(threshold);
    #else
    free_uinttensor(threshold);
    #endif

    return output;
}
