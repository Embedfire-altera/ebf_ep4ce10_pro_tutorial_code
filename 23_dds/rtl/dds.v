`timescale  1ns/1ns
/////////////////////////////////////////////////////////////////////////
// Author        : EmbedFire
// Create Date   : 2019/07/10
// Module Name   : dds
// Project Name  : top_dds
// Target Devices: Altera EP4CE10F17C8N
// Tool Versions : Quartus 13.0
// Description   : DDS信号发生器
// 
// Revision      : V1.0
// Additional Comments:
// 
// 实验平台: 野火_征途Pro_FPGA开发板
// 公司    : http://www.embedfire.com
// 论坛    : http://www.firebbs.cn
// 淘宝    : https://fire-stm32.taobao.com
////////////////////////////////////////////////////////////////////////

module  dds
(
    input   wire            sys_clk     ,   //系统时钟,50MHz
    input   wire            sys_rst_n   ,   //复位信号,低电平有效
    input   wire    [3:0]   wave_select ,   //输出波形选择

    output  wire    [7:0]   data_out        //波形输出
);

//********************************************************************//
//****************** Parameter and Internal Signal *******************//
//********************************************************************//
//parameter define
parameter   sin_wave    =   4'b0001     ,   //正弦波
            squ_wave    =   4'b0010     ,   //方波
            tri_wave    =   4'b0100     ,   //三角波
            saw_wave    =   4'b1000     ;   //锯齿波
parameter   FREQ_CTRL   =   32'd42949   ,   //相位累加器单次累加值
            PHASE_CTRL  =   12'd1024    ;   //相位偏移量

//reg   define
reg     [31:0]  fre_add     ;   //相位累加器
reg     [11:0]  rom_addr_reg;   //相位调制后的相位码
reg     [13:0]  rom_addr    ;   //ROM读地址

//********************************************************************//
//***************************** Main Code ****************************//
//********************************************************************//
//fre_add:相位累加器
always@(posedge sys_clk or negedge sys_rst_n)
    if(sys_rst_n == 1'b0)
        fre_add <=  32'd0;
    else
        fre_add <=  fre_add + FREQ_CTRL;

//rom_addr:ROM读地址
always@(posedge sys_clk or negedge sys_rst_n)
    if(sys_rst_n == 1'b0)
        rom_addr <= 14'd0;
    else
    case(wave_select)
        sin_wave:
            begin
                rom_addr_reg    <=  fre_add[31:20] + PHASE_CTRL;
                rom_addr        <=  rom_addr_reg;
            end     //正弦波
        squ_wave:
            begin
                rom_addr_reg    <=  fre_add[31:20] + PHASE_CTRL;
                rom_addr        <=  rom_addr_reg + 14'd4096;
            end     //方波
        tri_wave:
            begin
                rom_addr_reg    <=  fre_add[31:20] + PHASE_CTRL;
                rom_addr        <=  rom_addr_reg + 14'd8192;
            end     //三角波
        saw_wave:
        begin
                rom_addr_reg    <=  fre_add[31:20] + PHASE_CTRL;
                rom_addr        <=  rom_addr_reg + 14'd12288;
            end     //锯齿波
        default:
            begin
                rom_addr_reg    <=  fre_add[31:20] + PHASE_CTRL;
                rom_addr        <=  rom_addr_reg;
            end     //正弦波
    endcase

//********************************************************************//
//*************************** Instantiation **************************//
//********************************************************************//
//------------------------- rom_wave_inst ------------------------
rom_wave    rom_wave_inst
(
    .address    (rom_addr   ),  //ROM读地址
    .clock      (sys_clk    ),  //读时钟

    .q          (data_out   )   //读出波形数据
);

endmodule
