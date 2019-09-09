#include <stdio.h>
#include <stdlib.h>
#include "types.h"
#include "tensor_utils.h"
#include "settings.h"

//init tensor
struct FloatTensor* floattensor_init(int N, int C, int H, int W, bool zeros){
    struct FloatTensor *tensor = (struct FloatTensor * ) malloc(sizeof(struct FloatTensor));
    if (tensor == NULL){
        PRINTF("Malloc has failed allocating memory.\n");
        free(tensor);
        exit(EXIT_FAILURE);
    }
    tensor->N = N; tensor->C = C; tensor->H = H; tensor->W = W; 

    if (zeros == true) {
        tensor->data = (float*) calloc(TENSORSIZE(tensor), sizeof(float));
    } else {
        tensor->data = (float*) malloc(TENSORSIZE(tensor) * sizeof(float));
    }
    
    if(tensor->data == NULL) {
        PRINTF("Malloc has failed allocating memory.\n");
        free(tensor->data);
        exit(EXIT_FAILURE);
    }
    return tensor;
}

struct UIntTensor* uinttensor_init(int N, int C, int H, int W, bool zeros){
    struct UIntTensor *tensor = (struct UIntTensor *) malloc(sizeof(struct UIntTensor));
    if (tensor == NULL){
        PRINTF("Malloc has failed allocating memory.\n");
        free(tensor);
        exit(EXIT_FAILURE);
    }
    tensor->N = N; tensor->C = C; tensor->H = H; tensor->W = W; 

    if (zeros == true) {
        tensor->data = (uint32_t*) calloc(TENSORSIZE(tensor), sizeof(uint32_t));
    } else {
        tensor->data = (uint32_t*) malloc(TENSORSIZE(tensor) * sizeof(uint32_t));
    }
    
    if(tensor->data == NULL) {
        PRINTF("Malloc has failed allocating memory.\n");
        free(tensor->data);
        exit(EXIT_FAILURE);
    }
    return tensor;
}

#if __PLATFORM == _TCE
#include <string.h>
// Data input
float input_data[Hin][Win] __attribute__((aligned(ALIGNNUM)));
float l0_weights[Co][Kx][Kx] __dataBufAligned;
uint32_t conv1_weights[Co][Ci][Kx][Kx] __dataBufAligned;
uint32_t conv2_weights[Co][Ci][Kx][Kx] __dataBufAligned;
uint32_t conv3_weights[Co][Ci][Kx][Kx] __dataBufAligned;
uint32_t conv4_weights[Co][Ci][Kx][Kx] __dataBufAligned;
uint32_t conv5_weights[Co][Ci][Kx][Kx] __dataBufAligned;
uint32_t conv6_weights[Co][Ci][Kx][Kx] __dataBufAligned;
uint32_t conv7_weights[Co][Ci][Kx][Kx] __dataBufAligned;
uint32_t conv8_weights[Co][Ci][Kx][Kx] __dataBufAligned;
uint32_t conv9_weights[Co][Ci][Kx][Kx] __dataBufAligned;
uint32_t conv10_weights[Co][Ci][Kx][Kx] __dataBufAligned;
uint32_t conv11_weights[Co][Ci][Kx][Kx] __dataBufAligned;
uint32_t conv12_weights[Co][Ci][Kx][Kx] __dataBufAligned;
uint32_t conv13_weights[Co][Ci][Kx][Kx] __dataBufAligned;
uint32_t conv14_weights[Co][Ci][Kx][Kx] __dataBufAligned;
uint32_t conv15_weights[Co][Ci][Kx][Kx] __dataBufAligned;
float conv16_weights[Co][Kx][Kx] __dataBufAligned;
uint32_t act1_thresholds[Co] __dataBufAligned;
uint32_t act2_thresholds[Co] __dataBufAligned;
uint32_t act3_thresholds[Co] __dataBufAligned;
uint32_t act4_thresholds[Co] __dataBufAligned;
uint32_t act5_thresholds[Co] __dataBufAligned;
uint32_t act6_thresholds[Co] __dataBufAligned;
uint32_t act7_thresholds[Co] __dataBufAligned;
uint32_t act8_thresholds[Co] __dataBufAligned;
uint32_t act9_thresholds[Co] __dataBufAligned;
uint32_t act10_thresholds[Co] __dataBufAligned;
uint32_t act11_thresholds[Co] __dataBufAligned;
uint32_t act12_thresholds[Co] __dataBufAligned;
uint32_t act13_thresholds[Co] __dataBufAligned;
uint32_t act14_thresholds[Co] __dataBufAligned;
float act15a_thresholds[Co] __dataBufAligned;
float act15b_thresholds[Co] __dataBufAligned;

// output
float conv0_output[Co][Hin][Win] __dataBufAligned;
uint32_t conv1_output[Co][Hin][Win] __dataBufAligned;
uint32_t conv2_output[Co][Hin][Win] __dataBufAligned;
uint32_t conv3_output[Co][Hin][Win] __dataBufAligned;
uint32_t conv4_output[Co][Hin][Win] __dataBufAligned;
uint32_t conv5_output[Co][Hin][Win] __dataBufAligned;
uint32_t conv6_output[Co][Hin][Win] __dataBufAligned;
uint32_t conv7_output[Co][Hin][Win] __dataBufAligned;
uint32_t conv8_output[Co][Hin][Win] __dataBufAligned;
uint32_t conv9_output[Co][Hin][Win] __dataBufAligned;
uint32_t conv10_output[Co][Hin][Win] __dataBufAligned;
uint32_t conv11_output[Co][Hin][Win] __dataBufAligned;
uint32_t conv12_output[Co][Hin][Win] __dataBufAligned;
uint32_t conv13_output[Co][Hin][Win] __dataBufAligned;
uint32_t conv14_output[Co][Hin][Win] __dataBufAligned;
uint32_t conv15_output[Co][Hin][Win] __dataBufAligned;
float conv16_output[Co][Hin][Win] __dataBufAligned;

uint32_t act0_output[Ci][Hin][Win] __dataBufAligned;
uint32_t act1_output[Ci][Hin][Win] __dataBufAligned;
uint32_t act2_output[Ci][Hin][Win] __dataBufAligned;
uint32_t act3_output[Ci][Hin][Win] __dataBufAligned;
uint32_t act4_output[Ci][Hin][Win] __dataBufAligned;
uint32_t act5_output[Ci][Hin][Win] __dataBufAligned;
uint32_t act6_output[Ci][Hin][Win] __dataBufAligned;
uint32_t act7_output[Ci][Hin][Win] __dataBufAligned;
uint32_t act8_output[Ci][Hin][Win] __dataBufAligned;
uint32_t act9_output[Ci][Hin][Win] __dataBufAligned;
uint32_t act10_output[Ci][Hin][Win] __dataBufAligned;
uint32_t act11_output[Ci][Hin][Win] __dataBufAligned;
uint32_t act12_output[Ci][Hin][Win] __dataBufAligned;
uint32_t act13_output[Ci][Hin][Win] __dataBufAligned;
uint32_t act14_output[Ci][Hin][Win] __dataBufAligned;
float act15_output[Ci][Hin][Win] __dataBufAligned;
/*
c0

a0
c1

a1
c2
*/

#endif

//tensor from file
struct FloatTensor* floattensor_from_file(int N, int C, int H, int W, char *path){
    // struct FloatTensor *tensor = floattensor_init(N, C, H, W, 0);
    struct FloatTensor *tensor = (struct FloatTensor * ) malloc(sizeof(struct FloatTensor));
    if (tensor == NULL){
        PRINTF("Malloc has failed allocating memory.\n");
        free(tensor);
        exit(EXIT_FAILURE);
    }
    tensor->N = N; tensor->C = C; tensor->H = H; tensor->W = W; 
    #if __PLATFORM == _TCE
        float *var = NULL;
        if (strstr(path, "input.bin") != NULL) {
            PRINTF("Copying input...\n");
            var = &input_data[0][0];
        }

        if (var != NULL) {
            tensor->data = var;
        } else {
            PRINTF("Could not copy the data :(");
            exit(EXIT_FAILURE);
        }
    #else
        FILE *fp = fopen(path, "rb");
        if(fread(tensor->data, sizeof(float), TENSORSIZE(tensor), fp) != TENSORSIZE(tensor)){
            PRINTF("Failed to read that much data from input file: %s\n", path);
            fclose(fp);
            exit(EXIT_FAILURE);
        }
        fclose(fp);
    #endif

    return tensor;
}

struct FloatTensor2* floattensor2_from_file(int N, int C, int H, int W, char *path){
    // struct FloatTensor *tensor = floattensor_init(N, C, H, W, 0);
    struct FloatTensor2 *tensor = (struct FloatTensor2 * ) malloc(sizeof(struct FloatTensor2));
    if (tensor == NULL){
        PRINTF("Malloc has failed allocating memory.\n");
        free(tensor);
        exit(EXIT_FAILURE);
    }
    tensor->N = N; tensor->C = C; tensor->H = H; tensor->W = W; 
    #if __PLATFORM == _TCE
        float __dataBufAligned* var = NULL;
        if (strstr(path, "conv0.bin") != NULL) {
            PRINTF("Copying conv0...\n");
            var = &l0_weights[0][0][0];
        } else if (strstr(path, "act15_a.bin") != NULL) {
            PRINTF("Copying act15_a...\n");
            var = &act15a_thresholds[0];
        } else if (strstr(path, "act15_b.bin") != NULL) {
            PRINTF("Copying act15_b...\n");
            var = &act15b_thresholds[0];
        } else if (strstr(path, "conv16.bin") != NULL) {
            PRINTF("Copying conv16...\n");
            var = &conv16_weights[0][0][0];
        }

        if (var != NULL) {
            // free(tensor->data);
            tensor->data = var;
            // for (int l = 0; l < N; l++){
            //     for (int k = 0; k < C; k++){
            //         for (int j = 0; j < H; j++){
            //             for (int i = 0; i < W; i++){
            //                 // PRINTF("%f = %f | ", *IND4(tensor, l, k, j, i),  *(var + ((l*C + k)*H + j)*W + i));
            //                 *IND4(tensor, l, k, j, i) = *(var + ((l*C + k)*H + j)*W + i);
            //                 // PRINTF("%f\n", *IND4(tensor, l, k, j, i));
            //             }
            //         }
            //     }
            // }
        } else {
            PRINTF("Could not copy the data :(");
            exit(EXIT_FAILURE);
        }
    #else
        FILE *fp = fopen(path, "rb");
        if(fread(tensor->data, sizeof(float), TENSORSIZE(tensor), fp) != TENSORSIZE(tensor)){
            PRINTF("Failed to read that much data from input file: %s\n", path);
            fclose(fp);
            exit(EXIT_FAILURE);
        }
        fclose(fp);
    #endif

    return tensor;
}

struct UIntTensor2* uinttensor_from_file(int N, int C, int H, int W, char *path){
    // struct UIntTensor *tensor = uinttensor_init(N, C, H, W, 0);
    struct UIntTensor2 *tensor = (struct UIntTensor2 *) malloc(sizeof(struct UIntTensor2));
    if (tensor == NULL){
        PRINTF("Malloc has failed allocating memory.\n");
        free(tensor);
        exit(EXIT_FAILURE);
    }
    tensor->N = N; tensor->C = C; tensor->H = H; tensor->W = W; 
    #if __PLATFORM == _TCE
        __dataBufAligned uint32_t *var = NULL;
        if (strstr(path, "conv1.bin") != NULL) {
            PRINTF("Copying conv1...\n");
            var = &conv1_weights[0][0][0][0];
        } else if (strstr(path, "act1.bin") != NULL) {
            PRINTF("Copying act1...\n");
            var = &act1_thresholds[0];
        } else if (strstr(path, "conv2.bin") != NULL) {
            PRINTF("Copying conv2...\n");
            var = &conv2_weights[0][0][0][0];
       } else if (strstr(path, "act2.bin") != NULL) {
            PRINTF("Copying act2...\n");
            var = &act2_thresholds[0];
        } else if (strstr(path, "conv3.bin") != NULL) {
            PRINTF("Copying conv3...\n");
            var = &conv3_weights[0][0][0][0];
       } else if (strstr(path, "act3.bin") != NULL) {
            PRINTF("Copying act3...\n");
            var = &act3_thresholds[0];
        } else if (strstr(path, "conv4.bin") != NULL) {
            PRINTF("Copying conv4...\n");
            var = &conv4_weights[0][0][0][0];
       } else if (strstr(path, "act4.bin") != NULL) {
            PRINTF("Copying act4...\n");
            var = &act4_thresholds[0];
        } else if (strstr(path, "conv5.bin") != NULL) {
            PRINTF("Copying conv5...\n");
            var = &conv5_weights[0][0][0][0];
       } else if (strstr(path, "act5.bin") != NULL) {
            PRINTF("Copying act5...\n");
            var = &act5_thresholds[0];
        } else if (strstr(path, "conv6.bin") != NULL) {
            PRINTF("Copying conv6...\n");
            var = &conv6_weights[0][0][0][0];
       } else if (strstr(path, "act6.bin") != NULL) {
            PRINTF("Copying act6...\n");
            var = &act6_thresholds[0];
        } else if (strstr(path, "conv7.bin") != NULL) {
            PRINTF("Copying conv7...\n");
            var = &conv7_weights[0][0][0][0];
       } else if (strstr(path, "act7.bin") != NULL) {
            PRINTF("Copying act7...\n");
            var = &act7_thresholds[0];
        } else if (strstr(path, "conv8.bin") != NULL) {
            PRINTF("Copying conv8...\n");
            var = &conv8_weights[0][0][0][0];
       } else if (strstr(path, "act8.bin") != NULL) {
            PRINTF("Copying act8...\n");
            var = &act8_thresholds[0];
        } else if (strstr(path, "conv9.bin") != NULL) {
            PRINTF("Copying conv9...\n");
            var = &conv9_weights[0][0][0][0];
       } else if (strstr(path, "act9.bin") != NULL) {
            PRINTF("Copying act9...\n");
            var = &act9_thresholds[0];
        } else if (strstr(path, "conv10.bin") != NULL) {
            PRINTF("Copying conv10...\n");
            var = &conv10_weights[0][0][0][0];
       } else if (strstr(path, "act10.bin") != NULL) {
            PRINTF("Copying act10...\n");
            var = &act10_thresholds[0];
        } else if (strstr(path, "conv11.bin") != NULL) {
            PRINTF("Copying conv11...\n");
            var = &conv11_weights[0][0][0][0];
       } else if (strstr(path, "act11.bin") != NULL) {
            PRINTF("Copying act11...\n");
            var = &act11_thresholds[0];
        } else if (strstr(path, "conv12.bin") != NULL) {
            PRINTF("Copying conv12...\n");
            var = &conv12_weights[0][0][0][0];
       } else if (strstr(path, "act12.bin") != NULL) {
            PRINTF("Copying act12...\n");
            var = &act12_thresholds[0];
        } else if (strstr(path, "conv13.bin") != NULL) {
            PRINTF("Copying conv13...\n");
            var = &conv13_weights[0][0][0][0];
       } else if (strstr(path, "act13.bin") != NULL) {
            PRINTF("Copying act13...\n");
            var = &act13_thresholds[0];
        } else if (strstr(path, "conv14.bin") != NULL) {
            PRINTF("Copying conv14...\n");
            var = &conv14_weights[0][0][0][0];
       } else if (strstr(path, "act14.bin") != NULL) {
            PRINTF("Copying act14...\n");
            var = &act14_thresholds[0];
        } else if (strstr(path, "conv15.bin") != NULL) {
            PRINTF("Copying conv15...\n");
            var = &conv15_weights[0][0][0][0];
        }

        if (var != NULL) {
            // free(tensor->data);
            tensor->data = var;
            // for (int l = 0; l < N; l++){
            //     for (int k = 0; k < C; k++){
            //         for (int j = 0; j < H; j++){
            //             for (int i = 0; i < W; i++){
            //                 *IND4(tensor, l, k, j, i) = *(var + ((l*C + k)*H + j)*W + i);
            //             }
            //         }
            //     }
            // }
        } else {
            PRINTF("Could not copy the data :(");
            exit(EXIT_FAILURE);
        }
    #else
        FILE *fp = fopen(path, "rb");
        if(fread(tensor->data, sizeof(__uint32_t), TENSORSIZE(tensor), fp) != TENSORSIZE(tensor)){
            PRINTF("Failed to read that much data from input file: %s\n", path);
            fclose(fp);
            exit(EXIT_FAILURE);
        }
        fclose(fp);
    #endif
    return tensor;
}

//tensor to file
void floattensor_to_file(struct FloatTensor *tensor, char *path){
    #if __PLATFORM == _TCE
        volatile __dataBufAligned float *var = NULL;
        if (strstr(path, "conv0.bin") != NULL){
            PRINTF("Exporting conv0...\n");
            var = &conv0_output[0][0][0];
        } else if (strstr(path, "act15.bin") != NULL){
            PRINTF("Exporting act15...\n");
            var = &act15_output[0][0][0];
        } else if (strstr(path, "conv16.bin") != NULL){
            PRINTF("Exporting conv16...\n");
            var = &conv16_output[0][0][0];
        }

        if (var != NULL) {
            for (int l = 0; l < tensor->N; l++){
                for (int k = 0; k < tensor->C; k++){
                    for (int j = 0; j < tensor->H; j++){
                        for (int i = 0; i < tensor->W; i++){
                            *(var + ((l*tensor->C + k)*tensor->H + j)*tensor->W + i) = *IND4(tensor, l, k, j, i);
                        }
                    }
                }
            }
        } else {
            PRINTF("Cannot export to %s \n", path);
        }
    #else
        FILE *fp = fopen(path, "wb");
        fwrite(tensor->data, sizeof(float), TENSORSIZE(tensor), fp);
        fclose(fp);
    #endif
}

void uinttensor_to_file(struct UIntTensor *tensor, char *path){
    #if __PLATFORM == _TCE
        volatile __dataBufAligned uint32_t *var = NULL;
        if (strstr(path, "act0.bin") != NULL){
            PRINTF("Exporting act0...\n");
            var = &act0_output[0][0][0];
        } else if (strstr(path, "conv1.bin") != NULL){
            PRINTF("Exporting conv1...\n");
            var = &conv1_output[0][0][0];
        } else if (strstr(path, "act1.bin") != NULL){
            PRINTF("Exporting act1...\n");
            var = &act1_output[0][0][0];
        } else if (strstr(path, "conv2.bin") != NULL){
            PRINTF("Exporting conv2...\n");
            var = &conv2_output[0][0][0];
        } else if (strstr(path, "act2.bin") != NULL){
            PRINTF("Exporting act2...\n");
            var = &act2_output[0][0][0];
        } else if (strstr(path, "conv3.bin") != NULL){
            PRINTF("Exporting conv3...\n");
            var = &conv3_output[0][0][0];
        } else if (strstr(path, "act3.bin") != NULL){
            PRINTF("Exporting act3...\n");
            var = &act3_output[0][0][0];
        } else if (strstr(path, "conv4.bin") != NULL){
            PRINTF("Exporting conv4...\n");
            var = &conv4_output[0][0][0];
        } else if (strstr(path, "act4.bin") != NULL){
            PRINTF("Exporting act4...\n");
            var = &act4_output[0][0][0];
        } else if (strstr(path, "conv5.bin") != NULL){
            PRINTF("Exporting conv5...\n");
            var = &conv5_output[0][0][0];
        } else if (strstr(path, "act5.bin") != NULL){
            PRINTF("Exporting act5...\n");
            var = &act5_output[0][0][0];
        } else if (strstr(path, "conv6.bin") != NULL){
            PRINTF("Exporting conv6...\n");
            var = &conv6_output[0][0][0];
        } else if (strstr(path, "act6.bin") != NULL){
            PRINTF("Exporting act6...\n");
            var = &act6_output[0][0][0];
        } else if (strstr(path, "conv7.bin") != NULL){
            PRINTF("Exporting conv7...\n");
            var = &conv7_output[0][0][0];
        } else if (strstr(path, "act7.bin") != NULL){
            PRINTF("Exporting act7...\n");
            var = &act7_output[0][0][0];
        } else if (strstr(path, "conv8.bin") != NULL){
            PRINTF("Exporting conv8...\n");
            var = &conv8_output[0][0][0];
        } else if (strstr(path, "act8.bin") != NULL){
            PRINTF("Exporting act8...\n");
            var = &act8_output[0][0][0];
        } else if (strstr(path, "conv9.bin") != NULL){
            PRINTF("Exporting conv9...\n");
            var = &conv9_output[0][0][0];
        } else if (strstr(path, "act9.bin") != NULL){
            PRINTF("Exporting act9...\n");
            var = &act9_output[0][0][0];
        } else if (strstr(path, "conv10.bin") != NULL){
            PRINTF("Exporting conv10...\n");
            var = &conv10_output[0][0][0];
        } else if (strstr(path, "act10.bin") != NULL){
            PRINTF("Exporting act10...\n");
            var = &act10_output[0][0][0];
        } else if (strstr(path, "conv11.bin") != NULL){
            PRINTF("Exporting conv11...\n");
            var = &conv11_output[0][0][0];
        } else if (strstr(path, "act11.bin") != NULL){
            PRINTF("Exporting act11...\n");
            var = &act11_output[0][0][0];
        } else if (strstr(path, "conv12.bin") != NULL){
            PRINTF("Exporting conv12...\n");
            var = &conv12_output[0][0][0];
        } else if (strstr(path, "act12.bin") != NULL){
            PRINTF("Exporting act12...\n");
            var = &act12_output[0][0][0];
        } else if (strstr(path, "conv13.bin") != NULL){
            PRINTF("Exporting conv13...\n");
            var = &conv13_output[0][0][0];
        } else if (strstr(path, "act13.bin") != NULL){
            PRINTF("Exporting act13...\n");
            var = &act13_output[0][0][0];
        } else if (strstr(path, "conv14.bin") != NULL){
            PRINTF("Exporting conv14...\n");
            var = &conv14_output[0][0][0];
        } else if (strstr(path, "act14.bin") != NULL){
            PRINTF("Exporting act14...\n");
            var = &act14_output[0][0][0];
        } else if (strstr(path, "conv15.bin") != NULL){
            PRINTF("Exporting conv15...\n");
            var = &conv15_output[0][0][0];
        }

        if (var != NULL) {
            for (int l = 0; l < tensor->N; l++){
                for (int k = 0; k < tensor->C; k++){
                    for (int j = 0; j < tensor->H; j++){
                        for (int i = 0; i < tensor->W; i++){
                            *(var + ((l*tensor->C + k)*tensor->H + j)*tensor->W + i) = *IND4(tensor, l, k, j, i);
                        }
                    }
                }
            }
        } else {
            PRINTF("Cannot export to %s \n", path);
        }
    #else
        FILE *fp = fopen(path, "wb");
        fwrite(tensor->data, sizeof(unsigned int), TENSORSIZE(tensor), fp);
        fclose(fp);
    #endif
}

//free tensor memory
void free_floattensor(struct FloatTensor *tensor){
    free(tensor->data);
    free(tensor);
}

void free_uinttensor(struct UIntTensor *tensor){
    free(tensor->data);
    free(tensor);
}