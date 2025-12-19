cnt_max equ (10 - 1)

extrn key_in:byte

public key
public key_val

data segment public
    cnt db 0
    key_val db 0
data ends

code segment public 'code'
    assume cs:code, ds:data

key proc
    call set_cnt
    call set_val
    ret
key endp

set_cnt proc
    cmp key_in, 0ffh
    je no_key
    cmp cnt, cnt_max
    je cnt_finish
    inc cnt
    jmp cnt_finish
no_key:
    mov cnt, 0
cnt_finish:
    ret
set_cnt endp

set_val proc
    cmp cnt, cnt_max - 1
    jne no_key
    test key_in, 1
    jnz two
    mov key_val, 1
    jmp val_finish
two:
    test key_in, 2
    jnz three
    mov key_val, 2
    jmp val_finish
three:
    test key_in, 4
    jnz four
    mov key_val, 3
    jmp val_finish
four:
    test key_in, 8
    jnz val_finish
    mov key_val, 4
    jmp val_finish
no_key:
    mov key_val, 0
val_finish:
    ret
set_val endp

code ends
    end
