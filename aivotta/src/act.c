#include "conv_act.h"
#include "tceops.h"
#include "tce_vector.h"
#include <stdint.h>
#include "settings.h"
#include "dma.h"

void act0(unsigned output_ptr, unsigned input_ptr){
    const int K_c = 64; // Input/Output maps
    // Tiling settings
    const int TO_n = 1; // Tile Batch size
    const int TO_y = 1; // Tile Output map height
    const int TO_x = 16; // Tile Output map width
    const int TK_c = 64; // Tile Input/Output maps (multiple of 32)
    
    // Buffers
    volatile int32 B_in[TO_n][TO_y][TO_x][TK_c/32];
    int32 thresholds_v = {0};

    // Inter-tile loop
    for(int o_n = 0; o_n < O_n; o_n += TO_n){
        for(int o_y = 0; o_y < O_y; o_y += TO_y){
            for(int o_x = 0; o_x < O_x; o_x += TO_x){
                for(int k_c = 0; k_c < K_c; k_c += TK_c){
                    volatile int32_t B_out[TO_n][TO_y][TO_x][TK_c/32] = {0};

                    // DMA get in[o_n:TO_n][o_y:TO_y][O_x:TO_x][k_c:TK_c] to B_in
                    for(int k = 0; k < TO_n; k++){
                        for(int j = 0; j < TO_y; j++){
                            // for(int i = 0; i < TO_x; i++){
                                unsigned ptr = 4*IND4((o_n + k), (o_y + j), O_y, o_x, O_x, k_c, K_c);
                                dma_queue_bursts(input_ptr + ptr, (DMEM_OFFSET + (unsigned) &B_in[k][j][0][0]), (TO_x*TK_c), 4);
                                // dma_wait();
                    }}//} // End DMA get in to B_in loop

                    dma_wait();

                    // Intra-tile loop
                    for(int to_n = 0; to_n < TO_n; to_n++){
                        for(int to_y = 0; to_y < TO_y; to_y++){
                            for(int to_x = 0; to_x < TO_x; to_x++){
                                for(int tk_c = 0; tk_c < TK_c/32; tk_c++){
                                    _TCE_GE32X32TO32X1(B_in[to_n][to_y][to_x][tk_c], thresholds_v, B_out[to_n][to_y][to_x][tk_c]);
                    }}}} // End intra-tile loop

                    // DMA put B_out to out[o_n:TO_n][o_y:TO_y][o_x:TO_x][k_c:TK_c]
                    for(int k = 0; k < TO_n; k++){
                        for(int j = 0; j < TO_y; j++){
                            // for(int i = 0; i < TO_x; i++){
                                unsigned ptr = 4*IND4((o_n + k), (o_y + j), O_y, (o_x), O_x, k_c, K_c/32);
                                dma_queue_bursts((DMEM_OFFSET + (unsigned) &B_out[k][j][0][0]), output_ptr + ptr, (TO_x*TK_c/32), 4); 
                                // dma_wait();
                    }}//} // End DMA put B_out to out loop
                    dma_wait();
    }}}} // End inter-tile loop
}

void act1(unsigned output_ptr, unsigned input_ptr, unsigned threshold_ptr){
    const int K_c = 64; // Input/Output maps
    // Tiling settings
    const int TO_n = 1; // Tile Batch size
    const int TO_y = 1; // Tile Output map height
    const int TO_x = 4; // Tile Output map width
    const int TK_c = 64; // Tile Input/Output maps (multiple of 32)
    
    // Buffers
    ushort32 B_in[TO_n][TO_y][TO_x][TK_c/32];
    ushort32 B_thresholds[TK_c/32];
    ushort32 B_thresholds3[TK_c/32];
    ushort32 B_thresholds5[TK_c/32];// static _pmem 
    uint32_t B_out[TO_n][TO_y][TO_x][TK_c/32];
    // DMA get thresholds
    dma_queue_bursts(threshold_ptr, (DMEM_OFFSET + (unsigned) &B_thresholds[0]), (TK_c), 2);
    dma_queue_bursts(threshold_ptr + 2*64, (DMEM_OFFSET + (unsigned) &B_thresholds3[0]), (TK_c), 2);
    dma_queue_bursts(threshold_ptr + 4*64, (DMEM_OFFSET + (unsigned) &B_thresholds5[0]), (TK_c), 2);
    dma_wait();

    // Inter-tile loop
    for(int o_n = 0; o_n < O_n; o_n += TO_n){
        for(int o_y = 0; o_y < O_y; o_y += TO_y){
            for(int o_x = 0; o_x < O_x; o_x += TO_x){
                for(int k_c = 0; k_c < K_c; k_c += TK_c){
                    // DMA get in[o_n:TO_n][o_y:TO_y][O_x:TO_x][k_c:TK_c] to B_in
                    for(int k = 0; k < TO_n; k++){
                        for(int j = 0; j < TO_y; j++){
                            // for(int i = 0; i < TO_x; i++){
                                unsigned ptr = 2*IND4((o_n + k), (o_y + j), O_y, o_x, O_x, 0, K_c);
                                dma_queue_bursts(input_ptr + ptr, (DMEM_OFFSET + (unsigned) &B_in[k][j][0][0]), (TO_x*TK_c), 2);
                                // dma_wait();
                    }}//} // End DMA get in to B_in loop

                    dma_wait();

                    if (o_y == 0 || o_x == 0 || o_y == O_y-TO_y || o_x == O_x-TO_x){
                        // Intra-tile loop
                        for(int to_n = 0; to_n < TO_n; to_n++){
                            for(int to_y = 0; to_y < TO_y; to_y++){
                                for(int to_x = 0; to_x < TO_x; to_x++){
                                    for(int tk_c = 0; tk_c < TK_c/32; tk_c++){
                                        ushort32 input_v = B_in[to_n][to_y][to_x][tk_c] << 1;
                                        if (((o_y + to_y) == 0 && (o_x + to_x) == 0) || ((o_y + to_y) == O_y-1 && (o_x + to_x) == 0) || 
                                            ((o_y + to_y) == 0 && (o_x + to_x) == O_x-1) || ((o_y + to_y) == O_y-1 && (o_x + to_x) == O_x-1)){
                                            _TCE_GEU16X32TO32X1(input_v, B_thresholds5[k_c+tk_c], B_out[to_n][to_y][to_x][tk_c]);
                                        } else if ((o_x + to_x) == 0 || (o_x + to_x) == O_x-1 || (o_y + to_y) == 0 || (o_y + to_y) == O_y-1){
                                            _TCE_GEU16X32TO32X1(input_v, B_thresholds3[k_c+tk_c], B_out[to_n][to_y][to_x][tk_c]);
                                        } else {
                                            _TCE_GEU16X32TO32X1(input_v, B_thresholds[k_c+tk_c], B_out[to_n][to_y][to_x][tk_c]);
                                        }
                                        
                        }}}} // End intra-tile loop
                    } else {
                        // Intra-tile loop
                        for(int to_n = 0; to_n < TO_n; to_n++){
                            for(int to_y = 0; to_y < TO_y; to_y++){
                                for(int to_x = 0; to_x < TO_x; to_x++){
                                     for(int tk_c = 0; tk_c < TK_c/32; tk_c++){
                                        _TCE_GEU16X32TO32X1(B_in[to_n][to_y][to_x][tk_c] << 1, B_thresholds[k_c+tk_c], B_out[to_n][to_y][to_x][tk_c]);
                        }}}} // End intra-tile loop
                    }

                    // DMA put B_out to out[o_n:TO_n][o_y:TO_y][o_x:TO_x][k_c:TK_c]
                    for(int k = 0; k < TO_n; k++){
                        for(int j = 0; j < TO_y; j++){
                            // for(int i = 0; i < TO_x; i++){
                                unsigned ptr = 4*IND4((o_n + k), (o_y + j), O_y, (o_x), O_x, k_c, K_c/32);
                                dma_queue_bursts((DMEM_OFFSET + (unsigned) &B_out[k][j][0][0]), output_ptr + ptr, (TO_x*TK_c/32), 4); 
                                // dma_wait();
                    }}//} // End DMA put B_out to out loop
                    // dma_wait();
    }}}} // End inter-tile loop
    dma_wait();
}

void relu(unsigned output_ptr, unsigned input_ptr, unsigned a_threshold_ptr, unsigned b_threshold_ptr){
    const int K_c = 64; // Input/Output maps
    // Tiling settings
    const int TO_n = 1; // Tile Batch size
    const int TO_y = 1; // Tile Output map height
    const int TO_x = 10; // Tile Output map width
    const int TK_c = 32; // Tile Input/Output maps (multiple of 32)
    
    // Buffers
    ushort32 B_in[TO_n][TO_y][TO_x][TK_c/32];
    short32 B_out[TO_n][TO_y][TO_x][TK_c/32];
    short32 B_a_thresholds[TK_c/32];
    int32 B_b_thresholds[TK_c/32];

    short32 zeros = {0};

    // Inter-tile loop
    for(int o_n = 0; o_n < O_n; o_n += TO_n){
        for(int o_y = 0; o_y < O_y; o_y += TO_y){ //!
            for(int o_x = 0; o_x < O_x; o_x += TO_x){ //!
                for(int k_c = 0; k_c < K_c; k_c += TK_c){ //!
                    // DMA get thresholds
                    dma_queue_bursts(a_threshold_ptr + 2*k_c, (DMEM_OFFSET + (unsigned) &B_a_thresholds[0]), (TK_c), 2);
                    dma_queue_bursts(b_threshold_ptr + 4*k_c, (DMEM_OFFSET + (unsigned) &B_b_thresholds[0]), (TK_c), 4);
                    // dma_wait();

                    // DMA get in[o_n:TO_n][o_y:TO_y][O_x:TO_x][k_c:TK_c] to B_in
                    for(int k = 0; k < TO_n; k++){
                        for(int j = 0; j < TO_y; j++){
                            for(int i = 0; i < TO_x; i++){
                                unsigned ptr = 2*IND4((o_n + k), (o_y + j), O_y, o_x, (O_x + i), k_c, K_c); // !
                                dma_queue_bursts(input_ptr + ptr, (DMEM_OFFSET + (unsigned) &B_in[k][j][0][0]), (TK_c), 2); //!
                                // dma_wait();
                    }}} // End DMA get in to B_in loop

                    dma_wait();

                    // // Intra-tile loop
                    // for(int to_n = 0; to_n < TO_n; to_n++){
                    //     for(int to_y = 0; to_y < TO_y; to_y++){
                    //         for(int to_x = 0; to_x < TO_x; to_x++){
                    //             int16_t T = -9*64;
                    //             if ((o_x + to_x) == 0 || (o_x + to_x) == O_x-1){
                    //                 T += 3*64;
                    //             }
                    //             if ((o_y + to_y) == 0 || (o_y + to_y) == O_y-1){
                    //                 T += 3*64;
                    //             }
                    //             if (((o_y + to_y) == 0 && (o_x + to_x) == 0) || ((o_y + to_y) == O_y-1 && (o_x + to_x) == 0) || 
                    //                 ((o_y + to_y) == 0 && (o_x + to_x) == O_x-1) || ((o_y + to_y) == O_y-1 && (o_x + to_x) == O_x-1)){
                    //                 T -= 1*64;
                    //             }
                    //             short32 vT;
                    //             _TCE_VBCAST16X32(T, vT);

                    //             for(int tk_c = 0; tk_c < TK_c/32; tk_c++){
                    //                 // short32 vA = B_a_thresholds[tk_c];
                    //                 // int32 vB = B_b_thresholds[tk_c];

                    //                 int32 y = {0};
                    //                 // y0 = vA*vT + vB
                    //                 _TCE_MAC16X32TO32X32(B_a_thresholds[tk_c], vT, B_b_thresholds[tk_c], y);
                    //                 // y = 2*vA*X + y0                                  
                    //                 _TCE_MAC16X32TO32X32(B_a_thresholds[tk_c]<<1, B_in[to_n][to_y][to_x][tk_c], y, y); // B_in signed vs unsigned problem?
                    //                 short32 z;
                    //                 _TCE_TRUNCWH32X32(y, z);
                    //                 // MAX(z,0)
                    //                 _TCE_MAX16X32(z, zeros, B_out[to_n][to_y][to_x][tk_c]);
                    // }}}} // End intra-tile loop
                    #if ZPAD
                    if (o_y == 0 || o_x == 0 || o_y == O_y-TO_y || o_x == O_x-TO_x){
                        // Intra-tile loop
                        for(int to_n = 0; to_n < TO_n; to_n++){
                            for(int to_y = 0; to_y < TO_y; to_y++){
                                for(int to_x = 0; to_x < TO_x; to_x++){
                                    int16_t T = -9*64;
                                    if ((o_x + to_x) == 0 || (o_x + to_x) == O_x-1){
                                        T += 3*64;
                                    }
                                    if ((o_y + to_y) == 0 || (o_y + to_y) == O_y-1){
                                        T += 3*64;
                                    }
                                    if (((o_y + to_y) == 0 && (o_x + to_x) == 0) || ((o_y + to_y) == O_y-1 && (o_x + to_x) == 0) || 
                                        ((o_y + to_y) == 0 && (o_x + to_x) == O_x-1) || ((o_y + to_y) == O_y-1 && (o_x + to_x) == O_x-1)){
                                        T -= 1*64;
                                    }
                                    short32 vT;
                                    _TCE_VBCAST16X32(T, vT);

                                    for(int tk_c = 0; tk_c < TK_c/32; tk_c++){
                                        // short32 vA = B_a_thresholds[tk_c];
                                        // int32 vB = B_b_thresholds[tk_c];

                                        int32 y = {0};
                                        // y0 = vA*vT + vB
                                        _TCE_MAC16X32TO32X32(B_a_thresholds[tk_c], vT, B_b_thresholds[tk_c], y);
                                        // y = 2*vA*X + y0                                  
                                        _TCE_MAC16X32TO32X32(B_a_thresholds[tk_c]<<1, B_in[to_n][to_y][to_x][tk_c], y, y); // B_in signed vs unsigned problem?
                                        short32 z;
                                        _TCE_TRUNCWH32X32(y, z);
                                        // MAX(z,0)
                                        _TCE_MAX16X32(z, zeros, B_out[to_n][to_y][to_x][tk_c]);
                        }}}} // End intra-tile loop
                    } else {
                    #endif
                        // Intra-tile loop
                        for(int to_n = 0; to_n < TO_n; to_n++){
                            for(int to_y = 0; to_y < TO_y; to_y++){
                                for(int to_x = 0; to_x < TO_x; to_x++){
                                    short32 vT;
                                    _TCE_VBCAST16X32(-9*64, vT);

                                    for(int tk_c = 0; tk_c < TK_c/32; tk_c++){
                                        // short32 vA = B_a_thresholds[tk_c];
                                        // int32 vB = B_b_thresholds[tk_c];

                                        int32 y = {0};
                                        // y0 = vA*vT + vB
                                        _TCE_MAC16X32TO32X32(B_a_thresholds[tk_c], vT, B_b_thresholds[tk_c], y);
                                        // y = 2*vA*X + y0                                  
                                        _TCE_MAC16X32TO32X32(B_a_thresholds[tk_c]<<1, B_in[to_n][to_y][to_x][tk_c], y, y); // B_in signed vs unsigned problem?
                                        short32 z;
                                        _TCE_TRUNCWH32X32(y, z);
                                        // MAX(z,0)
                                        _TCE_MAX16X32(z, zeros, B_out[to_n][to_y][to_x][tk_c]);
                        }}}} // End intra-tile loop
                    #if ZPAD
                    }
                    #endif

                    // DMA put B_out to out[o_n:TO_n][o_y:TO_y][o_x:TO_x][k_c:TK_c]
                    for(int k = 0; k < TO_n; k++){
                        for(int j = 0; j < TO_y; j++){
                            for(int i = 0; i < TO_x; i++){
                                unsigned ptr = 2*IND4((o_n + k), (o_y + j), O_y, (o_x + i), O_x, k_c, K_c); //!
                                dma_queue_bursts((DMEM_OFFSET + (unsigned) &B_out[k][j][i][0]), output_ptr + ptr, (TK_c), 2);
                                // dma_wait();
                    }}} // End DMA put B_out to out loop
    }}}} // End inter-tile loop
    dma_wait();
}