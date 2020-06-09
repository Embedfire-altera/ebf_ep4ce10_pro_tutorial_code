`timescale  1ns/1ns
//////////////////////////////////////////////////////////////////////////////////
// Author: fire
// Create Date: 2019/09/03
// Module Name: tb_ethernet
// Project Name: ethernet
// Target Devices: Altera EP4CE10F17C8N
// Tool Versions: Quartus 13.0
// Description: UDP协议数据接收模块
//
// Revision:V1.1
// Additional Comments:
//
// 实验平台:野火FPGA开发板
// 公司    :http://www.embedfire.com
// 论坛    :http://www.firebbs.cn
// 淘宝    :https://fire-stm32.taobao.com
//////////////////////////////////////////////////////////////////////////////////

module  tb_ethernet_udp_rmii();
//********************************************************************//
//****************** Parameter and Internal Signal *******************//
//********************************************************************//
//reg   define
reg             sys_clk         ;   //PHY芯片接收数据时钟信号
reg             sys_rst_n       ;   //系统复位,低电平有效
reg             eth_rxdv        ;   //PHY芯片输入数据有效信号
reg     [655:0] data_mem        ;   //data_mem是一个存储器,相当于一个ram
reg     [11:0]  cnt_data        ;   //数据包字节计数器
reg             start_flag      ;   //数据输入开始标志信号

//wire define
wire            eth_tx_en_r     ;   //PHY芯片输出数据有效信号
wire    [1:0]   eth_tx_data_r   ;   //PHY芯片输出数据
wire            eth_rst_n       ;   //PHY芯片复位信号,低电平有效
wire    [1:0]   eth_rx_data     ;   //PHY芯片输入数据

//********************************************************************//
//***************************** Main Code ****************************//
//********************************************************************//
//时钟、复位信号
initial
  begin
    sys_clk  =   1'b1    ;
    sys_rst_n   <=  1'b0    ;
    start_flag  <=  1'b0    ;
    #200
    sys_rst_n   <=  1'b1    ;
    #100
    start_flag  <=  1'b1    ;
    #50
    start_flag  <=  1'b0    ;
  end
//sys_clk
always  #10 sys_clk = ~sys_clk;

//data_mem
always@(negedge sys_clk or negedge sys_rst_n)
    if(sys_rst_n == 1'b0)
        data_mem    <=  'hFE_DC_BA_98_76_54_32_10_FE_DC_BA_98_76_54_32_10_FE_DC_BA_98_76_54_32_10_FE_DC_BA_98_76_54_32_10_00_00_28_00_D2_04_D2_04_17_01_FE_A9_1F_BF_FE_A9_00_00_11_80_00_00_00_5F_3C_00_00_45_00_08_2D_DB_4A_5E_D5_E0_BC_9A_78_56_34_12_D5_55_55_55_55_55_55_55;
    else    if(eth_rxdv == 1'b1)
        data_mem    <=  data_mem >>2;
    else
        data_mem    <=  data_mem;

//eth_rxdv:PHY芯片输入数据有效信号
always@(negedge sys_clk or negedge sys_rst_n)
    if(sys_rst_n == 1'b0)
        eth_rxdv    <=  1'b0;
    else    if(cnt_data == 327)
        eth_rxdv    <=  1'b0;
    else    if(start_flag == 1'b1)
        eth_rxdv    <=  1'b1;
    else
        eth_rxdv    <=  eth_rxdv;

//cnt_data:数据包字节计数器
always@(negedge sys_clk or negedge sys_rst_n)
    if(sys_rst_n == 1'b0)
        cnt_data    <=  12'd0;
    else    if(eth_rxdv == 1'b1)
        cnt_data    <=  cnt_data + 1'b1;
    else
        cnt_data    <=  cnt_data;

//eth_rx_data:PHY芯片输入数据
assign  eth_rx_data = (eth_rxdv == 1'b1)
                    ? data_mem[1:0] : 2'b0;

//********************************************************************//
//*************************** Instantiation **************************//
//********************************************************************//
//------------- ethernet_udp_rmii_inst -------------
ethernet_udp_rmii   ethernet_udp_rmii_inst
(
    .eth_clk        (sys_clk        ),  //PHY芯片时钟
    .sys_rst_n      (sys_rst_n      ),  //系统复位,低电平有效
    .eth_rxdv_r     (eth_rxdv       ),  //PHY芯片输入数据有效信号
    .eth_rx_data_r  (eth_rx_data    ),  //PHY芯片输入数据

    .eth_tx_en_r    (eth_tx_en_r    ),  //PHY芯片输出数据有效信号
    .eth_tx_data_r  (eth_tx_data_r  ),  //PHY芯片输出数据

    .eth_rst_n      (eth_rst_n      )   //PHY芯片复位信号,低电平有效
);

endmodule
