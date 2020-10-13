`timescale  1ns/1ns
////////////////////////////////////////////////////////////////////////
// Author        : EmbedFire
// Create Date   : 2019/03/12
// Module Name   : tb_rs485
// Project Name  : rs485
// Target Devices: Altera EP4CE10F17C8N
// Tool Versions : Quartus 13.0
// Description   : RS485仿真文件
// 
// Revision      : V1.0
// Additional Comments:
// 
// 实验平台: 野火_征途Pro_FPGA开发板
// 公司    : http://www.embedfire.com
// 论坛    : http://www.firebbs.cn
// 淘宝    : https://fire-stm32.taobao.com
////////////////////////////////////////////////////////////////////////

module  tb_rs485();

//********************************************************************//
//****************** Parameter and Internal Signal *******************//
//********************************************************************//

//wire  define
wire            rx1         ;
wire            work_en1    ;
wire            tx1         ;
wire    [3:0]   led1        ;
wire            work_en2    ;
wire            tx2         ;
wire    [3:0]   led2        ;

//reg   define
reg             sys_clk     ;
reg             sys_rst_n   ;
reg     [1:0]   key1        ;
reg     [1:0]   key2        ;

//********************************************************************//
//***************************** Main Code ****************************//
//********************************************************************//

//对sys_clk,sys_rst赋初值，并模拟按键抖动
initial
    begin
            sys_clk     =   1'b1 ;
            sys_rst_n   <=  1'b0 ;
            key1        <=  2'b11;
            key2        <=  2'b11;
    #200    sys_rst_n   <=  1'b1 ;
//按下流水灯按键
    #2000000    key1[0]      <=  1'b0;//按下按键
    #20         key1[0]      <=  1'b1;//模拟抖动
    #20         key1[0]      <=  1'b0;//模拟抖动
    #20         key1[0]      <=  1'b1;//模拟抖动
    #20         key1[0]      <=  1'b0;//模拟抖动
    #200        key1[0]      <=  1'b1;//松开按键
    #20         key1[0]      <=  1'b0;//模拟抖动
    #20         key1[0]      <=  1'b1;//模拟抖动
    #20         key1[0]      <=  1'b0;//模拟抖动
    #20         key1[0]      <=  1'b1;//模拟抖动
//按下呼吸灯按键
    #2000000    key1[1]      <=  1'b0;//按下按键
    #20         key1[1]      <=  1'b1;//模拟抖动
    #20         key1[1]      <=  1'b0;//模拟抖动
    #20         key1[1]      <=  1'b1;//模拟抖动
    #20         key1[1]      <=  1'b0;//模拟抖动
    #200        key1[1]      <=  1'b1;//松开按键
    #20         key1[1]      <=  1'b0;//模拟抖动
    #20         key1[1]      <=  1'b1;//模拟抖动
    #20         key1[1]      <=  1'b0;//模拟抖动
    #20         key1[1]      <=  1'b1;//模拟抖动
//按下呼吸灯按键
    #2000000    key1[1]      <=  1'b0;//按下按键
    #20         key1[1]      <=  1'b1;//模拟抖动
    #20         key1[1]      <=  1'b0;//模拟抖动
    #20         key1[1]      <=  1'b1;//模拟抖动
    #20         key1[1]      <=  1'b0;//模拟抖动
    #200        key1[1]      <=  1'b1;//松开按键
    #20         key1[1]      <=  1'b0;//模拟抖动
    #20         key1[1]      <=  1'b1;//模拟抖动
    #20         key1[1]      <=  1'b0;//模拟抖动
    #20         key1[1]      <=  1'b1;//模拟抖动
//按下呼吸灯按键
    #2000000    key1[1]      <=  1'b0;//按下按键
    #20         key1[1]      <=  1'b1;//模拟抖动
    #20         key1[1]      <=  1'b0;//模拟抖动
    #20         key1[1]      <=  1'b1;//模拟抖动
    #20         key1[1]      <=  1'b0;//模拟抖动
    #200        key1[1]      <=  1'b1;//松开按键
    #20         key1[1]      <=  1'b0;//模拟抖动
    #20         key1[1]      <=  1'b1;//模拟抖动
    #20         key1[1]      <=  1'b0;//模拟抖动
    #20         key1[1]      <=  1'b1;//模拟抖动
//按下流水灯灯按键
    #2000000    key1[0]      <=  1'b0;//按下按键
    #20         key1[0]      <=  1'b1;//模拟抖动
    #20         key1[0]      <=  1'b0;//模拟抖动
    #20         key1[0]      <=  1'b1;//模拟抖动
    #20         key1[0]      <=  1'b0;//模拟抖动
    #200        key1[0]      <=  1'b1;//松开按键
    #20         key1[0]      <=  1'b0;//模拟抖动
    #20         key1[0]      <=  1'b1;//模拟抖动
    #20         key1[0]      <=  1'b0;//模拟抖动
    #20         key1[0]      <=  1'b1;//模拟抖动
//按下流水灯灯按键
    #2000000    key1[0]      <=  1'b0;//按下按键
    #20         key1[0]      <=  1'b1;//模拟抖动
    #20         key1[0]      <=  1'b0;//模拟抖动
    #20         key1[0]      <=  1'b1;//模拟抖动
    #20         key1[0]      <=  1'b0;//模拟抖动
    #200        key1[0]      <=  1'b1;//松开按键
    #20         key1[0]      <=  1'b0;//模拟抖动
    #20         key1[0]      <=  1'b1;//模拟抖动
    #20         key1[0]      <=  1'b0;//模拟抖动
    #20         key1[0]      <=  1'b1;//模拟抖动
    end

//sys_clk:模拟系统时钟，每10ns电平取反一次，周期为20ns，频率为50Mhz
always #10 sys_clk = ~sys_clk;

//重新定义参数值，缩短仿真时间仿真
//发送板参数
defparam    rs485_inst1.key_filter_w.CNT_MAX         =   5      ;
defparam    rs485_inst1.key_filter_b.CNT_MAX         =   5      ;
defparam    rs485_inst1.uart_rx_inst.UART_BPS        =   1000000;
defparam    rs485_inst1.uart_tx_inst.UART_BPS        =   1000000;
defparam    rs485_inst1.water_led_inst.CNT_MAX       =   4000   ;
defparam    rs485_inst1.breath_led_inst.CNT_1US_MAX  =   4      ;
defparam    rs485_inst1.breath_led_inst.CNT_1MS_MAX  =   9      ;
defparam    rs485_inst1.breath_led_inst.CNT_1S_MAX   =   9      ;
//接收板参数
defparam    rs485_inst2.key_filter_w.CNT_MAX         =   5      ;
defparam    rs485_inst2.key_filter_b.CNT_MAX         =   5      ;
defparam    rs485_inst2.uart_rx_inst.UART_BPS        =   1000000;
defparam    rs485_inst2.uart_tx_inst.UART_BPS        =   1000000;
defparam    rs485_inst2.water_led_inst.CNT_MAX       =   4000   ;
defparam    rs485_inst2.breath_led_inst.CNT_1US_MAX  =   4      ;
defparam    rs485_inst2.breath_led_inst.CNT_1MS_MAX  =   99     ;
defparam    rs485_inst2.breath_led_inst.CNT_1S_MAX   =   99     ;


//********************************************************************//
//*************************** Instantiation **************************//
//********************************************************************//

//发送板
//-------------rs485_inst1-------------
rs485   rs485_inst1
(
    .sys_clk     (sys_clk    ),   //系统时钟，50MHz
    .sys_rst_n   (sys_rst_n  ),   //复位信号，低有效
    .rx          (rx1        ),   //串口接收数据
    .key         (key1       ),   //两个按键

    .work_en     (work_en1   ),   //发送使能，高有效
    .tx          (tx1        ),   //串口发送数据
    .led         (led_tx1    )    //led灯

);

//接收板
//-------------rs485_inst2-------------
rs485   rs485_inst2
(
    .sys_clk     (sys_clk    ),   //系统时钟，50MHz
    .sys_rst_n   (sys_rst_n  ),   //复位信号，低有效
    .rx          (tx1        ),   //串口接收数据
    .key         (key2       ),   //两个按键

    .work_en     (work_en2   ),   //发送使能，高有效
    .tx          (tx2        ),   //串口发送数据
    .led         (led_rx2    )    //led灯

);
endmodule
