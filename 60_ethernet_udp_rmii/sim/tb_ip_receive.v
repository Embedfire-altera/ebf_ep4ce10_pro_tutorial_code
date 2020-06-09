`timescale  1ns/1ns
//////////////////////////////////////////////////////////////////////////////////
// Author: fire
// Create Date: 2019/09/03
// Module Name: tb_ip_receive
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

module  tb_ip_receive();
//********************************************************************//
//****************** Parameter and Internal Signal *******************//
//********************************************************************//
//parameter define
//板卡MAC地址
parameter  BOARD_MAC = 48'h12_34_56_78_9A_BC;
//板卡IP地址
parameter  BOARD_IP  = {8'd169,8'd254,8'd1,8'd23};

//reg   define
reg             eth_rx_clk          ;   //PHY芯片接收数据时钟信号
reg             eth_tx_clk          ;   //PHY芯片发送数据时钟信号
reg             sys_rst_n           ;   //系统复位,低电平有效
reg             eth_rxdv            ;   //PHY芯片输入数据有效信号
reg     [3:0]   data_mem [171:0]    ;   //data_mem是一个存储器,相当于一个ram
reg     [7:0]   cnt_data            ;   //数据包字节计数器
reg             start_flag          ;   //数据输入开始标志信号

//wire define
wire            rec_end             ;   //数据接收使能信号
wire    [3:0]   rec_en              ;   //接收数据
wire            rec_data            ;   //数据包接收完成信号
wire            rec_data_num        ;   //接收数据字节数
wire    [3:0]   eth_rx_data         ;   //PHY芯片输入数据

//********************************************************************//
//***************************** Main Code ****************************//
//********************************************************************//
//读取sim文件夹下面的data.txt文件，并把读出的数据定义为data_mem
initial $readmemh
    ("E:/GitLib/Altera/EP4CE10/code/54_ethernet/sim/data.txt",data_mem);

//时钟、复位信号
initial
  begin
    eth_rx_clk  =   1'b1    ;
    eth_tx_clk  =   1'b1    ;
    sys_rst_n   <=  1'b0    ;
    start_flag  <=  1'b0    ;
    #200
    sys_rst_n   <=  1'b1    ;
    #100
    start_flag  <=  1'b1    ;
    #50
    start_flag  <=  1'b0    ;
  end

always  #20 eth_rx_clk = ~eth_rx_clk;
always  #20 eth_tx_clk = ~eth_tx_clk;

//eth_rxdv:PHY芯片输入数据有效信号
always@(negedge eth_rx_clk or negedge sys_rst_n)
    if(sys_rst_n == 1'b0)
        eth_rxdv    <=  1'b0;
    else    if(cnt_data == 171)
        eth_rxdv    <=  1'b0;
    else    if(start_flag == 1'b1)
        eth_rxdv    <=  1'b1;
    else
        eth_rxdv    <=  eth_rxdv;

//cnt_data:数据包字节计数器
always@(negedge eth_rx_clk or negedge sys_rst_n)
    if(sys_rst_n == 1'b0)
        cnt_data    <=  8'd0;
    else    if(eth_rxdv == 1'b1)
        cnt_data    <=  cnt_data + 1'b1;
    else
        cnt_data    <=  cnt_data;

//eth_rx_data:PHY芯片输入数据
assign  eth_rx_data = (eth_rxdv == 1'b1)
                    ? data_mem[cnt_data] : 4'b0;

//********************************************************************//
//*************************** Instantiation **************************//
//********************************************************************//
//------------- ethernet_inst -------------
ip_receive
#(
    .BOARD_MAC      (BOARD_MAC      ),  //板卡MAC地址
    .BOARD_IP       (BOARD_IP       )   //板卡IP地址
)
ip_receive_inst
(
    .sys_clk        (eth_rx_clk     ),  //时钟信号
    .sys_rst_n      (sys_rst_n      ),  //复位信号,低电平有效
    .eth_rxdv       (eth_rxdv       ),  //数据有效信号
    .eth_rx_data    (eth_rx_data    ),  //输入数据

    .rec_end        (rec_end        ),  //数据接收使能信号
    .rec_data_en    (rec_en         ),  //接收数据
    .rec_data       (rec_data       ),  //数据包接收完成信号
    .rec_data_num   (rec_data_num   )   //接收数据字节数
);

endmodule
