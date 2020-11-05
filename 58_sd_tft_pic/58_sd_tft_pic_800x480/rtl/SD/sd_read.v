`timescale  1ns/1ns
////////////////////////////////////////////////////////////////////////
// Author        : EmbedFire
//Create Date    : 2019/09/03
// Module Name   : sd_read
// Project Name  : sd_tft_pic
// Target Devices: Altera EP4CE10F17C8N
// Tool Versions : Quartus 13.0
// Description   : SD卡数据读操作
//
// Revision      : V1.0
// Additional Comments:
// 
// 实验平台: 野火_征途Pro_FPGA开发板
// 公司    : http://www.embedfire.com
// 论坛    : http://www.firebbs.cn
// 淘宝    : https://fire-stm32.taobao.com
////////////////////////////////////////////////////////////////////////

module  sd_read
(
    input   wire            sys_clk         ,   //输入工作时钟,频率50MHz
    input   wire            sys_clk_shift   ,   //输入工作时钟,频率50MHz,相位偏移90度
    input   wire            sys_rst_n       ,   //输入复位信号,低电平有效
    input   wire            miso            ,   //主输入从输出信号
    input   wire            rd_en           ,   //数据读使能信号
    input   wire    [31:0]  rd_addr         ,   //读数据扇区地址

    output  wire            rd_busy         ,   //读操作忙信号
    output  reg             rd_data_en      ,   //读数据标志信号
    output  reg     [15:0]  rd_data         ,   //读数据
    output  reg             cs_n            ,   //片选信号
    output  reg             mosi                //主输出从输入信号
);

//********************************************************************//
//****************** Parameter and Internal Signal *******************//
//********************************************************************//
//parameter define
parameter   IDLE        =   3'b000  ,   //初始状态
            SEND_CMD17  =   3'b001  ,   //读命令CMD17发送状态
            CMD17_ACK   =   3'b011  ,   //CMD17响应状态
            RD_DATA     =   3'b010  ,   //读数据状态
            RD_END      =   3'b110  ;   //读结束状态
parameter   DATA_NUM    =   12'd256 ;   //待读取数据字节数

//wire  define
wire    [47:0]  cmd_rd      ;   //数据读指令

//reg   define
reg     [2:0]   state       ;   //状态机状态
reg     [7:0]   cnt_cmd_bit ;   //指令比特计数器
reg             ack_en      ;   //响应使能信号
reg     [7:0]   ack_data    ;   //响应数据
reg     [7:0]   cnt_ack_bit ;   //响应数据字节计数
reg     [11:0]  cnt_data_num;   //读出数据个数计数
reg     [3:0]   cnt_data_bit;   //读数据比特计数器
reg     [2:0]   cnt_end     ;   //结束状态时钟计数
reg             miso_dly    ;   //主输入从输出信号打一拍
reg     [15:0]  rd_data_reg ;   //读出数据寄存
reg     [15:0]  byte_head   ;   //读数据字节头
reg             byte_head_en;   //读数据字节头使能

//********************************************************************//
//***************************** Main Code ****************************//
//********************************************************************//
//rd_busy:读操作忙信号
assign  rd_busy = (state != IDLE) ? 1'b1 : 1'b0;

//cmd_rd:数据读指令
assign  cmd_rd = {8'h51,rd_addr,8'hff};

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
    else    if((state == CMD17_ACK) && (miso == 1'b0)
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

//state:状态机状态跳转
always@(posedge sys_clk or negedge sys_rst_n)
    if(sys_rst_n == 1'b0)
        state   <=  IDLE;
    else
        case(state)
            IDLE:
                if(rd_en == 1'b1)
                    state   <=  SEND_CMD17;
                else
                    state   <=  state;
            SEND_CMD17:
                if(cnt_cmd_bit == 8'd47)
                    state   <=  CMD17_ACK;
                else
                    state   <=  state;
            CMD17_ACK:
                if(cnt_ack_bit == 8'd15)
                    if(ack_data == 8'h00)
                        state   <=  RD_DATA;
                    else
                        state   <=  SEND_CMD17;
                else
                    state   <=  state;
            RD_DATA:
                if((cnt_data_num == (DATA_NUM + 1'b1))
                    && (cnt_data_bit == 4'd15))
                    state   <=  RD_END;
                else
                    state   <=  state;
            RD_END:
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
    else    if(rd_en == 1'b1)
        cs_n    <=  1'b0;
    else
        cs_n    <=  cs_n;

//cnt_cmd_bit:指令比特计数器
always@(posedge sys_clk or negedge sys_rst_n)
    if(sys_rst_n == 1'b0)
        cnt_cmd_bit     <=  8'd0;
    else    if(state == SEND_CMD17)
        cnt_cmd_bit     <=  cnt_cmd_bit + 8'd1;
    else
        cnt_cmd_bit     <=  8'd0;

//mosi:主输出从输入信号
always@(posedge sys_clk or negedge sys_rst_n)
    if(sys_rst_n == 1'b0)
        mosi    <=  1'b1;
    else    if(state == SEND_CMD17)
        mosi    <=  cmd_rd[8'd47 - cnt_cmd_bit];
    else
        mosi    <=  1'b1;

//byte_head:读数据字节头
always@(posedge sys_clk_shift or negedge sys_rst_n)
    if(sys_rst_n == 1'b0)
        byte_head   <=  16'b0;
    else    if(byte_head_en == 1'b0)
        byte_head   <=  16'b0;
    else    if(byte_head_en == 1'b1)
        byte_head   <=  {byte_head[14:0],miso};
    else
        byte_head   <=  byte_head;

//byte_head_en:读数据字节头使能
always@(posedge sys_clk or negedge sys_rst_n)
    if(sys_rst_n == 1'b0)
        byte_head_en    <=  1'b0;
    else    if(byte_head == 16'hfffe)
        byte_head_en    <=  1'b0;
    else    if((state == RD_DATA) && (cnt_data_num == 12'd0)
                && (cnt_data_bit == 4'd0))
        byte_head_en    <=  1'b1;
    else
        byte_head_en    <=  byte_head_en;

//cnt_data_bit:读数据比特计数器
always@(posedge sys_clk or negedge sys_rst_n)
    if(sys_rst_n == 1'b0)
        cnt_data_bit    <=  4'd0;
    else    if((state == RD_DATA) && (cnt_data_num >= 12'd1))
        cnt_data_bit    <=  cnt_data_bit + 4'd1;
    else
        cnt_data_bit    <=  4'd0;

//cnt_data_num:读出数据个数计数
always@(posedge sys_clk or negedge sys_rst_n)
    if(sys_rst_n == 1'b0)
        cnt_data_num    <=  12'd0;
    else    if(state == RD_DATA)
        if((cnt_data_bit == 4'd15) || (byte_head == 16'hfffe))
            cnt_data_num    <=  cnt_data_num + 12'd1;
        else
            cnt_data_num    <=  cnt_data_num;
    else
        cnt_data_num    <=  12'd0;

//rd_data_reg:读出数据寄存
always@(posedge sys_clk_shift or negedge sys_rst_n)
    if(sys_rst_n == 1'b0)
        rd_data_reg <=  16'd0;
    else    if((state == RD_DATA) && (cnt_data_num >= 12'd1)
                && (cnt_data_num <= DATA_NUM))
        rd_data_reg <=  {rd_data_reg[14:0],miso};
    else
        rd_data_reg <=  16'd0;

//rd_data_en:读数据标志信号
//rd_data:读数据
always@(posedge sys_clk or negedge sys_rst_n)
    if(sys_rst_n == 1'b0)
        begin
            rd_data_en  <=  1'b0;
            rd_data     <=  16'd0;
        end
    else    if(state == RD_DATA)
        begin
            if((cnt_data_bit == 4'd15) && (cnt_data_num <= DATA_NUM))
                begin
                    rd_data_en  <=  1'b1;
                    rd_data     <=  rd_data_reg;
                end
            else
                begin
                    rd_data_en  <=  1'b0;
                    rd_data     <=  rd_data;
                end
        end
    else
        begin
            rd_data_en  <=  1'b0;
            rd_data     <=  16'd0;
        end

//cnt_end:结束状态时钟计数
always@(posedge sys_clk or negedge sys_rst_n)
    if(sys_rst_n == 1'b0)
        cnt_end <=  3'd0;
    else    if(state == RD_END)
        cnt_end <=  cnt_end + 3'd1;
    else
        cnt_end <=  3'd0;

endmodule
