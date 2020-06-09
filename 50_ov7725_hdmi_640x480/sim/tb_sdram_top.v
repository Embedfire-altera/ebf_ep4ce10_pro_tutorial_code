`timescale  1ns/1ns
////////////////////////////////////////////////////////////////////////
// Author        : EmbedFire
// Create Date   : 2019/09/25
// Module Name   : tb_sdram_top
// Project Name  : ov7725_hdmi_640x480
// Target Devices: Altera EP4CE10F17C8N
// Tool Versions : Quartus 13.0
// Description   : SDRAM控制器仿真
// 
// Revision      : V1.0
// Additional Comments:
// 
// 实验平台: 野火_征途Pro_FPGA开发板
// 公司    : http://www.embedfire.com
// 论坛    : http://www.firebbs.cn
// 淘宝    : https://fire-stm32.taobao.com
////////////////////////////////////////////////////////////////////////

module  tb_sdram_top();

//********************************************************************//
//****************** Internal Signal and Defparam ********************//
//********************************************************************//
//wire define
//clk_gen
wire            clk_25m         ;   //PLL输出50M时钟
wire            clk_100m        ;   //PLL输出100M时钟
wire            clk_100m_shift  ;   //PLL输出100M时钟,相位偏移-30deg
wire            locked          ;   //PLL时钟锁定信号
wire            rst_n           ;   //复位信号,低有效
//sdram
wire            sdram_clk       ;   //SDRAM时钟
wire            sdram_cke       ;   //SDRAM时钟使能信号
wire            sdram_cs_n      ;   //SDRAM片选信号
wire            sdram_ras_n     ;   //SDRAM行选通信号
wire            sdram_cas_n     ;   //SDRAM列选题信号
wire            sdram_we_n      ;   //SDRAM写使能信号
wire    [1:0]   sdram_ba        ;   //SDRAM L-Bank地址
wire    [12:0]  sdram_addr      ;   //SDRAM地址总线
wire    [15:0]  sdram_dq        ;   //SDRAM数据总线
wire            sdram_dqm       ;   //SDRAM数据总线
//uart_rx
wire            rx_flag         ;
wire    [7:0]   rx_data         ;
//vga_ctrl
wire            data_req        ;
wire    [15:0]  data_in         ;



wire    [9:0]   rd_fifo_num     ;   //fifo_ctrl模块中读fifo中的数据量
wire    [15:0]  rfifo_rd_data   ;   //fifo_ctrl模块中读fifo读数据

//reg define
reg             sys_clk         ;   //系统时钟
reg             sys_rst_n       ;   //复位信号
reg             rx              ;   //串行数据接收信号
reg     [7:0]   data_mem [99:0] ;  //data_mem是一个存储器，相当于一个ram

//defparam
//重定义仿真模型中的相关参数
defparam uart_rx_inst.BAUD_CNT_END       = 26;
defparam uart_rx_inst.BAUD_CNT_END_HALF  = 13;
defparam sdram_model_plus_inst.addr_bits = 13;          //地址位宽
defparam sdram_model_plus_inst.data_bits = 16;          //数据位宽
defparam sdram_model_plus_inst.col_bits  = 9;           //列地址位宽
defparam sdram_model_plus_inst.mem_sizes = 2*1024*1024; //L-Bank容量

//重定义自动刷新模块自动刷新间隔时间计数最大值
defparam sdram_top_inst.sdram_ctrl_inst.sdram_a_ref_inst.CNT_REF_MAX = 40;

//********************************************************************//
//****************************** Main Code ***************************//
//********************************************************************//
//加载测试数据
initial
  $readmemh("E:/GitLib/Altera/EP4CE10/code/46_ov7725_vga_640x480/sim/test_data.txt",data_mem);
  
//时钟、复位信号
initial
  begin
    sys_clk     =   1'b1  ;
    sys_rst_n   <=  1'b0  ;
    #200
    sys_rst_n   <=  1'b1  ;
  end

always  #10 sys_clk = ~sys_clk;

//rst_n:复位信号
assign  rst_n = sys_rst_n & locked;

//模拟串口数据接收信号
initial
  begin
    rx  <=  1'b1;
    #200
    rx_byte();
  end

task  rx_byte();
  integer j;
  for(j=0;j<100;j=j+1)
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
        #1040;                  //一个波特时间=sys_clk周期*波特计数器
      end
endtask

//********************************************************************//
//*************************** Instantiation **************************//
//********************************************************************//

//------------- clk_gen_inst -------------
clk_gen clk_gen_inst (
    .inclk0     (sys_clk        ),
    .areset     (~sys_rst_n     ),
    .c0         (clk_100m       ),
    .c1         (clk_100m_shift ),
    .c2         (clk_25m        ),

    .locked     (locked         )
);

//------------- uart_rx_inst -------------
uart_rx uart_rx_inst(
    .sys_clk     (clk_25m  ),   //input             sys_clk
    .sys_rst_n   (rst_n     ),   //input             sys_rst_n
    .rx          (rx       ),   //input             rx

    .po_data     (rx_data  ),   //output    [7:0]   rx_data
    .po_flag     (rx_flag  )    //output            rx_flag
);

//------------- sdram_top_inst -------------
sdram_top   sdram_top_inst(
    .sys_clk            (clk_100m       ),  //sdram 控制器参考时钟
    .clk_out            (clk_100m_shift ),  //用于输出的相位偏移时钟
    .sys_rst_n          (rst_n          ),  //系统复位
//用户写端口
    .wr_fifo_wr_clk     (clk_25m        ),  //写端口FIFO: 写时钟
    .wr_fifo_wr_req     (rx_flag        ),  //写端口FIFO: 写使能
    .wr_fifo_wr_data    ({8'b0,rx_data} ),  //写端口FIFO: 写数据
    .sdram_wr_b_addr    (24'd0          ),  //写SDRAM的首地址
    .sdram_wr_e_addr    (24'd50         ),  //写SDRAM的末地址
    .wr_burst_len       (10'd10         ),  //写SDRAM时的数据突发长度
    .wr_rst             (~rst_n         ),  //写地址复位信号
//用户读端口
    .rd_fifo_rd_clk     (clk_25m        ),  //读端口FIFO: 读时钟
    .rd_fifo_rd_req     (data_req       ),  //读端口FIFO: 读使能
    .rd_fifo_rd_data    (data_in        ),  //读端口FIFO: 读数据
    .sdram_rd_b_addr    (24'd0          ),  //读SDRAM的首地址
    .sdram_rd_e_addr    (24'd50         ),  //读SDRAM的末地址
    .rd_burst_len       (10'd10         ),  //从SDRAM中读数据时的突发长度
    .rd_rst             (~rst_n         ),  //读地址复位信号
    .rd_fifo_num        (               ),  //读fifo中的数据量
//用户控制端口
    .read_valid         (1'b1           ),  //SDRAM 读使能
    .pingpang_en        (1'b1           ),  //SDRAM 乒乓操作使能
    .init_end           (               ),  //SDRAM 初始化完成标志
//SDRAM 芯片接口
    .sdram_clk          (sdram_clk      ),  //SDRAM 芯片时钟
    .sdram_cke          (sdram_cke      ),  //SDRAM 时钟有效
    .sdram_cs_n         (sdram_cs_n     ),  //SDRAM 片选
    .sdram_ras_n        (sdram_ras_n    ),  //SDRAM 行有效
    .sdram_cas_n        (sdram_cas_n    ),  //SDRAM 列有效
    .sdram_we_n         (sdram_we_n     ),  //SDRAM 写有效
    .sdram_ba           (sdram_ba       ),  //SDRAM Bank地址
    .sdram_addr         (sdram_addr     ),  //SDRAM 行/列地址
    .sdram_dq           (sdram_dq       ),  //SDRAM 数据
    .sdram_dqm          (sdram_dqm      )   //SDRAM 数据掩码
);

//------------- vga_ctrl_inst -------------
vga_ctrl    vga_ctrl_inst(
    .vga_clk     (clk_25m   ),   //输入工作时钟,频率25MHz
    .sys_rst_n   (rst_n     ),   //输入复位信号,低电平有效
    .pix_data    (data_in   ),

    .pix_data_req(data_req  ),
    .hsync       (hsync     ),   //输出行同步信号
    .vsync       (vsync     ),   //输出场同步信号
    .rgb         (rgb_vga   )    //输出像素信息

);

//-------------sdram_model_plus_inst-------------
sdram_model_plus    sdram_model_plus_inst(
    .Dq     (sdram_dq       ),
    .Addr   (sdram_addr     ),
    .Ba     (sdram_ba       ),
    .Clk    (sdram_clk      ),
    .Cke    (sdram_cke      ),
    .Cs_n   (sdram_cs_n     ),
    .Ras_n  (sdram_ras_n    ),
    .Cas_n  (sdram_cas_n    ),
    .We_n   (sdram_we_n     ),
    .Dqm    (sdram_dqm      ),
    .Debug  (1'b1           )

);

endmodule