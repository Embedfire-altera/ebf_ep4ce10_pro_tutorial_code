`timescale  1ns/1ns
////////////////////////////////////////////////////////////////////////
// Author        : EmbedFire
// Create Date   : 2019/09/29
// Module Name   : rs485
// Project Name  : rs485
// Target Devices: Altera EP4CE10F17C8N
// Tool Versions : Quartus 13.0
// Description   : RS485顶层模块
// 
// Revision      : V1.0
// Additional Comments:
// 
// 实验平台: 野火_征途Pro_FPGA开发板
// 公司    : http://www.embedfire.com
// 论坛    : http://www.firebbs.cn
// 淘宝    : https://fire-stm32.taobao.com
////////////////////////////////////////////////////////////////////////

module  rs485
(
    input   wire            sys_clk     ,   //系统时钟，50MHz
    input   wire            sys_rst_n   ,   //复位信号，低有效
    input   wire            rx          ,   //串口接收数据
    input   wire    [1:0]   key         ,   //两个按键

    output  wire            work_en     ,   //发送使能，高有效
    output  wire            tx          ,   //串口接收数据
    output  wire    [3:0]   led             //led灯

);

//********************************************************************//
//****************** Parameter and Internal Signal *******************//
//********************************************************************//

//parameter define
parameter   UART_BPS    =   14'd9600;       //比特率
parameter   CLK_FREQ    =   26'd50_000_000; //时钟频率

//wire  define
wire    [7:0]   po_data         ;   //接收数据
wire    [7:0]   pi_data         ;   //发送数据
wire            pi_flag         ;   //发送标志信号
wire            water_key_flag  ;   //流水灯按键有效信号
wire            breath_key_flag ;   //呼吸灯按键有效信号
wire    [3:0]   led_out_w       ;   //流水灯
wire            led_out_b       ;   //呼吸灯

//********************************************************************//
//***************************** Main Code ****************************//
//********************************************************************//

//--------------------uart_rx_inst------------------------
uart_rx
#(
    .UART_BPS    (UART_BPS  ),   //串口波特率
    .CLK_FREQ    (CLK_FREQ  )    //时钟频率
)
uart_rx_inst(
    .sys_clk     (sys_clk   ),   //系统时钟50Mhz
    .sys_rst_n   (sys_rst_n ),   //全局复位
    .rx          (rx        ),   //串口接收数据

    .po_data     (po_data   ),   //串转并后的8bit数据
    .po_flag     (          )    //接收数据完成标志信号没用到可不接
);

//--------------------uart_tx_inst------------------------
uart_tx
#(
    .UART_BPS    (UART_BPS  ),   //串口波特率
    .CLK_FREQ    (CLK_FREQ  )    //时钟频率
)
uart_tx_inst(
    .sys_clk     (sys_clk   ),   //系统时钟50Mhz
    .sys_rst_n   (sys_rst_n ),   //全局复位
    .pi_data     (pi_data   ),   //并行数据
    .pi_flag     (pi_flag   ),   //并行数据有效标志信号

    .work_en     (work_en   ),   //发送使能，高有效
    .tx          (tx        )    //串口发送数据
);

//--------------------key_filter_inst------------------------
//两个按键信号例化两次
key_filter  key_filter_w
(
    .sys_clk        (sys_clk        ),    //系统时钟50Mhz
    .sys_rst_n      (sys_rst_n      ),    //全局复位
    .key_in         (key[0]         ),    //按键输入信号

    .key_flag       (water_key_flag)  //key_flag为1时表示消抖后按键有效

);
key_filter  key_filter_b
(
    .sys_clk        (sys_clk        ),    //系统时钟50Mhz
    .sys_rst_n      (sys_rst_n      ),    //全局复位
    .key_in         (key[1]         ),    //按键输入信号

    .key_flag       (breath_key_flag) //key_flag为1时表示消抖后按键有效

);

//--------------------key_ctrl_inst------------------------
led_ctrl    led_ctrl_inst
(
    .sys_clk         (sys_clk        ),   //模块时钟，50MHz
    .sys_rst_n       (sys_rst_n      ),   //复位信号，低有效
    .water_key_flag  (water_key_flag ),   //流水灯按键有效信号
    .breath_key_flag (breath_key_flag),   //呼吸灯按键有效信号
    .led_out_w       (led_out_w      ),   //流水灯
    .led_out_b       (led_out_b      ),   //呼吸灯
    .po_data         (po_data        ),   //接收数据

    .pi_flag         (pi_flag        ),   //发送标志信号
    .pi_data         (pi_data        ),   //发送数据
    .led_out         (led            )    //输出led灯

);

//--------------------water_led_inst------------------------
water_led   water_led_inst
(
    .sys_clk         (sys_clk   ),   //系统时钟50Mh
    .sys_rst_n       (sys_rst_n ),   //全局复位

    .led_out         (led_out_w )    //输出控制led灯

);

//--------------------breath_led_inst------------------------
breath_led  breath_led_inst
(
    .sys_clk         (sys_clk   ),   //系统时钟50Mhz
    .sys_rst_n       (sys_rst_n ),   //全局复位

    .led_out         (led_out_b )    //输出信号，控制led灯

);

endmodule
