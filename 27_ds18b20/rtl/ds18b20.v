`timescale  1ns/1ns
////////////////////////////////////////////////////////////////////////
// Author        : EmbedFire
// Create Date   : 2019/07/30
// Module Name   : ds18b20
// Project Name  : ds18b20
// Target Devices: Altera EP4CE10F17C8N
// Tool Versions : Quartus 13.0
// Description   : 数字温度传感器显示
//
// Revision      : V1.0
// Additional Comments:
// 
// 实验平台: 野火_征途Pro_FPGA开发板
// 公司    :http://www.embedfire.com
// 论坛    :http://www.firebbs.cn
// 淘宝    :https://fire-stm32.taobao.com
////////////////////////////////////////////////////////////////////////

module  ds18b20
(
    input   wire            sys_clk     ,   //系统时钟，频率50MHz
    input   wire            sys_rst_n   ,   //复位信号，低电平有效

    inout   wire            dq          ,   //数据总线

    output  wire            stcp        ,   //输出数据存储寄时钟
    output  wire            shcp        ,   //移位寄存器的时钟输入
    output  wire            ds          ,   //串行数据输入
    output  wire            oe

);

//********************************************************************//
//****************** Parameter and Internal Signal *******************//
//********************************************************************//

//wire  define
wire    [19:0]  data_out ;
wire            sign     ;

//********************************************************************//
//*************************** Instantiation **************************//
//********************************************************************//

//-------------ds18b20_ctrl_inst--------------
ds18b20_ctrl    ds18b20_ctrl_inst
(
    .sys_clk     (sys_clk  ),   //系统时钟，频率50MHz
    .sys_rst_n   (sys_rst_n),   //复位信号，低电平有效

    .dq          (dq       ),   //数据总线

    .data_out    (data_out ),   //输出温度
    .sign        (sign     )    //输出温度符号位

);

//-------------seg7_dynamic_inst--------------
seg_595_dynamic  seg_595_dynamic_inst
(
    .sys_clk     (sys_clk  ), //系统时钟，频率50MHz
    .sys_rst_n   (sys_rst_n), //复位信号，低有效
    .data        (data_out ), //数码管要显示的值
    .point       (6'b001000), //小数点显示,高电平有效
    .seg_en      (1'b1     ), //数码管使能信号，高电平有效
    .sign        (sign     ), //符号位，高电平显示负号

    .stcp        (stcp     ), //输出数据存储寄时钟
    .shcp        (shcp     ), //移位寄存器的时钟输入
    .ds          (ds       ), //串行数据输入
    .oe          (oe       )  //输出使能信号

);

endmodule
