`timescale  1ns/1ns
////////////////////////////////////////////////////////////////////////
// Author        : EmbedFire
// Create Date   : 2019/03/15
// Module Name   : key_filter
// Project Name  : eeprom_byte_rd_wr
// Target Devices: Altera EP4CE10F17C8N
// Tool Versions : Quartus 13.0
// Description   : 按键消抖模块
//
// Revision      : V1.0
// Additional Comments:
// 
// 实验平台: 野火_征途Pro_FPGA开发板
// 公司    : http://www.embedfire.com
// 论坛    : http://www.firebbs.cn
// 淘宝    : https://fire-stm32.taobao.com
////////////////////////////////////////////////////////////////////////

module  key_filter
#(
    parameter CNT_MAX = 20'd999_999 //计数器计数最大值
)
(
    input   wire    sys_clk     ,   //系统时钟50Mhz
    input   wire    sys_rst_n   ,   //全局复位
    input   wire    key_in      ,   //按键输入信号

    output  reg     key_flag        //key_flag为1时表示消抖后检测到按键被按下
                                    //key_flag为0时表示没有检测到按键被按下
);

//********************************************************************//
//****************** Parameter and Internal Signal *******************//
//********************************************************************//
//reg   define
reg     [19:0]  cnt_20ms    ;   //计数器

//********************************************************************//
//***************************** Main Code ****************************//
//********************************************************************//

//cnt_20ms:如果时钟的上升沿检测到外部按键输入的值为低电平时，计数器开始计数
always@(posedge sys_clk or negedge sys_rst_n)
    if(sys_rst_n == 1'b0)
        cnt_20ms <= 20'b0;
    else    if(key_in == 1'b1)
        cnt_20ms <= 20'b0;
    else    if(cnt_20ms == CNT_MAX && key_in == 1'b0)
        cnt_20ms <= cnt_20ms;
    else
        cnt_20ms <= cnt_20ms + 1'b1;

//key_flag:当计数满20ms后产生按键有效标志位
//且key_flag在999_999时拉高,维持一个时钟的高电平
always@(posedge sys_clk or negedge sys_rst_n)
    if(sys_rst_n == 1'b0)
        key_flag <= 1'b0;
    else    if(cnt_20ms == CNT_MAX - 1'b1)
        key_flag <= 1'b1;
    else
        key_flag <= 1'b0;

endmodule
