`timescale  1ns/1ns
////////////////////////////////////////////////////////////////////////
// Author        : EmbedFire
// Create Date   : 2019/11/18
// Module Name   : pingpang
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

module  pingpang
(
    input   wire    sys_clk     ,   //系统时钟，频率50MHz
    input   wire    sys_rst_n       //复位信号，低有效

);

//********************************************************************//
//******************** Parameter And Internal Signal *****************//
//********************************************************************//

//wire  define
wire            clk_50m      ;   //50MHz时钟
wire            clk_25m      ;   //100MHz时钟
wire            rst_n        ;   //复位信号
wire    [15:0]  ram1_rd_data ;   //ram1读数据
wire    [15:0]  ram2_rd_data ;   //ram2读数据
wire            data_en      ;   //输入数据使能信号
wire    [7:0]   data_in      ;   //输入数据
wire            ram1_wr_en   ;   //ram1写使能
wire            ram1_rd_en   ;   //ram1读使能
wire    [6:0]   ram1_wr_addr ;   //ram1写地址
wire    [5:0]   ram1_rd_addr ;   //ram1写地址
wire    [7:0]   ram1_wr_data ;   //ram1写数据
wire            ram2_wr_en   ;   //ram2写使能
wire            ram2_rd_en   ;   //ram2读使能
wire    [6:0]   ram2_wr_addr ;   //ram2写地址
wire    [5:0]   ram2_rd_addr ;   //ram2写地址
wire    [7:0]   ram2_wr_data ;   //ram2写数据
wire    [15:0]  data_out     ;   //输出乒乓操作数据
wire            locked       ;   //PLl核输出稳定时钟标志信号，高有效

//时钟不稳定时视为复位
assign  rst_n   =   sys_rst_n   &   locked;

//********************************************************************//
//*************************** Instantiation **************************//
//********************************************************************//

//----------- ram_ctrl_inst -----------
ram_ctrl    ram_ctrl_inst
(
    .clk_50m     (clk_50m       ),   //写ram时钟，50MHz
    .clk_25m     (clk_25m       ),   //读ram时钟，25MHz
    .rst_n       (rst_n         ),   //复位信号，低有效
    .ram1_rd_data(ram1_rd_data  ),   //ram1读数据
    .ram2_rd_data(ram2_rd_data  ),   //ram2读数据
    .data_en     (data_en       ),   //输入数据使能信号
    .data_in     (data_in       ),   //输入数据

    .ram1_wr_en  (ram1_wr_en    ),   //ram1写使能
    .ram1_rd_en  (ram1_rd_en    ),   //ram1读使能
    .ram1_wr_addr(ram1_wr_addr  ),   //ram1读写地址
    .ram1_rd_addr(ram1_rd_addr  ),   //ram1读地址
    .ram1_wr_data(ram1_wr_data  ),   //ram1写数据
    .ram2_wr_en  (ram2_wr_en    ),   //ram2写使能
    .ram2_rd_en  (ram2_rd_en    ),   //ram2读使能
    .ram2_wr_addr(ram2_wr_addr  ),   //ram2写地址
    .ram2_rd_addr(ram2_rd_addr  ),   //ram2读地址
    .ram2_wr_data(ram2_wr_data  ),   //ram2写数据
    .data_out    (data_out      )    //输出乒乓操作数据

);

//----------- data_gen_inst -----------
data_gen    data_gen_inst
(
    .clk_50m     (clk_50m   ),   //模块时钟，频率50MHz
    .rst_n       (rst_n     ),   //复位信号，低电平有效
    
    .data_en     (data_en   ),   //数据使能信号，高电平有效
    .data_in     (data_in   )    //输出数据

);

//----------- clk_gen_inst -----------
clk_gen     clk_gen_inst
(
    .areset (~sys_rst_n ),  //异步复位
    .inclk0 (sys_clk    ),  //输入时钟

    .c0     (clk_50m    ),  //输出时钟，频率50MHz
    .c1     (clk_25m    ),  //输出时钟，频率25MHz
    .locked (locked     )   //时钟稳定输出标志信号
    
);

//------------ dq_ram1-------------
dp_ram  dp_ram1
(
    .data       (ram1_wr_data   ),
    .rdaddress  (ram1_rd_addr   ),
    .rdclock    (clk_25m        ),
    .rden       (ram1_rd_en     ),
    .wraddress  (ram1_wr_addr   ),
    .wrclock    (clk_50m        ),
    .wren       (ram1_wr_en     ),
    
    .q          (ram1_rd_data   )

);

//------------ dq_ram2-------------
dp_ram  dp_ram2
(
    .data       (ram2_wr_data   ),
    .rdaddress  (ram2_rd_addr   ),
    .rdclock    (clk_25m        ),
    .rden       (ram2_rd_en     ),
    .wraddress  (ram2_wr_addr   ),
    .wrclock    (clk_50m        ),
    .wren       (ram2_wr_en     ),
    
    .q          (ram2_rd_data   )

);
endmodule
