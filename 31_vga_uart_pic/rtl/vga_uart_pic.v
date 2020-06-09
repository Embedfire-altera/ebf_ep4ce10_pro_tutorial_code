`timescale  1ns/1ns
////////////////////////////////////////////////////////////////////////
// Author        : EmbedFire
// Create Date   : 2019/06/12
// Module Name   : vga_uart_pic
// Project Name  : vga_uart_pic
// Target Devices: Altera EP4CE10F17C8N
// Tool Versions : Quartus 13.0
// Description   : uart_vga_pic顶层模块
// 
// Revision      : V1.0
// Additional Comments:
// 
// 实验平台: 野火_征途Pro_FPGA开发板
// 公司    : http://www.embedfire.com
// 论坛    : http://www.firebbs.cn
// 淘宝    : https://fire-stm32.taobao.com
////////////////////////////////////////////////////////////////////////

module  vga_uart_pic
(
    input   wire            sys_clk     ,   //输入工作时钟,频率50MHz
    input   wire            sys_rst_n   ,   //输入复位信号,低电平有效
    input   wire            rx          ,   //输入串口的图片数据

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
wire            po_flag     ;   //串口拼接好的图片数据
wire    [7:0]   po_data     ;   //数据标志信号
wire            vga_clk     ;   //VGA工作时钟
wire            clk_50m     ;   //串口工作时钟
wire            locked      ;   //PLL locked信号
wire            rst_n       ;   //VGA模块复位信号
wire    [9:0]   pix_x       ;   //VGA有效显示区域X轴坐标
wire    [9:0]   pix_y       ;   //VGA有效显示区域Y轴坐标
wire    [7:0]   pix_data    ;   //VGA像素点色彩信息

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

//-------------uart_rx_inst-------------
uart_rx
#(
    .UART_BPS    (UART_BPS),         //串口波特率
    .CLK_FREQ    (CLK_FREQ)          //时钟频率
)
uart_rx_inst
(
    .sys_clk     (clk_50m  ),   //输入工作时钟,频率50MHz,1bit
    .sys_rst_n   (rst_n    ),   //输入复位信号,低电平有效,1bit
    .rx          (rx       ),   //输入串口的图片数据,1bit

    .po_data     (po_data  ),   //输出拼接好的图片数据
    .po_flag     (po_flag  )    //输出数据标志信号
);

//------------- vga_ctrl_inst -------------
vga_ctrl    vga_ctrl_inst
(
    .vga_clk    (vga_clk    ),  //输入工作时钟,频率25MHz,1bit
    .sys_rst_n  (rst_n      ),  //输入复位信号,低电平有效,1bit
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
    .sys_clk        (clk_50m    ),  //输入RAM写时钟,1bit
    .sys_rst_n      (rst_n      ),  //输入复位信号,低电平有效,1bit
    .pi_flag        (po_flag    ),  //输入RAM写使能,1bit
    .pi_data        (po_data    ),  //输入RAM写数据,8bit
    .pix_x          (pix_x      ),  //输入VGA有效显示区域像素点X轴坐标,10bit
    .pix_y          (pix_y      ),  //输入VGA有效显示区域像素点Y轴坐标,10bit

    .pix_data_out   (pix_data   )   //输出像素点色彩信息,8bit

);

endmodule