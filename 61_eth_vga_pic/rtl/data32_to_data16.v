`timescale  1ns/1ns
////////////////////////////////////////////////////////////////////////
// Author        : EmbedFire
// Create Date   : 2019/10/20
// Module Name   : data32_to_data16
// Project Name  : eth_vga_pic
// Target Devices: Altera EP4CE10F17C8N
// Tool Versions : Quartus 13.0
// Description   : 32位数据转16位数据
// 
// Revision      : V1.0
// Additional Comments:
// 
// 实验平台: 野火_征途Pro_FPGA开发板
// 公司    : http://www.embedfire.com
// 论坛    : http://www.firebbs.cn
// 淘宝    : https://fire-stm32.taobao.com
////////////////////////////////////////////////////////////////////////

module  data32_to_data16
(
    input   wire            sys_clk     ,   //系统时钟
    input   wire            sys_rst_n   ,   //复位信号,低有效
    input   wire            rec_en_in   ,   //输入32位数据使能信号
    input   wire    [31:0]  rec_data_in ,   //输入32位数据

    output  reg             rec_en_out  ,   //输出16位数据使能信号
    output  reg     [15:0]  rec_data_out    //输出16位数据
);


//********************************************************************//
//****************** Parameter and Internal Signal *******************//
//********************************************************************//
//reg   define
reg             rec_en_in_d1;
reg             rec_en_in_d2;
reg             rec_en_in_d3;
reg             rec_en_in_d4;   //输入32位数据使能信号打拍

//********************************************************************//
//***************************** Main Code ****************************//
//********************************************************************//
//rec_en_in_d1,rec_en_in_d2,rec_en_in_d3,rec_en_in_d4
//输入32位数据使能信号打拍
always@(posedge sys_clk or negedge sys_rst_n)
    if(sys_rst_n == 1'b0)
        begin
            rec_en_in_d1    <=  1'b0;
            rec_en_in_d2    <=  1'b0;
            rec_en_in_d3    <=  1'b0;
            rec_en_in_d4    <=  1'b0;
        end
    else
        begin
            rec_en_in_d1    <=  rec_en_in;
            rec_en_in_d2    <=  rec_en_in_d1;
            rec_en_in_d3    <=  rec_en_in_d2;
            rec_en_in_d4    <=  rec_en_in_d3;
        end

//rec_en_out:输出16位数据使能信号
always@(posedge sys_clk or negedge sys_rst_n)
    if(sys_rst_n == 1'b0)
        rec_en_out  <=  1'b0;
    else    if((rec_en_in == 1'b1) || (rec_en_in_d4 == 1'b1))
        rec_en_out  <=  1'b1;
    else
        rec_en_out  <=  1'b0;

//rec_data_out:输出16位数据
always@(posedge sys_clk or negedge sys_rst_n)
    if(sys_rst_n == 1'b0)
        rec_data_out <= 16'b0;
    else    if(rec_en_in == 1'b1)
        rec_data_out <= rec_data_in[31:16];
    else    if(rec_en_in_d4 == 1'b1)
        rec_data_out <= rec_data_in[15:0];
    else
        rec_data_out <= rec_data_out;

endmodule 