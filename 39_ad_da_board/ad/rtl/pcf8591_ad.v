`timescale  1ns/1ns
////////////////////////////////////////////////////////////////////////
// Author        : EmbedFire
// Create Date   : 2019/04/01
// Module Name   : pcf8591_adda
// Project Name  : ad
// Target Devices: Altera EP4CE10F17C8N
// Tool Versions : Quartus 13.0
// Description   : AD电压测量模块
// 
// Revision      : V1.0
// Additional Comments:
// 
// 实验平台: 野火_征途Pro_FPGA开发板
// 公司    : http://www.embedfire.com
// 论坛    : http://www.firebbs.cn
// 淘宝    : https://fire-stm32.taobao.com
////////////////////////////////////////////////////////////////////////

module  pcf8591_ad
(
    input   wire            sys_clk     ,   //输入系统时钟,50MHz
    input   wire            sys_rst_n   ,   //输入复位信号,低电平有效
    input   wire            i2c_end     ,   //i2c设备一次读/写操作完成
    input   wire    [7:0]   rd_data     ,   //输出i2c设备读取数据

    output  reg             rd_en       ,   //输入i2c设备读使能信号
    output  reg             i2c_start   ,   //输入i2c设备触发信号
    output  reg     [15:0]  byte_addr   ,   //输入i2c设备字节地址
    output  wire    [19:0]  po_data         //数码管待显示数据
);

//************************************************************************//
//******************** Parameter and Internal Signal *********************//
//************************************************************************//
//parameter     define
parameter   CTRL_DATA   =   8'b0100_0000;   //AD/DA控制字
parameter   CNT_WAIT_MAX=   18'd6_9999  ;   //采样间隔计数最大值
parameter   IDLE        =   3'b001,
            AD_START    =   3'b010,
            AD_CMD      =   3'b100;

//wire  define
wire    [31:0]  data_reg/* synthesis keep */;   //数码管待显示数据缓存

//reg   define
reg     [17:0]  cnt_wait;   //采样间隔计数器
reg     [4:0]   state   ;   //状态机状态变量
reg     [7:0]   ad_data ;   //AD数据

//********************************************************************//
//***************************** Main Code ****************************//
//********************************************************************//
//cnt_wait:采样间隔计数器
always@(posedge sys_clk or negedge sys_rst_n)
    if(sys_rst_n == 1'b0)
        cnt_wait    <=  18'd0;
    else    if(state == IDLE)
        if(cnt_wait == CNT_WAIT_MAX)
            cnt_wait    <=  18'd0;
        else
            cnt_wait    <=  cnt_wait + 18'd1;
    else
        cnt_wait    <=  18'd0;

//state:状态机状态变量
always@(posedge sys_clk or negedge sys_rst_n)
    if(sys_rst_n == 1'b0)
        state   <=  IDLE;
    else
        case(state)
            IDLE:
                if(cnt_wait == CNT_WAIT_MAX)
                    state   <=  AD_START;
                else
                    state   <=  IDLE;
            AD_START:
                state   <=  AD_CMD;
            AD_CMD:
                if(i2c_end == 1'b1)
                    state   <=  IDLE;
                else
                    state   <=  AD_CMD;
            default:state   <=  IDLE;
        endcase

//i2c_start:输入i2c设备触发信号
always@(posedge sys_clk or negedge sys_rst_n)
    if(sys_rst_n == 1'b0)
        i2c_start   <=  1'b0;
    else    if(state == AD_START)
        i2c_start   <=  1'b1;
    else
        i2c_start   <=  1'b0;

//rd_en:输入i2c设备读使能信号
always@(posedge sys_clk or negedge sys_rst_n)
    if(sys_rst_n == 1'b0)
        rd_en   <=  1'b0;
    else    if(state == AD_CMD)
        rd_en   <=  1'b1;
    else
        rd_en   <=  1'b0;

//byte_addr:输入i2c设备字节地址
always@(posedge sys_clk or negedge sys_rst_n)
    if(sys_rst_n == 1'b0)
        byte_addr   <=  16'b0;
    else
        byte_addr   <=  CTRL_DATA;

//ad_data:AD数据
always@(posedge sys_clk or negedge sys_rst_n)
    if(sys_rst_n == 1'b0)
        ad_data <=  8'b0;
    else    if(i2c_end == 1'b1) //(state == AD_CMD) && (i2c_end == 1'b1))
        ad_data <=  rd_data;

//data_reg:数码管待显示数据缓存
assign  data_reg = ((ad_data * 3300) >> 4'd8);

//po_data:数码管待显示数据
assign  po_data = data_reg[19:0];

endmodule

