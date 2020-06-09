`timescale  1ns/1ns
////////////////////////////////////////////////////////////////////////
// Author        : EmbedFire
// Create Date   : 2019/10/10
// Module Name   : mii_to_rmii
// Project Name  : eth_ov7725_rgb
// Target Devices: Altera EP4CE10F17C8N
// Tool Versions : Quartus 13.0
// Description   : mii转rmii
// 
// Revision      : V1.0
// Additional Comments:
// 
// 实验平台: 野火_征途Pro_FPGA开发板
// 公司    : http://www.embedfire.com
// 论坛    : http://www.firebbs.cn
// 淘宝    : https://fire-stm32.taobao.com
////////////////////////////////////////////////////////////////////////

module  mii_to_rmii
(
    input   wire            eth_mii_clk ,   //mii时钟
    input   wire            eth_rmii_clk,   //rmii时钟
    input   wire            sys_rst_n   ,   //复位信号
    input   wire            tx_dv       ,   //输出数据有效信号(mii)
    input   wire    [3:0]   tx_data     ,   //输出数据(mii)

    output  reg             eth_tx_dv   ,   //输出数据有效信号(rmii)
    output  reg     [1:0]   eth_tx_data     //输出数据(rmii)
);

//********************************************************************//
//****************** Parameter and Internal Signal *******************//
//********************************************************************//
reg             tx_dv_reg       ;   //输出数据有效信号打一拍(mii)
reg     [3:0]   tx_data_reg     ;   //输出数据打一拍(mii)
reg             rd_flag         ;   //eth_tx_data_reg读使能信号
reg     [1:0]   eth_tx_data_reg ;   //输出数据打一拍(rmii)

//********************************************************************//
//***************************** Main Code ****************************//
//********************************************************************//
//tx_dv_reg:输出数据有效信号打一拍(mii)
always@(negedge eth_rmii_clk or negedge sys_rst_n)
    if(sys_rst_n == 1'b0)
        tx_dv_reg   <=  1'b0;
    else
        tx_dv_reg   <=  tx_dv;

//tx_data_reg:输出数据打一拍(mii)
always@(negedge eth_rmii_clk or negedge sys_rst_n)
    if(sys_rst_n == 1'b0)
        tx_data_reg   <=  4'b0;
    else
        tx_data_reg   <=  tx_data;

//rd_flag:eth_tx_data_reg读使能信号
always@(negedge eth_rmii_clk or negedge sys_rst_n)
    if(sys_rst_n == 1'b0)
        rd_flag <=  1'b0;
    else    if(tx_dv_reg == 1'b1)
        rd_flag <=  ~rd_flag;
    else
        rd_flag <=  1'b0;

//eth_tx_data_reg:输出数据打一拍(rmii)
always@(posedge eth_rmii_clk or negedge sys_rst_n)
    if(sys_rst_n == 1'b0)
        eth_tx_data_reg <=  2'b0;
    else    if(tx_dv_reg == 1'b1)
        if(rd_flag == 1'b0)
            eth_tx_data_reg <=  {tx_data_reg[1:0]};
        else    if(rd_flag == 1'b1)
            eth_tx_data_reg <=  {tx_data_reg[3:2]};
    else
        eth_tx_data_reg <=  1'b0;

//eth_tx_dv:输出数据有效信号(rmii)
always@(negedge eth_rmii_clk or negedge sys_rst_n)
    if(sys_rst_n == 1'b0)
        eth_tx_dv   <=  1'b0;
    else
        eth_tx_dv   <=  tx_dv_reg;

//eth_tx_data:输出数据(rmii)
always@(negedge eth_rmii_clk or negedge sys_rst_n)
    if(sys_rst_n == 1'b0)
        eth_tx_data   <=  1'b0;
    else
        eth_tx_data   <=  eth_tx_data_reg;

endmodule
