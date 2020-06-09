`timescale  1ns/1ns
////////////////////////////////////////////////////////////////////////
// Author        : EmbedFire
// Create Date   : 2019/03/15
// Module Name   : non_blocking
// Project Name  : non_blocking
// Target Devices: Altera EP4CE10F17C8N
// Tool Versions : Quartus 13.0
// Description   : 非阻塞赋值
//
// Revision      : V1.0
// Additional Comments:
// 
// 实验平台: 野火_征途Pro_FPGA开发板
// 公司    : http://www.embedfire.com
// 论坛    : http://www.firebbs.cn
// 淘宝    : https://fire-stm32.taobao.com
////////////////////////////////////////////////////////////////////////

module  non_blocking
(
    input   wire            sys_clk     ,   //系统时钟50Mhz
    input   wire            sys_rst_n   ,   //全局复位
    input   wire    [1:0]   in          ,   //输入按键

    output  reg     [1:0]   out             //输出控制led灯
);

reg     [1:0]   in_reg;

//in_reg:给输入信号打一拍
//out:输出控制一个LED灯
always@(posedge sys_clk or negedge sys_rst_n)
    if(sys_rst_n == 1'b0)
        begin
            in_reg <= 2'b0;
            out    <= 2'b0;
        end
    else
        begin
            in_reg <= in;
            out    <= in_reg;
        end

endmodule
