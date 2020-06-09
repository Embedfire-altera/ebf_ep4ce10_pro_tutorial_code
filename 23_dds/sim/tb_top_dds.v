`timescale  1ns/1ns
/////////////////////////////////////////////////////////////////////////
// Author        : EmbedFire
// Create Date   : 2019/07/10
// Module Name   : tb_top_dds
// Project Name  : top_dds
// Target Devices: Altera EP4CE10F17C8N
// Tool Versions : Quartus 13.0
// Description   : DDS信号发生器仿真文件
// 
// Revision      : V1.0
// Additional Comments:
// 
// 实验平台: 野火_征途Pro_FPGA开发板
// 公司    : http://www.embedfire.com
// 论坛    : http://www.firebbs.cn
// 淘宝    : https://fire-stm32.taobao.com
////////////////////////////////////////////////////////////////////////

module  tb_top_dds();

//**************************************************************//
//*************** Parameter and Internal Signal ****************//
//**************************************************************//
//wire  define
wire            dac_clk;
wire    [7:0]   dac_data;

//reg   define
reg             sys_clk;
reg             sys_rst_n;
reg     [3:0]   key;

//defparam  define
defparam
    top_dds_inst.key_control_inst.key_unshake_inst3.CNT_KEY_MAX = 5;
defparam
    top_dds_inst.key_control_inst.key_unshake_inst2.CNT_KEY_MAX = 5;
defparam
    top_dds_inst.key_control_inst.key_unshake_inst1.CNT_KEY_MAX = 5;
defparam
    top_dds_inst.key_control_inst.key_unshake_inst0.CNT_KEY_MAX = 5;

//**************************************************************//
//************************** Main Code *************************//
//**************************************************************//
//sys_rst_n,sys_clk,key
initial
    begin
        sys_rst_n   =   1'b0;
        sys_clk     =   1'b0;
        #200;
        sys_rst_n   =   1'b1;
        #8000000;
        key = 4'b1110;
        #200;
        key = 4'b1111;
        #8000000;
        key = 4'b1101;
        #200;
        key = 4'b1111;
        #8000000;
        key = 4'b1011;
        #200;
        key = 4'b1111;
        #8000000;
        key = 4'b0111;
        #200;
        key = 4'b1111;
        #8000000;
        $stop;
    end

always #10 sys_clk = ~sys_clk;

//**************************************************************//
//************************ Instantiation ***********************//
//**************************************************************//
//------------- top_dds_inst -------------
top_dds top_dds_inst
(
    .sys_clk    (sys_clk    ),
    .sys_rst_n  (sys_rst_n  ),
    .key        (key        ),

    .dac_clk    (dac_clk    ),
    .dac_data   (dac_data   )
);

endmodule
