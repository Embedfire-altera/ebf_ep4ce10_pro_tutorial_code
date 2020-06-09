`timescale  1ns/1ns
////////////////////////////////////////////////////////////////////////
// Author        : EmbedFire
// Create Date   : 2019/04/01
// Module Name   : eeprom_byte_rd_wr
// Project Name  : eeprom_byte_rd_wr
// Target Devices: Altera EP4CE10F17C8N
// Tool Versions : Quartus 13.0
// Description   : eeprom_byte_rd_wr顶层模块
//
// Revision      : V1.0
// Additional Comments:
// 
// 实验平台: 野火_征途Pro_FPGA开发板
// 公司    : http://www.embedfire.com
// 论坛    : http://www.firebbs.cn
// 淘宝    : https://fire-stm32.taobao.com
////////////////////////////////////////////////////////////////////////

module  eeprom_byte_rd_wr
(
    input   wire            sys_clk     ,   //输入工作时钟,频率50MHz
    input   wire            sys_rst_n   ,   //输入复位信号,低电平有效
    input   wire            key_wr      ,   //按键写
    input   wire            key_rd      ,   //按键读

    inout   wire            sda         ,   //串行数据
    output  wire            scl         ,   //串行时钟
    output  wire            stcp        ,   //输出数据存储器时钟
    output  wire            shcp        ,   //移位寄存器的时钟输入
    output  wire            ds          ,   //串行数据输入
    output  wire            oe              //使能信号
);

//********************************************************************//
//****************** Parameter and Internal Signal *******************//
//********************************************************************//
//wire  define
wire            read        ;   //读数据
wire            write       ;   //写数据
wire    [7:0]   po_data     ;   //fifo输出数据
wire    [7:0]   rd_data     ;   //eeprom读出数据
wire            wr_en       ;
wire            rd_en       ;
wire            i2c_end     ;
wire            i2c_start   ;
wire    [7:0]   wr_data     ;
wire    [15:0]  byte_addr   ;
wire            i2c_clk     ;

//********************************************************************//
//*************************** Instantiation **************************//
//********************************************************************//
//------------- key_wr_inst -------------
key_filter  key_wr_inst
(
    .sys_clk    (sys_clk    ),  //系统时钟50Mhz
    .sys_rst_n  (sys_rst_n  ),  //全局复位
    .key_in     (key_wr     ),  //按键输入信号

    .key_flag   (write      )   //key_flag为1时表示按键有效，0表示按键无效
);

//------------- key_rd_inst -------------
key_filter  key_rd_inst
(
    .sys_clk    (sys_clk    ),  //系统时钟50Mhz
    .sys_rst_n  (sys_rst_n  ),  //全局复位
    .key_in     (key_rd     ),  //按键输入信号

    .key_flag   (read       )   //key_flag为1时表示按键有效，0表示按键无效
);

//------------- i2c_rw_data_inst -------------
i2c_rw_data i2c_rw_data_inst
(
    .sys_clk     (sys_clk   ),  //输入系统时钟,频率50MHz
    .i2c_clk     (i2c_clk   ),  //输入i2c驱动时钟,频率1MHz
    .sys_rst_n   (sys_rst_n ),  //输入复位信号,低有效
    .write       (write     ),  //输入写触发信号
    .read        (read      ),  //输入读触发信号
    .i2c_end     (i2c_end   ),  //一次i2c读/写结束信号
    .rd_data     (rd_data   ),  //输入自i2c设备读出的数据

    .wr_en       (wr_en     ),  //输出写使能信号
    .rd_en       (rd_en     ),  //输出读使能信号
    .i2c_start   (i2c_start ),  //输出i2c读/写触发信号
    .byte_addr   (byte_addr ),  //输出i2c设备读/写地址
    .wr_data     (wr_data   ),  //输出写入i2c设备的数据
    .fifo_rd_data(po_data   )   //输出自fifo中读出的数据

);

//------------- i2c_ctrl_inst -------------
i2c_ctrl
#(
    .DEVICE_ADDR    (7'b1010_011     ), //i2c设备器件地址
    .SYS_CLK_FREQ   (26'd50_000_000  ), //i2c_ctrl模块系统时钟频率
    .SCL_FREQ       (18'd250_000     )  //i2c的SCL时钟频率
)
i2c_ctrl_inst
(
    .sys_clk     (sys_clk   ),   //输入系统时钟,50MHz
    .sys_rst_n   (sys_rst_n ),   //输入复位信号,低电平有效
    .wr_en       (wr_en     ),   //输入写使能信号
    .rd_en       (rd_en     ),   //输入读使能信号
    .i2c_start   (i2c_start ),   //输入i2c触发信号
    .addr_num    (1'b1      ),   //输入i2c字节地址字节数
    .byte_addr   (byte_addr ),   //输入i2c字节地址
    .wr_data     (wr_data   ),   //输入i2c设备数据

    .rd_data     (rd_data   ),   //输出i2c设备读取数据
    .i2c_end     (i2c_end   ),   //i2c一次读/写操作完成
    .i2c_clk     (i2c_clk   ),   //i2c驱动时钟
    .i2c_scl     (scl       ),   //输出至i2c设备的串行时钟信号scl
    .i2c_sda     (sda       )    //输出至i2c设备的串行数据信号sda
);

//------------- seg7_dynamic_inst -------------
seg_595_dynamic seg_595_dynamic_inst
(
    .sys_clk     (sys_clk   ), //系统时钟，频率50MHz
    .sys_rst_n   (sys_rst_n ), //复位信号，低有效
    .data        (po_data   ), //数码管要显示的值
    .point       (          ), //小数点显示,高电平有效
    .seg_en      (1'b1      ), //数码管使能信号，高电平有效
    .sign        (          ), //符号位，高电平显示负号

    .stcp        (stcp      ), //数据存储器时钟
    .shcp        (shcp      ), //移位寄存器时钟
    .ds          (ds        ), //串行数据输入
    .oe          (oe        )  //使能信号
);

endmodule