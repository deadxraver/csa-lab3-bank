  .data
input_addr:     .word 0x80
output_addr:    .word 0x84

  .text
.org 0x85

check_limits:
  dup if error
  dup -if first_ok
  error ;
first_ok:
  over dup if error
  dup -if no_error
error:
  lit 0xCCCC_CCCC
  @p output_addr a! !
  halt
no_error:
  ;


_start:
  @p input_addr a! @ @    \ a:b

  check_limits

  gcd
  drop

  @p output_addr a! !
  halt

abs:
  dup -if abs_ret
  inv lit 1 +
  ;
abs_ret:
  ;

min:
  dup >r
  over dup >r
  sub -if leave_top
  r> drop r>
  ;
leave_top:
  r> r> drop
  ;

sub:
  inv lit 1 + +
  ;

gcd:
  dup if gcd_ret                              \ check a
  over dup if gcd_ret                         \ check b
check_first:
  dup lit 1 and if shift_first_check_second  \ if a&1 is not zero, check b considering there might be no shifts
  over dup lit 1 and if shift_second
  no_shifts ;
shift_first_check_second:
  2/ over dup lit 1 and if shift_second_and_res
  gcd ;
shift_second_and_res:
  2/ gcd
  2* over 2*
  gcd ;
shift_second:
  2/
  gcd ;
no_shifts:
  dup >r over dup >r
  \ min
  sub abs
  r> r>
  \ sub abs
  min
  gcd ;
gcd_ret:
  ;
