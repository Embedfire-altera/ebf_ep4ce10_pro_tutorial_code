`timescale  1ns/1ns
////////////////////////////////////////////////////////////////////////
// Author        : EmbedFire
// Create Date   : 2019/10/10
// Module Name   : eth_udp_rmii
// Project Name  : eth_ov7725_rgb
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

module  eth_udp_rmii
#(
    //板卡MAC地址,也可使用广播地址FF_FF_FF_FF_FF_FF
    parameter   BOARD_MAC   =   48'h12_34_56_78_9A_BC,
    //板卡IP地址
    parameter   BOARD_IP    =   {8'd169,8'd254,8'd1,8'd23},
    //板卡端口号
    parameter  BOARD_PORT   = 16'd1234,
    //PC机MAC地址
    parameter   DES_MAC     =   48'hff_ff_ff_ff_ff_ff,
    //PC机IP地址
    parameter   DES_IP      =   {8'd169,8'd254,8'd191,8'd31},
    //PC机端口号
    parameter  DES_PORT   = 16'd1234
)
(
    input   wire            eth_rmii_clk    ,   //rmii时钟
    input   wire            eth_mii_clk     ,   //mii时钟
    input   wire            sys_rst_n       ,   //复位信号
    input   wire            rx_dv           ,   //输入数据有效信号(rmii)
    input   wire    [1:0]   rx_data         ,   //输入数据(rmii)

    input   wire            send_en         ,   //开始发送信号
    input   wire    [31:0]  send_data       ,   //发送数据
    input   wire    [15:0]  send_data_num   ,   //发送有效数据字节数

    output  wire            send_end        ,   //单包数据发送完成信号
    output  wire            read_data_req   ,   //读数据请求信号
    output  wire            rec_end         ,   //单包数据接收完成信号
    output  wire            rec_en          ,   //接收数据使能信号
    output  wire    [31:0]  rec_data        ,   //接收数据
    output  wire    [15:0]  rec_data_num    ,   //接收有效数据字节数

    output  wire            eth_tx_dv       ,   //输出数据有效信号(rmii)
    output  wire    [1:0]   eth_tx_data     ,   //输出数据(rmii)
    output  wire            eth_rst_n           //PHY芯片复位信号,低电平有效
);

//********************************************************************//
//****************** Parameter and Internal Signal *******************//
//********************************************************************//
//wire define
wire            eth_rxdv        ;   //输入数据有效信号(mii)
wire    [3:0]   eth_rx_data     ;   //输入数据(mii)
wire            eth_tx_en       ;   //接收有效数据字节数
wire    [3:0]   eth_tx_data_m   ;   //PHY芯片输出数据有效信号

//********************************************************************//
//*************************** Instantiation **************************//
//********************************************************************//
//------------- rmii_to_mii_inst -------------
rmii_to_mii rmii_to_mii_inst
(
    .eth_rmii_clk   (eth_rmii_clk   ),  //rmii时钟
    .eth_mii_clk    (eth_mii_clk    ),  //mii时钟
    .sys_rst_n      (sys_rst_n      ),  //复位信号
    .rx_dv          (rx_dv          ),  //输入数据有效信号(rmii)
    .rx_data        (rx_data        ),  //输入数据(rmii)

    .eth_rx_dv      (eth_rxdv       ),  //输入数据有效信号(mii)
    .eth_rx_data    (eth_rx_data    )   //输入数据(mii)
);

//------------- eth_udp_mii_inst -------------
eth_udp_mii
#(
    .BOARD_MAC      (BOARD_MAC      ),  //板卡MAC地址
    .BOARD_IP       (BOARD_IP       ),  //板卡IP地址
    .BOARD_PORT     (BOARD_PORT     ),  //板卡端口号
    .DES_MAC        (DES_MAC        ),  //PC机MAC地址
    .DES_IP         (DES_IP         ),  //PC机IP地址
    .DES_PORT       (DES_PORT       )   //PC机端口号
)
eth_udp_mii_inst
(
    .eth_rx_clk     (eth_mii_clk    ),  //PHY芯片接收数据时钟信号
    .sys_rst_n      (sys_rst_n      ),  //复位信号,低电平有效
    .eth_rxdv       (eth_rxdv       ),  //PHY芯片输入数据有效信号
    .eth_rx_data    (eth_rx_data    ),  //PHY芯片输入数据
    .eth_tx_clk     (eth_mii_clk    ),  //PHY芯片发送数据时钟信号
    .send_en        (send_en        ),  //开始发送信号
    .send_data      (send_data      ),  //发送数据
    .send_data_num  (send_data_num  ),  //发送有效数据字节数
    .send_end       (send_end       ),
    .read_data_req  (read_data_req  ),  //单包数据发送完成信号
    .rec_end        (               ),  //读数据请求信号
    .rec_en         (               ),  //单包数据接收完成信号
    .rec_data       (               ),  //接收数据使能信号
    .rec_data_num   (               ),  //接收数据
    .eth_tx_en      (eth_tx_en      ),  //接收有效数据字节数
    .eth_tx_data    (eth_tx_data_m  ),  //PHY芯片输出数据有效信号
    .eth_rst_n      (eth_rst_n      )   //PHY芯片输出数据
);                                      //PHY芯片复位信号,低电平有效

//------------- mii_to_rmii_inst -------------
mii_to_rmii mii_to_rmii_inst
(
    .eth_mii_clk    (eth_mii_clk    ),  //mii时钟
    .eth_rmii_clk   (eth_rmii_clk   ),  //rmii时钟
    .sys_rst_n      (sys_rst_n      ),  //复位信号
    .tx_dv          (eth_tx_en      ),  //输出数据有效信号(mii)
    .tx_data        (eth_tx_data_m  ),  //输出数据(mii)

    .eth_tx_dv      (eth_tx_dv      ),  //输出数据有效信号(rmii)
    .eth_tx_data    (eth_tx_data    )   //输出数据(rmii)
);

endmodule
