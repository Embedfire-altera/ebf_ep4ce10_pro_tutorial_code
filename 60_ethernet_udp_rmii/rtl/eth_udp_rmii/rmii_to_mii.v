`timescale  1ns/1ns
////////////////////////////////////////////////////////////////////////
// Author        : EmbedFire
// Create Date   : 2019/10/10
// Module Name   : rmii_to_mii
// Project Name  : eth_udp_rmii
// Target Devices: Altera EP4CE10F17C8N
// Tool Versions : Quartus 13.0
// Description   : rmii转mii
// 
// Revision      : V1.0
// Additional Comments:
// 
// 实验平台: 野火_征途Pro_FPGA开发板
// 公司    : http://www.embedfire.com
// 论坛    : http://www.firebbs.cn
// 淘宝    : https://fire-stm32.taobao.com
////////////////////////////////////////////////////////////////////////

module  rmii_to_mii
(
    input   wire            eth_rmii_clk,   //rmii时钟
    input   wire            eth_mii_clk ,   //mii时钟
    input   wire            sys_rst_n   ,   //复位信号
    input   wire            rx_dv       ,   //输入数据有效信号(rmii)
    input   wire    [1:0]   rx_data     ,   //输入数据(rmii)

    output  reg             eth_rx_dv   ,   //输入数据有效信号(mii)
    output  reg     [3:0]   eth_rx_data     //输入数据(mii)
);

//********************************************************************//
//****************** Parameter and Internal Signal *******************//
//********************************************************************//
reg             rx_dv_reg       ;   //输入数据有效信号寄存(rmii)
reg     [1:0]   rx_data_reg     ;   //输入数据寄存(rmii)
reg             rx_dv_reg1      ;   //rx_dv_reg寄存
reg             rx_dv_reg2      ;   //rx_dv_reg1寄存
reg             rx_dv_ture      ;   //真实的输入数据有效信号
reg             rx_dv_ture_reg  ;   //真实的输入数据有效信号打拍
reg     [1:0]   rx_data_reg1    ;   //rx_data_reg寄存
reg     [1:0]   rx_data_ture    ;   //有效的输入数据
reg             data_sw_en      ;   //数据拼接使能
reg     [3:0]   data            ;   //拼接后的数据

//********************************************************************//
//***************************** Main Code ****************************//
//********************************************************************//
//rx_dv:输入数据有效信号寄存(rmii)
always@(posedge eth_rmii_clk or negedge sys_rst_n)
    if(sys_rst_n == 1'b0)
        rx_dv_reg   <=  1'b0;
    else
        rx_dv_reg   <=  rx_dv;

//rx_data_reg:输入数据寄存(rmii)
always@(posedge eth_rmii_clk or negedge sys_rst_n)
    if(sys_rst_n == 1'b0)
        rx_data_reg <=  2'b0;
    else
        rx_data_reg <=  rx_data;

//rx_dv_reg1:rx_dv_reg寄存
always@(negedge eth_rmii_clk or negedge sys_rst_n)
    if(sys_rst_n == 1'b0)
        rx_dv_reg1  <=  1'b0;
    else    if(rx_dv_reg == 1'b1)
        if(rx_data_reg == 2'b1)
            rx_dv_reg1  <=  1'b1;
        else
            rx_dv_reg1  <=  rx_dv_reg1;
    else
        rx_dv_reg1  <=  1'b0;

//rx_dv_reg2:rx_dv_reg1寄存
always@(negedge eth_rmii_clk or negedge sys_rst_n)
    if(sys_rst_n == 1'b0)
        rx_dv_reg2  <=  1'b0;
    else
        rx_dv_reg2  <=  rx_dv_reg;

//rx_dv_ture:真实的输入数据有效信号
always@(negedge eth_rmii_clk or negedge sys_rst_n)
    if(sys_rst_n == 1'b0)
        rx_dv_ture  <=  1'b0;
    else    if((rx_dv_reg1) && (rx_dv_reg2))
        rx_dv_ture  <=  1'b1;
    else
        rx_dv_ture  <=  1'b0;

//rx_data_reg1:rx_data_reg寄存
always@(negedge eth_rmii_clk or negedge sys_rst_n)
    if(sys_rst_n == 1'b0)
        rx_data_reg1    <=  2'b0;
    else
        rx_data_reg1    <=  rx_data_reg;

//rx_data_ture:有效的输入数据
always@(negedge eth_rmii_clk or negedge sys_rst_n)
    if(sys_rst_n == 1'b0)
        rx_data_ture    <=  2'b0;
    else
        rx_data_ture    <=  rx_data_reg1;

//data_sw_en:数据拼接使能
always@(negedge eth_rmii_clk or negedge sys_rst_n)
    if(sys_rst_n == 1'b0)
        data_sw_en  <=  1'b0;
    else    if(rx_dv_ture == 1'b1)
        data_sw_en  <=  ~data_sw_en;
    else
        data_sw_en  <=  1'b0;

//data:拼接后的数据
always@(posedge eth_rmii_clk or negedge sys_rst_n)
    if(sys_rst_n == 1'b0)
        data    <=  4'b0;
    else    if((rx_dv_ture == 1'b1) && (data_sw_en == 1'b0))
        data    <=  {rx_data_reg1,rx_data_ture};
    else
        data    <=  data;

//rx_dv_ture_reg:真实的输入数据有效信号打一拍
always@(posedge eth_rmii_clk or negedge sys_rst_n)
    if(sys_rst_n == 1'b0)
        rx_dv_ture_reg  <=  1'b0;
    else
        rx_dv_ture_reg  <=  rx_dv_ture;


//eth_rx_dv:输入数据有效信号(mii)
always@(negedge eth_mii_clk or negedge sys_rst_n)
    if(sys_rst_n == 1'b0)
        eth_rx_dv   <=  1'b0;
    else
        eth_rx_dv   <=  rx_dv_ture_reg;

//eth_rx_data:输入数据(mii)
always@(negedge eth_mii_clk or negedge sys_rst_n)
    if(sys_rst_n == 1'b0)
        eth_rx_data <=  4'b0;
    else
        eth_rx_data <=  data;

endmodule