`timescale  1ns/1ns
////////////////////////////////////////////////////////////////////////
// Author        : EmbedFire
// Create Date   : 2019/05/12
// Module Name   : simple_fsm
// Project Name  : simple_fsm
// Target Devices: Altera EP4CE10F17C8
// Tool Versions : Quartus 13.0
// Description   : 简单状态机
//
// Revision      : V1.0
// Additional Comments:
// 
// 实验平台: 野火_征途Pro_FPGA开发板
// 公司    : http://www.embedfire.com
// 论坛    : http://www.firebbs.cn
// 淘宝    : https://fire-stm32.taobao.com
////////////////////////////////////////////////////////////////////////

module  simple_fsm
(
    input   wire    sys_clk     ,   //系统时钟50MHz
    input   wire    sys_rst_n   ,   //全局复位
    input   wire    pi_money    ,   //投币方式可以为：不投币（0）、投1元（1）

    output  reg     po_cola         //po_cola为1时出可乐，po_cola为0时不出可乐
);

//********************************************************************//
//****************** Parameter and Internal Signal *******************//
//********************************************************************//

//parameter define
//只有三种状态，使用独热码
parameter   IDLE = 3'b001;
parameter   ONE  = 3'b010;
parameter   TWO  = 3'b100;

//reg   define
reg     [2:0]   state;

//********************************************************************//
//***************************** Main Code ****************************//
//********************************************************************//

//第一段状态机，描述当前状态state如何根据输入跳转到下一状态
always@(posedge sys_clk or negedge sys_rst_n)
    if(sys_rst_n == 1'b0)
        state <= IDLE;  //任何情况下只要按复位就回到初始状态
    else    case(state)
                IDLE    :   if(pi_money == 1'b1)//判断输入情况
                                state <= ONE;
                            else
                                state <= IDLE;

                ONE     :   if(pi_money == 1'b1)
                                state <= TWO;
                            else
                                state <= ONE;

                TWO     :   if(pi_money == 1'b1)
                                state <= IDLE;
                            else
                                state <= TWO;
                //如果状态机跳转到编码的状态之外也回到初始状态
                default :       state <= IDLE;
            endcase

//第二段状态机，描述当前状态state和输入pi_money如何影响po_cola输出
always@(posedge sys_clk or negedge sys_rst_n)
    if(sys_rst_n == 1'b0)
        po_cola <= 1'b0;
    else    if((state == TWO) && (pi_money == 1'b1))
        po_cola <= 1'b1;
    else
        po_cola <= 1'b0;

endmodule
