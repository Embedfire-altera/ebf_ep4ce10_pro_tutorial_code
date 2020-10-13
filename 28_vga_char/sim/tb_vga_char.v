`timescale  1ns/1ns
////////////////////////////////////////////////////////////////////////////////// 
// Author: fire
// Create Date: 2019/03/12
// Module Name: tb_vga_char
// Project Name: vga_char
// Target Devices: Altera EP4CE10F17C8N
// Tool Versions: Quartus 13.0
// Description: vga_colorbar仿真文件
// 
// Revision:V1.1
// Additional Comments:
// 
// 实验平台:野火FPGA开发板 
// 公司    :http://www.embedfire.com
// 论坛    :http://www.firebbs.cn
// 淘宝    :https://fire-stm32.taobao.com
//////////////////////////////////////////////////////////////////////////////////
`timescale  1ns/1ns
////////////////////////////////////////////////////////////////////////
// Author        : EmbedFire
// Create Date   : 2019/03/12
// Module Name   : tb_vga_char
// Project Name  : vga_char
// Target Devices: Altera EP4CE10F17C8N
// Tool Versions : Quartus 13.0
// Description   : vga_char仿真文件
// 
// Revision      : V1.0
// Additional Comments:
// 
// 实验平台: 野火_征途Pro_FPGA开发板
// 公司    : http://www.embedfire.com
// 论坛    : http://www.firebbs.cn
// 淘宝    : https://fire-stm32.taobao.com
////////////////////////////////////////////////////////////////////////

module  tb_vga_char();

//********************************************************************//
//****************** Parameter and Internal Signal *******************//
//********************************************************************//
//wire  define
wire            hsync       ;
wire    [15:0]  rgb         ;
wire            vsync       ;

//reg   define
reg             sys_clk     ;
reg             sys_rst_n   ;

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

//********************************************************************//
//*************************** Instantiation **************************//
//********************************************************************//

//------------- vga_char_inst -------------
vga_char    vga_char_inst
(
    .sys_clk    (sys_clk    ),  //输入晶振时钟,频率50MHz,1bit
    .sys_rst_n  (sys_rst_n  ),  //输入复位信号,低电平有效,1bit

    .hsync      (hsync      ),  //输出行同步信号,1bit
    .vsync      (vsync      ),  //输出场同步信号,1bit
    .rgb        (rgb        )   //输出RGB图像信息,16bit
);

endmodule

