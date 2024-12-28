module clock (
    input clk, rst,
    input [2:0] key_val,
    output reg [20:0] data,
    output reg [2:0] led
);
    localparam  S1 = 3'd1,
                S2 = 3'd2,
                S3 = 3'd3,
                S4 = 3'd4;

    localparam  RUNNING = 1'b0,
                SETTING = 1'b1;

    reg current_state, next_state;

    always @(posedge clk or negedge rst) begin
        if (!rst) begin
            current_state <= RUNNING;
        end else begin
            current_state <= next_state;
        end
    end

    always @(*) begin
        next_state = current_state;
        case (current_state)
            RUNNING: begin
                if (key_val == S2) begin
                    next_state = SETTING;
                end else begin
                    next_state = RUNNING;
                end
            end

            SETTING: begin
                if (key_val == S4) begin
                    next_state = RUNNING;
                end else begin
                    next_state = SETTING;
                end
            end

            default: begin ; end
        endcase
    end

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
        end else begin
            case (current_state)
                RUNNING: begin
                    if (cnt == CNT_MAX) begin
                        cnt <= 26'd0;
                        if (data[5:0] == 6'd59) begin
                            data[5:0] <= 6'd0;
                            if (data[12:7] == 6'd59) begin
                                data[12:7] <= 6'd0;
                                if (data[18:14] == 5'd23) begin
                                    data <= 21'd0;
                                end else begin
                                    data[18:14] <= data[18:14] + 1'b1;
                                end
                            end else begin
                                data[12:7] <= data[12:7] + 1'b1;
                            end
                        end else begin
                            data[5:0] <= data[5:0] + 1'b1;
                        end
                    end else begin
                        cnt <= cnt + 1'b1;
                    end
                end

                SETTING: begin
                    cnt <= 26'd0;
                    if (key_val == S3) begin
                        case (choice)
                            SEC: begin
                                data[5:0] <= (data[5:0] == 6'd59) ? 6'd0 : (data[5:0] + 1'b1);
                            end
                            MIN: begin
                                data[12:7] <= (data[12:7] == 6'd59) ? 6'd0 : (data[12:7] + 1'b1);
                            end
                            HOUR: begin
                                data[18:14] <= (data[18:14] == 5'd23) ? 5'd0 : (data[18:14] + 1'b1);
                            end
                            default: begin ; end
                        endcase
                    end
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
                RUNNING: begin
                    choice <= SEC;
                end

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

                default: begin ; end
            endcase
        end
    end

    always @(*) begin
        led = 3'b111;
        case (current_state)
            RUNNING: begin
                led = 3'b111;
            end

            SETTING: begin
                case (choice)
                    SEC: begin led = 3'b110; end
                    MIN: begin led = 3'b101; end
                    HOUR: begin led = 3'b011; end
                    default: begin ; end
                endcase
            end

            default: begin ; end
        endcase
    end

endmodule
