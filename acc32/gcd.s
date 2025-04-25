  .data

input_addr:   .word 0x80
output_addr:  .word 0x84
a:            .word 0x0
b:            .word 0x0
temp:         .word 0x0
error_value:  .word 0xCCCC_CCCC

  .text
_start:
  load_ind    input_addr
  ble         error
  beqz        error       ; if a <= 0 -> error
  store       a
  load_ind    input_addr
  ble         error
  beqz        error       ; if b <= 0 -> error
  store       b
while:  ; a, b = b, a % b, while b != 0
  load        b           ; acc = b
  beqz        output      ; b == 0 ? -> end
  store       temp
  load        a
  rem         b           ; acc = a % b 
  store       b
  load        temp
  store       a
  jmp         while
output:
  load        a
  store_ind   output_addr
  jmp         end
error:
  load        error_value
  store_ind   output_addr
end:
  halt
