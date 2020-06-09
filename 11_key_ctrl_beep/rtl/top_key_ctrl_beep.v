`timescale  1ns/1ns
////////////////////////////////////////////////////////////////////////
// Author        : EmbedFire
// Create Date   : 2019/07/08
// Module Name   : top_key_ctrl_beep
// Project Name  : top_key_ctrl_beep
// Target Devices: Altera EP4CE10F17C8N
// Tool Versions : Quartus 13.0
// Description   : 按键控制蜂鸣器顶层文件
//
// Revision      : V1.0
// Additional Comments:
// 
// 实验平台: 野火_征途Pro_FPGA开发板
// 公司    : http://www.embedfire.com
// 论坛    : http://www.firebbs.cn
// 淘宝    : https://fire-stm32.taobao.com
////////////////////////////////////////////////////////////////////////

module  top_key_ctrl_beep
(
    input   wire    sys_clk     ,   //系统时钟，50MHz
    input   wire    sys_rst_n   ,   //系统复位，低有效
    input   wire    key_in      ,   //按键输入信号

    output  wire    beep            //蜂鸣器控制信号
);

//********************************************************************//
//******************** Parameter And Internal Signal *****************//
//********************************************************************//
//parameter define
parameter   CNT_MAX =   20'd999_999;    //计数器计数最大值

//wire  define
wire    key_flag;   //按键消抖后标志信号

//********************************************************************//
//*************************** Instantiation **************************//
//********************************************************************//
//------------- key_fifter_inst --------------
key_filter 
#(
    .CNT_MAX      (CNT_MAX  )       //计数器计数最大值
)
key_filter_inst
(
    .sys_clk      (sys_clk  )   ,   //系统时钟50Mhz
    .sys_rst_n    (sys_rst_n)   ,   //全局复位
    .key_in       (key_in   )   ,   //按键输入信号

    .key_flag     (key_flag )       //按键消抖后标志信号
);

//------------- key_ctrl_beep --------------
key_ctrl_beep   key_ctrl_beep_inst
(
    .sys_clk     (sys_clk  )    ,   //系统时钟，频率50MHz
    .sys_rst_n   (sys_rst_n)    ,   //复位信号，低电平有效
    .key_flag    (key_flag )    ,   //按键有效信号
                                    
    .beep        (beep     )        //蜂鸣器控制信号
);

endmodule
