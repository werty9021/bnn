#include "tceops.h"
#include "tce_vector.h"
#include <stdint.h>
#include "dma.h"

// #define _global __attribute__((address_space(1))) // AXI

// #define DMEM_OFFSET 0x43C40000
#define DMEM_OFFSET 0x0

// global
const int O_y = 48; // Output map height
const int O_x = 32; // Output map width
const int O_n = 1; // Batch size

// Conv properties
const int K_y = 3, K_x = 3; // Kernel size
const int P_y = 1, P_x = 1; // Padding size

// Pointer meth macro's
#define IND2(j, i, I) (j*I + i)
#define IND3(k, j, J, i, I) IND2(IND2(k, j, J), i, I)
#define IND4(l, k, K, j, J, i, I) IND2(IND3(l, k, K, j, J), i, I)

// // volatile int16_t B_in[1][10][12][1];
// // volatile short32 B_w[3][3][1][1];
// // volatile int32 B_out[1][6][8][1] = {0};
// void conv0(volatile unsigned* l0_output_ptr, volatile unsigned* l0_input_ptr, volatile unsigned * l0_weight_ptr){
//     unsigned input_ptr = *l0_input_ptr;
//     unsigned weight_ptr = *l0_weight_ptr;
//     unsigned output_ptr = *l0_output_ptr;
//     // Per layer
//     const int K_c = 1; // Input maps
//     const int O_c = 64; // Output channels
//     // Tiling settings
//     const int TO_c = 32; // Tile Output channels
//     const int TO_y = 6; // Tile Output map height
//     const int TO_x = 8; // Tile Output map width
//     const int TK_c = 1; // Tile Input maps
//     const int TO_n = 1; // Tile Batch size
//     // Buffers
//     int16_t B_in[TO_n][TO_y+2*(K_y-P_y)][TO_x+2*(K_x-P_y)][TK_c];
//     short32 B_w[K_y][K_x][TK_c][TO_c/32];

//     for(int o_c = 0; o_c < O_c; o_c += TO_c){
//         for(int k_c = 0; k_c < K_c; k_c += TK_c){
//             // DMA get w[0:K_y][0:K_x][k_c:TK_c][o_c:TO_c] to B_w
//             for(int k = 0; k < K_y; k++){
//                 for(int j = 0; j < K_x; j++){
//                     for(int i = 0; i < TK_c; i++){
//                         unsigned ptr = 2*IND4(k, j, K_x, (k_c + i), K_c, o_c, O_c);
//                         dma_queue_bursts(weight_ptr + ptr, (DMEM_OFFSET + (unsigned) &B_w[k][j][i][0]), TO_c, 2);
//                         dma_wait();
//             }}} // End DMA get w to B_w loop
//             //dma_wait();

//             for(int o_n = 0; o_n < O_n; o_n += TO_n){
//                 for(int o_y = 0; o_y < O_y; o_y += TO_y){
//                     for(int o_x = 0; o_x < O_x; o_x += TO_x){
//                         // Output Buffer
//                         int32 B_out[TO_n][TO_y][TO_x][TO_c/32] = {0}; // NEED TO SET TO ZERO EXPLICITLY, MISSING ld8/st8 FOR MEMSET!

//                         // DMA get in[o_n: TO_n][i_y: TI_y][i_x: TI_x][k_c:TK_c] to B_in
//                         /* // To only load what's necessary:
//                         unsigned y_end = (O_y-o_y) != TO_y ? (TO_y+K_y) : TO_y;
//                         unsigned x_end = (O_x-o_x) != TO_x ? (TO_x+K_x) : TO_x;
//                         */
//                         for(int k = 0; k < TO_n; k++){
//                             for(int j = 0; j < (TO_y+2*(K_y-P_y)); j++){
//                                 //for(int i = 0; i < (TO_x+K_x-P_x); i++){
//                                     unsigned ptr = 2*IND4((o_n + k), (o_y + j - 2*P_y), O_y, (o_x + 0 - 2*P_x), O_x, k_c, K_c); // -px
//                                     dma_queue_bursts(input_ptr + ptr, (DMEM_OFFSET + (unsigned) &B_in[k][j][0][0]), (TO_x+2*(K_x-P_x))*TK_c, 2);
//                                     dma_wait();
//                         }}//} // End DMA get in to B_in loop

//                         // if (k_c != 0){
//                         //     // DMA get out[o_n:TO_n][o_y:TO_y][o_x:TO_x][o_c:TO_c] to B_out
//                         //     for(int k = 0; k < TO_n; k++){
//                         //         for(int j = 0; j < TO_y; j++){
//                         //             for(int i = 0; i < TO_x; i++){
//                         //                 unsigned ptr = 4*IND4((o_n + k), (o_y + j), O_y, (o_x + i), O_x, o_c, O_c);
//                         //                 dma_queue_bursts(output_ptr + ptr, (DMEM_OFFSET + (unsigned) &B_out[k][j][i][0]), TO_c, 4);
//                         //                 dma_wait();
//                         //     }}} // End DMA get out to B_out loop
//                         //     // dma_wait();
//                         // }

//                         // Wait on all buffers to be filled
//                         dma_wait();

//                         // Intra-tile loop
//                         for(int to_n = 0; to_n < TO_n; to_n++){
//                             for(int to_y = 0; to_y < TO_y; to_y++){
//                                 for(int to_x = 0; to_x < TO_x; to_x++){
//                                     unsigned k_y_start = (o_y+to_y < P_y) ? (P_y - (o_y+to_y)) : 0;
//                                     unsigned k_y_end = (o_y+to_y >= O_y - P_y) ? (K_y - P_y - 1 + O_y - (o_y+to_y)) : K_y;
//                                     for(int k_y = k_y_start; k_y < k_y_end; k_y++){
//                                         unsigned k_x_start = (o_x + to_x < P_x) ? (P_x - (o_x + to_x)) : 0;
//                                         unsigned k_x_end = (o_x+to_x >= O_x - P_x) ? (K_x - P_x - 1 + O_x - (o_x + to_x)) : K_x;
//                                         for(int k_x = k_x_start; k_x < k_x_end; k_x++){
//                                             for(int tk_c = 0; tk_c < TK_c; tk_c++){
//                                                 short32 v_input;
//                                                 _TCE_VBCAST16X32(B_in[to_n][to_y+k_y+1][to_x+k_x+1][tk_c], v_input); // -1
//                                                 for(int to_c = 0; to_c < TO_c/32; to_c++){
//                                                     // B_out[to_n][to_y][to_x][to_c] += B_in[to_n][to_y+k_y-P_y][to_x+k_x-P_x][tk_c] * B_w[k_y][k_x][tk_c][to_c];
//                                                     _TCE_MAC16X32TO32X32(v_input, B_w[k_y][k_x][tk_c][to_c], B_out[to_n][to_y][to_x][to_c], B_out[to_n][to_y][to_x][to_c]);
//                         }}}}}}} // End intra-tile loop
                        
//                         // DMA put B_out to out[o_n:TO_n][o_y:TO_y][o_x:TO_x][o_c:TO_c]
//                         for(int k = 0; k < TO_n; k++){
//                             for(int j = 0; j < TO_y; j++){
//                                 for(int i = 0; i < TO_x; i++){
//                                     unsigned ptr = 4*IND4((o_n + k), (o_y + j), O_y, (o_x + i), O_x, o_c, O_c);
//                                     dma_queue_bursts((DMEM_OFFSET + (unsigned) &B_out[k][j][i][0]), output_ptr + ptr, TO_c, 4); 
//                                     dma_wait();
//                         }}} // End DMA put B_out to out loop
//                         dma_wait();
//     }}}}}
// }

// void act0(volatile unsigned* l0_output_ptr, volatile unsigned* l0_input_ptr){
//     unsigned input_ptr = *l0_input_ptr;
//     unsigned output_ptr = *l0_output_ptr;

//     const int K_c = 64; // Input/Output maps
//     // Tiling settings
//     const int TO_n = 1; // Tile Batch size
//     const int TO_y = 1; // Tile Output map height
//     const int TO_x = 16; // Tile Output map width
//     const int TK_c = 64; // Tile Input/Output maps (multiple of 32)
    
//     // Buffers
//     volatile int32 B_in[TO_n][TO_y][TO_x][TK_c/32];
//     int32 thresholds_v = {0};

//     // Inter-tile loop
//     for(int o_n = 0; o_n < O_n; o_n += TO_n){
//         for(int o_y = 0; o_y < O_y; o_y += TO_y){
//             for(int o_x = 0; o_x < O_x; o_x += TO_x){
//                 for(int k_c = 0; k_c < K_c; k_c += TK_c){
//                     volatile int32_t B_out[TO_n][TO_y][TO_x][TK_c/32] = {0};

//                     // DMA get in[o_n:TO_n][o_y:TO_y][O_x:TO_x][k_c:TK_c] to B_in
//                     for(int k = 0; k < TO_n; k++){
//                         for(int j = 0; j < TO_y; j++){
//                             // for(int i = 0; i < TO_x; i++){
//                                 unsigned ptr = 4*IND4((o_n + k), (o_y + j), O_y, o_x, O_x, k_c, K_c);
//                                 dma_queue_bursts(input_ptr + ptr, (DMEM_OFFSET + (unsigned) &B_in[k][j][0][0]), (TO_x*TK_c), 4);
//                                 // dma_wait();
//                     }}//} // End DMA get in to B_in loop

//                     dma_wait();

//                     // Intra-tile loop
//                     for(int to_n = 0; to_n < TO_n; to_n++){
//                         for(int to_y = 0; to_y < TO_y; to_y++){
//                             for(int to_x = 0; to_x < TO_x; to_x++){
//                                 for(int tk_c = 0; tk_c < TK_c/32; tk_c++){
//                                     _TCE_GE32X32TO32X1(B_in[to_n][to_y][to_x][tk_c], thresholds_v, B_out[to_n][to_y][to_x][tk_c]);
//                     }}}} // End intra-tile loop

//                     // DMA put B_out to out[o_n:TO_n][o_y:TO_y][o_x:TO_x][k_c:TK_c]
//                     for(int k = 0; k < TO_n; k++){
//                         for(int j = 0; j < TO_y; j++){
//                             // for(int i = 0; i < TO_x; i++){
//                                 unsigned ptr = 4*IND4((o_n + k), (o_y + j), O_y, (o_x), O_x, k_c, K_c/32);
//                                 dma_queue_bursts((DMEM_OFFSET + (unsigned) &B_out[k][j][0][0]), output_ptr + ptr, (TO_x*TK_c/32), 4); 
//                                 // dma_wait();
//                     }}//} // End DMA put B_out to out loop
//                     dma_wait();
//     }}}} // End inter-tile loop
// }

// volatile uint32_t B_in[1][8][10][2];
// volatile uint32 B_w[3][3][2][1];
// volatile ushort32 B_out[1][6][8][1];// = {0};
// volatile uint32 v_input;
void conv1(unsigned output_ptr, unsigned input_ptr, unsigned weight_ptr){
    // Per layer
    const int K_c = 2; // Input maps
    const int O_c = 64; // Output channels
    // Tiling settings
    const int TO_c = 32; // Tile Output channels
    const int TO_y = 4; // Tile Output map height
    const int TO_x = 4; // Tile Output map width
    const int TK_c = 2; // Tile Input maps
    const int TO_n = 1; // Tile Batch size
    // Buffers
    uint32_t B_in[TO_n][TO_y+K_y-P_y][TO_x+K_x-P_x][TK_c];
    uint32 B_w[K_y][K_x][TK_c][TO_c/32];

    for(int o_c = 0; o_c < O_c; o_c += TO_c){
        for(int k_c = 0; k_c < K_c; k_c += TK_c){
            // DMA get w[0:K_y][0:K_x][k_c:TK_c][o_c:TO_c] to B_w
            for(int k = 0; k < K_y; k++){
                for(int j = 0; j < K_x; j++){
                    for(int i = 0; i < TK_c; i++){
                        unsigned ptr = 4*IND4(k, j, K_x, (k_c + i), K_c, o_c, O_c);
                        dma_queue_bursts(weight_ptr + ptr, (DMEM_OFFSET + (unsigned) &B_w[k][j][i][0]), TO_c, 4);
                        // dma_wait();
            }}} // End DMA get w to B_w loop
            //dma_wait();

            for(int o_n = 0; o_n < O_n; o_n += TO_n){
                for(int o_y = 0; o_y < O_y; o_y += TO_y){
                    for(int o_x = 0; o_x < O_x; o_x += TO_x){
                        // Output Buffer
                        ushort32 B_out[TO_n][TO_y][TO_x][TO_c/32] = {0}; // NEED TO SET TO ZERO EXPLICITLY & DMA B_out to out should be finished!
                        
                        // DMA get in[o_n: TO_n][i_y: TI_y][i_x: TI_x][k_c:TK_c] to B_in
                        /* // To only load what's necessary:
                        unsigned y_start = (o_y < P_y) ? (P_y - o_y) : 0;
                        unsigned y_end = (O_y-o_y) != TO_y ? TO_y+K_y-P_y : TO_y + P_y;
                        unsigned x_start = (o_x < P_x) ? (P_x - o_x) : 0;
                        unsigned x_end = (O_x-o_x) != TO_x ? TO_x+K_x-P_x : TO_x + P_x;
                        */
                        for(int k = 0; k < TO_n; k++){
                            for(int j = 0; j < (TO_y+K_y-P_y); j++){
                                // for(int i = 0; i < (TO_x+K_x-P_x); i++){
                                    unsigned ptr = 4*IND4((o_n + k), (o_y + j - P_y), O_y, (o_x + 0 - P_x), O_x, k_c, K_c);
                                    dma_queue_bursts(input_ptr + ptr, (DMEM_OFFSET + (unsigned) &B_in[k][j][0][0]), ((TO_x+K_x-P_x)*TK_c), 4);
                                    // dma_wait();
                        }}//} // End DMA get in to B_in loop

                        // if (k_c != 0){
                            // DMA get out[o_n:TO_n][o_y:TO_y][o_x:TO_x][o_c:TO_c] to B_out
                            // for(int k = 0; k < TO_n; k++){
                            //     for(int j = 0; j < TO_y; j++){
                            //         for(int i = 0; i < TO_x; i++){
                            //             unsigned ptr = 2*IND4((o_n + k), (o_y + j), O_y, (o_x + i), O_x, o_c, O_c);
                            //             dma_queue_bursts(output_ptr + ptr, (DMEM_OFFSET + (unsigned) &B_out[k][j][i][0]), TO_c, 2);
                            //             dma_wait();
                            // }}} // End DMA get out to B_out loop
                            // dma_wait();
                        // }

                        // Wait on all buffers to be filled
                        dma_wait();

                        // Intra-tile loop
                        for(int to_n = 0; to_n < TO_n; to_n++){
                            for(int to_y = 0; to_y < TO_y; to_y++){
                                for(int to_x = 0; to_x < TO_x; to_x++){
                                    unsigned k_y_start = (o_y+to_y < P_y) ? (P_y - (o_y+to_y)) : 0;
                                    unsigned k_y_end = (o_y+to_y >= O_y - P_y) ? (K_y - P_y - 1 + O_y - (o_y+to_y)) : K_y;
                                    for(int k_y = k_y_start; k_y < k_y_end; k_y++){
                                        unsigned k_x_start = (o_x + to_x < P_x) ? (P_x - (o_x + to_x)) : 0;
                                        unsigned k_x_end = (o_x+to_x >= O_x - P_x) ? (K_x - P_x - 1 + O_x - (o_x + to_x)) : K_x;
                                        for(int k_x = k_x_start; k_x < k_x_end; k_x++){
                                            for(int tk_c = 0; tk_c < TK_c; tk_c++){
                                                // uint32 v_input;
                                                // _TCE_VBCAST32X32(B_in[to_n][to_y+k_y][to_x+k_x][tk_c], v_input);
                                                for(int to_c = 0; to_c < TO_c/32; to_c++){
                                                    // B_out[to_n][to_y][to_x][to_c] += B_in[to_n][to_y+k_y-P_y][to_x+k_x-P_x][tk_c] * B_w[k_y][k_x][tk_c][to_c];
                                                    // _TCE_XNORPOPCOUNTACC32X32(v_input, B_w[k_y][k_x][tk_c][to_c], B_out[to_n][to_y][to_x][to_c], B_out[to_n][to_y][to_x][to_c]);
                                                    _TCE_XNORPOPCOUNTACC32X32(B_in[to_n][to_y+k_y][to_x+k_x][tk_c], B_w[k_y][k_x][tk_c][to_c], B_out[to_n][to_y][to_x][to_c], B_out[to_n][to_y][to_x][to_c]);
                        }}}}}}} // End intra-tile loop
                        
                        // DMA put B_out to out[o_n:TO_n][o_y:TO_y][o_x:TO_x][o_c:TO_c]
                        for(int k = 0; k < TO_n; k++){
                            for(int j = 0; j < TO_y; j++){
                                for(int i = 0; i < TO_x; i++){
                                    unsigned ptr = 2*IND4((o_n + k), (o_y + j), O_y, (o_x + i), O_x, o_c, O_c);
                                    dma_queue_bursts((DMEM_OFFSET + (unsigned) &B_out[k][j][i][0]), output_ptr + ptr, TO_c, 2);
                                    // dma_wait();
                        }}} // End DMA put B_out to out loop
                        dma_wait();
    }}}}}
    
}

// // volatile ushort32 B_in[1][1][4][2];
// // volatile uint16_t B_thresholds[64];
// // volatile uint32_t B_out[1][1][4][2];
// // volatile ushort32 thresholds_v;
// // volatile ushort32 input_v;
// void act1(unsigned output_ptr, unsigned input_ptr, unsigned threshold_ptr){
//     const int K_c = 64; // Input/Output maps
//     // Tiling settings
//     const int TO_n = 1; // Tile Batch size
//     const int TO_y = 1; // Tile Output map height
//     const int TO_x = 4; // Tile Output map width
//     const int TK_c = 64; // Tile Input/Output maps (multiple of 32)
    
//     // Buffers
//     ushort32 B_in[TO_n][TO_y][TO_x][TK_c/32];
//     uint16_t B_thresholds[TK_c];// = {0}; // = {0} -> otherwise broken
//     uint32_t B_out[TO_n][TO_y][TO_x][TK_c/32];// = {0};
//     // DMA get thresholds
//     dma_queue_bursts(threshold_ptr, (DMEM_OFFSET + (unsigned) &B_thresholds[0]), (TK_c), 2);
//     // dma_wait();

//     // Inter-tile loop
//     for(int o_n = 0; o_n < O_n; o_n += TO_n){
//         for(int o_y = 0; o_y < O_y; o_y += TO_y){
//             for(int o_x = 0; o_x < O_x; o_x += TO_x){
//                 for(int k_c = 0; k_c < K_c; k_c += TK_c){
//                     // DMA get in[o_n:TO_n][o_y:TO_y][O_x:TO_x][k_c:TK_c] to B_in
//                     for(int k = 0; k < TO_n; k++){
//                         for(int j = 0; j < TO_y; j++){
//                             // for(int i = 0; i < TO_x; i++){
//                                 unsigned ptr = 2*IND4((o_n + k), (o_y + j), O_y, o_x, O_x, 0, K_c);
//                                 dma_queue_bursts(input_ptr + ptr, (DMEM_OFFSET + (unsigned) &B_in[k][j][0][0]), (TO_x*TK_c), 2);
//                                 // dma_wait();
//                     }}//} // End DMA get in to B_in loop

//                     dma_wait();

//                     // Intra-tile loop
//                     for(int to_n = 0; to_n < TO_n; to_n++){
//                         for(int to_y = 0; to_y < TO_y; to_y++){
//                             for(int to_x = 0; to_x < TO_x; to_x++){
//                                 uint16_t T = 0;
//                                 if ((o_x + to_x) == 0 || (o_x + to_x) == O_x-1){
//                                     T += 3*64;
//                                 }
//                                 if ((o_y + to_y) == 0 || (o_y + to_y) == O_y-1){
//                                     T += 3*64;
//                                 }
//                                 if (((o_y + to_y) == 0 && (o_x + to_x) == 0) || ((o_y + to_y) == O_y-1 && (o_x + to_x) == 0) || 
//                                     ((o_y + to_y) == 0 && (o_x + to_x) == O_x-1) || ((o_y + to_y) == O_y-1 && (o_x + to_x) == O_x-1)){
//                                     T -= 1*64;
//                                 }

//                                 for(int tk_c = 0; tk_c < TK_c/32; tk_c++){
//                                     ushort32 thresholds_v;
//                                     for(int pos = 0; pos < 32; pos++){
//                                         uint16_t thres = B_thresholds[(k_c + tk_c)*32 + pos] > T ? B_thresholds[(k_c + tk_c)*32 + pos] - T : 0;
//                                         _TCE_INSERTELEM16X32(thresholds_v, thres, pos, thresholds_v);
//                                     }
                                    
//                                     ushort32 input_v = B_in[to_n][to_y][to_x][tk_c] << 1;
//                                     _TCE_GEU16X32TO32X1(input_v, thresholds_v, B_out[to_n][to_y][to_x][tk_c]);
//                     }}}} // End intra-tile loop

//                     // DMA put B_out to out[o_n:TO_n][o_y:TO_y][o_x:TO_x][k_c:TK_c]
//                     for(int k = 0; k < TO_n; k++){
//                         for(int j = 0; j < TO_y; j++){
//                             // for(int i = 0; i < TO_x; i++){
//                                 unsigned ptr = 4*IND4((o_n + k), (o_y + j), O_y, (o_x), O_x, k_c, K_c/32);
//                                 dma_queue_bursts((DMEM_OFFSET + (unsigned) &B_out[k][j][0][0]), output_ptr + ptr, (TO_x*TK_c/32), 4); 
//                                 // dma_wait();
//                     }}//} // End DMA put B_out to out loop
//                     // dma_wait();
//     }}}} // End inter-tile loop
//     dma_wait();
// }

// // volatile ushort32 B_in[1][1][1][1];
// // volatile short32 B_out[1][1][1][1];
// // volatile short32 B_a_thresholds[1];
// // volatile int32 B_b_thresholds[1];
// void relu(unsigned output_ptr, unsigned input_ptr, unsigned a_threshold_ptr, unsigned b_threshold_ptr){
//     const int K_c = 64; // Input/Output maps
//     // Tiling settings
//     const int TO_n = 1; // Tile Batch size
//     const int TO_y = 1; // Tile Output map height
//     const int TO_x = 1; // Tile Output map width
//     const int TK_c = 32; // Tile Input/Output maps (multiple of 32)
    
//     // Buffers
//     ushort32 B_in[TO_n][TO_y][TO_x][TK_c/32];
//     short32 B_out[TO_n][TO_y][TO_x][TK_c/32];
//     short32 B_a_thresholds[TK_c/32];
//     int32 B_b_thresholds[TK_c/32];

//     short32 zeros = {0};

//     // Inter-tile loop
//     for(int o_n = 0; o_n < O_n; o_n += TO_n){
//         for(int o_y = 0; o_y < O_y; o_y += TO_y){ //!
//             for(int o_x = 0; o_x < O_x; o_x += TO_x){ //!
//                 for(int k_c = 0; k_c < K_c; k_c += TK_c){ //!
//                     // DMA get thresholds
//                     dma_queue_bursts(a_threshold_ptr + 2*k_c, (DMEM_OFFSET + (unsigned) &B_a_thresholds[0]), (TK_c), 2);
//                     dma_queue_bursts(b_threshold_ptr + 4*k_c, (DMEM_OFFSET + (unsigned) &B_b_thresholds[0]), (TK_c), 4);
//                     // dma_wait();

//                     // DMA get in[o_n:TO_n][o_y:TO_y][O_x:TO_x][k_c:TK_c] to B_in
//                     for(int k = 0; k < TO_n; k++){
//                         for(int j = 0; j < TO_y; j++){
//                             for(int i = 0; i < TO_x; i++){
//                                 unsigned ptr = 2*IND4((o_n + k), (o_y + j), O_y, o_x, (O_x + i), k_c, K_c); // !
//                                 dma_queue_bursts(input_ptr + ptr, (DMEM_OFFSET + (unsigned) &B_in[k][j][0][0]), (TK_c), 2); //!
//                                 // dma_wait();
//                     }}} // End DMA get in to B_in loop

//                     dma_wait();

//                     // Intra-tile loop
//                     for(int to_n = 0; to_n < TO_n; to_n++){
//                         for(int to_y = 0; to_y < TO_y; to_y++){
//                             for(int to_x = 0; to_x < TO_x; to_x++){
//                                 int16_t T = -9*64;
//                                 if ((o_x + to_x) == 0 || (o_x + to_x) == O_x-1){
//                                     T += 3*64;
//                                 }
//                                 if ((o_y + to_y) == 0 || (o_y + to_y) == O_y-1){
//                                     T += 3*64;
//                                 }
//                                 if (((o_y + to_y) == 0 && (o_x + to_x) == 0) || ((o_y + to_y) == O_y-1 && (o_x + to_x) == 0) || 
//                                     ((o_y + to_y) == 0 && (o_x + to_x) == O_x-1) || ((o_y + to_y) == O_y-1 && (o_x + to_x) == O_x-1)){
//                                     T -= 1*64;
//                                 }
//                                 short32 vT;
//                                 _TCE_VBCAST16X32(T, vT);

//                                 for(int tk_c = 0; tk_c < TK_c/32; tk_c++){
//                                     // short32 vA = B_a_thresholds[tk_c];
//                                     // int32 vB = B_b_thresholds[tk_c];

//                                     int32 y = {0};
//                                     // y0 = vA*vT + vB
//                                     _TCE_MAC16X32TO32X32(B_a_thresholds[tk_c], vT, B_b_thresholds[tk_c], y);
//                                     // y = 2*vA*X + y0                                  
//                                     _TCE_MAC16X32TO32X32(B_a_thresholds[tk_c]<<1, B_in[to_n][to_y][to_x][tk_c], y, y); // B_in signed vs unsigned problem?
//                                     short32 z;
//                                     _TCE_TRUNCWH32X32(y, z);
//                                     // MAX(z,0)
//                                     _TCE_MAX16X32(z, zeros, B_out[to_n][to_y][to_x][tk_c]);
//                     }}}} // End intra-tile loop

//                     // DMA put B_out to out[o_n:TO_n][o_y:TO_y][o_x:TO_x][k_c:TK_c]
//                     for(int k = 0; k < TO_n; k++){
//                         for(int j = 0; j < TO_y; j++){
//                             for(int i = 0; i < TO_x; i++){
//                                 unsigned ptr = 2*IND4((o_n + k), (o_y + j), O_y, (o_x + i), O_x, k_c, K_c); //!
//                                 dma_queue_bursts((DMEM_OFFSET + (unsigned) &B_out[k][j][i][0]), output_ptr + ptr, (TK_c), 2);
//                                 // dma_wait();
//                     }}} // End DMA put B_out to out loop
//     }}}} // End inter-tile loop
//     dma_wait();
// }

// volatile short32 B_in[1][10][12][1];
// volatile short32 B_w[3][3][1][1];
// volatile int32_t B_out[1][6][7][1] = {0};
// void conv2(volatile unsigned* a_output_ptr, volatile unsigned* a_input_ptr, volatile unsigned * a_weight_ptr){
//     unsigned input_ptr = *a_input_ptr;
//     unsigned weight_ptr = *a_weight_ptr;
//     unsigned output_ptr = *a_output_ptr;
// void conv2(unsigned output_ptr, unsigned input_ptr, unsigned weight_ptr){
//     // Per layer
//     const int K_c = 64; // Input maps
//     const int O_c = 1; // Output channels
//     // Tiling settings
//     const int TO_c = 1; // Tile Output channels
//     const int TO_y = 6; // Tile Output map height
//     const int TO_x = 8; // Tile Output map width
//     const int TK_c = 32; // Tile Input maps
//     const int TO_n = 1; // Tile Batch size
//     // Buffers
//     short32 B_in[TO_n][TO_y+2*(K_y-P_y)][TO_x+2*(K_x-P_x)][TK_c/32];
//     short32 B_w[K_y][K_x][TK_c/32][TO_c]; // moet die /32 hier wel?

//     // dma_queue_bursts(input_ptr, (DMEM_OFFSET + (unsigned) &B_in[0][0][0][0]), (TK_c), 2);

//     for(int o_c = 0; o_c < O_c; o_c += TO_c){
//         for(int k_c = 0; k_c < K_c; k_c += TK_c){
//             // DMA get w[0:K_y][0:K_x][k_c:TK_c][o_c:TO_c] to B_w
//             for(int k = 0; k < K_y; k++){
//                 for(int j = 0; j < K_x; j++){
//                     // for(int i = 0; i < TK_c; i++){
//                         unsigned ptr = 2*IND4(k, j, K_x, (k_c + 0), K_c, o_c, O_c);
//                         dma_queue_bursts(weight_ptr + ptr, (DMEM_OFFSET + (unsigned) &B_w[k][j][0][0]), (TK_c*TO_c), 2);
//                         // dma_wait();
//             }}//} // End DMA get w to B_w loop
//             //dma_wait();

//             for(int o_n = 0; o_n < O_n; o_n += TO_n){
//                 for(int o_y = 0; o_y < O_y; o_y += TO_y){
//                     for(int o_x = 0; o_x < O_x; o_x += TO_x){
//                         // Output Buffer
//                         int32_t B_out[TO_n][TO_y][TO_x][TO_c] = {0}; // NEED TO SET TO ZERO EXPLICITLY, MISSING ld8/st8 FOR MEMSET!

//                         // DMA get in[o_n: TO_n][i_y: TI_y][i_x: TI_x][k_c:TK_c] to B_in
//                         /* // To only load what's necesarry:
//                         unsigned y_start = (o_y < P_y) ? (P_y - o_y) : 0;
//                         unsigned y_end = (O_y-o_y) != TO_y ? TO_y+K_y-P_y : TO_y + P_y;
//                         unsigned x_start = (o_x < P_x) ? (P_x - o_x) : 0;
//                         unsigned x_end = (O_x-o_x) != TO_x ? TO_x+K_x-P_x : TO_x + P_x;
//                         */
//                         for(int k = 0; k < TO_n; k++){
//                             for(int j = 0; j < (TO_y+2*(K_y-P_y)); j++){
//                                 for(int i = 0; i < (TO_x+2*(K_x-P_x)); i++){
//                                     unsigned ptr = 2*IND4((o_n + k), (o_y + j - 2*P_y), O_y, (o_x + i - 2*P_x), O_x, k_c, K_c); // -pypx
//                                     dma_queue_bursts(input_ptr + ptr, (DMEM_OFFSET + (unsigned) &B_in[k][j][i][0]), (TK_c), 2);
//                                     // dma_wait();
//                         }}} // End DMA get in to B_in loop

//                         if (k_c != 0){
//                             // DMA get out[o_n:TO_n][o_y:TO_y][o_x:TO_x][o_c:TO_c] to B_out
//                             for(int k = 0; k < TO_n; k++){
//                                 for(int j = 0; j < TO_y; j++){
//                                     for(int i = 0; i < TO_x; i++){
//                                         unsigned ptr = 4*IND4((o_n + k), (o_y + j), O_y, (o_x + i), O_x, o_c, O_c);
//                                         dma_queue_bursts(output_ptr + ptr, (DMEM_OFFSET + (unsigned) &B_out[k][j][i][0]), TO_c, 4);
//                                         // dma_wait();
//                             }}} // End DMA get out to B_out loop
//                         }

//                         // Wait on all buffers to be filled
//                         dma_wait();

//                         // Intra-tile loop
//                         for(int to_n = 0; to_n < TO_n; to_n++){
//                             for(int to_y = 0; to_y < TO_y; to_y++){
//                                 for(int to_x = 0; to_x < TO_x; to_x++){
//                                     unsigned k_y_start = (o_y+to_y < P_y) ? (P_y - (o_y+to_y)) : 0;
//                                     unsigned k_y_end = (o_y+to_y >= O_y - P_y) ? (K_y - P_y - 1 + O_y - (o_y+to_y)) : K_y;
//                                     for(int k_y = k_y_start; k_y < k_y_end; k_y++){
//                                         unsigned k_x_start = (o_x + to_x < P_x) ? (P_x - (o_x + to_x)) : 0;
//                                         unsigned k_x_end = (o_x+to_x >= O_x - P_x) ? (K_x - P_x - 1 + O_x - (o_x + to_x)) : K_x;
//                                         for(int k_x = k_x_start; k_x < k_x_end; k_x++){
//                                             for(int tk_c = 0; tk_c < TK_c/32; tk_c++){ // = vector
//                                                 for(int to_c = 0; to_c < TO_c; to_c++){ // =1
//                                                     // B_out[to_n][to_y][to_x][0][to_c] += B_in[to_n][to_y+k_y-P_y][to_x+k_x-P_x][tk_c] * B_w[k_y][k_x][tk_c][0][to_c];

//                                                     int32 voutput = {0};
//                                                     _TCE_MAC16X32TO32X32(B_in[to_n][to_y+k_y+1][to_x+k_x+1][tk_c], B_w[k_y][k_x][tk_c][to_c], voutput, voutput);
//                                                     int32_t sum = 0;
//                                                     _TCE_VREDUCE32X32(voutput, sum);
//                                                     B_out[to_n][to_y][to_x][to_c] += sum;
//                         }}}}}}} // End intra-tile loop
                        
//                         // DMA put B_out to out[o_n:TO_n][o_y:TO_y][o_x:TO_x][o_c:TO_c]
//                         for(int k = 0; k < TO_n; k++){
//                             for(int j = 0; j < TO_y; j++){
//                                 for(int i = 0; i < TO_x; i++){
//                                     unsigned ptr = 4*IND4((o_n + k), (o_y + j), O_y, (o_x + i), O_x, o_c, O_c);
//                                     dma_queue_bursts((DMEM_OFFSET + (unsigned) &B_out[k][j][i][0]), output_ptr + ptr, TO_c, 4);
//                                     // dma_wait();
//                         }}} // End DMA put B_out to out loop
//                         dma_wait();
//     }}}}}
// }

volatile unsigned MMAP[67];

int main(){
    //conv1
    MMAP[3] = 0x20000000; // input
    MMAP[4] = 0x21000000; // weights
    MMAP[5] = 0x22000000; // output
    // volatile unsigned* l0_input_ptr = (volatile unsigned*) 0;
    // volatile unsigned* l0_weight_ptr = (volatile unsigned*) 4;
    // volatile unsigned* l0_output_ptr = (volatile unsigned*) 8;

    // conv0(l0_output_ptr, l0_input_ptr, l0_weight_ptr);
    // conv0(MMAP[2], MMAP[0], MMAP[1]);

    // volatile unsigned* l0_act_ptr = (volatile unsigned*) 12;
    // act0(l0_act_ptr, l0_output_ptr);
    // act0(MMAP[3], MMAP[2]);
    
    // int offset = 16;
    int j = 4;
    for(int i = 1; i < 2; i++){//!
        // volatile unsigned* act0_ptr = (volatile unsigned*) (offset - 4);
        // volatile unsigned* weight_ptr = (volatile unsigned*) (offset);
        // volatile unsigned* output_ptr = (volatile unsigned*) (offset + 4);
        // volatile unsigned* threshold_ptr = (volatile unsigned*) (offset + 8);
        // volatile unsigned* act1_ptr = (volatile unsigned*) (offset + 12);

        // conv1(output_ptr, act0_ptr, weight_ptr);
        // // act1(act1_ptr, output_ptr, threshold_ptr);
        
        conv1(MMAP[j+1], MMAP[j-1], MMAP[j]);
        // act1(MMAP[j+3], MMAP[j+1], MMAP[j+2]);
    //     offset += 16;
        j += 4;
    }
    
    // Conv 15
    // conv1((volatile unsigned*) (offset + 4), (volatile unsigned*) (offset - 4), (volatile unsigned*) (offset));
    // conv1(MMAP[j+1], MMAP[j-1], MMAP[j]);
    // offset += 8;
    j += 2;

    // Relu
    // volatile unsigned* a_threshold_ptr = (volatile unsigned*) (offset);
    // volatile unsigned* b_threshold_ptr = (volatile unsigned*) (offset + 4);
    // volatile unsigned* relu_ptr = (volatile unsigned*) (offset + 8);
    // relu(relu_ptr, (volatile unsigned*) (offset - 4), a_threshold_ptr, b_threshold_ptr);

    // relu(MMAP[j+2], MMAP[j-1], MMAP[j], MMAP[j+1]);
    // offset += 12;
    j += 3;

    // // Conv 16
    // volatile unsigned* weight_ptr = (volatile unsigned*) (offset);
    // volatile unsigned* output_ptr = (volatile unsigned*) (offset + 4);
    // conv2(output_ptr, relu_ptr, weight_ptr);
    // conv2(MMAP[j+1], MMAP[j-1], MMAP[j]);

    return 0;
}