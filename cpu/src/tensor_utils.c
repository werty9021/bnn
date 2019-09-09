#include <stdio.h>
#include <stdlib.h>
#include "types.h"
#include "tensor_utils.h"

//init tensor
struct FloatTensor* floattensor_init(int N, int C, int H, int W, bool zeros){
    struct FloatTensor *tensor = (struct FloatTensor *) malloc(sizeof(struct FloatTensor));
    if (tensor == NULL){
        printf("Malloc has failed allocating memory.\n");
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
        printf("Malloc has failed allocating memory.\n");
        free(tensor->data);
        exit(EXIT_FAILURE);
    }
    return tensor;
}

struct UIntTensor* uinttensor_init(int N, int C, int H, int W, bool zeros){
    struct UIntTensor *tensor = (struct UIntTensor *) malloc(sizeof(struct UIntTensor));
    if (tensor == NULL){
        printf("Malloc has failed allocating memory.\n");
        free(tensor);
        exit(EXIT_FAILURE);
    }
    tensor->N = N; tensor->C = C; tensor->H = H; tensor->W = W; 

    if (zeros == true) {
        tensor->data = (unsigned int*) calloc(TENSORSIZE(tensor), sizeof(unsigned int));
    } else {
        tensor->data = (unsigned int*) malloc(TENSORSIZE(tensor) * sizeof(unsigned int));
    }
    
    if(tensor->data == NULL) {
        printf("Malloc has failed allocating memory.\n");
        free(tensor->data);
        exit(EXIT_FAILURE);
    }
    return tensor;
}

struct IntTensor* inttensor_init(int N, int C, int H, int W, bool zeros){
    struct IntTensor *tensor = (struct IntTensor *) malloc(sizeof(struct IntTensor));
    if (tensor == NULL){
        printf("Malloc has failed allocating memory.\n");
        free(tensor);
        exit(EXIT_FAILURE);
    }
    tensor->N = N; tensor->C = C; tensor->H = H; tensor->W = W; 

    if (zeros == true) {
        tensor->data = (int*) calloc(TENSORSIZE(tensor), sizeof(int));
    } else {
        tensor->data = (int*) malloc(TENSORSIZE(tensor) * sizeof(int));
    }
    
    if(tensor->data == NULL) {
        printf("Malloc has failed allocating memory.\n");
        free(tensor->data);
        exit(EXIT_FAILURE);
    }
    return tensor;
}

struct Int16Tensor* int16tensor_init(int N, int C, int H, int W, bool zeros){
    struct Int16Tensor *tensor = (struct Int16Tensor *) malloc(sizeof(struct Int16Tensor));
    if (tensor == NULL){
        printf("Malloc has failed allocating memory.\n");
        free(tensor);
        exit(EXIT_FAILURE);
    }
    tensor->N = N; tensor->C = C; tensor->H = H; tensor->W = W; 

    if (zeros == true) {
        tensor->data = (__int16_t*) calloc(TENSORSIZE(tensor), sizeof(__int16_t));
    } else {
        tensor->data = (__int16_t*) malloc(TENSORSIZE(tensor) * sizeof(__int16_t));
    }
    
    if(tensor->data == NULL) {
        printf("Malloc has failed allocating memory.\n");
        free(tensor->data);
        exit(EXIT_FAILURE);
    }
    return tensor;
}

//tensor from file
struct FloatTensor* floattensor_from_file(int N, int C, int H, int W, char *path){
    struct FloatTensor *tensor = floattensor_init(N, C, H, W, 0);
    FILE *fp = fopen(path, "rb");
    if(fread(tensor->data, sizeof(float), TENSORSIZE(tensor), fp) != TENSORSIZE(tensor)){
        printf("Failed to read that much data from input file: %s\n", path);
        fclose(fp);
        exit(EXIT_FAILURE);
    }
    fclose(fp);
    return tensor;
}

struct UIntTensor* uinttensor_from_file(int N, int C, int H, int W, char *path){
    struct UIntTensor *tensor = uinttensor_init(N, C, H, W, 0);
    FILE *fp = fopen(path, "rb");
    if(fread(tensor->data, sizeof(__uint32_t), TENSORSIZE(tensor), fp) != TENSORSIZE(tensor)){
        printf("Failed to read that much data from input file: %s\n", path);
        fclose(fp);
        exit(EXIT_FAILURE);
    }
    fclose(fp);
    return tensor;
}

struct IntTensor* inttensor_from_file(int N, int C, int H, int W, char *path){
    struct IntTensor* tensor = inttensor_init(N, C, H, W, 0);
    FILE *fp = fopen(path, "rb");
    if(fread(tensor->data, sizeof(int), TENSORSIZE(tensor), fp) != TENSORSIZE(tensor)){
        printf("Failed to read that much data from input file: %s\n", path);
        fclose(fp);
        exit(EXIT_FAILURE);
    }
    fclose(fp);
    return tensor;
}

struct Int16Tensor* int16tensor_from_file(int N, int C, int H, int W, char *path){
    struct Int16Tensor* tensor = int16tensor_init(N, C, H, W, 0);
    FILE *fp = fopen(path, "rb");
    if(fread(tensor->data, sizeof(__int16_t), TENSORSIZE(tensor), fp) != TENSORSIZE(tensor)){
        printf("Failed to read that much data from input file: %s\n", path);
        fclose(fp);
        exit(EXIT_FAILURE);
    }
    fclose(fp);
    return tensor;
}

//tensor to file
void floattensor_to_file(struct FloatTensor *tensor, char *path){
    FILE *fp = fopen(path, "wb");
    fwrite(tensor->data, sizeof(float), TENSORSIZE(tensor), fp);
    fclose(fp);
}

void uinttensor_to_file(struct UIntTensor *tensor, char *path){
    FILE *fp = fopen(path, "wb");
    fwrite(tensor->data, sizeof(unsigned int), TENSORSIZE(tensor), fp);
    fclose(fp);
}

void inttensor_to_file(struct IntTensor *tensor, char *path){
    FILE *fp = fopen(path, "wb");
    fwrite(tensor->data, sizeof(int), TENSORSIZE(tensor), fp);
    fclose(fp);
}

void int16tensor_to_file(struct Int16Tensor *tensor, char *path){
    FILE *fp = fopen(path, "wb");
    fwrite(tensor->data, sizeof(int16_t), TENSORSIZE(tensor), fp);
    fclose(fp);
}
//tensor from ptr?


//free tensor memory
void free_floattensor(struct FloatTensor *tensor){
    free(tensor->data);
    free(tensor);
}

void free_uinttensor(struct UIntTensor *tensor){
    free(tensor->data);
    free(tensor);
}

void free_inttensor(struct IntTensor *tensor){
    free(tensor->data);
    free(tensor);
}

void free_int16tensor(struct Int16Tensor *tensor){
    free(tensor->data);
    free(tensor);
}