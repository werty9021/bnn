#include "conv_act.h"
#include "tceops.h"
#include "tce_vector.h"
#include <stdint.h>
#include "settings.h"
#include "dma.h"

void conv0(unsigned output_ptr, unsigned input_ptr, unsigned weight_ptr){
    // Per layer
    const int K_c = 1; // Input maps
    const int O_c = 64; // Output channels
    // Tiling settings
    const int TO_c = 32; // Tile Output channels
    const int TO_y = 6; // Tile Output map height
    const int TO_x = 8; // Tile Output map width
    const int TK_c = 1; // Tile Input maps
    const int TO_n = 1; // Tile Batch size
    // Buffers
    int16_t B_in[TO_n][TO_y+2*(K_y-P_y)][TO_x+2*(K_x-P_y)][TK_c];
    short32 B_w[K_y][K_x][TK_c][TO_c/32];

    for(int o_c = 0; o_c < O_c; o_c += TO_c){
        for(int k_c = 0; k_c < K_c; k_c += TK_c){
            // DMA get w[0:K_y][0:K_x][k_c:TK_c][o_c:TO_c] to B_w
            for(int k = 0; k < K_y; k++){
                for(int j = 0; j < K_x; j++){
                    for(int i = 0; i < TK_c; i++){
                        unsigned ptr = 2*IND4(k, j, K_x, (k_c + i), K_c, o_c, O_c);
                        dma_queue_bursts(weight_ptr + ptr, (DMEM_OFFSET + (unsigned) &B_w[k][j][i][0]), TO_c, 2);
                        dma_wait();
            }}} // End DMA get w to B_w loop
            //dma_wait();

            for(int o_n = 0; o_n < O_n; o_n += TO_n){
                for(int o_y = 0; o_y < O_y; o_y += TO_y){
                    for(int o_x = 0; o_x < O_x; o_x += TO_x){
                        // Output Buffer
                        int32 B_out[TO_n][TO_y][TO_x][TO_c/32] = {0}; // NEED TO SET TO ZERO EXPLICITLY, MISSING ld8/st8 FOR MEMSET!

                        // DMA get in[o_n: TO_n][i_y: TI_y][i_x: TI_x][k_c:TK_c] to B_in
                        /* // To only load what's necessary:
                        unsigned y_end = (O_y-o_y) != TO_y ? (TO_y+K_y) : TO_y;
                        unsigned x_end = (O_x-o_x) != TO_x ? (TO_x+K_x) : TO_x;
                        */
                        for(int k = 0; k < TO_n; k++){
                            for(int j = 0; j < (TO_y+2*(K_y-P_y)); j++){
                                //for(int i = 0; i < (TO_x+K_x-P_x); i++){
                                    unsigned ptr = 2*IND4((o_n + k), (o_y + j - 2*P_y), O_y, (o_x + 0 - 2*P_x), O_x, k_c, K_c); // -px
                                    dma_queue_bursts(input_ptr + ptr, (DMEM_OFFSET + (unsigned) &B_in[k][j][0][0]), (TO_x+2*(K_x-P_x))*TK_c, 2);
                                    dma_wait();
                        }}//} // End DMA get in to B_in loop

                        // if (k_c != 0){
                        //     // DMA get out[o_n:TO_n][o_y:TO_y][o_x:TO_x][o_c:TO_c] to B_out
                        //     for(int k = 0; k < TO_n; k++){
                        //         for(int j = 0; j < TO_y; j++){
                        //             for(int i = 0; i < TO_x; i++){
                        //                 unsigned ptr = 4*IND4((o_n + k), (o_y + j), O_y, (o_x + i), O_x, o_c, O_c);
                        //                 dma_queue_bursts(output_ptr + ptr, (DMEM_OFFSET + (unsigned) &B_out[k][j][i][0]), TO_c, 4);
                        //                 dma_wait();
                        //     }}} // End DMA get out to B_out loop
                        //     // dma_wait();
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
                                                short32 v_input;
                                                _TCE_VBCAST16X32(B_in[to_n][to_y+k_y+1][to_x+k_x+1][tk_c], v_input); // -1
                                                for(int to_c = 0; to_c < TO_c/32; to_c++){
                                                    // B_out[to_n][to_y][to_x][to_c] += B_in[to_n][to_y+k_y-P_y][to_x+k_x-P_x][tk_c] * B_w[k_y][k_x][tk_c][to_c];
                                                    _TCE_MAC16X32TO32X32(v_input, B_w[k_y][k_x][tk_c][to_c], B_out[to_n][to_y][to_x][to_c], B_out[to_n][to_y][to_x][to_c]);
                        }}}}}}} // End intra-tile loop
                        
                        // DMA put B_out to out[o_n:TO_n][o_y:TO_y][o_x:TO_x][o_c:TO_c]
                        for(int k = 0; k < TO_n; k++){
                            for(int j = 0; j < TO_y; j++){
                                for(int i = 0; i < TO_x; i++){
                                    unsigned ptr = 4*IND4((o_n + k), (o_y + j), O_y, (o_x + i), O_x, o_c, O_c);
                                    dma_queue_bursts((DMEM_OFFSET + (unsigned) &B_out[k][j][i][0]), output_ptr + ptr, TO_c, 4); 
                                    dma_wait();
                        }}} // End DMA put B_out to out loop
                        dma_wait();
    }}}}}
}

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
    #if FPGA
    uint32 B_w[K_y][K_x][TK_c][TO_c/32]; //static _pmem 
    #else
    uint32 B_w[K_y][K_x][TK_c][TO_c/32];
    #endif

    for(int o_c = 0; o_c < O_c; o_c += TO_c){
        for(int k_c = 0; k_c < K_c; k_c += TK_c){
            // DMA get w[0:K_y][0:K_x][k_c:TK_c][o_c:TO_c] to B_w
            for(int k = 0; k < K_y; k++){
                for(int j = 0; j < K_x; j++){
                    for(int i = 0; i < TK_c; i++){
                        unsigned ptr = IND4(k, j, K_x, (k_c + i), K_c, o_c, O_c);
                        dma_queue_bursts(weight_ptr + 4*ptr, (PMEM_OFFSET + (unsigned) &B_w[k][j][i][0]), TO_c, 4);
                        // dma_wait();
                    }
                }
            } // End DMA get w to B_w loop
            //dma_wait();

            for(int o_n = 0; o_n < O_n; o_n += TO_n){
                for(int o_y = 0; o_y < O_y; o_y += TO_y){
                    for(int o_x = 0; o_x < O_x; o_x += TO_x){
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

                        // Output Buffer
                        // NEED TO SET TO ZERO EXPLICITLY & DMA B_out to out should be finished!
                        ushort32 B_out[TO_n][TO_y][TO_x][TO_c/32] = {0}; 
                        // Quicker to zero:
                        ushort32 zeros;
                        _TCE_VBCAST16X32(0, zeros);
                        for(int k = 0; k < TO_n; k++){
                            for(int l = 0; l < TO_y; l++){
                                for(int j = 0; j < TO_x; j++){
                                    for(int i = 0; i < TO_c/32; i++){
                                    B_out[k][l][j][i] = zeros;
                        }}}}
                        #if ZPAD
                        if (o_y == 0 || o_x == 0 || o_y == O_y-TO_y || o_x == O_x-TO_x){
                            // Intra-tile loop
                            for(int to_n = 0; to_n < TO_n; to_n++){
                                for(int to_c = 0; to_c < TO_c/32; to_c++){
                                    for(int tk_c = 0; tk_c < TK_c; tk_c++){
                                        for(int to_y = 0; to_y < TO_y; to_y++){
                                            for(int to_x = 0; to_x < TO_x; to_x++){
                                                unsigned k_y_start = (o_y+to_y < P_y) ? (P_y - (o_y+to_y)) : 0;
                                                unsigned k_y_end = (o_y+to_y >= O_y - P_y) ? (K_y - P_y - 1 + O_y - (o_y+to_y)) : K_y;
                                                for(int k_y = k_y_start; k_y < k_y_end; k_y++){
                                                    unsigned k_x_start = (o_x + to_x < P_x) ? (P_x - (o_x + to_x)) : 0;
                                                    unsigned k_x_end = (o_x+to_x >= O_x - P_x) ? (K_x - P_x - 1 + O_x - (o_x + to_x)) : K_x;
                                                    for(int k_x = k_x_start; k_x < k_x_end; k_x++){                                                    
                                                        // B_out[to_n][to_y][to_x][to_c] += B_in[to_n][to_y+k_y-P_y][to_x+k_x-P_x][tk_c] * B_w[k_y][k_x][tk_c][to_c];
                                                        _TCE_XNORPOPCOUNTACC32X32(B_in[to_n][to_y+k_y][to_x+k_x][tk_c], B_w[k_y][k_x][tk_c][to_c], B_out[to_n][to_y][to_x][to_c], B_out[to_n][to_y][to_x][to_c]);
                            }}}}}}} // End intra-tile loop
                        } else {
                        #endif
                            // Intra-tile loop
                            for(int to_n = 0; to_n < TO_n; to_n++){ //1
                                for(int to_c = 0; to_c < TO_c/32; to_c++){ //1
                                    for(int tk_c = 0; tk_c < TK_c; tk_c++){ // 2
                                        for(int to_y = 0; to_y < TO_y; to_y++){ //4
                                            for(int to_x = 0; to_x < TO_x; to_x++){ //4        
                                                    for(int k_y = 0; k_y < K_y; k_y++){ //3
                                                        for(int k_x = 0; k_x < K_x; k_x++){//3
                                                        // B_out[to_n][to_y][to_x][to_c] += B_in[to_n][to_y+k_y-P_y][to_x+k_x-P_x][tk_c] * B_w[k_y][k_x][tk_c][to_c];
                                                        _TCE_XNORPOPCOUNTACC32X32(B_in[to_n][to_y+k_y][to_x+k_x][tk_c], B_w[k_y][k_x][tk_c][to_c], B_out[to_n][to_y][to_x][to_c], B_out[to_n][to_y][to_x][to_c]);
                                    }}}}}
                            }} // End intra-tile loop
                        #if ZPAD
                        }
                        #endif
                        // DMA put B_out to out[o_n:TO_n][o_y:TO_y][o_x:TO_x][o_c:TO_c]
                        for(int k = 0; k < TO_n; k++){
                            for(int j = 0; j < TO_y; j++){
                                for(int i = 0; i < TO_x; i++){
                                    unsigned ptr = 2*IND4((o_n + k), (o_y + j), O_y, (o_x + i), O_x, o_c, O_c);
                                    dma_queue_bursts((DMEM_OFFSET + (unsigned) &B_out[k][j][i][0]), output_ptr + ptr, TO_c, 2);
                                    // dma_wait();
                        }}} // End DMA put B_out to out loop
                        // dma_wait();
    }}}}}
}

void conv2(unsigned output_ptr, unsigned input_ptr, unsigned weight_ptr){
    // Per layer
    const int K_c = 64; // Input maps
    const int O_c = 1; // Output channels
    // Tiling settings
    const int TO_c = 1; // Tile Output channels
    const int TO_y = 1; // Tile Output map height
    const int TO_x = 4; // Tile Output map width
    const int TK_c = 32; // Tile Input maps
    const int TO_n = 1; // Tile Batch size
    // Buffers
    short32 B_in[TO_n][TO_y+2*(K_y-P_y)][TO_x+2*(K_x-P_x)][TK_c/32];
    short32 B_w[K_y][K_x][TK_c/32][TO_c]; // moet die /32 hier wel?

    // dma_queue_bursts(input_ptr, (DMEM_OFFSET + (unsigned) &B_in[0][0][0][0]), (TK_c), 2);

    for(int o_c = 0; o_c < O_c; o_c += TO_c){
        for(int k_c = 0; k_c < K_c; k_c += TK_c){
            // DMA get w[0:K_y][0:K_x][k_c:TK_c][o_c:TO_c] to B_w
            for(int k = 0; k < K_y; k++){
                for(int j = 0; j < K_x; j++){
                    // for(int i = 0; i < TK_c; i++){
                        unsigned ptr = 2*IND4(k, j, K_x, (k_c + 0), K_c, o_c, O_c);
                        dma_queue_bursts(weight_ptr + ptr, (DMEM_OFFSET + (unsigned) &B_w[k][j][0][0]), (TK_c*TO_c), 2);
                        // dma_wait();
            }}//} // End DMA get w to B_w loop
            //dma_wait();

            for(int o_n = 0; o_n < O_n; o_n += TO_n){
                for(int o_y = 0; o_y < O_y; o_y += TO_y){
                    for(int o_x = 0; o_x < O_x; o_x += TO_x){
                        // DMA get in[o_n: TO_n][i_y: TI_y][i_x: TI_x][k_c:TK_c] to B_in
                        /* // To only load what's necesarry:
                        unsigned y_start = (o_y < P_y) ? (P_y - o_y) : 0;
                        unsigned y_end = (O_y-o_y) != TO_y ? TO_y+K_y-P_y : TO_y + P_y;
                        unsigned x_start = (o_x < P_x) ? (P_x - o_x) : 0;
                        unsigned x_end = (O_x-o_x) != TO_x ? TO_x+K_x-P_x : TO_x + P_x;
                        */
                        for(int k = 0; k < TO_n; k++){
                            for(int j = 0; j < (TO_y+2*(K_y-P_y)); j++){
                                for(int i = 0; i < (TO_x+2*(K_x-P_x)); i++){
                                    unsigned ptr = 2*IND4((o_n + k), (o_y + j - 2*P_y), O_y, (o_x + i - 2*P_x), O_x, k_c, K_c); // -pypx
                                    dma_queue_bursts(input_ptr + ptr, (DMEM_OFFSET + (unsigned) &B_in[k][j][i][0]), (TK_c), 2);
                                    // dma_wait();
                        }}} // End DMA get in to B_in loop

                        // DMA get out[o_n:TO_n][o_y:TO_y][o_x:TO_x][o_c:TO_c] to B_out
                        // Output Buffer
                        int32_t B_out[TO_n][TO_y][TO_x][TO_c];
                        for(int k = 0; k < TO_n; k++){
                            for(int j = 0; j < TO_y; j++){
                                for(int i = 0; i < TO_x; i++){
                                    unsigned ptr = 4*IND4((o_n + k), (o_y + j), O_y, (o_x + i), O_x, o_c, O_c);
                                    dma_queue_bursts(output_ptr + ptr, (DMEM_OFFSET + (unsigned) &B_out[k][j][i][0]), TO_c, 4);
                                    // dma_wait();
                        }}} // End DMA get out to B_out loop

                        // Wait on all buffers to be filled
                        dma_wait();


                        #if ZPAD
                        if (o_y == 0 || o_x == 0 || o_y == O_y-TO_y || o_x == O_x-TO_x){
                            // Intra-tile loop
                            for(int to_n = 0; to_n < TO_n; to_n++){
                                for(int to_c = 0; to_c < TO_c; to_c++){ // =1
                                    for(int to_y = 0; to_y < TO_y; to_y++){
                                        for(int to_x = 0; to_x < TO_x; to_x++){
                                            unsigned k_y_start = (o_y+to_y < P_y) ? (P_y - (o_y+to_y)) : 0;
                                            unsigned k_y_end = (o_y+to_y >= O_y - P_y) ? (K_y - P_y - 1 + O_y - (o_y+to_y)) : K_y;
                                            for(int k_y = k_y_start; k_y < k_y_end; k_y++){
                                                unsigned k_x_start = (o_x + to_x < P_x) ? (P_x - (o_x + to_x)) : 0;
                                                unsigned k_x_end = (o_x+to_x >= O_x - P_x) ? (K_x - P_x - 1 + O_x - (o_x + to_x)) : K_x;
                                                for(int k_x = k_x_start; k_x < k_x_end; k_x++){
                                                    for(int tk_c = 0; tk_c < TK_c/32; tk_c++){ // = vector
                                                    
                                                        // B_out[to_n][to_y][to_x][0][to_c] += B_in[to_n][to_y+k_y-P_y][to_x+k_x-P_x][tk_c] * B_w[k_y][k_x][tk_c][0][to_c];

                                                        int32 voutput = {0};
                                                        _TCE_MAC16X32TO32X32(B_in[to_n][to_y+k_y+1][to_x+k_x+1][tk_c], B_w[k_y][k_x][tk_c][to_c], voutput, voutput);
                                                        int32_t sum = 0;
                                                        _TCE_VREDUCE32X32(voutput, sum);
                                                        B_out[to_n][to_y][to_x][to_c] += sum;
                            }}}}}}} // End intra-tile loop
                        } else {
                        #endif
                            // Intra-tile loop
                            for(int to_n = 0; to_n < TO_n; to_n++){
                                for(int to_c = 0; to_c < TO_c; to_c++){ // =1
                                    for(int tk_c = 0; tk_c < TK_c/32; tk_c++){ // = vector
                                        for(int to_y = 0; to_y < TO_y; to_y++){
                                            for(int to_x = 0; to_x < TO_x; to_x++){
                                                for(int k_y = 0; k_y < K_y; k_y++){
                                                    for(int k_x = 0; k_x < K_x; k_x++){
                                                        // B_out[to_n][to_y][to_x][0][to_c] += B_in[to_n][to_y+k_y-P_y][to_x+k_x-P_x][tk_c] * B_w[k_y][k_x][tk_c][0][to_c];
                                                        int32 voutput = {0};
                                                        _TCE_MAC16X32TO32X32(B_in[to_n][to_y+k_y+1][to_x+k_x+1][tk_c], B_w[k_y][k_x][tk_c][to_c], voutput, voutput);
                                                        int32_t sum = 0;
                                                        _TCE_VREDUCE32X32(voutput, sum);
                                                        B_out[to_n][to_y][to_x][to_c] += sum;
                            }}}}}}} // End intra-tile loop
                        #if ZPAD
                        }
                        #endif
                        
                        // DMA put B_out to out[o_n:TO_n][o_y:TO_y][o_x:TO_x][o_c:TO_c]
                        for(int k = 0; k < TO_n; k++){
                            for(int j = 0; j < TO_y; j++){
                                for(int i = 0; i < TO_x; i++){
                                    unsigned ptr = 4*IND4((o_n + k), (o_y + j), O_y, (o_x + i), O_x, o_c, O_c);
                                    dma_queue_bursts((DMEM_OFFSET + (unsigned) &B_out[k][j][i][0]), output_ptr + ptr, TO_c, 4);
                                    // dma_wait();
                        }}} // End DMA put B_out to out loop         
    }}}}}
    dma_wait();
}