`timescale  1ns/1ns
////////////////////////////////////////////////////////////////////////
// Author        : EmbedFire
//Create Date    : 2019/09/05
// Module Name   : uart_sdram_hdmi_pic
// Project Name  : uart_sdram_hdmi_pic
// Target Devices: Altera EP4CE10F17C8N
// Tool Versions : Quartus 13.0
// Description   : uart_sdram_hdmi_pic顶层文件
//
// Revision      : V1.0
// Additional Comments:
// 
// 实验平台: 野火_征途Pro_FPGA开发板
// 公司    : http://www.embedfire.com
// 论坛    : http://www.firebbs.cn
// 淘宝    : https://fire-stm32.taobao.com
////////////////////////////////////////////////////////////////////////

module  uart_sdram_hdmi_pic
(
    input   wire            sys_clk     ,   //系统时钟,50MHz
    input   wire            sys_rst_n   ,   //复位信号
    input   wire            rx          ,   //串口接收

    output  wire            ddc_scl     ,
    output  wire            ddc_sda     ,
    output  wire            tmds_clk_p  ,
    output  wire            tmds_clk_n  ,   //HDMI时钟差分信号
    output  wire    [2:0]   tmds_data_p ,
    output  wire    [2:0]   tmds_data_n ,   //HDMI图像差分信号

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
parameter   H_PIXEL     =   24'd640 ;   //水平方向像素个数,用于设置SDRAM缓存大小
parameter   V_PIXEL     =   24'd480 ;   //垂直方向像素个数,用于设置SDRAM缓存大小
parameter   UART_BPS    =   20'd115200      ,   //比特率
            CLK_FREQ    =   26'd50_000_000  ;   //时钟频率

// wire define
//uart_rx
wire    [7:0]   rx_data         ;   //拼接后的8位图像数据
wire            rx_flag         ;   //数据标志信号
//vga_ctrl
wire            data_req        ;   //TFT数据请求信号
wire    [15:0]  data_in         ;   //TFT图像数据
wire    [15:0]  rgb_vga         ;   //VGA显示数据
wire            rgb_valid       ;   //VGA有效显示区域
wire            hsync           ;   //VGA行同步信号
wire            vsync           ;   //VGA场同步信号
//clk_gen
wire            clk_25m         ;
wire            clk_50m         ;
wire            clk_125m        ;
wire            clk_125m_shift  ;   //pll产生时钟
wire            locked          ;   //pll锁定信号
wire            rst_n           ;   //复位信号

//********************************************************************//
//***************************** Main Code ****************************//
//********************************************************************//

//rst_n:复位信号
assign  rst_n = sys_rst_n & locked;
assign  ddc_scl = 1'b1;
assign  ddc_sda = 1'b1;

//------------- clk_gen_inst -------------
clk_gen clk_gen_inst (
    .inclk0     (sys_clk        ),
    .areset     (~sys_rst_n     ),
    .c0         (clk_25m        ),
    .c1         (clk_50m        ),
    .c2         (clk_125m       ),
    .c3         (clk_125m_shift ),
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

//------------- vga_ctrl_inst -------------
vga_ctrl    vga_ctrl_inst
(
    .vga_clk     (clk_25m   ),   //输入工作时钟,频率25MHz
    .sys_rst_n   (rst_n     ),   //输入复位信号,低电平有效
    .pix_data    ({data_in[7:5],2'b0,data_in[4:2],3'b0,data_in[1:0],3'b0}),

    .rgb_valid   (rgb_valid ),   //VGA有效显示区域
    .pix_data_req(data_req  ),
    .hsync       (hsync     ),   //输出行同步信号
    .vsync       (vsync     ),   //输出场同步信号
    .rgb         (rgb_vga   )    //输出像素信息
);

//------------- hdmi_ctrl_inst -------------
hdmi_ctrl   hdmi_ctrl_inst
(
    .clk_1x      (clk_25m           ),   //输入系统时钟
    .clk_5x      (clk_125m          ),   //输入5倍系统时钟
    .sys_rst_n   (rst_n             ),   //复位信号,低有效
    .rgb_blue    ({rgb_vga[4:0],3'b0}   ),   //蓝色分量
    .rgb_green   ({rgb_vga[10:5],2'b0}  ),   //绿色分量
    .rgb_red     ({rgb_vga[15:11],3'b0} ),   //红色分量
    .hsync       (hsync             ),   //行同步信号
    .vsync       (vsync             ),   //场同步信号
    .de          (rgb_valid         ),   //使能信号
    .hdmi_clk_p  (tmds_clk_p        ),
    .hdmi_clk_n  (tmds_clk_n        ),   //时钟差分信号
    .hdmi_r_p    (tmds_data_p[2]    ),
    .hdmi_r_n    (tmds_data_n[2]    ),   //红色分量差分信号
    .hdmi_g_p    (tmds_data_p[1]    ),
    .hdmi_g_n    (tmds_data_n[1]    ),   //绿色分量差分信号
    .hdmi_b_p    (tmds_data_p[0]    ),
    .hdmi_b_n    (tmds_data_n[0]    )    //蓝色分量差分信号
);

//------------- sdram_top_inst -------------
sdram_top   sdram_top_inst
(
    .sys_clk            (clk_125m       ),  //sdram 控制器参考时钟
    .clk_out            (clk_125m_shift ),  //用于输出的相位偏移时钟
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
    .rd_fifo_rd_clk     (clk_25m         ),  //读端口FIFO: 读时钟
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