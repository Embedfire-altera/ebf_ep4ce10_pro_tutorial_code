`timescale  1ns/1ns
/////////////////////////////////////////////////////////////////////////
// Author        : EmbedFire
// Create Date   : 2019/07/10
// Module Name   : fifo
// Project Name  : fifo
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

module fifo
(
    //如果端口信号较多，我们可以将端口信号进行分组
    //把相关的信号放在一起，使代码更加清晰
    //FIFO写端
    input   wire         wrclk     ,   //同步于FIFO写数据的时钟50MHz
    input   wire  [7:0]  pi_data   ,   //输入顶层模块的数据，要写入到FIFO中
                                       //的数据同步于wrclk时钟
    input   wire         pi_flag   ,   //输入数据有效标志信号，也作为FIFO的
                                       //写请求信号，同步于wrclk时钟
    //FIFO读端
    input   wire         rdclk     ,   //同步于FIFO读数据的时钟25MHz
    input   wire         rdreq     ,   //FIFO读请求信号，同步于rdclk时钟

    //FIFO写端
    output  wire         wrempty   ,   //FIFO写端口空标志信号，高有效，
                                       //同步于wrclk时钟
    output  wire         wrfull    ,   //FIFO写端口满标志信号，高有效，
                                       //同步于wrclk时钟
    output  wire  [7:0]  wrusedw   ,   //FIFO写端口中存在的数据个数，
                                       //同步于wrclk时钟
    //FIFO读端
    output  wire  [15:0] po_data   ,   //FIFO读出的数据，同步于rdclk时钟
    output  wire         rdempty   ,   //FIFO读端口空标志信号，高有效，
                                       //同步于rdclk时钟
    output  wire         rdfull    ,   //FIFO读端口满标志信号，高有效，
                                       //同步于rdclk时钟
    output  wire  [6:0]  rdusedw       //FIFO读端口中存在的数据个数，
                                       //同步于rdclk时钟
);

//----------------------dcfifo_256x8to128x16_inst-----------------------
dcfifo_256x8to128x16    dcfifo_256x8to128x16_inst
(
    .data   (pi_data),  //input     [7:0]   data
    .rdclk  (rdclk  ),  //input             rdclk
    .rdreq  (rdreq  ),  //input             rdreq
    .wrclk  (wrclk  ),  //input             wrclk
    .wrreq  (pi_flag),  //input             wrreq

    .q      (po_data),  //output    [15:0]  q
    .rdempty(rdempty),  //output            rdempty
    .rdfull (rdfull ),  //output            rdfull
    .rdusedw(rdusedw),  //output    [6:0]   rdusedw
    .wrempty(wrempty),  //output            wrempty
    .wrfull (wrfull ),  //output            wrfull
    .wrusedw(wrusedw)   //output    [7:0]   wrusedw
);

endmodule
