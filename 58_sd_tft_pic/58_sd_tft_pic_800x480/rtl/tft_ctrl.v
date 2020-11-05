`timescale  1ns/1ns
////////////////////////////////////////////////////////////////////////
// Author        : EmbedFire
// Create Date   : 2020/10/25
// Module Name   : tft_ctrl
// Project Name  : tft_800x480
// Target Devices: Altera EP4CE10F17C8N
// Tool Versions : Quartus 13.0
// Description   : TFT驱动
// 
// Revision      : V1.0
// Additional Comments:
// 
// 实验平台: 野火_征途Pro_FPGA开发板
// 公司    : http://www.embedfire.com
// 论坛    : http://www.firebbs.cn
// 淘宝    : https://fire-stm32.taobao.com
////////////////////////////////////////////////////////////////////////

module  tft_ctrl
(
    input   wire            clk_33m     ,   //输入时钟,频率33MHz
    input   wire            sys_rst_n   ,   //系统复位,低电平有效
    input   wire    [15:0]  data_in     ,   //待显示数据

    output  wire            data_req    ,   //数据请求信号
    output  wire    [15:0]  rgb_tft     ,   //TFT显示数据
    output  wire            hsync       ,   //TFT行同步信号
    output  wire            vsync       ,   //TFT场同步信号
    output  wire            tft_clk     ,   //TFT像素时钟
    output  wire            tft_de      ,   //TFT数据使能
    output  wire            tft_bl          //TFT背光信号
);

//********************************************************************//
//****************** Parameter and Internal Signal *******************//
//********************************************************************//

//parameter define
parameter   H_SYNC      =   11'd34  ,   //行同步
            H_BACK      =   11'd46   ,   //行时序后沿
            H_LEFT      =   11'd0   ,   //行时序左边框
            H_VALID     =   11'd800 ,   //行有效数据
            H_RIGHT     =   11'd0   ,   //行时序右边框
            H_FRONT     =   11'd210   ,   //行时序前沿
            H_TOTAL     =   11'd1090 ;   //行扫描周期
            
parameter   V_SYNC      =   11'd10  ,   //场同步
            V_BACK      =   11'd23   ,   //场时序后沿
            V_TOP       =   11'd0   ,   //场时序左边框
            V_VALID     =   11'd480 ,   //场有效数据
            V_BOTTOM    =   11'd0   ,   //场时序右边框
            V_FRONT     =   11'd22   ,   //场时序前沿
            V_TOTAL     =   11'd535 ;   //场扫描周期
parameter   H_PIXEL     =   11'd800 ,   //水平方向有效图像像素个数
            V_PIXEL     =   11'd480 ;   //垂直方向有效图像像素个数
parameter   H_BLACK     =   ((H_VALID - H_PIXEL) / 2),  //水平方向黑色边框宽度
            V_BLACK     =   ((V_VALID - V_PIXEL) / 2);  //垂直方向黑色边框宽度

//wire  define
wire            data_valid  ;   //有效显示区域标志
wire    [15:0]  data_out    ;   //输出有效图像数据

//reg   define
reg     [10:0]   cnt_h       ;   //行扫描计数器
reg     [10:0]   cnt_v       ;   //场扫描计数器
reg             data_req_dly;   //数据请求信号打一拍

//********************************************************************//
//***************************** Main Code ****************************//
//********************************************************************//

//tft_clk,tft_de,tft_bl:TFT像素时钟、数据使能、背光信号
assign  tft_clk = clk_33m    ;
assign  tft_de  = data_valid;
assign  tft_bl  = sys_rst_n ;

//cnt_h:行扫描计数器
always@(posedge clk_33m or negedge sys_rst_n)
    if(sys_rst_n == 1'b0)
        cnt_h   <=  11'd0;
    else    if(cnt_h == H_TOTAL - 1'b1)
        cnt_h   <=  11'd0;
    else
        cnt_h   <=  cnt_h + 10'd1;

//cnt_v:场扫描计数器
always@(posedge clk_33m or negedge sys_rst_n)
    if(sys_rst_n == 1'b0)
        cnt_v   <=  11'd0;
    else    if(cnt_h == H_TOTAL - 1'b1) 
    begin
        if(cnt_v == V_TOTAL - 1'b1)
            cnt_v   <=  11'd0;
        else
            cnt_v   <=  cnt_v + 10'd1;
    end
    else 
        cnt_v   <=  cnt_v;

//data_valid:有效显示区域标志
assign  data_valid = ((cnt_h >= (H_SYNC + H_BACK + H_LEFT - 1'b1))
            && (cnt_h < (H_SYNC + H_BACK + H_LEFT + H_VALID )))
            &&((cnt_v >= (V_SYNC + V_BACK + V_TOP - 1'b1))
            && (cnt_v < (V_SYNC + V_BACK + V_TOP + V_VALID)));

//data_req:图像数据请求
assign  data_req = ((cnt_h >= (H_SYNC + H_BACK + H_LEFT + H_BLACK - 2))
    && (cnt_h < ((H_SYNC + H_BACK + H_LEFT + H_BLACK + H_PIXEL - 2))))
    &&((cnt_v >= ((V_SYNC + V_BACK + V_TOP + V_BLACK)))
    && (cnt_v < ((V_SYNC + V_BACK + V_TOP + V_BLACK + V_PIXEL))));

//data_req_dly:数据请求信号打一拍,作为输出图像数据约束信号
always@(posedge clk_33m or negedge sys_rst_n)
    if(sys_rst_n == 1'b0)
        data_req_dly    <=  1'b0;
    else
        data_req_dly    <=  data_req;

//data_out:输出有效图像数据
assign  data_out = (data_req_dly == 1'b1) ? data_in : 16'h0000;

//hsync,vsync,rgb_tft:行、场同步信号、图像数据
assign  rgb_tft = (data_valid == 1'b0) ? 16'hFFFF : data_out;
assign  hsync = (cnt_h  <=  H_SYNC - 1'd1) ? 1'b1 : 1'b0  ;
assign  vsync = (cnt_v  <=  V_SYNC - 1'd1) ? 1'b1 : 1'b0  ;
endmodule
