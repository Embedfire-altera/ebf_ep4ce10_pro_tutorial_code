`timescale  1ns/1ns
////////////////////////////////////////////////////////////////////////
// Author        : EmbedFire
// Create Date   : 2018/03/27
// Module Name   : flash_seq_wr_ctrl
// Project Name  : spi_flash_seq_wr
// Target Devices: Altera EP4CE10F17C8N
// Tool Versions : Quartus 13.0
// Description   : flash连续写模块
// 
// Revision      : V1.0
// Additional Comments:
// 
// 实验平台: 野火_征途Pro_FPGA开发板
// 公司    : http://www.embedfire.com
// 论坛    : http://www.firebbs.cn
// 淘宝    : https://fire-stm32.taobao.com
////////////////////////////////////////////////////////////////////////

module  flash_seq_wr_ctrl(

    input   wire            sys_clk     ,   //系统时钟，频率50MHz
    input   wire            sys_rst_n   ,   //复位信号,低电平有效
    input   wire            pi_flag     ,   //数据标志信号
    input   wire    [7:0]   pi_data     ,   //写入数据

    output  reg             sck         ,   //串行时钟
    output  reg             cs_n        ,   //片选信号
    output  reg             mosi            //主输出从输入数据

);

//********************************************************************//
//****************** Parameter and Internal Signal *******************//
//********************************************************************//
//parameter define
parameter   IDLE    =   4'b0001 ,   //初始状态
            WR_EN   =   4'b0010 ,   //写状态
            DELAY   =   4'b0100 ,   //等待状态
            PP      =   4'b1000 ;   //扇区擦除状态
parameter   WR_EN_INST  =   8'b0000_0110,   //写使能指令
            PP_INST     =   8'b0000_0010;   //扇区擦除指令
parameter   ADDR        =   24'h00_04_25;   //数据写入地址

//reg   define
reg     [23:0]  addr_reg;   //数据写入地址寄存器
reg     [23:0]  addr    ;   //数据写入地址

reg     [4:0]   cnt_clk ;   //系统时钟计数器
reg     [3:0]   state   ;   //状态机状态
reg     [3:0]   cnt_byte;   //字节计数器
reg     [1:0]   cnt_sck ;   //串行时钟计数器
reg     [2:0]   cnt_bit ;   //比特计数器

//********************************************************************//
//***************************** Main Code ****************************//
//********************************************************************//

//cnt_clk:系统时钟计数器，用以记录单个字节
always@(posedge sys_clk or  negedge sys_rst_n)
    if(sys_rst_n == 1'b0)
        cnt_clk  <=  5'd0;
    else    if(state != IDLE)
        cnt_clk  <=  cnt_clk + 1'b1;

//cnt_byte:记录输出字节个数和等待时间
always@(posedge sys_clk or  negedge sys_rst_n)
    if(sys_rst_n == 1'b0)
        cnt_byte    <=  4'd0;
    else    if((cnt_clk == 5'd31) && (cnt_byte == 4'd10))
        cnt_byte    <=  4'd0;
    else    if(cnt_clk == 31)
        cnt_byte    <=  cnt_byte + 1'b1;

//cnt_sck:串行时钟计数器，用以生成串行时钟
always@(posedge sys_clk or  negedge sys_rst_n)
    if(sys_rst_n == 1'b0)
        cnt_sck <=  2'd0;
    else    if((state == WR_EN) && (cnt_byte == 1'b1))
        cnt_sck <=  cnt_sck + 1'b1;
    else    if((state == PP) && (cnt_byte >= 4'd5) && (cnt_byte <= 4'd9))
        cnt_sck <=  cnt_sck + 1'b1;

//addr_reg:数据写入地址寄存器
always@(posedge sys_clk or  negedge sys_rst_n)
    if(sys_rst_n == 1'b0)
        addr_reg    <=  ADDR;
    else    if(pi_flag == 1'b1)
        addr_reg    <=  addr_reg + 1'b1 ;

//addr:数据写入地址
always@(posedge sys_clk or  negedge sys_rst_n)
    if(sys_rst_n == 1'b0)
        addr    <=  24'd0;
    else    if(pi_flag == 1'b1)
        addr    <=  addr_reg;

//cs_n:片选信号
always@(posedge sys_clk or  negedge sys_rst_n)
    if(sys_rst_n == 1'b0)
        cs_n    <=  1'b1;
    else    if(pi_flag == 1'b1)
        cs_n    <=  1'b0;
    else    if((cnt_byte == 4'd2) && (cnt_clk == 5'd31) && (state == WR_EN))
        cs_n    <=  1'b1;
    else    if((cnt_byte == 4'd3) && (cnt_clk == 5'd31) && (state == DELAY))
        cs_n    <=  1'b0;
    else    if((cnt_byte == 4'd10) && (cnt_clk == 5'd31) && (state == PP))
        cs_n    <=  1'b1;

//sck:输出串行时钟
always@(posedge sys_clk or  negedge sys_rst_n)
    if(sys_rst_n == 1'b0)
        sck <=  1'b0;
    else    if(cnt_sck == 2'd0)
        sck <=  1'b0;
    else    if(cnt_sck == 2'd2)
        sck <=  1'b1;

//cnt_bit:高低位对调，控制mosi输出
always@(posedge sys_clk or  negedge sys_rst_n)
    if(sys_rst_n == 1'b0)
        cnt_bit <=  3'd0;
    else    if(cnt_sck == 2'd2)
        cnt_bit <=  cnt_bit + 1'b1;

//state:两段式状态机第一段，状态跳转
always@(posedge sys_clk or  negedge sys_rst_n)
    if(sys_rst_n == 1'b0)
        state   <=  IDLE;
    else
    case(state)
        IDLE:   if(pi_flag == 1'b1)
                state   <=  WR_EN;
        WR_EN:  if((cnt_byte == 4'd2) && (cnt_clk == 5'd31))
                state   <=  DELAY;
        DELAY:  if((cnt_byte == 4'd3) && (cnt_clk == 5'd31))
                state   <=  PP;
        PP:     if((cnt_byte == 4'd10) && (cnt_clk == 5'd31))
                state   <=  IDLE;
        default:    state   <=  IDLE;
    endcase

//mosi:两段式状态机第二段，逻辑输出
always@(posedge sys_clk or  negedge sys_rst_n)
    if(sys_rst_n == 1'b0)
        mosi    <=  1'b0;
    else    if((state == WR_EN) && (cnt_byte == 4'd2))
        mosi    <=  1'b0;
    else    if((state == PP) && (cnt_byte == 4'd10))
        mosi    <=  1'b0;
    else    if((state == WR_EN) && (cnt_byte == 4'd1) && (cnt_sck == 5'd0))
        mosi    <=  WR_EN_INST[7 - cnt_bit];    //写使能指令
    else    if((state == PP) && (cnt_byte == 4'd5) && (cnt_sck == 5'd0))
        mosi    <=  PP_INST[7 - cnt_bit];       //扇区擦除指令
    else    if((state == PP) && (cnt_byte == 4'd6) && (cnt_sck == 5'd0))
        mosi    <=  addr[23 - cnt_bit];         //扇区地址
    else    if((state == PP) && (cnt_byte == 4'd7) && (cnt_sck == 5'd0))
        mosi    <=  addr[15 - cnt_bit];         //页地址
    else    if((state == PP) && (cnt_byte == 4'd8) && (cnt_sck == 5'd0))
        mosi    <=  addr[7 - cnt_bit];          //字节地址
    else    if((state == PP) && (cnt_byte == 4'd9) && (cnt_sck == 5'd0))
        mosi    <=  pi_data[7 - cnt_bit];       //写入数据

endmodule
