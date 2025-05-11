  .data

buffer:       .byte '________________________________'
offset:       .byte '___'
adder:        .byte 0, '___'
input_addr:   .word 0x80
output_addr:  .word 0x84
error_code:   .word 0xCCCC_CCCC

  .text

.org 0x88

ret:
  lw        a0, 0(sp)
  addi      sp, sp, 4
  jr        a0

error:
  lui       t0, %hi(output_addr)
  addi      t0, t0, %lo(output_addr)
  lw        t0, 0(t0)

  lui       t1, %hi(error_code)
  addi      t1, t1, %lo(error_code)
  lw        t1, 0(t1)

  sw        t1, 0(t0)
  halt

f_read_to_buffer:   ; t0 - input, a0 - return addr, t1 - current sym, t2 - i, t3 - cmp sym, t4 - adder
  addi      sp, sp, -4
  sw        a0, 0(sp)   ; save return address to stack

  lui       t4, %hi(adder)
  addi      t4, t4, %lo(adder)
  lw        t4, 0(t4)             ; t4 = '\0___'

  lui       t2, %hi(buffer)
  addi      t2, t2, %lo(buffer)   ; t2 = i = buffer
  addi      t2, t2, 1             ; skip first byte for length
read_loop:
  addi      t3, zero, 0x21        ; i >= 33 -> error
  ble       t3, t2, error
  lw        t1, 0(t0)             ; read sym
  addi      t3, zero, 10          ; t3 = '\n'
  beq       t3, t1, end_read      ; t1 == '\n' ? => end
  addi      t3, zero, 'z'         ; t3 = 'z'
  bgt       t1, t3, continue_read ; if t1 > 'z'
  addi      t3, zero, 'a'
  bgt       t3, t1, continue_read ; if 'a' > t1
  sub       t1, t1, t3
  addi      t1, t1, 'A'
continue_read:
  add       t1, t1, t4
  sw        t1, 0(t2)
  addi      t2, t2, 1
  j         read_loop
end_read: ; load mem[buffer:buffer+4]; and 0xFFFF_FF00; plus with the length and place back
  addi      t1, t2, -1
;  add       t1, zero, t2
  lui       t2, %hi(buffer)
  addi      t2, t2, %lo(buffer)
  lw        t4, 0(t2)         ; t4 = *buffer
  add       t1, t1, t4
  addi      t1, t1, -95
  sw        t1, 0(t2)
  j         ret


f_print_buffer:   ; t0 - output, a0 - return addr, t1 - current sym, t2 - i, t3 - mask, t4 - length
  addi      sp, sp, -4
  sw        a0, 0(sp)   ; save return address to stack

  addi      t3, zero, 0xFF

  lui       t2, %hi(buffer)
  addi      t2, t2, %lo(buffer)

  lw        t4, 0(t2)
  and       t4, t4, t3
  addi      t4, t4, 1         ; because first char is length
  addi      t2, t2, 1
print_loop:
  beq       t2, t4, end_print
  lw        t1, 0(t2)
  and       t1, t1, t3
  sb        t1, 0(t0)
  addi      t2, t2, 1
  j         print_loop
end_print:
  j         ret


_start:
  lui       t0, %hi(input_addr)
  addi      t0, t0, %lo(input_addr)
  lw        t0, 0(t0)                 ; t0 = input_addr

  jal       a0, f_read_to_buffer

  lui       t0, %hi(output_addr)
  addi      t0, t0, %lo(output_addr)
  lw        t0, 0(t0)                 ; t0 = output_addr

  jal       a0, f_print_buffer
  halt
