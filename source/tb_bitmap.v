`timescale 1ns / 1ps

module tb_bitmap ();

//==========================================================================
// Game wrapper, including core logic
//==========================================================================
parameter AREA_ROW = 32;
parameter AREA_COL = 16;
parameter ROW_ADDR_W = 5;
parameter COL_ADDR_W = 4;
parameter SPEED_FREQ = 10;

reg clk = 1'b0;
reg rstn = 1'b1;

wire falling_update;

reg    [ROW_ADDR_W-1:0]        cur_blk_row = 0;   // current moving block
reg    [COL_ADDR_W-1:0]        cur_blk_col = 6;   //             : top-left position

wire cur_blk_act;
reg [15:0] cur_blk_data = {
   4'b0_0_0_0,
   4'b0_1_1_0,
   4'b0_0_1_0,
   4'b0_0_1_0
};

Bitmap #(
   .AREA_ROW(AREA_ROW),
   .AREA_COL(AREA_COL),
   .ROW_ADDR_W(ROW_ADDR_W),
   .COL_ADDR_W(COL_ADDR_W),
   .SPEED_FREQ(SPEED_FREQ)
) u_bitmap (
   .clk(clk),
   .rstn(rstn),
   .falling_update(falling_update),
   .cur_blk_row(cur_blk_row),
   .cur_blk_col(cur_blk_col),
   .cur_blk_data(cur_blk_data),
   .test_cur_blk_row(test_cur_blk_row),
   .test_cur_blk_col(test_cur_blk_col),
   .test_cur_blk_data(test_cur_blk_data),
   .cur_blk_act(cur_blk_act),
   .cur_blk_act_rot(cur_blk_act_rot),
   .cur_blk_act_lef(cur_blk_act_lef),
   .cur_blk_act_rig(cur_blk_act_rig),
   .score(score),
   .response(response),
   .r1_row(r1_row),
   .r1_data(r1_data),
   .r2_row(r2_row),
   .r2_data(r2_data)
);

initial begin
   
   rstn = 1;
   #10;
   rstn = 0;
   #10;
   rstn = 1;
   #10;

   #20000;
   $finish;
end

always #1 clk = ~clk;

reg [25:0] falling_clk_cnt = 26'b0;

assign falling_update = (falling_clk_cnt == (SPEED_FREQ - 1)) ? 1'b1 : 1'b0;
// assign falling_update = (falling_clk_cnt >= (SPEED_FREQ - 1)) ? game_state : 1'b0;

always @(posedge clk or negedge rstn) begin
   if (~rstn) begin
      falling_clk_cnt <= 26'b0;
   end 
   else if (falling_clk_cnt >= (SPEED_FREQ - 1)) begin
      falling_clk_cnt <= 26'b0;
   end 
   else begin
      falling_clk_cnt <= falling_clk_cnt + 26'b1;
   end 
end 

always @(posedge clk or negedge rstn) begin
    if (~rstn) begin
        cur_blk_row <= 0;
    end 
    else if (falling_update) begin 
        if (cur_blk_act) begin
            cur_blk_row <= cur_blk_row + 1;
        end 
        else begin
            cur_blk_row <= cur_blk_row;
        end 
    end 
end 

// 输出波形文件
initial begin
    $dumpfile("tb_bitmap.wave");
    $dumpvars;
    $display("save to tb_bitmap.wave");
end 

endmodule