  .data
input_addr:   .word 0x80
output_addr:  .word 0x84
  .text


count_leading_zeros:      ; a0 - number, a1 - counter, t2 - hardcoded 1 for shifts
  addi      sp, sp, -4
  sw        ra, 0(sp)
  addi      t2, zero, 1

  beqz      a0, count_leading_zeros_ret
  beqz      a1, count_leading_zeros_ret
  addi      a1, a1, -1
  sra       a0, a0, t2
  jal       ra, count_leading_zeros

count_leading_zeros_ret:
  lw        ra, 0(sp)
  addi      sp, sp, 4
  jr        ra


print_res:
  lui       t0, %hi(output_addr)
  addi      t0, t0, %lo(output_addr)
  lw        t0, 0(t0)
  sw        a0, 0(t0)
  jr        ra


_start:
  addi      sp, zero, 0x120
  lui       t0, %hi(input_addr)
  addi      t0, t0, %lo(input_addr)
  lw        t0, 0(t0)

  lw        a0, 0(t0)                       ; load value from input
  addi      a1, zero, 0x20                  ; zeros counter

  jal       ra, count_leading_zeros
  mv        a0, a1
  jal       ra, print_res
  halt


