setting equ 0
running equ 1
paused equ 2
timeup equ 3

cnt_max equ (1000 - 1)
repeat_max equ 5

extrn key_val_timer:byte

public timer
public data_timer
public led_timer
public buz

data segment public
    cnt dw 0
    cnt_blink dw 0
    state db setting
    data_timer db 3 dup(0)
    data_tmp db 3 dup(0)
    led_blink db 0
    led_timer db 1
    buz db 0
    cnt_buz dw 0
    cnt_repeat db 0
data ends

key_val equ key_val_timer
led equ led_timer

code segment public 'code'
    assume cs:code, ds:data
timer proc
    call blink_proc
    mov al, state
    cmp al, setting
    je st_setting
    cmp al, running
    je st_running
    cmp al, paused
    je st_paused
    jmp st_timeup
st_setting:
    mov cnt, 0
    lea si, data_tmp
    lea di, data_timer
    mov cx, 3
    rep movsb
    cmp key_val, 4
    je s2r
    cmp key_val, 2
    je choose
    cmp key_val, 3
    jne finish
    ; increment setting digit
    mov si, offset data_timer
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
    jmp save
min:
    inc si
    mov al, [si]
    cmp al, 59h
    je zero
    add al, 1
    daa
    mov [si], al
    jmp save
hour:
    inc si
    inc si
    mov al, [si]
    cmp al, 23h
    je zero
    add al, 1
    daa
    mov [si], al
    jmp save
zero:
    mov al, 0
    mov [si], al
    jmp save
save:
    lea si, data_timer
    lea di, data_tmp
    mov cx, 3
    rep movsb
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
    jmp finish

st_running:
    mov led, 0
    cmp key_val, 4
    je r2p
    cmp key_val, 3
    je r2s
    cmp cnt, cnt_max
    jne inc_cnt
    mov cnt, 0
    ; decrement time
    mov si, offset data_timer
    mov al, [si]
    cmp al, 0
    jne no_borrow
    mov byte ptr [si], 59h
    inc si
    mov al, [si]
    cmp al, 0
    jne no_borrow
    mov byte ptr [si], 59h
    inc si
    mov al, [si]
    cmp al, 0
    jne no_borrow
    mov byte ptr [si - 1], 0
    mov byte ptr [si - 2], 0
    jmp r2t
no_borrow:
    sub al, 1
    das
    mov [si], al
    jmp finish
inc_cnt:
    inc cnt
    jmp finish
r2p:
    mov state, paused
    jmp finish
r2s:
    mov state, setting
    mov led, 1
    jmp finish
r2t:
    mov state, timeup
    jmp finish

st_paused:
    cmp key_val, 4
    je p2r
    cmp key_val, 3
    je p2s
    jmp finish
p2r:
    mov state, running
    jmp finish
p2s:
    mov state, setting
    jmp finish

st_timeup:
    mov al, led_blink
    and al, 1
    mov led, al
    cmp key_val, 4
    je t2s
    cmp cnt_repeat, repeat_max
    jnb stop
    cmp cnt_buz, cnt_max shr 1
    jnbe mute
    mov buz, 1
    inc cnt_buz
    jmp finish
mute:
    cmp cnt_buz, cnt_max
    jnb one_cycle
    mov buz, 0
    inc cnt_buz
    jmp finish
one_cycle:
    mov cnt_buz, 0
    inc cnt_repeat
    jmp finish
stop:
    mov buz, 0
    jmp finish
t2s:
    mov state, setting
    mov led, 1
    mov buz, 0
    mov cnt_buz, 0
    mov cnt_repeat, 0
    jmp finish

finish:
    ret
timer endp

blink_proc proc
    cmp cnt_blink, cnt_max shr 1
    jne inc_cnt_blink
    mov cnt_blink, 0
    not led_blink
    ret
inc_cnt_blink:
    inc cnt_blink
    ret
blink_proc endp

code ends
    end
