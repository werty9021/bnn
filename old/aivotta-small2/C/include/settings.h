#pragma once

// Input size
#define Hin 5
#define Win 5
// Output/Input channels
#define Co 64
#define Ci 2 //=64 channels/32 packsize
// Kernel size
#define Kx 3
#define Ky Kx

// Platform
#define _CPU 1
#define _TCE 2
#define __PLATFORM _TCE

//#define PRINTF(f_, ...) printf((f_), __VA_ARGS__)
#define PRINTF(f_, ...) (void)0