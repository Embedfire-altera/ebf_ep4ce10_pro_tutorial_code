`timescale  1ns/1ns
////////////////////////////////////////////////////////////////////////
// Author        : EmbedFire
// Create Date   : 2019/07/10
// Module Name   : data_gen
// Project Name  : top_seg_595
// Target Devices: Altera EP4CE10F17C8N
// Tool Versions : Quartus 13.0
// Description   : 生成数码管显示数据
//
// Revision      : V1.0
// Additional Comments:
// 
// 实验平台: 野火_征途Pro_FPGA开发板
// 公司    : http://www.embedfire.com
// 论坛    : http://www.firebbs.cn
// 淘宝    : https://fire-stm32.taobao.com
////////////////////////////////////////////////////////////////////////

module  data_gen
(
    input   wire            sys_clk     ,   //系统时钟，频率50MHz
    input   wire            sys_rst_n   ,   //复位信号，低电平有效

    output  reg     [19:0]  data        ,   //数码管要显示的值
    output  reg     [5:0]   point       ,   //小数点显示,高电平有效
    output  reg             seg_en      ,   //数码管使能信号，高电平有效
    output  reg             sign            //符号位，高电平显示负号
);

//********************************************************************//
//****************** Parameter and Internal Signal *******************//
//********************************************************************//
//parameter define
parameter   CNT_100MS_MAX   =   4999_999;   //100ms计数值
parameter   DATA_MAX        =   999_999 ;   //显示的最大值

//reg   define
reg     [22:0]  cnt_100ms   ;   //100ms计数器
reg             flag_100ms  ;   //100ms标志信号

//********************************************************************//
//***************************** Main Code ****************************//
//********************************************************************//
//cnt_100ms:用50MHz时钟从0到4999_999计数即为100ms
always@(posedge sys_clk or  negedge sys_rst_n)
    if(sys_rst_n == 1'b0)
        cnt_100ms   <=  23'b0;
    else    if(cnt_100ms == CNT_100MS_MAX)
        cnt_100ms   <=  23'b0;
    else
        cnt_100ms   <=  cnt_100ms + 1'b1;

//flag_100ms:每100ms产生一个标志信号
always@(posedge sys_clk or  negedge sys_rst_n)
    if(sys_rst_n == 1'b0)
        flag_100ms  <=  1'b0;
    else    if(cnt_100ms == CNT_100MS_MAX)
        flag_100ms  <=  1'b1;
    else
        flag_100ms  <=  1'b0;

//数码管显示的数据:0-999_999
always@(posedge sys_clk or  negedge sys_rst_n)
    if(sys_rst_n == 1'b0)
        begin
            data    <=  20'b0       ;
            point   <=  6'b000000   ;
            seg_en  <=  1'b0        ;
            sign    <=  1'b0        ;
        end
    else
        begin
            point   <=  6'b000000   ;   //不显示小数点
            seg_en  <=  1'b1        ;   //拉高使能信号
            sign    <=  1'b0        ;   //不显示负号
//显示数值每隔0.1s加1
            if( (data == DATA_MAX) && (flag_100ms == 1'b1) )
                data    <=  20'b0;
            else    if(flag_100ms == 1'b1)
                data    <=  data + 1'b1;
        end

endmodule