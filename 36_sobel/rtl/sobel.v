`timescale  1ns/1ns
////////////////////////////////////////////////////////////////////////
// Author        : EmbedFire
// Create Date   : 2019/03/18
// Module Name   : sobel
// Project Name  : sobel
// Target Devices: Altera EP4CE10F17C8N
// Tool Versions : Quartus 13.0
// Description   : sobel顶层模块
// 
// Revision      : V1.0
// Additional Comments:
// 
// 实验平台: 野火_征途Pro_FPGA开发板
// 公司    : http://www.embedfire.com
// 论坛    : http://www.firebbs.cn
// 淘宝    : https://fire-stm32.taobao.com
////////////////////////////////////////////////////////////////////////

module  sobel
(
    input   wire            sys_clk     ,   //系统时钟50Mhz
    input   wire            sys_rst_n   ,   //系统复位
    input   wire            rx          ,   //串口接收数据

    output  wire            tx          ,   //串口发送数据
    output  wire            hsync       ,   //输出行同步信号
    output  wire            vsync       ,   //输出场同步信号
    output  wire    [7:0]   rgb             //输出像素信息
);

//********************************************************************//
//****************** Parameter and Internal Signal *******************//
//********************************************************************//
//parameter define
parameter   UART_BPS    =   14'd9600        ,   //比特率
            CLK_FREQ    =   26'd50_000_000  ;   //时钟频率

//wire  define
wire            vga_clk ;
wire    [7:0]   pi_data ;
wire            pi_flag ;
wire    [7:0]   po_data ;
wire            po_flag ;
wire            locked  ;
wire            rst_n   ;
wire            clk_50m ;

//rst_n:VGA模块复位信号
assign  rst_n = (sys_rst_n & locked);

//********************************************************************//
//*************************** Instantiation **************************//
//********************************************************************//
//------------- clk_gen_inst -------------
clk_gen     clk_gen_inst
(
    .areset     (~sys_rst_n ),  //输入复位信号,高电平有效,1bit
    .inclk0     (sys_clk    ),  //输入50MHz晶振时钟,1bit

    .c0         (vga_clk    ),  //输出VGA工作时钟,频率25Mhz,1bit
    .c1         (clk_50m    ),  //输出串口工作时钟,频率50Mhz,1bit
    .locked     (locked     )   //输出pll locked信号,1bit
);

//------------- uart_rx_inst --------------
uart_rx
#(
    .UART_BPS    (UART_BPS),    //串口波特率
    .CLK_FREQ    (CLK_FREQ)     //时钟频率
)
uart_rx_inst
(
    .sys_clk    (clk_50m    ),  //系统时钟50Mhz
    .sys_rst_n  (rst_n      ),  //全局复位
    .rx         (rx         ),  //串口接收数据

    .po_data    (pi_data    ),  //串转并后的数据
    .po_flag    (pi_flag    )   //串转并后的数据有效标志信号
);

//------------- sobel_ctrl_inst --------------
sobel_ctrl  sobel_ctrl_inst
(
    .sys_clk    (clk_50m    ),  //输入系统时钟,频率50MHz
    .sys_rst_n  (rst_n      ),  //复位信号,低有效
    .pi_data    (pi_data    ),  //rx传入的数据信号
    .pi_flag    (pi_flag    ),  //rx传入的标志信号

    .po_data    (po_data    ),  //fifo加法运算后的信号
    .po_flag    (po_flag    )   //输出标志信号
);

//------------- vga_ctrl_inst -------------
vga     vga_inst
(
    .vga_clk    (vga_clk    ),  //输入工作时钟,频率50MHz
    .sys_clk    (clk_50m    ),  //输入工作时钟,频率25MHz
    .sys_rst_n  (rst_n      ),  //输入复位信号,低电平有效
    .pi_data    (po_data    ),  //输入数据
    .pi_flag    (po_flag    ),  //输入数据标志信号

    .hsync      (hsync      ),  //输出行同步信号
    .vsync      (vsync      ),  //输出场同步信号
    .rgb        (rgb        )   //输出像素信息
);

//------------- uart_tx_inst --------------
uart_tx
#(
    .UART_BPS    (UART_BPS),    //串口波特率
    .CLK_FREQ    (CLK_FREQ)     //时钟频率
)
uart_tx_inst
(
    .sys_clk    (clk_50m    ),  //系统时钟50Mhz
    .sys_rst_n  (rst_n      ),  //全局复位
    .pi_data    (po_data    ),  //并行数据
    .pi_flag    (po_flag    ),  //并行数据有效标志信号

    .tx         (tx         )   //串口发送数据
);

endmodule
