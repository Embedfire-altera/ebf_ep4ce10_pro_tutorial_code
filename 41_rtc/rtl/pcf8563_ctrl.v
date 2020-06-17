`timescale  1ns/1ns
////////////////////////////////////////////////////////////////////////
// Author        : EmbedFire
// Create Date   : 2019/09/06
// Module Name   : pcf8563_ctrl
// Project Name  : rtc
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

module  pcf8563_ctrl 
#(
    parameter   TIME_INIT = 48'h20_06_08_08_00_00
)
(
    input   wire            sys_clk     ,   //系统时钟，频率50MHz
    input   wire            i2c_clk     ,   //i2c驱动时钟
    input   wire            sys_rst_n   ,   //复位信号，低有效
    input   wire            i2c_end     ,   //i2c一次读/写操作完成
    input   wire    [7:0]   rd_data     ,   //输出i2c设备读取数据
    input   wire            key_flag    ,   //按键消抖后标志信号

    output  reg             wr_en       ,   //输出写使能信号
    output  reg             rd_en       ,   //输出读使能信号
    output  reg             i2c_start   ,   //输出i2c触发信号
    output  reg     [15:0]  byte_addr   ,   //输出i2c字节地址
    output  reg     [7:0]   wr_data     ,   //输出i2c设备数据
    output  reg     [23:0]  data_out        //输出到数码管显示的bcd码数据
    
);

//********************************************************************//
//******************** Parameter and Internal Signal *****************//
//********************************************************************//

//parameter define  
localparam   S_WAIT         =   4'd1    ,   //上电等待状态
             INIT_SEC       =   4'd2    ,   //初始化秒
             INIT_MIN       =   4'd3    ,   //初始化分
             INIT_HOUR      =   4'd4    ,   //初始化小时
             INIT_DAY       =   4'd5    ,   //初始化日 
             INIT_MON       =   4'd6    ,   //初始化月 
             INIT_YEAR      =   4'd7    ,   //初始化年 
             RD_SEC         =   4'd8    ,   //读秒
             RD_MIN         =   4'd9    ,   //读分
             RD_HOUR        =   4'd10   ,   //读小时
             RD_DAY         =   4'd11   ,   //读日
             RD_MON         =   4'd12   ,   //读月
             RD_YEAR        =   4'd13   ;   //读年
localparam   CNT_WAIT_8MS   =   8000    ;   //8ms时间计数值

//reg   define
reg [7:0]   year        ;   //年数据
reg [7:0]   month       ;   //月数据
reg [7:0]   day         ;   //日数据
reg [7:0]   hour        ;   //小时数据
reg [7:0]   minute      ;   //年数据
reg [7:0]   second      ;   //秒数据
reg         data_flag   ;   //数据切换标志信号
reg [3:0]   state       ;   //状态机状态
reg [12:0]  cnt_wait    ;   //等待计数器

//********************************************************************//
//***************************** Main Code ****************************//
//********************************************************************//

//产生数据切换的标志信号
always@(posedge sys_clk or  negedge sys_rst_n)
    if(sys_rst_n == 1'b0)
        data_flag   <=  1'b0;
    else    if(key_flag ==  1'b1)
        data_flag   <=  ~data_flag;
    else
        data_flag   <=  data_flag;

//data_flag为0时显示时分秒，为1时显示年月日
always@(posedge sys_clk or  negedge sys_rst_n)
    if(sys_rst_n == 1'b0)
        data_out    <=  24'd0;
    else    if(data_flag == 1'b0)
        data_out    <=  {hour,minute,second};
    else
        data_out    <=  {year,month,day};

//cnt_wait:状态机跳转到一个新的状态时计数器归0，其余时候一直计数
always@(posedge i2c_clk or  negedge sys_rst_n)
    if(sys_rst_n == 1'b0)
        cnt_wait    <=  13'd0;
    else    if((state==S_WAIT && cnt_wait==CNT_WAIT_8MS) || 
              (state==INIT_SEC && i2c_end==1'b1) || (state==INIT_MIN 
              && i2c_end==1'b1) || (state==INIT_HOUR && i2c_end==1'b1)
              || (state==INIT_DAY && i2c_end==1'b1) || (state==INIT_MON
              && i2c_end == 1'b1) || (state==INIT_YEAR && i2c_end==1'b1)
              || (state==RD_SEC && i2c_end==1'b1) || (state==RD_MIN && 
              i2c_end==1'b1) || (state==RD_HOUR && i2c_end==1'b1) || 
              (state==RD_DAY && i2c_end==1'b1) || (state==RD_MON && 
              i2c_end==1'b1) || (state==RD_YEAR && i2c_end==1'b1))
        cnt_wait    <=  13'd0;
    else
        cnt_wait    <=  cnt_wait + 1'b1;

//状态机状态跳转
always@(posedge i2c_clk or  negedge sys_rst_n)
    if(sys_rst_n == 1'b0)
        state   <=  S_WAIT;
    else    case(state)
    //上电等待8ms后跳转到系统配置状态
        S_WAIT:
            if(cnt_wait == CNT_WAIT_8MS)
                state       <=  INIT_SEC;
            else
                state       <=  S_WAIT;
    //初始化秒状态：初始化秒后（i2c_end == 1'b1），跳转到下一状态
        INIT_SEC:
            if(i2c_end == 1'b1)
                state       <=  INIT_MIN;
            else
                state       <=  INIT_SEC;
    //初始化分状态：初始化分后（i2c_end == 1'b1），跳转到下一状态
        INIT_MIN:
            if(i2c_end == 1'b1)
                state       <=  INIT_HOUR ;
            else
                state       <=  INIT_MIN       ;
    //初始化时状态：初始化时后（i2c_end == 1'b1），跳转到下一状态
        INIT_HOUR:
            if(i2c_end == 1'b1)
                state       <=  INIT_DAY;
            else
                state       <=  INIT_HOUR       ;
    //初始化日状态：初始化日后（i2c_end == 1'b1），跳转到下一状态
        INIT_DAY:
            if(i2c_end == 1'b1)
                state       <=  INIT_MON;
            else
                state       <=  INIT_DAY       ;
    //初始化月状态：初始化月后（i2c_end == 1'b1），跳转到下一状态
        INIT_MON:
            if(i2c_end == 1'b1)
                state       <=  INIT_YEAR;
            else
                state       <=  INIT_MON;
    //初始化年状态：初始化年后（i2c_end == 1'b1），跳转到下一状态
        INIT_YEAR:
            if(i2c_end == 1)
                state   <=  RD_SEC;
            else
                state       <=  INIT_YEAR;
    //读秒状态：读取完秒数据后，跳转到下一状态
        RD_SEC:
            if(i2c_end == 1'b1)
                state       <=  RD_MIN;
            else
                state       <=  RD_SEC;
    //读分状态：读取完分数据后，跳转到下一状态
        RD_MIN:
            if(i2c_end == 1'b1)
                state       <=  RD_HOUR;
            else
                state       <=  RD_MIN;
    //读时状态：读取完小时数据后，跳转到下一状态
        RD_HOUR:
            if(i2c_end == 1'b1)
                state       <=  RD_DAY;
            else
                state       <=  RD_HOUR;
    //读日状态：读取完日数据后，跳转到下一状态
        RD_DAY:
            if(i2c_end == 1'b1)
                state       <=  RD_MON;
            else
                state       <=  RD_DAY;
    //读月状态：读取完月数据后，跳转到下一状态
        RD_MON:
            if(i2c_end == 1'b1)
                state       <=  RD_YEAR;
            else
                state       <=  RD_MON;
    //读年状态：读取完年数据后，跳转回读秒状态开始下一轮数据读取
        RD_YEAR:
            if(i2c_end == 1'b1)
                state       <=  RD_SEC;
            else
                state       <=  RD_YEAR;
        default:
            state       <=  S_WAIT;
    endcase
        
//各状态下的信号赋值
always@(posedge i2c_clk or  negedge sys_rst_n)
    if(sys_rst_n == 1'b0)
        begin
            wr_en       <=  1'b0    ;
            rd_en       <=  1'b0    ;
            i2c_start   <=  1'b0    ;
            byte_addr   <=  16'd0   ;
            wr_data     <=  8'd0    ;
            year        <=  8'd0    ;
            month       <=  8'd0    ;
            day         <=  8'd0    ;
            hour        <=  8'd0    ;
            minute      <=  8'd0    ;
            second      <=  8'd0    ;
        end
    else    case(state)
        S_WAIT: //上电等待状态
            begin
                wr_en       <=  1'b0    ;
                rd_en       <=  1'b0    ;
                i2c_start   <=  1'b0    ;
                byte_addr   <=  16'h0   ;
                wr_data     <=  8'h00   ;
            end 
        INIT_SEC:  //初始化秒
            if(cnt_wait == 13'd1)
                begin
                    wr_en       <=  1'b1    ;
                    i2c_start   <=  1'b1    ;
                    byte_addr   <=  16'h02  ;
                    wr_data     <=  TIME_INIT[7:0];
                end
            else
                begin
                    wr_en       <=  1'b1    ;
                    i2c_start   <=  1'b0    ;
                    byte_addr   <=  16'h02  ;
                    wr_data     <=  TIME_INIT[7:0];
                end
        INIT_MIN:  //初始化分
            if(cnt_wait == 13'd1)
                begin
                    i2c_start   <=  1'b1    ;
                    byte_addr   <=  16'h03  ;
                    wr_data     <=  TIME_INIT[15:8];
                end
            else
                begin
                    i2c_start   <=  1'b0    ;
                    byte_addr   <=  16'h03  ;
                    wr_data     <=  TIME_INIT[15:8];
                end
        INIT_HOUR: //初始化小时
            if(cnt_wait == 13'd1)
                begin
                    i2c_start   <=  1'b1    ;   
                    byte_addr   <=  16'h04  ;
                    wr_data     <=  TIME_INIT[23:16];
                end
            else
                begin
                    i2c_start   <=  1'b0    ;
                    byte_addr   <=  16'h04  ;
                    wr_data     <=  TIME_INIT[23:16];
                end
        INIT_DAY: //初始化日
            if(cnt_wait == 13'd1)
                begin
                    i2c_start   <=  1'b1    ;   
                    byte_addr   <=  16'h05  ;
                    wr_data     <=  TIME_INIT[31:24];
                end
            else
                begin
                    i2c_start   <=  1'b0    ;
                    byte_addr   <=  16'h05  ;
                    wr_data     <=  TIME_INIT[31:24];
                end
        INIT_MON: //初始化月
            if(cnt_wait == 13'd1)
                begin
                    i2c_start   <=  1'b1    ;   
                    byte_addr   <=  16'h07  ;
                    wr_data     <=  TIME_INIT[39:32];
                end
            else
                begin
                    i2c_start   <=  1'b0    ;
                    byte_addr   <=  16'h07  ;
                    wr_data     <=  TIME_INIT[39:32];
                end
        INIT_YEAR: //初始化年
            if(cnt_wait == 13'd1)
                begin
                    i2c_start   <=  1'b1    ;
                    byte_addr   <=  16'h08  ;
                    wr_data     <=  TIME_INIT[47:40];
                end
            else
                begin
                    i2c_start   <=  1'b0    ;
                    byte_addr   <=  16'h08  ;
                    wr_data     <=  TIME_INIT[47:40];
                end
        RD_SEC: //读秒
            if(cnt_wait == 13'd1)
                i2c_start   <=  1'b1;
            else    if(i2c_end == 1'b1)
                second      <=  rd_data[6:0];
            else
                begin
                    wr_en       <=  1'b0    ;
                    rd_en       <=  1'b1    ;
                    i2c_start   <=  1'b0    ;
                    byte_addr   <=  16'h02  ;
                    wr_data     <=  8'd0    ;
                end
        RD_MIN: //读分
            if(cnt_wait == 13'd1)
                i2c_start   <=  1'b1;
            else    if(i2c_end == 1'b1)
                minute      <=  rd_data[6:0];
            else
                begin
                    rd_en       <=  1'b1    ;
                    i2c_start   <=  1'b0    ;
                    byte_addr   <=  16'h03  ;
                end
        RD_HOUR: //读时
            if(cnt_wait == 13'd1)
                i2c_start   <=  1'b1;
            else    if(i2c_end == 1'b1)
                hour        <=  rd_data[5:0];
            else
                begin
                    rd_en       <=  1'b1    ;
                    i2c_start   <=  1'b0    ;
                    byte_addr   <=  16'h04  ;
                end
        RD_DAY: //读日
            if(cnt_wait == 13'd1)
                i2c_start   <=  1'b1;
            else    if(i2c_end == 1'b1)
                day      <=  rd_data[5:0];
            else
                begin
                    rd_en       <=  1'b1    ;
                    i2c_start   <=  1'b0    ;
                    byte_addr   <=  16'h05  ;
                end
        RD_MON: //读月
            if(cnt_wait == 13'd1)
                i2c_start   <=  1'b1;
            else    if(i2c_end == 1'b1)
                month      <=  rd_data[4:0];
            else
                begin
                    rd_en       <=  1'b1    ;
                    i2c_start   <=  1'b0    ;
                    byte_addr   <=  16'h07  ;
                end
        RD_YEAR: //读年
            if(cnt_wait == 13'd1)
                i2c_start   <=  1'b1;
            else    if(i2c_end == 1'b1)
                year        <=  rd_data[7:0];
            else
                begin
                    rd_en       <=  1'b1    ;
                    i2c_start   <=  1'b0    ;
                    byte_addr   <=  16'h08  ;
                end
        default:
        begin
            wr_en       <=  1'b0    ;
            rd_en       <=  1'b0    ;
            i2c_start   <=  1'b0    ;
            byte_addr   <=  16'd0   ;
            wr_data     <=  8'd0    ;
            year        <=  8'd0    ;
            month       <=  8'd0    ;
            day         <=  8'd0    ;
            hour        <=  8'd0    ;
            minute      <=  8'd0    ;
            second      <=  8'd0    ;
        end
    endcase

endmodule
