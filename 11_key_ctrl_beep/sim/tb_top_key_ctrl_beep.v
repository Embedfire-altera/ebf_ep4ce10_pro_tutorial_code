`timescale  1ns/1ns
////////////////////////////////////////////////////////////////////////
// Author        : EmbedFire
// Create Date   : 2019/07/08
// Module Name   : tb_top_key_ctrl_beep
// Project Name  : top_key_ctrl_beep
// Target Devices: Altera EP4CE10F17C8N
// Tool Versions : Quartus 13.0
// Description   : 按键控制蜂鸣器仿真文件
//
// Revision      : V1.0
// Additional Comments:
// 
// 实验平台: 野火_征途Pro_FPGA开发板
// 公司    : http://www.embedfire.com
// 论坛    : http://www.firebbs.cn
// 淘宝    : https://fire-stm32.taobao.com
////////////////////////////////////////////////////////////////////////

module  tb_top_key_ctrl_beep();

//********************************************************************//
//****************** Parameter and Internal Signal *******************//
//********************************************************************//
//wire  define
wire    beep        ;

//reg   define
reg     key_in      ;
reg     sys_clk     ;
reg     sys_rst_n   ;

//********************************************************************//
//***************************** Main Code ****************************//
//********************************************************************//
//对sys_clk,sys_rst赋初值，并模拟按键抖动
initial
    begin
            sys_clk     =   1'b1;
            sys_rst_n   <=  1'b0;
            key_in      <=  1'b1;
    #200    sys_rst_n   <=  1'b1;
    #20     key_in      <=  1'b0;//按下按键
    #20     key_in      <=  1'b1;//模拟抖动
    #20     key_in      <=  1'b0;//模拟抖动
    #20     key_in      <=  1'b1;//模拟抖动
    #20     key_in      <=  1'b0;//模拟抖动
    #200    key_in      <=  1'b1;//松开按键
    #20     key_in      <=  1'b0;//模拟抖动
    #20     key_in      <=  1'b1;//模拟抖动
    #20     key_in      <=  1'b0;//模拟抖动
    #20     key_in      <=  1'b1;//模拟抖动
    #200    key_in      <=  1'b0;//按下按键
    #20     key_in      <=  1'b1;//模拟抖动
    #20     key_in      <=  1'b0;//模拟抖动
    #20     key_in      <=  1'b1;//模拟抖动
    #20     key_in      <=  1'b0;//模拟抖动
    #200    key_in      <=  1'b1;//松开按键
    #20     key_in      <=  1'b0;//模拟抖动
    #20     key_in      <=  1'b1;//模拟抖动
    #20     key_in      <=  1'b0;//模拟抖动
    #20     key_in      <=  1'b1;//模拟抖动    
    end

//clk:产生时钟
always  #10 sys_clk =  ~sys_clk;

//重新定义参数值，缩短仿真时间
defparam    top_key_ctrl_beep_inst.key_filter_inst.CNT_MAX    =   5;

//********************************************************************//
//*************************** Instantiation **************************//
//********************************************************************//
//------------- top_key_ctrl_beep_inst -------------
top_key_ctrl_beep   top_key_ctrl_beep_inst
(
    .sys_clk     (sys_clk   ),
    .sys_rst_n   (sys_rst_n ),
    .key_in      (key_in    ),

    .beep        (beep      )
);
endmodule
