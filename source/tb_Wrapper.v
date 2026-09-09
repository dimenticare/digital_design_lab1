`timescale 1ns / 1ps

module tb_Wrapper ();

parameter AREA_ROW = 32;
parameter AREA_COL = 16;
parameter ROW_ADDR_W = 5;
parameter COL_ADDR_W = 4;
parameter SPEED_FREQ = 50_000_000;

// Inputs
reg clk;
reg rstn;
reg pressed_left;
reg pressed_right;
reg pressed_up;
reg pressed_down;
reg pressed_speed_up_down;
reg pressed_pause_or_start;
reg [ROW_ADDR_W-1:0] r1_row;
reg [ROW_ADDR_W-1:0] r2_row;

// Outputs
wire [AREA_COL*2-1:0] r1_data;
wire [AREA_COL*2-1:0] r2_data;
wire falling_update;
wire game_over;
wire [9:0] game_score;

Wrapper #(
    .AREA_ROW(AREA_ROW),
    .AREA_COL(AREA_COL),
    .ROW_ADDR_W(ROW_ADDR_W),
    .COL_ADDR_W(COL_ADDR_W),
    .SPEED_FREQ(SPEED_FREQ)
) uut (
    .clk(clk),
    .rstn(rstn),
    .pressed_left(pressed_left),
    .pressed_right(pressed_right),
    .pressed_up(pressed_up),
    .pressed_down(pressed_down),
    .pressed_speed_up_down(pressed_speed_up_down),
    .pressed_pause_or_start(pressed_pause_or_start),
    .r1_row(r1_row),
    .r1_data(r1_data),
    .r2_row(r2_row),
    .r2_data(r2_data),
    .falling_update(falling_update),
    .game_over(game_over),
    .game_score(game_score)
);

always #1 clk = ~clk;

initial begin
    // 初始化输入
    clk = 0;
    rstn = 0;
    pressed_left = 0;
    pressed_right = 0;
    pressed_up = 0;
    pressed_down = 0;
    pressed_speed_up_down = 0;
    pressed_pause_or_start = 0;
    r1_row = 0;
    r2_row = 0;

    // 复位
    #100;
    rstn = 1;
    #100;

    // 模拟按键按下
    #10 pressed_left = 1;
    #10 pressed_left = 0;

    #10 pressed_right = 1;
    #10 pressed_right = 0;

    #10 pressed_up = 1;
    #10 pressed_up = 0;

    #10 pressed_down = 1;
    #10 pressed_down = 0;

    #10 pressed_speed_up_down = 1;
    #10 pressed_speed_up_down = 0;

    #10 pressed_pause_or_start = 1;
    #10 pressed_pause_or_start = 0;

    // 模拟进行中
    repeat (1000) begin
        #10;
    end

    // 检查游戏结束和得分
    $display("Game Over: %b", game_over);
    $display("Game Score: %d", game_score);

    // 结束仿真
    $stop;
end

// 下降更新信号生成
reg [25:0] falling_clk_cnt = 26'b0;

assign falling_update = (falling_clk_cnt == (SPEED_FREQ - 1)) ? 1'b1 : 1'b0;

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

initial begin
    $dumpfile("tb_Wrapper.vcd");
    $dumpvars;
    $display("Saving waveform to tb_Wrapper.vcd");
end 

endmodule
