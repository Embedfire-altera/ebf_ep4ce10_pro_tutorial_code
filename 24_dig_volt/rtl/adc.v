`timescale  1ns/1ns
////////////////////////////////////////////////////////////////////////
// Author        : EmbedFire
// Create Date   : 2019/08/10
// Module Name   : adc
// Project Name  : dig_volt
// Target Devices: Altera EP4CE10F17C8N
// Tool Versions : Quartus 13.0
// Description   : 电压计算模块
//
// Revision      : V1.0
// Additional Comments:
// 
// 实验平台: 野火_征途Pro_FPGA开发板
// 公司    : http://www.embedfire.com
// 论坛    : http://www.firebbs.cn
// 淘宝    : https://fire-stm32.taobao.com
////////////////////////////////////////////////////////////////////////

module  adc
(
    input   wire            sys_clk         ,   //时钟
    input   wire            sys_rst_n       ,   //复位信号，低电平有效
    input   wire    [7:0]   ad_data         ,   //AD输入数据

    output  wire            ad_clk          ,   //AD驱动时钟,最大支持20Mhz时钟
    output  wire            sign            ,   //正负符号位
    output  wire    [15:0]  volt                //数据转换后的电压值
);
//********************************************************************//
//******************Parameter And Internal Signal ********************//
//********************************************************************//
//parameter define
parameter   CNT_DATA_MAX = 11'd1024;    //数据累加次数

//wire  define
wire    [27:0]  data_p      ;   //根据中值计算出的正向电压AD分辨率
wire    [27:0]  data_n      ;   //根据中值计算出的负向电压AD分辨率

//reg define
reg             median_en   ;   //中值使能
reg     [10:0]  cnt_median  ;   //中值数据累加计数器
reg     [18:0]  data_sum_m  ;   //1024次中值数据累加总和
reg     [7:0]   data_median ;   //中值数据
reg     [1:0]   cnt_sys_clk ;   //时钟分频计数器
reg             clk_sample  ;   //采样数据时钟
reg     [27:0]  volt_reg    ;   //电压值寄存

//********************************************************************//
//***************************** Main Code ****************************//
//********************************************************************//
//数据ad_data是在ad_sys_clk的上升沿更新
//所以在ad_sys_clk的下降沿采集数据是数据稳定的时刻
//FPGA内部一般使用上升沿锁存数据,所以时钟取反
//这样ad_sys_clk的下降沿相当于sample_sys_clk的上升沿
assign  ad_clk = ~clk_sample;

//sign:正负符号位
assign  sign = (ad_data < data_median) ? 1'b1 : 1'b0;

//时钟分频(4分频,时钟频率为12.5Mhz),产生采样AD数据时钟
always@(posedge sys_clk or negedge sys_rst_n)
    if(sys_rst_n == 1'b0)
        begin
            cnt_sys_clk <=  2'd0;
            clk_sample  <=  1'b0;
        end
        else
        begin
            cnt_sys_clk <=  cnt_sys_clk + 2'd1;
        if(cnt_sys_clk == 2'd1)
            begin
            cnt_sys_clk <=  2'd0;
            clk_sample  <=  ~clk_sample;
            end
        end

//中值使能信号
always@(posedge clk_sample or negedge sys_rst_n)
    if(sys_rst_n == 1'b0)
        median_en   <=  1'b0;
    else    if(cnt_median == CNT_DATA_MAX)
        median_en   <=  1'b1;
    else
        median_en   <=  median_en;

//cnt_median:中值数据累加计数器
always@(posedge clk_sample or negedge sys_rst_n)
    if(sys_rst_n == 1'b0)
        cnt_median    <=  11'd0;
    else    if(median_en == 1'b0)
        cnt_median    <=  cnt_median + 1'b1;

//data_sum_m:1024次中值数据累加总和
always@(posedge clk_sample or negedge sys_rst_n)
    if(sys_rst_n == 1'b0)
        data_sum_m  <=  19'd0;
    else    if(cnt_median == CNT_DATA_MAX)
        data_sum_m    <=  19'd0;
    else
        data_sum_m    <=  data_sum_m + ad_data;

//data_median:中值数据
always@(posedge clk_sample or negedge sys_rst_n)
    if(sys_rst_n == 1'b0)
        data_median    <=  8'd0;
    else    if(cnt_median == CNT_DATA_MAX)
        data_median    <=  data_sum_m / CNT_DATA_MAX;
    else
        data_median    <=  data_median;

//data_p:根据中值计算出的正向电压AD分辨率(放大2^13*1000倍)
//data_n:根据中值计算出的负向电压AD分辨率(放大2^13*1000倍)
assign  data_p = (median_en == 1'b1) ? 8192_0000 / ((255 - data_median) * 2) : 0;
assign  data_n = (median_en == 1'b1) ? 8192_0000 / ((data_median + 1) * 2) : 0;

//volt_reg:处理后的稳定数据
always@(posedge clk_sample or negedge sys_rst_n)
    if(sys_rst_n == 1'b0)
        volt_reg    <= 'd0;
    else    if(median_en == 1'b1)
        if((ad_data > (data_median - 3))&&(ad_data < (data_median + 3)))
            volt_reg    <= 'd0;
        else    if(ad_data < data_median)
            volt_reg <= (data_n *(data_median - ad_data)) >> 13;
        else    if(ad_data > data_median)
            volt_reg <= (data_p *(ad_data - data_median)) >> 13;
    else
        volt_reg    <= 'd0;

//volt:数据转换后的电压值
assign  volt    =   volt_reg;

endmodule