`timescale  1ns/1ns
////////////////////////////////////////////////////////////////////////
// Author        : EmbedFire
// Create Date   : 2019/07/16
// Module Name   : tb_top_infrared_rcv
// Project Name  : top_infrared_rcv
// Target Devices: Altera EP4CE10F17C8N
// Tool Versions : Quartus 13.0
// Description   : top_infrared_rcv仿真文件
// 
// Revision      :V1.1
// Additional Comments:
// 
// 实验平台:野火_征途Pro_FPGA开发板 
// 公司    :http://www.embedfire.com
// 论坛    :http://www.firebbs.cn
// 淘宝    :https://fire-stm32.taobao.com
////////////////////////////////////////////////////////////////////////

module  tb_top_infrared_rcv();

//********************************************************************//
//****************** Parameter and Internal Signal *******************//
//********************************************************************//

//wire  define
wire         led    ;
wire         stcp   ;
wire         shcp   ;
wire         ds     ;
wire         oe     ;

//reg   define
reg     sys_clk     ;
reg     sys_rst_n   ;
reg     infrared_in ;

//********************************************************************//
//***************************** Main Code ****************************//
//********************************************************************//

//对sys_clk,sys_rst_n,infrared_in赋值
initial
    begin
        sys_clk     =   1'b1;
        sys_rst_n   <=  1'b0;
        infrared_in <=  1'b1;
        #100
        sys_rst_n   <=  1'b1;
//引导码
        #1000
        infrared_in <=  1'b0; #9000000
        infrared_in <=  1'b1; #4500000
//地址码（发送地址码8’h99）
//数据1
        infrared_in <=  1'b0; #560000
        infrared_in <=  1'b1; #1690000
//数据0
        infrared_in <=  1'b0; #560000
        infrared_in <=  1'b1; #560000
//数据0
        infrared_in <=  1'b0; #560000
        infrared_in <=  1'b1; #560000
//数据1
        infrared_in <=  1'b0; #560000
        infrared_in <=  1'b1; #1690000
//数据1
        infrared_in <=  1'b0; #560000
        infrared_in <=  1'b1; #1690000
//数据0
        infrared_in <=  1'b0; #560000
        infrared_in <=  1'b1; #560000
//数据0
        infrared_in <=  1'b0; #560000
        infrared_in <=  1'b1; #560000
//数据1
        infrared_in <=  1'b0; #560000
        infrared_in <=  1'b1; #1690000
//地址反码（地址反码为8’h66）
//数据0
        infrared_in <=  1'b0; #560000
        infrared_in <=  1'b1; #560000
//数据1
        infrared_in <=  1'b0; #560000
        infrared_in <=  1'b1; #1690000
//数据1
        infrared_in <=  1'b0; #560000
        infrared_in <=  1'b1; #1690000
//数据0
        infrared_in <=  1'b0; #560000
        infrared_in <=  1'b1; #560000
//数据0
        infrared_in <=  1'b0; #560000
        infrared_in <=  1'b1; #560000
//数据1
        infrared_in <=  1'b0; #560000
        infrared_in <=  1'b1; #1690000
//数据1
        infrared_in <=  1'b0; #560000
        infrared_in <=  1'b1; #1690000
//数据0
        infrared_in <=  1'b0; #560000
        infrared_in <=  1'b1; #560000
//数据码（发送数据码8’h22）
//数据0
        infrared_in <=  1'b0; #560000
        infrared_in <=  1'b1; #560000
//数据1
        infrared_in <=  1'b0; #560000
        infrared_in <=  1'b1; #1690000
//数据0
        infrared_in <=  1'b0; #560000
        infrared_in <=  1'b1; #560000
//数据0
        infrared_in <=  1'b0; #560000
        infrared_in <=  1'b1; #560000
//数据0
        infrared_in <=  1'b0; #560000
        infrared_in <=  1'b1; #560000
//数据1
        infrared_in <=  1'b0; #560000
        infrared_in <=  1'b1; #1690000
//数据0
        infrared_in <=  1'b0; #560000
        infrared_in <=  1'b1; #560000
//数据0
        infrared_in <=  1'b0; #560000
        infrared_in <=  1'b1; #560000
//数据反码（数据反码为8’hdd）
//数据1
        infrared_in <=  1'b0; #560000
        infrared_in <=  1'b1; #1690000
//数据0
        infrared_in <=  1'b0; #560000
        infrared_in <=  1'b1; #560000
//数据1
        infrared_in <=  1'b0; #560000
        infrared_in <=  1'b1; #1690000
//数据1
        infrared_in <=  1'b0; #560000
        infrared_in <=  1'b1; #1690000
//数据1
        infrared_in <=  1'b0; #560000
        infrared_in <=  1'b1; #1690000
//数据0
        infrared_in <=  1'b0; #560000
        infrared_in <=  1'b1; #560000
//数据1
        infrared_in <=  1'b0; #560000
        infrared_in <=  1'b1; #1690000
//数据1
        infrared_in <=  1'b0; #560000
        infrared_in <=  1'b1; #1690000
//重复码
        infrared_in <=  1'b0; #560000
        infrared_in <=  1'b1; #42000000
        infrared_in <=  1'b0; #9000000
        infrared_in <=  1'b1; #2250000
        infrared_in <=  1'b0; #560000
        infrared_in <=  1'b1;
    end

//clk:产生时钟
always  #10 sys_clk <=  ~sys_clk;

//********************************************************************//
//*************************** Instantiation **************************//
//********************************************************************//

top_infrared_rcv    top_infrared_rcv_inst
(
    .sys_clk     (sys_clk    ),   //系统时钟，频率50MHz
    .sys_rst_n   (sys_rst_n  ),   //复位信号，低电平有效
    .infrared_in (infrared_in),   //红外接收信号
    
    .stcp        (stcp       ),   //输出数据存储寄时钟
    .shcp        (shcp       ),   //移位寄存器的时钟输入
    .ds          (ds         ),   //串行数据输入
    .oe          (oe         ),   //输出使能信号
    .led         (led        )    //led灯控制信号

);

endmodule
