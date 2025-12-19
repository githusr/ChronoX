running equ 0
setting equ 1

cnt_max equ 1000 - 1

extrn key_val_clock:byte

public clock
public data_clock
public led_clock

data segment public
    cnt dw 0
    state db running
    data_clock db 3 dup(0)
    led_clock db 0
data ends

key_val equ key_val_clock
led equ led_clock

code segment public 'code'
    assume cs:code, ds:data

clock proc
    mov al, state
    cmp al, running
    je st_running
    jmp st_setting

st_running:
    mov led, 0
    cmp key_val, 2
    je r2s
    cmp cnt, cnt_max
    jne inc_cnt
    mov cnt, 0
    ; increment time
    mov si, offset data_clock
    mov al, [si]
    cmp al, 59h
    jne no_carry
    mov byte ptr [si], 0
    inc si
    mov al, [si]
    cmp al, 59h
    jne no_carry
    mov byte ptr [si], 0
    inc si
    mov al, [si]
    cmp al, 23h
    jne no_carry
    mov byte ptr [si], 0
    jmp finish
no_carry:
    add al, 1
    daa
    mov [si], al
    jmp finish
inc_cnt:
    inc cnt
    jmp finish
r2s:
    mov state, setting
    mov led, 1
    jmp finish

st_setting:
    cmp key_val, 4
    je s2r
    cmp key_val, 2
    je choose
    cmp key_val, 3
    jne finish
    ; increment setting digit
    mov si, offset data_clock
    test led, 1
    jnz sec
    test led, 2
    jnz min
    jmp hour
sec:
    mov al, [si]
    cmp al, 59h
    je zero
    add al, 1
    daa
    mov [si], al
    jmp finish
min:
    inc si
    mov al, [si]
    cmp al, 59h
    je zero
    add al, 1
    daa
    mov [si], al
    jmp finish
hour:
    inc si
    inc si
    mov al, [si]
    cmp al, 23h
    je zero
    add al, 1
    daa
    mov [si], al
    jmp finish
zero:
    mov al, 0
    mov [si], al
    jmp finish
choose:
    cmp led, 4
    je choose_sec
    shl led, 1
    jmp finish
choose_sec:
    mov led, 1
    jmp finish
s2r:
    mov state, running

finish:
    ret
clock endp

code ends
    end
