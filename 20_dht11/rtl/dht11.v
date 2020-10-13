`timescale  1ns/1ns
////////////////////////////////////////////////////////////////////////
// Author        : EmbedFire
// Create Date   : 2019/08/7
// Module Name   : dht11
// Project Name  : dht11
// Target Devices: Altera EP4CE10F17C8N
// Tool Versions : Quartus 13.0
// Description   : 温湿度传感器显示
//
// Revision      : V1.0
// Additional Comments:
// 
// 实验平台: 野火_征途Pro_FPGA开发板
// 公司    :http://www.embedfire.com
// 论坛    :http://www.firebbs.cn
// 淘宝    :https://fire-stm32.taobao.com
////////////////////////////////////////////////////////////////////////

module  dht11
(
    input   wire    sys_clk     ,   //系统时钟，频率50MHz
    input   wire    sys_rst_n   ,   //复位信号，低电平有效
    input   wire    key_in      ,   //按键信号

    inout   wire    dht11       ,   //数据总线
    output  wire    stcp        ,   //输出数据存储寄时钟
    output  wire    shcp        ,   //移位寄存器的时钟输入
    output  wire    ds          ,   //串行数据输入
    output  wire    oe

    );

//********************************************************************//
//****************** Parameter and Internal Signal *******************//
//********************************************************************//

//wire  define
wire    [19:0]  data_out;   //需要显示的数据
wire            key_flag;   //按键消抖后输出信号
wire            sign    ;   //输出符号

//********************************************************************//
//***************************** Main Code ****************************//
//********************************************************************//

//-------------dht11_ctrl_inst--------------
dht11_ctrl  dht11_ctrl_inst
(
    .sys_clk     (sys_clk  ),   //系统时钟，频率50MHz
    .sys_rst_n   (sys_rst_n),   //复位信号，低电平有效
    .key_flag    (key_flag ),   //按键消抖后标志信号

    .dht11       (dht11    ),   //控制总线

    .data_out    (data_out ),   //输出显示的数据
    .sign        (sign     )    //输出符号
);

//-------------key_fifter_inst--------------
key_filter  key_filter_inst
(
    .sys_clk      (sys_clk  )   ,   //系统时钟50Mhz
    .sys_rst_n    (sys_rst_n)   ,   //全局复位
    .key_in       (key_in   )   ,   //按键输入信号

    .key_flag     (key_flag )       //按键消抖后输出信号

);

//-------------seg_595_dynamic_inst--------------
seg_595_dynamic     seg_595_dynamic_inst
(
    .sys_clk     (sys_clk  ), //系统时钟，频率50MHz
    .sys_rst_n   (sys_rst_n), //复位信号，低有效
    .data        (data_out ), //数码管要显示的值
    .point       (6'b000010), //小数点显示,高电平有效
    .seg_en      (1'b1     ), //数码管使能信号，高电平有效
    .sign        (sign     ), //符号位，高电平显示负号

    .stcp        (stcp     ), //输出数据存储寄时钟
    .shcp        (shcp     ), //移位寄存器的时钟输入
    .ds          (ds       ), //串行数据输入
    .oe          (oe       )  //输出使能信号

);

endmodule
