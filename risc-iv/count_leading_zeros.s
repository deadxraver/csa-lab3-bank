  .data
input_addr:   .word 0x80
output_addr:  .word 0x84
zeros_count:  .word 0x20
  .text


count_leading_zeros:      ; t0 - number, t1 - counter, t2 - hardcoded 1 for shifts
  addi      sp, sp, -4
  sw        a0, 0(sp)
  addi      t2, zero, 1

  beqz      t0, count_leading_zeros_ret
  beqz      t1, count_leading_zeros_ret
  addi      t1, t1, -1
  sra       t0, t0, t2
  jal       a0, count_leading_zeros

count_leading_zeros_ret:
  lw        a0, 0(sp)
  addi      sp, sp, 4
  jr        a0


print_res:
  addi      sp, sp, -4
  sw        a0, 0(sp)

  lui       t0, %hi(output_addr)
  addi      t0, t0, %lo(output_addr)
  lw        t0, 0(t0)
  sw        t1, 0(t0)
  lw        a0, 0(sp)
  addi      sp, sp, 4
  jr        a0


_start:
  lui       t0, %hi(input_addr)
  addi      t0, t0, %lo(input_addr)
  lw        t0, 0(t0)

  lw        t0, 0(t0)                       ; load value from input
  addi      t1, zero, 0x20                  ; zeros counter

  jal       a0, count_leading_zeros
  jal       a0, print_res
  halt


