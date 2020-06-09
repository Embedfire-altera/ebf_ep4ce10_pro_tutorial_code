`timescale  1ns/1ns
////////////////////////////////////////////////////////////////////////
// Author        : EmbedFire
// Create Date   : 2019/09/25
// Module Name   : tb_ov7725_data
// Project Name  : ov7725_hdmi_640x480
// Target Devices: Altera EP4CE10F17C8N
// Tool Versions : Quartus 13.0
// Description   : OV7725摄像头图像数据采集模块仿真文件
// 
// Revision      : V1.0
// Additional Comments:
// 
// 实验平台: 野火_征途Pro_FPGA开发板
// 公司    : http://www.embedfire.com
// 论坛    : http://www.firebbs.cn
// 淘宝    : https://fire-stm32.taobao.com
////////////////////////////////////////////////////////////////////////

module  tb_ov7725_data();

//********************************************************************//
//****************** Parameter and Internal Signal *******************//
//********************************************************************//
//parameter define
parameter   H_VALID   =   10'd640 ,   //行有效数据
            H_TOTAL   =   10'd784 ;   //行扫描周期
parameter   V_SYNC    =   10'd4   ,   //场同步
            V_BACK    =   10'd18  ,   //场时序后沿
            V_VALID   =   10'd480 ,   //场有效数据
            V_FRONT   =   10'd8   ,   //场时序前沿
            V_TOTAL   =   10'd510 ;   //场扫描周期

//wire  define
wire            ov7725_wr_en    ;   //有效图像使能信号
wire    [15:0]  ov7725_data_out ;   //有效图像数据
wire            ov7725_href     ;   //行同步信号
wire            ov7725_vsync    ;   //场同步信号

//reg   define
reg             sys_clk         ;   //模拟时钟信号
reg             sys_rst_n       ;   //模拟复位信号
reg     [7:0]   ov7725_data     ;   //模拟摄像头采集图像数据
reg     [11:0]  cnt_h           ;   //行同步计数器
reg     [9:0]   cnt_v           ;   //场同步计数器

//********************************************************************//
//***************************** Main Code ****************************//
//********************************************************************//
//时钟、复位信号
initial
  begin
    sys_clk     =   1'b1  ;
    sys_rst_n   <=  1'b0  ;
    #200
    sys_rst_n   <=  1'b1  ;
  end

always  #20 sys_clk = ~sys_clk;

//cnt_h:行同步信号计数器
always@(posedge sys_clk or  negedge sys_rst_n)
    if(sys_rst_n == 1'b0)
        cnt_h   <=  12'd0   ;
    else    if(cnt_h == ((H_TOTAL * 2) - 1'b1))
        cnt_h   <=  12'd0   ;
    else
        cnt_h   <=  cnt_h + 1'd1   ;

//ov7725_href:行同步信号
assign  ov7725_href = (((cnt_h >= 0)
                      && (cnt_h <= ((H_VALID * 2) - 1'b1)))
                      && ((cnt_v >= (V_SYNC + V_BACK))
                      && (cnt_v <= (V_SYNC + V_BACK + V_VALID - 1'b1))))
                      ? 1'b1 : 1'b0  ;

//cnt_v:场同步信号计数器
always@(posedge sys_clk or  negedge sys_rst_n)
    if(sys_rst_n == 1'b0)
        cnt_v   <=  10'd0 ;
    else    if((cnt_v == (V_TOTAL - 1'b1))
                && (cnt_h == ((H_TOTAL * 2) - 1'b1)))
        cnt_v   <=  10'd0 ;
    else    if(cnt_h == ((H_TOTAL * 2) - 1'b1))
        cnt_v   <=  cnt_v + 1'd1 ;
    else
        cnt_v   <=  cnt_v ;

//vsync:场同步信号
assign  ov7725_vsync = (cnt_v  <= (V_SYNC - 1'b1)) ? 1'b1 : 1'b0  ;

//ov7725_data:模拟摄像头采集图像数据
always@(posedge sys_clk or  negedge sys_rst_n)
    if(sys_rst_n == 1'b0)
        ov7725_data <=  8'd0;
    else    if(ov7725_href == 1'b1)
        ov7725_data <=  ov7725_data + 1'b1;
    else
        ov7725_data <=  8'd0;

//********************************************************************//
//*************************** Instantiation **************************//
//********************************************************************//
//------------- ov7725_data_inst -------------
ov7725_data ov7725_data_inst
(
    .sys_rst_n          (sys_rst_n      ),  //复位信号
    .ov7725_pclk        (sys_clk        ),  //摄像头像素时钟
    .ov7725_href        (ov7725_href    ),  //摄像头行同步信号
    .ov7725_vsync       (ov7725_vsync   ),  //摄像头场同步信号
    .ov7725_data        (ov7725_data    ),  //摄像头图像数据

    .ov7725_wr_en       (ov7725_wr_en   ),  //图像数据有效使能信号
    .ov7725_data_out    (ov7725_data_out)   //图像数据
);

endmodule

