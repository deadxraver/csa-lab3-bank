  .data
ready_buffer:   .byte 'Hello, '
buffer:         .byte '_______________________'
buffer_end:     .byte '_____'
endline:        .word '\n'
question:       .byte 'What is your name?\n\0'
byte_mask:      .word 0x0000_00FF
input_addr:     .word 0x80
output_addr:    .word 0x84

  .text

.org 0x88

overflow_error:
  @p output_addr a!
  lit 0xCCCC_CCCC !
  halt

sub:
  inv lit 1 + +           \; -(stack.pop()) + stack.pop()
  ;

read_name:
  lit buffer a!           \; a = &buffer
  @p input_addr b!        \; b = stdin
read_name_loop:
  a lit buffer_end sub    \; ptr - &buffer_end
  -if overflow_error
  @b dup @p endline xor   \; cmp c with endline
  if read_name_end
  @ lit 0xffff_ff00 and + \; get upper 3 bytes of a word
  !+
  read_name_loop ;        \; next iteration
read_name_end:
  drop                    \; drop endline
  a lit buffer xor if overflow_error  \; check if input is not empty
  @ lit 0xffff_ff00 and ! \; get upper bytes
  lit buffer a!
put_exclamation_loop:
  @+ @p byte_mask and
  dup if put_exclamation_end
  put_exclamation_loop ;
put_exclamation_end:
  drop
  a lit -1 + a!
  lit '!' @ + !+
  @ lit 0xffff_ff00 and !
  ;

print_from_a:
  @p output_addr b!
print_buffer_loop:
  @+ @p byte_mask and   \; push sym
  dup if print_buffer_end
  !b
  print_buffer_loop ;
print_buffer_end:
  drop
  ;

_start:
  lit question a!
  print_from_a
  read_name
  lit ready_buffer a!
  print_from_a
  halt
