`timescale  1ns/1ns
////////////////////////////////////////////////////////////////////////
// Author        : EmbedFire
// Create Date   : 2019/03/21
// Module Name   : tb_flash_be_ctrl
// Project Name  : spi_flash_be
// Target Devices: Altera EP4CE10F17C8N
// Tool Versions : Quartus 13.0
// Description   : flash_be_ctrl模块仿真文件
//
// Revision      : V1.0
// Additional Comments:
// 
// 实验平台: 野火_征途Pro_FPGA开发板
// 公司    : http://www.embedfire.com
// 论坛    : http://www.firebbs.cn
// 淘宝    : https://fire-stm32.taobao.com
////////////////////////////////////////////////////////////////////////

module  tb_flash_be_ctrl();

//wire  define
wire            cs_n    ;   //Flash片选信号
wire            sck     ;   //Flash串行时钟
wire            mosi    ;   //Flash主输出从输入信号

//reg   define
reg     sys_clk     ;   //模拟时钟信号
reg     sys_rst_n   ;   //模拟复位信号
reg     key         ;   //模拟全擦除触发信号

//时钟、复位信号、模拟按键信号
initial
    begin
        sys_clk     =   1'b1;
        sys_rst_n   <=  1'b0;
        key <=  1'b0;
        #100
        sys_rst_n   <=  1'b1;
        #1000
        key <=  1'b1;
        #20
        key <=  1'b0;
    end

always  #10 sys_clk <=  ~sys_clk;   //模拟时钟,频率50MHz

//写入Flash仿真模型初始值(全F)
defparam memory.mem_access.initfile = "initmemory.txt";

//------------- flash_be_ctrl_inst -------------
flash_be_ctrl  flash_be_ctrl_inst
(
    .sys_clk    (sys_clk    ),  //输入系统时钟,频率50MHz,1bit
    .sys_rst_n  (sys_rst_n  ),  //输入复位信号,低电平有效,1bit
    .key        (key        ),  //按键输入信号,1bit

    .sck        (sck        ),  //输出串行时钟,1bit
    .cs_n       (cs_n       ),  //输出片选信号,1bit
    .mosi       (mosi       )   //输出主输出从输入数据,1bit
);

//------------- memory -------------
m25p16  memory
(
    .c          (sck    ),  //输入串行时钟,频率12.5Mhz,1bit
    .data_in    (mosi   ),  //输入串行指令或数据,1bit
    .s          (cs_n   ),  //输入片选信号,1bit
    .w          (1'b1   ),  //输入写保护信号,低有效,1bit
    .hold       (1'b1   ),  //输入hold信号,低有效,1bit

    .data_out   (       )   //输出串行数据
);

endmodule
