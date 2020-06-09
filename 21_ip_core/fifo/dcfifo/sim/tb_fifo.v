`timescale  1ns/1ns
/////////////////////////////////////////////////////////////////////////
// Author        : EmbedFire
// Create Date   : 2019/07/10
// Module Name   : tb_fifo
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

module tb_fifo();

//********************************************************************//
//****************** Parameter and Internal Signal *******************//
//********************************************************************//

//reg   define
reg          wrclk          ;
reg  [7:0]   pi_data        ;
reg          pi_flag        ;
reg          rdclk          ;
reg          rdreq          ;
reg          sys_rst_n      ;
reg  [1:0]   cnt_baud       ;
reg          wrfull_reg0    ;
reg          wrfull_reg1    ;

//wire  define
wire            wrempty     ;
wire            wrfull      ;
wire    [7:0]   wrusedw     ;
wire    [15:0]  po_data     ;
wire            rdempty     ;
wire            rdfull      ;
wire    [6:0]   rdusedw     ;

//********************************************************************//
//***************************** Main Code ****************************//
//********************************************************************//

//初始化时钟、复位
initial begin
    wrclk      = 1'b1;
    rdclk      = 1'b1;
    sys_rst_n <= 1'b0;
    #100;
    sys_rst_n <= 1'b1;
end

//wrclk:模拟FIFO的写时钟，每10ns电平翻转一次，周期为20ns，频率为50MHz
always #10 wrclk = ~wrclk;

//rdclk:模拟FIFO的读时钟，每20ns电平翻转一次，周期为40ns，频率为25MHz
always #20 rdclk = ~rdclk;

//cnt_baud:计数从0到3的计数器，用于产生输入数据间的间隔
always@(posedge wrclk or negedge sys_rst_n)
    if(sys_rst_n == 1'b0)
        cnt_baud <= 2'b0;
    else    if(&cnt_baud == 1'b1)
        cnt_baud <= 2'b0;
    else
        cnt_baud <= cnt_baud + 1'b1;

//pi_flag:输入数据有效标志信号，也作为FIFO的写请求信号
always@(posedge wrclk or negedge sys_rst_n)
    if(sys_rst_n == 1'b0)
        pi_flag <= 1'b0;
    //每4个时钟周期且没有读请求时产生一个数据有效标志信号
    else    if((cnt_baud == 2'd0) && (rdreq == 1'b0))
        pi_flag <= 1'b1;
    else
        pi_flag <= 1'b0;

//pi_data:输入顶层模块的数据，要写入到FIFO中的数据
always@(posedge wrclk or negedge sys_rst_n)
    if(sys_rst_n == 1'b0)
        pi_data <= 8'b0;
    ////pi_data的值为0~255依次循环
    else    if((pi_data == 8'd255) && (pi_flag == 1'b1))
        pi_data <= 8'b0;
    else    if(pi_flag  == 1'b1)    //每当pi_flag有效时产生一个数据
        pi_data <= pi_data + 1'b1;

//将同步于rdclk时钟的写满标志信号wrfull在rdclk时钟下打两拍
always@(posedge rdclk or negedge sys_rst_n)
    if(sys_rst_n == 1'b0)   
        begin
            wrfull_reg0 <= 1'b0;
            wrfull_reg1 <= 1'b0;
        end
    else
        begin
            wrfull_reg0 <= wrfull;
            wrfull_reg1 <= wrfull_reg0;
        end

//rdreq:FIFO读请求信号同步于rdclk时钟
always@(posedge rdclk or negedge sys_rst_n)
    if(sys_rst_n == 1'b0)
        rdreq <= 1'b0;
//如果wrfull信号有效就立刻读，则不会看到rd_full信号拉高，
//所以此处使用wrfull在rdclk时钟下打两拍后的信号
    else    if(wrfull_reg1 == 1'b1)
        rdreq <= 1'b1;
    else    if(rdempty == 1'b1)//当FIFO中的数据被读空时停止读取FIFO中的数据
        rdreq <= 1'b0;

//********************************************************************//
//*************************** Instantiation **************************//
//********************************************************************//

//------------------------fifo_inst------------------------
fifo    fifo_inst(
    //FIFO写端
    .wrclk  (wrclk  ),  //input             wclk
    .pi_data(pi_data),  //input     [7:0]   pi_data
    .pi_flag(pi_flag),  //input             pi_flag
    //FIFO读端
    .rdclk  (rdclk  ),  //input             rdclk
    .rdreq  (rdreq  ),  //input             rdreq

    //FIFO写端
    .wrempty(wrempty),  //output            wrempty
    .wrfull (wrfull ),  //output            wrfull
    .wrusedw(wrusedw),  //output    [7:0]   wrusedw
    //FIFO读端
    .po_data(po_data),  //output    [15:0]  po_data
    .rdempty(rdempty),  //output            rdempty
    .rdfull (rdfull ),  //output            rdfull
    .rdusedw(rdusedw)   //output    [6:0]   rdusedw
);

endmodule
