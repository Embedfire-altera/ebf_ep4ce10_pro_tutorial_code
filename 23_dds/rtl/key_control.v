`timescale  1ns/1ns
/////////////////////////////////////////////////////////////////////////
// Author        : EmbedFire
// Create Date   : 2019/07/10
// Module Name   : key_control
// Project Name  : top_dds
// Target Devices: Altera EP4CE10F17C8N
// Tool Versions : Quartus 13.0
// Description   : 按键控制模块,控制波形选择
// 
// Revision      : V1.0
// Additional Comments:
// 
// 实验平台: 野火_征途Pro_FPGA开发板
// 公司    : http://www.embedfire.com
// 论坛    : http://www.firebbs.cn
// 淘宝    : https://fire-stm32.taobao.com
////////////////////////////////////////////////////////////////////////

module  key_control
(
    input   wire            sys_clk     ,   //系统时钟,50MHz
    input   wire            sys_rst_n   ,   //复位信号,低电平有效
    input   wire    [3:0]   key         ,   //输入4位按键

    output  wire    [3:0]   wave_select     //输出波形选择
);

//********************************************************************//
//****************** Parameter and Internal Signal *******************//
//********************************************************************//
//parameter define
parameter   sin_wave    =   4'b0001,    //正弦波
            squ_wave    =   4'b0010,    //方波
            tri_wave    =   4'b0100,    //三角波
            saw_wave    =   4'b1000;    //锯齿波

parameter   CNT_MAX =   20'd999_999;    //计数器计数最大值

//wire  define
wire            key3    ;   //按键3
wire            key2    ;   //按键2
wire            key1    ;   //按键1
wire            key0    ;   //按键0

//reg   define
reg     [3:0]   wave    ;   //按键状态对应波形
reg     [3:0]   key_state;  //按键状态

//********************************************************************//
//***************************** Main Code ****************************//
//********************************************************************//
//key_state:按键状态
always@(posedge sys_clk or negedge sys_rst_n)
    if(sys_rst_n == 1'b0)
        key_state   <=  4'b0001;
    else    if(key0 == 1'b1)
        key_state   <=  4'b0001;
    else    if(key1 == 1'b1)
        key_state   <=  4'b0010;
    else    if(key2 == 1'b1)
        key_state   <=  4'b0100;
    else    if(key3 == 1'b1)
        key_state   <=  4'b1000;
    else
        key_state   <=  key_state;

//wave:按键状态对应波形
always@(posedge sys_clk or negedge sys_rst_n)
    if(sys_rst_n == 1'b0)
        wave    <=  4'd0;
    else
        case(key_state)          //按键扫描
            4'b0001:wave    <=  sin_wave;
            4'b0010:wave    <=  squ_wave;
            4'b0100:wave    <=  tri_wave;
            4'b1000:wave    <=  saw_wave;
            default:wave    <=  sin_wave;
        endcase

//wave_select:波形选择
assign  wave_select =   wave;

//********************************************************************//
//*************************** Instantiation **************************//
//********************************************************************//
//------------- key_fifter_inst3 --------------
key_filter 
#(
    .CNT_MAX      (CNT_MAX  )       //计数器计数最大值
)
key_filter_inst3
(
    .sys_clk      (sys_clk  )   ,   //系统时钟50Mhz
    .sys_rst_n    (sys_rst_n)   ,   //全局复位
    .key_in       (key[3]   )   ,   //按键输入信号

    .key_flag     (key3     )       //按键消抖后标志信号
);

//------------- key_fifter_inst2 --------------
key_filter 
#(
    .CNT_MAX      (CNT_MAX  )       //计数器计数最大值
)
key_filter_inst2
(
    .sys_clk      (sys_clk  )   ,   //系统时钟50Mhz
    .sys_rst_n    (sys_rst_n)   ,   //全局复位
    .key_in       (key[2]   )   ,   //按键输入信号

    .key_flag     (key2     )       //按键消抖后标志信号
);

//------------- key_fifter_inst1 --------------
key_filter 
#(
    .CNT_MAX      (CNT_MAX  )       //计数器计数最大值
)
key_filter_inst1
(
    .sys_clk      (sys_clk  )   ,   //系统时钟50Mhz
    .sys_rst_n    (sys_rst_n)   ,   //全局复位
    .key_in       (key[1]   )   ,   //按键输入信号

    .key_flag     (key1     )       //按键消抖后标志信号
);

//------------- key_fifter_inst0 --------------
key_filter 
#(
    .CNT_MAX      (CNT_MAX  )       //计数器计数最大值
)
key_filter_inst0
(
    .sys_clk      (sys_clk  )   ,   //系统时钟50Mhz
    .sys_rst_n    (sys_rst_n)   ,   //全局复位
    .key_in       (key[0]   )   ,   //按键输入信号

    .key_flag     (key0     )       //按键消抖后标志信号
);

endmodule
