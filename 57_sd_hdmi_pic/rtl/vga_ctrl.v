`timescale  1ns/1ns
//////////////////////////////////////////////////////////////////////////////////
// Author: fire
// Create Date: 2018/03/25
// Module Name: vga_ctrl
// Project Name: sd_vga_pic
// Target Devices: Altera EP4CE10F17C8N
// Tool Versions: Quartus 13.0
// Description: VGA驱动模块
//
// Revision:V1.1
// Additional Comments:
//
// 实验平台:野火FPGA开发板
// 公司    :http://www.embedfire.com
// 论坛    :http://www.firebbs.cn
// 淘宝    :https://fire-stm32.taobao.com
//////////////////////////////////////////////////////////////////////////////////
`timescale  1ns/1ns
////////////////////////////////////////////////////////////////////////
// Author        : EmbedFire
// Create Date   : 2019/03/25
// Module Name   : vga_ctrl
// Project Name  : sd_hdmi_pic
// Target Devices: Altera EP4CE10F17C8N
// Tool Versions : Quartus 13.0
// Description   : VGA驱动模块
// 
// Revision      : V1.0
// Additional Comments:
// 
// 实验平台: 野火_征途Pro_FPGA开发板
// 公司    : http://www.embedfire.com
// 论坛    : http://www.firebbs.cn
// 淘宝    : https://fire-stm32.taobao.com
////////////////////////////////////////////////////////////////////////

module  vga_ctrl
(
    input   wire            vga_clk     ,   //输入工作时钟,频率25MHz
    input   wire            sys_rst_n   ,   //输入复位信号,低电平有效
    input   wire    [15:0]  data_in     ,   //待显示数据输入

    output  wire            rgb_valid   ,   //VGA有效显示区域
    output  wire            data_req    ,   //数据请求信号
    output  wire            hsync       ,   //输出行同步信号
    output  wire            vsync       ,   //输出场同步信号
    output  wire    [15:0]  rgb             //输出像素信息
);

//********************************************************************//
//****************** Parameter and Internal Signal *******************//
//********************************************************************//
//parameter define
parameter   H_SYNC    = 11'd96  , //行同步
            H_BACK    = 11'd40  , //行时序后沿
            H_LEFT    = 11'd8   , //行时序左边框
            H_VALID   = 11'd640 , //行有效数据
            H_RIGHT   = 11'd8   , //行时序右边框
            H_FRONT   = 11'd8   , //行时序前沿
            H_TOTAL   = 11'd800 ; //行扫描周期
parameter   V_SYNC    = 11'd2   , //场同步
            V_BACK    = 11'd25  , //场时序后沿
            V_TOP     = 11'd8   , //场时序左边框
            V_VALID   = 11'd480 , //场有效数据
            V_BOTTOM  = 11'd8   , //场时序右边框
            V_FRONT   = 11'd2   , //场时序前沿
            V_TOTAL   = 11'd525 ; //场扫描周期

//reg   define
reg   [10:0]     cnt_h       ; //行同步信号计数器
reg   [10:0]     cnt_v       ; //场同步信号计数器

//********************************************************************//
//***************************** Main Code ****************************//
//********************************************************************//

//cnt_h:行同步信号计数器
always@(posedge vga_clk or  negedge sys_rst_n)
    if(sys_rst_n == 1'b0)
        cnt_h <=  11'd0 ;
    else    if(cnt_h == (H_TOTAL-1'b1))
        cnt_h <=  11'd0 ;
    else
        cnt_h <=  cnt_h + 1'b1 ;

//hsync:行同步信号
assign  hsync = (cnt_h <= H_SYNC-1) ? 1'b1 : 1'b0  ;

//cnt_v:场同步信号计数器
always@(posedge vga_clk or  negedge sys_rst_n)
    if(sys_rst_n == 1'b0)
        cnt_v <=  11'd0 ;
    else    if((cnt_v == V_TOTAL- 1'b1)&&(cnt_h == H_TOTAL - 1'b1))
        cnt_v <=  11'd0 ;
    else    if(cnt_h == H_TOTAL - 1'b1)
        cnt_v <=  cnt_v + 1'b1 ;
    else
        cnt_v <=  cnt_v ;

//vsync:场同步信号
assign  vsync = (cnt_v <= V_SYNC - 1'b1) ? 1'b1 : 1'b0  ;

//data_valid:有效显示区域标志
assign  rgb_valid = ((cnt_h >= (H_SYNC + H_BACK + H_LEFT)) && (cnt_h < (H_SYNC + H_BACK + H_LEFT + H_VALID)))
                    &&((cnt_v >= (V_SYNC + V_BACK + V_TOP)) && (cnt_v < (V_SYNC + V_BACK + V_TOP + V_VALID)));
//data_req:数据请求信号
assign  data_req = ((cnt_h >= (H_SYNC + H_BACK + H_LEFT) - 1'b1) && (cnt_h < ((H_SYNC + H_BACK + H_LEFT + H_VALID) - 1'b1)))
                    &&((cnt_v >= ((V_SYNC + V_BACK + V_TOP))) && (cnt_v < ((V_SYNC + V_BACK + V_TOP + V_VALID))));

//rgb:输出像素信息
assign  rgb = (rgb_valid == 1'b1) ? data_in : 16'b0 ;

endmodule
