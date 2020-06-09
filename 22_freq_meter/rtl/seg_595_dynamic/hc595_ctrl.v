`timescale  1ns/1ns
////////////////////////////////////////////////////////////////////////
// Author        : EmbedFire
// Create Date   : 2019/11/28
// Module Name   : hc595_ctrl
// Project Name  : freq_meter
// Target Devices: Altera EP4CE10F17C8N
// Tool Versions : Quartus 13.0
// Description   : 595控制模块
//
// Revision      : V1.0
// Additional Comments:
// 
// 实验平台: 野火_征途Pro_FPGA开发板
// 公司    : http://www.embedfire.com
// 论坛    : http://www.firebbs.cn
// 淘宝    : https://fire-stm32.taobao.com
////////////////////////////////////////////////////////////////////////

module  hc595_ctrl
(
    input   wire            sys_clk     ,   //系统时钟，频率50MHz
    input   wire            sys_rst_n   ,   //复位信号，低有效
    input   wire    [5:0]   sel         ,   //数码管位选信号
    input   wire    [7:0]   seg         ,   //数码管段选信号

    output  reg             stcp        ,   //数据存储器时钟
    output  reg             shcp        ,   //移位寄存器时钟
    output  reg             ds          ,   //串行数据输入
    output  wire            oe              //使能信号

);

//********************************************************************//
//****************** Parameter and Internal Signal *******************//
//********************************************************************//
//reg   define
reg             cnt     ;   //分频计数器
reg     [4:0]   state   ;   //状态机状态

//********************************************************************//
//***************************** Main Code ****************************//
//********************************************************************//

assign  oe  =   1'b0;   //将输出使能信号赋值位0，让其一直正常输出即可

//分频计数器：0~1循环计数（也可看做是二分频时钟）
always@(posedge sys_clk or  negedge sys_rst_n)
    if(sys_rst_n == 1'b0)
        cnt <=  1'b0;
    else    if(cnt == 1'b1)
        cnt <=  1'b0;
    else
        cnt <=  cnt +   1'b1;

//state：50MHz时钟每计2个数为一个状态，产生28个状态（0~27）
always@(posedge sys_clk or  negedge sys_rst_n)
    if(sys_rst_n == 1'b0)
        state   <=  5'd0;
    else    if(cnt == 1'b1 && state == 5'd27)
        state   <=  5'd0;
    else    if(cnt  ==  1'b1)
        state   <=  state   +   1'b1;
    else
        state   <=  state;

//各状态下输出信号赋值
//每2个状态传输一个数据，每个状态为2个系统时钟，即4个系统时钟传输一个
//数据，从而实现系统时钟四分频传输数据
always@(posedge sys_clk or  negedge sys_rst_n)
    if(sys_rst_n == 1'b0)
        begin
            stcp    <=  1'b0;
            shcp    <=  1'b0;
            ds      <=  1'b0;
        end
    else    case(state)
        5'd0:
            begin
                stcp    <=  1'b1;   //拉高stcp时钟开始传输数据
                shcp    <=  1'b0;
                ds      <=  sel[0]; //传输第1位数据
            end
        5'd1:
            begin
                stcp    <=  1'b0; //产生上升沿后拉低
                shcp    <=  1'b1; //数据稳定时拉高
            end
        5'd2:
            begin
                shcp    <=  1'b0;   //每传输完一位数据拉低一次
                ds      <=  sel[1]; //传输第2位数据
            end
        5'd3:
            begin
                shcp    <=  1'b1;
            end
        5'd4:
            begin
                shcp    <=  1'b0;
                ds      <=  sel[2]; //传输第3位数据
            end
        5'd5:
            begin
                shcp    <=  1'b1;
            end
        5'd6:
            begin
                shcp    <=  1'b0;
                ds      <=  sel[3]; //传输第4位数据
            end
        5'd7:
            begin
                shcp    <=  1'b1;
            end
        5'd8:
            begin
                shcp    <=  1'b0;
                ds      <=  sel[4]; //传输第5位数据
            end
        5'd9:
            begin
                shcp    <=  1'b1;
            end
        5'd10:
            begin
                shcp    <=  1'b0;
                ds      <=  sel[5]; //传输第6位数据
            end
        5'd11:
            begin
                shcp    <=  1'b1;
            end
        5'd12:
            begin
                shcp    <=  1'b0;
                ds      <=  seg[7]; //传输第7位数据
            end
        5'd13:
            begin
                shcp    <=  1'b1;
            end
        5'd14:
            begin
                shcp    <=  1'b0;
                ds      <=  seg[6]; //传输第8位数据
            end
        5'd15:
            begin
                shcp    <=  1'b1;
            end
        5'd16:
            begin
                shcp    <=  1'b0;
                ds      <=  seg[5]; //传输第9位数据
            end
        5'd17:
            begin
                shcp    <=  1'b1;
            end
        5'd18:
            begin
                shcp    <=  1'b0;
                ds      <=  seg[4]; //传输第10位数据
            end
        5'd19:
            begin
                shcp    <=  1'b1;
            end
        5'd20:
            begin
                shcp    <=  1'b0;
                ds      <=  seg[3]; //传输第11位数据
            end
        5'd21:
            begin
                shcp    <=  1'b1;
            end
        5'd22:
            begin
                shcp    <=  1'b0;
                ds      <=  seg[2]; //传输第12位数据
            end
        5'd23:
            begin
                shcp    <=  1'b1;
            end
        5'd24:
            begin
                shcp    <=  1'b0;
                ds      <=  seg[1]; //传输第13位数据
            end
        5'd25:
            begin
                shcp    <=  1'b1;
            end
        5'd26:
            begin
                shcp    <=  1'b0;
                ds      <=  seg[0]; //传输第14位数据
            end
        5'd27:
            begin
                shcp    <=  1'b1;
            end
    endcase

endmodule
