`timescale  1ns/1ns
////////////////////////////////////////////////////////////////////////
// Author        : EmbedFire
// Create Date   : 2019/04/01
// Module Name   : i2c_rw_data
// Project Name  : eeprom_byte_rd_wr
// Target Devices: Altera EP4CE10F17C8N
// Tool Versions : Quartus 13.0
// Description   : eeprom读写数据模块
//
// Revision      : V1.0
// Additional Comments:
// 
// 实验平台: 野火_征途Pro_FPGA开发板
// 公司    : http://www.embedfire.com
// 论坛    : http://www.firebbs.cn
// 淘宝    : https://fire-stm32.taobao.com
////////////////////////////////////////////////////////////////////////

module  i2c_rw_data
(
    input   wire            sys_clk     ,   //输入系统时钟,频率50MHz
    input   wire            i2c_clk     ,   //输入i2c驱动时钟,频率1MHz
    input   wire            sys_rst_n   ,   //输入复位信号,低有效
    input   wire            write       ,   //输入写触发信号
    input   wire            read        ,   //输入读触发信号
    input   wire            i2c_end     ,   //一次i2c读/写结束信号
    input   wire    [7:0]   rd_data     ,   //输入自i2c设备读出的数据

    output  reg             wr_en       ,   //输出写使能信号
    output  reg             rd_en       ,   //输出读使能信号
    output  reg             i2c_start   ,   //输出i2c读/写触发信号
    output  reg     [15:0]  byte_addr   ,   //输出i2c设备读/写地址
    output  reg     [7:0]   wr_data     ,   //输出写入i2c设备的数据
    output  wire    [7:0]   fifo_rd_data    //输出自fifo中读出的数据
);

//********************************************************************//
//****************** Parameter and Internal Signal *******************//
//********************************************************************//
// parameter  define
parameter   DATA_NUM        =   8'd10       ,   //读/写操作读出或写入的数据个数
            CNT_START_MAX   =   16'd4000    ,   //cnt_start计数器计数最大值
            CNT_WR_RD_MAX   =   8'd200      ,   //cnt_wr/cnt_rd计数器计数最大值
            CNT_WAIT_MAX    =   28'd500_000 ;   //cnt_wait计数器计数最大值
// wire  define
wire    [7:0]   data_num    ;   //fifo中数据个数

// reg   define
reg     [7:0]   cnt_wr          ;   //写触发有效信号保持时间计数器
reg             write_valid     ;   //写触发有效信号
reg     [7:0]   cnt_rd          ;   //读触发有效信号保持时间计数器
reg             read_valid      ;   //读触发有效信号
reg     [15:0]  cnt_start       ;   //单字节数据读/写时间间隔计数
reg     [7:0]   wr_i2c_data_num ;   //写入i2c设备的数据个数
reg     [7:0]   rd_i2c_data_num ;   //读出i2c设备的数据个数
reg             fifo_rd_valid   ;   //fifo读有效信号
reg     [27:0]  cnt_wait        ;   //fifo读使能信号间时间间隔计数
reg             fifo_rd_en      ;   //fifo读使能信号
reg     [7:0]   rd_data_num     ;   //读出fifo数据个数

//********************************************************************//
//***************************** Main Code ****************************//
//********************************************************************//
//cnt_wr:写触发有效信号保持时间计数器,计数写触发有效信号保持时钟周期数
always@(posedge sys_clk or negedge sys_rst_n)
    if(sys_rst_n == 1'b0)
        cnt_wr    <=  8'd0;
    else    if(write_valid == 1'b0)
        cnt_wr    <=  8'd0;
    else    if(write_valid == 1'b1)
        cnt_wr    <=  cnt_wr + 1'b1;

//write_valid:写触发有效信号
//由于写触发信号保持时间为一个系统时钟周期(20ns),
//不能被i2c驱动时钟i2c_scl正确采集,延长写触发信号生成写触发有效信号
always@(posedge sys_clk or negedge sys_rst_n)
    if(sys_rst_n == 1'b0)
        write_valid    <=  1'b0;
    else    if(cnt_wr == (CNT_WR_RD_MAX - 1'b1))
        write_valid    <=  1'b0;
    else    if(write == 1'b1)
        write_valid    <=  1'b1;

//cnt_rd:读触发有效信号保持时间计数器,计数读触发有效信号保持时钟周期数
always@(posedge sys_clk or negedge sys_rst_n)
    if(sys_rst_n == 1'b0)
        cnt_rd    <=  8'd0;
    else    if(read_valid == 1'b0)
        cnt_rd    <=  8'd0;
    else    if(read_valid == 1'b1)
        cnt_rd    <=  cnt_rd + 1'b1;

//read_valid:读触发有效信号
//由于读触发信号保持时间为一个系统时钟周期(20ns),
//不能被i2c驱动时钟i2c_scl正确采集,延长读触发信号生成读触发有效信号
always@(posedge sys_clk or negedge sys_rst_n)
    if(sys_rst_n == 1'b0)
        read_valid    <=  1'b0;
    else    if(cnt_rd == (CNT_WR_RD_MAX - 1'b1))
        read_valid    <=  1'b0;
    else    if(read == 1'b1)
        read_valid    <=  1'b1;

//cnt_start:单字节数据读/写操作时间间隔计数
always@(posedge i2c_clk or negedge sys_rst_n)
    if(sys_rst_n == 1'b0)
        cnt_start   <=  16'd0;
    else    if((wr_en == 1'b0) && (rd_en == 1'b0))
        cnt_start   <=  16'd0;
    else    if(cnt_start == (CNT_START_MAX - 1'b1))
        cnt_start   <=  16'd0;
    else    if((wr_en == 1'b1) || (rd_en == 1'b1))
        cnt_start   <=  cnt_start + 1'b1;

//i2c_start:i2c读/写触发信号
always@(posedge i2c_clk or negedge sys_rst_n)
    if(sys_rst_n == 1'b0)
        i2c_start   <=  1'b0;
    else    if((cnt_start == (CNT_START_MAX - 1'b1)))
        i2c_start   <=  1'b1;
    else
        i2c_start   <=  1'b0;

//wr_en:输出写使能信号
always@(posedge i2c_clk or negedge sys_rst_n)
    if(sys_rst_n == 1'b0)
        wr_en   <=  1'b0;
    else    if((wr_i2c_data_num == DATA_NUM - 1) 
                && (i2c_end == 1'b1) && (wr_en == 1'b1))
        wr_en   <=  1'b0;
    else    if(write_valid == 1'b1)
        wr_en   <=  1'b1;

//wr_i2c_data_num:写入i2c设备的数据个数
always@(posedge i2c_clk or negedge sys_rst_n)
    if(sys_rst_n == 1'b0)
        wr_i2c_data_num <=  8'd0;
    else    if(wr_en == 1'b0)
        wr_i2c_data_num <=  8'd0;
    else    if((wr_en == 1'b1) && (i2c_end == 1'b1))
        wr_i2c_data_num <=  wr_i2c_data_num + 1'b1;

//rd_en:输出读使能信号
always@(posedge i2c_clk or negedge sys_rst_n)
    if(sys_rst_n == 1'b0)
        rd_en   <=  1'b0;
    else    if((rd_i2c_data_num == DATA_NUM - 1) 
                && (i2c_end == 1'b1) && (rd_en == 1'b1))
        rd_en   <=  1'b0;
    else    if(read_valid == 1'b1)
        rd_en   <=  1'b1;

//rd_i2c_data_num:写入i2c设备的数据个数
always@(posedge i2c_clk or negedge sys_rst_n)
    if(sys_rst_n == 1'b0)
        rd_i2c_data_num <=  8'd0;
    else    if(rd_en == 1'b0)
        rd_i2c_data_num <=  8'd0;
    else    if((rd_en == 1'b1) && (i2c_end == 1'b1))
        rd_i2c_data_num <=  rd_i2c_data_num + 1'b1;

//byte_addr:输出读/写地址
always@(posedge i2c_clk or negedge sys_rst_n)
    if(sys_rst_n == 1'b0)
        byte_addr   <=  16'h00_5A;
    else    if((wr_en == 1'b0) && (rd_en == 1'b0))
        byte_addr   <=  16'h00_5A;
    else    if(((wr_en == 1'b1) || (rd_en == 1'b1)) && (i2c_end == 1'b1))
        byte_addr   <=  byte_addr + 1'b1;

//wr_data:输出待写入i2c设备数据
always@(posedge i2c_clk or negedge sys_rst_n)
    if(sys_rst_n == 1'b0)
        wr_data <=  8'h01;
    else    if(wr_en == 1'b0)
        wr_data <=  8'h01;
    else    if((wr_en == 1'b1) && (i2c_end == 1'b1))
        wr_data <=  wr_data + 1'b1;

//fifo_rd_valid:fifo读有效信号
always@(posedge i2c_clk or negedge sys_rst_n)
    if(sys_rst_n == 1'b0)
        fifo_rd_valid  <=  1'b0;
    else    if((rd_data_num == DATA_NUM)
                && (cnt_wait == (CNT_WAIT_MAX - 1'b1)))
        fifo_rd_valid  <=  1'b0;
    else    if(data_num == DATA_NUM)
        fifo_rd_valid  <=  1'b1;

//cnt_wait:fifo读使能信号间时间间隔计数,计数两fifo读使能间的时间间隔
always@(posedge i2c_clk or negedge sys_rst_n)
    if(sys_rst_n == 1'b0)
        cnt_wait    <=  28'd0;
    else    if(fifo_rd_valid == 1'b0)
        cnt_wait    <=  28'd0;
    else    if(cnt_wait == (CNT_WAIT_MAX - 1'b1))
        cnt_wait    <=  28'd0;
    else    if(fifo_rd_valid == 1'b1)
        cnt_wait    <=  cnt_wait + 1'b1;

//fifo_rd_en:fifo读使能信号
always@(posedge i2c_clk or negedge sys_rst_n)
    if(sys_rst_n == 1'b0)
        fifo_rd_en <=  1'b0;
    else    if((cnt_wait == (CNT_WAIT_MAX - 1'b1))
                && (rd_data_num < DATA_NUM))
        fifo_rd_en <=  1'b1;
    else
        fifo_rd_en <=  1'b0;

//rd_data_num:自fifo中读出数据个数计数
always@(posedge i2c_clk or negedge sys_rst_n)
    if(sys_rst_n == 1'b0)
        rd_data_num <=  8'd0;
    else    if(fifo_rd_valid == 1'b0)
        rd_data_num <=  8'd0;
    else    if(fifo_rd_en == 1'b1)
        rd_data_num <=  rd_data_num + 1'b1;

//****************************************************************//
//************************* Instantiation ************************//
//****************************************************************//
//------------- fifo_read_inst -------------
fifo_data   fifo_read_inst
(
    .clock  (i2c_clk            ),  //输入时钟信号,频率1MHz,1bit
    .data   (rd_data            ),  //输入写入数据,1bit
    .rdreq  (fifo_rd_en         ),  //输入数据读请求,1bit
    .wrreq  (i2c_end && rd_en   ),  //输入数据写请求,1bit

    .q      (fifo_rd_data       ),  //输出读出数据,1bit
    .usedw  (data_num           )   //输出fifo内数据个数,1bit
);

endmodule







