`timescale  1ns/1ns
////////////////////////////////////////////////////////////////////////
// Author        : EmbedFire
// Create Date   : 2019/03/27
// Module Name   : flash_read_ctrl
// Project Name  : spi_flash_read
// Target Devices: Altera EP4CE10F17C8N
// Tool Versions : Quartus 13.0
// Description   : flash读控制模块
//
// Revision      : V1.0
// Additional Comments:
// 
// 实验平台: 野火_征途Pro_FPGA开发板
// 公司    : http://www.embedfire.com
// 论坛    : http://www.firebbs.cn
// 淘宝    : https://fire-stm32.taobao.com
////////////////////////////////////////////////////////////////////////

module  flash_read_ctrl(

    input   wire            sys_clk     ,   //系统时钟，频率50MHz
    input   wire            sys_rst_n   ,   //复位信号,低电平有效
    input   wire            key         ,   //按键输入信号
    input   wire            miso        ,   //读出flash数据

    output  reg             sck         ,   //串行时钟
    output  reg             cs_n        ,   //片选信号
    output  reg             mosi        ,   //主输出从输入数据
    output  reg             tx_flag     ,   //输出数据标志信号
    output  wire    [7:0]   tx_data         //输出数据

);

//********************************************************************//
//****************** Parameter and Internal Signal *******************//
//********************************************************************//

//parameter define
parameter   IDLE    =   3'b001  ,   //初始状态
            READ    =   3'b010  ,   //数据读状态
            SEND    =   3'b100  ;   //数据发送状态

parameter   READ_INST   =   8'b0000_0011;   //读指令
parameter   NUM_DATA    =   16'd100     ;   //读出数据个数
parameter   SECTOR_ADDR =   8'b0000_0000,   //扇区地址
            PAGE_ADDR   =   8'b0000_0100,   //页地址
            BYTE_ADDR   =   8'b0010_0101;   //字节地址
parameter   CNT_WAIT_MAX=   16'd6_00_00 ;

//wire  define
wire    [7:0]   fifo_data_num   ;   //fifo内数据个数
//reg   define
reg     [4:0]   cnt_clk         ;   //系统时钟计数器
reg     [2:0]   state           ;   //状态机状态
reg     [15:0]  cnt_byte        ;   //字节计数器
reg     [1:0]   cnt_sck         ;   //串行时钟计数器
reg     [2:0]   cnt_bit         ;   //比特计数器
reg             miso_flag       ;   //miso提取标志信号
reg     [7:0]   data            ;   //拼接数据
reg             po_flag_reg     ;   //输出数据标志信号
reg             po_flag         ;   //输出数据
reg     [7:0]   po_data         ;   //输出数据
reg             fifo_read_valid ;   //fifo读有效信号
reg     [15:0]  cnt_wait        ;   //等待计数器
reg             fifo_read_en    ;   //fifo读使能
reg     [7:0]   read_data_num   ;   //读出fifo数据个数

//********************************************************************//
//***************************** Main Code ****************************//
//********************************************************************//
//cnt_clk：系统时钟计数器，用以记录单个字节
always@(posedge sys_clk or  negedge sys_rst_n)
    if(sys_rst_n == 1'b0)
        cnt_clk  <=  5'd0;
    else    if(state == READ)
        cnt_clk  <=  cnt_clk + 1'b1;

//cnt_byte：记录输出字节个数和等待时间
always@(posedge sys_clk or  negedge sys_rst_n)
    if(sys_rst_n == 1'b0)
        cnt_byte    <=  16'd0;
    else    if((cnt_clk == 5'd31) && (cnt_byte == NUM_DATA + 16'd3))
        cnt_byte    <=  16'd0;
    else    if(cnt_clk == 5'd31)
        cnt_byte    <=  cnt_byte + 1'b1;

//cnt_sck：串行时钟计数器，用以生成串行时钟
always@(posedge sys_clk or  negedge sys_rst_n)
    if(sys_rst_n == 1'b0)
        cnt_sck <=  2'd0;
    else    if(state == READ)
        cnt_sck <=  cnt_sck + 1'b1;

//cs_n：片选信号
always@(posedge sys_clk or  negedge sys_rst_n)
    if(sys_rst_n == 1'b0)
        cs_n    <=  1'b1;
    else    if(key == 1'b1)
        cs_n    <=  1'b0;
    else    if((cnt_byte == NUM_DATA + 16'd3) && (cnt_clk == 5'd31) && (state == READ))
        cs_n    <=  1'b1;

//sck：输出串行时钟
always@(posedge sys_clk or  negedge sys_rst_n)
    if(sys_rst_n == 1'b0)
        sck <=  1'b0;
    else    if(cnt_sck == 2'd0)
        sck <=  1'b0;
    else    if(cnt_sck == 2'd2)
        sck <=  1'b1;

//cnt_bit：高低位对调，控制mosi输出
always@(posedge sys_clk or  negedge sys_rst_n)
    if(sys_rst_n == 1'b0)
        cnt_bit <=  3'd0;
    else    if(cnt_sck == 2'd2)
        cnt_bit <=  cnt_bit + 1'b1;

//state：两段式状态机第一段，状态跳转
always@(posedge sys_clk or  negedge sys_rst_n)
    if(sys_rst_n == 1'b0)
        state   <=  IDLE;
    else
    case(state)
        IDLE:   if(key == 1'b1)
                    state   <=  READ;
        READ:   if((cnt_byte == NUM_DATA + 16'd3) && (cnt_clk == 5'd31))
                    state   <=  SEND;
        SEND:   if((read_data_num == NUM_DATA)
                && ((cnt_wait == (CNT_WAIT_MAX - 1'b1))))
                    state   <=  IDLE;
        default:    state   <=  IDLE;
    endcase

//mosi：两段式状态机第二段，逻辑输出
always@(posedge sys_clk or  negedge sys_rst_n)
    if(sys_rst_n == 1'b0)
        mosi    <=  1'b0;
    else    if((state == READ) && (cnt_byte>= 16'd4))
        mosi    <=  1'b0;
    else    if((state == READ) && (cnt_byte == 16'd0) && (cnt_sck == 2'd0))
        mosi    <=  READ_INST[7 - cnt_bit];  //读指令
    else    if((state == READ) && (cnt_byte == 16'd1) && (cnt_sck == 2'd0))
        mosi    <=  SECTOR_ADDR[7 - cnt_bit];  //扇区地址
    else    if((state == READ) && (cnt_byte == 16'd2) && (cnt_sck == 2'd0))
        mosi    <=  PAGE_ADDR[7 - cnt_bit];    //页地址
    else    if((state == READ) && (cnt_byte == 16'd3) && (cnt_sck == 2'd0))
        mosi    <=  BYTE_ADDR[7 - cnt_bit];    //字节地址

//miso_flag：miso提取标志信号
always@(posedge sys_clk or  negedge sys_rst_n)
    if(sys_rst_n == 1'b0)
        miso_flag   <=  1'b0;
    else    if((cnt_byte >= 16'd4) && (cnt_sck == 2'd1))
        miso_flag   <=  1'b1;
    else
        miso_flag   <=  1'b0;

//data：拼接数据
always@(posedge sys_clk or  negedge sys_rst_n)
    if(sys_rst_n == 1'b0)
        data    <=  8'd0;
    else    if(miso_flag == 1'b1)
        data    <=  {data[6:0],miso};

//po_flag_reg:输出数据标志信号
always@(posedge sys_clk or  negedge sys_rst_n)
    if(sys_rst_n == 1'b0)
        po_flag_reg <=  1'b0;
    else    if((cnt_bit == 3'd7) && (miso_flag == 1'b1))
        po_flag_reg <=  1'b1;
    else
        po_flag_reg <=  1'b0;

//po_flag:输出数据标志信号
always@(posedge sys_clk or  negedge sys_rst_n)
    if(sys_rst_n == 1'b0)
        po_flag <=  1'b0;
    else
        po_flag <=  po_flag_reg;

//po_data:输出数据
always@(posedge sys_clk or  negedge sys_rst_n)
    if(sys_rst_n == 1'b0)
        po_data <=  8'd0;
    else    if(po_flag_reg == 1'b1)
        po_data <=  data;
    else
        po_data <=  po_data;

//fifo_read_valid:fifo读有效信号
always@(posedge sys_clk or  negedge sys_rst_n)
    if(sys_rst_n == 1'b0)
        fifo_read_valid <=  1'b0;
    else    if((read_data_num == NUM_DATA)
                && ((cnt_wait == (CNT_WAIT_MAX - 1'b1))))
        fifo_read_valid <=  1'b0;
    else    if(fifo_data_num == NUM_DATA)
        fifo_read_valid <=  1'b1;

//cnt_wait:两数据读取时间间隔
always@(posedge sys_clk or  negedge sys_rst_n)
    if(sys_rst_n == 1'b0)
        cnt_wait    <=  16'd0;
    else    if(fifo_read_valid == 1'b0)
        cnt_wait    <=  16'd0;
    else    if(cnt_wait == (CNT_WAIT_MAX - 1'b1))
        cnt_wait    <=  16'd0;
    else    if(fifo_read_valid == 1'b1)
        cnt_wait    <=  cnt_wait + 1'b1;

//fifo_read_en:fifo读使能信号
always@(posedge sys_clk or negedge sys_rst_n)
    if(sys_rst_n == 1'b0)
        fifo_read_en <=  1'b0;
    else    if((cnt_wait == (CNT_WAIT_MAX - 1'b1))
                && (read_data_num < NUM_DATA))
        fifo_read_en <=  1'b1;
    else
        fifo_read_en <=  1'b0;

//read_data_num:自fifo中读出数据个数计数
always@(posedge sys_clk or negedge sys_rst_n)
    if(sys_rst_n == 1'b0)
        read_data_num <=  8'd0;
    else    if(fifo_read_valid == 1'b0)
        read_data_num <=  8'd0;
    else    if(fifo_read_en == 1'b1)
        read_data_num <=  read_data_num + 1'b1;

//tx_flag
always@(posedge sys_clk or negedge sys_rst_n)
    if(sys_rst_n == 1'b0)
        tx_flag <=  1'b0;
    else
        tx_flag <=  fifo_read_en;

//********************************************************************//
//*************************** Instantiation **************************//
//********************************************************************//
//-------------fifo_data_inst--------------
fifo_data fifo_data_inst(
    .clock  (sys_clk      ),    //时钟信号
    .data   (po_data      ),    //写数据,8bit
    .wrreq  (po_flag      ),    //写请求
    .rdreq  (fifo_read_en ),    //读请求

    .q      (tx_data      ),    //数据读出,8bit
    .usedw  (fifo_data_num)     //fifo内数据个数
);

endmodule
