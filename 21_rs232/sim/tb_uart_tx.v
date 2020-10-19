`timescale  1ns/1ns
/////////////////////////////////////////////////////////////////////////
// Author        : EmbedFire
// Create Date   : 2019/06/12
// Module Name   : tb_uart_tx
// Project Name  : rs232
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

module  tb_uart_tx();

//********************************************************************//
//****************** Parameter and Internal Signal *******************//
//********************************************************************//
//reg   define
reg         sys_clk;
reg         sys_rst_n;
reg [7:0]   pi_data;
reg         pi_flag;

//wire  define
wire        tx;

//********************************************************************//
//***************************** Main Code ****************************//
//********************************************************************//
//初始化系统时钟、全局复位
initial begin
        sys_clk    = 1'b1;
        sys_rst_n <= 1'b0;
        #20;
        sys_rst_n <= 1'b1;
end

//模拟发送7次数据，分别为0~7
initial begin
        pi_data <= 8'b0;
        pi_flag <= 1'b0;
        #200
        //发送数据0
        pi_data <= 8'd0;
        pi_flag <= 1'b1;
        #20
        pi_flag <= 1'b0;
//每发送1bit数据需要5208个时钟周期，一帧数据为10bit
//所以需要数据延时(5208*20*10)后再产生下一个数据
        #(5208*20*10);
        //发送数据1
        pi_data <= 8'd1;
        pi_flag <= 1'b1;
        #20
        pi_flag <= 1'b0;
        #(5208*20*10);
        //发送数据2
        pi_data <= 8'd2;
        pi_flag <= 1'b1;
        #20
        pi_flag <= 1'b0;
        #(5208*20*10);
        //发送数据3
        pi_data <= 8'd3;
        pi_flag <= 1'b1;
        #20
        pi_flag <= 1'b0;
        #(5208*20*10);
        //发送数据4
        pi_data <= 8'd4;
        pi_flag <= 1'b1;
        #20
        pi_flag <= 1'b0;
        #(5208*20*10);
        //发送数据5
        pi_data <= 8'd5;
        pi_flag <= 1'b1;
        #20
        pi_flag <= 1'b0;
        #(5208*20*10);
        //发送数据6
        pi_data <= 8'd6;
        pi_flag <= 1'b1;
        #20
        pi_flag <= 1'b0;
        #(5208*20*10);
        //发送数据7
        pi_data <= 8'd7;
        pi_flag <= 1'b1;
        #20
        pi_flag <= 1'b0;
end

//sys_clk:每10ns电平翻转一次，产生一个50MHz的时钟信号
always #10 sys_clk = ~sys_clk;

//********************************************************************//
//*************************** Instantiation **************************//
//********************************************************************//
//------------------------uart_rx_inst------------------------
uart_tx uart_tx_inst(
        .sys_clk    (sys_clk    ),  //input           sys_clk
        .sys_rst_n  (sys_rst_n  ),  //input           sys_rst_n
        .pi_data    (pi_data    ),  //output  [7:0]   pi_data
        .pi_flag    (pi_flag    ),  //output          pi_flag

        .tx         (tx         )   //input           tx
);

endmodule
