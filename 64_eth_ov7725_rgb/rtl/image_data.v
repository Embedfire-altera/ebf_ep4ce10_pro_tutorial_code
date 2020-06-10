`timescale  1ns/1ns
////////////////////////////////////////////////////////////////////////
// Author        : EmbedFire
// Create Date   : 2019/10/25
// Module Name   : eth_ov7725_rgb
// Project Name  : image_data
// Target Devices: Altera EP4CE10F17C8N
// Tool Versions : Quartus 13.0
// Description   : 图像数据包发送
// 
// Revision      : V1.0
// Additional Comments:
// 
// 实验平台: 野火_征途Pro_FPGA开发板
// 公司    : http://www.embedfire.com
// 论坛    : http://www.firebbs.cn
// 淘宝    : https://fire-stm32.taobao.com
////////////////////////////////////////////////////////////////////////

module  image_data
#(
    parameter   H_PIXEL =   11'd640     ,   //图像水平方向像素个数
    parameter   V_PIXEL =   11'd480     ,   //图像竖直方向像素个数
    parameter   CNT_FRAME_WAIT = 24'h0E_FF_FF , //单帧图像等待时间计数
    parameter   CNT_IDLE_WAIT  = 24'h00_01_99   //单包数据等待时间计数
)
(
    input   wire            sys_clk     ,   //系统时钟,频率25MHz
    input   wire            sys_rst_n   ,   //复位信号,低电平有效
    input   wire    [15:0]  image_data  ,   //自SDRAM中读取的16位图像数据
    input   wire            eth_tx_req  ,   //以太网发送数据请求信号
    input   wire            eth_tx_done ,   //以太网发送数据完成信号

    output  reg             data_rd_req ,   //图像数据请求信号
    output  reg             eth_tx_start,   //以太网发送数据开始信号
    output  wire    [31:0]  eth_tx_data ,   //以太网发送数据
    output  reg     [15:0]  eth_tx_data_num //以太网单包数据有效字节数
);

//********************************************************************//
//****************** Parameter and Internal Signal *******************//
//********************************************************************//
//parameter define
parameter   IDLE        =   6'b0000_01, //初始状态
            FIRST_BAG   =   6'b0000_10, //发送第一包数据(包含包头)
            COM_BAG     =   6'b0001_00, //发送普通包数据
            LAST_BAG    =   6'b0010_00, //发送最后一包数据(包含CRC-16)
            BAG_WAIT    =   6'b0100_00, //单包数据发送完成等待
            FRAME_END   =   6'b1000_00; //一帧图像发送完成等待

//wire  define
wire            fifo_empty      ;   //FIFO读空信号
wire            fifo_empty_fall ;   //FIFO读空信号下降沿

//reg       define
reg     [5:0]   state           ;   //状态机状态
reg     [23:0]  cnt_idle_wait   ;   //初始状态即单包间隔等待时间计数
reg     [10:0]  cnt_h           ;   //单包数据包含像素个数计数(一行图像)
reg             data_rd_req1    ;
reg             data_rd_req2    ;
reg             data_rd_req3    ;
reg             data_rd_req4    ;
reg             data_rd_req5    ;
reg             data_rd_req6    ;   //图像数据请求信号打拍(插入包头和CRC)
reg     [15:0]  image_data1     ;
reg     [15:0]  image_data2     ;
reg     [15:0]  image_data3     ;
reg     [15:0]  image_data4     ;
reg     [15:0]  image_data5     ;
reg     [15:0]  image_data6     ;   //图像数据打拍(目的是插入包头和CRC)
reg             data_valid      ;   //图像数据有效信号
reg             wr_fifo_en      ;   //FIFO写使能
reg     [15:0]  cnt_wr_data     ;   //写入FIFO数据个数(单位2字节)
reg     [31:0]  wr_fifo_data    ;   //写入FIFO数据
reg             fifo_empty_reg  ;   //fifo读空信号打一拍
reg     [10:0]  cnt_v           ;   //一帧图像发送包个数(一帧图像行数)
reg     [23:0]  cnt_frame_wait  ;   //单帧图像等待时间计数

//********************************************************************//
//***************************** Main Code ****************************//
//********************************************************************//
//state:状态机状态变量
always@(posedge sys_clk or negedge sys_rst_n)
    if(sys_rst_n == 1'b0)
        state   <=  IDLE;
    else    case(state)
        IDLE:
            if(cnt_idle_wait == CNT_IDLE_WAIT)
                state   <=  FIRST_BAG;
            else
                state   <=  IDLE;
        FIRST_BAG:
            if(eth_tx_done == 1'b1)
                state   <=  BAG_WAIT;
            else
                state   <=  FIRST_BAG;
        BAG_WAIT:
            if((cnt_v < V_PIXEL - 11'd1) && 
                (cnt_idle_wait == CNT_IDLE_WAIT))
                state   <=  COM_BAG;
            else    if((cnt_v == V_PIXEL - 11'd1) && 
                        (cnt_idle_wait == CNT_IDLE_WAIT))
                state   <=  LAST_BAG;
            else
                state   <=  BAG_WAIT;
        COM_BAG:
            if(eth_tx_done == 1'b1)
                state   <=  BAG_WAIT;
            else
                state   <=  COM_BAG;
        LAST_BAG:
            if(eth_tx_done == 1'b1)
                state   <=  FRAME_END;
            else
                state   <=  LAST_BAG;
        FRAME_END:
            if(cnt_frame_wait == CNT_FRAME_WAIT)
                state   <=  IDLE;
            else
                state   <=  FRAME_END;
        default:state   <=  IDLE;
    endcase

//cnt_idle_wait:初始状态即单包间隔等待时间计数
always@(posedge sys_clk or negedge sys_rst_n)
    if(sys_rst_n == 1'b0)
        cnt_idle_wait   <=  24'd0;
    else    if(((state == IDLE) || (state == BAG_WAIT)) && (cnt_idle_wait < CNT_IDLE_WAIT))
        cnt_idle_wait   <=  cnt_idle_wait + 1'b1;
    else
        cnt_idle_wait   <=  24'd0;

//cnt_h:单包数据包含像素个数计数(一行图像)
always@(posedge sys_clk or negedge sys_rst_n)
    if(sys_rst_n == 1'b0)
        cnt_h   <=  11'd0;
    else    if(cnt_h == 11'd0)
        if(cnt_idle_wait == CNT_IDLE_WAIT)
            cnt_h   <=  H_PIXEL;
        else
            cnt_h   <=  cnt_h;
    else
        cnt_h   <=  cnt_h - 1'b1;

//data_rd_req:图像数据请求信号
always@(posedge sys_clk or negedge sys_rst_n)
    if(sys_rst_n == 1'b0)
        data_rd_req     <=  1'b0;
    else    if(cnt_h != 11'd0)
        data_rd_req     <=  1'b1;
    else
        data_rd_req     <=  1'b0;

//图像数据请求信号打拍,插入包头和CRC
always @(posedge sys_clk or negedge sys_rst_n)
    if(!sys_rst_n)
        begin
            data_rd_req1    <=  1'b0;
            data_rd_req2    <=  1'b0;
            data_rd_req3    <=  1'b0;
            data_rd_req4    <=  1'b0;
            data_rd_req5    <=  1'b0;
            data_rd_req6    <=  1'b0;
        end
    else
        begin
            data_rd_req1    <=  data_rd_req;
            data_rd_req2    <=  data_rd_req1;
            data_rd_req3    <=  data_rd_req2;
            data_rd_req4    <=  data_rd_req3;
            data_rd_req5    <=  data_rd_req4;
            data_rd_req6    <=  data_rd_req5;
        end

//图像数据打拍,方便插入包头和CRC
always@(posedge sys_clk or negedge sys_rst_n)
    if(!sys_rst_n)
        begin
            image_data1    <=  16'b0;
            image_data2    <=  16'b0;
            image_data3    <=  16'b0;
            image_data4    <=  16'b0;
            image_data5    <=  16'b0;
            image_data6    <=  16'b0;
        end
    else
        begin
            image_data1    <=  image_data;
            image_data2    <=  image_data1;
            image_data3    <=  image_data2;
            image_data4    <=  image_data3;
            image_data5    <=  image_data4;
            image_data6    <=  image_data5;
        end

//data_valid:图像数据有效信号
always@(posedge sys_clk or negedge sys_rst_n)
    if(sys_rst_n == 1'b0)
        data_valid  <=  1'b0;
    else    if(state == FIRST_BAG)
        data_valid  <=  (data_rd_req1 || data_rd_req6);
    else    if(state == LAST_BAG)
        data_valid  <=  (data_rd_req4 || data_rd_req5);
    else
        data_valid  <=  data_rd_req1;

//wr_fifo_en:FIFO写使能
always@(posedge sys_clk or negedge sys_rst_n)
    if(sys_rst_n == 1'b0)
        wr_fifo_en   <=  1'b0;
    else    if(data_valid == 1'b1)
        wr_fifo_en   <=  ~wr_fifo_en;
    else
        wr_fifo_en   <=  1'b0;

//cnt_wr_data:写入FIFO数据个数
always@(posedge sys_clk or negedge sys_rst_n)
    if(sys_rst_n == 1'b0)
        cnt_wr_data <=  16'd0;
    else    if(data_valid == 1'b1)
        if(wr_fifo_en == 1'b1)
            cnt_wr_data <=  cnt_wr_data + 1'b1;
        else
            cnt_wr_data <=  cnt_wr_data;
    else
        cnt_wr_data <=  16'd0;

//wr_fifo_data:写入FIFO数据
always@(posedge sys_clk or negedge sys_rst_n)
    if(sys_rst_n == 1'b0)
        wr_fifo_data    <=  32'h0;
    else    if(wr_fifo_en == 1'b0)
        if(state == FIRST_BAG)
            if(cnt_wr_data == 16'd0)
                wr_fifo_data    <=  32'h53_5a_48_59;
            else    if(cnt_wr_data == 16'd1)
                wr_fifo_data    <=  32'h00_0C_60_09;
            else    if(cnt_wr_data == 16'd2)
                wr_fifo_data    <=  {16'h00_02,image_data5};
            else
                wr_fifo_data    <=  {image_data6,image_data5};
        else    if(state == COM_BAG)
            wr_fifo_data    <=  {image_data2,image_data1};
        else    if(state == LAST_BAG)
            if(cnt_wr_data == 16'd320)
                wr_fifo_data    <=  {16'h5A_A5,16'h00_00};
            else
                wr_fifo_data    <=  {image_data4,image_data3};
    else
        wr_fifo_data    <=  wr_fifo_data;

//fifo_empty:FIFO读空信号
always@(posedge sys_clk or negedge sys_rst_n)
    if(sys_rst_n == 1'b0)
        fifo_empty_reg   <=  1'b1;
    else
        fifo_empty_reg   <=  fifo_empty;

//fifo_empty_fall:FIFO读空信号下降沿
assign  fifo_empty_fall = ((fifo_empty_reg == 1'b1) && (fifo_empty == 1'b0));

//eth_tx_start:以太网发送数据开始信号
always@(posedge sys_clk or negedge sys_rst_n)
    if(sys_rst_n == 1'b0)
        eth_tx_start    <=  1'b0;
    else    if(fifo_empty_fall == 1'b1)
        eth_tx_start    <=  1'b1;  
    else
        eth_tx_start    <=  1'b0;

//eth_tx_data_num:以太网单包数据有效字节数
always@(posedge sys_clk or negedge sys_rst_n)
    if(sys_rst_n == 1'b0)
        eth_tx_data_num     <=  16'd0;
    else    if(state == FIRST_BAG)
        eth_tx_data_num     <=  {H_PIXEL,1'b0} + 16'd10;
    else    if(state == COM_BAG)
        eth_tx_data_num     <=  {H_PIXEL,1'b0};
    else    if(state == LAST_BAG)
        eth_tx_data_num     <=  {H_PIXEL,1'b0} + 16'd2;
    else
        eth_tx_data_num     <=  eth_tx_data_num;

//cnt_v:一帧图像发送包个数(一帧图像行数)
always@(posedge sys_clk or negedge sys_rst_n)
    if(sys_rst_n == 1'b0)
        cnt_v   <=  11'd0;
    else    if(state == IDLE)
        cnt_v   <=  11'd0;
    else    if(eth_tx_done == 1'b1)
        cnt_v   <=  cnt_v + 1'b1;
    else
        cnt_v   <=  cnt_v;

//cnt_frame_wait:单帧图像等待时间计数
always@(posedge sys_clk or negedge sys_rst_n)
    if(sys_rst_n == 1'b0)
        cnt_frame_wait  <=  24'd0;
    else    if((state == FRAME_END) && (cnt_frame_wait < CNT_FRAME_WAIT))
        cnt_frame_wait  <=  cnt_frame_wait + 1'b1;
    else
        cnt_frame_wait  <=  24'd0;

//********************************************************************//
//*************************** Instantiation **************************//
//********************************************************************//
//------------- fifo_image_inst -------------
fifo_image    fifo_image_inst
(
    .aclr          (~sys_rst_n  ),
    .clock         (sys_clk     ),
    .data          (wr_fifo_data),
    .rdreq         (eth_tx_req  ),
    .wrreq         (wr_fifo_en  ),

    .empty         (fifo_empty  ),
    .q             (eth_tx_data )
);

endmodule
