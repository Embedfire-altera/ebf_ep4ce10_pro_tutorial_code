`timescale  1ns/1ns
////////////////////////////////////////////////////////////////////////
// Author        : EmbedFire
// Create Date   : 2019/03/21
// Module Name   : spi_flash_be
// Project Name  : spi_flash_be
// Target Devices: Altera EP4CE10F17C8N
// Tool Versions : Quartus 13.0
// Description   : spi_flash_be顶层模块
//
// Revision      : V1.0
// Additional Comments:
// 
// 实验平台: 野火_征途Pro_FPGA开发板
// 公司    : http://www.embedfire.com
// 论坛    : http://www.firebbs.cn
// 淘宝    : https://fire-stm32.taobao.com
////////////////////////////////////////////////////////////////////////

module  spi_flash_be
(
    input   wire    sys_clk     ,   //系统时钟，频率50MHz
    input   wire    sys_rst_n   ,   //复位信号,低电平有效
    input   wire    pi_key      ,   //按键输入信号

    output  wire    cs_n        ,   //片选信号
    output  wire    sck         ,   //串行时钟
    output  wire    mosi            //主输出从输入数据
);

//********************************************************************//
//****************** Parameter and Internal Signal *******************//
//********************************************************************//
//parameter define
parameter   CNT_MAX =   20'd999_999;    //计数器计数最大值

//wire  define
wire    po_key  ;

//********************************************************************//
//*************************** Instantiation **************************//
//********************************************************************//
//------------- key_filter_inst -------------
key_filter
#(
    .CNT_MAX    (CNT_MAX    )   //计数器计数最大值
)
key_filter_inst
(
    .sys_clk    (sys_clk    ),  //系统时钟，频率50MHz
    .sys_rst_n  (sys_rst_n  ),  //复位信号,低电平有效
    .key_in     (pi_key     ),  //按键输入信号

    .key_flag   (po_key     )   //消抖后信号
);

//------------- flash_be_ctrl_inst -------------
flash_be_ctrl  flash_be_ctrl_inst
(

    .sys_clk    (sys_clk    ),  //系统时钟，频率50MHz
    .sys_rst_n  (sys_rst_n  ),  //复位信号,低电平有效
    .key        (po_key     ),  //按键输入信号

    .sck        (sck        ),  //片选信号
    .cs_n       (cs_n       ),  //串行时钟
    .mosi       (mosi       )   //主输出从输入数据
);

endmodule
