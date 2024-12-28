module top(
    input clk, rst,
    input [3:0] key_in,
    output [6:0] seg,
    output [7:0] sel,
    output reg [2:0] led, sel_led,
    output buz
);

/**********按键消抖**************/
    wire [2:0] key_val;
    localparam  S1 = 3'd1,
                S2 = 3'd2,
                S3 = 3'd3,
                S4 = 3'd4;
    key u_key(
        .clk(clk),
        .rst(rst),
        .key_in(key_in),
        .key_val(key_val)
    );
/*********************************/

/***********数码管显示**************/
    reg [20:0] data_to_show;
    seg u_seg(
        .clk(clk),
        .rst(rst),
        .seg(seg),
        .sel(sel),
        .data(data_to_show)
    );
/***********************************/

    wire [20:0] data_clock, data_stopwatch, data_timer;
    wire [2:0] led_clock, led_timer;
    wire [2:0] key_val_clock, key_val_stopwatch, key_val_timer;
    reg [1:0] current_state, next_state;
    localparam  CLOCK       = 2'b00,
                STOPWATCH   = 2'b01,
                TIMER       = 2'b11;
    assign key_val_clock = (current_state == CLOCK) ? key_val : 3'd0;
    assign key_val_stopwatch = (current_state == STOPWATCH) ? key_val : 3'd0;
    assign key_val_timer = (current_state == TIMER) ? key_val : 3'd0;

    clock u_clock (
        .clk(clk),
        .rst(rst),
        .key_val(key_val_clock),
        .data(data_clock),
        .led(led_clock)
    );

    stopwatch u_stopwatch (
        .clk(clk),
        .rst(rst),
        .key_val(key_val_stopwatch),
        .data(data_stopwatch)
    );

    timer u_timer (
        .clk(clk),
        .rst(rst),
        .key_val(key_val_timer),
        .data(data_timer),
        .led(led_timer),
        .buz(buz)
    );

/***********************state machine***************************/
    always @(posedge clk or negedge rst) begin
        if (!rst) begin
            current_state <= CLOCK;
        end else begin
            current_state <= next_state;
        end
    end

    always @(*) begin
        next_state = current_state;
        case (current_state)
            CLOCK: begin
                if (key_val == S1) begin
                    next_state = STOPWATCH;
                end else begin
                    next_state = CLOCK;
                end
            end

            STOPWATCH: begin
                if (key_val == S1) begin
                    next_state = TIMER;
                end else begin
                    next_state = STOPWATCH;
                end
            end

            TIMER: begin
                if (key_val == S1) begin
                    next_state = CLOCK;
                end else begin
                    next_state = TIMER;
                end
            end

            default: begin ; end
        endcase
    end

    always @(*) begin
        led = 3'b111;
        data_to_show = 20'd0;
        sel_led = 3'b111;

        case (current_state)
            CLOCK: begin
                led = 3'b110;
                data_to_show = data_clock;
                sel_led = led_clock;
            end
            STOPWATCH: begin
                led = 3'b101;
                data_to_show = data_stopwatch;
                sel_led = 3'b111;
            end
            TIMER: begin
                led = 3'b011;
                data_to_show = data_timer;
                sel_led = led_timer;
            end
            default: begin ; end
        endcase
    end
/***************************************************************/

endmodule
