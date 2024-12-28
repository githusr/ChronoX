module stopwatch (
    input clk, rst,
    input [2:0] key_val,
    output reg [20:0] data
);
    localparam  S1 = 3'd1,
                S2 = 3'd2,
                S3 = 3'd3,
                S4 = 3'd4;

    localparam  IDLE    = 2'b00,
                RUNNING = 2'b01,
                PAUSED  = 2'b11;

    reg [1:0] current_state, next_state;

    always @(posedge clk or negedge rst) begin
        if (!rst) begin
            current_state <= IDLE;
        end else begin
            current_state <= next_state;
        end
    end

    always @(*) begin
        next_state = current_state;
        case (current_state)
            IDLE: begin
                if (key_val == S2) begin
                    next_state = RUNNING;
                end else begin
                    next_state = IDLE;
                end
            end

            RUNNING: begin
                if (key_val == S2 ||
                    (data[6:0] == 7'd99 && data[12:7] == 6'd59 && data[20:14] == 7'd99)) begin
                    next_state = PAUSED;
                end else begin
                    next_state = RUNNING;
                end
            end

            PAUSED: begin
                if (key_val == S2) begin
                    next_state = RUNNING;
                end else if (key_val == S3) begin
                    next_state = IDLE;
                end else begin
                    next_state = PAUSED;
                end
            end

            default: begin ; end
        endcase
    end

    reg [18:0] cnt;
    localparam CNT_MAX = 19'd499_999; // 0.01s

    always @(posedge clk or negedge rst) begin
        if (!rst) begin
            data <= 21'd0;
            cnt <= 19'd0;
        end else begin
            case (current_state)
                IDLE: begin
                    data <= 21'd0;
                    cnt <= 19'd0;
                end

                RUNNING: begin
                    if (cnt == CNT_MAX) begin
                        cnt <= 19'd0;
                        if (data[6:0] == 7'd99) begin
                            data[6:0] <= 7'd0;
                            if (data[12:7] == 6'd59) begin
                                data[12:7] <= 6'd0;
                                data[20:14] <= data[20:14] + 1'b1;
                            end else begin
                                data[12:7] = data[12:7] + 1'b1;
                            end
                        end else begin
                            data[6:0] <= data[6:0] + 1'b1;
                        end
                    end else begin
                        cnt <= cnt + 1'b1;
                    end
                end

                PAUSED: begin
                end

                default: begin ; end
            endcase
        end
    end

endmodule
