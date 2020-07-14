`timescale  1ns/1ns
////////////////////////////////////////////////////////////////////////
// Author        : EmbedFire
// Create Date   : 2019/08/6
// Module Name   : dht11_ctrl
// Project Name  : dht11
// Target Devices: Altera EP4CE10F17C8N
// Tool Versions : Quartus 13.0
// Description   : 湿度传感器控制模块
//
// Revision      : V1.0
// Additional Comments:
// 
// 实验平台: 野火_征途系列FPGA开发板
// 公司    :http://www.embedfire.com
// 论坛    :http://www.firebbs.cn
// 淘宝    :https://fire-stm32.taobao.com
////////////////////////////////////////////////////////////////////////

module  dht11_ctrl
(
    input   wire        sys_clk     ,   //系统时钟，频率50MHz
    input   wire        sys_rst_n   ,   //复位信号，低电平有效
    input   wire        key_flag    ,   //按键消抖后标志信号

    inout   wire        dht11       ,   //控制总线

    output  reg [19:0]  data_out    ,   //输出显示的数据
    output  reg         sign            //输出符号位，高电平显示负号

);

//********************************************************************//
//****************** Parameter and Internal Signal *******************//
//********************************************************************//

//parameter define
parameter   S_WAIT_1S  = 3'd1   ,   //上电等待1s状态
            S_LOW_18MS = 3'd2   ,   //主机拉低18ms，发送开始信号状态
            S_DLY1     = 3'd3   ,   //等待20-40us状态
            S_REPLY    = 3'd4   ,   //DHT11响应80us状态
            S_DLY2     = 3'd5   ,   //拉高等待80us状态
            S_RD_DATA  = 3'd6   ;   //接收数据状态

parameter   T_1S_DATA    = 999999 ; //1s时间计数值
parameter   T_18MS_DATA  = 17999  ; //18ms时间计数值

//reg define
reg         clk_1us     ;   //1us时钟，用于驱动整个模块
reg [4:0]   cnt         ;   //时钟分频计数器
reg [2:0]   state       ;   //状态机状态
reg [20:0]  cnt_us      ;   //us计数器
reg         dht11_out   ;   //总线输出数据
reg         dht11_en    ;   //总线输出使能信号
reg [5:0]   bit_cnt     ;   //字节计数器
reg [39:0]  data_tmp    ;   //读出数据寄存器
reg         data_flag   ;   //数据切换标志信号
reg         dht11_d1    ;   //总线信号打一拍
reg         dht11_d2    ;   //总线信号打两拍
reg [31:0]  data        ;   //除校验位数据
reg [6:0]   cnt_low     ;   //低电平计数器

//wire  define
wire            dht11_fall; //总线下降沿
wire            dht11_rise; //总线上升沿

//********************************************************************//
//***************************** Main Code ****************************//
//********************************************************************//

//当使能信号为1是总线的值为DATA_out的值，为0时值为高阻态
assign  dht11  =   (dht11_en == 1 ) ? dht11_out : 1'bz;

//检测总线信号的上升沿下降沿
assign  dht11_rise =   (~dht11_d2) & (dht11_d1)    ;
assign  dht11_fall =   (dht11_d2)  & (~dht11_d1)   ;

//对dht11信号打拍
always@(posedge clk_1us or  negedge sys_rst_n)
    if(sys_rst_n == 1'b0)
        begin
            dht11_d1  <=  1'b0 ;
            dht11_d2  <=  1'b0 ;
        end
    else
        begin
            dht11_d1  <=  dht11    ;
            dht11_d2  <=  dht11_d1 ;
        end

//cnt:分频计数器
always@(posedge sys_clk or  negedge sys_rst_n)
    if(sys_rst_n == 1'b0)
        cnt <=  5'b0;
    else    if(cnt == 5'd24)
        cnt <=  5'b0;
    else
        cnt <=  cnt + 1'b1;

//clk_1us：产生单位时钟为1us的时钟
always@(posedge sys_clk or  negedge sys_rst_n)
    if(sys_rst_n == 1'b0)
        clk_1us <=  1'b0;
    else    if(cnt == 5'd24)
        clk_1us <=  ~clk_1us;
    else
        clk_1us <=  clk_1us;

//bit_cnt：读出数据bit位数计数器
always@(posedge clk_1us or  negedge sys_rst_n)
    if(sys_rst_n == 1'b0)
        bit_cnt <=  6'b0;
    else    if(bit_cnt == 40 && dht11_rise == 1'b1)
        bit_cnt <=  6'b0;
    else    if(dht11_fall == 1'b1 && state == S_RD_DATA)
        bit_cnt <=  bit_cnt + 1'b1;

//data_flag:数据变换标志信号的产生，按一次键变换一次
always@(posedge sys_clk or  negedge sys_rst_n)
    if(sys_rst_n == 1'b0)
        data_flag   <=  1'b0;
    else    if(key_flag == 1'b1)
        data_flag   <=  ~data_flag;
    else
        data_flag   <=  data_flag;

//状态机状态跳转
always@(posedge clk_1us or  negedge sys_rst_n)
    if(sys_rst_n == 1'b0)
        state   <=  S_WAIT_1S   ;
    else
        case(state)
        S_WAIT_1S:
            if(cnt_us == T_1S_DATA) //上电1s后跳入起始状态
                state   <=  S_LOW_18MS  ;
            else
                state   <=  S_WAIT_1S   ;
        S_LOW_18MS:
            if(cnt_us == T_18MS_DATA)
                state   <=  S_DLY1     ;
            else
                state   <=  S_LOW_18MS  ;
        S_DLY1:
            if(cnt_us == 10)    //等待10us后进入下一状态
                state   <=  S_REPLY     ;
            else
                state   <=  S_DLY1     ;
        S_REPLY:  //上升沿到来且低电平保持时间大于70us，则跳转到下一状态
            if(dht11_rise == 1'b1 && cnt_low >= 70)
                state   <=  S_DLY2     ;
                 //若1ms后，dht11还没响应，则回去继续发送起始信号
            else    if(cnt_us >= 1000)
                state   <=  S_LOW_18MS ;
            else
                state   <=  S_REPLY    ;
        S_DLY2: //下降沿到来且计数器值大于70us，则跳转到下一状态
            if(dht11_fall == 1'b1 && cnt_us >= 70)
                state   <=  S_RD_DATA   ;
            else
                state       <=  S_DLY2  ;
        S_RD_DATA:  //读完数据后，回到起始状态
            if(bit_cnt == 40 && dht11_rise == 1'b1)
                state   <=  S_LOW_18MS  ;
            else
                state   <=  S_RD_DATA   ;
        default:
                state   <=  S_WAIT_1S   ;
        endcase

//各状态下的计数器赋值
//cnt_us:每到一个新的状态就让该计数器重新计数
always@(posedge clk_1us or  negedge sys_rst_n)
    if(sys_rst_n == 1'b0)
        begin
            cnt_low <=  7'd0      ;
            cnt_us   <=  21'd0    ;
        end
    else
        case(state)
        S_WAIT_1S:
            if(cnt_us == T_1S_DATA) 
                cnt_us   <=  21'd0  ;
            else
                cnt_us   <=  cnt_us + 1'b1;
        S_LOW_18MS:
            if(cnt_us == T_18MS_DATA)
                cnt_us   <=  21'd0  ;
            else
                cnt_us   <=  cnt_us + 1'b1;
        S_DLY1:
            if(cnt_us == 10)
                cnt_us   <=  21'd0  ;
            else
                cnt_us   <=  cnt_us + 1'b1;
        S_REPLY:
            if(dht11_rise == 1'b1 && cnt_low >= 70)
                begin
                    cnt_low <=  7'd0    ;
                    cnt_us   <=  21'd0  ;
                end
            //当dht11发送低电平回应时，计算其低电平的持续时间
            else    if(dht11 == 1'b0)
                begin
                    cnt_low  <=  cnt_low + 1'b1 ;
                    cnt_us   <=  cnt_us + 1'b1  ;
                end
            //若1ms后，dht11还没响应，则回去继续发送起始信号
            else    if(cnt_us >= 1000)
                begin
                    cnt_low <=  7'd0   ;
                    cnt_us  <=  21'd0  ;
                end
            else
                begin
                    cnt_low <=  cnt_low        ;
                    cnt_us  <=  cnt_us + 1'b1  ;
                end
        S_DLY2:
            if(dht11_fall == 1'b1 && cnt_us >= 70)
                cnt_us   <=  21'd0  ;
            else
                cnt_us   <=  cnt_us + 1'b1;
        S_RD_DATA:
            if(dht11_fall == 1'b1 || dht11_rise == 1'b1)
                cnt_us   <=  21'd0  ;
            else
                cnt_us   <=  cnt_us + 1'b1;
        default:
            begin
                cnt_low  <=  7'd0   ;
                cnt_us   <=  21'd0  ;
            end
        endcase

//各状态下的单总线赋值
always@(posedge clk_1us or  negedge sys_rst_n)
    if(sys_rst_n == 1'b0)
        begin
               dht11_out <=  1'b0    ;
               dht11_en  <=  1'b0    ;
        end
    else
        case(state)
        S_WAIT_1S:
                begin
                    dht11_out    <=  1'b0    ;
                    dht11_en     <=  1'b0    ;
                end
        S_LOW_18MS: //拉低总线18ms
                begin
                    dht11_out    <=  1'b0    ;
                    dht11_en     <=  1'b1    ;
                end
    //后面状态释放总线即可，由DHT11操控总线
        S_DLY1:
                begin
                    dht11_out    <=  1'b0    ;
                    dht11_en     <=  1'b0    ;
                end
        S_REPLY:
                begin
                    dht11_out    <=  1'b0    ;
                    dht11_en     <=  1'b0    ;
                end
        S_DLY2:
                begin
                    dht11_out    <=  1'b0    ;
                    dht11_en     <=  1'b0    ;
                end
        S_RD_DATA:
                begin
                    dht11_out    <=  1'b0    ;
                    dht11_en     <=  1'b0    ;
                end
        default:;
        endcase

//data_tmp:将读出的数据寄存在data_tmp中
always@(posedge clk_1us or  negedge sys_rst_n)
    if(sys_rst_n == 1'b0)
        data_tmp    <=  40'b0;
    else    if(state == S_RD_DATA && dht11_fall == 1'b1 && cnt_us<=50)
        data_tmp[39-bit_cnt]   <=  1'b0;
    else    if(state == S_RD_DATA && dht11_fall == 1'b1 && cnt_us>50)
        data_tmp[39-bit_cnt]   <=  1'b1;
    else
        data_tmp    <=  data_tmp;

//data_out:输出数据显示，按一次按键切换一次数据
always@(posedge clk_1us or  negedge sys_rst_n)
    if(sys_rst_n == 1'b0)
        data    <=  32'b0;
    else    if(data_tmp[7:0] == data_tmp[39:32] + data_tmp[31:24] +
                                      data_tmp[23:16] + data_tmp[15:8])
        data    <=  data_tmp[39:8];   //若检验位正确，则数据值有效
     else
        data    <=  data;

//data_out:对数码管显示的湿度和温度进行赋值
always@(posedge clk_1us or  negedge sys_rst_n)
    if(sys_rst_n == 1'b0)
        data_out    <=  20'b0;
    else    if(data_flag == 1'b0 )
        data_out    <=  data[31:24] * 10; //湿度小数位为0
    else    if(data_flag == 1'b1)
    //温度低四位显示温度小数数据
        data_out    <=  data[15:8] * 10 + data[3:0];

//sign:符号位的显示
always@(posedge clk_1us or  negedge sys_rst_n)
    if(sys_rst_n == 1'b0)
        sign    <=  1'b0;
    else    if(data[7] == 1'b1 && data_flag == 1'b1)
    //当温度低八位最高位为1时，显示负号
        sign    <=  1'b1;
    else
        sign    <=  1'b0;

endmodule
