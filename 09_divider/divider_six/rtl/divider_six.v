`timescale  1ns/1ns
////////////////////////////////////////////////////////////////////////
// Author        : EmbedFire
// Create Date   : 2019/03/16
// Module Name   : divider_six
// Project Name  : divider_six
// Target Devices: Altera EP4CE10F17C8N
// Tool Versions : Quartus 13.0
// Description   : 六分频
//
// Revision      : V1.0
// Additional Comments:
// 
// 实验平台: 野火_征途Pro_FPGA开发板
// 公司    : http://www.embedfire.com
// 论坛    : http://www.firebbs.cn
// 淘宝    : https://fire-stm32.taobao.com
////////////////////////////////////////////////////////////////////////


//方法1实现：仅实现分频功能
module  divider_six
(
    input   wire    sys_clk     ,   //系统时钟50Mhz
    input   wire    sys_rst_n   ,   //全局复位

    output  reg     clk_out         //对系统时钟6分频后的信号
);

//********************************************************************//
//****************** Parameter and Internal Signal *******************//
//********************************************************************//
//reg   define
reg [1:0] cnt;  //用于计数的寄存器

//********************************************************************//
//***************************** Main Code ****************************//
//********************************************************************//
//cnt:计数器从0到2循环计数
always@(posedge sys_clk or negedge sys_rst_n)
    if(sys_rst_n == 1'b0)
        cnt <= 2'b0;
    else    if(cnt == 2'd2)
        cnt <= 2'b0;
    else
        cnt <= cnt + 1'b1;

//clk_out:6分频50%占空比输出
always@(posedge sys_clk or negedge sys_rst_n)
    if(sys_rst_n == 1'b0)
        clk_out <= 1'b0;
    else    if(cnt == 2'd2)
        clk_out <= ~clk_out;

endmodule


/* 
//方法2实现：实用的降频方法
module  divider_six(
    input   wire    sys_clk     ,   //系统时钟50Mhz
    input   wire    sys_rst_n   ,   //全局复位

    output  reg     clk_flag        //指示系统时钟6分频后的脉冲标志信号
);

reg [2:0] cnt;  //用于计数的寄存器

//cnt:计数器从0到5循环计数
always@(posedge sys_clk or negedge sys_rst_n)
    if(sys_rst_n == 1'b0)
        cnt <= 3'b0;
    else    if(cnt == 3'd5)
        cnt <= 3'b0;
    else
        cnt <= cnt + 1'b1;

//clk_flag:脉冲信号指示6分频
always@(posedge sys_clk or negedge sys_rst_n)
    if(sys_rst_n == 1'b0)
        clk_flag <= 1'b0;
    else    if(cnt == 3'd4)
        clk_flag <= 1'b1;
    else
        clk_flag <= 1'b0;

endmodule
 */