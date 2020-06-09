`timescale  1ns/1ns
////////////////////////////////////////////////////////////////////////
// Author        : EmbedFire
// Create Date   : 2019/07/15
// Module Name   : led_ctrl
// Project Name  : top_infrared_rcv
// Target Devices: Altera EP4CE10F17C8N
// Tool Versions : Quartus 13.0
// Description   : led控制模块
// 
// Revision      : V1.0
// Additional Comments:
// 
// 实验平台: 野火_征途Pro_FPGA开发板
// 公司    : http://www.embedfire.com
// 论坛    : http://www.firebbs.cn
// 淘宝    : https://fire-stm32.taobao.com
////////////////////////////////////////////////////////////////////////

module  led_ctrl
(
    input   wire    sys_clk     ,   //系统时钟，频率50MHz
    input   wire    sys_rst_n   ,   //复位信号，低有效
    input   wire    repeat_en   ,   //重复码使能信号
    
    output  reg     led             //输出led灯信号
);

//********************************************************************//
//****************** Parameter and Internal Signal *******************//
//********************************************************************//
//parameter define
parameter   CNT_MAX =   2500_000;

//wire  define
wire    repeat_en_rise  ;   //重复码使能信号上升沿

//reg   define
reg         repeat_en_d1;   //重复码使能信号打一拍
reg         repeat_en_d2;   //重复码使能信号打两拍
reg [21:0]  cnt         ;   //计数器

//********************************************************************//
//******************************* Main Code **************************//
//********************************************************************//

//获得repeat_en上升沿信号
assign  repeat_en_rise  =   repeat_en_d1 &  ~repeat_en_d2;

//对reeat_en打两拍
always@(posedge sys_clk or  negedge sys_rst_n)
    if(sys_rst_n == 1'b0)
        begin
            repeat_en_d1    <=  1'b0;
            repeat_en_d2    <=  1'b0;
        end
    else
        begin
            repeat_en_d1    <=  repeat_en;
            repeat_en_d2    <=  repeat_en_d1;
        end

//当重复码使能信号上升沿来到，让计数器从2500_000~0计数
always@(posedge sys_clk or  negedge sys_rst_n)
    if(sys_rst_n == 1'b0)
            cnt <=  22'b0;
    else    if(repeat_en_rise == 1'b1)
            cnt <=  CNT_MAX;
    else    if(cnt >    1'b0)
            cnt <=  cnt - 1'b1;
    else
            cnt <=  1'b0;

//当计数器大于0时，点亮led灯，也就是当使能信号到来，led灯会亮0.05s
always@(posedge sys_clk or  negedge sys_rst_n)
    if(sys_rst_n == 1'b0)
        led <=  1'b1;
    else    if(cnt > 0)
        led <=  1'b0;
    else
        led <=  1'b1;

endmodule
