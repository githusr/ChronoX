// 按键消抖
module key(
    input clk, rst,
    input [3:0] key_in,
    output reg [2:0] key_val
);

    localparam CNT_MAX = 19'd499_999;

    reg [18:0] cnt;

    always @(posedge clk or negedge rst) begin
        if (!rst) begin
            cnt <= 19'd0;
        end else begin
            if (key_in[0] && key_in[1] && key_in[2] && key_in[3]) begin
                cnt <= 19'd0;
            end else begin
                cnt <= (cnt == CNT_MAX) ? cnt : (cnt + 1'b1);
            end
        end
    end

    always @(posedge clk or negedge rst) begin
        if (!rst) begin
            key_val <= 3'd0;
        end else if (cnt == CNT_MAX - 1'b1) begin
            if (~key_in[0]) begin
                key_val <= 3'd1;
            end else if (~key_in[1]) begin
                key_val <= 3'd2;
            end else if (~key_in[2]) begin
                key_val <= 3'd3;
            end else if (~key_in[3]) begin
                key_val <= 3'd4;
            end
        end else begin
            key_val <= 3'd0;
        end
    end

endmodule
