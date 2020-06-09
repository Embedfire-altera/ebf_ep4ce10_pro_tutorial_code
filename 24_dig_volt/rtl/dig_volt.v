`timescale  1ns/1ns
////////////////////////////////////////////////////////////////////////
// Author        : EmbedFire
// Create Date   : 2019/08/10
// Module Name   : dig_volt
// Project Name  : dig_volt
// Target Devices: Altera EP4CE10F17C8N
// Tool Versions : Quartus 13.0
// Description   : 电压表顶层模块
//
// Revision      : V1.0
// Additional Comments:
// 
// 实验平台: 野火_征途Pro_FPGA开发板
// 公司    : http://www.embedfire.com
// 论坛    : http://www.firebbs.cn
// 淘宝    : https://fire-stm32.taobao.com
////////////////////////////////////////////////////////////////////////

module  dig_volt
(
    input   wire            sys_clk     ,   //系统时钟,50MHz
    input   wire            sys_rst_n   ,   //复位信号，低有效
    input   wire    [7:0]   ad_data     ,   //AD输入数据

    output  wire            ad_clk      ,   //AD驱动时钟,最大支持20Mhz时钟
    output  wire            stcp        ,   //数据存储器时钟
    output  wire            shcp        ,   //移位寄存器时钟
    output  wire            ds          ,   //串行数据输入
    output  wire            oe              //使能信号
);
//********************************************************************//
//*********************** Internal Signal ****************************//
//********************************************************************//
//wire  define
wire    [15:0]  volt    ;   //数据转换后的电压值
wire            sign    ;   //正负符号位

//********************************************************************//
//*************************** Instantiation **************************//
//********************************************************************//
//------------- adc_inst -------------
adc     adc_inst
(
    .sys_clk    (sys_clk    ),  //时钟
    .sys_rst_n  (sys_rst_n  ),  //复位信号，低电平有效
    .ad_data    (ad_data    ),  //AD输入数据

    .ad_clk     (ad_clk     ),  //AD驱动时钟,最大支持20Mhz时钟
    .sign       (sign       ),  //正负符号位
    .volt       (volt       )   //数据转换后的电压值
);

//------------- seg_595_dynamic_inst --------------
seg_595_dynamic     seg_595_dynamic_inst
(
    .sys_clk    (sys_clk    ),  //系统时钟，频率50MHz
    .sys_rst_n  (sys_rst_n  ),  //复位信号，低有效
    .data       ({4'b0,volt}),  //数码管要显示的值
    .point      (6'b001000  ),  //小数点显示,高电平有效
    .seg_en     (1'b1       ),  //数码管使能信号，高电平有效
    .sign       (sign       ),  //符号位，高电平显示负号

    .stcp       (stcp       ),  //输出数据存储寄时钟
    .shcp       (shcp       ),  //移位寄存器的时钟输入
    .ds         (ds         ),  //串行数据输入
    .oe         (oe         )   //输出使能信号
);

endmodule