#include "tceops.h"
#include "conv_act.h"
#include "conv.h"
#include "act.h"
#include "settings.h"

#if FPGA
volatile int ecc;
volatile int lcc;
#endif
int main(){
    unsigned MMAP[67];
    for (int i = 0, j = 0; i < 67; i++, j+=4){
        MMAP[i] = *(volatile unsigned*) j;
    }

    // conv0(MMAP[2], MMAP[0], MMAP[1]);
    // act0(MMAP[3], MMAP[2]);
    // conv0_act0(MMAP[3], MMAP[0], MMAP[1]);
    
    int j = 4;
    for(int i = 1, j = 4; i < 15; i++, j += 4){//!
        // conv1(MMAP[j+1], MMAP[j-1], MMAP[j]);
        // act1(MMAP[j+3], MMAP[j+1], MMAP[j+2]);
        // conv1_act1(MMAP[j+3], MMAP[j-1], MMAP[j], MMAP[j+2]);
    }
    
    // Conv 15
    // conv1(MMAP[j+1], MMAP[j-1], MMAP[j]);
    j += 2;

    // Relu
    // relu(MMAP[j+2], MMAP[j-1], MMAP[j], MMAP[j+1]);
    j += 3;

    // Conv 16
    j = 256;
    conv2(MMAP[j+1], MMAP[j-1], MMAP[j]);
    #if FPGA
    _TCE_ECC(0, ecc);
    _TCE_LCC(0, lcc);
    #endif
    return 0;
}