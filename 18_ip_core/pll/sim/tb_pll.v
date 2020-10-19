`timescale  1ns/1ns
////////////////////////////////////////////////////////////////////////
// Author        : EmbedFire
// Create Date   : 2019/05/12
// Module Name   : tb_pll
// Project Name  : pll
// Target Devices: Altera EP4CE10F17C8N
// Tool Versions : Quartus 13.0
// Description   : pll时钟仿真文件
//
// Revision      : V1.0
// Additional Comments:
// 
// 实验平台: 野火_征途Pro_FPGA开发板
// 公司    : http://www.embedfire.com
// 论坛    : http://www.firebbs.cn
// 淘宝    : https://fire-stm32.taobao.com
////////////////////////////////////////////////////////////////////////

module tb_pll();

//********************************************************************//
//****************** Parameter and Internal Signal *******************//
//********************************************************************//
//wire  define
wire    clk_mul_2   ;
wire    clk_div_2   ;
wire    clk_phase_90;
wire    clk_ducle_20;
wire    locked      ;

//reg   define
reg     sys_clk     ;

//********************************************************************//
//***************************** Main Code ****************************//
//********************************************************************//

//初始化系统时钟
initial sys_clk = 1'b1;

//sys_clk:模拟系统时钟，每10ns电平翻转一次，周期为20ns，频率为50Mhz
always #10 sys_clk = ~sys_clk;

//********************************************************************//
//*************************** Instantiation **************************//
//********************************************************************//

//------------------------pll_inst------------------------
pll pll_inst
(
    .sys_clk        (sys_clk        ),  //input     sys_clk

    .clk_mul_2      (clk_mul_2      ),  //output    clk_mul_2
    .clk_div_2      (clk_div_2      ),  //output    clk_div_2
    .clk_phase_90   (clk_phase_90   ),  //output    clk_phase_90
    .clk_ducle_20   (clk_ducle_20   ),  //output    clk_ducle_20
    .locked         (locked         )   //output    locked
);

endmodule