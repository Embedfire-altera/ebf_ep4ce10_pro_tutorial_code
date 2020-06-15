`timescale  1ns/1ns
//////////////////////////////////////////////////////////////////////////////////
// Author: fire
// Create Date: 2020/05/23
// Module Name: beep
// Project Name:
// Target Devices: Altera EP4CE10F17C8N
// Tool Versions: Quartus 13.0
// Description:无源蜂鸣器驱动
//
// Revision:V1.1
// Additional Comments:
//
// 实验平台:野火FPGA开发板
// 公司    :http://www.embedfire.com
// 论坛    :http://www.firebbs.cn
// 淘宝    :https://fire-stm32.taobao.com
//////////////////////////////////////////////////////////////////////////////////

module  beep
#(
    parameter   TIME_500MS =   25'd24999999,   //0.5s计数值
    parameter   DO  =   18'd190839 ,   //"哆"音调分频计数值（频率262）
    parameter   RE  =   18'd170067 ,   //"来"音调分频计数值（频率294）
    parameter   MI  =   18'd151514 ,   //"咪"音调分频计数值（频率330）
    parameter   FA  =   18'd143265 ,   //"发"音调分频计数值（频率349）
    parameter   SO  =   18'd127550 ,   //"梭"音调分频计数值（频率392）
    parameter   LA  =   18'd113635 ,   //"拉"音调分频计数值（频率440）
    parameter   XI  =   18'd101214     //"西"音调分频计数值（频率494）
)
(
    input   wire        sys_clk     ,   //系统时钟,频率50MHz
    input   wire        sys_rst_n   ,   //系统复位，低有效

    output  reg         beep            //输出蜂鸣器控制信号
);

//********************************************************************//
//****************** Parameter and Internal Signal *******************//
//********************************************************************//

//reg   define
reg     [24:0]  cnt         ;   //0.5s计数器
reg     [17:0]  freq_cnt    ;   //音调计数器
reg     [2:0]   cnt_500ms   ;   //0.5s个数计数
reg     [17:0]  freq_data   ;   //音调分频计数值

//wire  define
wire    [16:0]  duty_data   ;   //占空比计数值

//********************************************************************//
//***************************** Main Code ****************************//
//********************************************************************//

//设置50％占空比：音阶分频计数值的一半即为占空比的高电平数
assign  duty_data   =   freq_data   >>    1'b1;

//cnt:0.5s循环计数器
always@(posedge sys_clk or  negedge sys_rst_n)
    if(sys_rst_n == 1'b0)
        cnt <=  25'd0;
    else    if(cnt == TIME_500MS )
        cnt <=   25'd0;
    else
        cnt <=  cnt +   1'b1;

//cnt_500ms：对500ms个数进行计数，每个音阶鸣叫时间0.5s，7个音节一循环
always@(posedge sys_clk or  negedge sys_rst_n)
    if(sys_rst_n == 1'b0)
        cnt_500ms   <=  3'd0;
    else    if(cnt == TIME_500MS && cnt_500ms ==  6)
        cnt_500ms   <=  3'd0;
    else    if(cnt == TIME_500MS)
        cnt_500ms   <=  cnt_500ms + 1'b1;

//不同时间鸣叫不同的音阶
always@(posedge sys_clk or  negedge sys_rst_n)
    if(sys_rst_n == 1'b0)
        freq_data   <=  DO;
    else    case(cnt_500ms)
        0:  freq_data   <=   DO;
        1:  freq_data   <=   RE;
        2:  freq_data   <=   MI;
        3:  freq_data   <=   FA;
        4:  freq_data   <=   SO;
        5:  freq_data   <=   LA;
        6:  freq_data   <=   XI;
        default:  freq_data   <=   DO;
    endcase

//freq_cnt：当计数到音阶计数值或跳转到下一音阶时，开始重新计数
always@(posedge sys_clk or  negedge sys_rst_n)
    if(sys_rst_n == 1'b0)
        freq_cnt    <=  18'd0;
    else    if(freq_cnt == freq_data || cnt == TIME_500MS)
        freq_cnt    <=  18'd0;
    else
        freq_cnt    <=  freq_cnt +  1'b1;

//beep：输出蜂鸣器波形
always@(posedge sys_clk or  negedge sys_rst_n)
    if(sys_rst_n == 1'b0)
        beep    <=  1'b0;
    else    if(freq_cnt >= duty_data)
        beep    <=  1'b1;
    else
        beep    <=  1'b0;

endmodule
