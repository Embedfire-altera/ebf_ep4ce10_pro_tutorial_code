`timescale  1ns/1ns
////////////////////////////////////////////////////////////////////////
// Author        : EmbedFire
// Create Date   : 2019/03/12
// Module Name   : mux2_1
// Project Name  : mux2_1
// Target Devices: Altera EP4CE10F17C8N
// Tool Versions : Quartus 13.0
// Description   : 2选1多路选择器
//
// Revision      : V1.0
// Additional Comments:
// 
// 实验平台: 野火_征途Pro_FPGA开发板
// 公司    : http://www.embedfire.com
// 论坛    : http://www.firebbs.cn
// 淘宝    : https://fire-stm32.taobao.com
////////////////////////////////////////////////////////////////////////

module  mux2_1              //模块的开头以“module”开始,然后是模块名“mux2_1”
(
    input   wire    in1,    //输入端1,信号名后就是端口列表“();”（端口列表里面列举了该模块对外输入、输出信号的方式、类型、位宽、名字）,该写法采用了Verilog-2001标准,这样更直观且实例化更方便,之前的Verilog-1995标准是将模块对外输入、输出信号的方式、类型、位宽都放到外面
    input   wire    in2,    //输入端2,当数据只有一位宽时位宽表示可以省略,且输入只能是wire型变量
    input   wire    sel,    //选择端,每行信号以“,”结束,最后一个后面不加“,”

    output  reg     out     //结果输出,输出可以是wire型变量也可以是reg型变量,如果输出在always块中被赋值（即在“<=”的左边）就要用reg型变量,如果输出在assign语句中被赋值（即在“=”的左边）就要用wire型变量
);                          //端口列表括号后有个“;”不要忘记

//********************************************************************//
//***************************** Main Code ****************************//
//********************************************************************//
//out:组合逻辑输出sel选择的结果
always@(*)                  //“*”为通配符,表示只要if括号中的条件或赋值号右边的变量发生变化则立即执行下面的代码,“(*)”在此always中等价于“(sel, in1, in2)”写法
    if(sel == 1'b1)         //当“if...else...”中只有一个变量时不需要加“begin...end”,也显得整个代码更加简洁
        out = in1;          //always块中如果表达的是组合逻辑关系时使用“=”进行赋值,每句赋值以“;”结束
    else
        out = in2;

/*
//out:组合逻辑输出选择结果
always@(*)
    case(sel)
        1'b1    : out = in1;

        1'b0    : out = in2;

        default : out = in1;    //如果sel不能列举出所有的情况一定要加default。此处sel只有两种情况,并且完全列举了,所以default可以省略
    endcase
*/

/*
out:组合逻辑输出选择结果
assign out = (sel == 1'b1) ? in1 : in2; //此处使用的是条件运算符（三元运算符）,当括号里面的条件成立时,执行"?”后面的结果；如果括号里面的条件不成立时,执行“:”后面的结果
*/

endmodule                       //模块的结尾以“endmodule”结束（每个模块只能有一组“module”和“endmodule”,所有的代码都要在它们中间编写）
