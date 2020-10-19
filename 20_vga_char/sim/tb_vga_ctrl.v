`timescale  1ns/1ns
////////////////////////////////////////////////////////////////////////
// Author        : EmbedFire
// Create Date   : 2019/03/12
// Module Name   : tb_vga_ctrl
// Project Name  : vga_char
// Target Devices: Altera EP4CE10F17C8N
// Tool Versions : Quartus 13.0
// Description   : vga_ctrl仿真文件
// 
// Revision      : V1.0
// Additional Comments:
// 
// 实验平台: 野火_征途Pro_FPGA开发板
// 公司    : http://www.embedfire.com
// 论坛    : http://www.firebbs.cn
// 淘宝    : https://fire-stm32.taobao.com
////////////////////////////////////////////////////////////////////////

module  tb_vga_ctrl();

//********************************************************************//
//****************** Parameter and Internal Signal *******************//
//********************************************************************//
//wire  define
wire            locked      ;
wire            rst_n       ;
wire            vga_clk     ;

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
always  #10 sys_clk = ~sys_clk  ;

//rst_n:VGA模块复位信号
assign  rst_n = (sys_rst_n & locked);

//pix_data:输入像素点色彩信息
always@(posedge vga_clk or  negedge rst_n)
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
    .c0         (vga_clk    ),  //输出VGA工作时钟,频率25Mhz,1bit
    .locked     (locked     )   //输出pll locked信号,1bit
);

//------------- vga_ctrl_inst -------------
vga_ctrl  vga_ctrl_inst
(
    .vga_clk    (vga_clk    ),  //输入工作时钟,频率25MHz,1bit
    .sys_rst_n  (rst_n      ),  //输入复位信号,低电平有效,1bit
    .pix_data   (pix_data   ),  //输入像素点色彩信息,16bit

    .pix_x      (pix_x      ),  //输出VGA有效显示区域像素点X轴坐标,10bit
    .pix_y      (pix_y      ),  //输出VGA有效显示区域像素点Y轴坐标,10bit
    .hsync      (hsync      ),  //输出行同步信号,1bit
    .vsync      (vsync      ),  //输出场同步信号,1bit
    .rgb        (rgb        )   //输出像素点色彩信息,16bit
);

endmodule

