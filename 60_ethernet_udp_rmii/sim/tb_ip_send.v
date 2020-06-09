`timescale  1ns/1ns
//////////////////////////////////////////////////////////////////////////////////
// Author: fire
// Create Date: 2019/09/03
// Module Name: tb_ip_send
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

module  tb_ip_send();
//********************************************************************//
//****************** Parameter and Internal Signal *******************//
//********************************************************************//
//parameter define
//板卡MAC地址
parameter  BOARD_MAC = 48'h12_34_56_78_9A_BC;
//板卡IP地址
parameter  BOARD_IP  = {8'd169,8'd254,8'd1,8'd23};
//PC机MAC地址
parameter  DES_MAC   = 48'hff_ff_ff_ff_ff_ff;
//PC机IP地址
parameter  DES_IP    = {8'd169,8'd254,8'd191,8'd31};

//reg   define
reg             eth_tx_clk      ;   //PHY芯片发送数据时钟信号
reg             clk_50m         ;
reg             sys_rst_n       ;   //系统复位,低电平有效
reg             send_en         ;   //数据输入开始标志信号
reg     [31:0]  send_data       ;   //待发送数据
reg     [31:0]  data_mem [2:0]  ;   //data_mem是一个存储器,相当于一个ram
reg     [15:0]  cnt_data        ;   //待发送数据

//wire define
wire            send_end        ;   //单包数据发送完成标志信号
wire            read_data_req   ;   //读FIFO使能信号
wire            eth_tx_en       ;   //输出数据有效信号
wire    [3:0]   eth_tx_data     ;   //输出数据
wire            crc_en          ;   //CRC开始校验使能
wire            crc_clr         ;   //CRC复位信号
wire    [31:0]  crc_data        ;   //CRC校验数据
wire    [31:0]  crc_next        ;   //CRC下次校验完成数据

wire            en              ;
wire    [1:0]   data            ;

//********************************************************************//
//***************************** Main Code ****************************//
//********************************************************************//
//时钟、复位信号
initial
  begin
    eth_tx_clk  =   1'b1    ;
    clk_50m     =   1'b1    ;
    sys_rst_n   <=  1'b0    ;
    send_en     <=  1'b0    ;
    #200
    sys_rst_n   <=  1'b1    ;
    #100
    send_en     <=  1'b1    ;
    #50
    send_en     <=  1'b0    ;
  end

always  #20 eth_tx_clk = ~eth_tx_clk;
always  #10 clk_50m = ~clk_50m;

always @(posedge eth_tx_clk or negedge sys_rst_n)
    if(sys_rst_n == 1'b0)
        begin
            data_mem[0] <=  32'h00_00_00_00;
            data_mem[1] <=  32'h00_00_00_00;
            data_mem[2] <=  32'h00_00_00_00;
        end
    else
        begin
            data_mem[0] <=  32'h68_74_74_70;
            data_mem[1] <=  32'h3a_2f_2f_77;
            data_mem[2] <=  32'h77_77_00_00;
        end

//cnt_data:数据包字节计数器
always@(posedge eth_tx_clk or negedge sys_rst_n)
    if(sys_rst_n == 1'b0)
        cnt_data    <=  8'd0;
    else    if(read_data_req == 1'b1)
        cnt_data    <=  cnt_data + 1'b1;
    else
        cnt_data    <=  cnt_data;

//send_data:PHY芯片输入数据
always @(posedge eth_tx_clk or negedge sys_rst_n)
    if(sys_rst_n == 1'b0)
        send_data   <=  32'h0;
    else    if(read_data_req == 1'b1)
        send_data   <=  data_mem[cnt_data];

//********************************************************************//
//*************************** Instantiation **************************//
//********************************************************************//
//------------ ip_send_inst -------------
ip_send
#(
    .BOARD_MAC      (BOARD_MAC      ),  //板卡MAC地址
    .BOARD_IP       (BOARD_IP       ),  //板卡IP地址
    .DES_MAC        (DES_MAC        ),  //PC机MAC地址
    .DES_IP         (DES_IP         )   //PC机IP地址
)
ip_send_inst
(
    .sys_clk        (eth_tx_clk     ),  //时钟信号
    .sys_rst_n      (sys_rst_n      ),  //复位信号,低电平有效
    .send_en        (send_en        ),  //数据发送开始信号
    .send_data      (send_data      ),  //发送数据
    .send_data_num  (16'd10         ),  //发送数据有效字节数
    .crc_data       (crc_data       ),  //CRC校验数据
    .crc_next       (crc_next[31:28]),  //CRC下次校验完成数据

    .send_end       (send_end       ),  //单包数据发送完成标志信号
    .read_data_req  (read_data_req  ),  //读FIFO使能信号
    .eth_tx_en      (eth_tx_en      ),  //输出数据有效信号
    .eth_tx_data    (eth_tx_data    ),  //输出数据
    .crc_en         (crc_en         ),  //CRC开始校验使能
    .crc_clr        (crc_clr        )   //crc复位信号
);

//------------ crc32_d4_inst -------------
crc32_d4    crc32_d4_inst
(
    .sys_clk        (eth_tx_clk     ),  //时钟信号
    .sys_rst_n      (sys_rst_n      ),  //复位信号,低电平有效
    .data           (eth_tx_data    ),  //待校验数据
    .crc_en         (crc_en         ),  //crc使能,校验开始标志
    .crc_clr        (crc_clr        ),  //crc数据复位信号

    .crc_data       (crc_data       ),  //CRC校验数据
    .crc_next       (crc_next       )   //CRC下次校验完成数据
);

endmodule
