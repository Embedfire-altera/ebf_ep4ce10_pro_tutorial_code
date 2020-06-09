`timescale  1ns/1ns
////////////////////////////////////////////////////////////////////////
// Author        : EmbedFire
// Create Date   : 2019/03/13
// Module Name   : half_adder
// Project Name  : half_adder
// Target Devices: Altera EP4CE10F17C8N
// Tool Versions : Quartus 13.0
// Description   : 半加器
//
// Revision      : V1.0
// Additional Comments:
// 
// 实验平台: 野火_征途Pro_FPGA开发板
// 公司    : http://www.embedfire.com
// 论坛    : http://www.firebbs.cn
// 淘宝    : https://fire-stm32.taobao.com
////////////////////////////////////////////////////////////////////////

module  half_adder
(
    input   wire    in1 ,   //加数1
    input   wire    in2 ,   //加数2
    
    output  wire    sum ,   //两个数的加和
    output  wire    cout    //加和后的进位
);

//********************************************************************//
//***************************** Main Code ****************************//
//********************************************************************//
//sum:两个数加和的输出
//cout:两个数进位的输出
assign  {cout, sum} = in1 + in2;

endmodule   
