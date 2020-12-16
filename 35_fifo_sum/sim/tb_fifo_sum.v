`timescale  1ns/1ns
////////////////////////////////////////////////////////////////////////
// Author        : EmbedFire
// Create Date   : 2018/03/18
// Module Name   : tb_fifo_sum
// Project Name  : fifo_sum
// Target Devices: Altera EP4CE10F17C8N
// Tool Versions : Quartus 13.0
// Description   : SUM求和模块仿真
// 
// Revision      : V1.0
// Additional Comments:
// 
// 实验平台: 野火_征途Pro_FPGA开发板
// 公司    : http://www.embedfire.com
// 论坛    : http://www.firebbs.cn
// 淘宝    : https://fire-stm32.taobao.com
////////////////////////////////////////////////////////////////////////

module  tb_fifo_sum();

//********************************************************************//
//****************** Parameter and Internal Signal *******************//
//********************************************************************//
//wire  define
wire            tx      ;

//reg   define
reg             clk     ;
reg             rst_n   ;
reg             rx      ;
reg     [7:0]   data_men[2499:0]    ;

//********************************************************************//
//***************************** Main Code ****************************//
//********************************************************************//
//读取数据
initial
   $readmemh("E:/sources/fifo_sum/matlab/fifo_data.txt",data_men);

//生成时钟和复位信号
initial
  begin
    clk = 1'b1;
    rst_n <=  1'b0;
    #30
    rst_n <=  1'b1;
  end

always  #10 clk = ~clk;

//rx赋初值,调用rx_byte
initial
  begin
    rx  <=  1'b1;
    #200
    rx_byte();
  end

//rx_byte
task  rx_byte();
  integer j;
    for(j=0;j<2500;j=j+1)
      rx_bit(data_men[j]);
  endtask

//rx_bit
task  rx_bit(input[7:0] data);//data是data_men[j]的值。
  integer i;
    for(i=0;i<10;i=i+1)
      begin
        case(i)
          0:  rx  <=  1'b0;     //起始位
          1:  rx  <=  data[0];
          2:  rx  <=  data[1];
          3:  rx  <=  data[2];
          4:  rx  <=  data[3];
          5:  rx  <=  data[4];
          6:  rx  <=  data[5];
          7:  rx  <=  data[6];
          8:  rx  <=  data[7];  //上面8个发送的是数据位
          9:  rx  <=  1'b1;     //停止位
        endcase
        #1040;
      end
endtask

//重定义defparam,用于修改参数
defparam fifo_sum_inst.uart_rx_inst.CLK_FREQ    = 500000  ;
defparam fifo_sum_inst.uart_tx_inst.CLK_FREQ    = 500000  ;

//********************************************************************//
//*************************** Instantiation **************************//
//********************************************************************//
//------------- fifo_sum_inst --------------
fifo_sum    fifo_sum_inst
(
  .sys_clk      (clk    ),
  .sys_rst_n    (rst_n  ),
  .rx           (rx     ),

  .tx           (tx     )
);

endmodule
