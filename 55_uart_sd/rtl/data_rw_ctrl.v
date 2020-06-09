`timescale  1ns/1ns
////////////////////////////////////////////////////////////////////////
// Author        : EmbedFire
//Create Date    : 2019/09/03
// Module Name   : data_rw
// Project Name  : uart_sd
// Target Devices: Altera EP4CE10F17C8N
// Tool Versions : Quartus 13.0
// Description   : 读写数据控制模块
//
// Revision      : V1.0
// Additional Comments:
// 
// 实验平台: 野火_征途Pro_FPGA开发板
// 公司    : http://www.embedfire.com
// 论坛    : http://www.firebbs.cn
// 淘宝    : https://fire-stm32.taobao.com
////////////////////////////////////////////////////////////////////////

module  data_rw_ctrl
(
    input   wire            sys_clk     ,   //输入工作时钟,频率50MHz
    input   wire            sys_rst_n   ,   //输入复位信号,低电平有效
    input   wire            init_end    ,   //SD卡初始化完成信号
    
    input   wire            rx_flag     ,   //写fifo写入数据标志信号
    input   wire    [7:0]   rx_data     ,   //写fifo写入数据
    input   wire            wr_req      ,   //sd卡数据写请求
    input   wire            wr_busy     ,   //sd卡写数据忙信号

    output  wire            wr_en       ,   //sd卡数据写使能信号
    output  wire    [31:0]  wr_addr     ,   //sd卡写数据扇区地址
    output  wire    [15:0]  wr_data     ,   //sd卡写数据

    input   wire            rd_data_en  ,   //sd卡读出数据标志信号
    input   wire    [15:0]  rd_data     ,   //sd卡读出数据
    input   wire            rd_busy     ,   //sd卡读数据忙信号
    output  reg             rd_en       ,   //sd卡数据读使能信号
    output  wire    [31:0]  rd_addr     ,   //sd卡读数据扇区地址
    output  reg             tx_flag     ,   //读fifo读出数据标志信号
    output  wire    [7:0]   tx_data         //读fifo读出数据
);

//********************************************************************//
//****************** Parameter and Internal Signal *******************//
//********************************************************************//
//parameter define
parameter   DATA_NUM    =   12'd256     ;   //读写数据个数
parameter   SECTOR_ADDR =   32'd1000    ;   //读写数据扇区地址
parameter   CNT_WAIT_MAX=   16'd60000   ;   //读fifo输出数据时间间隔计数最大值

//wire  define
wire    [11:0]  wr_fifo_data_num    ;   //写fifo内数据个数
wire            wr_busy_fall        ;   //sd卡写数据忙信号下降沿
wire            rd_busy_fall        ;   //sd卡读数据忙信号下降沿
//wire            rd_fifo_rd_en       ;   //读fifo读使能信号

//reg   define
reg             wr_busy_dly         ;   //sd卡写数据忙信号打一拍
reg             rd_busy_dly         ;   //sd卡读数据忙信号打一拍
reg             send_data_en        ;   //串口发送数据使能信号
reg     [15:0]  cnt_wait            ;   //读fifo输出数据时间间隔计数
reg     [11:0]  send_data_num       ;   //串口发送数据字节数计数
reg             rd_fifo_rd_en       ;

//********************************************************************//
//***************************** Main Code ****************************//
//********************************************************************//
//wr_en:sd卡数据写使能信号
assign  wr_en = ((wr_fifo_data_num == (DATA_NUM)) && (init_end == 1'b1))
                ? 1'b1 : 1'b0;

//wr_addr:sd卡写数据扇区地址
assign  wr_addr = SECTOR_ADDR;

//wr_busy_dly:sd卡写数据忙信号打一拍
always@(posedge sys_clk or negedge sys_rst_n)
    if(sys_rst_n == 1'b0)
        wr_busy_dly <=  1'b0;
    else
        wr_busy_dly <=  wr_busy;

//wr_busy_fall:sd卡写数据忙信号下降沿
assign  wr_busy_fall = ((wr_busy == 1'b0) && (wr_busy_dly == 1'b1))
                        ? 1'b1 : 1'b0;

//rd_en:sd卡数据读使能信号
always@(posedge sys_clk or negedge sys_rst_n)
    if(sys_rst_n == 1'b0)
        rd_en   <=  1'b0;
    else    if(wr_busy_fall == 1'b1)
        rd_en   <=  1'b1;
    else
        rd_en   <=  1'b0;

//rd_addr:sd卡读数据扇区地址
assign  rd_addr = SECTOR_ADDR;

//rd_busy_dly:sd卡读数据忙信号打一拍
always@(posedge sys_clk or negedge sys_rst_n)
    if(sys_rst_n == 1'b0)
        rd_busy_dly <=  1'b0;
    else
        rd_busy_dly <=  rd_busy;

//rd_busy_fall:sd卡读数据忙信号下降沿
assign  rd_busy_fall = ((rd_busy == 1'b0) && (rd_busy_dly == 1'b1))
                        ? 1'b1 : 1'b0;

//send_data_en:串口发送数据使能信号
always@(posedge sys_clk or negedge sys_rst_n)
    if(sys_rst_n == 1'b0)
        send_data_en    <=  1'b0;
    else    if((send_data_num == (DATA_NUM * 2) - 1'b1)
                && (cnt_wait == CNT_WAIT_MAX - 1'b1))
        send_data_en    <=  1'b0;
    else    if(rd_busy_fall == 1'b1)
        send_data_en    <=  1'b1;
    else
        send_data_en    <=  send_data_en;

//cnt_wait:读fifo输出数据时间间隔计数
always@(posedge sys_clk or negedge sys_rst_n)
    if(sys_rst_n == 1'b0)
        cnt_wait    <=  16'd0;
    else    if(send_data_en == 1'b1)
        if(cnt_wait == CNT_WAIT_MAX)
            cnt_wait    <=  16'd0;
        else
            cnt_wait    <=  cnt_wait + 1'b1;
    else
        cnt_wait    <=  16'd0;

//send_data_num:串口发送数据字节数计数
always@(posedge sys_clk or negedge sys_rst_n)
    if(sys_rst_n == 1'b0)
        send_data_num   <=  12'd0;
    else    if(send_data_en == 1'b1)
        if(cnt_wait == CNT_WAIT_MAX)
            send_data_num   <=  send_data_num + 1'b1;
        else
            send_data_num   <=  send_data_num;
    else
        send_data_num   <=  12'd0;

//rd_fifo_rd_en:读fifo读使能信号
//assign  rd_fifo_rd_en = (cnt_wait == CNT_WAIT_MAX) ? 1'b1 : 1'b0;
always@(posedge sys_clk or negedge sys_rst_n)
    if(sys_rst_n == 1'b0)
        rd_fifo_rd_en   <=  1'b0;
    else    if(cnt_wait == (CNT_WAIT_MAX - 1'b1))
        rd_fifo_rd_en   <=  1'b1;
    else
        rd_fifo_rd_en   <=  1'b0;

//tx_flag:读fifo读出数据标志信号
always@(posedge sys_clk or negedge sys_rst_n)
    if(sys_rst_n == 1'b0)
        tx_flag <=  1'b0;
    else
        tx_flag <=  rd_fifo_rd_en;

//********************************************************************//
//************************** Instantiation ***************************//
//********************************************************************//
//------------- fifo_wr_data_inst -------------
fifo_wr_data   fifo_wr_data_inst
(
    .wrclk      (sys_clk            ),  //数据写时钟
    .wrreq      (rx_flag            ),  //数据写使能
    .data       (rx_data            ),  //写入数据

    .rdclk      (sys_clk            ),  //数据读时钟
    .rdreq      (wr_req             ),  //数据读使能
    .q          (wr_data            ),  //读出数据
    .rdusedw    (wr_fifo_data_num   )   //fifo内剩余数据个数
);

//------------- fifo_rd_data_inst -------------
fifo_rd_data    fifo_rd_data_inst
(
    .wrclk      (sys_clk        ),  //数据写时钟
    .wrreq      (rd_data_en     ),  //数据写使能
    .data       (rd_data        ),  //写入数据

    .rdclk      (sys_clk        ),  //数据读时钟
    .rdreq      (rd_fifo_rd_en  ),  //数据读使能
    .q          (tx_data        )   //读出数据
);

endmodule