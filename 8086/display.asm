dash equ 40h

extrn disp_data:byte

public display
public seg7
public idx

data segment public
    seg7 db 0
    idx db 7
    table db 3fh, 06h, 5bh, 4fh, 66h,
             6dh, 7dh, 07h, 7fh, 6fh
    format db 5, 6, 0, 3, 4, 0, 1, 2
data ends

code segment public 'code'
    assume cs:code, ds:data

display proc
    inc idx
    and idx, 7
    lea bx, format
    mov al, idx
    xlat
    cmp al, 0
    je zero
    mov ah, al
    dec al
    shr al, 1
    lea bx, disp_data
    xlat
    test ah, 1
    jz l
    jmp h
zero:
    mov seg7, dash
    jmp finish
l:
    and al, 0fh
    jmp lookup
h:
    mov cl, 4
    shr al, cl
lookup:
    lea bx, table
    xlat
    mov seg7, al
finish:
    ret
display endp

code ends
    end
