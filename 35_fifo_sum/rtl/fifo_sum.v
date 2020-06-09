`timescale  1ns/1ns
////////////////////////////////////////////////////////////////////////
// Author        : EmbedFire
// Create Date   : 2018/03/18
// Module Name   : fifo_sum
// Project Name  : fifo_sum
// Target Devices: Altera EP4CE10F17C8N
// Tool Versions : Quartus 13.0
// Description   : SUM求和模块
// 
// Revision      : V1.0
// Additional Comments:
// 
// 实验平台: 野火_征途Pro_FPGA开发板
// 公司    : http://www.embedfire.com
// 论坛    : http://www.firebbs.cn
// 淘宝    : https://fire-stm32.taobao.com
////////////////////////////////////////////////////////////////////////

module  fifo_sum
(
    input     wire    sys_clk       ,   //输入系统时钟,50MHz
    input     wire    sys_rst_n     ,   //复位信号,低电平有效
    input     wire    rx            ,   //串口数据接收

    output    wire    tx                //串口数据发送
);

//********************************************************************//
//****************** Parameter and Internal Signal *******************//
//********************************************************************//
//parameter define
parameter   UART_BPS    =   14'd9600        ,   //比特率
            CLK_FREQ    =   26'd50_000_000  ;   //时钟频率

//wire define
wire    [7:0]   pi_data ;   //输入待求和数据
wire            pi_flag ;   //输入数据标志信号
wire    [7:0]   po_sum  ;   //输出求和后数据
wire            po_flag ;   //输出数据标志信号

//********************************************************************//
//*************************** Instantiation **************************//
//********************************************************************//

//------------- uart_rx_inst --------------
uart_rx
#(
    .UART_BPS    (UART_BPS  ),  //串口波特率
    .CLK_FREQ    (CLK_FREQ  )   //时钟频率
)
uart_rx_inst
(
    .sys_clk    (sys_clk    ),  //系统时钟50Mhz
    .sys_rst_n  (sys_rst_n  ),  //全局复位
    .rx         (rx         ),  //串口接收数据

    .po_data    (pi_data    ),  //串转并后的数据
    .po_flag    (pi_flag    )   //串转并后的数据有效标志信号
);

//------------- fifo_sum_ctrl_inst --------------
fifo_sum_ctrl  fifo_sum_ctrl_inst
(
    .sys_clk    (sys_clk    ),  //频率为50MHz
    .sys_rst_n  (sys_rst_n  ),  //复位信号,低有效
    .pi_data    (pi_data    ),  //rx传入的数据信号
    .pi_flag    (pi_flag    ),  //rx传入的标志信号

    .po_sum     (po_sum     ),  //求和运算后的信号
    .po_flag    (po_flag    )   //输出数据标志信号
);

//------------- uart_tx_inst --------------
uart_tx
#(
    .UART_BPS    (UART_BPS  ),  //串口波特率
    .CLK_FREQ    (CLK_FREQ  )   //时钟频率
)
uart_tx_inst
(
    .sys_clk    (sys_clk    ),  //系统时钟50Mhz
    .sys_rst_n  (sys_rst_n  ),  //全局复位
    .pi_data    (po_sum     ),  //并行数据
    .pi_flag    (po_flag    ),  //并行数据有效标志信号

    .tx         (tx         )   //串口发送数据
);

endmodule