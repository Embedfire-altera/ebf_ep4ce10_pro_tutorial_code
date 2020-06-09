`timescale  1ns/1ns
////////////////////////////////////////////////////////////////////////
// Author        : EmbedFire
// Create Date   : 2019/07/08
// Module Name   : seg7_static
// Project Name  : seg7_static
// Target Devices: Altera EP4CE10F17C8N
// Tool Versions : Quartus 13.0
// Description   : 静态数码管显示
//
// Revision      : V1.0
// Additional Comments:
// 
// 实验平台: 野火_征途Pro_FPGA开发板
// 公司    : http://www.embedfire.com
// 论坛    : http://www.firebbs.cn
// 淘宝    : https://fire-stm32.taobao.com
////////////////////////////////////////////////////////////////////////

module  seg_static
(
    input   wire            sys_clk     ,   //系统时钟，频率50MHz
    input   wire            sys_rst_n   ,   //复位信号，低电平有效

    output  reg     [5:0]   sel         ,   //数码管位选信号
    output  reg     [7:0]   seg             //数码管段选信号
);

//********************************************************************//
//****************** Parameter and Internal Signal *******************//
//********************************************************************//
//parameter define
parameter   CNT_WAIT_MAX  =  25'd24_999_999;   //计数器最大值（0.5s）
//十六进制数显示编码
parameter   SEG_0 = 8'b1100_0000,   SEG_1 = 8'b1111_1001,
            SEG_2 = 8'b1010_0100,   SEG_3 = 8'b1011_0000,
            SEG_4 = 8'b1001_1001,   SEG_5 = 8'b1001_0010,
            SEG_6 = 8'b1000_0010,   SEG_7 = 8'b1111_1000,
            SEG_8 = 8'b1000_0000,   SEG_9 = 8'b1001_0000,
            SEG_A = 8'b1000_1000,   SEG_B = 8'b1000_0011,
            SEG_C = 8'b1100_0110,   SEG_D = 8'b1010_0001,
            SEG_E = 8'b1000_0110,   SEG_F = 8'b1000_1110;
parameter   IDLE  = 8'b1111_1111;   //不显示状态

//reg   define
reg             add_flag    ;   //数码管数值+1标志信号
reg     [24:0]  cnt_wait    ;   //时钟分频计数器
reg     [3:0]   num         ;   //数码管显示的十六进制数

//********************************************************************//
//*************************** Main Code ******************************//
//********************************************************************//
//cnt_wait：0.5秒计数
always@(posedge sys_clk or  negedge sys_rst_n)
    if(sys_rst_n == 1'b0)
        cnt_wait    <=  25'd0;
    else    if(cnt_wait == CNT_WAIT_MAX)
        cnt_wait    <=  25'd0;
    else
        cnt_wait    <=  cnt_wait + 1'b1;

//add_flag:0.5s拉高一个标志信号
always@(posedge sys_clk or  negedge sys_rst_n)
    if(sys_rst_n == 1'b0)
        add_flag    <=  1'b0;
    else    if(cnt_wait == CNT_WAIT_MAX)
        add_flag    <=  1'b1;
    else
        add_flag    <=  1'b0;

//num：从 4'h0 加到 4'hf 循环
always@(posedge sys_clk or  negedge sys_rst_n)
    if(sys_rst_n == 1'b0)
        num <=  4'd0;
    else    if(add_flag == 1'b1)
        num <=  num + 1'b1;
    else
        num <=  num;

//sel：选中六个数码管
always@(posedge sys_clk or  negedge sys_rst_n)
    if(sys_rst_n == 1'b0)
        sel <=  6'b000000;
    else
        sel <=  6'b111111;

//给要显示的值编码
always@(posedge sys_clk or  negedge sys_rst_n)
    if(sys_rst_n == 1'b0)
        seg    <=  IDLE;
    else    case(num)
        4'd0:   seg    <=  SEG_0;
        4'd1:   seg    <=  SEG_1;
        4'd2:   seg    <=  SEG_2;
        4'd3:   seg    <=  SEG_3;
        4'd4:   seg    <=  SEG_4;
        4'd5:   seg    <=  SEG_5;
        4'd6:   seg    <=  SEG_6;
        4'd7:   seg    <=  SEG_7;
        4'd8:   seg    <=  SEG_8;
        4'd9:   seg    <=  SEG_9;
        4'd10:  seg    <=  SEG_A;
        4'd11:  seg    <=  SEG_B;
        4'd12:  seg    <=  SEG_C;
        4'd13:  seg    <=  SEG_D;
        4'd14:  seg    <=  SEG_E;
        4'd15:  seg    <=  SEG_F;
        default:seg    <=  IDLE ;  //闲置状态，不显示
    endcase

endmodule
