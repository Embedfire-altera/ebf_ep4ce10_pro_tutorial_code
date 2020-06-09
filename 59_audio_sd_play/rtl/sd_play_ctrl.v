`timescale  1ns/1ns
////////////////////////////////////////////////////////////////////////
// Author        : EmbedFire
// Create Date   : 2019/12/05
// Module Name   : sd_play_ctrl
// Project Name  : audio_sd_play
// Target Devices: Altera EP4CE10F17C8N
// Tool Versions : Quartus 13.0
// Description   : SD卡音乐播放控制模块
// 
// Revision      : V1.0
// Additional Comments:
// 
// 实验平台: 野火_征途Pro_FPGA开发板
// 公司    : http://www.embedfire.com
// 论坛    : http://www.firebbs.cn
// 淘宝    : https://fire-stm32.taobao.com
////////////////////////////////////////////////////////////////////////

module  sd_play_ctrl
#(   
    parameter   INIT_ADDR       =   'd472896 ,   //音乐存放起始扇区地址
    parameter   AUDIO_SECTOR    =   'd111913     //播放的音乐占用的扇区数
)
(
    input   wire            sd_clk        ,   //SD卡时钟信号
    input   wire            audio_bclk    ,   //WM8978音频时钟
    input   wire            sys_rst_n     ,   //复位信号，低有效
    input   wire            sd_init_end   ,   //sd卡初始化完成信号
    input   wire            rd_busy       ,   //读操作忙信号
    input   wire            send_done     ,   //一次音频发送完成信号
    input   wire    [15:0]  fifo_data     ,   //读fifo数据
    input   wire    [10:0]  fifo_data_cnt ,   //fifo内剩余数据量
    input   wire            cfg_done      ,   //寄存器配置完成信号

    output  reg             rd_en         ,   //数据读使能信号
    output  wire    [31:0]  rd_addr       ,   //读数据扇区地址
    output  reg     [15:0]  dac_data          //输出WM8978音频数据

);

//********************************************************************//
//***************** Parameter and Internal Signal ********************//
//********************************************************************//

//reg   define
reg             rd_busy_d0      ;   //读操作忙信号打一拍信号
reg             rd_busy_d1      ;   //读操作忙信号打两拍信号
reg     [16:0]  sector_cnt      ;   //读扇区计数器
reg     [1:0]   state           ;   //状态机状态

//wire  define
wire            rd_busy_fall    ;   //读操作忙信号下降沿

//********************************************************************//
//******************************* Main Code **************************//
//********************************************************************//

//sd卡读操作忙信号下降沿，用于控制扇区地址
assign  rd_busy_fall  =  ~rd_busy_d0  &  rd_busy_d1;

//rd_addr：读地址为首地址加扇区计数器值
assign  rd_addr =   INIT_ADDR   +   sector_cnt;

//对读忙操作信号打拍
always@(posedge sd_clk  or  negedge sys_rst_n)
    if(sys_rst_n == 1'b0)
        begin
            rd_busy_d0  <=  1'b0;
            rd_busy_d1  <=  1'b0;
        end
    else
        begin
            rd_busy_d0  <=  rd_busy;
            rd_busy_d1  <=  rd_busy_d0;
        end

//dac_data：发送完一次数据后，将读出fifo的数据给dac_data
//WAV音乐数据格式低字节在前，而WM8978音频是从高字节输入，需换位
always@(posedge audio_bclk  or  negedge sys_rst_n)
    if(sys_rst_n == 1'b0)
        dac_data    <=  16'd0;
    else    if(send_done == 1'b1)
        dac_data    <=  {fifo_data[7:0],fifo_data[15:8]};
    else
        dac_data    <=  dac_data;

//生成读使能以及扇区计数器
always@(posedge sd_clk  or  negedge sys_rst_n)
    if(sys_rst_n == 1'b0)
        begin
            state   <=  2'b0;
            sector_cnt  <=  17'd0;
            rd_en       <=  1'b0;
        end
    else
        case(state)
        2'd0:
    //SD卡初始化话完成后拉高读使能信号
            if(sd_init_end == 1'b1  && cfg_done == 1'b1 )
                begin
                    rd_en   <=  1'b1;
                    state   <=  state + 1'b1;
                end
            else
                begin
                    rd_en   <=  1'b0;
                    state   <=  2'd0;
                end
        2'd1:
    //扇区计数器计到音乐所占扇区数时，归0重新播放
            if(sector_cnt   ==  AUDIO_SECTOR)
                begin
                    rd_en       <=  1'b0;
                    sector_cnt  <=  17'd0;
                    state   <=  2'd0;
                end
    //一个扇区读完之后，扇区加1
            else    if(rd_busy_fall == 1'b1)
                begin
                    rd_en       <=  1'b0;
                    sector_cnt  <=  sector_cnt  +  17'd1;
                    state   <=  state + 1'b1;
                end
            else
                begin
                    rd_en       <=  1'b0;
                    sector_cnt  <=  sector_cnt;
                    state   <=  2'd1;
                end
        2'd2:
    //当fifo内数据量低于256个时，拉高一个读使能信号并回到状态1
            if(fifo_data_cnt < 11'd512)
                begin
                    rd_en   <=  1'd1;
                    state   <=  2'd1;
                end
            else
                begin
                    rd_en   <=  1'd0;
                    state   <=  2'd2;
                end
        default:    state   <=  2'b0;
        endcase

endmodule
