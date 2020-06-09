`timescale  1ns/1ns
////////////////////////////////////////////////////////////////////////
// Author        : EmbedFire
// Create Date   : 2019/07/09
// Module Name   : tb_water_led
// Project Name  : water_led
// Target Devices: Altera EP4CE10F17C8N
// Tool Versions : Quartus 13.0
// Description   : 流水灯仿真文件
//
// Revision      : V1.0
// Additional Comments:
// 
// 实验平台: 野火_征途Pro_FPGA开发板
// 公司    : http://www.embedfire.com
// 论坛    : http://www.firebbs.cn
// 淘宝    : https://fire-stm32.taobao.com
////////////////////////////////////////////////////////////////////////

module  tb_water_led();

//********************************************************************//
//****************** Parameter and Internal Signal *******************//
//********************************************************************//
//wire  define
wire    [3:0]   led_out     ;

//reg   define
reg             sys_clk     ;
reg             sys_rst_n   ;

//********************************************************************//
//***************************** Main Code ****************************//
//********************************************************************//
//初始化系统时钟、全局复位
initial begin
    sys_clk    = 1'b1;
    sys_rst_n <= 1'b0;
    #20
    sys_rst_n <= 1'b1;
end

//sys_clk:模拟系统时钟，每10ns电平翻转一次，周期为20ns，频率为50Mhz
always #10 sys_clk = ~sys_clk;

//********************************************************************//
//*************************** Instantiation **************************//
//********************************************************************//
//-------------------- water_led_inst --------------------
water_led   
#(
    .CNT_MAX    (25'd24)
)
water_led_inst
(
    .sys_clk    (sys_clk    ),  //input          sys_clk
    .sys_rst_n  (sys_rst_n  ),  //input          sys_rst_n
                    
    .led_out    (led_out    )   //output  [3:0]  led_out
);

endmodule
