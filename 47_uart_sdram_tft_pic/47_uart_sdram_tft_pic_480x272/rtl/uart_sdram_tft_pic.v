`timescale  1ns/1ns
////////////////////////////////////////////////////////////////////////
// Author        : EmbedFire
// Create Date   : 2019/09/20
// Module Name   : uart_sdram_tft_pic
// Project Name  : uart_sdram_tft_pic
// Target Devices: Altera EP4CE10F17C8N
// Tool Versions : Quartus 13.0
// Description   : uart_sdram_tft_pic顶层文件
// 
// Revision      : V1.0
// Additional Comments:
// 
// 实验平台: 野火_征途Pro_FPGA开发板
// 公司    : http://www.embedfire.com
// 论坛    : http://www.firebbs.cn
// 淘宝    : https://fire-stm32.taobao.com
////////////////////////////////////////////////////////////////////////

module  uart_sdram_tft_pic
(
    input   wire            sys_clk     ,   //系统时钟,50MHz
    input   wire            sys_rst_n   ,   //复位信号
    input   wire            rx          ,   //串口接收

    output  wire    [15:0]  rgb_tft     ,   //TFT显示数据
    output  wire            hsync       ,   //TFT行同步信号
    output  wire            vsync       ,   //TFT场同步信号
    output  wire            tft_clk     ,   //TFT像素时钟
    output  wire            tft_de      ,   //TFT数据使能
    output  wire            tft_bl      ,   //TFT背光信号

    output  wire            sdram_clk   ,   //SDRAM时钟
    output  wire            sdram_cke   ,   //SDRAM时钟使能
    output  wire            sdram_cs_n  ,   //SDRAM片选
    output  wire            sdram_cas_n ,   //SDRAM列选通
    output  wire            sdram_ras_n ,   //SDRAM行选通
    output  wire            sdram_we_n  ,   //SDRAM写使能
    output  wire    [1:0]   sdram_ba    ,   //SDRAM Bank地址
    output  wire    [12:0]  sdram_addr  ,   //SDRAM地址总线
    output  wire    [1:0]   sdram_dqm   ,   //SDRAM数据掩码
    inout   wire    [15:0]  sdram_dq        //SDRAM数据总线
);

//********************************************************************//
//****************** Parameter and Internal Signal *******************//
//********************************************************************//
//parameter define
parameter   H_PIXEL     =   24'd480 ;   //水平方向像素个数,用于设置SDRAM缓存大小
parameter   V_PIXEL     =   24'd272 ;   //垂直方向像素个数,用于设置SDRAM缓存大小
parameter   UART_BPS    =   20'd115200      ,   //比特率
            CLK_FREQ    =   26'd50_000_000  ;   //时钟频率

// wire define
//uart_rx
wire    [7:0]   rx_data         ;   //拼接后的8位图像数据
wire            rx_flag         ;   //数据标志信号
//vga_ctrl
wire            data_req        ;   //TFT数据请求信号
wire    [15:0]  data_in         ;   //TFT图像数据

//clk_gen
wire            clk_9m          ;
wire            clk_50m         ;
wire            clk_100m        ;
wire            clk_100m_shift  ;   //pll产生时钟
wire            locked          ;   //pll锁定信号
wire            rst_n           ;   //复位信号

//********************************************************************//
//***************************** Main Code ****************************//
//********************************************************************//

//rst_n:复位信号
assign  rst_n = sys_rst_n & locked;

//------------- clk_gen_inst -------------
clk_gen clk_gen_inst (
    .inclk0     (sys_clk        ),
    .areset     (~sys_rst_n     ),
    .c0         (clk_9m         ),
    .c1         (clk_50m        ),
    .c2         (clk_100m       ),
    .c3         (clk_100m_shift ),
    .locked     (locked         )
);

//------------- uart_rx_inst -------------
uart_rx
#(
    .UART_BPS    (UART_BPS ),   //串口波特率
    .CLK_FREQ    (CLK_FREQ )    //时钟频率
)
uart_rx_inst
(
    .sys_clk     (clk_50m  ),   //input             sys_clk
    .sys_rst_n   (rst_n    ),   //input             sys_rst_n
    .rx          (rx       ),   //input             rx

    .po_data     (rx_data  ),   //output    [7:0]   rx_data
    .po_flag     (rx_flag  )    //output            rx_flag
);

//------------- tft_ctrl_inst -------------
tft_ctrl    tft_ctrl_inst(
    .tft_clk_9m  (clk_9m        ),   //输入时钟,频率9MHz
    .sys_rst_n   (rst_n         ),   //系统复位,低电平有效
    .pix_data    ({data_in[7:5],2'b0,data_in[4:2],3'b0,data_in[1:0],3'b0}  ),   //待显示数据

    .pix_data_req(data_req      ),   //TFT图像数据
    .rgb_tft     (rgb_tft       ),   //TFT显示数据
    .hsync       (hsync         ),   //TFT行同步信号
    .vsync       (vsync         ),   //TFT场同步信号
    .tft_clk     (tft_clk       ),   //TFT像素时钟
    .tft_de      (tft_de        ),   //TFT数据使能
    .tft_bl      (tft_bl        )    //TFT背光信号

);

//------------- sdram_top_inst -------------
sdram_top   sdram_top_inst
(
    .sys_clk            (clk_100m       ),  //sdram 控制器参考时钟
    .clk_out            (clk_100m_shift ),  //用于输出的相位偏移时钟
    .sys_rst_n          (rst_n          ),  //系统复位
//用户写端口
    .wr_fifo_wr_clk     (clk_50m        ),  //写端口FIFO: 写时钟
    .wr_fifo_wr_req     (rx_flag        ),  //写端口FIFO: 写使能
    .wr_fifo_wr_data    ({8'b0,rx_data} ),  //写端口FIFO: 写数据
    .sdram_wr_b_addr    (24'd0          ),  //写SDRAM的起始地址
    .sdram_wr_e_addr    (H_PIXEL*V_PIXEL),  //写SDRAM的结束地址
    .wr_burst_len       (10'd512        ),  //写SDRAM时的数据突发长度
    .wr_rst             (~rst_n         ),  //写复位
//用户读端口
    .rd_fifo_rd_clk     (clk_9m         ),  //读端口FIFO: 读时钟
    .rd_fifo_rd_req     (data_req       ),  //读端口FIFO: 读使能
    .rd_fifo_rd_data    (data_in        ),  //读端口FIFO: 读数据
    .sdram_rd_b_addr    (24'd0          ),  //读SDRAM的起始地址
    .sdram_rd_e_addr    (H_PIXEL*V_PIXEL),  //读SDRAM的结束地址
    .rd_burst_len       (10'd512        ),  //从SDRAM中读数据时的突发长度
    .rd_rst             (               ),  //读复位
    .rd_fifo_num        (               ),  //读fifo中的数据量
//用户控制端口
    .read_valid         (1'b1           ),  //SDRAM 读使能
    .init_end           (               ),  //SDRAM 初始化完成标志
//SDRAM 芯片接口
    .sdram_clk          (sdram_clk      ),  //SDRAM 芯片时钟
    .sdram_cke          (sdram_cke      ),  //SDRAM 时钟有效
    .sdram_cs_n         (sdram_cs_n     ),  //SDRAM 片选
    .sdram_ras_n        (sdram_ras_n    ),  //SDRAM 行有效
    .sdram_cas_n        (sdram_cas_n    ),  //SDRAM 列有效
    .sdram_we_n         (sdram_we_n     ),  //SDRAM 写有效
    .sdram_ba           (sdram_ba       ),  //SDRAM Bank地址
    .sdram_addr         (sdram_addr     ),  //SDRAM 行/列地址
    .sdram_dq           (sdram_dq       ),  //SDRAM 数据
    .sdram_dqm          (sdram_dqm      )   //SDRAM 数据掩码
);

endmodule