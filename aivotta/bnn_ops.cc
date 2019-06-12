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
OPERATION(XNORPOPCNTACC)
TRIGGER
    uint32_t x = UINT(1);
    uint32_t w = UINT(2);
    uint32_t prev_sum = UINT(3);

    IO(4) = prev_sum + __builtin_popcount(~(x ^ w));
    return true;
END_TRIGGER;
END_OPERATION(XNORPOPCNTACC)

/* SET_BIT */
OPERATION(SET_BIT)
TRIGGER
    uint32_t position = UINT(1);
    uint32_t bit_string = UINT(2);

    IO(3) = bit_string | (1 << (31 - position));
    return true;
END_TRIGGER;
END_OPERATION(SET_BIT)

