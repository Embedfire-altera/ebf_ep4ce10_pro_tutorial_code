`timescale  1ns/1ns
////////////////////////////////////////////////////////////////////////
// Author        : EmbedFire
// Create Date   : 2019/09/05
// Module Name   : data_read_ctrl
// Project Name  : sd_hdmi_pic
// Target Devices: Altera EP4CE10F17C8N
// Tool Versions : Quartus 13.0
// Description   : SD卡数据读控制模块
// 
// Revision      : V1.0
// Additional Comments:
// 
// 实验平台: 野火_征途Pro_FPGA开发板
// 公司    : http://www.embedfire.com
// 论坛    : http://www.firebbs.cn
// 淘宝    : https://fire-stm32.taobao.com
////////////////////////////////////////////////////////////////////////

module  data_rd_ctrl
(
    input   wire            sys_clk     ,   //输入工作时钟,频率50MHz
    input   wire            sys_rst_n   ,   //输入复位信号,低电平有效
    input   wire            rd_busy     ,   //读操作忙信号

    output  reg             rd_en       ,   //数据读使能信号
    output  reg     [31:0]  rd_addr         //读数据扇区地址
);

//********************************************************************//
//****************** Parameter and Internal Signal *******************//
//********************************************************************//
//parameter define
parameter   IDLE    =   3'b001, //初始状态
            READ    =   3'b010, //读数据状态
            WAIT    =   3'b100; //等待状态
parameter   IMG_SEC_ADDR0   =   32'd16640,  //图片1扇区起始地址
            IMG_SEC_ADDR1   =   32'd17856;  //图片2扇区起始地址
parameter   RD_NUM  =   11'd1200    ;       //单张图片读取次数
parameter   WAIT_MAX=   26'd50_000_000  ;   //图片切换时间间隔计数最大值

//wire  define
wire            rd_busy_fall;   //读操作忙信号下降沿

//reg   defien
reg             rd_busy_dly ;   //读操作忙信号打一拍
reg     [2:0]   state       ;   //状态机状态
reg     [10:0]  cnt_rd      ;   //单张图片读取次数计数
reg             pic_c       ;   //图片切换
reg     [25:0]  cnt_wait    ;   //图片切换时间间隔计数

//********************************************************************//
//***************************** Main Code ****************************//
//********************************************************************//
//rd_busy_dly:读操作忙信号打一拍
always@(posedge sys_clk or negedge sys_rst_n)
    if(sys_rst_n == 1'b0)
        rd_busy_dly <=  1'b0;
    else
        rd_busy_dly <=  rd_busy;

//rd_busy_fall:读操作忙信号下降沿
assign  rd_busy_fall = ((rd_busy == 1'b0) && (rd_busy_dly == 1'b1))
                        ? 1'b1 : 1'b0;

//state:状态机状态
always@(posedge sys_clk or negedge sys_rst_n)
    if(sys_rst_n == 1'b0)
        state   <=  IDLE;
    else
        case(state)
            IDLE:   state   <=  READ;
            READ:
                if(cnt_rd == (RD_NUM - 1'b1))
                    state   <=  WAIT;
                else
                    state   <=  state;
            WAIT:
                if(cnt_wait == (WAIT_MAX - 1'b1))
                    state   <=  IDLE;
                else
                    state   <=  state;
            default:    state   <=  IDLE;
        endcase

//pic_c:图片切换
always@(posedge sys_clk or negedge sys_rst_n)
    if(sys_rst_n == 1'b0)
        pic_c   <=  1'b0;
    else    if(state == IDLE)
        pic_c   <=  ~pic_c;
    else
        pic_c   <=  pic_c;

//cnt_rd:单张图片读取次数计数
always@(posedge sys_clk or negedge sys_rst_n)
    if(sys_rst_n == 1'b0)
        cnt_rd  <=  11'd0;
    else    if(state == READ)
        if(cnt_rd == RD_NUM - 1'b1)
            cnt_rd  <=  11'd0;
        else    if(rd_busy_fall == 1'b1)
            cnt_rd  <=  cnt_rd + 1'b1;
        else
            cnt_rd  <=  cnt_rd;

//rd_en:数据读使能信号
always@(posedge sys_clk or negedge sys_rst_n)
    if(sys_rst_n == 1'b0)
        rd_en   <=  1'b0;
    else    if(state == IDLE)
        rd_en   <=  1'b1;
    else    if(state == READ)
        if(rd_busy_fall == 1'b1)
            rd_en   <=  1'b1;
        else
            rd_en   <=  1'b0;
    else
        rd_en   <=  1'b0;

//rd_addr:读数据扇区地址
always@(posedge sys_clk or negedge sys_rst_n)
    if(sys_rst_n == 1'b0)
        rd_addr <=  32'd0;
    else
        case(state)
            IDLE:
                if(pic_c == 1'b1)
                    rd_addr <=  IMG_SEC_ADDR1;
                else
                    rd_addr <=  IMG_SEC_ADDR0;
            READ:
                if(rd_busy_fall == 1'b1)
                    rd_addr <=  rd_addr + 1'd1;
                else
                    rd_addr <=  rd_addr;
            default:rd_addr <=  rd_addr;
        endcase

//cnt_wait:图片切换时间间隔计数
always@(posedge sys_clk or negedge sys_rst_n)
    if(sys_rst_n == 1'b0)
        cnt_wait    <=  26'd0;
    else    if(state == WAIT)
        if(cnt_wait == (WAIT_MAX - 1'b1))
            cnt_wait    <=  26'd0;
        else
            cnt_wait    <=  cnt_wait + 1'b1;
    else
        cnt_wait    <=  26'd0;

endmodule
