`timescale  1ns/1ns
////////////////////////////////////////////////////////////////////////
// Author        : EmbedFire
// Create Date   : 2019/03/13
// Module Name   : decoder3_8
// Project Name  : decoder3_8
// Target Devices: Altera EP4CE10F17C8N
// Tool Versions : Quartus 13.0
// Description   : 3-8译码器
//
// Revision      : V1.0
// Additional Comments:
// 
// 实验平台: 野火_征途Pro_FPGA开发板
// 公司    : http://www.embedfire.com
// 论坛    : http://www.firebbs.cn
// 淘宝    : https://fire-stm32.taobao.com
////////////////////////////////////////////////////////////////////////

module  decoder3_8
(
    input   wire            in1 ,   //输入信号in1
    input   wire            in2 ,   //输入信号in2
    input   wire            in3 ,   //输入信号in2

    output  reg     [7:0]   out     //输出信号out
);

//********************************************************************//
//***************************** Main Code ****************************//
//********************************************************************//
/*
//out:根据3个输入信号选择输出对应的8bit out信号
always@(*)
    if({in1, in2, in3} == 3'b000)           //使用"{}"位拼接符将3个1bit数据按照顺序拼成一个3bit数据
        out = 8'b0000_0001;
    else    if({in1, in2, in3} == 3'b001)
        out = 8'b0000_0010;
    else    if({in1, in2, in3} == 3'b010)
        out = 8'b0000_0100;
    else    if({in1, in2, in3} == 3'b011)
        out = 8'b0000_1000;
    else    if({in1, in2, in3} == 3'b100)
        out = 8'b0001_0000;
    else    if({in1, in2, in3} == 3'b101)
        out = 8'b0010_0000;
    else    if({in1, in2, in3} == 3'b110)
        out = 8'b0100_0000;
    else    if({in1, in2, in3} == 3'b111)
        out = 8'b1000_0000;
    else                                    //最一个else对应的if中的条件只有一种情况，还可能产生以上另外的7种情况，如果不加这个else综合器会把不符合该if中条件的上面另外7种情况都考虑进去，会产生大量的冗余逻辑并产生latch（锁存器），所以在组合逻辑中最后一个if后一定要加上else，并任意指定一种确定的输出情况
        out = 8'b0000_0001;
*/

//out:根据3个输入信号选择输出对应的8bit out信号
always@(*)
    case({in1, in2, in3})
        3'b000 : out = 8'b0000_0001;        //输入与输出的8种译码对应关系
        3'b001 : out = 8'b0000_0010;
        3'b010 : out = 8'b0000_0100;
        3'b011 : out = 8'b0000_1000;
        3'b100 : out = 8'b0001_0000;
        3'b101 : out = 8'b0010_0000;
        3'b110 : out = 8'b0100_0000;
        3'b111 : out = 8'b1000_0000;
        default: out = 8'b0000_0001;        //因为case中列举了in所有可能输入的8种情况，且每种情况都有对应确定的输出，所以此处default可以省略，但是为了以后因不能够完全列举而产生latch，所以我们默认一定要加上default，并任意指定一种确定的输出情况
    endcase

endmodule
