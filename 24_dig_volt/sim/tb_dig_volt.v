`timescale  1ns/1ns
//////////////////////////////////////////////////////////////////////////////////
// Author: EmbedFire
// Create Date: 2019/07/10
// Module Name: dig_volt
// Project Name: dig_volt
// Target Devices: Altera EP4CE10F17C8N
// Tool Versions: Quartus 13.0
// Description: 电压表顶层模块
//
// Revision:V1.1
// Additional Comments:
//
// 实验平台:野火FPGA开发板
// 公司    :http://www.embedfire.com
// 论坛    :http://www.firebbs.cn
// 淘宝    :https://fire-stm32.taobao.com
//////////////////////////////////////////////////////////////////////////////////

module  tb_dig_volt();
//wire  define
wire            ad_clk  ;
wire            shcp    ;
wire            stcp    ;
wire            ds      ;
wire            oe      ;

//reg   define
reg             sys_clk     ;
reg             clk_sample  ;
reg             sys_rst_n   ;
reg             data_en     ;
reg     [7:0]   ad_data_reg ;
reg     [7:0]   ad_data     ;

//sys_rst_n,sys_clk,ad_data
initial
    begin
        sys_clk     =   1'b1;
        clk_sample  =   1'b1;
        sys_rst_n   =   1'b0;
        #200;
        sys_rst_n   =   1'b1;
        data_en     =   1'b0;
        #499990;
        data_en     =   1'b1; 
    end

always #10 sys_clk = ~sys_clk;
always #40 clk_sample = ~clk_sample;

always@(posedge clk_sample or negedge sys_rst_n)
    if(sys_rst_n == 1'b0)
        ad_data_reg <=  8'd0;
    else    if(data_en == 1'b1)
        ad_data_reg <=  ad_data_reg + 1'b1;
    else
        ad_data_reg <=  8'd0;

always@(posedge clk_sample or negedge sys_rst_n)
    if(sys_rst_n == 1'b0)
        ad_data <=  8'd0;
    else    if(data_en == 1'b0)
        ad_data <=  8'd125;
    else    if(data_en == 1'b1)
        ad_data <=  ad_data_reg;
    else
        ad_data <=  ad_data;

//------------- dig_volt_inst -------------
dig_volt    dig_volt_inst
(
    .sys_clk     (sys_clk   ),
    .sys_rst_n   (sys_rst_n ),
    .ad_data     (ad_data   ),

    .ad_clk      (ad_clk    ),
    .shcp        (shcp      ),
    .stcp        (stcp      ),
    .ds          (ds        ),
    .oe          (oe        )
);

endmodule