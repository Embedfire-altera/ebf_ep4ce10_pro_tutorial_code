`timescale  1ns/1ns
////////////////////////////////////////////////////////////////////////
// Author        : EmbedFire
// Create Date   : 2019/09/05
// Module Name   : sd_tft_pic
// Project Name  : sd_tft_pic
// Target Devices: Altera EP4CE10F17C8N
// Tool Versions : Quartus 13.0
// Description   : 顶层模块
// 
// Revision      : V1.0
// Additional Comments:
// 
// 实验平台: 野火_征途Pro_FPGA开发板
// 公司    : http://www.embedfire.com
// 论坛    : http://www.firebbs.cn
// 淘宝    : https://fire-stm32.taobao.com
////////////////////////////////////////////////////////////////////////

module  sd_tft_pic
(
    input   wire            sys_clk     ,  //输入工作时钟,频率50MHz
    input   wire            sys_rst_n   ,  //输入复位信号,低电平有效
    //SD卡
    input   wire            sd_miso     ,  //主输入从输出信号
    output  wire            sd_clk      ,  //SD卡时钟信号
    output  wire            sd_cs_n     ,  //片选信号
    output  wire            sd_mosi     ,  //主输出从输入信号
    //SDRAM
    output  wire            sdram_clk   ,  //SDRAM 芯片时钟
    output  wire            sdram_cke   ,  //SDRAM 时钟有效
    output  wire            sdram_cs_n  ,  //SDRAM 片选
    output  wire            sdram_ras_n ,  //SDRAM 行有效
    output  wire            sdram_cas_n ,  //SDRAM 列有效
    output  wire            sdram_we_n  ,  //SDRAM 写有效
    output  wire    [1:0]   sdram_ba    ,  //SDRAM Bank地址
    output  wire    [1:0]   sdram_dqm   ,  //SDRAM 数据掩码
    output  wire    [12:0]  sdram_addr  ,  //SDRAM 行/列地址
    inout   wire    [15:0]  sdram_dq    ,  //SDRAM 数据
    //TFT接口                          
    output  wire    [15:0]  tft_rgb     ,   //输出像素信息
    output  wire            tft_hs      ,   //输出TFT行同步信号
    output  wire            tft_vs      ,   //输出TFT场同步信号
    output  wire            tft_clk     ,   //输出TFT像素时钟
    output  wire            tft_de      ,   //输出TFT数据使能
    output  wire            tft_bl          //输出TFT背光信号
);

//********************************************************************//
//****************** Parameter and Internal Signal *******************//
//********************************************************************//
//parameter define
parameter  H_VALID  =   24'd800 ;   //行有效数据
parameter  V_VALID  =   24'd480 ;   //列有效数据

//wire define
wire            rst_n           ;   //复位信号
wire            clk_100m        ;   //生成100MHz时钟
wire            clk_100m_shift  ;   //生成100MHz时钟,相位偏移180度
wire            clk_50m         ;   //生成50MHz时钟
wire            clk_50m_shift   ;   //生成50MHz时钟,相位偏移180度
wire            clk_33m         ;   //生成33MHz时钟
wire            locked          ;   //时钟锁定信号
wire            sys_init_end    ;  //系统初始化完成

wire            sd_rd_en        ;  //开始写SD卡数据信号
wire    [31:0]  sd_rd_addr      ;  //读数据扇区地址    
wire            sd_rd_busy      ;  //读忙信号
wire            sd_rd_data_en   ;  //数据读取有效使能信号
wire    [15:0]  sd_rd_data      ;  //读数据
wire            sd_init_end     ;  //SD卡初始化完成信号

wire            wr_en           ;  //sdram_ctrl模块写使能
wire    [15:0]  wr_data         ;  //sdram_ctrl模块写数据
wire            rd_en           ;  //sdram_ctrl模块读使能
wire    [15:0]  rd_data         ;  //sdram_ctrl模块读数据
wire            sdram_init_end  ;  //SDRAM初始化完成

//********************************************************************//
//***************************** Main Code ****************************//
//********************************************************************//
//rdt_n:复位信号,系统复位与时钟锁定取与
assign  rst_n = sys_rst_n && locked;
//sys_init_end:系统初始化完成,SD卡和SDRAM均完成初始化
assign  sys_init_end = sd_init_end && sdram_init_end;

//********************************************************************//
//************************** Instantiation ***************************//
//********************************************************************//
//------------- clk_gen_inst -------------
clk_gen clk_gen_inst
(
    .areset       (~sys_rst_n       ),  //复位信号,高有效
    .inclk0       (sys_clk          ),  //输入系统时钟,50MHz

    .c0           (clk_100m         ),  //生成100MHz时钟
    .c1           (clk_100m_shift   ),  //生成100MHz时钟,相位偏移180度
    .c2           (clk_50m          ),  //生成50MHz时钟
    .c3           (clk_50m_shift    ),  //生成50MHz时钟,相位偏移180度
    .c4           (clk_33m          ),  //生成33MHz时钟
    .locked       (locked           )   //时钟锁定信号
);

//------------- data_rd_ctrl_inst -------------
data_rd_ctrl    data_rd_ctrl_inst
(
    .sys_clk    (clk_50m                ),   //输入工作时钟,频率50MHz
    .sys_rst_n  (rst_n & sys_init_end   ),   //输入复位信号,低电平有效
    .rd_busy    (sd_rd_busy             ),   //读操作忙信号

    .rd_en      (sd_rd_en               ),   //数据读使能信号
    .rd_addr    (sd_rd_addr             )    //读数据扇区地址
);

//------------- sd_ctrl_inst -------------
sd_ctrl sd_ctrl_inst
(
    .sys_clk         (clk_50m       ),  //输入工作时钟,频率50MHz
    .sys_clk_shift   (clk_50m_shift ),  //输入工作时钟,频率50MHz,相位偏移180度
    .sys_rst_n       (rst_n         ),  //输入复位信号,低电平有效

    .sd_miso         (sd_miso       ),  //主输入从输出信号
    .sd_clk          (sd_clk        ),  //SD卡时钟信号
    .sd_cs_n         (sd_cs_n       ),  //片选信号
    .sd_mosi         (sd_mosi       ),  //主输出从输入信号

    .wr_en           (1'b0          ),  //数据写使能信号
    .wr_addr         (32'b0         ),  //写数据扇区地址
    .wr_data         (16'b0         ),  //写数据
    .wr_busy         (              ),  //写操作忙信号
    .wr_req          (              ),  //写数据请求信号

    .rd_en           (sd_rd_en      ),  //数据读使能信号
    .rd_addr         (sd_rd_addr    ),  //读数据扇区地址
    .rd_busy         (sd_rd_busy    ),  //读操作忙信号
    .rd_data_en      (sd_rd_data_en ),  //读数据标志信号
    .rd_data         (sd_rd_data    ),  //读数据

    .init_end        (sd_init_end   )   //SD卡初始化完成信号
);

//------------- sdram_top_inst -------------
sdram_top   sdram_top_inst
(
    .sys_clk            (clk_100m       ),  //sdram 控制器参考时钟
    .clk_out            (clk_100m_shift ),  //用于输出的相位偏移时钟
    .sys_rst_n          (rst_n          ),  //系统复位
//用户写端口
    .wr_fifo_wr_clk     (clk_50m        ),  //写端口FIFO: 写时钟
    .wr_fifo_wr_req     (sd_rd_data_en  ),  //写端口FIFO: 写使能
    .wr_fifo_wr_data    (sd_rd_data     ),  //写端口FIFO: 写数据
    .sdram_wr_b_addr    (24'd0          ),  //写SDRAM的起始地址
    .sdram_wr_e_addr    (H_VALID*V_VALID),  //写SDRAM的结束地址
    .wr_burst_len       (10'd512        ),  //写SDRAM时的数据突发长度
    .wr_rst             (~rst_n         ),  //写端口复位: 复位写地址,清空写FIFO
//用户读端口
    .rd_fifo_rd_clk     (clk_33m        ),  //读端口FIFO: 读时钟
    .rd_fifo_rd_req     (rd_en          ),  //读端口FIFO: 读使能
    .rd_fifo_rd_data    (rd_data        ),  //读端口FIFO: 读数据
    .sdram_rd_b_addr    (24'd0          ),  //读SDRAM的起始地址
    .sdram_rd_e_addr    (H_VALID*V_VALID),  //读SDRAM的结束地址
    .rd_burst_len       (10'd512        ),  //从SDRAM中读数据时的突发长度
    .rd_fifo_num        (               ),  //读fifo中的数据量
    .rd_rst             (~rst_n         ),  //读端口复位: 复位读地址,清空读FIFO
//用户控制端口
    .read_valid         (1'b1           ),  //SDRAM 读使能
    .pingpang_en        (1'b0           ),  //SDRAM 乒乓操作使能
    .init_end           (sdram_init_end ),  //SDRAM 初始化完成标志
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

//------------- tft_ctrl_inst -------------
tft_ctrl  tft_ctrl_inst
(
    .clk_33m     (clk_33m   ),   //输入时钟,频率33MHz
    .sys_rst_n   (rst_n     ),   //系统复位,低电平有效
    .data_in     (rd_data   ),   //待显示数据

    .data_req    (rd_en     ),   //数据请求信号
    .rgb_tft     (tft_rgb   ),   //TFT显示数据
    .hsync       (tft_hs    ),   //TFT行同步信号
    .vsync       (tft_vs    ),   //TFT场同步信号
    .tft_clk     (tft_clk   ),   //TFT像素时钟
    .tft_de      (tft_de    ),   //TFT数据使能
    .tft_bl      (tft_bl    )    //TFT背光信号
);

endmodule