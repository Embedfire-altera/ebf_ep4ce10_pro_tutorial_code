`timescale  1ns/1ns
////////////////////////////////////////////////////////////////////////
// Author        : EmbedFire
// Create Date   : 2019/10/10
// Module Name   : eth_udp_rmii
// Project Name  : eth_udp_rmii
// Target Devices: Altera EP4CE10F17C8N
// Tool Versions : Quartus 13.0
// Description   : 顶层模块
// 
// Revision      : V1.0
// Additional Comments:
// 
// 实验平台: 野火_征途Pro_FPGA开发板
// 公司    : http://www.embedfire.com
// 论坛    : http://www.firebbs.cn
// 淘宝    : https://fire-stm32.taobao.com
////////////////////////////////////////////////////////////////////////

module  ethernet_udp_rmii
(
    input   wire            sys_rst_n       ,   //系统复位,低电平有效
    input   wire            eth_clk         ,   //PHY芯片时钟信号
    input   wire            eth_rxdv_r      ,   //PHY芯片输入数据有效信号
    input   wire    [1:0]   eth_rx_data_r   ,   //PHY芯片输入数据

    output  wire            eth_tx_en_r     ,   //PHY芯片输出数据有效信号
    output  wire    [1:0]   eth_tx_data_r   ,   //PHY芯片输出数据
    output  wire            eth_rst_n           //PHY芯片复位信号,低电平有效
);

//********************************************************************//
//****************** Parameter and Internal Signal *******************//
//********************************************************************//
//parameter define
parameter   BOARD_MAC   = 48'h12_34_56_78_9a_bc ;   //板卡MAC地址
parameter   BOARD_IP    = 32'hC0_A8_00_EA       ;   //板卡IP地址
parameter   BOARD_PORT  = 16'd1234              ;   //板卡端口号
parameter   PC_MAC      = 48'hE0_D5_5E_4A_DB_2D ;   //PC机MAC地址
parameter   PC_IP       = 32'hC0_A8_00_F5       ;   //PC机IP地址
parameter   PC_PORT     = 16'd1234              ;   //PC机端口号

//wire define
wire            rec_end         ;   //单包数据接收完成信号
wire            rec_en          ;   //接收数据使能信号
wire   [31:0]   rec_data        ;   //接收数据
wire   [15:0]   rec_data_num    ;   //接收有效数据字节数
wire            send_end        ;   //发送完成信号
wire            read_data_req   ;   //读数据请求信号
wire            send_en         ;   //数据开始发送信号
wire   [31:0]   send_data       ;   //发送数据
wire            eth_rxdv        ;   //输入数据有效信号(mii)
wire    [3:0]   eth_rx_data     ;   //输入数据(mii)
wire            eth_tx_en       ;   //输出数据有效信号(mii)
wire    [3:0]   eth_tx_data     ;   //输出数据(mii)

//reg   define
reg             clk_25m         ;   //mii时钟

//********************************************************************//
//***************************** Main Code ****************************//
//********************************************************************//
//clk_25m:mii时钟
always@(negedge eth_clk or negedge sys_rst_n)
    if(sys_rst_n == 1'b0)
        clk_25m <=  1'b0;
    else
        clk_25m <=  ~clk_25m;

//********************************************************************//
//*************************** Instantiation **************************//
//********************************************************************//
//------------- rmii_to_mii_inst -------------
rmii_to_mii rmii_to_mii_inst
(
    .eth_rmii_clk   (eth_clk        ),  //rmii时钟
    .eth_mii_clk    (clk_25m        ),  //mii时钟
    .sys_rst_n      (sys_rst_n      ),  //复位信号
    .rx_dv          (eth_rxdv_r     ),  //输入数据有效信号(rmii)
    .rx_data        (eth_rx_data_r  ),  //输入数据(rmii)

    .eth_rx_dv      (eth_rxdv       ),  //输入数据有效信号(mii)
    .eth_rx_data    (eth_rx_data    )   //输入数据(mii)
);

//------------- eth_udp_inst -------------
eth_udp_mii
#(
    .BOARD_MAC      (BOARD_MAC      ),  //板卡MAC地址
    .BOARD_IP       (BOARD_IP       ),  //板卡IP地址
    .BOARD_PORT     (BOARD_PORT     ),  //板卡端口号
    .PC_MAC         (PC_MAC         ),  //PC机MAC地址
    .PC_IP          (PC_IP          ),  //PC机IP地址
    .PC_PORT        (PC_PORT        )   //PC机端口号
)
eth_udp_mii_inst
(
    .eth_rx_clk     (clk_25m        ),  //mii时钟,接收
    .sys_rst_n      (sys_rst_n      ),  //复位信号,低电平有效
    .eth_rxdv       (eth_rxdv       ),  //输入数据有效信号(mii)
    .eth_rx_data    (eth_rx_data    ),  //输入数据(mii)
    .eth_tx_clk     (clk_25m        ),  //mii时钟,发送
    .send_en        (rec_end        ),  //开始发送信号
    .send_data      (send_data      ),  //发送数据
    .send_data_num  (rec_data_num   ),  //发送有效数据字节数

    .send_end       (send_end       ),  //单包数据发送完成信号
    .read_data_req  (read_data_req  ),  //读数据请求信号
    .rec_end        (rec_end        ),  //单包数据接收完成信号
    .rec_en         (rec_en         ),  //接收数据使能信号
    .rec_data       (rec_data       ),  //接收数据
    .rec_data_num   (rec_data_num   ),  //接收有效数据字节数
    .eth_tx_en      (eth_tx_en      ),  //输出数据有效信号(mii)
    .eth_tx_data    (eth_tx_data    ),  //输出数据(mii)
    .eth_rst_n      (eth_rst_n      )   //复位信号,低电平有效
);

//------------- mii_to_rmii_inst -------------
mii_to_rmii mii_to_rmii_inst
(
    .eth_mii_clk    (clk_25m        ),  //mii时钟
    .eth_rmii_clk   (eth_clk        ),  //rmii时钟
    .sys_rst_n      (sys_rst_n      ),  //复位信号
    .tx_dv          (eth_tx_en      ),  //输出数据有效信号(mii)
    .tx_data        (eth_tx_data    ),  //输出有效数据(mii)

    .eth_tx_dv      (eth_tx_en_r    ),  //输出数据有效信号(rmii)
    .eth_tx_data    (eth_tx_data_r  )   //输出数据(rmii)
);

//------------- fifo_2048x32_inst -------------
//fifo模块，用于缓存单包数据
fifo_2048x32    fifo_2048x32_inst
(
    .aclr           (~sys_rst_n     ),  //fifo清零信号
    .wrclk          (clk_25m        ),  //fifo写时钟
    .wrreq          (rec_en         ),  //fifo写请求
    .data           (rec_data       ),  //fifo写数据

    .rdclk          (clk_25m        ),  //fifo读时钟
    .rdreq          (read_data_req  ),  //fifo读请求
    .q              (send_data      )   //fifo读数据
);

endmodule