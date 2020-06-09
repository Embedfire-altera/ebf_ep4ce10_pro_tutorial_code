`timescale  1ns/1ns
////////////////////////////////////////////////////////////////////////
// Author        : EmbedFire
// Create Date   : 2019/10/10
// Module Name   : eth_udp_mii
// Project Name  : eth_hdmi_pic
// Target Devices: Altera EP4CE10F17C8N
// Tool Versions : Quartus 13.0
// Description   : UDP
// 
// Revision      : V1.0
// Additional Comments:
// 
// 实验平台: 野火_征途Pro_FPGA开发板
// 公司    : http://www.embedfire.com
// 论坛    : http://www.firebbs.cn
// 淘宝    : https://fire-stm32.taobao.com
////////////////////////////////////////////////////////////////////////

module  eth_udp_mii
#(
    parameter   BOARD_MAC   = 48'hFF_FF_FF_FF_FF_FF ,   //板卡MAC地址
    parameter   BOARD_IP    = 32'hFF_FF_FF_FF       ,   //板卡IP地址
    parameter   BOARD_PORT  = 16'd1234              ,   //板卡端口号
    parameter   PC_MAC      = 48'hFF_FF_FF_FF_FF_FF ,   //PC机MAC地址
    parameter   PC_IP       = 32'hFF_FF_FF_FF       ,   //PC机IP地址
    parameter   PC_PORT     = 16'd1234                  //PC机端口号
)
(
    input   wire            eth_rx_clk      ,   //mii时钟,接收
    input   wire            sys_rst_n       ,   //复位信号,低电平有效
    input   wire            eth_rxdv        ,   //输入数据有效信号(mii)
    input   wire    [3:0]   eth_rx_data     ,   //输入数据(mii)
    input   wire            eth_tx_clk      ,   //mii时钟,发送
    input   wire            send_en         ,   //开始发送信号
    input   wire    [31:0]  send_data       ,   //发送数据
    input   wire    [15:0]  send_data_num   ,   //发送有效数据字节数

    output  wire            send_end        ,   //单包数据发送完成信号
    output  wire            read_data_req   ,   //读数据请求信号
    output  wire            rec_end         ,   //单包数据接收完成信号
    output  wire            rec_en          ,   //接收数据使能信号
    output  wire    [31:0]  rec_data        ,   //接收数据
    output  wire    [15:0]  rec_data_num    ,   //接收有效数据字节数
    output  wire            eth_tx_en       ,   //输出数据有效信号(mii)
    output  wire    [3:0]   eth_tx_data     ,   //输出数据(mii)
    output  wire            eth_rst_n           //复位信号,低电平有效
);

//********************************************************************//
//****************** Parameter and Internal Signal *******************//
//********************************************************************//
//wire define
wire            crc_en  ;   //CRC校验开始标志信号
wire            crc_clr ;   //CRC数据复位信号
wire    [31:0]  crc_data;   //CRC校验数据
wire    [31:0]  crc_next;   //CRC下次校验完成数据

//********************************************************************//
//***************************** Main Code ****************************//
//********************************************************************//
//eth_rst_n:PHY芯片复位信号,低电平有效
assign  eth_rst_n = sys_rst_n;

//********************************************************************//
//*************************** Instantiation **************************//
//********************************************************************//
//------------ ip_receive_inst -------------
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

//------------ ip_send_inst -------------
ip_send
#(
    .BOARD_MAC      (BOARD_MAC      ),  //板卡MAC地址
    .BOARD_IP       (BOARD_IP       ),  //板卡IP地址
    .BOARD_PORT     (BOARD_PORT     ),  //板卡端口号
    .PC_MAC         (PC_MAC         ),  //PC机MAC地址
    .PC_IP          (PC_IP          ),  //PC机IP地址
    .PC_PORT        (PC_PORT        )   //PC机端口号
)
ip_send_inst
(
    .sys_clk        (eth_tx_clk     ),  //时钟信号
    .sys_rst_n      (sys_rst_n      ),  //复位信号,低电平有效
    .send_en        (send_en        ),  //数据发送开始信号
    .send_data      (send_data      ),  //发送数据
    .send_data_num  (send_data_num  ),  //发送数据有效字节数
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
