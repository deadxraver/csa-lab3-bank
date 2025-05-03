  .data
input_addr:   .word 0x80
output_addr:  .word 0x84
upper_word:   .word 0x0
lower_word:   .word 0x0
  .text

_start:
  load_imm    0
  store       lower_word
loop:
  clc
  load_ind    input_addr
  beqz        end_loop       ; null-term ? => end
  ble         dec_upper
  add         lower_word
  store       lower_word
  bcs         inc_upper
  jmp         loop
dec_upper:
  add         lower_word
  store       lower_word
  bcs         loop
  load_imm    -1
  add         upper_word
  store       upper_word
  jmp         loop
inc_upper:
  load_imm    1
  add         upper_word
  store       upper_word
  jmp         loop
end_loop:
  load        upper_word
  store_ind   output_addr
  load        lower_word
  store_ind   output_addr
  halt
