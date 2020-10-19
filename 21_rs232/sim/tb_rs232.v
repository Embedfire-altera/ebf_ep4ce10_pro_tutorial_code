`timescale  1ns/1ns
////////////////////////////////////////////////////////////////////////
// Author        : EmbedFire
// Create Date   : 2019/06/12
// Module Name   : tb_rs232
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

module  tb_rs232();

//********************************************************************//
//****************** Parameter and Internal Signal *******************//
//********************************************************************//
//wire  define
wire    tx          ;

//reg   define
reg     sys_clk     ;
reg     sys_rst_n   ;
reg     rx          ;

//********************************************************************//
//***************************** Main Code ****************************//
//********************************************************************//
//初始化系统时钟、全局复位和输入信号
initial begin
    sys_clk    = 1'b1;
    sys_rst_n <= 1'b0;
    rx        <= 1'b1;
    #20;
    sys_rst_n <= 1'b1;
end

//调用任务rx_byte
initial begin
    #200
    rx_byte();
end

//sys_clk:每10ns电平翻转一次，产生一个50MHz的时钟信号
always #10 sys_clk = ~sys_clk;

//创建任务rx_byte，本次任务调用rx_bit任务，发送8次数据，分别为0~7
task    rx_byte();  //因为不需要外部传递参数，所以括号中没有输入
    integer j;
    for(j=0; j<8; j=j+1)    //调用8次rx_bit任务，每次发送的值从0变化7
        rx_bit(j);
endtask

//创建任务rx_bit，每次发送的数据有10位，data的值分别为0到7由j的值传递进来
task    rx_bit(
    input   [7:0]   data
);
    integer i;
    for(i=0; i<10; i=i+1)   begin
        case(i)
            0: rx <= 1'b0;
            1: rx <= data[0];
            2: rx <= data[1];
            3: rx <= data[2];
            4: rx <= data[3];
            5: rx <= data[4];
            6: rx <= data[5];
            7: rx <= data[6];
            8: rx <= data[7];
            9: rx <= 1'b1;
        endcase
        #(5208*20); //每发送1位数据延时5208个时钟周期
    end
endtask

//********************************************************************//
//*************************** Instantiation **************************//
//********************************************************************//
//------------------------ rs232_inst ------------------------
rs232   rs232_inst
(
    .sys_clk    (sys_clk    ),  //input         sys_clk
    .sys_rst_n  (sys_rst_n  ),  //input         sys_rst_n
    .rx         (rx         ),  //input         rx

    .tx         (tx         )   //output        tx
);

endmodule


