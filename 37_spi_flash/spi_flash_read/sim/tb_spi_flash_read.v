`timescale  1ns/1ns
////////////////////////////////////////////////////////////////////////
// Author        : EmbedFire
// Create Date   : 2019/03/27
// Module Name   : tb_spi_flash_read
// Project Name  : spi_flash_read
// Target Devices: Altera EP4CE10F17C8N
// Tool Versions : Quartus 13.0
// Description   : flash读顶层仿真文件
//
// Revision      : V1.0
// Additional Comments:
// 
// 实验平台: 野火_征途Pro_FPGA开发板
// 公司    : http://www.embedfire.com
// 论坛    : http://www.firebbs.cn
// 淘宝    : https://fire-stm32.taobao.com
////////////////////////////////////////////////////////////////////////

module  tb_spi_flash_read();

//wire  define
wire    cs_n;
wire    sck ;
wire    mosi;
wire    miso;
wire    tx  ;

//reg   define
reg     clk     ;
reg     rst_n   ;
reg     key     ;

//时钟、复位信号、模拟按键信号
initial
    begin
        clk =   0;
        rst_n   <=  0;
        key <=  0;
        #100
        rst_n   <=  1;
        #1000
        key <=  1;
        #20
        key <=  0;
    end

always  #10 clk <=  ~clk;

defparam memory.mem_access.initfile = "initM25P16_test.txt";
defparam spi_flash_read_inst.flash_read_ctrl_inst.CNT_WAIT_MAX = 1000;
defparam spi_flash_read_inst.uart_tx_inst.BAUD_CNT_END = 10;
//------------- spi_flash_read -------------
spi_flash_read    spi_flash_read_inst(
    .sys_clk    (clk    ),  //input     sys_clk
    .sys_rst_n  (rst_n  ),  //input     sys_rst
    .pi_key     (key    ),  //input     key
    .miso       (miso   ),

    .sck        (sck    ),  //output    sck
    .cs_n       (cs_n   ),  //output    cs_n
    .mosi       (mosi   ),  //output    mosi
    .tx         (tx     )

);

//------------- memory -------------
m25p16  memory (
    .c          (sck    ), 
    .data_in    (mosi   ), 
    .s          (cs_n   ), 
    .w          (1'b1   ), 
    .hold       (1'b1   ), 
    .data_out   (miso   )
);

endmodule
