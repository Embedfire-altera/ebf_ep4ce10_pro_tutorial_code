`timescale  1ns/1ns
////////////////////////////////////////////////////////////////////////
// Author        : EmbedFire
// Create Date   : 2018/08/19
// Module Name   : i2c_reg_cfg
// Project Name  : audio_loopback
// Target Devices: Altera EP4CE10F17C8N
// Tool Versions : Quartus 13.0
// Description   : 寄存器配置
// 
// Revision      : V1.0
// Additional Comments:
// 
// 实验平台: 野火_征途Pro_FPGA开发板
// 公司    : http://www.embedfire.com
// 论坛    : http://www.firebbs.cn
// 淘宝    : https://fire-stm32.taobao.com
////////////////////////////////////////////////////////////////////////

module  i2c_reg_cfg
(
    input   wire            i2c_clk     ,   //系统时钟,由i2c模块传入
    input   wire            sys_rst_n   ,   //系统复位,低有效
    input   wire            cfg_end     ,   //单个寄存器配置完成

    output  reg             cfg_start   ,   //单个寄存器配置触发信号
    output  wire    [15:0]  cfg_data    ,   //寄存器地址7bit+数据9bit
    output  reg             cfg_done        //寄存器配置完成
);

//********************************************************************//
//****************** Parameter and Internal Signal *******************//
//********************************************************************//

//parameter define
parameter   REG_NUM       =   6'd18    ;  //总共需要配置的寄存器个数
parameter   CNT_WAIT_MAX  =   10'd1000 ;  //上电等待1ms后开始配置寄存器

parameter   LOUT1VOL      =   6'd40    ;  //耳机左声道音量设置(0~63)
parameter   ROUT1VOL      =   6'd40    ;  //耳机右声道音量设置(0~63)

parameter   SPK_LOUT2VOL  =   6'd45    ;  //扬声器左声道音量设置(0~63)
parameter   SPK_ROUT2VOL  =   6'd45    ;  //扬声器右声道音量设置(0~63)

//wire  define
wire    [15:0]  cfg_data_reg[REG_NUM-1:0];   //寄存器配置数据暂存

//reg   define
reg     [9:0]  cnt_wait     ;   //寄存器配置上电等待计数器
reg     [5:0]   reg_num     ;   //配置寄存器个数

//********************************************************************//
//***************************** Main Code ****************************//
//********************************************************************//

//cnt_wait:寄存器配置等待计数器
always@(posedge i2c_clk or negedge sys_rst_n)
    if(sys_rst_n == 1'b0)
        cnt_wait    <=  10'd0;
    else    if(cnt_wait < CNT_WAIT_MAX)
        cnt_wait    <=  cnt_wait + 1'b1;

//reg_num:配置寄存器个数
always@(posedge i2c_clk or negedge sys_rst_n)
    if(sys_rst_n == 1'b0)
        reg_num <=  6'd0;
    else    if(cfg_end == 1'b1)
        reg_num <=  reg_num + 1'b1;

//cfg_start:单个寄存器配置触发信号
always@(posedge i2c_clk or negedge sys_rst_n)
    if(sys_rst_n == 1'b0)
        cfg_start   <=  1'b0;
    else    if(cnt_wait == (CNT_WAIT_MAX - 1'b1))
        cfg_start   <=  1'b1;
    else    if((cfg_end == 1'b1) && (reg_num < (REG_NUM-1)))
        cfg_start   <=  1'b1;
    else
        cfg_start   <=  1'b0;

//cfg_done:寄存器配置完成信号
always@(posedge i2c_clk or negedge sys_rst_n)
    if(sys_rst_n == 1'b0)
        cfg_done    <=  1'b0;
    else    if((reg_num == REG_NUM - 1'b1) && (cfg_end == 1'b1))
        cfg_done    <=  1'b1;

//cfg_data:7bit地址+9bit数据
assign  cfg_data = (cfg_done == 1'b1) ? 16'b0 : cfg_data_reg[reg_num];

//----------------------------------------------------
//cfg_data_reg：寄存器配置数据暂存
//各寄存器功能配置详见文档介绍
assign  cfg_data_reg[00]  =       {7'd0 , 9'b0                  };
assign  cfg_data_reg[01]  =       {7'd1 , 9'b1_0010_1111        };
assign  cfg_data_reg[02]  =       {7'd2 , 9'b1_1011_0011        };
assign  cfg_data_reg[03]  =       {7'd4 , 9'b0_0101_0000        };
assign  cfg_data_reg[04]  =       {7'd6 , 9'b0_0000_0001        };
assign  cfg_data_reg[05]  =       {7'd10, 9'b0_0000_1000        };
assign  cfg_data_reg[06]  =       {7'd14, 9'b1_0000_1000        };
assign  cfg_data_reg[07]  =       {7'd43, 9'b0_0001_0000        };
assign  cfg_data_reg[08]  =       {7'd47, 9'b0_0111_0000        };
assign  cfg_data_reg[09]  =       {7'd48, 9'b0_0111_0000        };
assign  cfg_data_reg[10]  =       {7'd49, 9'b0_0000_0110        };
assign  cfg_data_reg[11]  =       {7'd50, 9'b0_0000_0001        };
assign  cfg_data_reg[12]  =       {7'd51, 9'b0_0000_0001        };
assign  cfg_data_reg[13]  =       {7'd52, 3'b110 , LOUT1VOL     };
assign  cfg_data_reg[14]  =       {7'd53, 3'b110 , ROUT1VOL     };
assign  cfg_data_reg[15]  =       {7'd54, 3'b110 , SPK_LOUT2VOL };
assign  cfg_data_reg[16]  =       {7'd55, 3'b110 , SPK_ROUT2VOL };
//更新完耳机和扬声器的音量后再开启音频输出使能，防止出现“嘎达”声
assign  cfg_data_reg[17]  =       {7'd3 , 9'b0_0110_1111        };
//-------------------------------------------------------

endmodule
