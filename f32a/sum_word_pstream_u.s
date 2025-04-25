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
  dup @p lower_word +                   \ s: current_word, lower_word + current_word | !CARRY SET!
  dup dup dup eam +                     \ s: current_word, sum, sum + sum + c
  over dup +                            \ s: current_word, sum + sum + c, sum + sum
  inv lit 1 + +                         \ s: current_word, c
  @p upper_word + !p upper_word         \ s: current_word
  end_upper ;
end_upper:
  @p lower_word + !p lower_word
  next loop
  ;

_start:
  sum_words
  print_words
  halt

