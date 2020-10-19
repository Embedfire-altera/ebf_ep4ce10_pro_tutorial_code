`timescale  1ns/1ns
////////////////////////////////////////////////////////////////////////
// Author        : EmbedFire
// Create Date   : 2019/07/10
// Module Name   : freq_meter
// Project Name  : freq_meter
// Target Devices: Altera EP4CE10F17C8N
// Tool Versions : Quartus 13.0
// Description   : 简易频率计顶层模块
//
// Revision      : V1.0
// Additional Comments:
// 
// 实验平台: 野火_征途Pro_FPGA开发板
// 公司    : http://www.embedfire.com
// 论坛    : http://www.firebbs.cn
// 淘宝    : https://fire-stm32.taobao.com
////////////////////////////////////////////////////////////////////////

module  freq_meter
(
    input   wire            sys_clk     ,   //系统时钟,频率50MHz
    input   wire            sys_rst_n   ,   //复位信号,低电平有效
    input   wire            clk_test    ,   //待检测时钟

    output  wire            clk_out     ,   //生成的待检测时钟
    output  wire            stcp        ,   //输出数据存储寄时钟
    output  wire            shcp        ,   //移位寄存器的时钟输入
    output  wire            ds          ,   //串行数据输入
    output  wire            oe

);

//wire  define
wire    [33:0]  freq    ;   //计算得到的待检测信号时钟频率

//********************************************************************//
//*************************** Instantiation **************************//
//********************************************************************//
//---------- clk_gen_test_inst ----------
clk_test_gen    clk_gen_test_inst
(
    .areset     (~sys_rst_n ),  //复位端口,高电平有效
    .inclk0     (sys_clk    ),  //输入系统时钟

    .c0         (clk_out    )   //输出生成的待检测时钟信号
);

//------------- freq_meter_calc_inst --------------
freq_meter_calc freq_meter_calc_inst
(
    .sys_clk    (sys_clk    ),   //系统时钟,频率50MHz
    .sys_rst_n  (sys_rst_n  ),   //复位信号,低电平有效
    .clk_test   (clk_test   ),   //待检测时钟

    .freq       (freq       )    //待检测时钟频率  
);

//------------- seg_595_dynamic_inst --------------
seg_595_dynamic     seg_595_dynamic_inst
(
    .sys_clk     (sys_clk    ), //系统时钟，频率50MHz
    .sys_rst_n   (sys_rst_n  ), //复位信号，低有效
    .data        (freq/1000  ), //数码管要显示的值
    .point       (6'b001000  ), //小数点显示,高电平有效
    .seg_en      (1'b1       ), //数码管使能信号，高电平有效
    .sign        (1'b0       ), //符号位，高电平显示负号

    .stcp        (stcp       ), //输出数据存储寄时钟
    .shcp        (shcp       ), //移位寄存器的时钟输入
    .ds          (ds         ), //串行数据输入
    .oe          (oe         )  //输出使能信号

);

endmodule
