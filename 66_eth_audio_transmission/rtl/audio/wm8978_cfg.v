//////////////////////////////////////////////////////////////////////////////////
// Author: EmbedFire
// Create Date: 2018/08/19
// Module Name: wm8978_cfg
// Project Name: audio_loopback
// Target Devices: Altera EP4CE10F17C8N
// Tool Versions: Quartus 13.0
// Description: 
//
// Revision:V1.1
// Additional Comments:
//
// 实验平台:野火FPGA开发板
// 公司    :http://www.embedfire.com
// 论坛    :http://www.firebbs.cn
// 淘宝    :https://fire-stm32.taobao.com
//////////////////////////////////////////////////////////////////////////////////

`timescale  1ns/1ns
module  wm8978_cfg
(
    input   wire    sys_clk     ,   //系统时钟，频率50MHz
    input   wire    sys_rst_n   ,   //系统复位，低有效

    output  wire    i2c_scl     ,   //输出至WM8978的串行时钟信号scl
    inout   wire    i2c_sda         //输出至WM8978的串行数据信号sda

);

//********************************************************************//
//****************** Parameter and Internal Signal *******************//
//********************************************************************//

//wire  define
wire            cfg_start   ;   //输入i2c触发信号
wire    [15:0]  cfg_data    ;   //寄存器地址7bit+数据9bit
wire            i2c_clk     ;   //i2c驱动时钟
wire            i2c_end     ;   //i2c一次读/写操作完成
wire            cfg_done    ;   //寄存器配置完成信号

//********************************************************************//
//***************************** Main Code ****************************//
//********************************************************************//

//------------------------ i2c_ctrl_inst -----------------------
i2c_ctrl
#(
    . DEVICE_ADDR     (7'b0011_010   )  ,   //i2c设备地址
    . SYS_CLK_FREQ    (26'd50_000_000)  ,   //输入系统时钟频率
    . SCL_FREQ        (18'd250_000   )      //i2c设备scl时钟频率
)
i2c_ctrl_inst
(
    .sys_clk        (sys_clk       ),  //输入系统时钟,50MHz
    .sys_rst_n      (sys_rst_n     ),  //输入复位信号,低电平有效
    .wr_en          (1'b1          ),  //输入写使能信号
    .rd_en          (1'b0          ),  //输入读使能信号
    .i2c_start      (cfg_start     ),  //输入i2c触发信号
    .addr_num       (1'b0          ),  //输入i2c字节地址字节数
    .byte_addr      (cfg_data[15:8]),  //输入i2c字节地址+数据最高位
    .wr_data        (cfg_data[7:0] ),  //输入i2c设备数据低八位

    .rd_data        (              ),  //输出i2c设备读取数据
    .i2c_end        (i2c_end       ),  //i2c一次读/写操作完成
    .i2c_clk        (i2c_clk       ),  //i2c驱动时钟
    .i2c_scl        (i2c_scl       ),  //输出至i2c设备的串行时钟信号scl
    .i2c_sda        (i2c_sda       )   //输出至i2c设备的串行数据信号sda
);

//---------------------- i2c_reg_cfg_inst ---------------------
i2c_reg_cfg     i2c_reg_cfg_inst
(
    .i2c_clk     (i2c_clk   ),   //系统时钟,由i2c模块传入
    .sys_rst_n   (sys_rst_n ),   //系统复位,低有效
    .cfg_end     (i2c_end   ),   //单个寄存器配置完成

    .cfg_start   (cfg_start ),   //单个寄存器配置触发信号
    .cfg_data    (cfg_data  ),   //寄存器的地址和数据
    .cfg_done    (cfg_done  )    //寄存器配置完成信号
); 

endmodule
