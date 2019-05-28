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
        tensor->data = (uint32_t*) calloc(TENSORSIZE(tensor), sizeof(uint32_t));
    } else {
        tensor->data = (uint32_t*) malloc(TENSORSIZE(tensor) * sizeof(uint32_t));
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

//tensor from ptr
struct FloatTensor* floattensor_from_ptr(int N, int C, int H, int W, float *data){
    struct FloatTensor *tensor = (struct FloatTensor *) malloc(sizeof(struct FloatTensor));
    if (tensor == NULL){
        printf("Malloc has failed allocating memory.\n");
        free(tensor);
        exit(EXIT_FAILURE);
    }
    tensor->N = N; tensor->C = C; tensor->H = H; tensor->W = W; tensor->data = data;

    return tensor;
}

struct UIntTensor* uinttensor_from_ptr(int N, int C, int H, int W, uint32_t *data){
    struct UIntTensor *tensor = uinttensor_init(N, C, H, W, 0);
    tensor->data = data;

    return tensor;
}

struct IntTensor* inttensor_from_ptr(int N, int C, int H, int W, int *data){
    struct IntTensor *tensor = inttensor_init(N, C, H, W, 0);
    tensor->data = data;

    return tensor;
}


//free tensor memory
void free_floattensor(struct FloatTensor *tensor){
    // free(tensor->data);
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