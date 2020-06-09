`timescale  1ns/1ns
////////////////////////////////////////////////////////////////////////
// Author        : EmbedFire
// Create Date   : 2019/07/09
// Module Name   : water_led
// Project Name  : water_led
// Target Devices: Altera EP4CE10F17C8N
// Tool Versions : Quartus 13.0
// Description   : 流水灯
//
// Revision      : V1.0
// Additional Comments:
// 
// 实验平台: 野火_征途Pro_FPGA开发板
// 公司    : http://www.embedfire.com
// 论坛    : http://www.firebbs.cn
// 淘宝    : https://fire-stm32.taobao.com
////////////////////////////////////////////////////////////////////////

module  water_led
#(
    parameter CNT_MAX = 25'd24_999_999
)
(
    input   wire            sys_clk     ,   //系统时钟50Mh
    input   wire            sys_rst_n   ,  //全局复位

    output  wire    [3:0]   led_out        //输出控制led灯

);

//********************************************************************//
//****************** Parameter and Internal Signal *******************//
//********************************************************************//
//reg   define
reg     [24:0]  cnt         ;
reg             cnt_flag    ;
reg     [3:0]   led_out_reg ;

//********************************************************************//
//***************************** Main Code ****************************//
//********************************************************************//
//cnt:计数器计数1s
always@(posedge sys_clk or negedge sys_rst_n)
    if(sys_rst_n == 1'b0)
        cnt <= 25'b0;
    else    if(cnt == CNT_MAX)
        cnt <= 25'b0;
    else
        cnt <= cnt + 1'b1;

//cnt_flag:计数器计数满1s标志信号
always@(posedge sys_clk or negedge sys_rst_n)
    if(sys_rst_n == 1'b0)
        cnt_flag <= 1'b0;
    else    if(cnt == CNT_MAX - 1)
        cnt_flag <= 1'b1;
    else
        cnt_flag <= 1'b0;

//led_out_reg:led循环流水
always@(posedge sys_clk or negedge sys_rst_n)
    if(sys_rst_n == 1'b0)
        led_out_reg <=  4'b0001;
    else    if(led_out_reg == 4'b1000 && cnt_flag == 1'b1)
        led_out_reg <=  4'b0001;
    else    if(cnt_flag == 1'b1)
        led_out_reg <=  led_out_reg << 1'b1; //左移

assign  led_out = ~led_out_reg;

endmodule
