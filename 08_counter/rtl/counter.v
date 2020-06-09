`timescale  1ns/1ns
////////////////////////////////////////////////////////////////////////
// Author        : EmbedFire
// Create Date   : 2019/03/14
// Module Name   : counter
// Project Name  : counter
// Target Devices: Altera EP4CE10F17C8N
// Tool Versions : Quartus 13.0
// Description   : 计数器
//
// Revision      : V1.0
// Additional Comments:
// 
// 实验平台: 野火_征途Pro_FPGA开发板
// 公司    : http://www.embedfire.com
// 论坛    : http://www.firebbs.cn
// 淘宝    : https://fire-stm32.taobao.com
////////////////////////////////////////////////////////////////////////

//方法1实现：不带标志信号的计数器
module  counter
#(
    parameter   CNT_MAX = 25'd24_999_999    //这是我们第一次使用参数的方式定义常量,使用参数的方式定义常量有很多好处,如：我们在RTL代码中实例化该模块时,如果需要两个不同计数值的计数器我们不必设计两个模块,而是直接修改参数的值即可；另一个好处是在编写Testbench进行仿真时我们也需要实例化该模块,但是我们需要仿真至少0.5s的时间才能够看出到led_out效果,这会让仿真时间很长,也会导致产生的仿真文件很大,所以我们可以通过直接修改参数的方式来缩短仿真的时间而看到相同的效果,且不会影响到RTL代码模块中的实际值,因为parameter定义的是局部参数,所以只在本模块中有效。为了更好的区分,参数名我们习惯上都要大写
)
(
    input   wire    sys_clk     ,   //系统时钟50Mhz
    input   wire    sys_rst_n   ,   //全局复位

    output  reg     led_out         //输出控制led灯
);

//********************************************************************//
//****************** Parameter and Internal Signal *******************//
//********************************************************************//
//reg   define
reg     [24:0]  cnt;                //经计算得需要25位宽的寄存器才够500ms

//********************************************************************//
//***************************** Main Code ****************************//
//********************************************************************//
//cnt:计数器计数,当计数到CNT_MAX的值时清零
always@(posedge sys_clk or negedge sys_rst_n)
    if(sys_rst_n == 1'b0)
        cnt <= 25'b0;
    else    if(cnt == CNT_MAX)
        cnt <= 25'b0;
    else
        cnt <= cnt + 1'b1;

//led_out:输出控制一个LED灯,每当计数满标志信号有效时取反
always@(posedge sys_clk or negedge sys_rst_n)
    if(sys_rst_n == 1'b0)
        led_out <= 1'b0;
    else    if(cnt == CNT_MAX)
        led_out <= ~led_out;

endmodule

/*
//方法2实现：带标志信号的计数器
module  counter
#(
    parameter   CNT_MAX = 25'd24_999_999    //这是我们第一次使用参数的方式定义常量,使用参数的方式定义常量有很多好处,如：我们在RTL代码中实例化该模块时,如果需要两个不同计数值的计数器我们不必设计两个模块,而是直接修改参数的值即可；另一个好处是在编写Testbench进行仿真时我们也需要实例化该模块,但是我们需要仿真至少0.5s的时间才能够看出到led_out效果,这会让仿真时间很长,也会导致产生的仿真文件很大,所以我们可以通过直接修改参数的方式来缩短仿真的时间而看到相同的效果,且不会影响到RTL代码模块中的实际值,因为parameter定义的是局部参数,所以只在本模块中有效。为了更好的区分,参数名我们习惯上都要大写
)
(
    input   wire    sys_clk     ,   //系统时钟50Mhz
    input   wire    sys_rst_n   ,   //全局复位

    output  reg     led_out         //输出控制led灯
);

reg     [24:0]  cnt;                //经计算得需要25位宽的寄存器才够500ms
reg             cnt_flag;

//cnt:计数器计数,当计数到CNT_MAX的值时清零
always@(posedge sys_clk or negedge sys_rst_n)
    if(sys_rst_n == 1'b0)
        cnt <= 25'b0;
    else    if(cnt == CNT_MAX)
        cnt <= 25'b0;
    else
        cnt <= cnt + 1'b1;

//cnt_flag:计数到最大值产生的标志信号
always@(posedge sys_clk or negedge sys_rst_n)
    if(sys_rst_n == 1'b0)
        cnt_flag <= 1'b0;
    else    if(cnt == CNT_MAX - 1'b1)
        cnt_flag <= 1'b1;
    else
        cnt_flag <= 1'b0;

//led_out:输出控制一个LED灯,每当计数满标志信号有效时取反
always@(posedge sys_clk or negedge sys_rst_n)
    if(sys_rst_n == 1'b0)
        led_out <= 1'b0;
    else    if(cnt_flag == 1'b1)
        led_out <= ~led_out;

endmodule
*/
