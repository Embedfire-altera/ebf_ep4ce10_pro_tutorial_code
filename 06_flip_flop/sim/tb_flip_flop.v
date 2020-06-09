`timescale  1ns/1ns
////////////////////////////////////////////////////////////////////////
// Author        : EmbedFire
// Create Date   : 2019/03/14
// Module Name   : tb_flip_flop
// Project Name  : flip_flop
// Target Devices: Altera EP4CE10F17C8N
// Tool Versions : Quartus 13.0
// Description   : 寄存器仿真文件
//
// Revision      : V1.0
// Additional Comments:
// 
// 实验平台: 野火_征途Pro_FPGA开发板
// 公司    : http://www.embedfire.com
// 论坛    : http://www.firebbs.cn
// 淘宝    : https://fire-stm32.taobao.com
////////////////////////////////////////////////////////////////////////

module  tb_flip_flop();

//********************************************************************//
//****************** Parameter and Internal Signal *******************//
//********************************************************************//
//wire  define
wire            led_out     ;

//reg   define
reg             sys_clk     ;
reg             sys_rst_n   ;
reg             key_in      ;

//********************************************************************//
//***************************** Main Code ****************************//
//********************************************************************//
//初始化系统时钟、全局复位和输入信号
initial begin
    sys_clk    = 1'b1;  //时钟信号的初始化为1，且使用“=”赋值，其他信号的赋值都是用“<=”
    sys_rst_n <= 1'b0;  //因为低电平复位，所以复位信号的初始化为0
    key_in    <= 1'b0;  //输入信号按键的初始化，为0和1均可
    #20
    sys_rst_n <= 1'b1;  //初始化20ns后，复位释放，因为是低电平复位，所示释放时，把信号拉高，电路开始工作
    #210
    sys_rst_n <= 1'b0;  //为了观察同步复位和异步复位的区别，在复位释放后电路工作210ns后再让复位有效。之所以选择延时210ns而不是200ns或220ns，是因为能够使复位信号在时钟下降沿时复位，能够清晰的看出同步复位和异步复位的差别
    #40
    sys_rst_n <= 1'b1;  //复位40ns后再次让复位释放掉
end

//sys_clk:模拟系统时钟，每10ns电平翻转一次，周期为20ns，频率为50Mhz
always #10 sys_clk = ~sys_clk; //使用always产生时钟信号，让时钟每隔10ns反转一次，即一个时钟周期为20ns，换算为频率为50Mhz

//key_in:产生输入随机数，模拟按键的输入情况
always #20 key_in <= {$random} % 2; //取模求余数，产生非负随机数0、1，每隔20ns产生一次随机数（之所以每20ns产生一次随机数而不是之前的每10ns产生一次随机数，是为了在时序逻辑中能够保证key_in信号的变化的时间小于等于时钟的周期，这样就不会产生类似毛刺的变化信号，虽然产生的毛刺在时序电路中也能被滤除掉，但是不便于我们观察波形）

initial begin
    $timeformat(-9, 0, "ns", 6);
    $monitor("@time %t: key_in=%b led_out=%b", $time, key_in, led_out);
end

//********************************************************************//
//**************************** Instantiate ***************************//
//********************************************************************//
//------------- flip_flop_inst -------------
flip_flop   flip_flop_inst
(
    .sys_clk    (sys_clk    ),  //input     sys_clk
    .sys_rst_n  (sys_rst_n  ),  //input     sys_rst_n
    .key_in     (key_in     ),  //input     key_in

    .led_out    (led_out    )   //output    led_out
);

endmodule
