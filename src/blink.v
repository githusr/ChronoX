// 指示灯闪烁
module blink(
    input clk, rst, en,
    output reg led
);

    localparam CNT_MAX = 26'd49_999_999; // 1Hz
    reg [25:0] cnt;

    always @(posedge clk or negedge rst) begin
        if (!rst) begin
            cnt <= 26'd0;
            led <= 1'b0;
        end else if (en) begin
            if (cnt == (CNT_MAX >> 1'b1)) begin
                cnt <= 26'd0;
                led <= ~led;
            end else begin
                cnt <= cnt + 1'b1;
            end
        end else begin
            cnt <= 26'd0;
            led <= 1'b0;
        end
    end

endmodule
