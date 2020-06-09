`timescale  1ns/1ns
//////////////////////////////////////////////////////////////////////////////////
// Author: EmbedFire
// Create Date: 2018/03/25
// Module Name: tb_data32_to_data16
// Project Name: eth_vga_pic
// Target Devices: Altera EP4CE10F17C8N
// Tool Versions: Quartus 13.0
// Description: 32位数据转16位数据
//
// Revision:V1.1
// Additional Comments:
//
// 实验平台:野火FPGA开发板
// 公司    :http://www.embedfire.com
// 论坛    :http://www.firebbs.cn
// 淘宝    :https://fire-stm32.taobao.com
//////////////////////////////////////////////////////////////////////////////////

module  tb_data32_to_data16();

//********************************************************************//
//****************** Parameter and Internal Signal *******************//
//********************************************************************//
//wire  define
wire            rec_en_out  ;   //输出16位数据使能信号
wire    [15:0]  rec_data_out;   //输出16位数据

//reg   define
reg             eth_rx_clk  ;   //系统时钟
reg             sys_rst_n   ;   //复位信号,低有效
reg             rec_en_in   ;   //32位数据使能信号
reg     [31:0]  rec_data_in ;   //32位数据
reg     [2:0]   cnt_data    ;   //数据间隔计数器

//********************************************************************//
//***************************** Main Code ****************************//
//********************************************************************//
//时钟、复位信号
initial
  begin
    eth_rx_clk  =   1'b1    ;
    sys_rst_n   <=  1'b0    ;
    #200
    sys_rst_n   <=  1'b1    ;
  end

always  #20 eth_rx_clk = ~eth_rx_clk;

//cnt_data:数据间隔计数器
always@(posedge eth_rx_clk or negedge sys_rst_n)
    if(sys_rst_n == 1'b0)
        cnt_data    <=  3'd0;
    else
        cnt_data    <=  cnt_data + 3'd1;

//rec_data_in:32位数据
always@(posedge eth_rx_clk or negedge sys_rst_n)
    if(sys_rst_n == 1'b0)
        rec_data_in <=  32'h12_34_56_78;
    else    if(cnt_data == 3'd7)
        rec_data_in <=  rec_data_in + 1'b1;
    else
        rec_data_in <=  rec_data_in;

//rec_en_in:32位数据使能信号
always@(posedge eth_rx_clk or negedge sys_rst_n)
    if(sys_rst_n == 1'b0)
        rec_en_in   <=  1'b0;
    else    if(cnt_data == 3'd7)
        rec_en_in   <=  1'b1;
    else
        rec_en_in   <=  1'b0;

//********************************************************************//
//*************************** Instantiation **************************//
//********************************************************************//
//------------ data32_to_data16_inst -------------
data32_to_data16    data32_to_data16_inst
(
    .sys_clk        (eth_rx_clk     ),   //系统时钟
    .sys_rst_n      (sys_rst_n      ),   //复位信号,低有效
    .rec_en_in      (rec_en_in      ),   //输入32位数据使能信号
    .rec_data_in    (rec_data_in    ),   //输入32位数据

    .rec_en_out     (rec_en_out     ),   //输出16位数据使能信号
    .rec_data_out   (rec_data_out   )    //输出16位数据
);

endmodule
