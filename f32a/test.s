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
  @p input_addr a! @
адский_пиздец:
  @ + dup dup dup eam + over dup dup >r + \ sum + sum + c sum + sum     z2
лютый_пиздец:
  inv lit 1 + +
  @p upper_word + !p upper_word
снимай_эту_шлюху:
  r>
  !p lower_word
  ;


_start:
  sum_words
  print_words
  halt

