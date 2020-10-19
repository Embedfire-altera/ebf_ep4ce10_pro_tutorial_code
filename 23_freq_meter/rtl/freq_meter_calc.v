`timescale  1ns/1ns
////////////////////////////////////////////////////////////////////////
// Author        : EmbedFire
// Create Date   : 2019/07/10
// Module Name   : freq_meter_calc
// Project Name  : freq_meter
// Target Devices: Altera EP4CE10F17C8N
// Tool Versions : Quartus 13.0
// Description   : 频率计算模块
//
// Revision      : V1.0
// Additional Comments:
// 
// 实验平台: 野火_征途Pro_FPGA开发板
// 公司    : http://www.embedfire.com
// 论坛    : http://www.firebbs.cn
// 淘宝    : https://fire-stm32.taobao.com
////////////////////////////////////////////////////////////////////////

module  freq_meter_calc
(
    input   wire            sys_clk     ,   //系统时钟,频率50MHz
    input   wire            sys_rst_n   ,   //复位信号,低电平有效
    input   wire            clk_test    ,   //待检测时钟

    output  reg     [33:0]  freq            //待检测时钟频率

);
//********************************************************************//
//****************** Parameter And Internal Signal *******************//
//********************************************************************//
//parameter define
parameter   CNT_GATE_S_MAX  =   28'd74_999_999  ,   //软件闸门计数器计数最大值
            CNT_RISE_MAX    =   28'd12_500_000  ;   //软件闸门拉高计数值
parameter   CLK_STAND_FREQ  =   28'd100_000_000 ;   //标准时钟时钟频率
//wire  define
wire            clk_stand           ;   //标准时钟,频率100MHz
wire            gate_a_fall_s       ;   //实际闸门下降沿(标准时钟下)
wire            gate_a_fall_t       ;   //实际闸门下降沿(待检测时钟下)

//reg   define
reg     [27:0]  cnt_gate_s          ;   //软件闸门计数器
reg             gate_s              ;   //软件闸门
reg             gate_a              ;   //实际闸门
reg             gate_a_stand        ;   //实际闸门打一拍(标准时钟下)
reg             gate_a_test         ;   //实际闸门打一拍(待检测时钟下)
reg     [47:0]  cnt_clk_stand       ;   //标准时钟周期计数器
reg     [47:0]  cnt_clk_stand_reg   ;   //实际闸门下标志时钟周期数
reg     [47:0]  cnt_clk_test        ;   //待检测时钟周期计数器
reg     [47:0]  cnt_clk_test_reg    ;   //实际闸门下待检测时钟周期数
reg             calc_flag           ;   //待检测时钟时钟频率计算标志信号
reg     [63:0]  freq_reg            ;   //待检测时钟频率寄存
reg             calc_flag_reg       ;   //待检测时钟频率输出标志信号

//********************************************************************//
//***************************** Main Code ****************************//
//********************************************************************//
//cnt_gate_s:软件闸门计数器
always@(posedge sys_clk or negedge sys_rst_n)
    if(sys_rst_n == 1'b0)
        cnt_gate_s  <=  28'd0;
    else    if(cnt_gate_s == CNT_GATE_S_MAX)
        cnt_gate_s  <=  28'd0;
    else
        cnt_gate_s  <=  cnt_gate_s + 1'b1;

//gate_s:软件闸门
always@(posedge sys_clk or negedge sys_rst_n)
    if(sys_rst_n == 1'b0)
        gate_s  <=  1'b0;
    else    if((cnt_gate_s>= CNT_RISE_MAX)
                && (cnt_gate_s <= (CNT_GATE_S_MAX - CNT_RISE_MAX)))
        gate_s  <=  1'b1;
    else
        gate_s  <=  1'b0;

//gate_a:实际闸门
always@(posedge clk_test or negedge sys_rst_n)
    if(sys_rst_n == 1'b0)
        gate_a  <=  1'b0;
    else
        gate_a  <=  gate_s;

//cnt_clk_stand:标准时钟周期计数器,计数实际闸门下标准时钟周期数
always@(posedge clk_stand or negedge sys_rst_n)
    if(sys_rst_n == 1'b0)
        cnt_clk_stand   <=  48'd0;
    else    if(gate_a == 1'b0)
        cnt_clk_stand   <=  48'd0;
    else    if(gate_a == 1'b1)
        cnt_clk_stand   <=  cnt_clk_stand + 1'b1;

//cnt_clk_test:待检测时钟周期计数器,计数实际闸门下待检测时钟周期数
always@(posedge clk_test or negedge sys_rst_n)
    if(sys_rst_n == 1'b0)
        cnt_clk_test    <=  48'd0;
    else    if(gate_a == 1'b0)
        cnt_clk_test    <=  48'd0;
    else    if(gate_a == 1'b1)
        cnt_clk_test    <=  cnt_clk_test + 1'b1;

//gate_a_stand:实际闸门打一拍(标准时钟下)
always@(posedge clk_stand or negedge sys_rst_n)
    if(sys_rst_n == 1'b0)
        gate_a_stand    <=  1'b0;
    else
        gate_a_stand    <=  gate_a;

//gate_a_fall_s:实际闸门下降沿(标准时钟下)
assign  gate_a_fall_s = ((gate_a_stand == 1'b1) && (gate_a == 1'b0))
                        ? 1'b1 : 1'b0;

//cnt_clk_stand_reg:实际闸门下标志时钟周期数
always@(posedge clk_stand or negedge sys_rst_n)
    if(sys_rst_n == 1'b0)
        cnt_clk_stand_reg   <=  32'd0;
    else    if(gate_a_fall_s == 1'b1)
        cnt_clk_stand_reg   <=  cnt_clk_stand;

//gate_a_test:实际闸门打一拍(待检测时钟下)
always@(posedge clk_test or negedge sys_rst_n)
    if(sys_rst_n == 1'b0)
        gate_a_test <=  1'b0;
    else
        gate_a_test <=  gate_a;

//gate_a_fall_t:实际闸门下降沿(待检测时钟下)
assign  gate_a_fall_t = ((gate_a_test == 1'b1) && (gate_a == 1'b0))
                        ? 1'b1 : 1'b0;

//cnt_clk_test_reg:实际闸门下待检测时钟周期数
always@(posedge clk_test or negedge sys_rst_n)
    if(sys_rst_n == 1'b0)
        cnt_clk_test_reg   <=  32'd0;
    else    if(gate_a_fall_t == 1'b1)
        cnt_clk_test_reg   <=  cnt_clk_test;

//calc_flag:待检测时钟时钟频率计算标志信号
always@(posedge sys_clk or negedge sys_rst_n)
    if(sys_rst_n == 1'b0)
        calc_flag   <=  1'b0;
    else    if(cnt_gate_s == (CNT_GATE_S_MAX - 1'b1))
        calc_flag   <=  1'b1;
    else
        calc_flag   <=  1'b0;

//freq_reg:待检测时钟信号时钟频率寄存
always@(posedge sys_clk or negedge sys_rst_n)
    if(sys_rst_n == 1'b0)
        freq_reg    <=  64'd0;
    else    if(calc_flag == 1'b1)
        freq_reg    <=  (CLK_STAND_FREQ * cnt_clk_test_reg / cnt_clk_stand_reg);

//calc_flag_reg:待检测时钟频率输出标志信号
always@(posedge sys_clk or negedge sys_rst_n)
    if(sys_rst_n == 1'b0)
        calc_flag_reg   <=  1'b0;
    else
        calc_flag_reg   <=  calc_flag;

//freq:待检测时钟信号时钟频率
always@(posedge sys_clk or negedge sys_rst_n)
    if(sys_rst_n == 1'b0)
        freq    <=  34'd0;
    else    if(calc_flag_reg == 1'b1)
        freq    <=  freq_reg[33:0];

//********************************************************************//
//*************************** Instantiation **************************//
//********************************************************************//
//---------- clk_gen_inst ----------
clk_gen clk_gen_inst
(
    .areset (~sys_rst_n ),
    .inclk0 (sys_clk    ),

    .c0     (clk_stand  )
);

endmodule
