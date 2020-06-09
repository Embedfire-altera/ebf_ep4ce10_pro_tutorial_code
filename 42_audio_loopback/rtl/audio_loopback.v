`timescale  1ns/1ns
////////////////////////////////////////////////////////////////////////
// Author        : EmbedFire
// Create Date   : 2018/08/20
// Module Name   : audio_loopback
// Project Name  : audio_loopback
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

module  audio_loopback
(
    input   wire    sys_clk         ,   //系统时钟，频率50MHz
    input   wire    sys_rst_n       ,   //系统复位，低电平有效
    input   wire    audio_bclk      ,   //WM8978输出的位时钟
    input   wire    audio_lrc       ,   //WM8978输出的数据左/右对齐时钟
    input   wire    audio_adcdat    ,   //WM8978ADC数据输出

    output  wire    scl             ,   //输出至wm8978的串行时钟信号scl
    output  wire    audio_mclk      ,   //输出WM8978主时钟,频率12MHz
    output  wire    audio_dacdat    ,   //输出DAC数据给WM8978

    inout   wire    sda                 //输出至wm8978的串行数据信号sda

);

//********************************************************************//
//******************** Parameter And Internal Signal *****************//
//********************************************************************//

//wire  define
wire    [23:0]  adc_data    ;   //接收的音频数据

//********************************************************************//
//*************************** Instantiation **************************//
//********************************************************************//

//------------------- clk_gen_inst ----------------------
clk_gen     clk_gen_inst
(
    .areset (~sys_rst_n ),  //异步复位，取反连接
    .inclk0 (sys_clk    ),  //输入时钟（50MHz）

    .c0     (audio_mclk ),  //输出时钟（12MHz）
    .locked ()              //输出稳定时钟标志信号

    );

//------------------- audio_rcv_inst -------------------
audio_rcv   audio_rcv_inst
(
    .audio_bclk      (audio_bclk  ),   //WM8978输出的位时钟
    .sys_rst_n       (sys_rst_n   ),   //系统复位，低有效
    .audio_lrc       (audio_lrc   ),   //WM8978输出的数据左/右对齐时钟
    .audio_adcdat    (audio_adcdat),   //WM8978ADC数据输出

    .adc_data        (adc_data    ),   //一次接收的数据
    .rcv_done        ()                //一次数据接收完成

);

//------------------ audio_send_inst ------------------
audio_send  audio_send_inst
(
    .audio_bclk      (audio_bclk  ),   //WM8978输出的位时钟
    .sys_rst_n       (sys_rst_n   ),   //系统复位，低有效
    .audio_lrc       (audio_lrc   ),   //WM8978输出数据左/右对齐时钟
    .dac_data        (adc_data    ),   //往WM8978发送的数据

    .audio_dacdat    (audio_dacdat),   //发送DAC数据给WM8978
    .send_done       ()                //一次数据发送完成

);

//----------------- wm8978_cfg_inst --------------------
wm8978_cfg  wm8978_cfg_inst
(
    .sys_clk     (sys_clk   ),  //系统时钟，频率50MHz
    .sys_rst_n   (sys_rst_n ),  //系统复位，低电平有效

    .i2c_scl     (scl       ),  //输出至wm8978的串行时钟信号scl
    .i2c_sda     (sda       )   //输出至wm8978的串行数据信号sda

);

endmodule
