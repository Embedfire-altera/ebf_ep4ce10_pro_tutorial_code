`timescale  1ns/1ns
////////////////////////////////////////////////////////////////////////
// Author        : EmbedFire
// Create Date   : 2019/11/18
// Module Name   : data_gen
// Project Name  : pingpang
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

module  data_gen
(
    input   wire        clk_50m     ,   //模块时钟，频率50MHz
    input   wire        rst_n       ,   //复位信号，低电平有效

    output  reg         data_en     ,   //数据使能信号，高电平有效
    output  reg [7:0]   data_in         //输出数据

);

//********************************************************************//
//******************************* Main Code **************************//
//********************************************************************//

//data_en：让其一直为高电平，一直输出数据
always@(posedge clk_50m or  negedge rst_n)
    if(rst_n == 1'b0)
        data_en  <=  1'b0;
    else
        data_en  <=  1'b1;
        
//data_in:循环生成写入的数据(8'd0 ~ 8'd199)
always@(posedge clk_50m or  negedge rst_n)
    if(rst_n == 1'b0)
        data_in <=  8'd0;
    else    if(data_in  == 8'd199)
        data_in <=  8'd0;
    else    if(data_en == 1'b1)
        data_in <=  data_in +   1'b1;
    else
        data_in <=  data_in;

endmodule
