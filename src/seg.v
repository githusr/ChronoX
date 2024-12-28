// 数据显示
module seg(
    input clk, rst,
    input [20:0] data,
    output reg [6:0] seg,
    output reg [7:0] sel
);

    localparam  CNT_MAX = 16'd49_999;

    localparam  DIGIT0 = 7'b100_0000,
                DIGIT1 = 7'b111_1001,
                DIGIT2 = 7'b010_0100,
                DIGIT3 = 7'b011_0000,
                DIGIT4 = 7'b001_1001,
                DIGIT5 = 7'b001_0010,
                DIGIT6 = 7'b000_0010,
                DIGIT7 = 7'b111_1000,
                DIGIT8 = 7'b000_0000,
                DIGIT9 = 7'b001_0000,
                DASH   = 7'b011_1111;

    reg [15:0] cnt;
    reg [2:0] idx;

    // 处理位选信号
    always @(posedge clk or negedge rst) begin
        if (!rst) begin
            cnt <= 16'd0;
            idx <= 3'd0;
            sel <= 8'b1111_1111;
        end else begin
            sel <= ~(1'b1 << idx);
            if (cnt == CNT_MAX) begin // 1kHz
                cnt <= 16'd0;
                idx <= (idx == 3'd7) ? 3'd0 : (idx + 1'b1); // 125Hz
            end else begin
                cnt <= cnt + 1'b1;
            end
        end
    end


    reg [6:0] digit;

    // 处理段选信号
    always @(*) begin

        case (idx)
            3'd0: digit = data[6:0] % 4'd10;
            3'd1: digit = data[6:0] / 4'd10;
            3'd2: digit = 4'd10;
            3'd3: digit = data[13:7] % 4'd10;
            3'd4: digit = data[13:7] / 4'd10;
            3'd5: digit = 4'd10;
            3'd6: digit = data[20:14] % 4'd10;
            3'd7: digit = data[20:14] / 4'd10;
            default: ;
        endcase

        case (digit)
            4'd0: seg = DIGIT0;
            4'd1: seg = DIGIT1;
            4'd2: seg = DIGIT2;
            4'd3: seg = DIGIT3;
            4'd4: seg = DIGIT4;
            4'd5: seg = DIGIT5;
            4'd6: seg = DIGIT6;
            4'd7: seg = DIGIT7;
            4'd8: seg = DIGIT8;
            4'd9: seg = DIGIT9;
            4'd10: seg = DASH;
            default: seg = 7'dx;
        endcase

    end

endmodule
