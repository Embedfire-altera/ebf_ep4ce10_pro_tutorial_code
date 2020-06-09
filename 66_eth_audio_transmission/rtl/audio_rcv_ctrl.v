`timescale  1ns/1ns
////////////////////////////////////////////////////////////////////////
// Author        : EmbedFire
// Create Date   : 2019/10/10
// Module Name   : audio_rcv_ctrl
// Project Name  : eth_audio_transmission
// Target Devices: Altera EP4CE10F17C8N
// Tool Versions : Quartus 13.0
// Description   : UDP
// 
// Revision      : V1.0
// Additional Comments:
// 
// 实验平台: 野火_征途Pro_FPGA开发板
// 公司    : http://www.embedfire.com
// 论坛    : http://www.firebbs.cn
// 淘宝    : https://fire-stm32.taobao.com
////////////////////////////////////////////////////////////////////////

module  audio_rcv_ctrl
(
    input   wire            eth_rx_clk      ,   //mii时钟,接收
    input   wire            sys_rst_n       ,   //复位信号，低电平有效
    input   wire            audio_bclk      ,   //音频位时钟
    input   wire            audio_send_done ,   //wm8978音频接收使能信号
    input   wire            rec_end         ,   //单包数据接收完成信号
    input   wire            rec_en          ,   //接收数据使能信号
    input   wire    [31:0]  rec_data        ,   //接收数据

    output  wire    [23:0]  audio_dac_data      //往wm8978发送的音频播放数据

);

//********************************************************************//
//****************** Parameter and Internal Signal *******************//
//********************************************************************//

//wire  define
wire    [23:0]  wr_data ;   //写fifo数据
wire            rd_en   ;   //读fifo使能

//reg   define
reg     rcv_flag    ;   //数据包接收完成标志信号

//********************************************************************//
//***************************** Main Code ****************************//
//********************************************************************//

//接收数据的前24位即为音频传输数据
assign  wr_data =   rec_data[23:0];

//数据包接收完成之后，将音频接收使能信号作为读fifo使能
assign  rd_en   =   audio_send_done &   rcv_flag;

//当数据包接收完成之后拉高接收标志信号
always@(posedge eth_rx_clk  or  negedge sys_rst_n)
    if(sys_rst_n == 1'b0)
        rcv_flag    <=  1'b0;
    else    if(rec_end == 1'b1)
        rcv_flag    <=  1'b1;

//------------ dcfifo_512x24_inst -------------
//例化的FIFO为：512深度24bit位宽的异步fifo
dcfifo_512x24   dcfifo_512x24_inst2
(
    .aclr   (~sys_rst_n     ), //异步复位信号
    .data   (wr_data        ), //写入FIFO数据
    .rdclk  (audio_bclk     ), //读FIFO时钟
    .rdreq  (rd_en          ), //读FIFO使能
    .wrclk  (eth_rx_clk     ), //写FIFO时钟
    .wrreq  (rec_en         ), //写FIFO使能
    .q      (audio_dac_data ), //读FIFO数据
    .rdusedw(               ), //FIFO中存储个数(读时钟采样)
    .wrusedw(               )  //FIFO中存储个数(写时钟采样)

);

endmodule
