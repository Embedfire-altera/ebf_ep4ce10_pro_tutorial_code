`timescale  1ns/1ns
////////////////////////////////////////////////////////////////////////
// Author        : EmbedFire
// Create Date   : 2019/07/08
// Module Name   : key_ctrl_beep
// Project Name  : top_key_ctrl_beep
// Target Devices: Altera EP4CE10F17C8N
// Tool Versions : Quartus 13.0
// Description   : 按键控制蜂鸣器
//
// Revision      : V1.0
// Additional Comments:
// 
// 实验平台: 野火_征途Pro_FPGA开发板
// 公司    : http://www.embedfire.com
// 论坛    : http://www.firebbs.cn
// 淘宝    : https://fire-stm32.taobao.com
////////////////////////////////////////////////////////////////////////

module  key_ctrl_beep
(
    input   wire    sys_clk     ,   //系统时钟，频率50MHz
    input   wire    sys_rst_n   ,   //复位信号，低电平有效
    input   wire    key_flag    ,   //按键有效信号

    output  reg     beep            //蜂鸣器控制信号
);

//********************************************************************//
//***************************** Main Code ****************************//
//********************************************************************//
//beep:当按键有效时改变蜂鸣器的状态
always@(posedge sys_clk or  negedge sys_rst_n)
    if(sys_rst_n == 1'b0)
        beep    <=  1'b0;
    else    if(key_flag == 1'b1)
        beep    <=  ~beep;

endmodule
