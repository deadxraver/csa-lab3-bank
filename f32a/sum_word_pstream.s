  .data
input_addr:     .word 0x80
output_addr:    .word 0x84

sign_mask:      .word 0x8000_0000

lower_word:     .word 0x00
upper_word:     .word 0x00

  .text

.org 0x85

print_words:
  @p lower_word
  @p upper_word
  @p output_addr a! ! !
  ;

sum_words:
  @p input_addr a! @                    \ get number of words
  lit -1 +
  >r                                    \ push it to the rstack
loop:
  @p input_addr a! @                    \ s: current_word
  dup @p sign_mask and                  \ s: current_word, current_sign
  @p lower_word @p sign_mask and        \ s: current_word, current_sign, low_sign
  xor                                   \ s: current_word, (current_sign != low_sign)
  if maybe_overflow
no_overflow:                            \ s: current_word
  dup @p lower_word +                   \ s: current_word, lower_word + current_word | !CARRY SET!
  dup dup dup eam +                     \ s: current_word, sum, sum + sum + c
  over dup +                            \ s: current_word, sum + sum + c, sum + sum
  inv lit 1 + +                         \ s: current_word, c ; FIXME: something wrong with `-`
  @p upper_word + !p upper_word         \ s: current_word
  end_upper ;
maybe_overflow:                         \ s: current_word
  dup                                   \ s: current_word, current_word
  @p lower_word @p sign_mask and        \ s: current_word, current_word, low_sign
  >r @p lower_word +                    \ s: current_word, current_word + lower_word
  @p sign_mask and r>                   \ s: current_word, res_sign, low_sign
  xor if no_overflow                    \ s: current_word | if res_sign == low_sign -> no overflow
overflow:                               \ s: current_word
  dup @p lower_word + @p sign_mask and  \ s: current_word, res_sign
  if inc_upper                          \ if !res_sign -> ++upper_word else --upper_word
dec_upper:                              \ s: current_word
  @p upper_word lit -1 + !p upper_word  \ s: current_word
  end_upper ;
inc_upper:
  @p upper_word lit 1 + !p upper_word   \ =//=
end_upper:
  @p lower_word + !p lower_word
  next loop
  ;


_start:
  sum_words
  print_words
  halt

