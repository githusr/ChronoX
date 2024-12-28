module timer (
    input clk, rst,
    input [2:0] key_val,
    output reg [20:0] data,
    output reg [2:0] led,
    output buz
);
    localparam  S1 = 3'd1,
                S2 = 3'd2,
                S3 = 3'd3,
                S4 = 3'd4;

/**********指示灯闪烁**************/
    reg en_blink;
    wire led_blink;
    blink u_blink(
        .clk(clk),
        .rst(rst),
        .en(en_blink),
        .led(led_blink)
    );
/*********************************/

/**********蜂鸣器发声**************/
    reg en_buz;
    reg [25:0] cnt_buz;
    reg [2:0] cnt_repeat;
    localparam REPEATS_MAX = 3'd5;
    buzz u_buzz(
        .clk(clk),
        .rst(rst),
        .en(en_buz),
        .buz(buz)
    );
/*********************************/

    localparam  SETTING = 2'b00,
                RUNNING = 2'b01,
                PAUSED = 2'b11,
                TIMEUP = 2'b10;

    reg [1:0] current_state, next_state;

    always @(posedge clk or negedge rst) begin
        if (!rst) begin
            current_state <= SETTING;
        end else begin
            current_state <= next_state;
        end
    end

    always @(*) begin
        next_state = current_state;
        case (current_state)
            SETTING: begin
                if (key_val == S4) begin
                    next_state = RUNNING;
                end else begin
                    next_state = SETTING;
                end
            end

            RUNNING: begin
                if (data == 21'd0) begin
                    next_state = TIMEUP;
                end else begin
                    if (key_val == S4) begin
                        next_state = PAUSED;
                    end else if (key_val == S3) begin
                        next_state = SETTING;
                    end else begin
                        next_state = RUNNING;
                    end
                end
            end

            PAUSED: begin
                if (key_val == S4) begin
                    next_state = RUNNING;
                end else if (key_val == S3) begin
                    next_state = SETTING;
                end else begin
                    next_state = PAUSED;
                end
            end

            TIMEUP: begin
                if (key_val == S4) begin
                    next_state = SETTING;
                end else begin
                    next_state = TIMEUP;
                end
            end

            default: begin ; end
        endcase
    end

    reg [20:0] data_tmp;
    reg [25:0] cnt;
    localparam CNT_MAX = 26'd49_999_999; // 1s
    reg [1:0] choice;
    localparam  SEC     = 2'b00,
                MIN     = 2'b01,
                HOUR    = 2'b11;

    always @(posedge clk or negedge rst) begin
        if (!rst) begin
            data <= 21'd0;
            cnt <= 26'd0;
            data_tmp <= 21'd0;
        end else begin
            case (current_state)
                SETTING: begin
                    cnt <= 26'd0;
                    data <= data_tmp;
                    if (key_val == S3) begin
                        case (choice)
                            SEC: begin
                                data[5:0] <= (data[5:0] == 6'd59) ? 6'd0 : (data[5:0] + 1'b1);
                                data_tmp[5:0] <= (data[5:0] == 6'd59) ? 6'd0 : (data[5:0] + 1'b1);
                            end
                            MIN: begin
                                data[12:7] <= (data[12:7] == 6'd59) ? 6'd0 : (data[12:7] + 1'b1);
                                data_tmp[12:7] <= (data[12:7] == 6'd59) ? 6'd0 : (data[12:7] + 1'b1);
                            end
                            HOUR: begin
                                data[18:14] <= (data[18:14] == 5'd23) ? 5'd0 : (data[18:14] + 1'b1);
                                data_tmp[18:14] <= (data[18:14] == 5'd23) ? 5'd0 : (data[18:14] + 1'b1);
                            end
                            default: begin ; end
                        endcase
                    end
                end

                RUNNING: begin
                    if (cnt == CNT_MAX) begin
                        cnt <= 26'd0;
                        if (data[5:0] == 6'd0) begin
                            data[5:0] <= 6'd59;
                            if (data[12:7] == 6'd0) begin
                                data[12:7] <= 6'd59;
                                data[18:14] <= data[18:14] - 1'b1;
                            end else begin
                                data[12:7] <= data[12:7] - 1'b1;
                            end
                        end else begin
                            data[5:0] <= data[5:0] - 1'b1;
                        end
                    end else begin
                        cnt <= cnt + 1'b1;
                    end
                end

                PAUSED: begin
                end

                TIMEUP: begin
                end

                default: begin ; end
            endcase
        end
    end

    always @(posedge clk or negedge rst) begin
        if (!rst) begin
            choice <= SEC;
        end else begin
            case (current_state)
                SETTING: begin
                    if (key_val == S2) begin
                        case (choice)
                            SEC: begin choice <= MIN; end
                            MIN: begin choice <= HOUR; end
                            HOUR: begin choice <= SEC; end
                            default: begin ; end
                        endcase
                    end
                end

                RUNNING: begin
                    choice <= SEC;
                end

                PAUSED: begin
                end

                TIMEUP: begin
                end

                default: begin ; end
            endcase
        end
    end

    always @(*) begin
        led = 3'b111;
        en_blink = 1'b0;
        case (current_state)
            SETTING: begin
                case (choice)
                    SEC: begin led = 3'b110; end
                    MIN: begin led = 3'b101; end
                    HOUR: begin led = 3'b011; end
                    default: begin ; end
                endcase
            end

            RUNNING: begin
                led = 3'b111;
            end

            PAUSED: begin
            end

            TIMEUP: begin
                en_blink = 1'b1;
                led = {2'b11, led_blink};
            end

            default: begin ; end
        endcase
    end

    always @(posedge clk or negedge rst) begin
        if (!rst) begin
            en_buz <= 1'b0;
            cnt_buz <= 26'd0;
            cnt_repeat <= 3'd0;
        end else begin
            case (current_state)
                SETTING: begin
                    en_buz <= 1'b0;
                    cnt_buz <= 26'd0;
                    cnt_repeat <= 3'd0;
                end

                RUNNING: begin
                end

                PAUSED: begin
                end

                TIMEUP: begin
                    if (cnt_repeat < REPEATS_MAX) begin
                        if (cnt_buz <= (CNT_MAX >> 1'b1)) begin
                            en_buz <= 1'b1;
                            cnt_buz <= cnt_buz + 1'b1;
                        end else if (cnt_buz < CNT_MAX) begin
                            en_buz <= 1'b0;
                            cnt_buz <= cnt_buz + 1'b1;
                        end else begin
                            cnt_buz <= 26'd0;
                            cnt_repeat <= cnt_repeat + 1'b1;
                        end
                    end else begin
                        en_buz <= 1'b0;
                    end
                end

                default: begin ; end
            endcase
        end
    end

endmodule
