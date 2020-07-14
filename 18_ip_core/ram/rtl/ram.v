`timescale  1ns/1ns
/////////////////////////////////////////////////////////////////////////
// Author        : EmbedFire
// Create Date   : 2019/12/05
// Module Name   : ram
// Project Name  : ram
// Target Devices: Altera EP4CE10F17C8N
// Tool Versions : Quartus 13.0
// Description   : ram顶层文件
// 
// Revision      : V1.0
// Additional Comments:
// 
// 实验平台: 野火_征途Pro_FPGA开发板
// 公司    : http://www.embedfire.com
// 论坛    : http://www.firebbs.cn
// 淘宝    : https://fire-stm32.taobao.com
////////////////////////////////////////////////////////////////////////

module  ram
(
    input   wire            sys_clk     ,   //系统时钟，频率50MHz
    input   wire            sys_rst_n   ,   //复位信号，低电平有效
    input   wire    [1:0]   key         ,   //输入按键信号
    
    output  wire            stcp        ,   //输出数据存储器时钟
    output  wire            shcp        ,   //移位寄存器的时钟输入
    output  wire            ds          ,   //串行数据输入
    output  wire            oe              //输出使能信号

);

//********************************************************************//
//****************** Parameter and Internal Signal *******************//
//********************************************************************//

//wire  define
wire            wr_en       ;   //写使能
wire            rd_en       ;   //读使能
wire    [7:0]   addr        ;   //地址线
wire    [7:0]   wr_data     ;   //写数据
wire    [7:0]   rd_data     ;   //读出RAM数据
wire            key1_flag   ;   //按键1消抖信号
wire            key2_flag   ;   //按键2消抖信号

//********************************************************************//
//*************************** Instantiation **************************//
//********************************************************************//

//----------------ram_ctrl_inst----------------
ram_ctrl    ram_ctrl_inst
(
    .sys_clk   (sys_clk     ), //系统时钟，频率50MHz
    .sys_rst_n (sys_rst_n   ), //复位信号，低有效
    .key1_flag (key1_flag   ), //按键1消抖后有效信号，作为写标志信号
    .key2_flag (key2_flag   ), //按键2消抖后有效信号，作为读标志信号

    .wr_en     (wr_en       ), //输出写RAM使能，高点平有效
    .rd_en     (rd_en       ), //输出读RAM使能，高电平有效
    .addr      (addr        ), //输出读写RAM地址
    .wr_data   (wr_data     )  //输出写RAM数据

);

//----------------key1_filter_inst----------------
key_filter  key1_filter_inst
(
    .sys_clk     (sys_clk   ),   //系统时钟50Mhz
    .sys_rst_n   (sys_rst_n ),   //全局复位
    .key_in      (key[0]    ),   //按键输入信号

    .key_flag    (key1_flag )    //key_flag为1时表示消抖后检测到按键被按下
                                 //key_flag为0时表示没有检测到按键被按下
);

//----------------key2_filter_inst----------------
key_filter  key2_filter_inst
(
    .sys_clk     (sys_clk   ),   //系统时钟50Mhz
    .sys_rst_n   (sys_rst_n ),   //全局复位
    .key_in      (key[1]    ),   //按键输入信号

    .key_flag    (key2_flag )    //key_flag为1时表示消抖后检测到按键被按下
                                 //key_flag为0时表示没有检测到按键被按下
);

//----------------seg_595_dynamic_inst----------------
seg_595_dynamic     seg_595_dynamic_inst
(
    .sys_clk     (sys_clk         ), //系统时钟，频率50MHz
    .sys_rst_n   (sys_rst_n       ), //复位信号，低有效
    .data        ({12'd0,rd_data} ), //数码管要显示的值
    .point       (0               ), //小数点显示,高电平有效
    .seg_en      (1'b1            ), //数码管使能信号，高电平有效
    .sign        (0               ), //符号位，高电平显示负号

    .stcp        (stcp            ), //输出数据存储寄时钟
    .shcp        (shcp            ), //移位寄存器的时钟输入
    .ds          (ds              ), //串行数据输入
    .oe          (oe              )  //输出使能信号

);

//---------------rom_256x8_inst--------------
ram_256x8   ram_256x8_inst 
(
    .aclr       (~sys_rst_n ),  //异步清零信号
    .address    (addr       ),  //读写地址线
    .clock      (sys_clk    ),  //使用系统时钟作为读写时钟
    .data       (wr_data    ),  //输入写入RAM的数据
    .rden       (rd_en      ),  //读RAM使能
    .wren       (wr_en      ),  //写RAM使能
    .q          (rd_data    )   //输出读RAM数据
);

endmodule
