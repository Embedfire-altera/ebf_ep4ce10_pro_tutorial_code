`timescale  1ns/1ns
////////////////////////////////////////////////////////////////////////
// Author        : EmbedFire
// Create Date   : 2018/08/30
// Module Name   : tb_wm8978_cfg
// Project Name  : audio_loopback
// Target Devices: Altera EP4CE10F17C8N
// Tool Versions : Quartus 13.0
// Description   : 
// 
// Revision      : V1.0
// Additional Comments:
// 
// 实验平台: 野火_征途Pro_FPGA开发板
// 公司    : http://www.embedfire.com
// 论坛    : http://www.firebbs.cn
// 淘宝    : https://fire-stm32.taobao.com
////////////////////////////////////////////////////////////////////////

module  tb_wm8978_cfg();

//********************************************************************//
//****************** Parameter and Internal Signal *******************//
//********************************************************************//

//wire  define
wire       i2c_scl  ;
wire       i2c_sda  ;

//reg   define
reg     sys_clk     ;
reg     sys_rst_n   ;

//********************************************************************//
//***************************** Main Code ****************************//
//********************************************************************//

//对sys_clk,sys_rst_n赋初始值
initial
    begin
        sys_clk     =   1'b0;
        sys_rst_n   <=  1'b0;
        #100
        sys_rst_n   <=  1'b1;
    end

//clk:产生时钟
always  #10 sys_clk =  ~sys_clk;

//********************************************************************//
//*************************** Instantiation **************************//
//********************************************************************//

//------------- wm89078_cfg_inst -------------
wm8978_cfg  wm8978_cfg_inst
(
    .sys_clk     (sys_clk   ),   //系统时钟，频率50MHz
    .sys_rst_n   (sys_rst_n ),   //系统复位，低有效

    .i2c_scl     (i2c_scl   ),   //输出至WM8978的串行时钟信号scl
    .i2c_sda     (i2c_sda   )    //输出至WM8978的串行数据信号sda

);

endmodule 
