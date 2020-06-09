`timescale  1ns/1ns
////////////////////////////////////////////////////////////////////////
// Author        : EmbedFire
// Create Date   : 2019/03/14
// Module Name   : tb_uart_vga_pic
// Project Name  : vga_rom_pic
// Target Devices: Altera EP4CE10F17C8N
// Tool Versions : Quartus 13.0
// Description   : uart_vga_pic仿真文件
// 
// Revision      : V1.0
// Additional Comments:
// 
// 实验平台: 野火_征途Pro_FPGA开发板
// 公司    : http://www.embedfire.com
// 论坛    : http://www.firebbs.cn
// 淘宝    : https://fire-stm32.taobao.com
////////////////////////////////////////////////////////////////////////

module  tb_vga_uart_pic();

//********************************************************************//
//****************** Parameter and Internal Signal *******************//
//********************************************************************//
//wire define
wire          hsync ;
wire          vsync ;
wire  [7:0]   rgb   ;

//reg define
reg             sys_clk     ;
reg             sys_rst_n   ;
reg             rx          ;
reg     [7:0]   data_mem [9999:0] ;  //data_mem是一个存储器，相当于一个ram

//********************************************************************//
//***************************** Main Code ****************************//
//********************************************************************//

//读取sim文件夹下面的data.txt文件，并把读出的数据定义为data_mem
initial
    $readmemh("F:/GitLib/Altera/EP4CE10F17C8/ZT_Pro/A/4_base_code/30_vga_uart_pic/matlab/data_test.txt",data_mem);

//时钟、复位信号
initial
  begin
    sys_clk     =   1'b1  ;
    sys_rst_n   <=  1'b0  ;
    #200
    sys_rst_n   <=  1'b1  ;
  end

always  #10 sys_clk = ~sys_clk;

//rx
initial
    begin
        rx  <=  1'b1;
        #200
        rx_byte();
    end

//rx_byte
task    rx_byte();
    integer j;
    for(j=0;j<10000;j=j+1)
        rx_bit(data_mem[j]);
endtask

//rx_bit
task    rx_bit(input[7:0] data);  //data是data_mem[j]的值。
    integer i;
        for(i=0;i<10;i=i+1)
        begin
            case(i)
                0:  rx  <=  1'b0   ;    //起始位
                1:  rx  <=  data[0];
                2:  rx  <=  data[1];
                3:  rx  <=  data[2];
                4:  rx  <=  data[3];
                5:  rx  <=  data[4];
                6:  rx  <=  data[5];
                7:  rx  <=  data[6];
                8:  rx  <=  data[7];    //上面8个发送的是数据位
                9:  rx  <=  1'b1   ;    //停止位
            endcase
            #1040;                      //一个波特时间=sys_clk周期*波特计数器
        end
endtask

//重定义defparam,用于修改参数,缩短仿真时间
defparam    vga_uart_pic_inst.uart_rx_inst.BAUD_CNT_END      = 52;
defparam    vga_uart_pic_inst.uart_rx_inst.BAUD_CNT_END_HALF = 26;

//********************************************************************//
//*************************** Instantiation **************************//
//********************************************************************//

//------------- vga_uart_pic_jump -------------
vga_uart_pic  vga_uart_pic_inst
(
    .sys_clk    (sys_clk    ),  //输入工作时钟,频率50MHz,1bit
    .sys_rst_n  (sys_rst_n  ),  //输入复位信号,低电平有效,1bit
    .rx         (rx         ),  //输入串口的图片数据,1bit

    .hsync      (hsync      ),  //输出行同步信号,1bit
    .vsync      (vsync      ),  //输出场同步信号,1bit
    .rgb        (rgb        )   //输出像素信息,8bit

);

endmodule