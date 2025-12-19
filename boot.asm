include config.inc

extrn isr_tick:far
extrn sys:near

stackseg segment stack
    dw 512 dup(?)
    stack_top label word
stackseg ends

data segment public
data ends

code segment public 'code'
    assume cs:code, ds:data, ss:stackseg
start:
    cli

    ; initialize data segment
    mov ax, data
    mov ds, ax

    ; initialize stack segment
    mov ax, stackseg
    mov ss, ax
    mov sp, offset stack_top

    ; initialize 8255
    mov al, 81h
    out io_8255_ctrl, al

    ; initialize 8253
    mov al, 34h ; channel 0
    out io_8253_ctrl, al
    mov ax, tick_div
    out io_8253_ch0, al
    mov al, ah
    out io_8253_ch0, al
    mov al, 76h ; channel 1
    out io_8253_ctrl, al
    mov ax, buzz_div
    out io_8253_ch1, al
    mov al, ah
    out io_8253_ch1, al

    ; set ivt
    xor ax, ax ; mov ax, 0
    mov es, ax
    mov di, int_tick * 4
    mov ax, offset isr_tick
    mov es:[di], ax
    mov ax, seg isr_tick
    mov es:[di + 2], ax

    ; initialize es
    mov ax, data
    mov es, ax

    ; initialize 8259
    mov al, 13h
    out io_8259_0, al ; icw1
    mov al, int_base
    out io_8259_1, al ; icw2
    mov al, 1
    out io_8259_1, al ; icw4
    mov al, 0feh
    out io_8259_1, al ; ocw1

    sti

    call sys

    jmp $
code ends
    end start
