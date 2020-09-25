`timescale  1ns/1ns
////////////////////////////////////////////////////////////////////////
// Author        : EmbedFire
// Create Date   : 2019/03/19
// Module Name   : tb_sobel
// Project Name  : sobel
// Target Devices: Altera EP4CE10F17C8N
// Tool Versions : Quartus 13.0
// Description   : sobel仿真文件
// 
// Revision      : V1.0
// Additional Comments:
// 
// 实验平台: 野火_征途Pro_FPGA开发板
// 公司    : http://www.embedfire.com
// 论坛    : http://www.firebbs.cn
// 淘宝    : https://fire-stm32.taobao.com
////////////////////////////////////////////////////////////////////////

module  tb_sobel();
//wire define
wire          tx    ;
wire          hsync ;
wire          vsync ;
wire  [7:0]   rgb   ;

//reg define
reg           clk   ;
reg           rst_n ;
reg           rx    ;
reg   [7:0]   data_mem [9999:0] ;  //data_mem是一个存储器，相当于一个ram

//读取sim文件夹下面的data.txt文件，并把读出的数据定义为data_mem
initial
  $readmemh
    ("E:/GitLib/Altera/EP4CE10/base_code/9_sobel/matlab/data_test.txt",data_mem);

//时钟、复位信号
initial
  begin
    clk     =   1'b1  ;
    rst_n   <=  1'b0  ;
    #200
    rst_n   <=  1'b1  ;
  end

always  #10 clk = ~clk;


initial
  begin
    rx  <=  1'b1;
    #200
    rx_byte();
  end

task  rx_byte();
  integer j;
  for(j=0;j<10000;j=j+1)
    rx_bit(data_mem[j]);
endtask

task  rx_bit(input[7:0] data);  //data是data_mem[j]的值。
  integer i;
    for(i=0;i<10;i=i+1)
      begin
        case(i)
          0:  rx  <=  1'b0   ;  //起始位
          1:  rx  <=  data[0];
          2:  rx  <=  data[1];
          3:  rx  <=  data[2];
          4:  rx  <=  data[3];
          5:  rx  <=  data[4];
          6:  rx  <=  data[5];
          7:  rx  <=  data[6];
          8:  rx  <=  data[7];  //上面8个发送的是数据位
          9:  rx  <=  1'b1   ;  //停止位
        endcase
        #1040;                  //一个波特时间=sclk周期*波特计数器
      end
endtask

//重定义defparam,用于修改参数,缩短仿真时间
defparam    sobel_inst.uart_rx_inst.CLK_FREQ    =   500000;
defparam    sobel_inst.uart_tx_inst.CLK_FREQ    =   500000;

//-------------sobel_inst-------------
sobel   sobel_inst(
    .sys_clk    (clk    ),  //input           sys_clk
    .sys_rst_n  (rst_n  ),  //input           sys_rst_n
    .rx         (rx     ),  //input           rx
                            
    .hsync      (hsync  ),  //output          hsync
    .vsync      (vsync  ),  //output          vsync
    .rgb        (rgb    ),  //output  [7:0]   rgb
    .tx         (tx     )   //output          tx
);

endmodule