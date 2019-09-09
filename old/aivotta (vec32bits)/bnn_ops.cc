/**
 * OSAL behavior definition file.
 */

#include "OSAL.hh"
#include <stdint.h>

/* POPCOUNT */
OPERATION(POPCOUNT)
TRIGGER
    uint32_t x = UINT(1);
    IO(2) = __builtin_popcount(x);
    return true;
END_TRIGGER;
END_OPERATION(POPCOUNT)

/* POPCOUNT ACCUMULATOR */
OPERATION(POPCOUNTACC)
TRIGGER
    uint32_t x = UINT(1);
    uint32_t prev_sum = UINT(2);

    IO(3) = prev_sum + __builtin_popcount(x);
    return true;
END_TRIGGER;
END_OPERATION(POPCOUNTACC)

/* XNOR POPCOUNT ACCUMULATOR */
OPERATION(XNORPOPCOUNTACC)
TRIGGER
    uint32_t x = UINT(1);
    uint32_t w = UINT(2);
    uint32_t prev_sum = UINT(3);

    IO(4) = prev_sum + __builtin_popcount(~(x ^ w));
    return true;
END_TRIGGER;
END_OPERATION(XNORPOPCOUNTACC)

/* SET_BIT */
OPERATION(SET_BIT)
TRIGGER
    uint32_t position = UINT(1);
    uint32_t bit_string = UINT(2);

    IO(3) = bit_string | (1 << (31 - position));
    return true;
END_TRIGGER;
END_OPERATION(SET_BIT)

/* GT32X32TO32 */
OPERATION(GT32X32TO32)
TRIGGER
    uint32_t bit_string = 0;
    
    for (int i = 0; i < 32; i++){
        bool val = 2*SUBWORD32(1,i) >= SUBWORD32(2,i) ? 1 : 0;
        bit_string |= (val << (31 - i));
    }

    IO(3) = bit_string;
    return true;
END_TRIGGER;
END_OPERATION(GT32X32TO32)
