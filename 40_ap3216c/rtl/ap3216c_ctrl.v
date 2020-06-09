`timescale  1ns/1ns
////////////////////////////////////////////////////////////////////////
// Author        : EmbedFire
// Create Date   : 2018/08/31
// Module Name   : ap3216c_ctrl
// Project Name  : ap3216c
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

module  ap3216c_ctrl
(
    input   wire            i2c_clk     ,   //i2c驱动时钟,1MHz
    input   wire            sys_rst_n   ,   //复位信号，低有效
    input   wire            i2c_end     ,   //i2c一次读/写操作完成
    input   wire    [7:0]   rd_data     ,   //i2c设备读取数据
    
    output  reg             wr_en       ,   //写数据使能信号
    output  reg             rd_en       ,   //读数据使能信号
    output  reg             i2c_start   ,   //i2c触发信号
    output  reg     [15:0]  byte_addr   ,   //输入i2c字节地址
    output  reg     [7:0]   wr_data     ,   //输入i2c设备数据
    output  reg     [9:0]   ps_data     ,   //输出距离
    output  reg     [15:0]  als_data        //输出光感 
);

//********************************************************************//
//****************** Parameter and Internal Signal *******************//
//********************************************************************//

//parameter define                  
parameter   S_WAIT_1MS      = 4'd1   ,   //上电等待1ms状态
            S_CFG           = 4'd2   ,   //系统配置状态
            S_WAIT_PS       = 4'd3   ,   //等待50ms
            S_RD_PS_L4      = 4'd4   ,   //读取PS低四位数据
            S_RD_PS_H6      = 4'd5   ,   //读取PS高六位数据
            S_WAIT_ALS      = 4'd6   ,   //等待200ms
            S_RD_ALS_L8     = 4'd7   ,   //读取als低八位数据
            S_RD_ALS_H8     = 4'd8   ;   //读取als高八位数据

parameter   CNT_WAIT_ALS    = 200000 ; //200ms时间计数值
parameter   CNT_WAIT_PS     = 50000  ; //50ms时间计数值
parameter   CNT_WAIT_1MS    = 1000   ; //1ms时间计数值
                  
//reg define
reg     [17:0]  cnt_wait        ;   //寄存器配置上电等待计数器
reg             ps_done         ;   //ps数据采集完成信号
reg             als_done        ;   //als数据采集完成信号
reg     [9:0]   ps_data_reg     ;   //PS数据寄存器
reg     [15:0]  als_data_reg    ;   //als数据寄存器
reg     [3:0]   state           ;   //状态机状态

//********************************************************************//
//******************************* Main Code **************************//
//********************************************************************//

//状态机状态跳转
always@(posedge i2c_clk or  negedge sys_rst_n)
    if(sys_rst_n == 1'b0)
        begin
            state   <=  S_WAIT_1MS;
            cnt_wait    <=  18'd0 ;
        end
//当跳转到下一个状态时计数器归0，在当前状态每来一个时钟信号，计数器加一
    else    case(state)
    //上电等待1ms后跳转到系统配置状态
        S_WAIT_1MS:
            if(cnt_wait == CNT_WAIT_1MS)
                begin
                    state       <=  S_CFG;
                    cnt_wait    <=  18'd0;
                end
            else
                begin
                    state       <=  S_WAIT_1MS     ;
                    cnt_wait    <=  cnt_wait + 1'b1;
                end
    //系统配置完成（i2c_end == 1）后，跳转到下一状态
        S_CFG:
            if(i2c_end == 1'b1)
                begin
                    state       <=  S_WAIT_PS;
                    cnt_wait    <=  18'd0        ;
                end
            else
                begin
                    state       <=  S_CFG     ;
                    cnt_wait    <=  cnt_wait+1;
                end
    //等待50ms后跳转
        S_WAIT_PS:
            if(cnt_wait == CNT_WAIT_PS)
                begin
                    state       <=  S_RD_PS_L4;
                    cnt_wait    <=  18'd0     ;
                end
            else
                begin
                    state       <=  S_WAIT_PS  ;
                    cnt_wait    <=  cnt_wait + 1'b1;
                end
    //读取完ps低四位数据之后跳转
        S_RD_PS_L4:
            if(i2c_end == 1'b1)
                begin
                    state       <=  S_RD_PS_H6;
                    cnt_wait    <=  18'd0     ;
                end
            else
                begin
                    state       <=  S_RD_PS_L4     ;
                    cnt_wait    <=  cnt_wait + 1'b1;
                end
    //读取完PS高六位数据后跳转
        S_RD_PS_H6:
            if(i2c_end == 1'b1)
                begin
                    state       <=  S_WAIT_ALS;
                    cnt_wait    <=  18'd0       ;
                end
            else
                begin
                    state       <=  S_RD_PS_H6     ;
                    cnt_wait    <=  cnt_wait + 1'b1;
                end
    //等待200ms后跳转
        S_WAIT_ALS:
            if(cnt_wait == CNT_WAIT_ALS)
                begin
                    state       <=  S_RD_ALS_L8;
                    cnt_wait    <=  18'd0      ;
                end
            else
                begin
                    state       <=  S_WAIT_ALS    ;
                    cnt_wait    <=  cnt_wait +  1'b1;
                end
    //读取完als低八位数据后跳转
        S_RD_ALS_L8:
            if(i2c_end == 1'b1)
                begin
                    state   <=  S_RD_ALS_H8;
                    cnt_wait    <=  18'd0  ;
                end
            else
                begin
                    state       <=  S_RD_ALS_L8     ;
                    cnt_wait    <=  cnt_wait +  1'b1;
                end
    //读取完als高八位数据后跳转到S_WAIT_PS状态开始下一轮数据的读取
        S_RD_ALS_H8:
            if(i2c_end == 1'b1)
                begin
                    state       <=  S_WAIT_PS;
                    cnt_wait    <=  18'd0        ;
                end
            else
                begin
                    state       <=  S_RD_ALS_H8     ;
                    cnt_wait    <=  cnt_wait +  1'b1;
                end
        default:
            begin
                state       <=  S_WAIT_1MS;
                cnt_wait    <=  18'd0     ;
            end
    endcase

//各状态下的信号赋值
always@(posedge i2c_clk or  negedge sys_rst_n)
    if(sys_rst_n == 1'b0)
        begin
            wr_en       <=  1'b0    ;
            rd_en       <=  1'b0    ;
            i2c_start   <=  1'b0    ;
            byte_addr   <=  16'h0   ;
            wr_data     <=  8'h0    ;
        end
    else    case(state)
        S_WAIT_1MS: //上电等待状态
            begin
                wr_en       <=  1'b0    ;
                rd_en       <=  1'b0    ;
                i2c_start   <=  1'b0    ;
                byte_addr   <=  16'h0   ;
                wr_data     <=  8'h00   ;
            end 
        S_CFG:  //系统配置状态，产生一个时钟的开始信号，拉高写使能
            if(cnt_wait == 18'd0)
                begin
                    wr_en       <=  1'b1    ;
                    i2c_start   <=  1'b1    ;   
                    byte_addr   <=  16'h0   ;
                    wr_data     <=  8'h03   ;
                end
            else
                begin
                    wr_en       <=  1'b1    ;
                    i2c_start   <=  1'b0    ;
                    byte_addr   <=  16'h0   ;
                    wr_data     <=  8'h03   ;
                end
        S_WAIT_PS:  //等待ps数据转换完成状态
            begin
                wr_en       <=  1'b0    ;
                rd_en       <=  1'b0    ;
                i2c_start   <=  1'b0    ;
                byte_addr   <=  16'h0   ;
                wr_data     <=  8'h0    ;
            end 
        S_RD_PS_L4://读取ps数据低四位，产生一个时钟的开始信号，拉高读使能
            if(cnt_wait == 18'd0)
                begin
                    wr_en       <=  1'b0    ;
                    rd_en       <=  1'b1    ;
                    i2c_start   <=  1'b1    ;
                    byte_addr   <=  16'h0E  ;
                    wr_data     <=  8'h00   ;
                end
            else
                begin
                    wr_en       <=  1'b0    ;
                    rd_en       <=  1'b1    ;
                    i2c_start   <=  1'b0    ;
                    byte_addr   <=  16'h0E  ;
                    wr_data     <=  8'h00   ;
                end
        S_RD_PS_H6://读取ps数据高六位，产生一个时钟的开始信号，拉高读使能
        //ap3216c i2c配置结束信号与开始信号之间最小需等待1.3us
        //这里等待10us后产生开始信号
            if(cnt_wait == 18'd9)
                begin
                    wr_en       <=  1'b0    ;
                    rd_en       <=  1'b1    ;
                    i2c_start   <=  1'b1    ;
                    byte_addr   <=  16'h0F  ;
                    wr_data     <=  8'h00   ;
                end
            else
                begin
                    wr_en       <=  1'b0    ;
                    rd_en       <=  1'b1    ;
                    i2c_start   <=  1'b0    ;
                    byte_addr   <=  16'h0F  ;
                    wr_data     <=  8'h00   ;
                end
        S_WAIT_ALS:   //等待als数据转换完成状态
            begin
                wr_en       <=  1'b0    ;
                rd_en       <=  1'b0    ;
                i2c_start   <=  1'b0    ;
                byte_addr   <=  16'h0   ;
                wr_data     <=  8'h0    ;
            end
        S_RD_ALS_L8://读取als数据低八位，产生一个时钟的开始信号，拉高读使能
            if(cnt_wait == 18'd0)
                begin
                    wr_en       <=  1'b0    ;
                    rd_en       <=  1'b1    ;
                    i2c_start   <=  1'b1    ;
                    byte_addr   <=  16'h0C  ;
                    wr_data     <=  8'h00   ;
                end
            else
                begin
                    wr_en       <=  1'b0    ;
                    rd_en       <=  1'b1    ;
                    i2c_start   <=  1'b0    ;
                    byte_addr   <=  16'h0C  ;
                    wr_data     <=  8'h00   ;
                end
        S_RD_ALS_H8 ://读取als数据低八位，产生一个时钟的开始信号，拉高读使能
        //ap3216c i2c配置结束信号与开始信号直接最小需等待1.3us
        //这里等待10us后产生开始信号
            if(cnt_wait == 18'd9)
                begin
                    wr_en       <=  1'b0    ;
                    rd_en       <=  1'b1    ;
                    i2c_start   <=  1'b1    ;
                    byte_addr   <=  16'h0D  ;
                    wr_data     <=  8'h00   ;
                end
            else
                begin
                    wr_en       <=  1'b0    ;
                    rd_en       <=  1'b1    ;
                    i2c_start   <=  1'b0    ;
                    byte_addr   <=  16'h0D  ;
                    wr_data     <=  8'h00   ;
                end
        default:
        begin
            wr_en       <=  1'b0    ;
            rd_en       <=  1'b0    ;
            i2c_start   <=  1'b0    ;
            byte_addr   <=  16'h0   ;
            wr_data     <=  8'h0    ;
        end
    endcase

//读取的ps数据寄存到ps_data_reg中，读取完产生一个时钟的完成信号
always@(posedge i2c_clk or  negedge sys_rst_n)
    if(sys_rst_n == 1'b0)
        begin
            ps_data_reg <=  10'b0;
            ps_done     <=  1'b0;
        end
    else    if(state == S_RD_PS_L4 && i2c_end == 1'b1)
        begin
            ps_data_reg[3:0]    <=  rd_data[3:0];
            ps_done             <=  1'b0;
        end
    else    if(state == S_RD_PS_H6 && i2c_end == 1'b1)
        begin
            ps_data_reg[9:4]    <=  rd_data[5:0];
            ps_done             <=  1'b1;
        end
    else
        begin
            ps_data_reg         <=  ps_data_reg;
            ps_done             <=  1'b0;
        end

//读取的als数据寄存到als_data_reg中，读取完产生一个时钟的完成信号
always@(posedge i2c_clk or  negedge sys_rst_n)
    if(sys_rst_n == 1'b0)
        begin
            als_data_reg        <=  16'b0;
            als_done            <=  1'b0;
        end
    else    if(state == S_RD_ALS_L8 && i2c_end == 1'b1)
        begin
            als_data_reg[7:0]   <=  rd_data;
            als_done            <=  1'b0;
        end
    else    if(state == S_RD_ALS_H8 && i2c_end == 1'b1)
        begin
            als_data_reg[15:8]  <=  rd_data;
            als_done            <=  1'b1;
        end
    else
        begin
            als_data_reg        <=  als_data_reg;
            als_done            <=  1'b0;
        end

//ps数据读取完后，将值赋给ps_data
always@(posedge i2c_clk or  negedge sys_rst_n)
    if(sys_rst_n == 1'b0)
        ps_data <=  10'd0;
    else    if(ps_done == 1'b1)
        ps_data <=  ps_data_reg;
    else
        ps_data <=  ps_data;

//als数据读取完后，将值赋给als_data
always@(posedge i2c_clk or  negedge sys_rst_n)
    if(sys_rst_n == 1'b0)
        als_data <=  16'd0;
    else    if(als_done == 1'b1)
        als_data <=  als_data_reg * 6'd35 / 7'd100;
    else
        als_data <=  als_data;

endmodule
