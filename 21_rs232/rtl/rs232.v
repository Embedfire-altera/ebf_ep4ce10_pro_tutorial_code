`timescale  1ns/1ns
////////////////////////////////////////////////////////////////////////
// Author        : EmbedFire
// Create Date   : 2019/06/12
// Module Name   : rs232
// Project Name  : rs232
// Target Devices: Altera EP4CE10F17C8N
// Tool Versions : Quartus 13.0
// Description   : RS232顶层模块
//
// Revision      : V1.0
// Additional Comments:
// 
// 实验平台: 野火_征途Pro_FPGA开发板
// 公司    : http://www.embedfire.com
// 论坛    : http://www.firebbs.cn
// 淘宝    : https://fire-stm32.taobao.com
////////////////////////////////////////////////////////////////////////

module  rs232
(
    input   wire    sys_clk     ,   //系统时钟50MHz
    input   wire    sys_rst_n   ,   //全局复位
    input   wire    rx          ,   //串口接收数据

    output  wire    tx              //串口发送数据
);

//********************************************************************//
//****************** Parameter and Internal Signal *******************//
//********************************************************************//
//parameter define
parameter   UART_BPS    =   14'd9600        ,   //比特率
            CLK_FREQ    =   26'd50_000_000  ;   //时钟频率

//wire  define
wire    [7:0]   po_data;
wire            po_flag;

//********************************************************************//
//*************************** Instantiation **************************//
//********************************************************************//
//------------------------ uart_rx_inst ------------------------
uart_rx
#(
    .UART_BPS    (UART_BPS  ),  //串口波特率
    .CLK_FREQ    (CLK_FREQ  )   //时钟频率
)
uart_rx_inst
(
    .sys_clk    (sys_clk    ),  //input             sys_clk
    .sys_rst_n  (sys_rst_n  ),  //input             sys_rst_n
    .rx         (rx         ),  //input             rx
            
    .po_data    (po_data    ),  //output    [7:0]   po_data
    .po_flag    (po_flag    )   //output            po_flag
);

//------------------------ uart_tx_inst ------------------------
uart_tx
#(
    .UART_BPS    (UART_BPS  ),  //串口波特率
    .CLK_FREQ    (CLK_FREQ  )   //时钟频率
)
uart_tx_inst
(
    .sys_clk    (sys_clk    ),  //input             sys_clk
    .sys_rst_n  (sys_rst_n  ),  //input             sys_rst_n
    .pi_data    (po_data    ),  //input     [7:0]   pi_data
    .pi_flag    (po_flag    ),  //input             pi_flag
                
    .tx         (tx         )   //output            tx
);

endmodule
