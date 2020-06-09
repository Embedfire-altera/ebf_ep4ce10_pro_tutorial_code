`timescale  1ns/1ns
////////////////////////////////////////////////////////////////////////
// Author        : EmbedFire
// Create Date   : 2019/11/19
// Module Name   : tb_pingpang
// Project Name  : pingpang
// Target Devices: Altera EP4CE10F17C8N
// Tool Versions : Quartus 13.0
// Description   : 乒乓操作仿真文件
// 
// Revision      : V1.0
// Additional Comments:
// 
// 实验平台: 野火_征途Pro_FPGA开发板
// 公司    : http://www.embedfire.com
// 论坛    : http://www.firebbs.cn
// 淘宝    : https://fire-stm32.taobao.com
////////////////////////////////////////////////////////////////////////

module  tb_pingpang();

//reg   define
reg         sys_clk     ;
reg         sys_rst_n   ;

//********************************************************************//
//***************************** Main Code ****************************//
//********************************************************************//

initial
    begin
        sys_clk     =   1'b1;
        sys_rst_n   <=  1'b0;
      #200
        sys_rst_n   <=  1'b1;
    end

//sys_clk:模拟系统时钟，每10ns电平取反一次，周期为20ns，频率为50Mhz
always #10 sys_clk =   ~sys_clk;

//********************************************************************//
//*************************** Instantiation **************************//
//********************************************************************//

//-------------pingpang_inst-------------
pingpang    pingpang_inst
(
    .sys_clk     (sys_clk   ),   //系统时钟
    .sys_rst_n   (sys_rst_n )     //复位信号，低有效

);

endmodule
