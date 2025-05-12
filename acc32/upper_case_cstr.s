  .data
buffer:          .byte '________________________________'
padding:         .byte '___'
null_term:       .byte '\0___'
input_addr:      .word  0x80
output_addr:     .word  0x84
i:               .word  0
newline:         .word  '\n'
one_const:       .word  1
mask:            .word  0xFF
a_lower:         .word  'a'
z_lower:         .word  'z'
a_upper:         .word  'A'
overflow_code:   .word  0xCCCC_CCCC
;   0000 0000 0000 0000
  .text
; c >= 'a' && c <= 'z'
; c = c - 'a' + 'A'
.org 0x88

overflow_err:
  load          overflow_code
  store_ind     output_addr
  halt

_start:
read_string:
  load_imm      buffer          ; acc = buffer
  store         i               ; i = buffer
read_loop:
  load_imm      padding
  sub           i               ; i == &buffer_end ? => err
  beqz          overflow_err
  load_ind      input_addr      ; acc = *(input)
  and           mask            ; acc & 0xFF
  sub           newline         ; acc - '\n'
  beqz          read_end        ; acc == '\n' ? goto end
  add           newline         ; restore acc

  sub           a_lower         ; c -= 'a'
  ble           not_lower_a     ; c < 'a' ? => not_lower
  add           a_lower         ; restore c 
  sub           z_lower         ; c -= 'z'
  bgt           not_lower_z     ; c >'z' => not_lower
  add           z_lower
  sub           a_lower
  add           a_upper         ; c += 'A' (to uppercase)
  jmp           continue
not_lower_a:
  add           a_lower
  jmp           continue
not_lower_z:
  add           z_lower
continue:
  store_ind     i               ; buffer[i] = acc
  load          i               ; acc = i
  add           one_const       ; i++
  store         i
  jmp           read_loop       ; next iteration
read_end:
  load          null_term
  store_ind     i

print_buffer:
  load_imm      buffer          ; acc = buffer
  store         i               ; i = buffer
print_loop:
  load_ind      i               ; acc = buffer[i]
  and           mask            ; c & 0xFF (cut to byte)
  beqz          end             ; c == '\0' ? end of string
  store_ind     output_addr     ; c -> stdout
  load          i               ; acc = i
  add           one_const       ; i++
  store         i               ; save i
  jmp           print_loop      ; next iteration
end:

  halt
