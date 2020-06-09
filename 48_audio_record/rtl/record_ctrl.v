`timescale  1ns/1ns
////////////////////////////////////////////////////////////////////////
// Author        : EmbedFire
// Create Date   : 2019/09/17
// Module Name   : record_ctrl
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

module  record_ctrl
#(
    parameter  TIME_RECORD = 24'd11520000   //定义最大录音时长,120s
)
(
    input   wire            sys_clk         ,   //系统时钟
    input   wire            clk             ,   //模块驱动时钟
    input   wire            sys_rst_n       ,   //复位信号
    input   wire            key_record      ,   //录音按键
    input   wire            key_broadcast   ,   //播放按键
    input   wire            record_flag     ,   //录音按键有效信号
    input   wire            broadcast_flag  ,   //播放按键有效信号
    input   wire            sdram_init_end  ,   //SDRAM初始化完成标志信号
    input   wire            rcv_done        ,   //一次音频数据接收完成
    input   wire            send_done       ,   //一次音频数据发送完成
    input   wire    [15:0]  adc_data        ,   //输入音频数据
    input   wire    [15:0]  rd_data         ,   //SDRAM读出的数据

    output  reg     [15:0]  wr_data         ,   //写入SDRAM数据
    output  reg     [15:0]  dac_data        ,   //输出音频数据
    output  reg             wr_en           ,   //SDRAM写FIFO写请求
    output  reg             rd_en           ,   //SDRAM读FIFO读请求
    output  wire            p_record_flag   ,   //录音按键上升沿
    output  wire            p_broadcast_falg    //播放按键上升沿

);

//********************************************************************//
//****************** Parameter and Internal Signal *******************//
//********************************************************************//

//reg   define
reg    [23:0]  record_cnt          ;   //录音时长计数器
reg    [23:0]  broadcast_cnt       ;   //播放时长计数器
reg            sdram_init_end_d1   ;   //sdram初始化完成信号打一拍信号
reg            sdram_init_end_d2   ;   //sdram初始化完成信号打两拍信号
reg            record_flag_t       ;   //录音按键有效信号采样信号
reg            record_flag_t_d1    ;   //录音按键有效信号打一拍信号
reg            record_flag_t_d2    ;   //录音按键有效信号打两拍信号
reg            broadcast_flag_t    ;   //播放按键有效信号采样信号
reg            broadcast_flag_t_d1 ;   //播放按键信号打一拍信号
reg            broadcast_flag_t_d2 ;   //播放按键信号打两拍信号
reg            record              ;   //录音信号
reg            broadcast           ;   //播放信号

//********************************************************************//
//***************************** Main Code ****************************//
//********************************************************************//

//对录音、播放按键有效信号采上升沿即为该时钟下的按键有效采样信号
assign  p_record_flag   =   record_flag_t_d1  &   ~record_flag_t_d2;
assign  p_broadcast_falg   =  broadcast_flag_t_d1  &  ~broadcast_flag_t_d2;

//对sdram_init_end打拍，消除亚稳态
always@(posedge clk or  negedge sys_rst_n)
    if(sys_rst_n == 1'b0)
        begin
            sdram_init_end_d1   <=  1'b0;
            sdram_init_end_d2   <=  1'b0;
        end
    else
        begin
            sdram_init_end_d1   <=  sdram_init_end;
            sdram_init_end_d2   <=  sdram_init_end_d1;
        end

//record_flag_t：用系统时钟对录音按键有效信号采样
always@(posedge sys_clk or  negedge sys_rst_n)
    if(sys_rst_n == 1'b0)
        record_flag_t    <=  1'b0;
    else    if(record_flag  ==  1'b1)
        record_flag_t    <=  1'b1;
    else    if(key_record == 1'b1)
        record_flag_t    <=  1'b0;
    else
        record_flag_t    <=  record_flag_t;

// broadcast_flag_t ：用系统时钟对播放按键有效信号采样
always@(posedge sys_clk or  negedge sys_rst_n)
    if(sys_rst_n == 1'b0)
        broadcast_flag_t <=  1'b0;
    else    if(broadcast_flag   ==  1'b1)
        broadcast_flag_t <=  1'b1;
    else    if(key_broadcast == 1'b1)
        broadcast_flag_t    <=  1'b0;
    else
        broadcast_flag_t    <=  broadcast_flag_t;

//对采样有效信号延时打拍，获得上升沿标志信号
//该标志信号即为能被该模块时钟沿采到的按键有效信号
always@(posedge clk or  negedge sys_rst_n)
    if(sys_rst_n == 1'b0)
        begin
            record_flag_t_d1    <=  1'b0;
            record_flag_t_d2    <=  1'b0;
            broadcast_flag_t_d1 <=  1'b0;
            broadcast_flag_t_d2 <=  1'b0;
        end
    else
        begin
            record_flag_t_d1    <=  record_flag_t   ;
            record_flag_t_d2    <=  record_flag_t_d1;
            broadcast_flag_t_d1 <=  broadcast_flag_t;
            broadcast_flag_t_d2 <=  broadcast_flag_t_d1;
        end

//record：录音信号
always@(posedge clk or  negedge sys_rst_n)
    if(sys_rst_n == 1'b0)
        record  <=  1'b0;
    else    if(record_cnt == TIME_RECORD)
        record  <=  1'b0;
    else    if(p_record_flag == 1'b1)
        record  <=  ~record;
    else
        record  <=  record;

//broadcast:播放信号
always@(posedge clk or  negedge sys_rst_n)
    if(sys_rst_n == 1'b0)
        broadcast   <=  1'b0;
    else    if(p_broadcast_falg == 1'b1 && record == 1'b0)
        broadcast   <=  1'b1;
    else    if( broadcast_cnt == record_cnt || p_record_flag == 1'b1)
        broadcast   <=  1'b0;
    else
        broadcast   <=  broadcast;

//wr_en:写使能信号的拉高
always@(posedge clk or  negedge sys_rst_n)
    if(sys_rst_n == 1'b0)
        wr_en   <=  1'b0;
    else    if(record == 1'b1 && sdram_init_end_d2 == 1'b1 &&
                        record_cnt < TIME_RECORD && rcv_done == 1'b1)
        wr_en   <=  1'b1;
    else
        wr_en   <=  1'b0;

//record_cnt:录音时长计数器
always@(posedge clk or  negedge sys_rst_n)
    if(sys_rst_n == 1'b0)
        record_cnt  <=  1'b0;
    else    if(p_record_flag == 1'b1 && record == 1'b0)
        record_cnt  <=  1'b0;
    else    if(wr_en == 1'b1 )
        record_cnt  <=  record_cnt  +  1'b1;
    else
        record_cnt  <=  record_cnt;

//wr_data:录音有效时写入的数据为WM8978传来的录音数据
always@(posedge clk or  negedge sys_rst_n)
    if(sys_rst_n == 1'b0)
        wr_data   <=  16'd0;
    else    if(record == 1'b1)
        wr_data   <=  adc_data;
    else
        wr_data   <=  16'd0;

//rd_en:写使能信号的拉高
always@(posedge clk or  negedge sys_rst_n)
    if(sys_rst_n == 1'b0)
        rd_en   <=  1'b0;
    else    if(broadcast == 1'b1 && sdram_init_end_d2 == 1'b1 
                                            && send_done == 1'b1)
        rd_en   <=  1'b1;
    else
        rd_en   <=  1'b0;

//broadcast_cnt:播放时长计数器
always@(posedge clk or  negedge sys_rst_n)
    if(sys_rst_n == 1'b0)
        broadcast_cnt  <=  1'b0;
    else    if(p_broadcast_falg == 1'b1 || broadcast == record_cnt)
        broadcast_cnt   <=  1'b0;
    else    if(rd_en == 1'b1)
        broadcast_cnt   <=  broadcast_cnt   +   1'b1;
    else
        broadcast_cnt   <=  broadcast_cnt;

//dac_data:播放有效时读出的数据给WM8978播放
always@(posedge clk or  negedge sys_rst_n)
    if(sys_rst_n == 1'b0)
        dac_data   <=  16'd0;
    else    if(broadcast == 1'b1)
        dac_data   <=  rd_data;
    else
        dac_data    <=  16'd0;

endmodule
