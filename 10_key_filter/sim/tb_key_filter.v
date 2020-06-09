`timescale  1ns/1ns
////////////////////////////////////////////////////////////////////////
// Author        : EmbedFire
// Create Date   : 2019/03/14
// Module Name   : tb_counter
// Project Name  : counter
// Target Devices: Altera EP4CE10F17C8N
// Tool Versions : Quartus 13.0
// Description   : 按键消抖模块仿真文件
//
// Revision      : V1.0
// Additional Comments:
// 
// 实验平台: 野火_征途Pro_FPGA开发板
// 公司    : http://www.embedfire.com
// 论坛    : http://www.firebbs.cn
// 淘宝    : https://fire-stm32.taobao.com
////////////////////////////////////////////////////////////////////////

module  tb_key_filter();

//********************************************************************//
//****************** Parameter and Internal Signal *******************//
//********************************************************************//

//parameter define
//为了缩短仿真时间，我们将参数化的时间值改小
//但位宽依然定义和参数名的值保持一致
//也可以将这些参数值改成和参数名的值一致
parameter   CNT_1MS  = 20'd19   ,
            CNT_11MS = 21'd69   ,
            CNT_41MS = 22'd149  ,
            CNT_51MS = 22'd199  ,
            CNT_60MS = 22'd249  ;

//wire  define
wire            key_flag        ;   //消抖后按键信号

//reg   define
reg             sys_clk         ;   //仿真时钟信号
reg             sys_rst_n       ;   //仿真复位信号
reg             key_in          ;   //模拟按键输入
reg     [21:0]  tb_cnt          ;   //模拟按键抖动计数器

//********************************************************************//
//***************************** Main Code ****************************//
//********************************************************************//

//初始化输入信号
initial begin
    sys_clk    = 1'b1;
    sys_rst_n <= 1'b0;
    key_in    <= 1'b0;
    #20         
    sys_rst_n <= 1'b1;
end

//sys_clk:模拟系统时钟，每10ns电平翻转一次，周期为20ns，频率为50Mhz
always #10 sys_clk = ~sys_clk;

//tb_cnt:按键过程计数器，通过该计数器的计数时间来模拟按键的抖动过程
always@(posedge sys_clk or negedge sys_rst_n)
    if(sys_rst_n == 1'b0)
        tb_cnt <= 22'b0;
    else    if(tb_cnt == CNT_60MS)
          //计数器计数到CNT_60MS完成一次按键从按下到释放的整个过程
        tb_cnt <= 22'b0;
    else    
        tb_cnt <= tb_cnt + 1'b1;

//key_in:产生输入随机数，模拟按键的输入情况
always@(posedge sys_clk or negedge sys_rst_n)
    if(sys_rst_n == 1'b0)
        key_in <= 1'b1;     //按键未按下时的状态为为高电平
    else    if((tb_cnt >= CNT_1MS && tb_cnt <= CNT_11MS)
                || (tb_cnt >= CNT_41MS && tb_cnt <= CNT_51MS))
    //在该计数区间内产生非负随机数0、1来模拟10ms的前抖动和10ms的后抖动
        key_in <= {$random} % 2;    
    else    if(tb_cnt >= CNT_11MS && tb_cnt <= CNT_41MS)
        key_in <= 1'b0;
    //按键经过10ms的前抖动后稳定在低电平，持续时间需大于CNT_MAX
    else
        key_in <= 1'b1;

//********************************************************************//
//*************************** Instantiation **************************//
//********************************************************************//
//------------------------ key_filter_inst ------------------------
key_filter
#(
    .CNT_MAX    (20'd24     )
            //修改的CNT_MAX值一定要小于(CNT_41MS - CNT_11MS)
            //否则就会表现为按键一直处于“抖动状态”而没有“稳定状态”
            //无法模拟出按键消抖的效果
)
key_filter_inst
(
    .sys_clk    (sys_clk    ),  //input     sys_clk
    .sys_rst_n  (sys_rst_n  ),  //input     sys_rst_n
    .key_in     (key_in     ),  //input     key_in
                        
    .key_flag   (key_flag   )   //output    key_flag
);

endmodule
