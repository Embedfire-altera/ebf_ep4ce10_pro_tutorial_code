`timescale  1ns/1ns
////////////////////////////////////////////////////////////////////////
// Author        : EmbedFire
//Create Date    : 2019/09/03
// Module Name   : sd_write
// Project Name  : sd_hdmi_pic
// Target Devices: Altera EP4CE10F17C8N
// Tool Versions : Quartus 13.0
// Description   : SD卡数据写操作
//
// Revision      : V1.0
// Additional Comments:
// 
// 实验平台: 野火_征途Pro_FPGA开发板
// 公司    : http://www.embedfire.com
// 论坛    : http://www.firebbs.cn
// 淘宝    : https://fire-stm32.taobao.com
////////////////////////////////////////////////////////////////////////

module  sd_write
(
    input   wire            sys_clk         ,   //输入工作时钟,频率50MHz
    input   wire            sys_clk_shift   ,   //输入工作时钟,频率50MHz,相位偏移90度
    input   wire            sys_rst_n       ,   //输入复位信号,低电平有效
    input   wire            miso            ,   //主输入从输出信号
    input   wire            wr_en           ,   //数据写使能信号
    input   wire    [31:0]  wr_addr         ,   //写数据扇区地址
    input   wire    [15:0]  wr_data         ,   //写数据

    output  reg             cs_n            ,   //输出片选信号
    output  reg             mosi            ,   //主输出从输入信号
    output  wire            wr_busy         ,   //写操作忙信号
    output  wire            wr_req              //写数据请求信号
);

//********************************************************************//
//****************** Parameter and Internal Signal *******************//
//********************************************************************//
//parameter define
parameter   IDLE        =   3'b000  ,   //初始状态
            SEND_CMD24  =   3'b001  ,   //写命令CMD24发送状态
            CMD24_ACK   =   3'b011  ,   //CMD24响应状态
            WR_DATA     =   3'b010  ,   //写数据状态
            WR_BUSY     =   3'b110  ,   //SD卡写忙状态
            WR_END      =   3'b111  ;   //写结束状态
parameter   DATA_NUM    =   12'd256 ;   //待写入数据字节数
parameter   BYTE_HEAD   =   16'hfffe;   //写数据字节头

//wire  define
wire    [47:0]  cmd_wr      ;   //数据写指令

//reg   define
reg     [2:0]   state       ;   //状态机状态
reg     [7:0]   cnt_cmd_bit ;   //指令比特计数器
reg             ack_en      ;   //响应使能信号
reg     [7:0]   ack_data    ;   //响应数据
reg     [7:0]   cnt_ack_bit ;   //响应数据字节计数
reg     [11:0]  cnt_data_num;   //写入数据个数计数
reg     [3:0]   cnt_data_bit;   //写数据比特计数器
reg     [7:0]   busy_data   ;   //忙状态数据
reg     [2:0]   cnt_end     ;   //结束状态时钟计数
reg             miso_dly    ;   //主输入从输出信号打一拍

//********************************************************************//
//***************************** Main Code ****************************//
//********************************************************************//
//wr_busy:写操作忙信号
assign  wr_busy = (state != IDLE) ? 1'b1 : 1'b0;

//wr_req:写数据请求信号
assign  wr_req = ((cnt_data_num <= DATA_NUM - 1'b1) && (cnt_data_bit == 4'd15))
                ? 1'b1 : 1'b0;

//cmd_wr:数据写指令
assign  cmd_wr = {8'h58,wr_addr,8'hff};

//miso_dly:主输入从输出信号打一拍
always@(posedge sys_clk_shift or negedge sys_rst_n)
    if(sys_rst_n == 1'b0)
        miso_dly    <=  1'b0;
    else
        miso_dly    <=  miso;

//ack_en:响应使能信号
always@(posedge sys_clk_shift or negedge sys_rst_n)
    if(sys_rst_n == 1'b0)
        ack_en  <=  1'b0;
    else    if(cnt_ack_bit == 8'd15)
        ack_en  <=  1'b0;
    else    if((state == CMD24_ACK) && (miso == 1'b0)
                && (miso_dly == 1'b1) && (cnt_ack_bit == 8'd0))
        ack_en  <=  1'b1;
    else
        ack_en  <=  ack_en;

//ack_data:响应数据
//cnt_ack_bit:响应数据字节计数
always@(posedge sys_clk_shift or negedge sys_rst_n)
    if(sys_rst_n == 1'b0)
        begin
            ack_data    <=  8'b0;
            cnt_ack_bit <=  8'd0;
        end
    else    if(ack_en == 1'b1)
        begin
            cnt_ack_bit     <=  cnt_ack_bit + 8'd1;
            if(cnt_ack_bit < 8'd8)
                ack_data    <=  {ack_data[6:0],miso_dly};
            else
                ack_data    <=  ack_data;
        end
    else
        cnt_ack_bit <=  8'd0;

//busy_data:忙状态数据
always@(posedge sys_clk_shift or negedge sys_rst_n)
    if(sys_rst_n == 1'b0)
        busy_data   <=  8'd0;
    else    if(state == WR_BUSY)
        busy_data   <=  {busy_data[6:0],miso};
    else
        busy_data   <=  8'd0;

//state:状态机状态跳转
always@(posedge sys_clk or negedge sys_rst_n)
    if(sys_rst_n == 1'b0)
        state   <=  IDLE;
    else
        case(state)
            IDLE:
                if(wr_en == 1'b1)
                    state   <=  SEND_CMD24;
                else
                    state   <=  state;
            SEND_CMD24:
                if(cnt_cmd_bit == 8'd47)
                    state   <=  CMD24_ACK;
                else
                    state   <=  state;
            CMD24_ACK:
                if(cnt_ack_bit == 8'd15)
                    if(ack_data == 8'h00)
                        state   <=  WR_DATA;
                    else
                        state   <=  SEND_CMD24;
                else
                    state   <=  state;
            WR_DATA:
                if((cnt_data_num == (DATA_NUM + 1'b1))
                    && (cnt_data_bit == 4'd15))
                    state   <=  WR_BUSY;
                else
                    state   <=  state;
            WR_BUSY:
                if(busy_data == 8'hff)
                    state   <=  WR_END;
                else
                    state   <=  state;
            WR_END:
                if(cnt_end == 3'd7)
                    state   <=  IDLE;
                else
                    state   <=  state;
            default:state   <=  IDLE;
        endcase

//cs_n:输出片选信号
always@(posedge sys_clk or negedge sys_rst_n)
    if(sys_rst_n == 1'b0)
        cs_n    <=  1'b1;
    else    if(cnt_end == 3'd7)
        cs_n    <=  1'b1;
    else    if(wr_en == 1'b1)
        cs_n    <=  1'b0;
    else
        cs_n    <=  cs_n;

//cnt_cmd_bit:指令比特计数器
always@(posedge sys_clk or negedge sys_rst_n)
    if(sys_rst_n == 1'b0)
        cnt_cmd_bit     <=  8'd0;
    else    if(state == SEND_CMD24)
        cnt_cmd_bit     <=  cnt_cmd_bit + 8'd1;
    else
        cnt_cmd_bit     <=  8'd0;

//mosi:主输出从输入信号
always@(posedge sys_clk or negedge sys_rst_n)
    if(sys_rst_n == 1'b0)
        mosi    <=  1'b1;
    else    if(state == SEND_CMD24)
        mosi    <=  cmd_wr[8'd47 - cnt_cmd_bit];
    else    if(state == WR_DATA)
        if(cnt_data_num == 12'd0)
            mosi    <=  BYTE_HEAD[15 - cnt_data_bit];
        else    if((cnt_data_num >= 12'd1) && (cnt_data_num <= DATA_NUM))
            mosi    <=  wr_data[15 - cnt_data_bit];
        else
            mosi    <=  1'b1;
    else
        mosi    <=  1'b1;

//cnt_data_bit:写数据比特计数器
always@(posedge sys_clk or negedge sys_rst_n)
    if(sys_rst_n == 1'b0)
        cnt_data_bit    <=  4'd0;
    else    if(state == WR_DATA)
        cnt_data_bit    <=  cnt_data_bit + 4'd1;
    else
        cnt_data_bit    <=  4'd0;

//cnt_data_num:写入数据个数计数
always@(posedge sys_clk or negedge sys_rst_n)
    if(sys_rst_n == 1'b0)
        cnt_data_num    <=  12'd0;
    else    if(state == WR_DATA)
        if(cnt_data_bit == 4'd15)
            cnt_data_num    <=  cnt_data_num + 12'd1;
        else
            cnt_data_num    <=  cnt_data_num;
    else
        cnt_data_num    <=  12'd0;

//cnt_end:结束状态时钟计数
always@(posedge sys_clk or negedge sys_rst_n)
    if(sys_rst_n == 1'b0)
        cnt_end <=  3'd0;
    else    if(state == WR_END)
        cnt_end <=  cnt_end + 3'd1;
    else
        cnt_end <=  3'd0;

endmodule

