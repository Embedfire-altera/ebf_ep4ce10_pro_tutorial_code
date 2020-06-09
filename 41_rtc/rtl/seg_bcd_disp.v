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
    input   wire            sys_clk     ,   //系统时钟，频率50MHz
    input   wire            sys_rst_n   ,   //复位信号，低有效
    input   wire    [23:0]  num         ,   //bcd码数据
    input   wire    [5:0]   point       ,   //小数点显示,高电平有效
    input   wire            seg_en      ,   //数码管使能信号，高电平有效

    output  reg     [5:0]   sel         ,   //数码管位选信号
    output  reg     [7:0]   seg             //数码管段选信号

);

//********************************************************************//
//******************** Parameter and Internal Signal *****************//
//********************************************************************//

//parameter define
parameter   CNT_1K_MAX  =   24999;

//reg   define
reg     [14:0]  cnt_1k      ;   //时钟分频计数器
reg             clk_1k      ;   //位选刷新时钟
reg     [2:0]   cnt_sel     ;   //数码管位选计数器
reg     [3:0]   num_disp    ;   //当前数码管显示的数据
reg             dot_disp    ;   //当前数码管显示的小数点

//********************************************************************//
//******************************* Main Code **************************//
//********************************************************************//

//cnt_1k:从0到24999循环计数
always@(posedge  sys_clk or  negedge sys_rst_n)
    if(sys_rst_n == 1'b0)
        cnt_1k  <=  15'b0;
    else    if(cnt_1k == CNT_1K_MAX)
        cnt_1k  <=  15'b0;
    else
        cnt_1k  <=  cnt_1k  +   1'b1;

//clk_1k:产生频率为1KHz的刷新时钟
always@(posedge sys_clk or  negedge sys_rst_n)
    if(sys_rst_n == 1'b0)
        clk_1k  <=  0;
    else    if(cnt_1k == CNT_1K_MAX)
        clk_1k  <=  ~clk_1k;
    else
        clk_1k  <=  clk_1k;

//cnt_sel：从0到5循环数，用于选择当前显示的数码管
always@(posedge clk_1k or  negedge sys_rst_n)
    if(sys_rst_n == 1'b0)
        cnt_sel <=  3'b0;
    else    if(cnt_sel == 3'd5)
        cnt_sel <=  3'b0;
    else
        cnt_sel <=  cnt_sel + 1'b1;

//控制数码管的位选信号，使六个数码管轮流显示
always@(posedge clk_1k or  negedge sys_rst_n)
    if(sys_rst_n == 1'b0)
        begin
            sel <=  6'b000000;
            num_disp    <=  4'b0;
            dot_disp    <=  1'b1;
        end
    else    if(seg_en == 1'b1)
        case(cnt_sel)
        3'd0:
            begin
                sel <=  6'b000001;   //显示第1个数码管（最低位 数码管）
                num_disp    <=  num[3:0];  //给第1个数码管赋个位值
                dot_disp    <=  ~point[0]; /*小数点我们定义的是高电平有效
                            而共阳极数码管是低电平导通，故要对其取反操作*/
            end
        3'd1:
            begin
                sel         <=  6'b000010   ;   //显示第2个数码管
                num_disp    <=  num[7:4]    ;   //给第2个数码管赋十位值
                dot_disp    <=  ~point[1]   ;
            end
        3'd2:
            begin
                sel         <=  6'b000100   ;   //显示第3个数码管
                num_disp    <=  num[11:8]   ;   //给第3个数码管赋百位值
                dot_disp    <=  ~point[2]   ;
            end
        3'd3:
            begin
                sel         <=  6'b001000   ;   //显示第4个数码管
                num_disp    <=  num[15:12]  ;   //给第4个数码管赋千位值
                dot_disp    <=  ~point[3]   ;
            end
        3'd4:
            begin
                sel         <=  6'b010000   ;   //显示第5个数码管
                num_disp    <=  num[19:16]  ;   //给第5个数码管赋万位值
                dot_disp    <=  ~point[4]   ;
            end
        3'd5:
            begin
                sel         <=  6'b100000   ;   //显示第6个数码管
                num_disp    <=  num[23:20]  ;   //给第6个数码管赋十位值
                dot_disp    <=  ~point[5]   ;
            end
        default:
            begin
                sel         <=  6'b000000   ;
                num_disp    <=  4'b0        ;
                dot_disp    <=  1'b1        ;
            end
        endcase
 
//控制数码管段选信号，显示数字
always@(posedge sys_clk or  negedge sys_rst_n)
    if(sys_rst_n == 1'b0)
        seg <=  8'b1100_0000;
    else    case(num_disp)
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

endmodule
