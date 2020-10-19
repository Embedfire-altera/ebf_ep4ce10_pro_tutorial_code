`timescale  1ns/1ns
////////////////////////////////////////////////////////////////////////
// Author        : EmbedFire
// Create Date   : 2019/07/15
// Module Name   : top_infrared_rcv
// Project Name  : top_infrared_rcv
// Target Devices: Altera EP4CE10F17C8N
// Tool Versions : Quartus 13.0
// Description   : 红外遥控数码管显示，顶层模块
//
// Revision      :V1.0
// Additional Comments:
//
// 实验平台:野火_征途Pro_FPGA开发板
// 公司    :http://www.embedfire.com
// 论坛    :http://www.firebbs.cn
// 淘宝    :https://fire-stm32.taobao.com
////////////////////////////////////////////////////////////////////////

module  top_infrared_rcv
(
    input   wire         sys_clk     ,   //系统时钟，频率50MHz
    input   wire         sys_rst_n   ,   //复位信号，低电平有效
    input   wire         infrared_in ,   //红外接收信号

    output  wire         stcp        ,   //输出数据存储寄时钟
    output  wire         shcp        ,   //移位寄存器的时钟输入
    output  wire         ds          ,   //串行数据输入
    output  wire         oe          ,   //输出使能信号
    output  wire         led             //led灯控制信号
);

//********************************************************************//
//******************** Parameter And Internal Signal *****************//
//********************************************************************//

//wire  define
wire            repeat_en   ;   //重复码使能信号
wire    [19:0]  data        ;   //接收的控制码

//********************************************************************//
//**************************** Main Code *****************************//
//********************************************************************//

//-------------infrared_rcv_inst--------------
infrared_rcv    infrared_rcv_inst
(
    .sys_clk     (sys_clk    ),   //系统时钟，频率50MHz
    .sys_rst_n   (sys_rst_n  ),   //复位信号，低有效
    .infrared_in (infrared_in),   //红外接受信号

    .repeat_en   (repeat_en  ),   //重复码使能信号
    .data        (data       )    //接收的控制码
);

//-------------led_ctrl_inst--------------
led_ctrl    led_ctrl_inst
(
    .sys_clk     (sys_clk  ) ,   //系统时钟，频率50MHz
    .sys_rst_n   (sys_rst_n) ,   //复位信号，低有效
    .repeat_en   (repeat_en) ,   //重复码使能信号

    .led         (led      )
);

//-------------seg_595_dynamic_inst--------------
seg_595_dynamic     seg_595_dynamic_inst
(
    .sys_clk     (sys_clk  ), //系统时钟，频率50MHz
    .sys_rst_n   (sys_rst_n), //复位信号，低有效
    .data        (data     ), //数码管要显示的值
    .point       (6'd0     ), //小数点显示,高电平有效
    .seg_en      (1'b1     ), //数码管使能信号，高电平有效
    .sign        (1'b0     ), //符号位，高电平显示负号

    .stcp        (stcp     ), //输出数据存储寄时钟
    .shcp        (shcp     ), //移位寄存器的时钟输入
    .ds          (ds       ), //串行数据输入
    .oe          (oe       )  //输出使能信号
);

endmodule
