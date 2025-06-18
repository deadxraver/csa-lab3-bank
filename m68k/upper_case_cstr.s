  .data
buffer:         .byte '________________________________'
input_addr:     .word 0x80
output_addr:    .word 0x84
stack_pointer:  .word 0x500
  .text

f_overflow_error:
  move.l        0xCCCC_CCCC, (A1)
  halt

f_read_word:
  move.l        0, D0             ; D0 = i
read_word_loop:
  cmp.l         0x20, D0          ; if reached buffer end - stop
  bge           f_overflow_error
  move.b        (A0), D1          ; D1 = c
  cmp.b         10, D1            ; if end of line - end
  beq           read_word_end
  move.b        D1, (A2,D0)       ; buffer[i] = c
  add.b         1, D0             ; ++i
  jmp           read_word_loop    ; next iteration
read_word_end:
  move.b        0, (A2,D0)        ; buffer[-1] = '\0'
  rts

f_to_upper_case:
  move.l        0, D0             ; D0 = i
to_upper_case_loop:
  move.b        (A2,D0), D1       ; D1 = buffer[i]
  cmp.b         0, D1             ; buffer[i] == 0
  beq           to_upper_case_end
  add.b         1, D0
  cmp.b         'a', D1
  blt           to_upper_case_loop
  cmp.b         'z', D1
  bgt           to_upper_case_loop
  sub.b         'a', D1
  add.b         'A', D1
  move.b        D1, -1(A2,D0)
  jmp           to_upper_case_loop
to_upper_case_end:
  rts

f_print_buffer:
  move.l        0, D0             ; D0 = i
print_buffer_loop:
  move.b        (A3,D0), D1       ; D1 = buffer[i]
  cmp.b         0, D1             ; buffer[i] == 0
  beq           print_buffer_end
  add.b         1, D0             ; ++i
  move.b        D1, (A1)          ; print buffer[i]
  jmp           print_buffer_loop
print_buffer_end:
  rts

.org 0x88

_start:
  movea.l       stack_pointer, A7
  movea.l       (A7), A7            ; A7 = stack_pointer
  movea.l       input_addr, A0
  movea.l       (A0), A0            ; A0 = input_addr
  movea.l       output_addr, A1
  movea.l       (A1), A1            ; A1 = output_addr
  movea.l       buffer, A2          ; A3 = &buffer
  jsr           f_read_word
  jsr           f_to_upper_case
  jsr           f_print_buffer
  halt
