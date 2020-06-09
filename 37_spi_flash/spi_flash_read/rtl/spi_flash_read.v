`timescale  1ns/1ns
////////////////////////////////////////////////////////////////////////
// Author        : EmbedFire
// Create Date   : 2019/03/27
// Module Name   : spi_flash_read
// Project Name  : spi_flash_read
// Target Devices: Altera EP4CE10F17C8N
// Tool Versions : Quartus 13.0
// Description   : flash读顶层
//
// Revision      : V1.0
// Additional Comments:
// 
// 实验平台: 野火_征途Pro_FPGA开发板
// 公司    : http://www.embedfire.com
// 论坛    : http://www.firebbs.cn
// 淘宝    : https://fire-stm32.taobao.com
////////////////////////////////////////////////////////////////////////

module  spi_flash_read(

    input   wire    sys_clk     ,   //系统时钟，频率50MHz
    input   wire    sys_rst_n   ,   //复位信号,低电平有效
    input   wire    pi_key      ,   //按键输入信号
    input   wire    miso        ,   //读出flash数据

    output  wire    cs_n        ,   //片选信号
    output  wire    sck         ,   //串行时钟
    output  wire    mosi        ,   //主输出从输入数据
    output  wire    tx              

);

//********************************************************************//
//****************** Parameter and Internal Signal *******************//
//********************************************************************//
//parameter define
parameter   CNT_MAX     =   20'd999_999     ;   //计数器计数最大值
parameter   UART_BPS    =   14'd9600        ,   //比特率
            CLK_FREQ    =   26'd50_000_000  ;   //时钟频率


//wire  define
wire            po_key  ;   //消抖处理后的按键信号
wire            tx_flag ;   //输入串口发送模块数据标志信号
wire    [7:0]   tx_data ;   //输入串口发送模块数据

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

//-------------flash_read_ctrl_inst-------------
flash_read_ctrl  flash_read_ctrl_inst(

    .sys_clk    (sys_clk    ),  //系统时钟，频率50MHz
    .sys_rst_n  (sys_rst_n  ),  //复位信号,低电平有效
    .key        (po_key     ),  //按键输入信号
    .miso       (miso       ),  //读出flash数据

    .sck        (sck        ),  //片选信号
    .cs_n       (cs_n       ),  //串行时钟
    .mosi       (mosi       ),  //主输出从输入数据
    .tx_flag    (tx_flag    ),  //输出数据标志信号
    .tx_data    (tx_data    )   //输出数据

);

//-------------uart_tx_inst-------------
uart_tx
#(
    .UART_BPS    (UART_BPS ),         //串口波特率
    .CLK_FREQ    (CLK_FREQ )          //时钟频率
)
uart_tx_inst(
    .sys_clk     (sys_clk  ),   //系统时钟50Mhz
    .sys_rst_n   (sys_rst_n),   //全局复位
    .pi_data     (tx_data  ),   //并行数据
    .pi_flag     (tx_flag  ),   //并行数据有效标志信号
                                
    .tx          (tx       )    //串口发送数据
);

endmodule
