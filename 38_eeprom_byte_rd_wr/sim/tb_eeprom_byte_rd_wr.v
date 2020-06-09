`timescale  1ns/1ns
////////////////////////////////////////////////////////////////////////
// Author        : EmbedFire
// Create Date   : 2019/04/01
// Module Name   : tb_eeprom_byte_rd_wr
// Project Name  : eeprom_byte_rd_wr
// Target Devices: Altera EP4CE10F17C8N
// Tool Versions : Quartus 13.0
// Description   : eeprom_byte_rd_wr顶层仿真文件
// 
// Revision      : V1.0
// Additional Comments:
// 
// 实验平台: 野火_征途Pro_FPGA开发板
// 公司    : http://www.embedfire.com
// 论坛    : http://www.firebbs.cn
// 淘宝    : https://fire-stm32.taobao.com
////////////////////////////////////////////////////////////////////////

module  tb_eeprom_byte_rd_wr();
//wire define
wire            scl ;
wire            sda ;
wire            stcp;
wire            shcp;
wire            ds  ;
wire            oe  ;

//reg define
reg           clk   ;
reg           rst_n ;
reg           key_wr;
reg           key_rd;

//时钟、复位信号
initial
  begin
    clk     =   1'b1  ;
    rst_n   <=  1'b0  ;
    key_wr  <=  1'b1  ;
    key_rd  <=  1'b1  ;
    #200
    rst_n   <=  1'b1  ;
    #1000
    key_wr  <=  1'b0  ;
    key_rd  <=  1'b1  ;
    #400
    key_wr  <=  1'b1  ;
    key_rd  <=  1'b1  ;
    #20000000
    key_wr  <=  1'b1  ;
    key_rd  <=  1'b0  ;
    #400
    key_wr  <=  1'b1  ;
    key_rd  <=  1'b1  ;
    #40000000
    $stop;
  end

always  #10 clk = ~clk;

defparam eeprom_byte_rd_wr_inst.key_wr_inst.MAX_20MS = 5;
defparam eeprom_byte_rd_wr_inst.key_rd_inst.MAX_20MS = 5;
defparam eeprom_byte_rd_wr_inst.i2c_rw_data_inst.CNT_WAIT_MAX = 1000;

//-------------eeprom_byte_rd_wr_inst-------------
eeprom_byte_rd_wr   eeprom_byte_rd_wr_inst
(
    .sys_clk        (clk    ),    //输入工作时钟,频率50MHz
    .sys_rst_n      (rst_n  ),    //输入复位信号,低电平有效
    .key_wr         (key_wr ),    //按键写
    .key_rd         (key_rd ),    //按键读

    .sda            (sda    ),    //串行数据
    .scl            (scl    ),    //串行时钟
    .stcp           (stcp   ),   //输出数据存储寄时钟
    .shcp           (shcp   ),   //移位寄存器的时钟输入
    .ds             (ds     ),   //串行数据输入
    .oe             (oe     )

);

//-------------eeprom_inst-------------
M24LC64  M24lc64_inst
(
    .A0     (1'b0       ),  //器件地址
    .A1     (1'b0       ),  //器件地址
    .A2     (1'b0       ),  //器件地址
    .WP     (1'b0       ),  //写保护信号,高电平有效
    .RESET  (~rst_n     ),  //复位信号,高电平有效

    .SDA    (sda        ),  //串行数据
    .SCL    (scl        )   //串行时钟
);

endmodule
