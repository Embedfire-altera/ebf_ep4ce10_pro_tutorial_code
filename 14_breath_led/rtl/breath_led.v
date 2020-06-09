`timescale  1ns/1ns
////////////////////////////////////////////////////////////////////////
// Author        : EmbedFire
// Create Date   : 2019/07/10
// Module Name   : breath_led
// Project Name  : breath_led
// Target Devices: Altera EP4CE10F17C8N
// Tool Versions : Quartus 13.0
// Description   : 呼吸灯
//
// Revision      : V1.0
// Additional Comments:
// 
// 实验平台: 野火_征途Pro_FPGA开发板
// 公司    : http://www.embedfire.com
// 论坛    : http://www.firebbs.cn
// 淘宝    : https://fire-stm32.taobao.com
////////////////////////////////////////////////////////////////////////

module  breath_led
#(
    parameter CNT_1US_MAX = 6'd49   ,
    parameter CNT_1MS_MAX = 10'd999 ,
    parameter CNT_1S_MAX  = 10'd999
)
(
    input   wire    sys_clk     ,   //系统时钟50Mhz
    input   wire    sys_rst_n   ,   //全局复位

    output  reg     led_out         //输出信号，控制led灯
);

//********************************************************************//
//****************** Parameter and Internal Signal *******************//
//********************************************************************//
//reg define
reg [5:0]   cnt_1us     ;
reg [9:0]   cnt_1ms     ;
reg [9:0]   cnt_1s      ;
reg         cnt_1s_flag ;

//********************************************************************/
//***************************** Main Code ****************************//
//********************************************************************//
//cnt_1us:1us计数器
always@(posedge sys_clk or negedge sys_rst_n)
    if(sys_rst_n == 1'b0)
        cnt_1us <= 6'b0;
    else    if(cnt_1us == CNT_1US_MAX)
        cnt_1us <= 6'b0;
    else
        cnt_1us <= cnt_1us + 1'b1;

//cnt_1ms:1ms计数器
always@(posedge sys_clk or negedge sys_rst_n)
    if(sys_rst_n == 1'b0)
        cnt_1ms <= 10'b0;
    else    if(cnt_1ms == CNT_1MS_MAX && cnt_1us == CNT_1US_MAX)
        cnt_1ms <= 10'b0;
    else    if(cnt_1us == CNT_1US_MAX)
        cnt_1ms <= cnt_1ms + 1'b1;

//cnt_1s:1s计数器
always@(posedge sys_clk or negedge sys_rst_n)
    if(sys_rst_n == 1'b0)
        cnt_1s <= 10'b0;
    else    if(cnt_1s == CNT_1S_MAX && cnt_1ms == CNT_1MS_MAX 
                                        && cnt_1us == CNT_1US_MAX)
        cnt_1s <= 10'b0;
    else    if(cnt_1ms == CNT_1MS_MAX && cnt_1us == CNT_1US_MAX)
        cnt_1s <= cnt_1s + 1'b1;

//cnt_1s_flag:1s计数器标志信号
always@(posedge sys_clk or negedge sys_rst_n)
    if(sys_rst_n == 1'b0)
        cnt_1s_flag <= 1'b0;
    else    if(cnt_1s == CNT_1S_MAX && cnt_1ms == CNT_1MS_MAX 
                                            && cnt_1us == CNT_1US_MAX)
        cnt_1s_flag <= ~cnt_1s_flag;

//led_out:输出信号连接到外部的led灯
always@(posedge sys_clk or negedge sys_rst_n)
    if(sys_rst_n == 1'b0)
        led_out <= 1'b0;
    else    if((cnt_1s_flag == 1'b1 && cnt_1ms < cnt_1s) || 
                            (cnt_1s_flag == 1'b0 && cnt_1ms > cnt_1s))
        led_out <= 1'b0;
    else
        led_out <= 1'b1;

endmodule
