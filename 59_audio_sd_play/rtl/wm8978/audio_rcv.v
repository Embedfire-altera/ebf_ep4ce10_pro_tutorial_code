`timescale  1ns/1ns
////////////////////////////////////////////////////////////////////////
// Author        : EmbedFire
// Create Date   : 2019/12/05
// Module Name   : audio_rcv
// Project Name  : audio_sd_play
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

module  audio_rcv
(
    input   wire        audio_bclk      ,   //WM8978输出的位时钟
    input   wire        sys_rst_n       ,   //系统复位，低有效
    input   wire        audio_lrc       ,   //WM8978输出的数据左/右对齐时钟
    input   wire        audio_adcdat    ,   //WM8978ADC数据输出

    output  reg [15:0]  adc_data        ,   //一次接收的数据
    output  reg         rcv_done            //一次数据接收完成

);

//********************************************************************//
//************************** Internal Signal *************************//
//********************************************************************//

//reg   define
reg             audio_lrc_d1;   //对齐时钟打一拍信号
reg     [4:0]   adcdat_cnt  ;   //WM8978ADC数据输出位数计数器
reg     [15:0]  data_reg    ;   //adc_data数据寄存器

//wire  define
wire            lrc_edge    ;   //对齐时钟信号沿标志信号

//********************************************************************//
//***************************** Main Code ****************************//
//********************************************************************//

assign  lrc_edge    =   audio_lrc   ^   audio_lrc_d1; //使用异或运算符产生信号沿标志信号

//对audio_lrc信号打一拍以方便获得信号沿标志信号
always@(posedge audio_bclk  or  negedge sys_rst_n)
    if(sys_rst_n == 1'b0)
        audio_lrc_d1    <=  1'b0    ;
    else
        audio_lrc_d1    <=  audio_lrc   ;
        
//adcdat_cnt:当信号沿标志信号为高电平时，计数器清零
always@(posedge audio_bclk  or  negedge sys_rst_n)
    if(sys_rst_n == 1'b0)
        adcdat_cnt    <=  5'b0    ;
    else    if(lrc_edge == 1'b1)
        adcdat_cnt    <=  5'b0    ;
    else    if(adcdat_cnt < 5'd19)
        adcdat_cnt  <=  adcdat_cnt + 1'b1;

//将WM8978输出的ADC数据寄存在data_reg中，一次寄存24位
always@(posedge audio_bclk  or  negedge sys_rst_n)
    if(sys_rst_n == 1'b0)
        data_reg    <=  16'b0   ;
    else    if(adcdat_cnt <= 5'd15)
        data_reg[15-adcdat_cnt] <=  audio_adcdat    ;
    else
        data_reg    <=  data_reg    ;
        
//当最后一位数据传完之后，读出寄存器的值给adc_data
always@(posedge audio_bclk  or  negedge sys_rst_n)
    if(sys_rst_n == 1'b0)
        adc_data    <=  16'b0   ;
    else    if(adcdat_cnt == 5'd16)
        adc_data    <=  data_reg    ;
    else
        adc_data    <=  adc_data    ;
        
//当最后一位数据传完之后，输出一个时钟的完成标志信号
always@(posedge audio_bclk  or  negedge sys_rst_n)
    if(sys_rst_n == 1'b0)
        rcv_done    <=  1'b0    ;
    else    if(adcdat_cnt == 5'd16)
        rcv_done    <=  1'b1    ;
    else
        rcv_done    <=  1'b0    ;

endmodule
