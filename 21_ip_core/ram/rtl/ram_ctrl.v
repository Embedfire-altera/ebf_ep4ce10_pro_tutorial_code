`timescale  1ns/1ns
/////////////////////////////////////////////////////////////////////////
// Author        : EmbedFire
// Create Date   : 2019/12/05
// Module Name   : ram_ctrl
// Project Name  : ram
// Target Devices: Altera EP4CE10F17C8N
// Tool Versions : Quartus 13.0
// Description   : ram控制模块
// 
// Revision      : V1.0
// Additional Comments:
// 
// 实验平台: 野火_征途Pro_FPGA开发板
// 公司    : http://www.embedfire.com
// 论坛    : http://www.firebbs.cn
// 淘宝    : https://fire-stm32.taobao.com
////////////////////////////////////////////////////////////////////////

module  ram_ctrl
(
    input   wire         sys_clk   , //系统时钟，频率50MHz
    input   wire         sys_rst_n , //复位信号，低有效
    input   wire         key1_flag , //按键1消抖后有效信号，作为写标志信号
    input   wire         key2_flag , //按键2消抖后有效信号，作为读标志信号
 
    output  reg          wr_en     , //输出写RAM使能，高点平有效
    output  reg          rd_en     , //输出读RAM使能，高电平有效
    output  reg  [7:0]   addr      , //输出读写RAM地址
    output  wire [7:0]   wr_data     //输出写RAM数据

);

//********************************************************************//
//****************** Parameter and Internal Signal *******************//
//********************************************************************//

//parameter define
parameter   CNT_MAX =   9_999_999;  //0.2s计数器最大值

//reg   define
reg     [23:0]  cnt_200ms       ;   //0.2s计数器

//********************************************************************//
//***************************** Main Code ****************************//
//********************************************************************//

//让写入的数据等于地址数，即写入数据0~255
assign  wr_data =   (wr_en == 1'b1) ? addr : 8'd0;

//wr_en:产生写RAM使能信号
always@(posedge sys_clk or  negedge sys_rst_n)
    if(sys_rst_n == 1'b0)
        wr_en   <=  1'b0;
    else    if(addr == 8'd255)
        wr_en  <=  1'b0;
    else    if(key1_flag == 1'b1)
        wr_en  <=  1'b1;

//rd_en:产生读RAM使能信号
always@(posedge sys_clk or  negedge sys_rst_n)
    if(sys_rst_n == 1'b0)
        rd_en   <=  1'b0;
    else    if(key2_flag == 1'b1 && wr_en == 1'b0)
        rd_en   <=  1'b1;
    else    if(key1_flag == 1'b1)
        rd_en   <=  1'b0;
    else
        rd_en   <=  rd_en;

//0.2s循环计数
always@(posedge sys_clk or  negedge sys_rst_n)
    if(sys_rst_n == 1'b0)
        cnt_200ms    <=  24'd0;
    else    if(cnt_200ms == CNT_MAX || key2_flag == 1'b1)
        cnt_200ms   <=  24'd0;
    else    if(rd_en == 1'b1)
        cnt_200ms   <=  cnt_200ms + 1'b1;

//写使能有效时，
always@(posedge sys_clk or  negedge sys_rst_n)
    if(sys_rst_n == 1'b0)
        addr    <=  8'd0;
    else    if((addr == 8'd255 && cnt_200ms == CNT_MAX) || 
                (addr == 8'd255 && wr_en == 1'b1) || 
                (key2_flag == 1'b1) || (key1_flag == 1'b1))
        addr    <=  8'd0;
    else    if((wr_en == 1'b1) || (rd_en == 1'b1 && cnt_200ms == CNT_MAX))
        addr    <=  addr + 1'b1;

endmodule
