`timescale  1ns/1ns
////////////////////////////////////////////////////////////////////////
// Author        : EmbedFire
// Create Date   : 2019/08/19
// Module Name   : audio_send
// Project Name  : audio_record
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

module  audio_send
(
    input   wire            audio_bclk    ,   //WM8978输出的位时钟
    input   wire            sys_rst_n     ,   //系统复位，低有效
    input   wire            audio_lrc     ,   //WM8978输出数据左/右对齐时钟
    input   wire    [15:0]  dac_data      ,   //往WM8978发送的数据

    output  reg             audio_dacdat  ,   //发送DACDAT数据给WM8978
    output  reg             send_done         //一次数据发送完成

);

//********************************************************************//
//****************** Parameter and Internal Signal *******************//
//********************************************************************//

//reg   define
reg             audio_lrc_d1;   //对齐时钟打一拍信号
reg     [4:0]   dacdat_cnt  ;   //DACDAT数据发送位数计数器
reg     [15:0]  data_reg    ;   //dac_data数据寄存器

//wire  define
wire            lrc_edge    ;   //对齐时钟信号沿标志信号

//********************************************************************//
//***************************** Main Code ****************************//
//********************************************************************//

//使用异或运算符产生信号沿标志信号
assign  lrc_edge = audio_lrc ^ audio_lrc_d1;

//对audio_lcr信号打一拍以方便获得信号沿标志信号
always@(posedge audio_bclk  or  negedge sys_rst_n)
    if(sys_rst_n == 1'b0)
        audio_lrc_d1    <=  1'b0;
    else
        audio_lrc_d1    <=  audio_lrc;

//dacdat_cnt:当信号沿标志信号为高电平时，计数器清零
always@(posedge audio_bclk  or  negedge sys_rst_n)
    if(sys_rst_n == 1'b0)
        dacdat_cnt    <=  1'b0;
    else    if(lrc_edge == 1'b1)
        dacdat_cnt    <=  1'b0;
    else    if(dacdat_cnt < 5'd18)
        dacdat_cnt  <=  dacdat_cnt + 1'b1;
    else
        dacdat_cnt  <=  dacdat_cnt;

//将要发送的dac_data数据寄存在data_reg中
always@(posedge audio_bclk  or  negedge sys_rst_n)
    if(sys_rst_n == 1'b0)
        data_reg    <=  16'b0;
    else    if(lrc_edge == 1'b1)
        data_reg <=  dac_data;
    else
        data_reg    <=  data_reg;

//下降沿到来时将data_reg的数据一位一位传给audio_dacdat
always@(negedge audio_bclk  or  negedge sys_rst_n)
    if(sys_rst_n == 1'b0)
        audio_dacdat    <=  1'b0;
    else    if(dacdat_cnt <= 5'd15)
        audio_dacdat    <=  data_reg[15 - dacdat_cnt];

//当最后一位数据传完之后，输出一个时钟的发送完成标志信号
always@(posedge audio_bclk  or  negedge sys_rst_n)
    if(sys_rst_n == 1'b0)
        send_done    <=  1'b0;
    else    if(dacdat_cnt == 5'd16)
        send_done    <=  1'b1;
    else
        send_done    <=  1'b0;

endmodule
