// 蜂鸣器发声
module buzz(
    input clk, rst, en,
    output buz
);

    localparam CNT_MAX = 16'd39_999; // 1.25kHz
    reg [15:0] cnt;

    always @(posedge clk or negedge rst) begin
        if (!rst) begin
            cnt <= 16'd0;
        end else if (en) begin
            cnt <= (cnt == CNT_MAX) ? 16'd0 : (cnt + 1'b1);
        end else begin
            cnt <= 16'd0;
        end
    end

    assign buz = (cnt <= (CNT_MAX >> 1'b1)) ? 1'b0 : 1'b1; // 50%占空比

endmodule
