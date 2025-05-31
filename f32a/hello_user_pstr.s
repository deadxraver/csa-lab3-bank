  .data
ready_buffer:   .byte 0, 'Hello, '
buffer:         .byte '_______________________'
buffer_end:     .byte '_____'
endline:        .word '\n'
question:       .byte 19, 'What is your name?\n'
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
  inv lit 1 + +
  ;

read_name:
  lit buffer a!         \; a = &buffer
  @p input_addr b!      \; b = stdin
read_name_loop:
  a lit buffer_end sub  \; ptr - &buffer_end
  -if overflow_error
  @b dup @p endline xor \; cmp c with endline
  if read_name_end
  @ lit 0xffff_ff00 and +
  !+
  read_name_loop ;
read_name_end:
  drop
  a lit buffer xor if overflow_error
  @ lit 0xffff_ff00 and lit '!' + !
  a
  lit ready_buffer a!
  @ + !
  ;

print_from_a:
  @p output_addr b!
  @+ @p byte_mask and
print_loop:
  dup if print_end
  lit -1 +
  @+ @p byte_mask and   \; push sym
  dup if print_end
  !b
  print_loop ;
print_end:
  drop
  ;

_start:
  lit question a!
  print_from_a
  read_name
  lit ready_buffer a!
  print_from_a
  halt
