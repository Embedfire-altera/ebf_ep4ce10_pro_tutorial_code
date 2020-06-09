`timescale  1ns/1ns
////////////////////////////////////////////////////////////////////////
// Author        : EmbedFire
// Create Date   : 2019/05/12
// Module Name   : pll
// Project Name  : pll
// Target Devices: Altera EP4CE10F17C8N
// Tool Versions : Quartus 13.0
// Description   : pll时钟
//
// Revision      : V1.0
// Additional Comments:
// 
// 实验平台: 野火_征途Pro_FPGA开发板
// 公司    : http://www.embedfire.com
// 论坛    : http://www.firebbs.cn
// 淘宝    : https://fire-stm32.taobao.com
////////////////////////////////////////////////////////////////////////

module  pll
(
    input   wire    sys_clk     ,   //系统时钟50Mhz

    output  wire    clk_mul_2   ,   //系统时钟经过2倍频后的时钟
    output  wire    clk_div_2   ,   //系统时钟经过2分频后的时钟
    output  wire    clk_phase_90,   //系统时钟经过相移90°后的时钟
    output  wire    clk_ducle_20,   //系统时钟变为占空比为20%的时钟
    output  wire    locked          //检测锁相环是否已经锁定，
                                    //只有该信号为高时输出的时钟才是稳定的
);

//********************************************************************//
//*************************** Instantiation **************************//
//********************************************************************//

//------------------------ pll_inst ------------------------
pll_ip  pll_ip_inst
(
    .inclk0 (sys_clk        ),  //input     inclk0

    .c0     (clk_mul_2      ),  //output    c0
    .c1     (clk_div_2      ),  //output    c1
    .c2     (clk_phase_90   ),  //output    c2
    .c3     (clk_ducle_20   ),  //output    c3
    .locked (locked         )   //output    locked
);

endmodule

