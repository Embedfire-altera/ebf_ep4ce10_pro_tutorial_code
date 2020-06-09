`timescale  1ns/1ns
////////////////////////////////////////////////////////////////////////
// Author        : EmbedFire
// Create Date   : 2018/03/18
// Module Name   : fifo_sum_ctrl
// Project Name  : fifo_sum
// Target Devices: Altera EP4CE10F17C8N
// Tool Versions : Quartus 13.0
// Description   : SUM求和控制模块
// 
// Revision      : V1.0
// Additional Comments:
// 
// 实验平台: 野火_征途Pro_FPGA开发板
// 公司    : http://www.embedfire.com
// 论坛    : http://www.firebbs.cn
// 淘宝    : https://fire-stm32.taobao.com
////////////////////////////////////////////////////////////////////////

module  fifo_sum_ctrl
(
    input   wire          sys_clk     ,   //频率为50MHz
    input   wire          sys_rst_n   ,   //复位信号,低有效
    input   wire  [7:0]   pi_data     ,   //rx传入的数据信号
    input   wire          pi_flag     ,   //rx传入的标志信号

    output  reg   [7:0]   po_sum      ,   //求和运算后的信号
    output  reg           po_flag         //输出数据标志信号
);

//********************************************************************//
//****************** Parameter and Internal Signal *******************//
//********************************************************************//
//parameter define
parameter   CNT_ROW_MAX = 7'd49 ,   //行计数最大值
            CNT_COL_MAX = 7'd49 ;   //列计数最大值

//wire  define
wire  [7:0]   data_out1   ;   //fifo1数据输出
wire  [7:0]   data_out2   ;   //fifo2数据输出

//reg   define 
reg   [6:0]   cnt_row     ;   //行计数
reg   [6:0]   cnt_col     ;   //场计数
reg           wr_en1      ;   //fifo1写使能
reg           wr_en2      ;   //fifo2写使能
reg   [7:0]   data_in1    ;   //fifo1写数据输入  
reg   [7:0]   data_in2    ;   //fifo2写数据输入
reg           rd_en       ;   //fifo1、fifo2共用的读使能
reg           dout_flag   ;   //控制fifo1,2-84行的写使能
reg           po_flag_reg ;   //输出标志位缓存,rd_en延后一拍得到,控制计算po_sum

//********************************************************************//
//***************************** Main Code ****************************//
//********************************************************************//
//cnt_row:行计数器,计数一行数据个数
always@(posedge sys_clk or  negedge sys_rst_n)
begin
    if(sys_rst_n == 1'b0)
        cnt_row <=  7'd0;
    else    if((cnt_row == CNT_ROW_MAX) && (pi_flag == 1'b1))
        cnt_row <=  7'd0;
    else    if(pi_flag == 1'b1)
        cnt_row <=  cnt_row + 1'b1;
end

//cnt_col：列计数器,计数数据行数
always@(posedge sys_clk or  negedge sys_rst_n)
begin
    if(sys_rst_n == 1'b0)
        cnt_col <=  7'd0;
    else    if((cnt_col == CNT_COL_MAX) && (pi_flag == 1'b1) && (cnt_row == CNT_ROW_MAX))
        cnt_col <=  7'd0;
    else    if((cnt_row == CNT_ROW_MAX) && (pi_flag == 1'b1))
        cnt_col <=  cnt_col + 1'b1;
end

//wr_en1：fifo1写使能信号,高电平有效
always@(posedge sys_clk or  negedge sys_rst_n)
begin
    if(sys_rst_n == 1'b0)
        wr_en1  <=  1'b0;
    else    if((cnt_col == 7'd0) && (pi_flag == 1'b1))
        wr_en1  <=  1'b1;          //第0行写入fifo1
    else
        wr_en1  <=  dout_flag;  //2-84行写入fifo1
end

//wr_en2：fifo2写使能信号,高电平有效
always@(posedge sys_clk or  negedge sys_rst_n)
begin
    if(sys_rst_n == 1'b0)
        wr_en2  <=  1'b0;
    else    if((cnt_col >= 7'd1) && (cnt_col <= CNT_COL_MAX - 1'b1) && (pi_flag == 1'b1))
        wr_en2  <=  1'b1;          //2-CNT_COL_MAX行写入fifo2
    else
      wr_en2  <=  1'b0;
end

//data_in1：fifo1数据输入
always@(posedge sys_clk or  negedge sys_rst_n)
begin
    if(sys_rst_n == 1'b0)
        data_in1  <=  8'b0;
    else    if((pi_flag == 1'b1) && (cnt_col == 7'd0))
        data_in1  <=  pi_data;  //第0行数据暂存fifo1中
    else    if(dout_flag == 1'b1)
      data_in1  <=  data_out2;//第2-CNT_COL_MAX-1行时,fifo2读出数据存入fifo1
    else
        data_in1  <=  data_in1;
end

//data_in2：fifo2数据输入
always@(posedge sys_clk or  negedge sys_rst_n)
begin
    if(sys_rst_n == 1'b0)
        data_in2  <=  8'b0;
    else    if((pi_flag == 1'b1)&&(cnt_col >= 7'd1)&&(cnt_col <= (CNT_COL_MAX - 1'b1)))
        data_in2  <=  pi_data;
    else
        data_in2  <=  data_in2;
end

//rd_en：fifo1和fifo2的共用读使能信号
always@(posedge sys_clk or  negedge sys_rst_n)
begin
    if(sys_rst_n == 1'b0)
        rd_en <=  1'b0;
    else    if((pi_flag == 1'b1)&&(cnt_col >= 7'd2)&&(cnt_col <= CNT_COL_MAX))
        rd_en <=  1'b1;
    else
        rd_en <=  1'b0;
end

//dout_flag：控制2-CNT_COL_MAX-1行wr_en1信号
always@(posedge sys_clk or  negedge sys_rst_n)
begin
    if(sys_rst_n == 1'b0)
        dout_flag <=  0;
    else    if((wr_en2 == 1'b1) && (rd_en == 1'b1))
        dout_flag <=  1'b1;
    else
        dout_flag <=  1'b0;
end

//po_flag_reg：输出标志位缓存,延后rd_en一拍,控制po_sum信号
always@(posedge sys_clk or  negedge sys_rst_n)
begin
    if(sys_rst_n == 1'b0)
        po_flag_reg <=  1'b0;
    else    if(rd_en == 1'b1)
        po_flag_reg <=  1'b1;
    else
        po_flag_reg <=  1'b0;
end

//po_flag：输出标志信号,延后输出标志位缓存一拍,与po_sum同步输出
always@(posedge sys_clk or  negedge sys_rst_n)
begin
    if(sys_rst_n == 1'b0)
        po_flag <=  1'b0;
    else
        po_flag <=  po_flag_reg;
end

//po_sum：求和数据输出
always@(posedge sys_clk or  negedge sys_rst_n)
begin
    if(sys_rst_n == 1'b0)
        po_sum  <=  8'b0;
    else    if(po_flag_reg == 1'b1)
        po_sum  <=  data_out1 + data_out2 + pi_data;
    else
        po_sum  <=  po_sum;
end

//********************************************************************//
//*************************** Instantiation **************************//
//********************************************************************//

//------------- fifo_data_inst1 --------------
fifo_data   fifo_data_inst1
(
    .clock  (sys_clk    ),  //input clock
    .data   (data_in1   ),  //input [7:0] data
    .wrreq  (wr_en1     ),  //input wrreq
    .rdreq  (rd_en      ),  //input rdreq

    .q      (data_out1  )   //output [7:0] q
);

//------------- fifo_data_inst2 --------------
fifo_data   fifo_data_inst2
(
    .clock  (sys_clk    ),  //input clock
    .data   (data_in2   ),  //input [7:0] data
    .wrreq  (wr_en2     ),  //input wrreq
    .rdreq  (rd_en      ),  //input rdreq

    .q      (data_out2  )   //output [7:0] q
);

endmodule
