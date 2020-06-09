`timescale  1ns/1ns
////////////////////////////////////////////////////////////////////////
// Author        : EmbedFire
// Create Date   : 2018/03/27
// Module Name   : spi_flash_seq_wr
// Project Name  : spi_flash_seq_wr
// Target Devices: Altera EP4CE10F17C8N
// Tool Versions : Quartus 13.0
// Description   : spi_flash_seq_wr顶层模块
// 
// Revision      : V1.0
// Additional Comments:
// 
// 实验平台: 野火_征途Pro_FPGA开发板
// 公司    : http://www.embedfire.com
// 论坛    : http://www.firebbs.cn
// 淘宝    : https://fire-stm32.taobao.com
////////////////////////////////////////////////////////////////////////

module  spi_flash_seq_wr(

    input   wire    sys_clk     ,   //系统时钟，频率50MHz
    input   wire    sys_rst_n   ,   //复位信号,低电平有效
    input   wire    rx          ,   //串口接收数据

    output  wire    cs_n        ,   //片选信号
    output  wire    sck         ,   //串行时钟
    output  wire    mosi        ,   //主输出从输入数据
    output  wire    tx              //串口发送数据

);

//********************************************************************//
//****************** Parameter and Internal Signal *******************//
//********************************************************************//
//parameter define
parameter   UART_BPS    =   14'd9600        ,   //比特率
            CLK_FREQ    =   26'd50_000_000  ;   //时钟频率

//wire  define
wire            po_flag ;
wire    [7:0]   po_data ;

//********************************************************************//
//*************************** Instantiation **************************//
//********************************************************************//

//-------------uart_rx_inst-------------
uart_rx
#(
    .UART_BPS    (UART_BPS ),         //串口波特率
    .CLK_FREQ    (CLK_FREQ )          //时钟频率
)
uart_rx_inst(
    .sys_clk     (sys_clk  ),   //系统时钟50Mhz
    .sys_rst_n   (sys_rst_n),   //全局复位
    .rx          (rx       ),   //串口接收数据

    .po_data     (po_data  ),   //串转并后的数据
    .po_flag     (po_flag  )    //串转并后的数据有效标志信号
);

//-------------flash_seq_wr_ctrl_inst-------------
flash_seq_wr_ctrl  flash_seq_wr_ctrl_inst(

    .sys_clk    (sys_clk    ),  //系统时钟，频率50MHz
    .sys_rst_n  (sys_rst_n  ),  //复位信号,低电平有效
    .pi_flag    (po_flag    ),  //数据标志信号
    .pi_data    (po_data    ),  //写入数据

    .sck        (sck        ),  //片选信号
    .cs_n       (cs_n       ),  //串行时钟
    .mosi       (mosi       )   //主输出从输入数据

);

//-------------uart_tx_inst-------------
uart_tx
#(
    .UART_BPS    (UART_BPS ),         //串口波特率
    .CLK_FREQ    (CLK_FREQ )          //时钟频率
)
uart_tx_inst
(
    .sys_clk     (sys_clk  ),   //系统时钟50Mhz
    .sys_rst_n   (sys_rst_n),   //全局复位
    .pi_data     (po_data  ),   //并行数据
    .pi_flag     (po_flag  ),   //并行数据有效标志信号

    .tx          (tx       )    //串口发送数据
);

endmodule
