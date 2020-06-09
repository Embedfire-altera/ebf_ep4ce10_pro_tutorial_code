`timescale  1ns/1ns
////////////////////////////////////////////////////////////////////////
// Author        : EmbedFire
//Create Date    : 2019/09/05
// Module Name   : tb_data_rd_ctrl
// Project Name  : sd_vga_pic
// Target Devices: Altera EP4CE10F17C8N
// Tool Versions : Quartus 13.0
// Description   : SDRAM初始化模块仿真
//
// Revision      : V1.0
// Additional Comments:
// 
// 实验平台: 野火_征途Pro_FPGA开发板
// 公司    : http://www.embedfire.com
// 论坛    : http://www.firebbs.cn
// 淘宝    : https://fire-stm32.taobao.com
////////////////////////////////////////////////////////////////////////

module  tb_data_rd_ctrl();

//********************************************************************//
//****************** Internal Signal and Defparam ********************//
//********************************************************************//
//wire define
wire            rd_en           ;   //数据读使能信号
wire    [31:0]  rd_addr         ;   //读数据扇区地址

//reg define    
reg             sys_clk         ;   //系统时钟
reg             sys_rst_n       ;   //复位信号
reg             cnt_en          ;   //计数器计数使能
reg     [8:0]   cnt             ;   //计数器
reg             rd_busy         ;   //模拟读忙信号

//defparam
//重定义模块中的相关参数
defparam data_rd_ctrl_inst.RD_NUM   = 20    ;  //单张图片读取次数
defparam data_rd_ctrl_inst.WAIT_MAX = 3000  ;  //图片切换时间间隔计数最大值

//********************************************************************//
//**************************** Clk And Rst ***************************//
//********************************************************************//

//时钟、复位信号
initial
  begin
    sys_clk     =   1'b1  ;
    sys_rst_n   <=  1'b0  ;
    #200
    sys_rst_n   <=  1'b1  ;
  end

always  #10 sys_clk = ~sys_clk;

//cnt_en:计数器计数使能
always@(posedge sys_clk or negedge sys_rst_n)
    if(sys_rst_n == 1'b0)
        cnt_en  <=  1'b0;
    else    if(cnt == 9'd511)
        cnt_en  <=  1'b0;
    else    if(rd_en == 1'b1)
        cnt_en  <=  1'b1;
    else
        cnt_en  <=  cnt_en;


//cnt:计数器,约束读忙信号rd_busy
always@(posedge sys_clk or negedge sys_rst_n)
    if(sys_rst_n == 1'b0)
        cnt <=  9'd0;
    else    if(cnt_en == 1'b1)
        cnt <=  cnt + 1'b1;
    else
        cnt <=  9'd0;

//rd_busy:模拟读忙信号
always@(posedge sys_clk or negedge sys_rst_n)
    if(sys_rst_n == 1'b0)
        rd_busy <=  1'b0;
    else    if(cnt <= 9'd60)
        rd_busy <=  1'b0;
    else
        rd_busy <=  1'b1;

//********************************************************************//
//*************************** Instantiation **************************//
//********************************************************************//
//------------- data_rd_ctrl_inst -------------
data_rd_ctrl    data_rd_ctrl_inst
(
    .sys_clk    (sys_clk    ),   //输入工作时钟,频率50MHz
    .sys_rst_n  (sys_rst_n  ),   //输入复位信号,低电平有效
    .rd_busy    (rd_busy    ),   //读操作忙信号

    .rd_en      (rd_en      ),   //数据读使能信号
    .rd_addr    (rd_addr    )    //读数据扇区地址
);

endmodule