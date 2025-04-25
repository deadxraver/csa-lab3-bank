  .data

buffer:       .byte '________________________________'
offset:       .byte '___'
null_term:    .byte 0, '___'
input_addr:   .word 0x80
output_addr:  .word 0x84
error_code:   .word 0xCCCC_CCCC

  .text
.org 0x85
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

read_to_buffer:   ; t0 - input, a0 - return addr, t1 - current sym, t2 - i, t3 - cmp sym
  addi      sp, sp, -4
  sw        a0, 0(sp)   ; save return address to stack

  lui       t2, %hi(buffer)
  addi      t2, t2, %lo(buffer)   ; t2 = i = buffer
read_loop:
  addi      t3, zero, 0x20
  ble       t3, t2, error
  lw        t1, 0(t0)
  addi      t3, zero, 10
  beq       t3, t1, end_read
  addi      t3, zero, 'z'         ; t3 = 'z'
  bgt       t1, t3, continue_read ; if t1 > 'z'
  addi      t3, zero, 'a'
  bgt       t3, t1, continue_read ; if 'a' > t1
  sub       t1, t1, t3
  addi      t1, t1, 'A'
continue_read:
  sb        t1, 0(t2)
  addi      t2, t2, 1
  j         read_loop
end_read:
  lui       t1, %hi(null_term)
  addi      t1, t1, %lo(null_term)
  lw        t1, 0(t1)
  sw        t1, 0(t2)
  j         ret


print_buffer:   ; t0 - output, a0 - return addr, t1 - current sym, t2 - i, t3 - mask
  addi      sp, sp, -4
  sw        a0, 0(sp)   ; save return address to stack

  addi      t3, zero, 0xFF

  lui       t2, %hi(buffer)
  addi      t2, t2, %lo(buffer)
print_loop:
  lw        t1, 0(t2)
  and       t1, t1, t3
  beqz      t1, end_print
  sb        t1, 0(t0)
  addi      t2, t2, 1
  j         print_loop
end_print:
  j         ret


_start:
  lui       t0, %hi(input_addr)
  addi      t0, t0, %lo(input_addr)
  lw        t0, 0(t0)                 ; t0 = input_addr

  jal       a0, read_to_buffer

  lui       t0, %hi(output_addr)
  addi      t0, t0, %lo(output_addr)
  lw        t0, 0(t0)                 ; t0 = output_addr

  jal       a0, print_buffer
  halt
