`timescale  1ns/1ns
////////////////////////////////////////////////////////////////////////
// Author        : EmbedFire
// Create Date   : 2018/07/10
// Module Name   : seg7_bcd_disp
// Project Name  : rtc
// Target Devices: Altera EP4CE10F17C8N
// Tool Versions : Quartus 13.0
// Description   : 数码管bcd码显示
//
// Revision      : V1.0
// Additional Comments:
// 
// 实验平台: 野火_征途Pro_FPGA开发板
// 公司    : http://www.embedfire.com
// 论坛    : http://www.firebbs.cn
// 淘宝    : https://fire-stm32.taobao.com
////////////////////////////////////////////////////////////////////////

module  seg_bcd_disp
(
    input   wire            sys_clk     , //系统时钟，频率50MHz
    input   wire            sys_rst_n   , //复位信号，低有效
    input   wire    [23:0]  data_bcd    , //数码管要显示的值
    input   wire    [5:0]   point       , //小数点显示,高电平有效
    input   wire            seg_en      , //数码管使能信号，高电平有效
    input   wire            sign        , //符号位，高电平显示负号

    output  reg     [5:0]   sel         , //数码管位选信号
    output  reg     [7:0]   seg           //数码管段选信号
);

//********************************************************************//
//****************** Parameter and Internal Signal *******************//
//********************************************************************//

//parameter define
parameter   CNT_MAX =   16'd49_999;  //数码管刷新时间计数最大值

//reg   define
reg     [15:0]  cnt_1ms     ;   //1ms计数器
reg             flag_1ms    ;   //1ms标志信号
reg     [2:0]   cnt_sel     ;   //数码管位选计数器
reg     [5:0]   sel_reg     ;   //位选信号
reg     [3:0]   data_disp   ;   //当前数码管显示的数据
reg             dot_disp    ;   //当前数码管显示的小数点

//********************************************************************//
//***************************** Main Code ****************************//
//********************************************************************//

//cnt_1ms:1ms循环计数
always@(posedge sys_clk or negedge sys_rst_n)
    if(sys_rst_n == 1'b0)
        cnt_1ms <=  16'd0;
    else    if(cnt_1ms == CNT_MAX)
        cnt_1ms <=  16'd0;
    else
        cnt_1ms <=  cnt_1ms + 1'b1;

//flag_1ms:1ms标志信号
always@(posedge sys_clk or negedge sys_rst_n)
    if(sys_rst_n == 1'b0)
        flag_1ms    <=  1'b0;
    else    if(cnt_1ms == CNT_MAX - 1'b1)
        flag_1ms    <=  1'b1;
    else
        flag_1ms    <=  1'b0;

//cnt_sel：从0到5循环数，用于选择当前显示的数码管
always@(posedge sys_clk or negedge sys_rst_n)
    if(sys_rst_n == 1'b0)
        cnt_sel <=  3'd0;
    else    if((cnt_sel == 3'd5) && (flag_1ms == 1'b1))
        cnt_sel <=  3'd0;
    else    if(flag_1ms == 1'b1)
        cnt_sel <=  cnt_sel + 1'b1;
    else
        cnt_sel <=  cnt_sel;

//数码管位选信号寄存器
always@(posedge sys_clk or negedge sys_rst_n)
    if(sys_rst_n == 1'b0)
        sel_reg <=  6'b000_000;
    else    if((cnt_sel == 3'd0) && (flag_1ms == 1'b1))
        sel_reg <=  6'b000_001;
    else    if(flag_1ms == 1'b1)
        sel_reg <=  sel_reg << 1;
    else
        sel_reg <=  sel_reg;

//控制数码管的位选信号，使六个数码管轮流显示
always@(posedge sys_clk or  negedge sys_rst_n)
    if(sys_rst_n == 1'b0)
        data_disp    <=  4'b0;
    else    if((seg_en == 1'b1) && (flag_1ms == 1'b1))
        case(cnt_sel)
        3'd0:   data_disp    <=  data_bcd[3:0]  ;  //给第1个数码管赋个位值
        3'd1:   data_disp    <=  data_bcd[7:4]  ;  //给第2个数码管赋十位值
        3'd2:   data_disp    <=  data_bcd[11:8] ;  //给第3个数码管赋百位值
        3'd3:   data_disp    <=  data_bcd[15:12];  //给第4个数码管赋千位值
        3'd4:   data_disp    <=  data_bcd[19:16];  //给第5个数码管赋万位值
        3'd5:   data_disp    <=  data_bcd[23:20];  //给第6个数码管赋十万位值
        default:data_disp    <=  4'b0        ;
        endcase
    else
        data_disp   <=  data_disp;

//dot_disp：小数点低电平点亮，需对小数点有效信号取反
always@(posedge sys_clk or negedge sys_rst_n)
    if(sys_rst_n == 1'b0)
        dot_disp    <=  1'b1;
    else    if(flag_1ms == 1'b1)
        dot_disp    <=  ~point[cnt_sel];
    else
        dot_disp    <=  dot_disp;

//控制数码管段选信号，显示数字
always@(posedge sys_clk or  negedge sys_rst_n)
    if(sys_rst_n == 1'b0)
        seg <=  8'b1111_1111;
    else    
        case(data_disp)
            4'd0  : seg  <=  {dot_disp,7'b100_0000};    //显示数字0
            4'd1  : seg  <=  {dot_disp,7'b111_1001};    //显示数字1
            4'd2  : seg  <=  {dot_disp,7'b010_0100};    //显示数字2
            4'd3  : seg  <=  {dot_disp,7'b011_0000};    //显示数字3
            4'd4  : seg  <=  {dot_disp,7'b001_1001};    //显示数字4
            4'd5  : seg  <=  {dot_disp,7'b001_0010};    //显示数字5
            4'd6  : seg  <=  {dot_disp,7'b000_0010};    //显示数字6
            4'd7  : seg  <=  {dot_disp,7'b111_1000};    //显示数字7
            4'd8  : seg  <=  {dot_disp,7'b000_0000};    //显示数字8
            4'd9  : seg  <=  {dot_disp,7'b001_0000};    //显示数字9
            default:seg  <=  8'b1100_0000;
        endcase

//sel:数码管位选信号赋值
always@(posedge sys_clk or negedge sys_rst_n)
    if(sys_rst_n == 1'b0)
        sel <=  6'b000_000;
    else
        sel <=  sel_reg;

endmodule
