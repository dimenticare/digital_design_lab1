module KeyDebounce #(
                              // clock frequency(Mhz), 50 MHz
   parameter CLK_FREQ = 50_000_000,
   parameter KEY_CNT = 8
)
(
   input                clk,               // clock input
   input  [KEY_CNT-1:0] keys,              // input key pins, raw input
   output [KEY_CNT-1:0] keys_stable        // output stable key status, 0 - press down
);


// TODO - add your logic
reg [KEY_CNT-1:0] keys_prev;  // 用于缓存前一个时刻的按键状态

reg [KEY_CNT-1:0] keys_debounced=8'b1111_1111;  // 用于存储消抖后的按键状态

reg [19:0] debounce_counter;  // 消抖计数器，20ms为一个计数周期

// 按键状态的变化检测
always @(posedge clk) begin
    keys_prev <= keys;  // 缓存当前的按键状态

    // 如果按键状态有变化，则重新开始消抖计数
    if (keys != keys_prev)
        debounce_counter <= 0;
    else if (debounce_counter < (CLK_FREQ / 50))  // 20ms的消抖
        debounce_counter <= debounce_counter + 1;
end

// 按键消抖
always @(posedge clk) begin
    if (debounce_counter == (CLK_FREQ / 50)) begin
        keys_debounced <= keys;  // 当消抖计数器达到阈值时，更新消抖后的按键状态
    end
end

// 输出稳定的按键状态
assign keys_stable[KEY_CNT-1:0] = keys_debounced[KEY_CNT-1:0];

endmodule
