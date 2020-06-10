`timescale  1ns/1ns
////////////////////////////////////////////////////////////////////////
// Author        : EmbedFire
// Create Date   : 2019/07/11
// Module Name   : hc595_ctrl
// Project Name  : seg_595_static
// Target Devices: Altera EP4CE10F17C8N
// Tool Versions : Quartus 13.0
// Description   : 595控制模块
//
// Revision      : V1.0
// Additional Comments:
// 
// 实验平台: 野火_征途Pro_FPGA开发板
// 公司    : http://www.embedfire.com
// 论坛    : http://www.firebbs.cn
// 淘宝    : https://fire-stm32.taobao.com
////////////////////////////////////////////////////////////////////////
module  hc595_ctrl
(
    input   wire            sys_clk     ,   //系统时钟，频率50MHz
    input   wire            sys_rst_n   ,   //复位信号，低有效
    input   wire    [5:0]   sel         ,   //数码管位选信号
    input   wire    [7:0]   seg         ,   //数码管段选信号
    
    output  reg             stcp        ,   //数据存储器时钟
    output  reg             shcp        ,   //移位寄存器时钟
    output  reg             ds          ,   //串行数据输入
    output  wire            oe              //使能信号，低有效
);

//********************************************************************//
//****************** Parameter and Internal Signal *******************//
//********************************************************************//
//reg   define
reg     [1:0]   cnt_4   ;   //分频计数器
reg     [3:0]   cnt_bit ;   //传输位数计数器

//wire  define
wire    [13:0]  data    ;   //数码管信号寄存

//********************************************************************//
//***************************** Main Code ****************************//
//********************************************************************//

//将数码管信号寄存
assign  data = {seg[0],seg[1],seg[2],seg[3],seg[4],seg[5],seg[6],seg[7],sel};

//将复位取反后赋值给其即可
assign oe = ~sys_rst_n;

//分频计数器:0~3循环计数
always@(posedge sys_clk or  negedge sys_rst_n)
    if(sys_rst_n == 1'b0)
        cnt_4 <=  2'd0;
    else    if(cnt_4 == 2'd3)
        cnt_4 <=  2'd0;
    else
        cnt_4 <=  cnt_4 +   1'b1;

//cnt_bit:每输入一位数据加一
always@(posedge sys_clk or  negedge sys_rst_n)
    if(sys_rst_n == 1'b0)
        cnt_bit   <=  4'd0;
    else    if(cnt_4 == 2'd3 && cnt_bit == 4'd13)
        cnt_bit   <=  4'd0;
    else    if(cnt_4  ==  2'd3)
        cnt_bit   <=  cnt_bit   +   1'b1;
    else
        cnt_bit   <=  cnt_bit;

//stcp:14个信号传输完成之后产生一个上升沿
always@(posedge sys_clk or  negedge sys_rst_n)
    if(sys_rst_n == 1'b0)
        stcp    <=  1'b0;
    else    if(cnt_bit == 4'd13 && cnt_4 == 2'd3)
        stcp    <=  1'b1;
    else
        stcp    <=  1'b0;

//shcp:产生四分频移位时钟
always@(posedge sys_clk or  negedge sys_rst_n)
    if(sys_rst_n == 1'b0)
        shcp    <=  1'b0;
    else    if(cnt_4 >= 4'd2)
        shcp    <=  1'b1;
    else
        shcp    <=  1'b0;

//ds:将寄存器里存储的数码管信号输入即
always@(posedge sys_clk or  negedge sys_rst_n)
    if(sys_rst_n == 1'b0)
        ds  <=  1'b0;
    else    if(cnt_4 == 2'd0)
        ds  <=  data[cnt_bit];
    else
        ds  <=  ds;

endmodule
