`timescale  1ns/1ns
////////////////////////////////////////////////////////////////////////
// Author        : EmbedFire
// Create Date   : 2019/03/16
// Module Name   : tb_divider_five
// Project Name  : divider_five
// Target Devices: Altera EP4CE10F17C8N
// Tool Versions : Quartus 13.0
// Description   : 五分频仿真文件
//
// Revision      : V1.0
// Additional Comments:
// 
// 实验平台: 野火_征途Pro_FPGA开发板
// 公司    : http://www.embedfire.com
// 论坛    : http://www.firebbs.cn
// 淘宝    : https://fire-stm32.taobao.com
////////////////////////////////////////////////////////////////////////

module  tb_divider_five();

//********************************************************************//
//****************** Parameter and Internal Signal *******************//
//********************************************************************//
//wire  define
wire    clk_out;

//reg   define
reg     sys_clk;
reg     sys_rst_n;

//********************************************************************//
//***************************** Main Code ****************************//
//********************************************************************//
//初始化系统时钟、全局复位
initial begin
    sys_clk    = 1'b1;
    sys_rst_n <= 1'b0;
    #20
    sys_rst_n <= 1'b1;
 end

//sys_clk:模拟系统时钟，每10ns电平翻转一次，周期为20ns，频率为50Mhz
always  #10 sys_clk = ~sys_clk;

//********************************************************************//
//**************************** Instantiate ***************************//
//********************************************************************//
//------------- divider_five_inst --------------

divider_five    divider_five_inst
(
    .sys_clk    (sys_clk    ),  //input     sys_clk
    .sys_rst_n  (sys_rst_n  ),  //input     sys_rst_n

    .clk_out    (clk_out    )   //output    clk_out
);

endmodule
