`timescale  1ns/1ns
////////////////////////////////////////////////////////////////////////
// Author        : EmbedFire
// Create Date   : 2019/03/20
// Module Name   : tb_tft_ctrl
// Project Name  : tft_colorbar
// Target Devices: Altera EP4CE10F17C8N
// Tool Versions : Quartus 13.0
// Description   : tft_lcd控制模块仿真文件
// 
// Revision      : V1.0
// Additional Comments:
// 
// 实验平台: 野火_征途Pro_FPGA开发板
// 公司    : http://www.embedfire.com
// 论坛    : http://www.firebbs.cn
// 淘宝    : https://fire-stm32.taobao.com
////////////////////////////////////////////////////////////////////////

module  tb_tft_ctrl();
//********************************************************************//
//****************** Parameter and Internal Signal *******************//
//********************************************************************//
//wire  define
wire            locked      ;
wire            rst_n       ;
wire            tft_clk_9m  ;

//reg   define
reg             sys_clk     ;
reg             sys_rst_n   ;
reg     [15:0]  pix_data    ;

//********************************************************************//
//**************************** Clk And Rst ***************************//
//********************************************************************//

//sys_clk,sys_rst_n初始赋值
initial
    begin
        sys_clk     =   1'b1;
        sys_rst_n   <=  1'b0;
        #200
        sys_rst_n   <=  1'b1;
    end

//sys_clk：产生时钟
always  #10 sys_clk = ~sys_clk;

//rst_n:VGA模块复位信号
assign  rst_n = (sys_rst_n & locked);

//pix_data:输入像素点色彩信息
always@(posedge tft_clk_9m or negedge rst_n)
    if(rst_n == 1'b0)
        pix_data    <=  16'h0;
    else
        pix_data    <=  16'hffff;

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

endmodule

