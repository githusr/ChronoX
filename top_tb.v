`timescale 10ns / 10ns

module top_tb;

    reg clk;
    reg rst;
    reg [3:0] key_in;

    wire [6:0] seg;
    wire [7:0] sel;
    wire [2:0] led;
    wire [2:0] sel_led;
    wire buz;

    top uut (
        .clk(clk),
        .rst(rst),
        .key_in(key_in),
        .seg(seg),
        .sel(sel),
        .led(led),
        .sel_led(sel_led),
        .buz(buz)
    );

    initial begin
        clk = 1'b0;
        rst = 1'b1;
        key_in = 4'b1111;
        #1 rst = 1'b0;
        #1 rst = 1'b1; #500000;
        key_in = 4'b1101; #500000; // 5ms
        key_in = 4'b1111; #1000000; // 10ms
        key_in = 4'b1101; #2000000; // 20ms
        key_in = 4'b1111; #2000000; // 20ms
    end

    always begin
        #1 clk = ~clk;
    end

endmodule
