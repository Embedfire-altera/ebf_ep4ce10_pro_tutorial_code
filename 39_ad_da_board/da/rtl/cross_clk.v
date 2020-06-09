`timescale  1ns/1ns
////////////////////////////////////////////////////////////////////////
// Author        : EmbedFire
// Create Date   : 2019/04/01
// Module Name   : cross_clk
// Project Name  : da
// Target Devices: Altera EP4CE10F17C8N
// Tool Versions : Quartus 13.0
// Description   : 跨时钟域处理
//
// Revision      : V1.0
// Additional Comments:
// 
// 实验平台: 野火_征途Pro_FPGA开发板
// 公司    : http://www.embedfire.com
// 论坛    : http://www.firebbs.cn
// 淘宝    : https://fire-stm32.taobao.com
////////////////////////////////////////////////////////////////////////

module  cross_clk
(
    input   wire            clk_a       ,   //时钟a
    input   wire            clk_b       ,   //时钟b
    input   wire            sys_rst_n   ,   //复位信号
    input   wire            en_a        ,   //a使能信号

    output  reg             en_b            //b使能信号
);
//********************************************************************//
//****************** Parameter and Internal Signal *******************//
//********************************************************************//
//parameter define
parameter   CNT_MAX = 16'd50;   //计数器最大值

//reg   define
reg     [15:0]  cnt         ;   //计数器
reg             en_a_valid  ;   //a使能有效信号
reg             en_a_valid_r;   //a使能有效信号寄存

//********************************************************************//
//***************************** Main Code ****************************//
//********************************************************************//
//en_a_valid:a使能有效信号
always@(posedge  clk_a or  negedge sys_rst_n)
    if(sys_rst_n == 1'b0)
        en_a_valid  <=  1'b0;
    else    if(cnt == CNT_MAX)
        en_a_valid  <=  1'b0;
    else    if(en_a == 1'b1)
        en_a_valid  <=  1'b1;
    else
        en_a_valid  <=  en_a_valid;

//cnt:计数器
always@(posedge  clk_a or  negedge sys_rst_n)
    if(sys_rst_n == 1'b0)
        cnt <=  16'b0;
    else    if(cnt == CNT_MAX)
        cnt <=  16'b0;
    else    if(en_a_valid == 1'b1)
        cnt <=  cnt + 1'b1;

//en_a_valid_r:a使能有效信号寄存
always@(posedge  clk_b or  negedge sys_rst_n)
    if(sys_rst_n == 1'b0)
        en_a_valid_r    <=  1'b0;
    else    
        en_a_valid_r    <=  en_a_valid;

//en_b:b使能信号
always@(posedge  clk_b or  negedge sys_rst_n)
    if(sys_rst_n == 1'b0)
        en_b    <=  1'b0;
    else    if((en_a_valid == 1'b0) && (en_a_valid_r == 1'b1))
        en_b    <=  1'b1;
    else
        en_b    <=  1'b0;

endmodule
