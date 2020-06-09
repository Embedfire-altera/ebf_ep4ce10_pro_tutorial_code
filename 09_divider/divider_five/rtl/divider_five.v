`timescale  1ns/1ns
///////////////////////////////////////////////////////////////////////////
// Author        : EmbedFire
// Create Date   : 2019/03/16
// Module Name   : divider_five
// Project Name  : divider_five
// Target Devices: Altera EP4CE10F17C8N
// Tool Versions : Quartus 13.0
// Description   : 时钟五分频
//
// Revision      : V1.0
// Additional Comments:
// 
// 实验平台: 野火_征途Pro_FPGA开发板
// 公司    : http://www.embedfire.com
// 论坛    : http://www.firebbs.cn
// 淘宝    : https://fire-stm32.taobao.com
//////////////////////////////////////////////////////////////////////////


//方法1实现：仅实现分频功能
module  divider_five
(
    input   wire    sys_clk     ,   //系统时钟50Mhz
    input   wire    sys_rst_n   ,   //全局复位

    output  wire    clk_out         //对系统时钟5分频后的信号
);

//********************************************************************//
//****************** Parameter and Internal Signal *******************//
//********************************************************************//
//reg   define
reg     [2:0]   cnt;
reg             clk1;
reg             clk2;

//********************************************************************//
//***************************** Main Code ****************************//
//********************************************************************//
//cnt:上升沿开始从0到4循环计数
always@(posedge sys_clk or negedge sys_rst_n)
    if(sys_rst_n == 1'b0)
        cnt <= 3'b0;
    else    if(cnt == 3'd4)
        cnt <= 3'b0;
    else
        cnt <= cnt + 1'b1;

//clk1:上升沿触发，占空比高电平维持2个系统时钟周期，低电平维持3个系统时钟周期
always@(posedge sys_clk or negedge sys_rst_n)
    if(sys_rst_n == 1'b0)
        clk1 <= 1'b1;
    else    if(cnt == 3'd2)
        clk1 <= 1'b0;
    else    if(cnt == 3'd4)
        clk1 <= 1'b1;

//clk2:下降沿触发，占空比高电平维持2个系统时钟周期，低电平维持3个系统时钟周期
always@(negedge sys_clk or negedge sys_rst_n)
    if(sys_rst_n == 1'b0)
        clk2 <= 1'b1;
    else    if(cnt == 3'd2)
        clk2 <= 1'b0;
    else    if(cnt == 3'd4)
        clk2 <= 1'b1;

//clk_out:5分频50%占空比输出
assign clk_out = clk1 & clk2;

endmodule

/*
//方法2实现：实用的降频方法
module  divider_five
(
    input   wire    sys_clk     ,   //系统时钟50Mhz
    input   wire    sys_rst_n   ,   //全局复位

    output  reg     clk_flag        //指示系统时钟5分频后的脉冲标志信号
);

reg [2:0] cnt;  //用于计数的寄存器

//cnt:计数器从0到4循环计数
always@(posedge sys_clk or negedge sys_rst_n)
    if(sys_rst_n == 1'b0)
        cnt <= 3'b0;
    else    if(cnt == 3'd4)
        cnt <= 3'b0;
    else
        cnt <= cnt + 1'b1;

//clk_flag:脉冲信号指示5分频
always@(posedge sys_clk or negedge sys_rst_n)
    if(sys_rst_n == 1'b0)
        clk_flag <= 1'b0;
    else    if(cnt == 3'd3)
        clk_flag <= 1'b1;
    else
        clk_flag <= 1'b0;

endmodule

 */