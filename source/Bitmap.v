`define __DEBUG__

module Bitmap #(
   parameter AREA_ROW = 32,
   parameter AREA_COL = 16,
   parameter ROW_ADDR_W = 5,
   parameter COL_ADDR_W = 4,
   parameter SPEED_FREQ = 50_000_000
)
(
   input                            clk,
   input                            rstn,
   input                            falling_update,// block falling signal
   input    [ROW_ADDR_W-1:0]        cur_blk_row,   // current moving block
   input    [COL_ADDR_W-1:0]        cur_blk_col,   //             : top-left position
   input    [15:0]                  cur_blk_data,  //             : block 4x4 bitmap
   input    [ROW_ADDR_W-1:0]        test_cur_blk_row,   //             test
   input    [COL_ADDR_W-1:0]        test_cur_blk_col,   //             test
   input    [15:0]                  test_cur_blk_data,   //             test
   output                           cur_blk_act,   //             : is still on active
   output                           cur_blk_act_rot,   //             : is still on active
   output                           cur_blk_act_lef,   //             : is still on active
   output                           cur_blk_act_rig,   //             : is still on active
   output   [2:0]                   score,           //消除行数计数
   output                           response,        //game over
   input    [ROW_ADDR_W-1:0]        r1_row,        // output channel #1
   output   [AREA_COL*2-1:0]        r1_data,       //         : data
   input    [ROW_ADDR_W-1:0]        r2_row,        // output channel #1
   output   [AREA_COL*2-1:0]        r2_data        //         : data
);


//==========================================================================
// bitmap content
//==========================================================================

reg [AREA_COL - 1 : 0] bitmap_h [AREA_ROW - 1 : 0];
reg [AREA_COL - 1 : 0] bitmap_l [AREA_ROW - 1 : 0];


`ifdef __DEBUG__
wire [AREA_COL - 1 : 0] bitmap_h24 = bitmap_h[24];
wire [AREA_COL - 1 : 0] bitmap_h25 = bitmap_h[25];
wire [AREA_COL - 1 : 0] bitmap_h26 = bitmap_h[26];
wire [AREA_COL - 1 : 0] bitmap_h27 = bitmap_h[27];
wire [AREA_COL - 1 : 0] bitmap_h28 = bitmap_h[28];
wire [AREA_COL - 1 : 0] bitmap_h29 = bitmap_h[29];
wire [AREA_COL - 1 : 0] bitmap_h30 = bitmap_h[30];
wire [AREA_COL - 1 : 0] bitmap_h31 = bitmap_h[31];

wire [AREA_COL - 1 : 0] bitmap_l0 = bitmap_l[0];
wire [AREA_COL - 1 : 0] bitmap_l1 = bitmap_l[1];
wire [AREA_COL - 1 : 0] bitmap_l2 = bitmap_l[2];
wire [AREA_COL - 1 : 0] bitmap_l3 = bitmap_l[3];
wire [AREA_COL - 1 : 0] bitmap_l10 = bitmap_l[10];
wire [AREA_COL - 1 : 0] bitmap_l11 = bitmap_l[11];
wire [AREA_COL - 1 : 0] bitmap_l12 = bitmap_l[12];
wire [AREA_COL - 1 : 0] bitmap_l13 = bitmap_l[13];
wire [AREA_COL - 1 : 0] bitmap_l20 = bitmap_l[20];
wire [AREA_COL - 1 : 0] bitmap_l21 = bitmap_l[21];
wire [AREA_COL - 1 : 0] bitmap_l22 = bitmap_l[22];
wire [AREA_COL - 1 : 0] bitmap_l23 = bitmap_l[23];
wire [AREA_COL - 1 : 0] bitmap_l28 = bitmap_l[28];
wire [AREA_COL - 1 : 0] bitmap_l29 = bitmap_l[29];
wire [AREA_COL - 1 : 0] bitmap_l30 = bitmap_l[30];
wire [AREA_COL - 1 : 0] bitmap_l31 = bitmap_l[31];
`endif

//==========================================================================
// moving block
//==========================================================================

generate
genvar j;
for (j = 0; j < AREA_ROW; j = j+1) begin
   always @(posedge clk or negedge rstn) begin
      if (~rstn) begin
         bitmap_l[j] <= 0;
      end 
      else begin
         if (j == cur_blk_row) begin
            bitmap_l[j] <= {12'b0, cur_blk_data[3:0]} << (cur_blk_col);
         end 
         else if (j == cur_blk_row + 1) begin
            bitmap_l[j] <= {12'b0, cur_blk_data[7:4]} << (cur_blk_col);
         end 
         else if (j == cur_blk_row + 2) begin
            bitmap_l[j] <= {12'b0, cur_blk_data[11:8]} << (cur_blk_col);
         end
         else if (j == cur_blk_row + 3) begin
            bitmap_l[j] <= {12'b0, cur_blk_data[15:12]} << (cur_blk_col);
         end
         else begin
            bitmap_l[j] <= 0;
         end  
      end 
   end
end 
endgenerate

//==========================================================================
// output channel #1
//==========================================================================

wire [AREA_COL-1:0] r1_data_h = bitmap_h[r1_row];
wire [AREA_COL-1:0] r1_data_l = bitmap_l[r1_row];

assign r1_data = {r1_data_h, r1_data_l};


//==========================================================================
// output channel #2
//==========================================================================

reg [2*AREA_COL-1:0] r2_data_r;
assign r2_data = r2_data_r;

always @(*) begin
   r2_data_r <= {bitmap_h[r2_row], bitmap_l[r2_row]};
end 


//==========================================================================
// TODO - add your logic
//==========================================================================

//game over
assign response = (bitmap_h[0] != 16'b0);

//触底或触壁逻辑
reg [31:0] touch;
generate
genvar i;
for(i = 0; i < AREA_ROW; i = i + 1) begin
   if ( i == 31 )
      always @(*) begin
         if(bitmap_l[31] != 16'b0) begin //触底判断
            touch[31] = 1'b1;
         end
         else begin
            touch[31] = 1'b0;
         end
      end
   else begin
      always @(*)begin
         if((bitmap_l[i] & bitmap_h[i + 1]) != 16'b0) begin //触壁判断
            touch[i] = 1'b1;
         end
         else begin
            touch[i] = 1'b0;
         end
      end
   end
end
endgenerate

assign cur_blk_act = ~(|touch);

//消除行数计算器
wire [31:0] elirow;
reg [31:0] elirow_r;
assign elirow=elirow_r;
assign score = elirow[0]+elirow[1]+elirow[2]+elirow[3]+elirow[4]+elirow[5]+elirow[6]+elirow[7]+elirow[8]+elirow[9]+
        elirow[10]+elirow[11]+elirow[12]+elirow[13]+elirow[14]+elirow[15]+elirow[16]+elirow[17]+elirow[18]+elirow[19]+
        elirow[20]+elirow[21]+elirow[22]+elirow[23]+elirow[24]+elirow[25]+elirow[26]+elirow[27]+elirow[28]+elirow[29]+
        elirow[30]+elirow[31];

generate
integer o;
integer p;
integer m;
integer n;
always @(posedge clk or negedge rstn) begin
   if (~rstn) begin //归零时，清空bitmap_h
      for (m = 0; m < AREA_ROW; m = m + 1) begin
         bitmap_h[m] <= 16'h0;
      end 
   end
   else begin
      if(~cur_blk_act) begin //触底或触壁
         for (m = 0; m < AREA_ROW; m = m + 1) begin
            bitmap_h[m] <= bitmap_h[m] | bitmap_l[m]; //浮动方块被确认到bitmap_h中
         end
      end
      for (p = 0; p < AREA_ROW; p = p + 1) begin
         elirow_r[p] <= (bitmap_h[p] == 16'hFFFF);
      end
      for (o = 0; o < AREA_ROW; o = o + 1) begin 
         if(bitmap_h[o] == 16'hFFFF)begin //从上往下进行消行判断
            if(o > 0) begin
               for (n = o; n > 0; n = n - 1)begin
                  bitmap_h[n] <= (bitmap_h[n - 1]); //每一行下移一格
               end
               bitmap_h[0] <= 16'h0; //首行清空
            end
            else begin
               bitmap_h[0] <= 16'h0; //首行清空
            end
         end
      end
   end
end
endgenerate

genvar k;
//判断是否可以左移
reg cur_blk_act_lef_r;
assign cur_blk_act_lef = cur_blk_act_lef_r;

//对每一个方块位置进行对比，判断是否会发生堵塞
wire [15:0] lef_result;
wire lef_tot_result;
assign lef_result[0] = (bitmap_h[cur_blk_row][cur_blk_col-1] & bitmap_l[cur_blk_row][cur_blk_col]);
assign lef_result[1] = (bitmap_h[cur_blk_row+1][cur_blk_col-1] & bitmap_l[cur_blk_row+1][cur_blk_col]);
assign lef_result[2] = (bitmap_h[cur_blk_row+2][cur_blk_col-1] & bitmap_l[cur_blk_row+2][cur_blk_col]);
assign lef_result[3] = (bitmap_h[cur_blk_row+3][cur_blk_col-1] & bitmap_l[cur_blk_row+3][cur_blk_col]);
assign lef_result[4] = (bitmap_h[cur_blk_row][cur_blk_col-1+1] & bitmap_l[cur_blk_row][cur_blk_col+1]);
assign lef_result[5] = (bitmap_h[cur_blk_row+1][cur_blk_col-1+1] & bitmap_l[cur_blk_row+1][cur_blk_col+1]);
assign lef_result[6] = (bitmap_h[cur_blk_row+2][cur_blk_col-1+1] & bitmap_l[cur_blk_row+2][cur_blk_col+1]);
assign lef_result[7] = (bitmap_h[cur_blk_row+3][cur_blk_col-1+1] & bitmap_l[cur_blk_row+3][cur_blk_col+1]);
assign lef_result[8] = (bitmap_h[cur_blk_row][cur_blk_col-1+2] & bitmap_l[cur_blk_row][cur_blk_col+2]);
assign lef_result[9] = (bitmap_h[cur_blk_row+1][cur_blk_col-1+2] & bitmap_l[cur_blk_row+1][cur_blk_col+2]);
assign lef_result[10] = (bitmap_h[cur_blk_row+2][cur_blk_col-1+2] & bitmap_l[cur_blk_row+2][cur_blk_col+2]);
assign lef_result[11] = (bitmap_h[cur_blk_row+3][cur_blk_col-1+2] & bitmap_l[cur_blk_row+3][cur_blk_col+2]);
assign lef_result[12] = (bitmap_h[cur_blk_row][cur_blk_col-1+3] & bitmap_l[cur_blk_row][cur_blk_col+3]);
assign lef_result[13] = (bitmap_h[cur_blk_row+1][cur_blk_col-1+3] & bitmap_l[cur_blk_row+1][cur_blk_col+3]);
assign lef_result[14] = (bitmap_h[cur_blk_row+2][cur_blk_col-1+3] & bitmap_l[cur_blk_row+2][cur_blk_col+3]);
assign lef_result[15] = (bitmap_h[cur_blk_row+3][cur_blk_col-1+3] & bitmap_l[cur_blk_row+3][cur_blk_col+3]);
assign lef_tot_result = |lef_result;
always @(*) begin
   if(cur_blk_col==0 && (cur_blk_data[0] | cur_blk_data[4] | cur_blk_data[8] | cur_blk_data[12]))begin//判断最左侧是否存在方块阻挡左移
      cur_blk_act_lef_r = 0;
   end
   else if(lef_tot_result)begin
      cur_blk_act_lef_r = 0;
   end
   else begin
      cur_blk_act_lef_r = 1;
   end
end

//判断是否可以右移
reg cur_blk_act_rig_r;
assign cur_blk_act_rig = cur_blk_act_rig_r;

//对每一个方块位置进行对比，判断是否会发生堵塞
wire [15:0] rig_result;
wire rig_tot_result;
assign rig_result[0] = (bitmap_h[cur_blk_row][cur_blk_col+1] & bitmap_l[cur_blk_row][cur_blk_col]);
assign rig_result[1] = (bitmap_h[cur_blk_row+1][cur_blk_col+1] & bitmap_l[cur_blk_row+1][cur_blk_col]);
assign rig_result[2] = (bitmap_h[cur_blk_row+2][cur_blk_col+1] & bitmap_l[cur_blk_row+2][cur_blk_col]);
assign rig_result[3] = (bitmap_h[cur_blk_row+3][cur_blk_col+1] & bitmap_l[cur_blk_row+3][cur_blk_col]);
assign rig_result[4] = (bitmap_h[cur_blk_row][cur_blk_col+1+1] & bitmap_l[cur_blk_row][cur_blk_col+1]);
assign rig_result[5] = (bitmap_h[cur_blk_row+1][cur_blk_col+1+1] & bitmap_l[cur_blk_row+1][cur_blk_col+1]);
assign rig_result[6] = (bitmap_h[cur_blk_row+2][cur_blk_col+1+1] & bitmap_l[cur_blk_row+2][cur_blk_col+1]);
assign rig_result[7] = (bitmap_h[cur_blk_row+3][cur_blk_col+1+1] & bitmap_l[cur_blk_row+3][cur_blk_col+1]);
assign rig_result[8] = (bitmap_h[cur_blk_row][cur_blk_col+1+2] & bitmap_l[cur_blk_row][cur_blk_col+2]);
assign rig_result[9] = (bitmap_h[cur_blk_row+1][cur_blk_col+1+2] & bitmap_l[cur_blk_row+1][cur_blk_col+2]);
assign rig_result[10] = (bitmap_h[cur_blk_row+2][cur_blk_col+1+2] & bitmap_l[cur_blk_row+2][cur_blk_col+2]);
assign rig_result[11] = (bitmap_h[cur_blk_row+3][cur_blk_col+1+2] & bitmap_l[cur_blk_row+3][cur_blk_col+2]);
assign rig_result[12] = (bitmap_h[cur_blk_row][cur_blk_col+1+3] & bitmap_l[cur_blk_row][cur_blk_col+3]);
assign rig_result[13] = (bitmap_h[cur_blk_row+1][cur_blk_col+1+3] & bitmap_l[cur_blk_row+1][cur_blk_col+3]);
assign rig_result[14] = (bitmap_h[cur_blk_row+2][cur_blk_col+1+3] & bitmap_l[cur_blk_row+2][cur_blk_col+3]);
assign rig_result[15] = (bitmap_h[cur_blk_row+3][cur_blk_col+1+3] & bitmap_l[cur_blk_row+3][cur_blk_col+3]);
assign rig_tot_result = |rig_result;
always @(*) begin
    if(cur_blk_col+3==AREA_COL-1 && (cur_blk_data[3] | cur_blk_data[7] | cur_blk_data[11] | cur_blk_data[15]))begin//判断最右侧是否存在方块阻挡右移
        cur_blk_act_rig_r = 0;
    end
    else if(rig_tot_result)begin
        cur_blk_act_rig_r = 0;
    end
    else begin
        cur_blk_act_rig_r = 1;
    end
end


//判断是否可以旋转
reg cur_blk_act_rot_r;
assign cur_blk_act_rot = cur_blk_act_rot_r;

//对每一个方块位置进行对比，判断是否会发生堵塞
wire [15:0] rot_result;
wire rot_tot_result;
assign rot_result[0] = cur_blk_data[12] & bitmap_h[cur_blk_row][cur_blk_col];
assign rot_result[1] = cur_blk_data[8] & bitmap_h[cur_blk_row][cur_blk_col+1];
assign rot_result[2] = cur_blk_data[4] & bitmap_h[cur_blk_row][cur_blk_col+2];
assign rot_result[3] = cur_blk_data[0] & bitmap_h[cur_blk_row][cur_blk_col+3];
assign rot_result[4] = cur_blk_data[13] & bitmap_h[cur_blk_row+1][cur_blk_col];
assign rot_result[5] = cur_blk_data[9] & bitmap_h[cur_blk_row+1][cur_blk_col+1];
assign rot_result[6] = cur_blk_data[5] & bitmap_h[cur_blk_row+1][cur_blk_col+2];
assign rot_result[7] = cur_blk_data[1] & bitmap_h[cur_blk_row+1][cur_blk_col+3];
assign rot_result[8] = cur_blk_data[14] & bitmap_h[cur_blk_row+2][cur_blk_col];
assign rot_result[9] = cur_blk_data[10] & bitmap_h[cur_blk_row+2][cur_blk_col+1];
assign rot_result[10] = cur_blk_data[6] & bitmap_h[cur_blk_row+2][cur_blk_col+2];
assign rot_result[11] = cur_blk_data[2] & bitmap_h[cur_blk_row+2][cur_blk_col+3];
assign rot_result[12] = cur_blk_data[15] & bitmap_h[cur_blk_row+3][cur_blk_col];
assign rot_result[13] = cur_blk_data[11] & bitmap_h[cur_blk_row+3][cur_blk_col+1];
assign rot_result[14] = cur_blk_data[7] & bitmap_h[cur_blk_row+3][cur_blk_col+2];
assign rot_result[15] = cur_blk_data[3] & bitmap_h[cur_blk_row+3][cur_blk_col+3];
assign rot_tot_result = |rot_result;
always @(*) begin
    if(rot_tot_result) begin
        cur_blk_act_rot_r = 0;
    end    
    else begin
        cur_blk_act_rot_r = 1;
    end
end

endmodule