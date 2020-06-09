`timescale  1ns/1ns
////////////////////////////////////////////////////////////////////////
// Author        : EmbedFire
// Create Date   : 2019/04/01
// Module Name   : ad
// Project Name  : ad
// Target Devices: Altera EP4CE10F17C8N
// Tool Versions : Quartus 13.0
// Description   : 板载ad顶层模块
// 
// Revision      : V1.0
// Additional Comments:
// 
// 实验平台: 野火_征途Pro_FPGA开发板
// 公司    : http://www.embedfire.com
// 论坛    : http://www.firebbs.cn
// 淘宝    : https://fire-stm32.taobao.com
////////////////////////////////////////////////////////////////////////

module  ad
(
    input   wire            sys_clk     ,   //输入系统时钟,50MHz
    input   wire            sys_rst_n   ,   //输入复位信号,低电平有效

    output  wire            i2c_scl     ,   //输出至i2c设备的串行时钟信号scl
    inout   wire            i2c_sda     ,   //输出至i2c设备的串行数据信号sda
    output  wire            stcp        ,   //输出数据存储寄时钟
    output  wire            shcp        ,   //移位寄存器的时钟输入
    output  wire            ds          ,   //串行数据输入
    output  wire            oe              //使能信号
);

//************************************************************************//
//******************** Parameter and Internal Signal *********************//
//************************************************************************//
//parameter define
parameter    DEVICE_ADDR    =   7'h48           ;   //i2c设备地址
parameter    SYS_CLK_FREQ   =   26'd50_000_000  ;   //输入系统时钟频率
parameter    SCL_FREQ       =   18'd250_000     ;   //i2c设备scl时钟频率

//wire define
wire            i2c_clk     ;   //i2c驱动时钟
wire            i2c_start   ;   //i2c触发信号
wire    [15:0]  byte_addr   ;   //i2c字节地址
wire            i2c_end     ;   //i2c一次读/写操作完成
wire    [ 7:0]  rd_data     ;   //i2c设备读取数据
wire    [19:0]  data        ;   //数码管待显示数据
wire            rd_en       ;   //读使能信号

//************************************************************************//
//****************************** Instantiate *****************************//
//************************************************************************//
//------------- pcf8591_adda_inst -------------
pcf8591_ad  pcf8591_ad_inst
(
    .sys_clk     (i2c_clk   ),  //输入系统时钟,50MHz
    .sys_rst_n   (sys_rst_n ),  //输入复位信号,低电平有效
    .i2c_end     (i2c_end   ),  //i2c设备一次读/写操作完成
    .rd_data     (rd_data   ),  //输出i2c设备读取数据

    .rd_en       (rd_en     ),  //输入i2c设备读使能信号
    .i2c_start   (i2c_start ),  //输入i2c设备触发信号
    .byte_addr   (byte_addr ),  //输入i2c设备字节地址
    .po_data     (data      )   //数码管待显示数据
);

//------------- i2c_ctrl_inst -------------
i2c_ctrl
#(
    .DEVICE_ADDR    (DEVICE_ADDR    ),  //i2c设备器件地址
    .SYS_CLK_FREQ   (SYS_CLK_FREQ   ),  //i2c_ctrl模块系统时钟频率
    .SCL_FREQ       (SCL_FREQ       )   //i2c的SCL时钟频率
)
i2c_ctrl_inst
(
    .sys_clk        (sys_clk        ),   //输入系统时钟,50MHz
    .sys_rst_n      (sys_rst_n      ),  //输入复位信号,低电平有效
    .wr_en          (               ),  //输入写使能信号
    .rd_en          (rd_en          ),  //输入读使能信号
    .i2c_start      (i2c_start      ),  //输入i2c触发信号
    .addr_num       (1'b0           ),  //输入i2c字节地址字节数
    .byte_addr      (byte_addr      ),  //输入i2c字节地址
    .wr_data        (               ),  //输入i2c设备数据

    .rd_data        (rd_data        ),  //输出i2c设备读取数据
    .i2c_end        (i2c_end        ),  //i2c一次读/写操作完成
    .i2c_clk        (i2c_clk        ),  //i2c驱动时钟
    .i2c_scl        (i2c_scl        ),  //输出至i2c设备的串行时钟信号scl
    .i2c_sda        (i2c_sda        )   //输出至i2c设备的串行数据信号sda
);

//------------- seg_595_dynamic_inst -------------
seg_595_dynamic     seg_595_dynamic_inst
(
    .sys_clk    (sys_clk    ),  //系统时钟，频率50MHz
    .sys_rst_n  (sys_rst_n  ),  //复位信号，低有效
    .data       (data       ),  //数码管要显示的值
    .point      (6'b001000  ),  //小数点显示,高电平有效
    .seg_en     (1'b1       ),  //数码管使能信号，高电平有效
    .sign       (1'b0       ),  //符号位，高电平显示负号

    .stcp       (stcp       ),   //输出数据存储寄时钟
    .shcp       (shcp       ),   //移位寄存器的时钟输入
    .ds         (ds         ),   //串行数据输入
    .oe         (oe         )    //使能信号
);

endmodule
