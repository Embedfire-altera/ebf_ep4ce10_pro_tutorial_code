`timescale  1ns/1ns
////////////////////////////////////////////////////////////////////////
// Author        : EmbedFire
// Create Date   : 2018/08/31
// Module Name   : key_ctrl
// Project Name  : ap3216c
// Target Devices: Altera EP4CE10F17C8N
// Tool Versions : Quartus 13.0
// Description   : 
//
// Revision      : V1.0
// Additional Comments:
// 
// 实验平台: 野火_征途Pro_FPGA开发板
// 公司    : http://www.embedfire.com
// 论坛    : http://www.firebbs.cn
// 淘宝    : https://fire-stm32.taobao.com
////////////////////////////////////////////////////////////////////////

module  key_ctrl
(
    input   wire            sys_clk     ,   //系统时钟，频率50MHz
    input   wire            sys_rst_n   ,   //系统复位，低电平有效
    input   wire            key_flag    ,   //按键消抖标志信号
    input   wire    [9:0]   ps_data     ,   //ps数据
    input   wire    [15:0]  als_data    ,   //als数据

    output  reg     [19:0]  data_out        //输出数据给数码管显示

);

//********************************************************************//
//****************** Parameter and Internal Signal *******************//
//********************************************************************//

//reg   define
reg data_flag   ;   //数据切换标志信号

//********************************************************************//
//******************************* Main Code **************************//
//********************************************************************//

//data_flag：数据切换标志信号
always@(posedge sys_clk or  negedge sys_rst_n)
    if(sys_rst_n == 1'b0)
        data_flag    <=  1'd0;
    else    if(key_flag == 1'b1)
        data_flag    <=  ~data_flag;

//data_out:输出数码管显示数据
always@(posedge sys_clk or  negedge sys_rst_n)
    if(sys_rst_n == 1'b0)
        data_out    <=  20'd0;
    else    if(data_flag == 1'b0)
        data_out    <=  als_data;
   else
        data_out    <=  ps_data;

endmodule
