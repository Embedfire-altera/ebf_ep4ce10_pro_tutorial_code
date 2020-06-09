`timescale  1ns/1ns
////////////////////////////////////////////////////////////////////////
// Author        : EmbedFire
// Create Date   : 2019/12/05
// Module Name   : audio_sd_play
// Project Name  : audio_sd_play
// Target Devices: Altera EP4CE10F17C8N
// Tool Versions : Quartus 13.0
// Description   : SD卡音乐播放顶层模块
// 
// Revision      : V1.0
// Additional Comments:
// 
// 实验平台: 野火_征途Pro_FPGA开发板
// 公司    : http://www.embedfire.com
// 论坛    : http://www.firebbs.cn
// 淘宝    : https://fire-stm32.taobao.com
////////////////////////////////////////////////////////////////////////

module  audio_sd_play
(
    //系统时钟复位
    input   wire    sys_clk      ,  //系统时钟，频率50MHz
    input   wire    sys_rst_n    ,  //系统复位，低有效

    //WM8978接口
    input   wire    audio_bclk   ,  //WM8978输出的位时钟
    input   wire    audio_lrc    ,  //WM8978输出的数据左/右对齐时钟

    output  wire    audio_mclk   ,  //输出WM8978主时钟,频率12MHz
    output  wire    audio_dacdat ,  //输出DAC数据给WM8978
    //i2c接口
    output  wire    scl          ,  //输出至wm8978的串行时钟信号scl
    inout   wire    sda          ,  //输出至wm8978的串行数据信号sda

    //sd卡接口
    input   wire    sd_miso      ,  //主输入从输出信号
    output  wire    sd_clk       ,  //SD卡时钟信号
    output  wire    sd_cs_n      ,  //片选信号
    output  wire    sd_mosi         //主输出从输入信号

);

//****************************************************************//
//**************** Parameter and Internal Signal *****************//
//****************************************************************//

//parameter define
parameter   INIT_ADDR       =   'd472896 ; //音乐存放起始地址
parameter   AUDIO_SECTOR    =   'd111913 ; //播放的音乐占用的扇区数

//wire  define
wire            rst_n           ;   //当时钟输出不稳定时一直处于复位状态
wire            init_end        ;   //sd卡初始化完成信号
wire            rd_busy         ;   //sd卡读操作忙信号
wire            send_done       ;   //一次数据发送完成信号
wire    [15:0]  fifo_data       ;   //fifo读出数据
wire    [10:0]  fifo_data_cnt   ;   //fifo内剩余数据量
wire            rd_en           ;   //sd卡数据读使能信号
wire    [31:0]  rd_addr         ;   //sd卡读扇区地址
wire    [15:0]  dac_data        ;   //WM8978音频播放数据
wire            clk_50m         ;   //输出50MHz时钟
wire            clk_50m_shift   ;   //输出50MHZ，偏移90度
wire            locked          ;   //拉高表示锁相环开始稳定输出时钟信号
wire    [15:0]  sd_rd_data      ;   //sd卡读出的音频数据
wire            rd_data_en      ;   //写fifo使能信号
wire            cfg_done        ;   //寄存器配置完成信号

//rst_n:复位信号
assign  rst_n = sys_rst_n & locked;

//****************************************************************//
//************************* Instantiation ************************//
//****************************************************************//

//------------- sd_play_ctrl_inst -------------
sd_play_ctrl
#(   
    .INIT_ADDR   (INIT_ADDR        ),   //音乐存放起始地址
    .AUDIO_SECTOR(AUDIO_SECTOR     )    //播放的音乐占用的扇区数
)
sd_play_ctrl_inst
(
    .sd_clk         (sd_clk         ),   //SD卡时钟信号
    .audio_bclk     (audio_bclk     ),   //WM8978音频时钟
    .sys_rst_n      (rst_n          ),   //复位信号，低有效
    .sd_init_end    (init_end       ),   //sd卡初始化完成信号
    .rd_busy        (rd_busy        ),   //读操作忙信号
    .send_done      (send_done      ),   //一次音频发送完成信号
    .fifo_data      (fifo_data      ),   //fifo传来的音频数据
    .fifo_data_cnt  (fifo_data_cnt  ),   //fifo内剩余数据量
    .cfg_done       (cfg_done       ),   //寄存器配置完成信号

    .rd_en          (rd_en          ),   //数据读使能信号
    .rd_addr        (rd_addr        ),   //读数据扇区地址
    .dac_data       (dac_data       )    //输入WM8978音频数据

);

//------------- clk_gen_inst -------------
clk_gen     clk_gen_inst
(
    .areset (~sys_rst_n     ),  //异步复位，高有效
    .inclk0 (sys_clk        ),  //输入时钟
    .c0     (audio_mclk     ),  //输出12MHz时钟
    .c1     (clk_50m        ),  //输出50MHz时钟
    .c2     (clk_50m_shift  ),  //输出50MHz时钟，偏移90°
    .locked (locked         )   //时钟稳定输出信号，高有效

);

//------------- fifo_data_inst -------------
fifo_data fifo_data_inst
(
    .data   (sd_rd_data )   ,   //写入fifo数据
    .rdclk  (audio_bclk )   ,   //读fifo时钟
    .rdreq  (send_done  )   ,   //读fifo数据使能信号
    .wrclk  (sd_clk     )   ,   //写fifo时钟信号
    .wrreq  (rd_data_en )   ,   //写fifo使能信号

    .q      (fifo_data  )   ,   //读出fifo数据
    .wrusedw(fifo_data_cnt)     //fifo内剩余数据量

);

//------------- wm8978_ctrl_inst -------------
wm8978_ctrl wm8978_ctrl_inst
(
    .sys_clk     (clk_50m     ),  //系统时钟，频率50MHz
    .sys_rst_n   (rst_n       ),  //系统复位，低电平有效
    .audio_bclk  (audio_bclk  ),  //WM8978输出的位时钟
    .audio_lrc   (audio_lrc   ),  //WM8978输出的数据左/右对齐时钟
    .audio_adcdat(),              //WM8978ADC数据输出
    .dac_data    (dac_data    ),  //输入音频数据

    .scl         (scl         ),  //输出至wm8978的串行时钟信号scl
    .audio_dacdat(audio_dacdat),  //输出DAC数据给WM8978
    .rcv_done    (),              //一次数据接收完成
    .send_done   (send_done   ),  //一次数据发送完成
    .adc_data    (),              //输出音频数据
    .cfg_done    (cfg_done    ),  //寄存器配置完成信号
    .sda         (sda         )   //输出至wm8978的串行数据信号sda

);

//------------- sd_ctrl_inst -------------
sd_ctrl sd_ctrl_inst
(
    .sys_clk         (clk_50m      ),  //输入工作时钟,频率50MHz
    .sys_clk_shift   (clk_50m_shift),  //输入工作时钟,频率50MHz,相位偏移90度
    .sys_rst_n       (rst_n        ),  //输入复位信号,低电平有效
//SD卡接口
    .sd_miso         (sd_miso      ),  //主输入从输出信号
    .sd_clk          (sd_clk       ),  //SD卡时钟信号
    .sd_cs_n         (sd_cs_n      ),  //片选信号
    .sd_mosi         (sd_mosi      ),  //主输出从输入信号
//写SD卡接口（由于没有往sd卡内写入数据，故输入端口接0即可，输出端口可不接）
    .wr_en           (0),              //数据写使能信号
    .wr_addr         (0),              //写数据扇区地址
    .wr_data         (0),              //写数据
    .wr_busy         (),               //写操作忙信号
    .wr_req          (),               //写数据请求信号
//读SD卡接口
    .rd_en           (rd_en        ),  //数据读使能信号
    .rd_addr         (rd_addr      ),  //读数据扇区地址
    .rd_busy         (rd_busy      ),  //读操作忙信号
    .rd_data_en      (rd_data_en   ),  //读数据标志信号
    .rd_data         (sd_rd_data   ),  //读数据

    .init_end        (init_end     )   //SD卡初始化完成信号

);

endmodule