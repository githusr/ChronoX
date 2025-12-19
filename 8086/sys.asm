extrn tick_cnt:word
extrn cycle_run:near

public sys

data segment public
data ends

code segment public 'code'
    assume cs:code, ds:data
sys proc

fetch:
    xor ax, ax
    xchg ax, tick_cnt
    cmp ax, 0
    je idle

run:
    push ax
    call cycle_run
    pop ax
    dec ax
    jnz run
    jmp fetch

idle:
    sti
    hlt
    jmp fetch

sys endp
code ends
    end
