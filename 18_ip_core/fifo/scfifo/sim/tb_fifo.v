`timescale  1ns/1ns
/////////////////////////////////////////////////////////////////////////
// Author        : EmbedFire
// Create Date   : 2019/07/10
// Module Name   : tb_fifo
// Project Name  : tb_fifo
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

module tb_fifo();

//********************************************************************//
//****************** Parameter and Internal Signal *******************//
//********************************************************************//

//reg   define
reg         sys_clk     ;
reg [7:0]   pi_data     ;
reg         pi_flag     ;
reg         rdreq       ;
reg         sys_rst_n   ;
reg [1:0]   cnt_baud    ;

//wire  define
wire    [7:0]   po_data ;
wire            empty   ;
wire            full    ;
wire    [7:0]   usedw   ;

//********************************************************************//
//***************************** Main Code ****************************//
//********************************************************************//

//初始化系统时钟、复位
initial begin
    sys_clk    = 1'b1;
    sys_rst_n <= 1'b0;
    #100;
    sys_rst_n <= 1'b1;
end

//sys_clk:模拟系统时钟，每10ns电平翻转一次，周期为20ns，频率为50Mhz
always #10 sys_clk = ~sys_clk;

//cnt_baud:计数从0到3的计数器，用于产生输入数据间的间隔
always@(posedge sys_clk or negedge sys_rst_n)
    if(sys_rst_n == 1'b0)
        cnt_baud <= 2'b0;
    else    if(&cnt_baud == 1'b1)
        cnt_baud <= 2'b0;
    else
        cnt_baud <= cnt_baud + 1'b1;

//pi_flag:输入数据有效标志信号，也作为FIFO的写请求信号
always@(posedge sys_clk or negedge sys_rst_n)
    if(sys_rst_n == 1'b0)
        pi_flag <= 1'b0;
    //每4个时钟周期且没有读请求时产生一个数据有效标志信号
    else    if((cnt_baud == 2'd0) && (rdreq == 1'b0))
        pi_flag <= 1'b1;
    else
        pi_flag <= 1'b0;

//pi_data:输入顶层模块的数据，要写入到FIFO中的数据
always@(posedge sys_clk or negedge sys_rst_n)
    if(sys_rst_n == 1'b0)
        pi_data <= 8'b0;
    //pi_data的值为0~255依次循环
    else    if((pi_data == 8'd255) && (pi_flag == 1'b1))
        pi_data <= 8'b0;
    else    if(pi_flag  == 1'b1)    //每当pi_flag有效时产生一个数据
        pi_data <= pi_data + 1'b1;

//rdreq:FIFO读请求信号
always@(posedge sys_clk or negedge sys_rst_n)
    if(sys_rst_n == 1'b0)
        rdreq <= 1'b0;
    else    if(full == 1'b1)  //当FIFO中的数据存满时，开始读取FIFO中的数据
        rdreq <= 1'b1;
    else    if(empty == 1'b1) //当FIFO中的数据被读空时停止读取FIFO中的数据
        rdreq <= 1'b0;

//********************************************************************//
//*************************** Instantiation **************************//
//********************************************************************//

//------------------------fifo_inst------------------------
fifo fifo_inst(
    .sys_clk    (sys_clk    ),  //input             sys_clk
    .pi_data    (pi_data    ),  //input     [7:0]   pi_data
    .pi_flag    (pi_flag    ),  //input             pi_flag
    .rdreq      (rdreq      ),  //input             rdreq

    .po_data    (po_data    ),  //output    [7:0]   po_data
    .empty      (empty      ),  //output            empty
    .full       (full       ),  //output            full
    .usedw      (usedw      )   //output    [7:0]   usedw
);

endmodule

