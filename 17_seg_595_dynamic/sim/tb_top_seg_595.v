`timescale  1ns/1ns
////////////////////////////////////////////////////////////////////////
// Author        : EmbedFire
// Create Date   : 2019/07/08
// Module Name   : tb_top_seg_595
// Project Name  : tb_top_seg_595
// Target Devices: Altera EP4CE10F17C8N
// Tool Versions : Quartus 13.0
// Description   : top_seg_595仿真文件
//
// Revision      : V1.0
// Additional Comments:
// 
// 实验平台: 野火_征途Pro_FPGA开发板
// 公司    : http://www.embedfire.com
// 论坛    : http://www.firebbs.cn
// 淘宝    : https://fire-stm32.taobao.com
////////////////////////////////////////////////////////////////////////
`timescale  1ns/1ns
module  tb_top_seg_595();

//********************************************************************//
//****************** Parameter and Internal Signal *******************//
//********************************************************************//
//wire  define
wire    stcp    ;   //输出数据存储寄时钟
wire    shcp    ;   //移位寄存器的时钟输入   
wire    ds      ;   //串行数据输入
wire    oe      ;   //输出使能信号

//reg   define
reg     sys_clk     ;
reg     sys_rst_n   ;

//********************************************************************//
//***************************** Main Code ****************************//
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
defparam  top_seg_595_inst.seg_595_dynamic_inst.seg_dynamic_inst.CNT_MAX=19;
defparam  top_seg_595_inst.data_gen_inst.CNT_MAX    =   49;

//********************************************************************//
//*************************** Instantiation **************************//
//********************************************************************//
//------------- seg_595_static_inst -------------
top_seg_595  top_seg_595_inst
(
    .sys_clk     (sys_clk   ),  //系统时钟，频率50MHz
    .sys_rst_n   (sys_rst_n ),  //复位信号，低电平有效

    .stcp        (stcp      ),   //输出数据存储寄时钟
    .shcp        (shcp      ),   //移位寄存器的时钟输入
    .ds          (ds        ),   //串行数据输入
    .oe          (oe        )    //输出使能信号
);

endmodule
