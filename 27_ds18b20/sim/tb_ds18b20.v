`timescale  1ns/1ns
////////////////////////////////////////////////////////////////////////
// Author        : EmbedFire
// Create Date   : 2019/07/30
// Module Name   : tb_ds18b20
// Project Name  : ds18b20
// Target Devices: Altera EP4CE10F17C8N
// Tool Versions : Quartus 13.0
// Description   : ds18b20仿真文件
//
// Revision      : V1.0
// Additional Comments:
// 
// 实验平台: 野火_征途Pro_FPGA开发板
// 公司    :http://www.embedfire.com
// 论坛    :http://www.firebbs.cn
// 淘宝    :https://fire-stm32.taobao.com
////////////////////////////////////////////////////////////////////////

module  tb_ds18b20();

//********************************************************************//
//******************** Parameter And Internal Signal *****************//
//********************************************************************//

//wire  define
wire    stcp    ;
wire    shcp    ;
wire    ds      ;
wire    oe      ;
wire    dq      ;

//reg   define
reg     sys_clk     ;
reg     sys_rst_n   ;

//********************************************************************//
//*************************** Instantiation **************************//
//********************************************************************//

//对sys_clk,sys_rst_n赋初始值
initial
    begin
        sys_clk     =   1'b1;
        sys_rst_n   <=  1'b0;
        #100
        sys_rst_n   <=  1'b1;
    end

//clk:产生时钟
always  #10 sys_clk <=  ~sys_clk;

//重新定义参数值，缩短仿真时间
defparam    ds18b20_inst.ds18b20_ctrl_inst.S_WAIT_MAX   =   750;

//-------------ds18b20_inst-------------
ds18b20     ds18b20_inst
(
    .sys_clk     (sys_clk  ),   //系统时钟，频率50MHz
    .sys_rst_n   (sys_rst_n),   //复位信号，低电平有效

    .dq          (dq       ),   //数据总线

    .stcp        (stcp     ),   //输出数据存储寄时钟
    .shcp        (shcp     ),   //移位寄存器的时钟输入
    .ds          (ds       ),   //串行数据输入
    .oe          (oe       )    //输出使能信号

);

endmodule
