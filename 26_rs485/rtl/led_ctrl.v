`timescale  1ns/1ns
////////////////////////////////////////////////////////////////////////
// Author        : EmbedFire
// Create Date   : 2019/09/29
// Module Name   : led_ctrl
// Project Name  : rs485
// Target Devices: Altera EP4CE10F17C8N
// Tool Versions : Quartus 13.0
// Description   : 
// 
// Revision      : V1.0
// Additional Comments:
// 
// 实验平台: 野火_征途Pro_FPGA开发板
// 公司    : http://www.embedfire.com
// 论坛    : http://www.firebbs.cn
// 淘宝    : https://fire-stm32.taobao.com
////////////////////////////////////////////////////////////////////////

module  led_ctrl
(
    input   wire            sys_clk         ,   //模块时钟，50MHz 
    input   wire            sys_rst_n       ,   //复位信号，低有效
    input   wire            water_key_flag  ,   //流水灯按键有效信号
    input   wire            breath_key_flag ,   //呼吸灯按键有效信号
    input   wire    [3:0]   led_out_w       ,   //流水灯
    input   wire            led_out_b       ,   //呼吸灯
    input   wire    [7:0]   po_data         ,   //接收数据

    output  wire            pi_flag         ,   //发送标志信号
    output  wire    [7:0]   pi_data         ,   //发送数据
    output  reg     [3:0]   led_out             //输出led灯
    
);

//********************************************************************//
//****************** Parameter and Internal Signal *******************//
//********************************************************************//

//reg   define
reg     water_led_flag  ;   //流水灯标志信号，作为pi_data[0]发送
reg     breath_led_flag ;   //呼吸灯标志信号，作为pi_data[1]发送

//********************************************************************//
//***************************** Main Code ****************************//
//********************************************************************//

//按下呼吸灯按键或流水灯按键时，开始发送数据
assign  pi_flag =   water_key_flag | breath_key_flag;

//低两位数据为led控制信号
assign  pi_data =   {6'd0,breath_led_flag,water_led_flag};

//water_key_flag:串口发送的控制信号，高时流水灯，低时停止（按键控制）
always@(posedge sys_clk or  negedge sys_rst_n)
    if(sys_rst_n == 1'b0)
        water_led_flag  <=  1'b0;
    else    if(breath_key_flag == 1'b1)
        water_led_flag  <=  1'b0;
    else    if(water_key_flag == 1'b1)
        water_led_flag  <=  ~water_led_flag;

//breath_key_flag：串口发送的控制信号，高时呼吸灯灯，低时停止（按键控制）
always@(posedge sys_clk or  negedge sys_rst_n)
    if(sys_rst_n == 1'b0)
        breath_led_flag  <=  1'b0;
    else    if(water_key_flag == 1'b1)
        breath_led_flag  <=  1'b0;
    else    if(breath_key_flag == 1'b1)
        breath_led_flag  <=  ~breath_led_flag;

//led_out：当传入的流水灯有效时，led灯为流水灯，同理呼吸灯也是如此
always@(posedge sys_clk or  negedge sys_rst_n)
    if(sys_rst_n == 1'b0)
        led_out <=  4'b1111;
    else    if(po_data[0] == 1'b1 )
        led_out <=  led_out_w;
    else    if(po_data[1] == 1'b1 )
    //使四个led灯都显示呼吸灯状态
        led_out <=  {led_out_b,led_out_b,led_out_b,led_out_b};
    else
        led_out <=  4'b1111; 

endmodule
