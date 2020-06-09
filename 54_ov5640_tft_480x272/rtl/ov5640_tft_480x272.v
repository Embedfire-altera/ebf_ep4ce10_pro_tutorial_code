`timescale  1ns/1ns
////////////////////////////////////////////////////////////////////////
// Author        : EmbedFire
// Create Date   : 2019/11/01
// Module Name   : ov5640_tft_480x272
// Project Name  : ov5640_tft_480x272
// Target Devices: Altera EP4CE10F17C8N
// Tool Versions : Quartus 13.0
// Description   : 顶层模块
// 
// Revision      : V1.0
// Additional Comments:
// 
// 实验平台: 野火_征途Pro_FPGA开发板
// 公司    : http://www.embedfire.com
// 论坛    : http://www.firebbs.cn
// 淘宝    : https://fire-stm32.taobao.com
////////////////////////////////////////////////////////////////////////

module  ov5640_tft_480x272
(
    input   wire            sys_clk     ,  //系统时钟
    input   wire            sys_rst_n   ,  //系统复位，低电平有效
//摄像头接口
    input   wire            ov5640_pclk ,  //摄像头数据像素时钟
    input   wire            ov5640_vsync,  //摄像头场同步信号
    input   wire            ov5640_href ,  //摄像头行同步信号
    input   wire    [7:0]   ov5640_data ,  //摄像头数据
    output  wire            ov5640_rst_n,  //摄像头复位信号，低电平有效
    output  wire            ov5640_pwdn ,  //摄像头时钟选择信号, 1:使用摄像头自带的晶振
    output  wire            sccb_scl    ,  //摄像头SCCB_SCL线
    inout   wire            sccb_sda    ,  //摄像头SCCB_SDA线
//SDRAM接口
    output  wire            sdram_clk   ,  //SDRAM 时钟
    output  wire            sdram_cke   ,  //SDRAM 时钟使能
    output  wire            sdram_cs_n  ,  //SDRAM 片选
    output  wire            sdram_ras_n ,  //SDRAM 行有效
    output  wire            sdram_cas_n ,  //SDRAM 列有效
    output  wire            sdram_we_n  ,  //SDRAM 写有效
    output  wire    [1:0]   sdram_ba    ,  //SDRAM Bank地址
    output  wire    [1:0]   sdram_dqm   ,  //SDRAM 数据掩码
    output  wire    [12:0]  sdram_addr  ,  //SDRAM 地址
    inout   wire    [15:0]  sdram_dq    ,  //SDRAM 数据
//VGA接口
    output  wire            tft_clk     ,
    output  wire            tft_de      ,
    output  wire            tft_bl      ,
    output  wire            tft_hs      ,  //行同步信号
    output  wire            tft_vs      ,  //场同步信号
    output  wire    [15:0]  tft_rgb        //红绿蓝三原色输出 
);

//********************************************************************//
//****************** Parameter and Internal Signal *******************//
//********************************************************************//

//parameter define
parameter   H_PIXEL     =   24'd480 ;   //水平方向像素个数,用于设置SDRAM缓存大小
parameter   V_PIXEL     =   24'd272 ;   //垂直方向像素个数,用于设置SDRAM缓存大小

//wire  define
wire            clk_100m        ;   //100mhz时钟,SDRAM操作时钟
wire            clk_100m_shift  ;   //100mhz时钟,SDRAM相位偏移时钟
wire            clk_9m          ;   //9mhz时钟,提供给tft驱动时钟
wire            locked          ;   //PLL锁定信号
wire            rst_n           ;   //复位信号(sys_rst_n & locked)
wire            cfg_done        ;   //摄像头初始化完成
wire            wr_en           ;   //sdram写使能
wire   [15:0]   wr_data         ;   //sdram写数据
wire            rd_en           ;   //sdram读使能
wire   [15:0]   rd_data         ;   //sdram读数据
wire            sdram_init_done ;   //SDRAM初始化完成
wire            sys_init_done   ;   //系统初始化完成(SDRAM初始化+摄像头初始化)

//********************************************************************//
//***************************** Main Code ****************************//
//********************************************************************//

//rst_n:复位信号(sys_rst_n & locked)
assign  rst_n = sys_rst_n & locked;

//sys_init_done:系统初始化完成(SDRAM初始化+摄像头初始化)
assign  sys_init_done = sdram_init_done & cfg_done;

//ov5640_rst_n:摄像头复位,固定高电平
assign  ov5640_rst_n = 1'b1;

//ov5640_pwdn
assign  ov5640_pwdn = 1'b0;

//------------- clk_gen_inst -------------
clk_gen clk_gen_inst(

    .areset     (~sys_rst_n     ),
    .inclk0     (sys_clk        ),
    .c0         (clk_100m       ),
    .c1         (clk_100m_shift ),
    .c2         (clk_9m        ),
    .locked     (locked         )

);

//------------- ov5640_top_inst -------------
ov5640_top  ov5640_top_inst(

    .sys_clk         (clk_9m        ),   //系统时钟
    .sys_rst_n       (rst_n         ),   //复位信号
    .sys_init_done   (sys_init_done ),   //系统初始化完成(SDRAM + 摄像头)

    .ov5640_pclk     (ov5640_pclk   ),   //摄像头像素时钟
    .ov5640_href     (ov5640_href   ),   //摄像头行同步信号
    .ov5640_vsync    (ov5640_vsync  ),   //摄像头场同步信号
    .ov5640_data     (ov5640_data   ),   //摄像头图像数据

    .cfg_done        (cfg_done      ),   //寄存器配置完成
    .sccb_scl        (sccb_scl      ),   //SCL
    .sccb_sda        (sccb_sda      ),   //SDA
    .ov5640_wr_en    (wr_en         ),   //图像数据有效使能信号
    .ov5640_data_out (wr_data       )    //图像数据

);

//------------- sdram_top_inst -------------
sdram_top   sdram_top_inst(

    .sys_clk            (clk_100m       ),  //sdram 控制器参考时钟
    .clk_out            (clk_100m_shift ),  //用于输出的相位偏移时钟
    .sys_rst_n          (rst_n          ),  //系统复位
//用户写端口
    .wr_fifo_wr_clk     (ov5640_pclk    ),  //写端口FIFO: 写时钟
    .wr_fifo_wr_req     (wr_en          ),  //写端口FIFO: 写使能
    .wr_fifo_wr_data    (wr_data        ),  //写端口FIFO: 写数据
    .sdram_wr_b_addr    (24'd0          ),  //写SDRAM的起始地址
    .sdram_wr_e_addr    (H_PIXEL*V_PIXEL),  //写SDRAM的结束地址
    .wr_burst_len       (10'd512        ),  //写SDRAM时的数据突发长度
    .wr_rst             (~rst_n         ),  //写端口复位: 复位写地址,清空写FIFO
//用户读端口
    .rd_fifo_rd_clk     (clk_9m        ),  //读端口FIFO: 读时钟
    .rd_fifo_rd_req     (rd_en          ),  //读端口FIFO: 读使能
    .rd_fifo_rd_data    (rd_data        ),  //读端口FIFO: 读数据
    .sdram_rd_b_addr    (24'd0          ),  //读SDRAM的起始地址
    .sdram_rd_e_addr    (H_PIXEL*V_PIXEL),  //读SDRAM的结束地址
    .rd_burst_len       (10'd512        ),  //从SDRAM中读数据时的突发长度
    .rd_rst             (~rst_n         ),  //读端口复位: 复位读地址,清空读FIFO
//用户控制端口
    .read_valid         (1'b1           ),  //SDRAM 读使能
    .pingpang_en        (1'b1           ),  //SDRAM 乒乓操作使能
    .init_end           (sdram_init_done),  //SDRAM 初始化完成标志
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

//------------- tft_ctrl_inst -------------
tft_ctrl  tft_ctrl_inst(
    .clk_9m      (clk_9m    ),   //输入时钟,频率9MHz
    .sys_rst_n   (rst_n     ),   //系统复位,低电平有效
    .data_in     (rd_data   ),   //待显示数据

    .data_req    (rd_en     ),
    .rgb_tft     (tft_rgb   ),   //TFT显示数据
    .hsync       (tft_hs    ),   //TFT行同步信号
    .vsync       (tft_vs    ),   //TFT场同步信号
    .tft_clk     (tft_clk   ),   //TFT像素时钟
    .tft_de      (tft_de    ),   //TFT数据使能
    .tft_bl      (tft_bl    )    //TFT背光信号

);

endmodule