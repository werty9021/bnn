#include "tceops.h"
#include "tce_vector.h"
#include <stdint.h>

volatile short32 max_result __attribute__ ((aligned (256)));
volatile short32 shl_result __attribute__ ((aligned (256)));
volatile short32 insert_result __attribute__ ((aligned (256)));
volatile ushort32 popc_result __attribute__ ((aligned (256)));
volatile short32 trunc_result __attribute__ ((aligned (256)));

volatile uint32 xnor_result __attribute__ ((aligned (256)));
volatile int32 xnor_result2 __attribute__ ((aligned (256)));

volatile int32 mac_result __attribute__ ((aligned (256)));
volatile int32 shl_result2 __attribute__ ((aligned (256)));
volatile int32 insert_result2 __attribute__ ((aligned (256)));

volatile int geu_result __attribute__ ((aligned (256)));
volatile unsigned int geu_result2 __attribute__ ((aligned (256)));
volatile uint32_t ge_result;
volatile uint32_t ge_result2;
volatile int reduce_result;

volatile int input;
volatile int output;

volatile short32 sh1  __attribute__ ((aligned (256))) = {0,1,2,3,4,5,6,7,8,9,10,11,12,13,14,15,16,17,18,19,20,21,22,23,24,25,26,27,28,29,30,31};
volatile short32 sh2 __attribute__ ((aligned (256))) = {1,2,3,4,5,6,7,8, 9,10,11,12,13,14,15,16, 17,18,19,20,21,22,23,24, 25,26,27,28,29,30,31,32};
volatile ushort32 ush1 __attribute__ ((aligned (256))) = {2,2,2,3,4,5,6,7,8,9,10,11,12,13,14,15,16,17,18,19,20,21,22,23,24,25,26,27,28,29,30,31};
volatile ushort32 ush2 __attribute__ ((aligned (256))) = {1,2,3,4,5,6,7,8,9,10,11,12,13,14,15,16,17,18,19,20,21,22,23,24,25,26,27,28,29,30,29,0};

volatile int32 i1 __attribute__ ((aligned (256))) = {31,30,29,28,27,26,25,24,23,22,21,20,19,18,17,16,15,14,13,12,11,10,9,8,7,6,5,4,3,2,1,0};
volatile int32 i2 __attribute__ ((aligned (256))) = {1,2,3,4,5,6,7,8,9,10,11,12,13,14,15,16,17,18,19,20,21,22,23,24,25,26,27,28,29,30,31,32};

volatile uint32 ui1 __attribute__ ((aligned (256))) = {31,30,29,28,27,26,25,24,23,22,21,20,19,18,17,16,15,14,13,12,11,10,9,8,7,6,5,4,3,2,1,0};
volatile uint32 ui2 __attribute__ ((aligned (256))) = {1,2,3,4,5,6,7,8,9,10,11,12,13,14,15,16,17,18,19,20,21,22,23,24,25,26,27,28,29,30,31,32};

int main(){
    /* Ops to test:
     * max16x32
     * shlsame16x32/32x32
     * truncwh32x32
     * insertelem16x32/32x32
     * ge32x32to32x1
     * geu16x32to32x1
     * mac16x32to32x32
     * vreduce32x32
     * xnorpopcountacc32x32
     */
    

    // 0x0001 0x0002 0x0003 0x0004 0x0005 0x0006 0x0007 0x0008 0x0009 0x000a 0x000b 0x000c 0x000d 0x000e 0x000f 0x0010 0x0011 0x0012 0x0013 0x0014 0x0015 0x0016 0x0017 0x0018 0x0019 0x001a 0x001b 0x001c 0x001d 0x001e 0x001f 0x0020
    _TCE_MAX16X32(sh1, sh2, max_result); // ok

    // 0x0000 0x0002 0x0004 0x0006 0x0008 0x000a 0x000c 0x000e 0x0010 0x0012 0x0014 0x0016 0x0018 0x001a 0x001c 0x001e 0x0020 0x0022 0x0024 0x0026 0x0028 0x002a 0x002c 0x002e 0x0030 0x0032 0x0034 0x0036 0x0038 0x003a 0x003c 0x003e
    shl_result = sh1<<1; // = ok
    shl_result2 = i1<<1; // = ok

    _TCE_TRUNCWH32X32(i1, trunc_result); // ok

    // 0x0036 0x0001 0x0002 0x0003 0x0004 0x0005 0x0006 0x0007 0x0008 0x0009 0x000a 0x000b 0x000c 0x000d 0x000e 0x000f 0x0010 0x0011 0x0012 0x0013 0x0014 0x0015 0x0016 0x0017 0x0018 0x0019 0x001a 0x001b 0x001c 0x001d 0x001e 0x001f
    _TCE_INSERTELEM16X32(sh1, 54, 0, insert_result); // ok
    _TCE_INSERTELEM32X32(i2, 58, 0, insert_result2); // ok

    // 0xc0000003
    _TCE_GEU16X32TO32X1(ush1, ush2, geu_result); // ok
    // 0x7ffffffc
    _TCE_GEU16X32TO32X1(ush2, ush1, geu_result2); // ok

    // 0xffff0000
    _TCE_GE32X32TO32X1(i1, i2, ge_result); // ok
    // 0x0001ffff
    _TCE_GE32X32TO32X1(i2, i1, ge_result2); // ok

    // 0x00000021 0x00000022 0x00000023 0x00000028 0x0000002f 0x00000038 0x00000043 0x00000050 0x0000005f 0x00000070 0x00000083 0x00000098 0x000000af 0x000000c8 0x000000e3 0x00000100 0x0000011f 0x00000140 0x00000163 0x00000188 0x000001af 0x000001d8 0x00000203 0x00000230 0x0000025f 0x00000290 0x000002c3 0x000002f8 0x0000032f 0x00000368 0x00000367 0x00000000
    _TCE_MAC16X32TO32X32(ush1, ush2, i1, mac_result);

    // 0x000001f0
    _TCE_VREDUCE32X32(i1, reduce_result); // ok

    // 0x001c 0x001e 0x001e 0x0021 0x0020 0x0022 0x0022 0x0026 0x0024 0x0026 0x0026 0x0029 0x0028 0x002a 0x002a 0x002f 0x002c 0x002e 0x002e 0x0031 0x0030 0x0032 0x0032 0x0036 0x0034 0x0036 0x0036 0x0039 0x0038 0x003a 0x003a 0x003e
    _TCE_XNORPOPCOUNTACC32X32(i1, i2, sh1, popc_result);

    // 0xffffffe1 0xffffffe3 0xffffffe1 0xffffffe7 0xffffffe1 0xffffffe3 0xffffffe1 0xffffffef 0xffffffe1 0xffffffe3 0xffffffe1 0xffffffe7 0xffffffe1 0xffffffe3 0xffffffe1 0xffffffff 0xffffffe1 0xffffffe3 0xffffffe1 0xffffffe7 0xffffffe1 0xffffffe3 0xffffffe1 0xffffffef 0xffffffe1 0xffffffe3 0xffffffe1 0xffffffe7 0xffffffe1 0xffffffe3 0xffffffe1 0xffffffdf
    _TCE_XOR1024(ui1, ui2, xnor_result);
    _TCE_NOT1024(xnor_result, xnor_result2); // ok

    output = input + 1;

    return 0;
}
