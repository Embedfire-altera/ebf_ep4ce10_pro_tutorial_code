`timescale  1ns/1ns
////////////////////////////////////////////////////////////////////////
// Author        : EmbedFire
//Create Date    : 2019/09/03
// Module Name   : uart_sd
// Project Name  : uart_sd
// Target Devices: Altera EP4CE10F17C8N
// Tool Versions : Quartus 13.0
// Description   : 串口读写SD卡顶层模块
//
// Revision      : V1.0
// Additional Comments:
// 
// 实验平台: 野火_征途Pro_FPGA开发板
// 公司    : http://www.embedfire.com
// 论坛    : http://www.firebbs.cn
// 淘宝    : https://fire-stm32.taobao.com
////////////////////////////////////////////////////////////////////////

module  uart_sd
(
    input   wire            sys_clk     ,   //输入工作时钟,频率50MHz
    input   wire            sys_rst_n   ,   //输入复位信号,低电平有效
    input   wire            rx          ,   //串口发送数据
    input   wire            sd_miso     ,   //主输入从输出信号

    output  wire            sd_clk      ,   //SD卡时钟信号
    output  wire            sd_cs_n     ,   //片选信号
    output  wire            sd_mosi     ,   //主输出从输入信号
    output  wire            tx              //串口接收数据
);

//********************************************************************//
//****************** Parameter and Internal Signal *******************//
//********************************************************************//
//parameter define
parameter   UART_BPS    =   14'd9600        ,   //比特率
            CLK_FREQ    =   26'd50_000_000  ;   //时钟频率

//wire  define
wire            rx_flag         ;   //写fifo写入数据标志信号
wire    [7:0]   rx_data         ;   //写fifo写入数据
wire            wr_req          ;   //sd卡数据写请求
wire            wr_busy         ;   //sd卡写数据忙信号
wire            wr_en           ;   //sd卡数据写使能信号
wire    [31:0]  wr_addr         ;   //sd卡写数据扇区地址
wire    [15:0]  wr_data         ;   //sd卡写数据
wire            rd_data_en      ;   //sd卡读出数据标志信号
wire    [15:0]  rd_data         ;   //sd卡读出数据
wire            rd_busy         ;   //sd卡读数据忙信号
wire            rd_en           ;   //sd卡数据读使能信号
wire    [31:0]  rd_addr         ;   //sd卡读数据扇区地址
wire            tx_flag         ;   //读fifo读出数据标志信号
wire    [7:0]   tx_data         ;   //读fifo读出数据
wire            clk_50m         ;   //生成50MHz时钟
wire            clk_50m_shift   ;   //生成50MHz时钟,相位偏移180度
wire            locked          ;   //时钟锁定信号
wire            rst_n           ;   //复位信号
wire            init_end        ;   //SD卡初始化完成信号

//rst_n:复位信号,低有效
assign  rst_n = sys_rst_n && locked;

//********************************************************************//
//************************** Instantiation ***************************//
//********************************************************************//
//------------- clk_gen_inst -------------
clk_gen clk_gen_inst
(
    .areset     (~sys_rst_n     ),  //复位信号,高有效
    .inclk0     (sys_clk        ),  //输入系统时钟,50MHz

    .c0         (clk_50m        ),  //生成50MHz时钟
    .c1         (clk_50m_shift  ),  //生成50MHz时钟,相位偏移180度
    .locked     (locked         )   //时钟锁定信号
    );

//------------- uart_rx_inst -------------
uart_rx
#(
    .UART_BPS    (UART_BPS  ),   //串口波特率
    .CLK_FREQ    (CLK_FREQ  )    //时钟频率
)
uart_rx_inst
(
    .sys_clk     (clk_50m   ),   //系统时钟50Mhz
    .sys_rst_n   (rst_n     ),   //全局复位
    .rx          (rx        ),   //串口接收数据

    .po_data     (rx_data   ),   //串转并后的数据
    .po_flag     (rx_flag   )    //串转并后的数据有效标志信号
);

//------------- data_rw_ctrl_inst -------------
data_rw_ctrl    data_rw_ctrl_inst
(
    .sys_clk     (clk_50m   ),  //输入工作时钟,频率50MHz
    .sys_rst_n   (rst_n     ),  //输入复位信号,低电平有效
    .init_end    (init_end  ),  //SD卡初始化完成信号

    .rx_flag     (rx_flag   ),  //写fifo写入数据标志信号
    .rx_data     (rx_data   ),  //写fifo写入数据
    .wr_req      (wr_req    ),  //sd卡数据写请求
    .wr_busy     (wr_busy   ),  //sd卡写数据忙信号

    .wr_en       (wr_en     ),  //sd卡数据写使能信号
    .wr_addr     (wr_addr   ),  //sd卡写数据扇区地址
    .wr_data     (wr_data   ),  //sd卡写数据

    .rd_data_en  (rd_data_en),  //sd卡读出数据标志信号
    .rd_data     (rd_data   ),  //sd卡读出数据
    .rd_busy     (rd_busy   ),  //sd卡读数据忙信号
    .rd_en       (rd_en     ),  //sd卡数据读使能信号
    .rd_addr     (rd_addr   ),  //sd卡读数据扇区地址
    .tx_flag     (tx_flag   ),  //读fifo读出数据标志信号
    .tx_data     (tx_data   )   //读fifo读出数据
);

//------------- sd_ctrl_inst -------------
sd_ctrl sd_ctrl_inst
(
    .sys_clk         (clk_50m       ),  //输入工作时钟,频率50MHz
    .sys_clk_shift   (clk_50m_shift ),  //输入工作时钟,频率50MHz,相位偏移180度
    .sys_rst_n       (rst_n         ),  //输入复位信号,低电平有效

    .sd_miso         (sd_miso       ),  //主输入从输出信号
    .sd_clk          (sd_clk        ),  //SD卡时钟信号
    .sd_cs_n         (sd_cs_n       ),  //片选信号
    .sd_mosi         (sd_mosi       ),  //主输出从输入信号

    .wr_en           (wr_en         ),  //数据写使能信号
    .wr_addr         (wr_addr       ),  //写数据扇区地址
    .wr_data         (wr_data       ),  //写数据
    .wr_busy         (wr_busy       ),  //写操作忙信号
    .wr_req          (wr_req        ),  //写数据请求信号

    .rd_en           (rd_en         ),  //数据读使能信号
    .rd_addr         (rd_addr       ),  //读数据扇区地址
    .rd_busy         (rd_busy       ),  //读操作忙信号
    .rd_data_en      (rd_data_en    ),  //读数据标志信号
    .rd_data         (rd_data       ),  //读数据

    .init_end        (init_end      )   //SD卡初始化完成信号
);

//------------- uart_tx_inst -------------
uart_tx
#(
    .UART_BPS    (UART_BPS  ),   //串口波特率
    .CLK_FREQ    (CLK_FREQ  )    //时钟频率
)
uart_tx_inst
(
    .sys_clk     (clk_50m   ),   //系统时钟50Mhz
    .sys_rst_n   (rst_n     ),   //全局复位
    .pi_data     (tx_data   ),   //并行数据
    .pi_flag     (tx_flag   ),   //并行数据有效标志信号

    .tx          (tx        )    //串口发送数据
);

endmodule