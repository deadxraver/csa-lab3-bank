  .data
INPUT_ADDR:   .word 0x80
OUTPUT_ADDR:  .word 0x84
result:       .word 0
BYTE_MASK:    .word 0x00FF
temp:         .word 0
counter:      .word 0
WORD_SIZE:    .word 4
SHIFT_STEP:   .word 8

  .text

_start:
  load_imm    0             ; clear acc
  store       result        ; clear result
  store       counter       ; clear counter
  load_ind    INPUT_ADDR    ; load from stdin
  store       temp          ; save word to temp var
loop:
  load        counter       ; i
  sub         WORD_SIZE
  beqz        loop_end      ; i == WORD_SIZE ? end of loop
  load        result        ; acc = result
  shiftl      SHIFT_STEP    ; acc << SHIFT_STEP
  store       result        ; result <<= SHIFT_STEP
  load        temp
  and         BYTE_MASK     ; get last byte from word
  add         result        ; acc += result
  store       result
  load        temp
  shiftr      SHIFT_STEP    ; temp >>= SHIFT_STEP
  store       temp
  load_imm    1
  add         counter
  store       counter       ; ++i
  jmp         loop          ; next iteration
loop_end:
  load        result
  store_ind   OUTPUT_ADDR   ; print result
  halt
