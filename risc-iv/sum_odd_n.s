  .data
input_addr:   .word 0x80
output_addr:  .word 0x84
overflow_val: .word 0xCCCC_CCCC
  .text

f_incorrect_input:
  addi   a0, zero, -1
  jal    ra, f_print_n
  halt

f_overflow_error:
  lui   a0, %hi(overflow_val)
  addi  a0, a0, %lo(overflow_val)
  lw    a0, 0(a0)
  jal   ra, f_print_n
  halt

f_stack_init:
  addi  sp, zero, 0x500
  jr    ra

ret:
  lw    ra, 0(sp)
  addi  sp, sp, 4
  jr    ra

f_print_n:          ; a0 - word to print
  lui   t0, %hi(output_addr)
  addi  t0, t0, %lo(output_addr)
  lw    t0, 0(t0)
  sw    a0, 0(t0)
  jr    ra


  .data
.org 0x80
input:    .word 0x0
output:   .word 0x0

  .text

f_sum_odd_n_and_print:  ; a0 - n
  addi  sp, sp, -4
  sw    ra, 0(sp)
  addi  t1, zero, 2     ; t1 = 2; t1 - divisor
  addi  a0, a0, 1       ; increment a0 to correctly count number of odd numbers
  div   a0, a0, t1      ; S_odd_n = n_odd ^ 2
  mulh  t0, a0, a0      ; n_odd * n_odd is overflow ?
  bnez  t0, f_overflow_error
  mul   a0, a0, a0
  bgt   zero, a0, f_overflow_error
  jal   ra, f_print_n
  j     ret

_start:
  jal   ra, f_stack_init
  lui   t0, %hi(input_addr)
  addi  t0, t0, %lo(input_addr)
  lw    t0, 0(t0)
  lw    a0, 0(t0)
  ble   a0, zero, f_incorrect_input
  jal   ra, f_sum_odd_n_and_print
  halt
