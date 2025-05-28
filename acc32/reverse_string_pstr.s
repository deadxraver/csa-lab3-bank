    .data
buffer:             .byte '\0_______________________________', '___'
str_end:            .byte '\0___'
buffer_size:        .word 0x20
current_size:       .word 0
word_size:          .word 4
input_addr:         .word 0x80
output_addr:        .word 0x84
byte_mask:          .word 0x00FF
stack_pointer:      .word 0x500
buffer_ptr:         .word 0
one_const:          .word 1
newline:            .word '\n'
overflow_val:       .word 0xCCCC_CCCC

    .text
    .org 0x88
overflow_err:
    load            overflow_val
    store_ind       output_addr
    halt

_start:
read_loop:
    load            current_size        ; acc = current_size
    sub             buffer_size         ; current_size - buffer_size
    beqz            overflow_err        ; if (current_size - buffer_size == 0) goto err
    load            stack_pointer
    sub             word_size
    store           stack_pointer       ; stack_pointer -= 4
    load_ind        input_addr          ; acc << stdin
    sub             newline
    beqz            read_end            ; c == '\n' ? goto end
    add             newline
    store_ind       stack_pointer       ; stack.push(c)
    load            current_size
    add             one_const
    store           current_size        ; ++current_size
    jmp             read_loop           ; next iteration
read_end:
    load            current_size        ; buffer[0] = current_size
    store           buffer
    load_imm        buffer
    add             one_const
    store           buffer_ptr          ; skip length byte
to_buffer_loop:
    load            current_size
    beqz            to_buffer_end       ; current_size == 0 ? goto end
    sub             one_const
    store           current_size        ; --current_size
    load            stack_pointer
    add             word_size
    store           stack_pointer
    load_ind        stack_pointer       ; acc = stack.top()
    store_ind       buffer_ptr          ; buffer[i] = c
    store_ind       output_addr         ; print(c)
    load            buffer_ptr
    add             one_const
    store           buffer_ptr          ; ++buffer_ptr
    jmp             to_buffer_loop      ; next iteration
to_buffer_end:
    load            buffer_ptr
    sub             one_const
    store           buffer_ptr
    load_ind        buffer_ptr
    add             str_end
    store_ind       buffer_ptr
    halt

