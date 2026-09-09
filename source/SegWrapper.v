`define SEG_SEL_NULL 4'b0000
`define SEG_SEL_0 4'b0001
`define SEG_SEL_1 4'b0010
`define SEG_SEL_2 4'b0100
`define SEG_SEL_3 4'b1000

// `define SEG_FLASH_DUR 26'd49_999

module SegWrapper #(
    parameter CLK_FREQ = 50_000_000,
    parameter SEG_FLASH_DUR = 49_999,
    parameter SCAN_FREQ = 200, // scan frequency
    parameter SCAN_CLK_CNT = CLK_FREQ / (SCAN_FREQ * 4) - 1
) (
    input clk,
    input rstn,
    input [9:0] game_score,
    output reg [3:0] seg_sel,
    output reg [7:0] seg_data
);

// ¼ÆÊýÆ÷, ´¥·¢ scan_next ÐÅºÅ
reg [31:0] clk_cnt = 32'b0;
wire scan_next;
assign scan_next = (clk_cnt == SCAN_CLK_CNT);

always @(posedge clk or negedge rstn) begin
    if (rstn == 1'b0) begin
        clk_cnt <= 32'b0;
    end else begin
        if (clk_cnt == SCAN_CLK_CNT) begin
            clk_cnt <= 32'b0;
        end else begin
            clk_cnt <= clk_cnt + 32'b1;
        end
    end 
end

// ×´Ì¬»ú for seg_sel
reg [3:0] next_seg_sel = `SEG_SEL_NULL;

// ×´Ì¬»ú for seg_sel, 1) ×´Ì¬×ªÒÆ£¬Ê±ÐòÂß¼­
always @(posedge clk or negedge rstn) begin
    if (rstn == 1'b0) begin
        seg_sel <= `SEG_SEL_NULL;
    end else begin
        seg_sel <= next_seg_sel;
    end 
end 

// ×´Ì¬»ú for seg_sel, 2) ×´Ì¬ÇÐ»»£¬×éºÏÂß¼­
always @(*) begin
    if (scan_next) begin
        case (seg_sel)
            `SEG_SEL_NULL: next_seg_sel = `SEG_SEL_0;
            `SEG_SEL_0: next_seg_sel = `SEG_SEL_1;
            `SEG_SEL_1: next_seg_sel = `SEG_SEL_2;
            `SEG_SEL_2: next_seg_sel = `SEG_SEL_3;
            `SEG_SEL_3: next_seg_sel = `SEG_SEL_0;
            default: next_seg_sel = `SEG_SEL_NULL;
        endcase
    end else begin
        next_seg_sel = seg_sel;
    end 
end

// ×´Ì¬»ú for seg_sel, 3) Êä³ö sel_num & seg_data£¬Ê±ÐòÂß¼­
reg [3:0] sel_num = 4'b0;

always @(posedge clk or negedge rstn) begin
    if (rstn == 1'b0) begin
        sel_num <= 4'b0;
    end else begin
        case (seg_sel)
            `SEG_SEL_NULL: sel_num <= 4'b0;
            `SEG_SEL_0: sel_num <= ((game_score / 1000) % 10);
            `SEG_SEL_1: sel_num <= ((game_score / 100) % 10);
            `SEG_SEL_2: sel_num <= ((game_score / 10) % 10);
            `SEG_SEL_3: sel_num <= (game_score % 10);
            default: sel_num <= 4'b0;
        endcase
    end 
end

// combination logic, output: seg_data, based on sel_num
always @(*) begin
    case(sel_num)
        4'd0: seg_data = 8'b1100_0000;
        4'd1: seg_data = 8'b1111_1001;
        4'd2: seg_data = 8'b1010_0100;
        4'd3: seg_data = 8'b1011_0000;
        4'd4: seg_data = 8'b1001_1001;
        4'd5: seg_data = 8'b1001_0010;
        4'd6: seg_data = 8'b1000_0010;
        4'd7: seg_data = 8'b1111_1000;
        4'd8: seg_data = 8'b1000_0000;
        4'd9: seg_data = 8'b1001_0000;
        4'ha: seg_data = 8'b1000_1000;
        4'hb: seg_data = 8'b1000_0011;
        4'hc: seg_data = 8'b1100_0110;
        4'hd: seg_data = 8'b1010_0001;
        4'he: seg_data = 8'b1000_0110;
        4'hf: seg_data = 8'b1000_1110;
        default: seg_data = 8'b1100_0000;
    endcase
end

endmodule
