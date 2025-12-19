ifndef _config_inc_
_config_inc_ equ 1

clk_hz equ 1000000
tick_hz equ 1000
buzz_hz equ 1250

tick_div equ (clk_hz / tick_hz)
buzz_div equ (clk_hz / buzz_hz)

int_base equ 20h
int_tick equ (int_base + 0h)

io0 equ 00h
io1 equ 10h
io2 equ 20h

io_8255_base equ io0
io_8255_a equ (io_8255_base + 0h * 2)
io_8255_b equ (io_8255_base + 1h * 2)
io_8255_c equ (io_8255_base + 2h * 2)
io_8255_ctrl equ (io_8255_base + 3h * 2)

io_8253_base equ io1
io_8253_ch0 equ (io_8253_base + 0h * 2)
io_8253_ch1 equ (io_8253_base + 1h * 2)
io_8253_ch2 equ (io_8253_base + 2h * 2)
io_8253_ctrl equ (io_8253_base + 3h * 2)

io_8259_base equ io2
io_8259_0 equ (io_8259_base + 0h * 2)
io_8259_1 equ (io_8259_base + 1h * 2)

endif
