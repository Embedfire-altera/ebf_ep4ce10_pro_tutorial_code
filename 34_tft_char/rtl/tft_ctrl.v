`timescale  1ns/1ns
////////////////////////////////////////////////////////////////////////
// Author        : EmbedFire
// Create Date   : 2019/03/20
// Module Name   : tft_ctrl
// Project Name  : tft_char
// Target Devices: Altera EP4CE10F17C8N
// Tool Versions : Quartus 13.0
// Description   : TFT_LCD控制模块
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
    input   wire            tft_clk_9m  ,   //输入时钟,频率9MHz
    input   wire            sys_rst_n   ,   //系统复位,低电平有效
    input   wire    [15:0]  pix_data    ,   //待显示数据

    output  wire    [9:0]   pix_x       ,   //输出TFT有效显示区域像素点X轴坐标
    output  wire    [9:0]   pix_y       ,   //输出TFT有效显示区域像素点Y轴坐标
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
parameter H_SYNC    =   10'd41  ,   //行同步
          H_BACK    =   10'd2   ,   //行时序后沿
          H_VALID   =   10'd480 ,   //行有效数据
          H_FRONT   =   10'd2   ,   //行时序前沿
          H_TOTAL   =   10'd525 ;   //行扫描周期
parameter V_SYNC    =   10'd10  ,   //场同步
          V_BACK    =   10'd2   ,   //场时序后沿
          V_VALID   =   10'd272 ,   //场有效数据
          V_FRONT   =   10'd2   ,   //场时序前沿
          V_TOTAL   =   10'd286 ;   //场扫描周期

//wire  define
wire            rgb_valid       ;   //VGA有效显示区域
wire            pix_data_req    ;   //像素点色彩信息请求信号

//reg   define
reg     [9:0]   cnt_h   ;   //行扫描计数器
reg     [9:0]   cnt_v   ;   //场扫描计数器

//********************************************************************//
//***************************** Main Code ****************************//
//********************************************************************//

//tft_clk,tft_de,tft_bl：TFT像素时钟、数据使能、背光信号
assign  tft_clk = tft_clk_9m    ;
assign  tft_de  = rgb_valid     ;
assign  tft_bl  = sys_rst_n     ;

//cnt_h:行同步信号计数器
always@(posedge tft_clk_9m or  negedge sys_rst_n)
    if(sys_rst_n == 1'b0)
        cnt_h   <=  10'd0   ;
    else    if(cnt_h == H_TOTAL - 1'd1)
        cnt_h   <=  10'd0   ;
    else
        cnt_h   <=  cnt_h + 1'd1   ;

//hsync:行同步信号
assign  hsync = (cnt_h  <=  H_SYNC - 1'd1) ? 1'b1 : 1'b0  ;

//cnt_v:场同步信号计数器
always@(posedge tft_clk_9m or  negedge sys_rst_n)
    if(sys_rst_n == 1'b0)
        cnt_v   <=  10'd0 ;
    else    if((cnt_v == V_TOTAL - 1'd1) &&  (cnt_h == H_TOTAL-1'd1))
        cnt_v   <=  10'd0 ;
    else    if(cnt_h == H_TOTAL - 1'd1)
        cnt_v   <=  cnt_v + 1'd1 ;
    else
        cnt_v   <=  cnt_v ;

//vsync:场同步信号
assign  vsync = (cnt_v  <=  V_SYNC - 1'd1) ? 1'b1 : 1'b0  ;

//rgb_valid:VGA有效显示区域
assign  rgb_valid = (((cnt_h >= H_SYNC + H_BACK)
                    && (cnt_h < H_SYNC + H_BACK + H_VALID))
                    &&((cnt_v >= V_SYNC + V_BACK)
                    && (cnt_v < V_SYNC + V_BACK + V_VALID)))
                    ? 1'b1 : 1'b0;

//pix_data_req:像素点色彩信息请求信号,超前rgb_valid信号一个时钟周期
assign  pix_data_req = (((cnt_h >= H_SYNC + H_BACK - 1'b1)
                    && (cnt_h < H_SYNC + H_BACK + H_VALID - 1'b1))
                    &&((cnt_v >= V_SYNC + V_BACK)
                    && (cnt_v < V_SYNC + V_BACK + V_VALID)))
                    ? 1'b1 : 1'b0;

//pix_x,pix_y:VGA有效显示区域像素点坐标
assign  pix_x = (pix_data_req == 1'b1)
                ? (cnt_h - (H_SYNC + H_BACK - 1'b1)) : 10'h3ff;
assign  pix_y = (pix_data_req == 1'b1)
                ? (cnt_v - (V_SYNC + V_BACK )) : 10'h3ff;

//rgb_tft:输出像素点色彩信息
assign  rgb_tft = (rgb_valid == 1'b1) ? pix_data : 16'b0 ;

endmodule
