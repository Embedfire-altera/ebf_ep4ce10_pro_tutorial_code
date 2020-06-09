////////////////////////////////////////////////////////////////////////
// Author        : EmbedFire
// Create Date   : 2019/03/15
// Module Name   : tb_non_blocking
// Project Name  : non_blocking
// Target Devices: Altera EP4CE10F17C8N
// Tool Versions : Quartus 13.0
// Description   : 非阻塞赋值仿真文件
//
// Revision      : V1.0
// Additional Comments:
// 
// 实验平台: 野火_征途Pro_FPGA开发板
// 公司    : http://www.embedfire.com
// 论坛    : http://www.firebbs.cn
// 淘宝    : https://fire-stm32.taobao.com
////////////////////////////////////////////////////////////////////////

`timescale  1ns/1ns

module tb_non_blocking();

wire    [1:0]   out;

reg             sys_clk;
reg             sys_rst_n;
reg     [1:0]   in;

//初始化系统时钟、全局复位和输入信号
initial begin
    sys_clk    = 1'b1;
    sys_rst_n <= 1'b0;
    in        <= 2'b0;
    #20;
    sys_rst_n <= 1'b1;
end

//sys_clk:模拟系统时钟，每10ns电平翻转一次，周期为20ns，频率为50Mhz
always #10 sys_clk = ~sys_clk;

//key_in:产生输入随机数，模拟按键的输入情况
always #20 in <= {$random} % 4; //取模求余数，产生非负随机数0、1，每隔20ns产生一次随机数

//------------------------non_blocking_inst------------------------
non_blocking    non_blocking_inst
(
    .sys_clk    (sys_clk    ),  //input             sys_clk
    .sys_rst_n  (sys_rst_n  ),  //input             sys_rst_n
    .in         (in         ),  //input     [1:0]   in

    .out        (out        )   //output    [1:0]   out
);

endmodule