  .data

input_addr:       .word 0x80
output_addr:      .word 0x84
sign_mask:        .word 0x7FFF_FFFF

  .text

  \\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\

_start:
  @p input_addr a! @        \ read number

  count_ones

  @p output_addr a! !       \ print res

  halt

  \\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\

count_ones:
  lit 0 over               \ st: i = 0, n
  dup
  -if while
inc:
  over lit 1 + over        \ st: i = 1, n
  @p sign_mask and         \ st: i = 1, n_no_sign
while:
  dup
  lit 1 and                \ st: i, n, n % 2
  >r over r> +             \ st: n, i + n % 2
  over                     \ st: i..., n
  2/
  dup if end
  while ;

end:
  drop                     \ delete n
  ;
