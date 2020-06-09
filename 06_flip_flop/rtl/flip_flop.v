`timescale  1ns/1ns
////////////////////////////////////////////////////////////////////////
// Author        : EmbedFire
// Create Date   : 2019/03/14
// Module Name   : flip_flop
// Project Name  : flip_flop
// Target Devices: Altera EP4CE10F17C8N
// Tool Versions : Quartus 13.0
// Description   : 寄存器
//
// Revision      : V1.0
// Additional Comments:
// 
// 实验平台: 野火_征途Pro_FPGA开发板
// 公司    : http://www.embedfire.com
// 论坛    : http://www.firebbs.cn
// 淘宝    : https://fire-stm32.taobao.com
////////////////////////////////////////////////////////////////////////

module  flip_flop
(
    input   wire    sys_clk     ,   //系统时钟50Mhz，后面我们都是设计的时序电路，所以一定要有时钟，时序电路中几乎所有的信号都是伴随着时钟的沿（上升沿或下降沿，习惯上用上升沿）进行工作的
    input   wire    sys_rst_n   ,   //全局复位，复位信号的主要作用是在系统出现问题是能够回到初始状态，或一些信号的初始化时需要进行复位
    input   wire    key_in      ,   //输入按键

    output  reg     led_out         //输出控制led灯
);

//********************************************************************//
//***************************** Main Code ****************************//
//********************************************************************//
//同步复位
//led_out:led灯输出的结果为key_in按键的输入值
always@(posedge sys_clk)    //当always块中的敏感列表为检测到sys_clk上升沿时执行下面的语句
    if(sys_rst_n == 1'b0)   //sys_rst_n为低电平时复位，但是这个复位有个大前提，那就是当sys_clk的上升沿到来时，如果检测到sys_rst_n为低电平则复位有效。
        led_out <= 1'b0;    //复位的时候一定要给寄存器变量赋一个初值，一般情况下赋值为0（特殊情况除外），在描述时序电路时赋值符号一定要使用“<=”
    else
        led_out <= key_in;

/*
//异步复位
//led_out:led灯输出的结果为key_in按键的输入值
always@(posedge sys_clk or negedge sys_rst_n) //当always块中的敏感列表为检测到sys_clk上升沿或sys_rst_n下降沿时执行下面的语句
    if(sys_rst_n == 1'b0)                     //sys_rst_n为低电平时复位，且是检测到sys_rst_n的下降沿时立刻复位，不需等待sys_clk的上升沿来到后再复位
        led_out <= 1'b0;
    else
        led_out <= key_in;
 */

endmodule
