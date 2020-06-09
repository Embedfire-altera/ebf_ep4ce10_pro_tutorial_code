`timescale  1ns/1ns
////////////////////////////////////////////////////////////////////////
// Author        : EmbedFire
// Create Date   : 2019/10/10
// Module Name   : eth_audio_transmission
// Project Name  : eth_audio_transmission
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

module  eth_audio_transmission
(
    input   wire            sys_clk     ,   //系统时钟
    input   wire            sys_rst_n   ,   //系统复位，低电平有效
//Ethernet
    input   wire            eth_clk     ,   //PHY芯片时钟信号
    input   wire            eth_rxdv_r  ,   //PHY芯片输入数据有效信号
    input   wire    [1:0]   eth_rx_data_r,  //PHY芯片输入数据
    output  wire            eth_tx_en_r ,   //PHY芯片输出数据有效信号
    output  wire    [1:0]   eth_tx_data_r,  //PHY芯片输出数据
    output  wire            eth_rst_n   ,   //PHY芯片复位信号,低电平有效
//audio
    input   wire            audio_bclk  ,   //WM8978输出的位时钟
    input   wire            audio_lrc   ,   //WM8978输出的数据左/右对齐时钟
    input   wire            audio_adcdat,   //WM8978ADC数据输出
    output  wire            audio_mclk  ,   //输出WM8978主时钟,频率12MHz
    output  wire            audio_dacdat,   //输出DAC数据给WM8978
    output  wire            scl         ,   //输出至wm8978的串行时钟信号scl
    inout   wire            sda             //输出至wm8978的串行数据信号sda

);

//********************************************************************//
//****************** Parameter and Internal Signal *******************//
//********************************************************************//

parameter   BOARD_MAC   = 48'hff_ff_ff_ff_ff_ff ;   //板卡MAC地址
parameter   BOARD_IP    = 32'hff_ff_ff_ff       ;   //板卡IP地址
parameter   BOARD_PORT  = 16'd1234              ;   //板卡端口号
parameter   PC_MAC      = 48'hff_ff_ff_ff_ff_ff ;   //PC机MAC地址
parameter   PC_IP       = 32'hff_ff_ff_ff       ;   //PC机IP地址
parameter   PC_PORT     = 16'd1234              ;   //PC机端口号

//wire  define
wire            eth_rxdv        ;   //输入数据有效信号(mii)
wire    [3:0]   eth_rx_data     ;   //输入数据(mii)
wire            eth_tx_en       ;   //输出数据有效信号(mii)
wire    [3:0]   eth_tx_data     ;   //输出数据(mii)
wire            eth_tx_clk      ;   //mii时钟,发送
wire            read_data_req   ;   //读数据请求信号
wire            send_end        ;   //单包数据发送完成信号
wire            send_en         ;   //开始发送信号
wire    [15:0]  send_data_num   ;   //发送有效数据字节数
wire    [31:0]  send_data       ;   //发送数据
wire            rec_end         ;   //单包数据接收完成信号
wire            rec_en          ;   //接收数据使能信号
wire    [31:0]  rec_data        ;   //接收数据
wire            send_done       ;   //音频一次数据发送完成信号
wire            rcv_done        ;   //一次数据接受完成
wire    [23:0]  adc_data        ;   //一次接受的数据
wire    [23:0]  dac_data        ;   //往音频发送的播放数据

//reg   define
reg     clk_25m ;   //mii时钟

//********************************************************************//
//***************************** Main Code ****************************//
//********************************************************************//

 //clk_25m:mii时钟
always@(negedge eth_clk or negedge sys_rst_n)
    if(sys_rst_n == 1'b0)
        clk_25m <=  1'b1;
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

//------------- eth_udp_mii_inst -------------
eth_udp_mii
#(
    .BOARD_MAC   (BOARD_MAC ),   //板卡MAC地址
    .BOARD_IP    (BOARD_IP  ),   //板卡IP地址
    .BOARD_PORT  (BOARD_PORT),   //板卡端口号
    .PC_MAC      (PC_MAC    ),   //PC机MAC地址
    .PC_IP       (PC_IP     ),   //PC机IP地址
    .PC_PORT     (PC_PORT   )    //PC机端口号
)
eth_udp_mii_inst
(
    .eth_rx_clk      (clk_25m        ),   //mii时钟,接收
    .sys_rst_n       (sys_rst_n      ),   //复位信号,低电平有效
    .eth_rxdv        (eth_rxdv       ),   //输入数据有效信号(mii)
    .eth_rx_data     (eth_rx_data    ),   //输入数据(mii)
    .eth_tx_clk      (clk_25m        ),   //mii时钟,发送
    .send_en         (send_en        ),   //开始发送信号
    .send_data       (send_data      ),   //发送数据
    .send_data_num   (send_data_num  ),   //发送有效数据字节数

    .send_end        (send_end       ),   //单包数据发送完成信号
    .read_data_req   (read_data_req  ),   //读数据请求信号
    .rec_end         (rec_end        ),   //单包数据接收完成信号
    .rec_en          (rec_en         ),   //接收数据使能信号
    .rec_data        (rec_data       ),   //接收数据
    .rec_data_num    (               ),   //接收有效数据字节数
    .eth_tx_en       (eth_tx_en      ),   //输出数据有效信号(mii)
    .eth_tx_data     (eth_tx_data    ),   //输出数据(mii)
    .eth_rst_n       (eth_rst_n      )    //复位信号,低电平有效
);

//------------- audio_rcv_ctrl_inst -------------
audio_rcv_ctrl      audio_rcv_ctrl_inst
(
    .eth_rx_clk      (clk_25m       ),   //mii时钟,接收
    .sys_rst_n       (sys_rst_n     ),   //复位信号，低电平有效
    .audio_bclk      (audio_bclk    ),   //音频位时钟
    .audio_send_done (send_done     ),   //音频一次数据发送完成信号
    .rec_end         (rec_end       ),   //单包数据接收完成信号
    .rec_en          (rec_en        ),   //接收数据使能信号
    .rec_data        (rec_data      ),   //接收数据

    .audio_dac_data  (dac_data      )    //往音频发送的播放数据

);

//------------- audio_send_ctrl_inst -------------
audio_send_ctrl     audio_send_ctrl_inst
(
    .audio_bclk    (audio_bclk   ),   //音频位时钟
    .sys_rst_n     (sys_rst_n    ),   //复位信号
    .rcv_done      (rcv_done     ),   //一次数据接受完成
    .adc_data      (adc_data     ),   //一次接受的数据
    .eth_tx_clk    (clk_25m      ),   //mii时钟,发送
    .read_data_req (read_data_req),   //读数据请求信号
    .send_end      (send_end     ),   //单包数据发送完成信号

    .send_en       (send_en      ),   //开始发送信号
    .send_data_num (send_data_num),   //发送有效数据字节数
    .send_data     (send_data    )    //发送数据

);

//------------- audio_loopback_inst -------------
audio_loopback  audio_loopback_inst
(
    .sys_clk     (sys_clk       ),   //系统时钟，频率50MHz
    .sys_rst_n   (sys_rst_n     ),   //系统复位，低电平有效
    .audio_bclk  (audio_bclk    ),   //WM8978输出的位时钟
    .audio_lrc   (audio_lrc     ),   //WM8978输出的数据左/右对齐时钟
    .audio_adcdat(audio_adcdat  ),   //WM8978ADC数据输出

    .scl         (scl           ),   //输出至wm8978的串行时钟信号scl
    .audio_mclk  (audio_mclk    ),   //输出WM8978主时钟,频率12MHz
    .audio_dacdat(audio_dacdat  ),   //输出DAC数据给WM8978

    .sda         (sda           ),   //输出至wm8978的串行数据信号sda

    .adc_data    (adc_data      ),   //一次接收的数据
    .rcv_done    (rcv_done      ),   //一次数据接收完成
    .dac_data    (dac_data      ),   //往WM8978发送的数据
    .send_done   (send_done     )    //一次数据发送完成
    
);

endmodule
