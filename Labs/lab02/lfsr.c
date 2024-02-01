#include <stdint.h>
#include <stdio.h>
#include <stdlib.h>
#include <string.h>

#include "lfsr.h"

// Return the nth bit of x.
// Assume 0 <= n <= 31
uint16_t get_bit(uint16_t x, uint16_t n) { return (x >> n) & 1; }

// Set the nth bit of the value of x to v.
// Assume 0 <= n <= 31, and v is 0 or 1
void set_bit(uint16_t *x, uint16_t n, uint16_t v) {
  *x &= ~(1 << n);
  *x |= (v << n);
}

void lfsr_calculate(uint16_t *reg) {
  uint16_t new_bit =
      get_bit(*reg, 0) ^ get_bit(*reg, 2) ^ get_bit(*reg, 3) ^ get_bit(*reg, 5);

  *reg = (*reg >> 1);
  set_bit(reg, 15, new_bit);
}
