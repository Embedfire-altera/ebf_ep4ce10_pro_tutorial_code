`timescale  1ns/1ns
////////////////////////////////////////////////////////////////////////
// Author        : EmbedFire
// Create Date   : 2019/03/18
// Module Name   : vga
// Project Name  : sobel
// Target Devices: Altera EP4CE10F17C8N
// Tool Versions : Quartus 13.0
// Description   : vga显示顶层模块
// 
// Revision      : V1.0
// Additional Comments:
// 
// 实验平台: 野火_征途Pro_FPGA开发板
// 公司    : http://www.embedfire.com
// 论坛    : http://www.firebbs.cn
// 淘宝    : https://fire-stm32.taobao.com
////////////////////////////////////////////////////////////////////////

module  vga
(
    input   wire            sys_clk     ,   //输入工作时钟,频率50MHz
    input   wire            vga_clk     ,   //输入工作时钟,频率25MHz
    input   wire            sys_rst_n   ,   //输入复位信号,低电平有效
    input   wire            pi_flag     ,   //输入数据标志信号
    input   wire    [7:0]   pi_data     ,   //输入数据

    output  wire            hsync       ,   //输出行同步信号
    output  wire            vsync       ,   //输出场同步信号
    output  wire    [7:0]   rgb             //输出像素信息

);

//********************************************************************//
//****************** Parameter and Internal Signal *******************//
//********************************************************************//
//wire  define
wire    [9:0]   pix_x       ;   //VGA有效显示区域X轴坐标
wire    [9:0]   pix_y       ;   //VGA有效显示区域Y轴坐标
wire    [7:0]   pix_data    ;   //VGA像素点色彩信息


//********************************************************************//
//*************************** Instantiation **************************//
//********************************************************************//
//------------- vga_ctrl_inst -------------
vga_ctrl    vga_ctrl_inst
(
    .vga_clk    (vga_clk    ),  //输入工作时钟,频率25MHz,1bit
    .sys_rst_n  (sys_rst_n  ),  //输入复位信号,低电平有效,1bit
    .pix_data   (pix_data   ),  //输入像素点色彩信息,8bit

    .pix_x      (pix_x      ),  //输出VGA有效显示区域像素点X轴坐标,10bit
    .pix_y      (pix_y      ),  //输出VGA有效显示区域像素点Y轴坐标,10bit
    .hsync      (hsync      ),  //输出行同步信号,1bit
    .vsync      (vsync      ),  //输出场同步信号,1bit
    .rgb        (rgb        )   //输出像素点色彩信息,16bit
);

//------------- vga_pic_inst -------------
vga_pic     vga_pic_inst
(
    .vga_clk        (vga_clk    ),  //输入工作时钟,频率25MHz,1bit
    .sys_clk        (sys_clk    ),  //输入RAM写时钟,1bit
    .sys_rst_n      (sys_rst_n  ),  //输入复位信号,低电平有效,1bit
    .pi_flag        (pi_flag    ),  //输入RAM写使能,1bit
    .pi_data        (pi_data    ),  //输入RAM写数据,8bit
    .pix_x          (pix_x      ),  //输入VGA有效显示区域像素点X轴坐标,10bit
    .pix_y          (pix_y      ),  //输入VGA有效显示区域像素点Y轴坐标,10bit

    .pix_data_out   (pix_data   )   //输出像素点色彩信息,8bit
);

endmodule