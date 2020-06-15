`timescale  1ns/1ns
////////////////////////////////////////////////////////////////////////
// Author        : EmbedFire
// Create Date   : 2019/07/08
// Module Name   : tb_touch_ctrl_led
// Project Name  : touch_ctrl_led
// Target Devices: Altera EP4CE10F17C8N
// Tool Versions : Quartus 13.0
// Description   : 触摸按键控制LED灯仿真文件
//
// Revision      : V1.0
// Additional Comments:
// 
// 实验平台: 野火_征途Pro_FPGA开发板
// 公司    : http://www.embedfire.com
// 论坛    : http://www.firebbs.cn
// 淘宝    : https://fire-stm32.taobao.com
////////////////////////////////////////////////////////////////////////

module  tb_touch_ctrl_led();

//********************************************************************//
//****************** Parameter and Internal Signal *******************//
//********************************************************************//
//wire  define
wire    led         ;

//reg   define
reg     sys_clk     ;
reg     sys_rst_n   ;
reg     touch_key   ;

//********************************************************************//
//***************************** Main Code ****************************//
//********************************************************************//
//sys_clk,sys_rst_n初始赋值，模拟触摸按键信号值
initial
    begin
        sys_clk       =   1'b1 ;
        sys_rst_n    <=   1'b0 ;
        touch_key    <=   1'b0 ;
        #200
        sys_rst_n    <=   1'b1 ;
        #200
        touch_key    <=   1'b1 ;
        #2000
        touch_key    <=   1'b0 ;
        #1000
        touch_key    <=   1'b1 ;
        #3000
        touch_key    <=   1'b0 ;
    end

//clk：产生时钟
always  #10 sys_clk = ~sys_clk ;

//********************************************************************//
//*************************** Instantiation **************************//
//********************************************************************//
//------------- touch_ctrl_led_inst -------------
touch_ctrl_led    touch_ctrl_led_inst
(
    .sys_clk    (sys_clk    ),  //系统时钟，频率50MHz
    .sys_rst_n  (sys_rst_n  ),  //复位信号，低电平有效
    .touch_key  (touch_key  ),  //触摸按键信号

    .led        (led        )   //led输出信号
);

endmodule

