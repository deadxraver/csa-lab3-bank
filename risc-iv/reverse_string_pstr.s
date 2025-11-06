  .data
buffer:       .byte '________________________________'
input_addr:   .word 0x80
output_addr:  .word 0x84
overflow_val: .word 0xCCCC_CCCC
stack_base:   .word 0x500

  .text
  .org 0x88

f_overflow:
  lui   t0, %hi(overflow_val)
  addi  t0, t0, %lo(overflow_val)
  lw    t0, 0(t0)
  lui   t1, %hi(output_addr)
  addi  t1, t1, %lo(output_addr)
  lw    t1, 0(t1)
  sw    t0, 0(t1)
  halt

init:   ; stack init
  lui   sp, %hi(stack_base)
  addi  sp, sp, %lo(stack_base)
  lw    sp, 0(sp)
  jr    ra

push: ; push word to stack
  addi  sp, sp, -4
  sw    a0, 0(sp)
  jr    ra

pop:  ; pop word from stack
  lw    a0, 0(sp)
  addi  sp, sp, 4
  jr    ra

f_read_reverse:
  addi  sp, sp, -4
  sw    ra, 0(sp)   ; save ret addr
  lui   t0, %hi(input_addr)
  addi  t0, t0, %lo(input_addr) ; t0 - stdin
  lw    t0, 0(t0)
  addi  t1, zero, 0   ; t1 - counter
  ; t2 - cur_c, t3 - temporal calculations
  addi  t4, zero, 0x00FF ; t4 - byte mask
read_reverse_rloop:
  addi  t3, t1, -32           ; cmp
  beq   t3, zero, f_overflow  ; if (cnt > sz) goto f_overflow
  lw    t2, 0(t0)             ; t2 = c
  and   t2, t2, t4
  addi  t3, t2, -10           ; cmp with \n
  beq   t3, zero, read_reverse_rloop_end
  add   a0, zero, t2          ; a0 = c
  jal   ra, push              ; stack.push(c)
  addi  t1, t1, 1             ; ++cnt
  j     read_reverse_rloop    ; next iteration
read_reverse_rloop_end:
  lui   t0, %hi(buffer)
  addi  t0, t0, %lo(buffer)   ; t0 = buf_p
  sb    t1, 0(t0)             ; put strlen to first byte
  addi  t0, t0, 1             ; t0++
read_reverse_wloop:
  beq   t1, zero, read_reverse_wloop_end
  addi  t1, t1, -1            ; --cnt
  jal   ra, pop               ; a0 = stack.pop()
  sb    a0, 0(t0)
  addi  t0, t0, 1             ; ++buf_p
  j     read_reverse_wloop
read_reverse_wloop_end:
  lw    ra, 0(sp)
  addi  sp, sp, 4
  jr    ra

f_print_buffer:
  lui   t0, %hi(output_addr)
  addi  t0, t0, %lo(output_addr)
  lw    t0, 0(t0)             ; t0 - stdout
  lui   t1, %hi(buffer)
  addi  t1, t1, %lo(buffer)   ; t1 - buf_p
  lw    t2, 0(t1)             ; t2 - counter
  addi  t3, zero, 0x00FF
  and   t2, t2, t3            ; cut upper bytes
  addi  t1, t1, 1             ; skip len byte
print_buffer_loop:
  beq   t2, zero, print_buffer_ret
  addi  t2, t2, -1
  lw    t3, 0(t1)
  addi  t1, t1, 1
  sb    t3, 0(t0)
  j     print_buffer_loop
print_buffer_ret:
  jr    ra

main:
  addi  sp, sp, -4
  sw    ra, 0(sp)
  jal   ra, f_read_reverse
  jal   ra, f_print_buffer
  ; ret
  lw    ra, 0(sp)
  addi  sp, sp, 4
  jr    ra

_start:
  jal   ra, init
  jal   ra, main
  halt
