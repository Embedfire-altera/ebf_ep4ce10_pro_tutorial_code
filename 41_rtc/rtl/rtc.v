`timescale  1ns/1ns
////////////////////////////////////////////////////////////////////////
// Author        : EmbedFire
// Create Date   : 2018/09/07
// Module Name   : rtc
// Project Name  : rtc
// Target Devices: Altera EP4CE10F17C8N
// Tool Versions : Quartus 13.0
// Description   : 实时时钟显示实验
//
// Revision      : V1.0
// Additional Comments:
// 
// 实验平台: 野火_征途Pro_FPGA开发板
// 公司    : http://www.embedfire.com
// 论坛    : http://www.firebbs.cn
// 淘宝    : https://fire-stm32.taobao.com
////////////////////////////////////////////////////////////////////////

module  rtc
(
    input   wire           sys_clk   ,   //系统时钟，频率50MHz
    input   wire           sys_rst_n ,   //复位信号，低电平有效
    input   wire           key_in    ,   //按键信号

    output  wire           stcp      ,   //输出数据存储寄时钟
    output  wire           shcp      ,   //移位寄存器的时钟输入
    output  wire           ds        ,   //串行数据输入
    output  wire           oe        ,   //输出使能信号
    output  wire           scl       ,   //输出至pcf8536的串行时钟信号scl
    
    inout   wire           sda           //输出至pcf8536的串行数据信号sda
);

//********************************************************************//
//******************** Parameter And Internal Signal *****************//
//********************************************************************//

//parameter define
//设置实时时钟初始值分别为：年_月_日_时_分_秒
parameter   TIME_INIT   =   48'h19_09_09_16_15_20;

//wire  define
wire            i2c_clk     ;   //i2c驱动时钟
wire            i2c_end     ;   //i2c一次读/写操作完成
wire    [7:0]   rd_data     ;   //输出i2c设备读取数据
wire            key_flag    ;   //按键消抖后标志信号
wire            wr_en       ;   //写使能信号
wire            rd_en       ;   //读使能信号
wire            i2c_start   ;   //i2c触发信号
wire    [15:0]  byte_addr   ;   //i2c字节地址
wire    [7:0]   wr_data     ;   //写入i2c设备数据
wire    [23:0]  data_out    ;   //数码管显示数据

//********************************************************************//
//*************************** Instantiation **************************//
//********************************************************************//

//-------------pcf8563_ctrl_inst--------------
pcf8563_ctrl 
#(
    .TIME_INIT   (TIME_INIT)
)
pcf8563_ctrl_inst
(
    .sys_clk     (sys_clk  ),   //系统时钟，频率50MHz
    .i2c_clk     (i2c_clk  ),   //i2c驱动时钟
    .sys_rst_n   (sys_rst_n),   //复位信号，低有效
    .i2c_end     (i2c_end  ),   //i2c一次读/写操作完成
    .rd_data     (rd_data  ),   //输出i2c设备读取数据
    .key_flag    (key_flag ),   //按键消抖后标志信号

    .wr_en       (wr_en    ),   //输出写使能信号
    .rd_en       (rd_en    ),   //输出读使能信号
    .i2c_start   (i2c_start),   //输出i2c触发信号
    .byte_addr   (byte_addr),   //输出i2c字节地址
    .wr_data     (wr_data  ),   //输出i2c设备数据
    .data_out    (data_out )    //输出到数码管显示的bcd码数据
    
);

//-------------seg_595_bcd_inst--------------
seg_595_bcd     seg_595_bcd_inst
(
    .sys_clk     (sys_clk  ), //系统时钟，频率50MHz
    .sys_rst_n   (sys_rst_n), //复位信号，低有效
    .data_bcd    (data_out ), //数码管要显示的bcd码数值
    .point       (6'b010100), //小数点显示,高电平有效
    .seg_en      (1'b1     ), //数码管使能信号，高电平有效

    .stcp        (stcp     ), //输出数据存储寄时钟
    .shcp        (shcp     ), //移位寄存器的时钟输入
    .ds          (ds       ), //串行数据输入
    .oe          (oe       )  //输出使能信号

);

//-------------i2c_ctrl_inst--------------
i2c_ctrl
#(
   .DEVICE_ADDR     (7'b1010_001   ),   //i2c设备地址
   .SYS_CLK_FREQ    (26'd50_000_000),   //输入系统时钟频率
   .SCL_FREQ        (18'd250_000   )    //i2c设备scl时钟频率
)
i2c_ctrl_inst(
    .sys_clk     (sys_clk  ),   //输入系统时钟,50MHz
    .sys_rst_n   (sys_rst_n),   //输入复位信号,低电平有效
    .wr_en       (wr_en    ),   //输入写使能信号
    .rd_en       (rd_en    ),   //输入读使能信号
    .i2c_start   (i2c_start),   //输入i2c触发信号
    .addr_num    (1'b0     ),   //输入i2c字节地址字节数
    .byte_addr   (byte_addr),   //输入i2c字节地址
    .wr_data     (wr_data  ),   //输入i2c设备数据

    .i2c_clk     (i2c_clk  ),   //i2c驱动时钟
    .i2c_end     (i2c_end  ),   //i2c一次读/写操作完成
    .rd_data     (rd_data  ),   //输出i2c设备读取数据
    .i2c_scl     (scl      ),   //输出至i2c设备的串行时钟信号scl
    .i2c_sda     (sda      )    //输出至i2c设备的串行数据信号sda
);

//-------------key_fifter_inst--------------
key_filter
#(
    .CNT_MAX     (24'd999_999)
)
key_filter_inst
(
    .sys_clk      (sys_clk  ),    //系统时钟50Mhz
    .sys_rst_n    (sys_rst_n),    //全局复位
    .key_in       (key_in   ),    //按键输入信号

    .key_flag     (key_flag )     //按键消抖后输出信号
);

endmodule
