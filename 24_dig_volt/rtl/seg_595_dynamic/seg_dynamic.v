`timescale  1ns/1ns
////////////////////////////////////////////////////////////////////////
// Author        : EmbedFire
// Create Date   : 2019/07/10
// Module Name   : seg_dynamic
// Project Name  : dig_volt
// Target Devices: Altera EP4CE10F17C8N
// Tool Versions : Quartus 13.0
// Description   : 数码管动态显示
//
// Revision      : V1.0
// Additional Comments:
// 
// 实验平台: 野火_征途Pro_FPGA开发板
// 公司    : http://www.embedfire.com
// 论坛    : http://www.firebbs.cn
// 淘宝    : https://fire-stm32.taobao.com
////////////////////////////////////////////////////////////////////////

module  seg_dynamic
(
    input   wire            sys_clk     , //系统时钟，频率50MHz
    input   wire            sys_rst_n   , //复位信号，低有效
    input   wire    [19:0]  data        , //数码管要显示的值
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
parameter   CNT_1K_MAX  =   24999;  //产生clk_1k的计数器最大值

//wire  define
wire    [3:0]   data0;  //个位数
wire    [3:0]   data1;  //十位数
wire    [3:0]   data2;  //百位数
wire    [3:0]   data3;  //千位数
wire    [3:0]   data4;  //万位数
wire    [3:0]   data5;  //十万位数

//reg   define
reg     [14:0]  cnt_1k      ;   //时钟分频计数器
reg             clk_1k      ;   //位选刷新时钟
reg     [2:0]   cnt_sel     ;   //数码管位选计数器
reg     [23:0]  num         ;   //24位BCD码寄存器
reg     [3:0]   num_disp    ;   //当前数码管显示的数据
reg             dot_disp    ;   //当前数码管显示的小数点

//********************************************************************//
//***************************** Main Code ****************************//
//********************************************************************//

//提取数码管显示数值中各个数码管的十进制数（一个数码管显示一位）
assign  data0   =   data % 4'd10                ;   //个位数
assign  data1   =   data / 4'd10 % 4'd10        ;   //十位数
assign  data2   =   data / 7'd100 % 4'd10       ;   //百位数
assign  data3   =   data / 10'd1000 % 4'd10     ;   //千位数
assign  data4   =   data / 14'd10000 % 4'd10    ;   //万位数
assign  data5   =   data / 17'd100000           ;   //十万位数

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

//将显示的20位二进制数转化为8421BCD码（1位十进制数用4位二进制数表示）
always@(posedge sys_clk or  negedge sys_rst_n)
    if(sys_rst_n == 1'b0)
        num <=  24'b0;
//若显示的数据为6位十进制数，则依次给6个数码管赋值
    else    if(data5 || point[5])
        begin
            num[3:0]    <=  data0   ;
            num[7:4]    <=  data1   ;
            num[11:8]   <=  data2   ;
            num[15:12]  <=  data3   ;
            num[19:16]  <=  data4   ;
            num[23:20]  <=  data5   ;
        end
//若显示的数据为5位十进制数，则依次给前5个数码管赋值
    else    if(data4 || point[4])
        begin
            num[3:0]    <=  data0   ;
            num[7:4]    <=  data1   ;
            num[11:8]   <=  data2   ;
            num[15:12]  <=  data3   ;
            num[19:16]  <=  data4   ;
            if(sign == 1'b1)    //若需要显示负号，则在第6个数码管显示
                num[23:20]  <=  4'd10;
            else
                num[23:20]  <=  4'd11;
    //若不需要显示，则让第6个数码管不显示任何字符即可
    //0-9需显示十进制数，所以定义为4'd10显示负号，4'd11不显示任何字符
        end
//若显示的数据为4位十进制数，则依次给前4个数码管赋值
    else    if(data3 || point[3])
        begin
            num[3:0]    <=  data0   ;
            num[7:4]    <=  data1   ;
            num[11:8]   <=  data2   ;
            num[15:12]  <=  data3   ;
            num[23:20]  <=  4'd11   ;   //第6个数码管不显示任何字符
            if(sign == 1'b1)    //若需要显示负号，则在第5个数码管显示
                num[19:16]  <=  4'd10;
            else    //若不需要显示，则让第5个数码管不显示任何字符即可
                num[19:16]  <=  4'd11;
        end
//若显示的数据为3位十进制数，则依次给前3个数码管赋值
    else    if(data2 || point[2])
        begin
            num[3:0]    <=  data0   ;
            num[7:4]    <=  data1   ;
            num[11:8]   <=  data2   ;
            num[19:16]  <=  4'd11   ;   //第5个数码管不显示任何字符
            num[23:20]  <=  4'd11   ;   //第6个数码管不显示任何字符
            if(sign == 1'b1)    //若需要显示负号，则在第4个数码管显示
                num[15:12]  <=  4'd10;
            else    //若不需要显示，则让第4个数码管不显示任何字符即可
                num[15:12]  <=  4'd11;
        end
//若显示的数据为2位十进制数，则依次给前2个数码管赋值
    else    if(data1 || point[1])
        begin
            num[3:0]    <=  data0   ;
            num[7:4]    <=  data1   ;
            num[15:12]  <=  4'd11   ;   //第4个数码管不显示任何字符
            num[19:16]  <=  4'd11   ;   //第5个数码管不显示任何字符
            num[23:20]  <=  4'd11   ;   //第6个数码管不显示任何字符
            if(sign == 1'b1)    //若需要显示负号，则在第3个数码管显示
                num[11:8]  <=  4'd10;
            else    //若不需要显示，则让第3个数码管不显示任何字符即可
                num[11:8]  <=  4'd11;
        end
//若显示的数据为1位十进制数，则给第1个数码管赋值
    else
        begin
            num[3:0]    <=  data0   ;
            num[11:8]   <=  4'd11   ;   //第3个数码管不显示任何字符
            num[15:12]  <=  4'd11   ;   //第4个数码管不显示任何字符
            num[19:16]  <=  4'd11   ;   //第5个数码管不显示任何字符
            num[23:20]  <=  4'd11   ;   //第6个数码管不显示任何字符
            if(sign == 1'b1)    //若需要显示负号，则在第2个数码管显示
                num[7:4]  <=  4'd10;
            else    //若不需要显示，则让第2个数码管不显示任何字符即可
                num[7:4]  <=  4'd11;
        end

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
        4'd10 : seg  <=  8'b1011_1111          ;    //显示负号
        4'd11 : seg  <=  8'b1111_1111          ;    //不显示任何字符
        default:seg  <=  8'b1100_0000;
    endcase

endmodule
