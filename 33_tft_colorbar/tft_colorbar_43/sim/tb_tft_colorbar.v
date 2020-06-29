`timescale  1ns/1ns
////////////////////////////////////////////////////////////////////////
// Author        : EmbedFire
// Create Date   : 2019/03/20
// Module Name   : tb_tft_colorbar
// Project Name  : tft_colorbar
// Target Devices: Altera EP4CE10F17C8N
// Tool Versions : Quartus 13.0
// Description   : 顶层模块仿真文件
// 
// Revision      : V1.0
// Additional Comments:
// 
// 实验平台: 野火_征途Pro_FPGA开发板
// 公司    : http://www.embedfire.com
// 论坛    : http://www.firebbs.cn
// 淘宝    : https://fire-stm32.taobao.com
////////////////////////////////////////////////////////////////////////

module  tb_tft_colorbar();
//********************************************************************//
//****************** Parameter and Internal Signal *******************//
//********************************************************************//
//wire  define
wire            hsync   ;
wire    [15:0]  rgb_tft ;
wire            vsync   ;
wire            tft_clk ;
wire            tft_de  ;
wire            tft_bl  ;

//reg   define
reg             sys_clk     ;
reg             sys_rst_n   ;

//********************************************************************//
//**************************** Clk And Rst ***************************//
//********************************************************************//

//sys_clk,rst_n初始赋值
initial
    begin
        sys_clk     =   1'b1;
        sys_rst_n   <=  1'b0;
        #200
        sys_rst_n   <=  1'b1;
    end

//clk：产生时钟
always  #10 sys_clk = ~sys_clk  ;

//********************************************************************//
//*************************** Instantiation **************************//
//********************************************************************//

//------------- tft_colorbar_inst -------------
tft_colorbar    tft_colorbar_inst
(
    .sys_clk     (sys_clk   ),   //输入工作时钟,频率50MHz
    .sys_rst_n   (sys_rst_n ),   //输入复位信号,低电平有效

    .rgb_tft     (rgb_tft   ),   //输出像素信息
    .hsync       (hsync     ),   //输出行同步信号
    .vsync       (vsync     ),   //输出场同步信号
    .tft_clk     (tft_clk   ),   //输出TFT时钟信号
    .tft_de      (tft_de    ),   //输出TFT使能信号
    .tft_bl      (tft_bl    )    //输出背光信号

);

endmodule

