`timescale  1ns/1ns
////////////////////////////////////////////////////////////////////////
// Author        : EmbedFire
// Create Date   : 2019/07/11
// Module Name   : seg_595_static
// Project Name  : seg_595_static
// Target Devices: Altera EP4CE10F17C8N
// Tool Versions : Quartus 13.0
// Description   : 静态数码管顶层模块
//
// Revision      : V1.0
// Additional Comments:
// 
// 实验平台: 野火_征途Pro_FPGA开发板
// 公司    : http://www.embedfire.com
// 论坛    : http://www.firebbs.cn
// 淘宝    : https://fire-stm32.taobao.com
////////////////////////////////////////////////////////////////////////

module  seg_595_static
(
    input   wire            sys_clk     ,   //系统时钟，频率50MHz
    input   wire            sys_rst_n   ,   //复位信号，低有效

    output  wire            stcp        ,   //输出数据存储寄时钟
    output  wire            shcp        ,   //移位寄存器的时钟输入
    output  wire            ds          ,   //串行数据输入
    output  wire            oe              //输出使能信号
);

//********************************************************************//
//******************** Parameter And Internal Signal *****************//
//********************************************************************//
//wire  define
wire    [5:0]   sel;
wire    [7:0]   seg;

//********************************************************************//
//*************************** Instantiation **************************//
//********************************************************************//
//---------- seg_static_inst ----------
seg_static  seg_static_inst
(
    .sys_clk     (sys_clk   ),   //系统时钟，频率50MHz
    .sys_rst_n   (sys_rst_n ),   //复位信号，低电平有效

    .sel         (sel       ),   //数码管位选信号
    .seg         (seg       )    //数码管段选信号
);

//---------- hc595_ctrl_inst ----------
hc595_ctrl  hc595_ctrl_inst
(
    .sys_clk     (sys_clk  ),   //系统时钟，频率50MHz
    .sys_rst_n   (sys_rst_n),   //复位信号，低有效
    .sel         (sel      ),   //数码管位选信号
    .seg         (seg      ),   //数码管段选信号

    .stcp        (stcp     ),   //输出数据存储寄时钟
    .shcp        (shcp     ),   //移位寄存器的时钟输入
    .ds          (ds       ),   //串行数据输入
    .oe          (oe       )    //输出使能信号
);

endmodule
