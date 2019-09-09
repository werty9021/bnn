#include <stdio.h>
#include "print_arrays.h"
#include "tensor_utils.h"

void print1DFloatArray(int size, float *array){
    printf("[");
    char *sep = "";
    for(int i = 0; i < size; i++){
        printf("%s%f", sep, *(array + i));
        sep = ", ";
    }
    printf("]");
}

void print2DFloatArray(int y, int x, float *array){
    printf("[");
    char *sep = "";
    for(int i = 0; i < y; i++){
        printf("%s", sep);
        print1DFloatArray(x, (array + i*x));
        sep = ",\n ";
    }
    printf("]\n");
}

void print3DFloatArray(int z, int y, int x, float *array){ // 2,5,5
    printf("[");
    char *sep = "";
    char *sep2 = "";
    for(int i = 0; i < z; i++){
        printf("%s[", sep);
        sep2 = "";
        for(int j = 0; j < y; j++){
            printf("%s", sep2);
            print1DFloatArray(x, (array + i*y*x + j*x));
            sep2 = ",\n  ";
        }
        printf("]");

        sep = ",\n\n ";
    }
    printf("]\n");
}

void print4DFloatArray(int w, int z, int y, int x, float *array){ // 2,1,3,3
    printf("[");
    char *sep = "";
    char *sep2 = "";
    char *sep3 = "";
    for(int i = 0; i < w; i++){
        printf("%s[", sep);
        sep2 = "";
        for(int j = 0; j < z; j++){
            printf("%s[", sep2);
            sep3 = "";
            for(int k = 0; k < y; k++){
                printf("%s", sep3);
                print1DFloatArray(x, (array + i*z*y*x + j*y*x + k*x));
                sep3 = ",\n   ";
            }
            printf("]");

            sep2 = ",\n\n  ";
        }
        printf("]");
        sep = ",\n\n ";
    }
    printf("]\n");
}

// TODO: asprintf; spaces based on tensor dims?
void printFloatTensor(struct FloatTensor *tensor){
    printf("[");
    char *sep = "";
    char *sep2 = "";
    char *sep3 = "";
    // char *sep4 = "";
    for(int l = 0; l < tensor->N; l++){
        if (tensor->N > 1)
            printf("%s[", sep);
        sep2 = "";
        for(int k = 0; k < tensor->C; k++){
            if (tensor->C > 1)
                printf("%s[", sep2);
            sep3 = "";
            for(int j = 0; j < tensor->H; j++){
                if (tensor->H > 1)
                    printf("%s[", sep3);
                // sep4 = "";
                // for(int i = 0; i < tensor->W; i++){
                //     printf("%s%f", sep4, *IND4(tensor, l, k, j, i));
                //     sep4 = ", ";
                // }
                if (tensor->H > 1)
                    printf("]");
                sep3 = ",\n   ";
            }
            if (tensor->C > 1)
                printf("]");
            sep2 = ",\n\n  ";
        }
        if (tensor->N > 1)
            printf("]");
        sep = ",\n\n ";
    }
    printf("]\n");
}

void printUIntTensor(struct UIntTensor *tensor){
    printf("[");
    char *sep = "";
    char *sep2 = "";
    char *sep3 = "";
    char *sep4 = "";
    for(int l = 0; l < tensor->N; l++){
        if (tensor->N > 1)
            printf("%s[", sep);
        sep2 = "";
        for(int k = 0; k < tensor->C; k++){
            if (tensor->C > 1)
                printf("%s[", sep2);
            sep3 = "";
            for(int j = 0; j < tensor->H; j++){
                if (tensor->H > 1)
                    printf("%s[", sep3);
                sep4 = "";
                for(int i = 0; i < tensor->W; i++){
                    printf("%s%d", sep4, *IND4(tensor, l, k, j, i));
                    sep4 = ", ";
                }
                if (tensor->H > 1)
                    printf("]");
                sep3 = ",\n   ";
            }
            if (tensor->C > 1)
                printf("]");
            sep2 = ",\n\n  ";
        }
        if (tensor->N > 1)
            printf("]");
        sep = ",\n\n ";
    }
    printf("]\n");
}