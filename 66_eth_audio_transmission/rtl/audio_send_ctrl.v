`timescale  1ns/1ns
////////////////////////////////////////////////////////////////////////
// Author        : EmbedFire
// Create Date   : 2019/10/10
// Module Name   : audio_send_ctrl
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

module  audio_send_ctrl
(
    input   wire            audio_bclk    ,   //音频位时钟
    input   wire            sys_rst_n     ,   //复位信号
    input   wire            rcv_done      ,   //一次音频数据接受完成
    input   wire    [23:0]  adc_data      ,   //一次接受的音频数据
    input   wire            eth_tx_clk    ,   //mii时钟,发送
    input   wire            read_data_req ,   //读数据请求信号
    input   wire            send_end      ,   //单包数据发送完成信号

    output  reg             send_en       ,   //开始发送信号
    output  wire    [15:0]  send_data_num ,   //数据包发送有效数据字节数
    output  wire    [31:0]  send_data         //发送数据

);

//********************************************************************//
//****************** Parameter and Internal Signal *******************//
//********************************************************************//

//parameter define
parameter   DATA_CNT_NUM   =   9'd256;   //FIFO中存储个数为此值时开始发送

//wire  define
wire    [8:0]   data_cnt;   //FIFO中存储个数
wire    [23:0]  rd_data ;   //fifo读出数据

//reg   define
reg     eth_send_flag   ;  //发送状态标志信号

//********************************************************************//
//***************************** Main Code ****************************//
//********************************************************************//

//单包数据发送有效字节数：一个发送数据为32bit（4字节）
assign  send_data_num = {DATA_CNT_NUM,2'b0};

//音频数据为24位，以太网发送数据为32位，往高八位补零即可
assign  send_data   =   {8'd0,rd_data};

//发送状态标志信号：fifo内数据大于等于256时拉高，单包数据发送完成后拉低
 always@(posedge eth_tx_clk  or  negedge sys_rst_n)
    if(sys_rst_n == 1'b0)
        eth_send_flag   <=  1'b0;
    else    if(data_cnt >=  DATA_CNT_NUM)
        eth_send_flag   <=  1'b1;
    else    if(send_end == 1'b1)
        eth_send_flag   <=  1'b0;

//当FIFO内数据大于单包发送字节数时且不在发送状态时，拉高开始发送信号
always@(posedge eth_tx_clk  or  negedge sys_rst_n)
    if(sys_rst_n == 1'b0)
        send_en <=  1'b0;
    else    if(data_cnt >=  DATA_CNT_NUM && eth_send_flag == 1'b0)
        send_en <=  1'b1;   //拉高一个时钟发送信号
    else
        send_en <=  1'b0;

//********************************************************************//
//*************************** Instantiation **************************//
//********************************************************************//

//------------ dcfifo_512x24_inst -------------
//例化的FIFO为：512深度24bit位宽的异步fifo
dcfifo_512x24   dcfifo_512x24_inst1
(
    .aclr   (~sys_rst_n     ), //异步复位信号
    .data   (adc_data       ), //写入FIFO数据
    .rdclk  (eth_tx_clk     ), //读FIFO时钟
    .rdreq  (read_data_req  ), //读FIFO使能
    .wrclk  (audio_bclk     ), //写FIFO时钟
    .wrreq  (rcv_done       ), //写FIFO使能
    .q      (rd_data        ), //读FIFO数据
    .rdusedw(data_cnt       ), //FIFO中存储个数(读时钟采样)
    .wrusedw(               )  //FIFO中存储个数(写时钟采样)

);

endmodule