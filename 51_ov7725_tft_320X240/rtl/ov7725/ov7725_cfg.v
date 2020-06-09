`timescale  1ns/1ns
////////////////////////////////////////////////////////////////////////
// Author        : EmbedFire
// Create Date   : 2019/09/25
// Module Name   : ov7725_cfg
// Project Name  : ov7725_tft_320x272
// Target Devices: Altera EP4CE10F17C8N
// Tool Versions : Quartus 13.0
// Description   : OV7725摄像头寄存器配置
// 
// Revision      : V1.0
// Additional Comments:
// 
// 实验平台: 野火_征途Pro_FPGA开发板
// 公司    : http://www.embedfire.com
// 论坛    : http://www.firebbs.cn
// 淘宝    : https://fire-stm32.taobao.com
////////////////////////////////////////////////////////////////////////

module  ov7725_cfg
(
    input   wire            sys_clk     ,   //系统时钟,由iic模块传入
    input   wire            sys_rst_n   ,   //系统复位,低有效
    input   wire            cfg_end     ,   //单个寄存器配置完成

    output  reg             cfg_start   ,   //单个寄存器配置触发信号
    output  wire    [15:0]  cfg_data    ,   //ID,REG_ADDR,REG_VAL
    output  reg             cfg_done        //寄存器配置完成
);

//********************************************************************//
//****************** Parameter and Internal Signal *******************//
//********************************************************************//

//parameter define
parameter   REG_NUM         =   7'd69   ;   //总共需要配置的寄存器个数
parameter   CNT_WAIT_MAX    =   10'd1023;   //寄存器配置等待计数最大值

//wire  define
wire    [15:0]  cfg_data_reg[REG_NUM-1:0]   ;   //寄存器配置数据暂存

//reg   define
reg     [9:0]   cnt_wait    ;   //寄存器配置等待计数器
reg     [6:0]   reg_num     ;   //配置寄存器个数

//********************************************************************//
//***************************** Main Code ****************************//
//********************************************************************//
//cnt_wait:寄存器配置等待计数器
always@(posedge sys_clk or negedge sys_rst_n)
    if(sys_rst_n == 1'b0)
        cnt_wait    <=  15'd0;
    else    if(cnt_wait < CNT_WAIT_MAX)
        cnt_wait    <=  cnt_wait + 1'b1;

//reg_num:配置寄存器个数
always@(posedge sys_clk or negedge sys_rst_n)
    if(sys_rst_n == 1'b0)
        reg_num <=  7'd0;
    else    if(cfg_end == 1'b1)
        reg_num <=  reg_num + 1'b1;

//cfg_start:单个寄存器配置触发信号
always@(posedge sys_clk or negedge sys_rst_n)
    if(sys_rst_n == 1'b0)
        cfg_start   <=  1'b0;
    else    if(cnt_wait == (CNT_WAIT_MAX - 1'b1))
        cfg_start   <=  1'b1;
    else    if((cfg_end == 1'b1) && (reg_num < REG_NUM))
        cfg_start   <=  1'b1;
    else
        cfg_start   <=  1'b0;

//cfg_done:寄存器配置完成
always@(posedge sys_clk or negedge sys_rst_n)
    if(sys_rst_n == 1'b0)
        cfg_done    <=  1'b0;
    else    if((reg_num == REG_NUM) && (cfg_end == 1'b1))
        cfg_done    <=  1'b1;

//cfg_data:ID,REG_ADDR,REG_VAL
assign  cfg_data = (cfg_done == 1'b1) ? 16'h0000 : cfg_data_reg[reg_num];

//----------------------------------------------------
//cfg_data_reg：寄存器配置数据暂存  ID   REG_ADDR REG_VAL
assign  cfg_data_reg[00]  =       {8'h3d,  8'h03};
assign  cfg_data_reg[01]  =       {8'h15,  8'h02};
assign  cfg_data_reg[02]  =       {8'h17,  8'h3f};
assign  cfg_data_reg[03]  =       {8'h18,  8'h50};
assign  cfg_data_reg[04]  =       {8'h19,  8'h07};
assign  cfg_data_reg[05]  =       {8'h1a,  8'h78};
assign  cfg_data_reg[06]  =       {8'h32,  8'h00};
assign  cfg_data_reg[07]  =       {8'h29,  8'h50};
assign  cfg_data_reg[08]  =       {8'h2a,  8'h00};
assign  cfg_data_reg[09]  =       {8'h2b,  8'h00};
assign  cfg_data_reg[10]  =       {8'h2c,  8'h78};
assign  cfg_data_reg[11]  =       {8'h0d,  8'h41};
assign  cfg_data_reg[12]  =       {8'h11,  8'h00};
assign  cfg_data_reg[13]  =       {8'h12,  8'h06};
assign  cfg_data_reg[14]  =       {8'h0c,  8'hd0};
assign  cfg_data_reg[15]  =       {8'h42,  8'h7f};
assign  cfg_data_reg[16]  =       {8'h4d,  8'h09};
assign  cfg_data_reg[17]  =       {8'h63,  8'hf0};
assign  cfg_data_reg[18]  =       {8'h64,  8'hff};
assign  cfg_data_reg[19]  =       {8'h65,  8'h00};
assign  cfg_data_reg[20]  =       {8'h66,  8'h00};
assign  cfg_data_reg[21]  =       {8'h67,  8'h00};
assign  cfg_data_reg[22]  =       {8'h13,  8'hff};
assign  cfg_data_reg[23]  =       {8'h0f,  8'hc5};
assign  cfg_data_reg[24]  =       {8'h14,  8'h11};
assign  cfg_data_reg[25]  =       {8'h22,  8'h98};
assign  cfg_data_reg[26]  =       {8'h23,  8'h03};
assign  cfg_data_reg[27]  =       {8'h24,  8'h40};
assign  cfg_data_reg[28]  =       {8'h25,  8'h30};
assign  cfg_data_reg[29]  =       {8'h26,  8'ha1};
assign  cfg_data_reg[30]  =       {8'h6b,  8'haa};
assign  cfg_data_reg[31]  =       {8'h13,  8'hff};
assign  cfg_data_reg[32]  =       {8'h90,  8'h0a};
assign  cfg_data_reg[33]  =       {8'h91,  8'h01};
assign  cfg_data_reg[34]  =       {8'h92,  8'h01};
assign  cfg_data_reg[35]  =       {8'h93,  8'h01};
assign  cfg_data_reg[36]  =       {8'h94,  8'h5f};
assign  cfg_data_reg[37]  =       {8'h95,  8'h53};
assign  cfg_data_reg[38]  =       {8'h96,  8'h11};
assign  cfg_data_reg[39]  =       {8'h97,  8'h1a};
assign  cfg_data_reg[40]  =       {8'h98,  8'h3d};
assign  cfg_data_reg[41]  =       {8'h99,  8'h5a};
assign  cfg_data_reg[42]  =       {8'h9a,  8'h1e};
assign  cfg_data_reg[43]  =       {8'h9b,  8'h3f};
assign  cfg_data_reg[44]  =       {8'h9c,  8'h25};
assign  cfg_data_reg[45]  =       {8'h9e,  8'h81};
assign  cfg_data_reg[46]  =       {8'ha6,  8'h06};
assign  cfg_data_reg[47]  =       {8'ha7,  8'h65};
assign  cfg_data_reg[48]  =       {8'ha8,  8'h65};
assign  cfg_data_reg[49]  =       {8'ha9,  8'h80};
assign  cfg_data_reg[50]  =       {8'haa,  8'h80};
assign  cfg_data_reg[51]  =       {8'h7e,  8'h0c};
assign  cfg_data_reg[52]  =       {8'h7f,  8'h16};
assign  cfg_data_reg[53]  =       {8'h80,  8'h2a};
assign  cfg_data_reg[54]  =       {8'h81,  8'h4e};
assign  cfg_data_reg[55]  =       {8'h82,  8'h61};
assign  cfg_data_reg[56]  =       {8'h83,  8'h6f};
assign  cfg_data_reg[57]  =       {8'h84,  8'h7b};
assign  cfg_data_reg[58]  =       {8'h85,  8'h86};
assign  cfg_data_reg[59]  =       {8'h86,  8'h8e};
assign  cfg_data_reg[60]  =       {8'h87,  8'h97};
assign  cfg_data_reg[61]  =       {8'h88,  8'ha4};
assign  cfg_data_reg[62]  =       {8'h89,  8'haf};
assign  cfg_data_reg[63]  =       {8'h8a,  8'hc5};
assign  cfg_data_reg[64]  =       {8'h8b,  8'hd7};
assign  cfg_data_reg[65]  =       {8'h8c,  8'he8};
assign  cfg_data_reg[66]  =       {8'h8d,  8'h20};
assign  cfg_data_reg[67]  =       {8'h0e,  8'h65};
assign  cfg_data_reg[68]  =       {8'h09,  8'h00};
//-------------------------------------------------------

endmodule
