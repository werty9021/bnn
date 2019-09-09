#include <stdint.h>

volatile int16_t output[32];
volatile int end = 0;
int main(){
    volatile int16_t t = 537;
    output[0] = (int16_t)(t - 320);

    end = 1;
    return 0;
}