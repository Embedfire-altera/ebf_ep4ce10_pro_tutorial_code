`timescale  1ns/1ns
////////////////////////////////////////////////////////////////////////
// Author        : EmbedFire
// Create Date   : 2019/03/18
// Module Name   : sobel_ctrl
// Project Name  : sobel
// Target Devices: Altera EP4CE10F17C8N
// Tool Versions : Quartus 13.0
// Description   : 数据求和模块
// 
// Revision      : V1.0
// Additional Comments:
// 
// 实验平台: 野火_征途Pro_FPGA开发板
// 公司    : http://www.embedfire.com
// 论坛    : http://www.firebbs.cn
// 淘宝    : https://fire-stm32.taobao.com
////////////////////////////////////////////////////////////////////////

module  sobel_ctrl
(
    input   wire            sys_clk     ,   //输入系统时钟,频率50MHz
    input   wire            sys_rst_n   ,   //复位信号,低有效
    input   wire    [7:0]   pi_data     ,   //rx传入的数据信号
    input   wire            pi_flag     ,   //rx传入的标志信号

    output  reg     [7:0]   po_data     ,   //fifo加法运算后的信号
    output  reg             po_flag         //输出标志信号
);

//********************************************************************//
//****************** Parameter and Internal Signal *******************//
//********************************************************************//
//parameter define
parameter   LENGTH_P    =   10'd100         ,   //图片长度
            WIDE_P      =   10'd100         ;   //图片宽度
parameter   THRESHOLD   =   8'b000_011_00   ;   //比较阈值
parameter   BLACK       =   8'b0000_0000    ,   //黑色
            WHITE       =   8'b1111_1111    ;   //白色

//wire  define
wire    [7:0]   data_out1   ;   //fifo1数据输出
wire    [7:0]   data_out2   ;   //fifo2数据输出

//reg   define
reg     [7:0]   cnt_h       ;   //行计数
reg     [7:0]   cnt_v       ;   //场计数
reg     [7:0]   pi_data_dly ;   //pi_data数据寄存
reg             wr_en1      ;   //fifo1写使能
reg             wr_en2      ;   //fifo2写使能
reg     [7:0]   data_in1    ;   //fifo1写数据
reg     [7:0]   data_in2    ;   //fifo2写数据
reg             rd_en       ;   //fifo1,fifo2共用读使能
reg     [7:0]   data_out1_dly   ;   //fifo1数据输出寄存
reg     [7:0]   data_out2_dly   ;   //fifo2数据输出寄存
reg             dout_flag   ;   //使能信号
reg             rd_en_dly1  ;   //输出数据标志信号,延后rd_en一拍
reg             rd_en_dly2  ;   //a,b,c赋值标志信号
reg             gx_gy_flag  ;   //gx,gy计算标志信号
reg             gxy_flag    ;   //gxy计算标志信号
reg             compare_flag;   //阈值比较标志信号
reg     [7:0]   cnt_rd      ;   //读出数据计数器
reg     [7:0]   a1          ;
reg     [7:0]   a2          ;
reg     [7:0]   a3          ;
reg     [7:0]   b1          ;
reg     [7:0]   b2          ;
reg     [7:0]   b3          ;
reg     [7:0]   c1          ;
reg     [7:0]   c2          ;
reg     [7:0]   c3          ;   //图像数据
reg     [8:0]   gx          ;
reg     [8:0]   gy          ;   //gx,gy
reg     [7:0]   gxy         ;   //gxy

//********************************************************************//
//***************************** Main Code ****************************//
//********************************************************************//
//cnt_h：行数据个数计数器
always@(posedge sys_clk or  negedge sys_rst_n)
    if(sys_rst_n == 1'b0)
        cnt_h   <=  8'd0;
    else    if((cnt_h == (LENGTH_P - 1'b1)) && (pi_flag == 1'b1))
        cnt_h   <=  8'd0;
    else    if(pi_flag == 1'b1)
        cnt_h   <=  cnt_h + 1'b1;

//cnt_v：场计数器
always@(posedge sys_clk or  negedge sys_rst_n)
    if(sys_rst_n == 1'b0)
        cnt_v   <=  8'd0;
    else    if((cnt_v == (WIDE_P - 1'b1)) && (pi_flag == 1'b1)
            && (cnt_h == (LENGTH_P - 1'b1)))
        cnt_v   <=  8'd0;
    else    if((cnt_h == (LENGTH_P - 1'b1)) && (pi_flag == 1'b1))
        cnt_v   <=  cnt_v + 1'b1;

//cnt_rd：fifo数据读出个数计数,用来判断何时对gx,gy进行运算
always@(posedge sys_clk or  negedge sys_rst_n)
    if(sys_rst_n == 1'b0)
        cnt_rd   <=  8'd0;
    else    if((cnt_rd == (LENGTH_P - 1'b1)) && (rd_en == 1'b1))
        cnt_rd   <=  8'd0;
    else    if(rd_en == 1'b1)
        cnt_rd   <=  cnt_rd + 1'b1;

//wr_en1：fifo1写使能,高电平有效
always@(posedge sys_clk or  negedge sys_rst_n)
    if(sys_rst_n == 1'b0)
        wr_en1  <=  1'b0;
    else    if((cnt_v == 8'd0) && (pi_flag == 1'b1))
        wr_en1  <=  1'b1;      //第0行写入fifo1
    else
        wr_en1  <=  dout_flag;  //2-198行写入fifo1

//wr_en2,fifo2的写使能,高电平有效
always@(posedge sys_clk or  negedge sys_rst_n)
    if(sys_rst_n == 1'b0)
        wr_en2  <=  1'b0;
    else    if((cnt_v >= 8'd1)&&(cnt_v <= ((WIDE_P - 1'b1) - 1'b1))
            && (pi_flag == 1'b1))
        wr_en2  <=  1'b1;      //2-199行写入fifo2
    else
        wr_en2  <=  1'b0;

//data_in1：fifo1的数据写入
always@(posedge sys_clk or  negedge sys_rst_n)
    if(sys_rst_n == 1'b0)
        data_in1    <=  8'b0;
    else    if((pi_flag == 1'b1) && (cnt_v == 8'b0))
        data_in1    <=  pi_data;
    else    if(dout_flag == 1'b1)
        data_in1    <=  data_out2;
    else
        data_in1    <=  data_in1;

//data_in2：fifo2的数据写入
always@(posedge sys_clk or  negedge sys_rst_n)
    if(sys_rst_n == 1'b0)
        data_in2    <=  8'b0;
    else    if((pi_flag == 1'b1) && (cnt_v >= 8'd1)
            && (cnt_v <= ((WIDE_P - 1'b1) - 1'b1)))
        data_in2    <=  pi_data;
    else
        data_in2    <=  data_in2;

//rd_en：fifo1和fifo2的共用读使能,高电平有效
always@(posedge sys_clk or  negedge sys_rst_n)
    if(sys_rst_n == 1'b0)
        rd_en   <=  1'b0;
    else    if((pi_flag == 1'b1) && (cnt_v >= 8'd2)
            && (cnt_v <= (WIDE_P - 1'b1)))
        rd_en   <=  1'b1;  
    else
        rd_en   <=  1'b0;


//dout_flag：控制fifo1写使能wr_en1
always@(posedge sys_clk or  negedge sys_rst_n)
    if(sys_rst_n == 1'b0)
        dout_flag   <=  1'b0;
    else    if((wr_en2 == 1'b1) && (rd_en == 1'b1))
        dout_flag   <=  1'b1;
    else
        dout_flag   <=  1'b0;

//rd_en_dly1：输出数据标志信号
always@(posedge sys_clk or  negedge sys_rst_n)
    if(sys_rst_n == 1'b0)
        rd_en_dly1  <=  1'b0;
    else    if(rd_en == 1'b1)
        rd_en_dly1  <=  1'b1;
    else
        rd_en_dly1  <=  1'b0;

//data_out1_dly：data_out1数据寄存
always@(posedge sys_clk or  negedge sys_rst_n)
    if(sys_rst_n == 1'b0)
        data_out1_dly   <=  8'b0;
    else    if(rd_en_dly1 == 1'b1)
        data_out1_dly   <=  data_out1;

//data_out2_dly：data_out2数据寄存
always@(posedge sys_clk or  negedge sys_rst_n)
    if(sys_rst_n == 1'b0)
        data_out2_dly   <=  8'b0;
    else    if(rd_en_dly1 == 1'b1)
        data_out2_dly   <=  data_out2;

//pi_data_dly：输入数据pi_data寄存
always@(posedge sys_clk or  negedge sys_rst_n)
    if(sys_rst_n == 1'b0)
        pi_data_dly <=  8'b0;
    else    if(rd_en_dly1 == 1'b1)
        pi_data_dly <=  pi_data;

//rd_en_dly2：a,b,c赋值标志信号
always@(posedge sys_clk or  negedge sys_rst_n)
    if(sys_rst_n == 1'b0)
        rd_en_dly2  <=  1'b0;
    else    if(rd_en_dly1 == 1'b1)
        rd_en_dly2  <=  1'b1;
    else
        rd_en_dly2  <=  1'b0;

//gx_gy_flag：gx,gy计算标志信号
always@(posedge sys_clk or  negedge sys_rst_n)
    if(sys_rst_n == 1'b0)
        gx_gy_flag  <=  1'b0;
    else    if((rd_en_dly2 == 1'b1) && ((cnt_rd >= 8'd3) || (cnt_rd == 8'd0)))
        gx_gy_flag  <=  1'b1;
    else
        gx_gy_flag  <=  1'b0;

//gxy_flag：gxy计算标准信号
always@(posedge sys_clk or  negedge sys_rst_n)
    if(sys_rst_n == 1'b0)
        gxy_flag    <=  1'b0;
    else    if(gx_gy_flag == 1'b1)
        gxy_flag    <=  1'b1;
    else
        gxy_flag    <=  1'b0;

//compare_flag,阈值比较标志信号
always@(posedge sys_clk or  negedge sys_rst_n)
    if(sys_rst_n == 1'b0)
        compare_flag    <=  1'b0;
    else    if(gxy_flag == 1'b1)
        compare_flag    <=  1'b1;
    else
        compare_flag    <=  1'b0;

//a,b,c赋值
always@(posedge sys_clk or  negedge sys_rst_n)
    if(sys_rst_n == 1'b0)
    begin
        a1  <=  8'd0;
        a2  <=  8'd0;
        a3  <=  8'd0;
        b1  <=  8'd0;
        b2  <=  8'd0;
        b3  <=  8'd0;
        c1  <=  8'd0;
        c2  <=  8'd0;
        c3  <=  8'd0;
    end
    else    if(rd_en_dly2==1)
    begin
        a1  <=  data_out1_dly;
        b1  <=  data_out2_dly;
        c1  <=  pi_data_dly;
        a2  <=  a1;
        b2  <=  b1;
        c2  <=  c1;
        a3  <=  a2;
        b3  <=  b2;
        c3  <=  c2;
    end

//gx：计算gx
always@(posedge sys_clk or  negedge sys_rst_n)
    if(sys_rst_n == 1'b0)
        gx  <=  9'd0;
    else    if(gx_gy_flag == 1'b1)
        gx  <=  a3 - a1 + ((b3 - b1) << 1) + c3 - c1;
    else
        gx  <=  gx;

//gy：计算gy
always@(posedge sys_clk or  negedge sys_rst_n)
    if(sys_rst_n == 1'b0)
        gy  <=  9'd0;
    else    if(gx_gy_flag == 1'b1)
        gy  <=  a1 - c1 + ((a2 - c2) << 1) + a3 - c3;
    else
        gy  <=  gy;

//gxy：gxy计算
always@(posedge sys_clk or  negedge sys_rst_n)
    if(sys_rst_n == 1'b0)
        gxy <=  0;
    else    if((gx[8] == 1'b1) && (gy[8] == 1'b1) && (gxy_flag == 1'b1))
        gxy <=  (~gx[7:0] + 1'b1) + (~gy[7:0] + 1'b1);
    else    if((gx[8] == 1'b1) && (gy[8] == 1'b0) && (gxy_flag == 1'b1))
        gxy <=  (~gx[7:0] + 1'b1) + (gy[7:0]);
    else    if((gx[8] == 1'b0) && (gy[8] == 1'b1) && (gxy_flag == 1'b1))
        gxy <=  (gx[7:0]) + (~gy[7:0] + 1'b1);
    else    if((gx[8] == 1'b0) && (gy[8] == 1'b0) && (gxy_flag == 1'b1))
        gxy <=  (gx[7:0]) + (gy[7:0]);

//po_data：通过gxy与阈值比较,赋值po_data
always@(posedge sys_clk or  negedge sys_rst_n)
    if(sys_rst_n == 1'b0)
        po_data <=  8'b0;
    else    if((gxy >= THRESHOLD) && (compare_flag == 1'b1))
        po_data <=  BLACK;
    else    if(compare_flag == 1'b1)
        po_data <=  WHITE;

//po_flag：输出标志位
always@(posedge sys_clk or  negedge sys_rst_n)
    if(sys_rst_n == 1'b0)
        po_flag <=  1'b0;
    else    if(compare_flag == 1'b1)
        po_flag <=  1'b1;
    else
        po_flag <=  1'b0;

//********************************************************************//
//*************************** Instantiation **************************//
//********************************************************************//
//-------------fifo_pic_inst1--------------
fifo_pic    fifo_pic_inst1
(
    .clock  (sys_clk    ),  // input sys_clk
    .data   (data_in1   ),  // input [7 : 0] din
    .wrreq  (wr_en1     ),  // input wr_en
    .rdreq  (rd_en      ),  // input rd_en

    .q      (data_out1  )   // output [7 : 0] dout
);

//-------------fifo_pic_inst2--------------
fifo_pic    fifo_pic_inst2
(
    .clock  (sys_clk    ),  // input sys_clk
    .data   (data_in2   ),  // input [7 : 0] din
    .wrreq  (wr_en2     ),  // input wr_en
    .rdreq  (rd_en      ),  // input rd_en

    .q      (data_out2  )   // output [7 : 0] dout
);

endmodule
