include config.inc

clock_m equ 1
stopwatch_m equ 2
timer_m equ 3

extrn display:near
extrn seg7:byte
extrn idx:byte

extrn key:near
extrn key_val:byte

extrn clock:near
extrn data_clock:byte
extrn led_clock:byte

extrn stopwatch:near
extrn data_stopwatch:byte

extrn timer:near
extrn data_timer:byte
extrn led_timer:byte
extrn buz:byte

public cycle_run
public disp_data
public key_in
public key_val_clock
public key_val_stopwatch
public key_val_timer

data segment public
    disp_data db 00h, 00h, 00h
    key_in db ?
    key_val_clock db 0
    key_val_stopwatch db 0
    key_val_timer db 0
    led db 0
    mode_led db 1
    state db clock_m
data ends

code segment public 'code'
    assume cs:code, ds:data
cycle_run proc
    call io_sample
    call app_update
    call io_commit
    ret
cycle_run endp

io_sample proc
    in al, io_8255_c
    or al, 0f0h
    mov key_in, al
    ret
io_sample endp

app_update proc
    call clock
    call stopwatch
    call timer

    mov key_val_clock, 0
    mov key_val_stopwatch, 0
    mov key_val_timer, 0
    call key
    mov al, key_val

show_data macro src_data
    lea si, src_data
    lea di, disp_data
    mov cx, 3
    cld
    rep movsb
endm

    cmp state, clock_m
    je st_clock
    cmp state, stopwatch_m
    je st_stopwatch
    jmp st_timer

st_clock:
    cmp key_val, 1
    je c2s
    mov key_val_clock, al
    show_data data_clock
    mov mode_led, 1
    mov al, led_clock
    mov led, al
    jmp finish
c2s:
    mov state, stopwatch_m
    jmp finish

st_stopwatch:
    cmp key_val, 1
    je s2t
    mov key_val_stopwatch, al
    show_data data_stopwatch
    mov mode_led, 2
    mov led, 0
    jmp finish
s2t:
    mov state, timer_m
    jmp finish

st_timer:
    cmp key_val, 1
    je t2c
    mov key_val_timer, al
    show_data data_timer
    mov mode_led, 4
    mov al, led_timer
    mov led, al
    jmp finish
t2c:
    mov state, clock_m

finish:
    call display
    ret
app_update endp

io_commit proc
    mov al, idx
    mov ah, mode_led
    mov cl, 4
    shl ah, cl
    or al, ah
    and al, 11110111b
    out io_8255_b, al
    mov ah, al
    mov al, seg7
    out io_8255_a, al
    or ah, 00001000b
    mov al, ah
    out io_8255_b, al
    mov al, led
    mov cl, 4
    shl al, cl
    mov ah, buz
    mov cl, 7
    shl ah, cl
    or al, ah
    and al, 11110000b
    out io_8255_c, al
    ret
io_commit endp

code ends
    end
