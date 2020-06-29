`timescale  1ns/1ns
////////////////////////////////////////////////////////////////////////
// Author        : EmbedFire
// Create Date   : 2019/03/20
// Module Name   : tft_colorbar
// Project Name  : tft_colorbar
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

module  tft_colorbar
(
    input   wire            sys_clk     ,   //输入工作时钟,频率50MHz
    input   wire            sys_rst_n   ,   //输入复位信号,低电平有效

    output  wire    [15:0]  rgb_tft     ,   //输出像素信息
    output  wire            hsync       ,   //输出行同步信号
    output  wire            vsync       ,   //输出场同步信号
    output  wire            tft_clk     ,   //输出TFT时钟信号
    output  wire            tft_de      ,   //输出TFT使能信号
    output  wire            tft_bl          //输出背光信号

);

//********************************************************************//
//****************** Parameter and Internal Signal *******************//
//********************************************************************//

//wire  define
wire            tft_clk_9m  ;   //TFT工作时钟,频率9MHz
wire            locked      ;   //PLL locked信号
wire            rst_n       ;   //TFT模块复位信号
wire    [10:0]   pix_x       ;   //TFT有效显示区域X轴坐标
wire    [10:0]   pix_y       ;   //TFT有效显示区域Y轴坐标
wire    [15:0]  pix_data    ;   //TFT像素点色彩信息

//rst_n:TFT模块复位信号
assign  rst_n = (sys_rst_n & locked);

//********************************************************************//
//*************************** Instantiation **************************//
//********************************************************************//

//------------- clk_gen_inst -------------
clk_gen clk_gen_inst
(
    .areset     (~sys_rst_n ),  //输入复位信号,高电平有效,1bit
    .inclk0     (sys_clk    ),  //输入50MHz晶振时钟,1bit
    .c0         (tft_clk_9m ),  //输出TFT工作时钟,频率9Mhz,1bit

    .locked     (locked     )   //输出pll locked信号,1bit
);

//------------- tft_ctrl_inst -------------
tft_ctrl    tft_ctrl_inst
(
    .tft_clk_9m  (tft_clk_9m),   //输入时钟,频率9MHz
    .sys_rst_n   (rst_n     ),   //系统复位,低电平有效
    .pix_data    (pix_data  ),   //待显示数据

    .pix_x       (pix_x     ),   //输出TFT有效显示区域像素点X轴坐标
    .pix_y       (pix_y     ),   //输出TFT有效显示区域像素点Y轴坐标
    .rgb_tft     (rgb_tft   ),   //TFT显示数据
    .hsync       (hsync     ),   //TFT行同步信号
    .vsync       (vsync     ),   //TFT场同步信号
    .tft_clk     (tft_clk   ),   //TFT像素时钟
    .tft_de      (tft_de    ),   //TFT数据使能
    .tft_bl      (tft_bl    )    //TFT背光信号

);

//------------- tft_pic_inst -------------

tft_pic tft_pic_inst
(
    .tft_clk_9m  (tft_clk_9m),   //输入工作时钟,频率9MHz
    .sys_rst_n   (rst_n     ),   //输入复位信号,低电平有效
    .pix_x       (pix_x     ),   //输入TFT有效显示区域像素点X轴坐标
    .pix_y       (pix_y     ),   //输入TFT有效显示区域像素点Y轴坐标

    .pix_data    (pix_data  )    //输出像素点色彩信息

);

endmodule