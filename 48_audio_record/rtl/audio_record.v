`timescale  1ns/1ns
////////////////////////////////////////////////////////////////////////
// Author        : EmbedFire
// Create Date   : 2019/09/18
// Module Name   : audio_record
// Project Name  : audio_record
// Target Devices: Altera EP4CE10F17C8N
// Tool Versions : Quartus 13.0
// Description   : 
// 
// Revision      : V1.0
// Additional Comments:
// 
// 实验平台: 野火_征途Pro_FPGA开发板
// 公司    : http://www.embedfire.com
// 论坛    : http://www.firebbs.cn
// 淘宝    : https://fire-stm32.taobao.com
////////////////////////////////////////////////////////////////////////

module  audio_record
(
    input   wire          sys_clk      , //系统时钟，频率50MHz
    input   wire          sys_rst_n    , //系统复位，低电平有效
    input   wire          key_record   , //录音按键
    input   wire          key_broadcast, //播放按键
    input   wire          audio_bclk   , //WM8978输出的位时钟
    input   wire          audio_lrc    , //WM8978输出的数据左/右对齐时钟
    input   wire          audio_adcdat , //WM8978ADC数据输出

    inout   wire          sda          , //输出至wm8978的串行数据信号sda

    output  wire          scl          , //输出至wm8978的串行时钟信号scl
    output  wire          audio_mlck   , //输出WM8978主时钟,频率12MHz
    output  wire          audio_dacdat , //输出DAC数据给WM8978

//SDRAM接口信号
    output  wire          sdram_clk    , //SDRAM芯片时钟
    output  wire          sdram_cke    , //SDRAM时钟有效信号
    output  wire          sdram_cs_n   , //SDRAM片选信号
    output  wire          sdram_ras_n  , //SDRAM行地址选通脉冲
    output  wire          sdram_cas_n  , //SDRAM列地址选通脉冲
    output  wire          sdram_we_n   , //SDRAM写允许位
    output  wire  [1:0 ]  sdram_ba     , //SDRAM的L-Bank地址线
    output  wire  [12:0]  sdram_addr   , //SDRAM地址总线
    output  wire  [1:0 ]  sdram_dqm    , //SDRAM数据掩码
    inout   wire  [15:0]  sdram_dq       //SDRAM数据总线
);

//********************************************************************//
//****************** Parameter and Internal Signal *******************//
//********************************************************************//

//parameter define
parameter   TIME_RECORD = 24'd11520000; //录音时长，120s

//wire  define
wire            rst_n           ;   //当时钟输出不稳定时一直处于复位状态
wire            wr_en           ;   //SDRAM写FIFO写请求
wire            rd_en           ;   //SDRAM读FIFO读请求
wire    [15:0]  wr_data         ;   //SDRAM写数据
wire    [15:0]  rd_data         ;   //SDRAM读数据
wire    [15:0]  dac_data        ;   //SDRAM读FIFO读保存的录音数据
wire            init_end        ;   //SDRAM初始化完成信号
wire            record_flag     ;   //录音按键标志信号
wire            broadcast_flag  ;   //播放按键标志信号
wire    [15:0]  adc_data        ;   //wm8978输出录音数据
wire            rcv_done        ;   //一次数据接收完成
wire            send_done       ;   //一次数据发送完成
wire            clk_50m         ;   //输出50MHz时钟
wire            clk_100m        ;   //输出100MHz时钟
wire            clk_100m_shift  ;   //输出100MHZ，偏移-30度
wire            locked          ;   //拉高表示锁相环开始稳定输出时钟信号
wire            p_record_flag   ;   //录音按键上升沿
wire            p_broadcast_falg;   //播放按键上升沿

//rst_n:复位信号
assign  rst_n = sys_rst_n & locked;

//********************************************************************//
//*************************** Instantiation **************************//
//********************************************************************//

//------------- clk_gen_inst -------------
clk_gen     clk_gen_inst
(
    .areset     (~sys_rst_n     ),  //异步复位
    .inclk0     (sys_clk        ),  //输入时钟
    .c0         (audio_mlck     ),  //输出WM8978主时钟,频率12MHz
    .c1         (clk_50m        ),  //输出50MHz时钟
    .c2         (clk_100m       ),  //输出100MHz时钟
    .c3         (clk_100m_shift ),  //输出100MHZ，偏移-30度
    .locked     (locked         )   //拉高表示锁相环开始稳定输出时钟信号

    );

//------------- key_filter_inst -------------
key_filter  record_key_filter
(
    .sys_clk        (clk_50m      ),    //系统时钟50Mhz
    .sys_rst_n      (rst_n        ),    //全局复位
    .key_in         (key_record   ),    //录音按键

    .key_flag       (record_flag  )     //录音按键有效标志信号

);

//------------- key_filter_inst -------------
key_filter  broadcast_key_filter
(
    .sys_clk        (clk_50m       ),    //系统时钟50Mhz
    .sys_rst_n      (rst_n         ),    //全局复位
    .key_in         (key_broadcast ),    //播放按键

    .key_flag       (broadcast_flag)     //播放按键有效标志信号

);

//------------- record_ctrl_inst -------------
record_ctrl 
#(
    .TIME_RECORD     (TIME_RECORD   )    //定义最大录音时长,120s
)
record_ctrl_inst
(
    .sys_clk         (clk_50m       ),   //系统时钟50Mhz
    .clk             (audio_bclk    ),   //模块时钟
    .sys_rst_n       (rst_n         ),   //复位信号
    .key_record      (key_record    ),   //录音按键
    .key_broadcast   (key_broadcast ),   //播放按键
    .record_flag     (record_flag   ),   //录音按键消抖后信号
    .broadcast_flag  (broadcast_flag),   //播放按键消抖后信号
    .sdram_init_end  (init_end      ),   //SDRAM初始化完成信号
    .rcv_done        (rcv_done      ),   //一次音频数据接收完成
    .send_done       (send_done     ),   //一次音频数据发送完成
    .adc_data        (adc_data      ),   //输入音频数据
    .rd_data         (rd_data       ),   //SDRAM读出的数据

    .wr_en           (wr_en         ),   //SDRAM写FIFO写请求
    .rd_en           (rd_en         ),   //SDRAM读FIFO读请求
    .p_record_flag   (p_record_flag ),   //录音按键上升沿
    .p_broadcast_falg(p_broadcast_falg), //播放按键上升沿
    .wr_data         (wr_data       ),   //写入SDRAM数据
    .dac_data        (dac_data      )    //输出音频数据

);

//------------- sdram_top_inst -------------
sdram_top   sdram_top_inst
(
    .sys_clk            (clk_100m       ),  //sdram 控制器参考时钟
    .clk_out            (clk_100m_shift ),  //用于输出的相位偏移时钟
    .sys_rst_n          (rst_n          ),  //系统复位
//用户写端口
    .wr_fifo_wr_clk     (audio_bclk     ),  //写端口FIFO: 写时钟
    .wr_fifo_wr_req     (wr_en          ),  //写端口FIFO: 写使能
    .wr_fifo_wr_data    (wr_data        ),  //写端口FIFO: 写数据
    .sdram_wr_b_addr    (24'd0          ),  //写SDRAM的起始地址
    .sdram_wr_e_addr    (TIME_RECORD    ),  //写SDRAM的结束地址
    .wr_burst_len       (10'd512        ),  //写SDRAM时的数据突发长度
    .wr_rst             (p_record_flag  ),  //写复位
//用户读端口
    .rd_fifo_rd_clk     (audio_bclk     ),  //读端口FIFO: 读时钟
    .rd_fifo_rd_req     (rd_en          ),  //读端口FIFO: 读使能
    .rd_fifo_rd_data    (rd_data        ),  //读端口FIFO: 读数据
    .sdram_rd_b_addr    (24'd0          ),  //读SDRAM的起始地址
    .sdram_rd_e_addr    (TIME_RECORD    ),  //读SDRAM的结束地址
    .rd_burst_len       (10'd512        ),  //从SDRAM中读数据时的突发长度
    .rd_rst             (p_broadcast_falg),  //读复位
    .rd_fifo_num        (               ),  //读fifo中的数据量
//用户控制端口
    .read_valid         (1'b1           ),  //SDRAM 读使能
    .init_end           (init_end       ),  //SDRAM 初始化完成标志
//SDRAM 芯片接口
    .sdram_clk          (sdram_clk      ),  //SDRAM 芯片时钟
    .sdram_cke          (sdram_cke      ),  //SDRAM 时钟有效
    .sdram_cs_n         (sdram_cs_n     ),  //SDRAM 片选
    .sdram_ras_n        (sdram_ras_n    ),  //SDRAM 行有效
    .sdram_cas_n        (sdram_cas_n    ),  //SDRAM 列有效
    .sdram_we_n         (sdram_we_n     ),  //SDRAM 写有效
    .sdram_ba           (sdram_ba       ),  //SDRAM Bank地址
    .sdram_addr         (sdram_addr     ),  //SDRAM 行/列地址
    .sdram_dq           (sdram_dq       ),  //SDRAM 数据
    .sdram_dqm          (sdram_dqm      )   //SDRAM 数据掩码
);

//------------- wm8978_ctrl_inst -------------
wm8978_ctrl wm8978_ctrl_inst
(
    .sys_clk         (clk_50m     ),   //系统时钟，频率50MHz
    .sys_rst_n       (rst_n       ),   //系统复位，低电平有效
    .audio_bclk      (audio_bclk  ),   //WM8978输出的位时钟
    .audio_lrc       (audio_lrc   ),   //WM8978输出的数据左/右对齐时钟
    .audio_adcdat    (audio_adcdat),   //WM8978ADC数据输出
    .dac_data        (dac_data    ),   //输入音频数据

    .scl             (scl         ),   //输出至wm8978的串行时钟信号scl
    .audio_dacdat    (audio_dacdat),   //输出DAC数据给WM8978
    .rcv_done        (rcv_done    ),   //一次数据接收完成
    .send_done       (send_done   ),   //一次数据发送完成
    .adc_data        (adc_data    ),   //输出音频数据

    .sda             (sda         )    //输出至wm8978的串行数据信号sda

);

endmodule
