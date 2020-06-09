`timescale  1ns/1ns
////////////////////////////////////////////////////////////////////////
// Author        : EmbedFire
// Create Date   : 2019/07/08
// Module Name   : touch_ctrl_led
// Project Name  : touch_ctrl_led
// Target Devices: Altera EP4CE10F17C8N
// Tool Versions : Quartus 13.0
// Description   : 触摸按键控制LED灯
//
// Revision      : V1.0
// Additional Comments:
// 
// 实验平台: 野火_征途Pro_FPGA开发板
// 公司    : http://www.embedfire.com
// 论坛    : http://www.firebbs.cn
// 淘宝    : https://fire-stm32.taobao.com
////////////////////////////////////////////////////////////////////////

module  touch_ctrl_led
(
    input   wire    sys_clk     ,   //系统时钟，频率50MHz
    input   wire    sys_rst_n   ,   //复位信号，低电平有效
    input   wire    touch_key   ,   //触摸按键信号

    output  reg     led             //led输出信号
);

//********************************************************************//
//****************** Parameter and Internal Signal *******************//
//********************************************************************//
//wire  define
wire    touch_en    ;   //触摸使能信号

//reg   define
reg touch_key_dly1  ;   //touch_key延迟一个时钟信号
reg touch_key_dly2  ;   //touch_key延迟两个时钟信号

//********************************************************************//
//***************************** Main Code ****************************//
//********************************************************************//
//根据触摸按键信号的下降沿判断触摸了触摸按键
assign  touch_en    =   touch_key_dly2  &  (~touch_key_dly1);

//对touch_key信号延迟两个时钟周期用来产生触摸按键信号
always@(posedge sys_clk or  negedge sys_rst_n)
    if(sys_rst_n == 1'b0)
        begin
            touch_key_dly1  <=  1'b0;
            touch_key_dly2  <=  1'b0;
        end
    else
        begin
            touch_key_dly1  <=  touch_key;
            touch_key_dly2  <=  touch_key_dly1;
        end

//根据触摸使能信号控制led状态
always@(posedge sys_clk or  negedge sys_rst_n)
    if(sys_rst_n == 1'b0)
        led <=  1'b1;
    else    if(touch_en == 1'b1)
        led <=  ~led;

endmodule
