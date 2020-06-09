`timescale  1ns/1ns
////////////////////////////////////////////////////////////////////////
// Author        : EmbedFire
// Create Date   : 2019/06/12
// Module Name   : complex_fsm
// Project Name  : complex_fsm
// Target Devices: Altera EP4CE10F17C8
// Tool Versions : Quartus 13.0
// Description   : 复杂状态机
// 
// Revision      : V1.0
// Additional Comments:
// 
// 实验平台: 野火_征途Pro_FPGA开发板
// 公司    : http://www.embedfire.com
// 论坛    : http://www.firebbs.cn
// 淘宝    : https://fire-stm32.taobao.com
////////////////////////////////////////////////////////////////////////

module  complex_fsm
(
    input   wire    sys_clk         ,   //系统时钟50MHz
    input   wire    sys_rst_n       ,   //全局复位
    input   wire    pi_money_one    ,   //投币1元
    input   wire    pi_money_half   ,   //投币0.5元
                    
    output  reg     po_money        ,   //po_money为1时表示找零
                                        //po_money为0时表示不找零
    output  reg     po_cola             //po_cola为1时出可乐
                                        //po_cola为0时不出可乐
);

//********************************************************************//
//****************** Parameter and Internal Signal *******************//
//********************************************************************//

//parameter define
//只有五种状态，使用独热码
parameter   IDLE     = 5'b00001;
parameter   HALF     = 5'b00010;
parameter   ONE      = 5'b00100;
parameter   ONE_HALF = 5'b01000;
parameter   TWO      = 5'b10000;

//reg   define
reg     [4:0]   state;

//wire  define
wire    [1:0]   pi_money;

//********************************************************************//
//***************************** Main Code ****************************//
//********************************************************************//

//pi_money:为了减少变量的个数，我们用位拼接把输入的两个1bit信号拼接成1个2bit信号
//投币方式可以为：不投币（00）、投0.5元（01）、投1元（10），每次只投一个币
assign pi_money = {pi_money_one, pi_money_half};

//第一段状态机，描述当前状态state如何根据输入跳转到下一状态
always@(posedge sys_clk or negedge sys_rst_n)
    if(sys_rst_n == 1'b0)
        state <= IDLE;  //任何情况下只要按复位就回到初始状态
    else	case(state)
                IDLE    : if(pi_money == 2'b01)   //判断一种输入情况
                              state <= HALF;
                          else    if(pi_money == 2'b10)//判断另一种输入情况
                              state <= ONE;
                          else
                              state <= IDLE;
    
                HALF    : if(pi_money == 2'b01)
                              state <= ONE;
                          else    if(pi_money == 2'b10)
                              state <= ONE_HALF;
                          else
                              state <= HALF;
    
                ONE     : if(pi_money == 2'b01)
                              state <= ONE_HALF;
                          else    if(pi_money == 2'b10)
                              state <= TWO;
                          else
                              state <= ONE;
    
                ONE_HALF: if(pi_money == 2'b01)
                              state <= TWO;
                          else    if(pi_money == 2'b10)
                              state <= IDLE;
                          else
                              state <= ONE_HALF;
    
                TWO     : if((pi_money == 2'b01) || (pi_money == 2'b10))
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
    else    if((state == TWO && pi_money == 2'b01) || (state == TWO && 
          pi_money == 2'b10) || (state == ONE_HALF && pi_money == 2'b10))
        po_cola <= 1'b1;
    else
        po_cola <= 1'b0;

//第二段状态机，描述当前状态state和输入pi_money如何影响po_money输出
always@(posedge sys_clk or negedge sys_rst_n)
    if(sys_rst_n ==	1'b0)
        po_money <= 1'b0;
    else if((state == TWO) && (pi_money == 2'b10))
        po_money <= 1'b1;
    else
        po_money <= 1'b0;

endmodule
