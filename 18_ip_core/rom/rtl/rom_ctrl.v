`timescale  1ns/1ns
/////////////////////////////////////////////////////////////////////////
// Author        : EmbedFire
// Create Date   : 2019/12/05
// Module Name   : rom_ctrl
// Project Name  : rom
// Target Devices: Altera EP4CE10F17C8N
// Tool Versions : Quartus 13.0
// Description   : rom控制模块
// 
// Revision      : V1.0
// Additional Comments:
// 
// 实验平台: 野火_征途Pro_FPGA开发板
// 公司    : http://www.embedfire.com
// 论坛    : http://www.firebbs.cn
// 淘宝    : https://fire-stm32.taobao.com
////////////////////////////////////////////////////////////////////////
module  rom_ctrl
(
    input   wire        sys_clk     ,   //系统时钟，频率50MHz
    input   wire        sys_rst_n   ,   //复位信号，低有效
    input   wire        key1_flag   ,   //按键1消抖后有效信号
    input   wire        key2_flag   ,   //按键2消抖后有效信号

    output  reg [7:0]   addr            //输出读ROM地址

);

//********************************************************************//
//****************** Parameter and Internal Signal *******************//
//********************************************************************//

//parameter define
parameter   CNT_MAX =   9_999_999;  //0.2s计数器最大值

//reg   define
reg             addr_flag1      ;   //特定地址1标志信号
reg             addr_flag2      ;   //特定地址2标志信号
reg     [23:0]  cnt_200ms       ;   //0.2s计数器

//********************************************************************//
//***************************** Main Code ****************************//
//********************************************************************//

//产生特定地址1标志信号
always@(posedge sys_clk or  negedge sys_rst_n)
    if(sys_rst_n == 1'b0)
        addr_flag1   <=  1'b0;
    else    if(key2_flag == 1'b1)
        addr_flag1  <=  1'b0;
    else    if(key1_flag == 1'b1)
        addr_flag1   <=  ~addr_flag1;

//产生特定地址2标志信号
always@(posedge sys_clk or  negedge sys_rst_n)
    if(sys_rst_n == 1'b0)
        addr_flag2   <=  1'b0;
    else    if(key1_flag == 1'b1)
        addr_flag2  <=  1'b0;
    else    if(key2_flag == 1'b1)
        addr_flag2   <=  ~addr_flag2;

//0.2s循环计数
always@(posedge sys_clk or  negedge sys_rst_n)
    if(sys_rst_n == 1'b0)
        cnt_200ms    <=  24'd0;
    else    if(cnt_200ms == CNT_MAX)
        cnt_200ms   <=  24'd0;
    else
        cnt_200ms   <=  cnt_200ms + 1'b1;

//让地址从0~255循环，其中两个按键控制两个特定地址的跳转
always@(posedge sys_clk or  negedge sys_rst_n)
    if(sys_rst_n == 1'b0)
        addr    <=  8'd0;
    else    if(addr == 8'd255 && cnt_200ms == CNT_MAX)
        addr    <=  8'd0;
    else    if(addr_flag1 == 1'b1)
        addr    <=  8'd99;
    else    if(addr_flag2 == 1'b1)
        addr    <=  8'd199;
    else    if(cnt_200ms == CNT_MAX)
        addr    <=  addr + 1'b1;

endmodule
