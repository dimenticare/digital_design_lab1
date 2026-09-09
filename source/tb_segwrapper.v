`timescale 1ns/1ns

module tb_segwrapper;

  // Parameters
  parameter SCAN_FREQ = 200; // Scan frequency
  parameter CLK_FREQ = 50_000_000;
  parameter SCAN_CLK_CNT = 2;
  // Inputs
  reg clk = 0;
  reg rstn = 1;
  reg [9:0] game_score = 3;

  // Outputs
  wire [5:0] seg_sel;
  wire [7:0] seg_data;

  // Instantiate the SegWrapper module
  // Instantiate the SegWrapper module
SegWrapper #(
  .CLK_FREQ(CLK_FREQ),
  .SCAN_FREQ(SCAN_FREQ),
  .SCAN_CLK_CNT(SCAN_CLK_CNT)
) seg_wrapper_inst (
  .clk(clk),
  .rstn(rstn),
  .game_score(game_score),
  .seg_sel(seg_sel),
  .seg_data(seg_data)
);


  // Clock generation
  always #5 clk = ~clk;

  // Test sequence
  initial begin
    // Apply a reset
    rstn = 0;
    #10 rstn = 1;

    // Simulate game scores
    #20 game_score = 1234;
    #400 game_score = 0000;

    // Wait for simulation to finish
    #100 $finish;
  end

endmodule
