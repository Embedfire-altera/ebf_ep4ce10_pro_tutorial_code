`timescale  1ns/1ns
////////////////////////////////////////////////////////////////////////
// Author        : EmbedFire
// Create Date   : 2019/03/13
// Module Name   : tb_decoder3_8
// Project Name  : decoder3_8
// Target Devices: Altera EP4CE10F17C8N
// Tool Versions : Quartus 13.0
// Description   : 3-8译码器仿真文件
//
// Revision      : V1.0
// Additional Comments:
// 
// 实验平台: 野火_征途Pro_FPGA开发板
// 公司    : http://www.embedfire.com
// 论坛    : http://www.firebbs.cn
// 淘宝    : https://fire-stm32.taobao.com
////////////////////////////////////////////////////////////////////////

module  tb_decoder3_8();

//********************************************************************//
//****************** Parameter and Internal Signal *******************//
//********************************************************************//
//wire  define
wire    [7:0]   out;

//reg   define
reg             in1;
reg             in2;
reg             in3;

//********************************************************************//
//***************************** Main Code ****************************//
//********************************************************************//
//初始化输入信号
initial begin
    in1 <= 1'b0;
    in2 <= 1'b0;
    in3 <= 1'b0;
end

//in1:产生输入随机数，模拟输入端1的输入情况
always #10 in1 <= {$random} % 2;

//in2:产生输入随机数，模拟输入端2的输入情况
always #10 in2 <= {$random} % 2;

//in3:产生输入随机数，模拟输入端3的输入情况
always #10 in3 <= {$random} % 2;

initial begin
    $timeformat(-9, 0, "ns", 6);
    $monitor("@time %t: in1=%b in2=%b in3=%b out=%b", $time, in1, in2, in3, out);
end

//********************************************************************//
//**************************** Instantiate ***************************//
//********************************************************************//
//------------- decoder3_8_inst -------------
decoder3_8  decoder3_8_inst(
    .in1    (in1),  //input             in1
    .in2    (in2),  //input             in2
    .in3    (in3),  //input             in3

    .out    (out)   //output    [7:0]   out
);

endmodule
