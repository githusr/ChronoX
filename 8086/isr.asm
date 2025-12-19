include config.inc

public isr_tick
public tick_cnt

data segment public
    tick_cnt dw 0
data ends

code segment public 'code'
    assume cs:code, ds:data
isr_tick proc far
    push ax
    inc tick_cnt
    ; eoi
    mov al, 20h
    out io_8259_0, al ; ocw2
    pop ax
    iret
isr_tick endp
code ends
    end
