`timescale  1ns/1ns
////////////////////////////////////////////////////////////////////////
// Author        : EmbedFire
// Create Date   : 2019/07/12
// Module Name   : infrared_rcv
// Project Name  : top_infrared_rcv
// Target Devices: Altera EP4CE10F17C8N
// Tool Versions : Quartus 13.0
// Description   : 红外线解调模块
// 
// Revision      : V1.0
// Additional Comments:
// 
// 实验平台: 野火_征途系列FPGA开发板
// 公司    : http://www.embedfire.com
// 论坛    : http://www.firebbs.cn
// 淘宝    : https://fire-stm32.taobao.com
////////////////////////////////////////////////////////////////////////

module  infrared_rcv
(
    input   wire        sys_clk     ,   //系统时钟，频率50MHz
    input   wire        sys_rst_n   ,   //复位信号，低有效
    input   wire        infrared_in ,   //红外接受信号

    output  reg         repeat_en   ,   //重复码使能信号
    output  reg [19:0]  data            //接收的控制码
);

//********************************************************************//
//****************** Parameter and Internal Signal *******************//
//********************************************************************//
//parameter define
parameter   CNT_0_56MS_L  =   20000 ,    //0.56ms计数为0-27999
            CNT_0_56MS_H  =   35000 ,
            CNT_1_69MS_L  =   80000 ,    //1.69ms计数为0-84499
            CNT_1_69MS_H  =   90000 ,
            CNT_2_25MS_L  =   100000,    //2.25ms计数为0-112499
            CNT_2_25MS_H  =   125000,
            CNT_4_5MS_L   =   175000,   //4.5ms计数为0-224999
            CNT_4_5MS_H   =   275000,
            CNT_9MS_L     =   400000,   //9ms计数为0-449999
            CNT_9MS_H     =   490000;
//state
parameter   IDLE        =   5'b0_0001,  //空闲状态
            S_T9        =   5'b0_0010,  //监测同步码低电平
            S_JUDGE     =   5'b0_0100,  //判断重复码和同步码高电平
            S_IFR_DATA  =   5'b0_1000,  //接收数据
            S_REPEAT    =   5'b1_0000;  //重复码

//wire  define
wire            ifr_in_rise ;   //检测红外信号的上升沿
wire            ifr_in_fall ;   //检测红外信号的下降沿

//reg   define
reg         infrared_in_d1  ;   //对infrared_in信号打一拍
reg         infrared_in_d2  ;   //对infrared_in信号打两拍
reg [18:0]  cnt             ;   //计数器
reg         flag_0_56ms     ;   //0.56ms计数完成标志信号
reg         flag_1_69ms     ;   //1.69ms计数完成标志信号
reg         flag_2_25ms     ;   //2.25ms计数完成标志信号
reg         flag_4_5ms      ;   //4.5ms计数完成标志信号
reg         flag_9ms        ;   //0.56ms计数完成标志信号
reg [4:0]   state           ;   //状态机状态
reg [5:0]   data_cnt        ;   //数据计数器
reg [31:0]  data_tmp        ;   //数据寄存器
reg         data_end        ;   //数据接收完成信号

//********************************************************************//
//******************************* Main Code **************************//
//********************************************************************//

//检测红外信号的上升沿和下降沿
assign  ifr_in_rise =   (~infrared_in_d2) & (infrared_in_d1)    ;
assign  ifr_in_fall =   (infrared_in_d2)  & (~infrared_in_d1)   ;

//对infrared_in信号打拍
always@(posedge sys_clk or  negedge sys_rst_n)
    if(sys_rst_n == 1'b0)
        begin
            infrared_in_d1  <=  1'b0;
            infrared_in_d2  <=  1'b0;
        end
    else
        begin
            infrared_in_d1  <=  infrared_in;
            infrared_in_d2  <=  infrared_in_d1;
        end

//cnt
always@(posedge    sys_clk or  negedge sys_rst_n)
    if(sys_rst_n == 1'b0)
        cnt <=  19'd0;
    else    if(state==IDLE || (state==S_T9 && ifr_in_rise==1'b1 &&
        flag_9ms==1'b1) || (state==S_JUDGE && ifr_in_fall==1'b1 &&
       (flag_2_25ms==1'b1 || flag_4_5ms==1'b1)) || (state==S_IFR_DATA &&
       ifr_in_rise==1'b1 && flag_0_56ms==1'b1) || (state==S_IFR_DATA &&
       ifr_in_fall==1'b1 && (flag_0_56ms==1'b1 || flag_1_69ms==1'b1)))
        cnt <=  19'd0;
    else
        cnt <=  cnt + 1;

//flag_0_56ms：计数到0.56ms范围拉高标志信号
always@(posedge sys_clk or  negedge sys_rst_n)
    if(sys_rst_n == 1'b0)
        flag_0_56ms <=  1'b0;
    else    if(cnt >= CNT_0_56MS_L && cnt <= CNT_0_56MS_H)
        flag_0_56ms <=  1'b1;
    else
        flag_0_56ms <=  1'b0;

//flag_1_69ms：计数到1.69ms范围拉高标志信号
always@(posedge sys_clk or  negedge sys_rst_n)
    if(sys_rst_n == 1'b0)
        flag_1_69ms <=  1'b0;
    else    if(cnt >= CNT_1_69MS_L && cnt <= CNT_1_69MS_H)
        flag_1_69ms <=  1'b1;
    else
        flag_1_69ms <=  1'b0;

//flag_2_25ms：计数到2.25ms范围拉高标志信号
always@(posedge sys_clk or  negedge sys_rst_n)
    if(sys_rst_n == 1'b0)
        flag_2_25ms <=  1'b0;
    else    if(cnt >= CNT_2_25MS_L && cnt <= CNT_2_25MS_H)
        flag_2_25ms <=  1'b1;
    else
        flag_2_25ms <=  1'b0;

//flag_4_5ms：计数到4.5ms范围拉高标志信号
always@(posedge sys_clk or  negedge sys_rst_n)
    if(sys_rst_n == 1'b0)
        flag_4_5ms <=  1'b0;
    else    if(cnt >= CNT_4_5MS_L && cnt <= CNT_4_5MS_H)
        flag_4_5ms <=  1'b1;
    else
        flag_4_5ms <=  1'b0;

//flag_9ms：计数到9ms范围拉高标志信号
always@(posedge sys_clk or  negedge sys_rst_n)
    if(sys_rst_n == 1'b0)
        flag_9ms <=  1'b0;
    else    if(cnt >= CNT_9MS_L && cnt <= CNT_9MS_H)
        flag_9ms <=  1'b1;
    else
        flag_9ms <=  1'b0;

//状态机：状态跳转
always@(posedge sys_clk or  negedge sys_rst_n)
    if(sys_rst_n == 1'b0)
        state   <=  IDLE;
    else
        case(state)
    //若检测到红外信号下降沿到来跳转到S_T9状态
        IDLE:
            if(ifr_in_fall == 1'b1)
                state   <=  S_T9;
            else    //若没检测到红外信号的下降沿，则让其保持在IDLE状态
                state   <=  IDLE;
        S_T9:   //若检测到红外信号上升沿到来，则判断flag_9ms是否为1
                //若检测到时间接近9ms，则跳转到S_judje状态
            if(ifr_in_rise == 1'b1)
                if(flag_9ms ==  1'b1) 
                    state   <=  S_JUDGE;
                else    //若低电平保持时间不符合协议时间，则回到IDLE状态
                    state   <=  IDLE;
            else
                state   <=  S_T9;
        S_JUDGE:  //若检测到红外信号下降沿到来，则判断flag_2_25ms是否为1
                  //若检测到时间接近2.25ms，则跳转重复码状态
            if(ifr_in_fall == 1'b1)
                if(flag_2_25ms == 1'b1) 
                    state   <=  S_REPEAT;
                //若flag_2_25ms为0，则判断flag_4_5ms是否为1
                //若检测到时间接近4.5ms，则跳转接收数据状态
                else    if(ifr_in_fall == 1'b1 && flag_4_5ms == 1'b1)
                    state   <=  S_IFR_DATA;
                else
                    state   <=  IDLE;
            else
                state   <=  S_JUDGE;
        S_IFR_DATA:
            //若上升沿到来，低电平保持时间不满足编码协议，则回到空闲状态
            if(ifr_in_rise == 1'b1 && flag_0_56ms == 1'b0)
                state   <=  IDLE;
            //若下降沿到来，高电平保持时间不满足编码0或1，则回到空闲状态
            else    if(ifr_in_fall == 1'b1 && (flag_0_56ms == 1'b0 &&
                                                    flag_1_69ms == 1'b0))
                state   <=  IDLE;
            //数据接收完毕之后回到空闲状态，等待下一个指令的到来
            else    if(data_end ==  1'b1)
                state   <=  IDLE;
        S_REPEAT:
            /*若上升沿到来，无论时间是否到了0.56ms，
            状态机都跳回IDLE状态等待下一数据码或重复码的到来*/
            if(ifr_in_rise == 1'b1)
                state   <=  IDLE;
            else
                state   <=  S_REPEAT;
        default:
                state   <=  IDLE;
        endcase

//data_tmp
always@(posedge sys_clk or  negedge sys_rst_n)
    if(sys_rst_n == 1'b0)
        data_tmp    <=  32'b0;
    else    if(state == S_IFR_DATA && ifr_in_fall == 1'b1 &&
                                                    flag_0_56ms  == 1'b1)
        data_tmp[data_cnt]  <=  1'b0;
    else    if(state == S_IFR_DATA && ifr_in_fall == 1'b1 &&
                                                    flag_1_69ms  == 1'b1)
        data_tmp[data_cnt]  <=  1'b1;
    else
        data_tmp    <=  data_tmp;

//data_end
always@(posedge sys_clk or  negedge sys_rst_n)
    if(sys_rst_n == 1'b0)
        data_end    <=  1'b0;
    else    if(ifr_in_rise == 1'b1 && data_cnt == 6'd32)
        data_end    <=  1'b1;
    else
        data_end    <=  1'b0;

//data_cnt
always@(posedge sys_clk or  negedge sys_rst_n)
    if(sys_rst_n == 1'b0)
        data_cnt    <=  1'b0;
    else    if(ifr_in_rise == 1'b1 && data_cnt == 6'd32)
        data_cnt    <=  1'b0;
    else    if(ifr_in_fall == 1'b1 && state == S_IFR_DATA)
        data_cnt    <=  data_cnt + 1'b1;
    else
        data_cnt    <=  data_cnt;

//repeat_en
always@(posedge sys_clk or  negedge sys_rst_n)
    if(sys_rst_n == 1'b0)
        repeat_en  <=  1'b0;
    else    if(state == S_REPEAT && (data_tmp[23:16] == 
                                        ~data_tmp[31:24]))
        repeat_en  <=  1'b1;
    else
        repeat_en  <=  1'b0;

always@(posedge sys_clk or  negedge sys_rst_n)
    if(sys_rst_n == 1'b0)
        data    <=  20'b0;
    //数据接收完之后若数据校验正确，则输出数据码的数据
    else    if(data_tmp[23:16] == ~data_tmp[31:24] && data_tmp[7:0] ==
                                    ~data_tmp [15:8] && data_cnt==6'd32)
        data   <=  {12'b0,data_tmp[23:16]};

endmodule
