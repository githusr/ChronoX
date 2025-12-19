idle equ 0
running equ 1
paused equ 2

cnt_max equ (10 - 1)

extrn key_val_stopwatch:byte

public stopwatch
public data_stopwatch

data segment public
    cnt db 0
    state db idle
    data_stopwatch db 3 dup(0)
data ends

key_val equ key_val_stopwatch

code segment public 'code'
    assume cs:code, ds:data

stopwatch proc
    mov al, state
    cmp al, idle
    je st_idle
    cmp al, running
    je st_running
    jmp st_paused

st_idle:
    cmp key_val, 2
    je i2r
    mov al, 0
    lea di, data_stopwatch
    mov cx, 3
    rep stosb
    mov cnt, al
    jmp finish
i2r:
    mov state, running
    jmp finish

st_running:
    cmp key_val, 2
    je r2p
    cmp cnt, cnt_max
    jne inc_cnt
    mov cnt, 0
    ; increment time
    mov si, offset data_stopwatch
    mov al, [si]
    cmp al, 99h
    jne no_carry
    mov byte ptr [si], 0
    inc si
    mov al, [si]
    cmp al, 59h
    jne no_carry
    mov byte ptr [si], 0
    inc si
    mov al, [si]
    cmp al, 99h
    jne no_carry
    mov byte ptr [si - 1], 59h
    mov byte ptr [si - 2], 99h
    jmp r2p
no_carry:
    add al, 1
    daa
    mov [si], al
    jmp finish
inc_cnt:
    inc cnt
    jmp finish
r2p:
    mov state, paused
    jmp finish

st_paused:
    cmp key_val, 2
    je p2r
    cmp key_val, 3
    je p2i
    jmp finish
p2r:
    mov state, running
    jmp finish
p2i:
    mov state, idle
    jmp finish

finish:
    ret
stopwatch endp

code ends
    end
