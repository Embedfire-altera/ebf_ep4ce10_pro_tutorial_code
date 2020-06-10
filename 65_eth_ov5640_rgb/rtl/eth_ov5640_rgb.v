`timescale  1ns/1ns
////////////////////////////////////////////////////////////////////////
// Author        : EmbedFire
// Create Date   : 2019/10/25
// Module Name   : eth_ov5640_rgb
// Project Name  : eth_ov5640_rgb
// Target Devices: Altera EP4CE10F17C8N
// Tool Versions : Quartus 13.0
// Description   : eth_ov5640_rgb顶层模块
// 
// Revision      : V1.0
// Additional Comments:
// 
// 实验平台: 野火_征途Pro_FPGA开发板
// 公司    : http://www.embedfire.com
// 论坛    : http://www.firebbs.cn
// 淘宝    : https://fire-stm32.taobao.com
////////////////////////////////////////////////////////////////////////

module eth_ov5640_rgb
(
    input   wire            sys_clk     ,   //系统时钟
    input   wire            sys_rst_n   ,   //系统复位,低电平有效
//摄像头
    input   wire            ov5640_pclk ,  //摄像头数据像素时钟
    input   wire            ov5640_vsync,  //摄像头场同步信号
    input   wire            ov5640_href ,  //摄像头行同步信号
    input   wire    [7:0]   ov5640_data ,  //摄像头数据
    output  wire            ov5640_rst_n,  //摄像头复位信号，低电平有效
    output  wire            ov5640_pwdn ,  //摄像头时钟选择信号, 1:使用摄像头自带的晶振
    output  wire            sccb_scl    ,  //摄像头SCCB_SCL线
    inout   wire            sccb_sda    ,  //摄像头SCCB_SDA线
//SDRAM
    output  wire            sdram_clk   ,   //SDRAM 时钟
    output  wire            sdram_cke   ,   //SDRAM 时钟使能
    output  wire            sdram_cs_n  ,   //SDRAM 片选
    output  wire            sdram_ras_n ,   //SDRAM 行有效
    output  wire            sdram_cas_n ,   //SDRAM 列有效
    output  wire            sdram_we_n  ,   //SDRAM 写有效
    output  wire    [1:0]   sdram_ba    ,   //SDRAM Bank地址
    output  wire    [1:0]   sdram_dqm   ,   //SDRAM 数据掩码
    output  wire    [12:0]  sdram_addr  ,   //SDRAM 地址
    inout   wire    [15:0]  sdram_dq    ,   //SDRAM 数据
//以太网
    input   wire            eth_clk     ,   //PHY芯片接收数据时钟
    input   wire            eth_rxdv_r  ,   //PHY芯片输入数据有效信号
    input   wire    [1:0]   eth_rx_data_r,  //PHY芯片输入数据
    output  wire            eth_tx_en_r ,   //PHY芯片输出数据有效信号
    output  wire    [1:0]   eth_tx_data_r,  //PHY芯片输出数据
    output  wire            eth_rst_n       //PHY芯片复位信号，低电平有效
);

//********************************************************************//
//****************** Parameter and Internal Signal *******************//
//********************************************************************//
//parameter define
parameter  H_PIXEL    = 24'd640       ;  //CMOS水平方向像素个数,用于设置SDRAM缓存大小
parameter  V_PIXEL    = 24'd480       ;  //CMOS垂直方向像素个数,用于设置SDRAM缓存大小
//板卡MAC地址
parameter  BOARD_MAC = 48'h12_34_56_78_9A_BC;
//板卡IP地址
parameter  BOARD_IP  = {8'd169,8'd254,8'd255,8'd255};
//板卡端口号
parameter  BOARD_PORT   = 16'd1234;
//PC机MAC地址
parameter  DES_MAC   = 48'hff_ff_ff_ff_ff_ff;
//PC机IP地址
parameter  DES_IP    = {8'd255,8'd255,8'd255,8'd255};
//parameter  DES_IP    = {8'd192,8'd168,8'd0,8'd245};
//PC机端口号
parameter  DES_PORT   = 16'd1234;

//wire define
wire            clk_25m         ;   //25mhz时钟,提供给摄像头驱动时钟
wire            clk_100m        ;   //100mhz时钟,SDRAM操作时钟
wire            clk_100m_shift  ;   //100mhz时钟,SDRAM相位偏移时钟
wire            locked          ;   //时钟输出有效
wire            rst_n           ;   //系统复位信号
wire            cfg_done        ;   //摄像头初始化完成
wire            wr_en           ;   //sdram写使能
wire    [15:0]  wr_data         ;   //sdram写数据
wire            rd_en           ;   //sdram读使能
wire    [15:0]  rd_data         ;   //sdram读数据
wire            sdram_init_done ;   //SDRAM初始化完成
wire            sys_init_done   ;   //系统初始化完成(SDRAM初始化+摄像头初始化)
wire            eth_tx_req      ;   //以太网发送数据请求信号
wire            eth_tx_done     ;   //以太网发送数据完成
wire            eth_tx_start    ;   //以太网开始发送信号
wire    [31:0]  eth_tx_data     ;   //以太网发送的数据
wire    [15:0]  eth_tx_data_num ;   //以太网单包发送的有效字节数
wire            eth_tx_start_f  ;   //以太网开始发送信号(格式)
wire    [31:0]  eth_tx_data_f   ;   //以太网发送的数据(格式)
wire    [15:0]  eth_tx_data_num_f;  //以太网单包发送的有效字节数(格式)
wire            i_config_end    ;   //图像格式包发送完成
wire            eth_tx_start_i  ;   //以太网开始发送信号(图像)
wire    [31:0]  eth_tx_data_i   ;   //以太网发送的数据(图像)
wire    [15:0]  eth_tx_data_num_i;  //以太网单包发送的有效字节数(图像)
wire            eth_rxdv        ;   //输入数据有效信号(mii)
wire    [3:0]   eth_rx_data     ;   //输入数据(mii)
wire            eth_tx_en       ;   //输出数据有效信号(mii)
wire    [3:0]   eth_tx_data_m     ;   //输出数据(mii)

//reg   define
reg             mii_clk         ;   //mii时钟

//********************************************************************//
//***************************** Main Code ****************************//
//********************************************************************//
assign  eth_tx_start    = (i_config_end == 1'b1) ? eth_tx_start_i : eth_tx_start_f;
assign  eth_tx_data     = (i_config_end == 1'b1) ? eth_tx_data_i : eth_tx_data_f;
assign  eth_tx_data_num = (i_config_end == 1'b1) ? eth_tx_data_num_i : eth_tx_data_num_f;

//rst_n:复位信号(sys_rst_n & locked)
assign  rst_n = sys_rst_n && locked;

//sys_init_done:系统初始化完成(SDRAM初始化+摄像头初始化)
assign  sys_init_done = sdram_init_done && cfg_done;

//ov5640_rst_n:摄像头复位,固定高电平
assign  ov5640_rst_n = 1'b1;

//ov5640_pwdn:摄像头时钟选择信号,0:使用引脚XCLK提供的时钟 1:使用摄像头自带的晶振
assign  ov5640_pwdn = 1'b0;

//mii_clk:mii时钟
always@(negedge eth_clk or negedge sys_rst_n)
    if(sys_rst_n == 1'b0)
        mii_clk <=  1'b0;
    else
        mii_clk <=  ~mii_clk;

//********************************************************************//
//*************************** Instantiation **************************//
//********************************************************************//
//------------- clk_gen_inst -------------
clk_gen clk_gen_inst
(
    .areset       (~sys_rst_n       ),
    .inclk0       (sys_clk          ),
    .c0           (clk_100m         ),
    .c1           (clk_100m_shift   ),
    .c2           (clk_25m          ),
    .locked       (locked           )
);

//------------- ov5640_top_inst -------------
ov5640_top  ov5640_top_inst
(
    .sys_clk         (clk_25m       ),   //系统时钟
    .sys_rst_n       (rst_n         ),   //复位信号
    .sys_init_done   (sys_init_done ),   //系统初始化完成(SDRAM + 摄像头)

    .ov5640_pclk     (ov5640_pclk   ),   //摄像头像素时钟
    .ov5640_href     (ov5640_href   ),   //摄像头行同步信号
    .ov5640_vsync    (ov5640_vsync  ),   //摄像头场同步信号
    .ov5640_data     (ov5640_data   ),   //摄像头图像数据
                      
    .cfg_done        (cfg_done      ),   //寄存器配置完成
    .sccb_scl        (sccb_scl      ),   //SCL
    .sccb_sda        (sccb_sda      ),   //SDA
    .ov5640_wr_en    (wr_en         ),   //图像数据有效使能信号
    .ov5640_data_out (wr_data       )    //图像数据
);

//------------- sdram_top_inst -------------
sdram_top   sdram_top_inst
(
    .sys_clk            (clk_100m       ),  //sdram 控制器参考时钟
    .clk_out            (clk_100m_shift ),  //用于输出的相位偏移时钟
    .sys_rst_n          (rst_n          ),  //系统复位
//用户写端口
    .wr_fifo_wr_clk     (ov5640_pclk    ),  //写端口FIFO: 写时钟
    .wr_fifo_wr_req     (wr_en          ),  //写端口FIFO: 写使能
    .wr_fifo_wr_data    (wr_data        ),  //写端口FIFO: 写数据
    .sdram_wr_b_addr    (24'd0          ),  //写SDRAM的起始地址
    .sdram_wr_e_addr    (H_PIXEL*V_PIXEL),  //写SDRAM的结束地址
    .wr_burst_len       (10'd512        ),  //写SDRAM时的数据突发长度
    .wr_rst             (~rst_n         ),  //写复位信号
//用户读端口
    .rd_fifo_rd_clk     (mii_clk        ),  //读端口FIFO: 读时钟
    .rd_fifo_rd_req     (rd_en          ),  //读端口FIFO: 读使能
    .rd_fifo_rd_data    (rd_data        ),  //读端口FIFO: 读数据
    .sdram_rd_b_addr    (24'd0          ),  //读SDRAM的起始地址
    .sdram_rd_e_addr    (H_PIXEL*V_PIXEL),  //读SDRAM的结束地址
    .rd_burst_len       (10'd512        ),  //从SDRAM中读数据时的突发长度
    .rd_fifo_num        (               ),  //读fifo中的数据量
    .rd_rst             (~rst_n         ),  //读复位信号
//用户控制端口
    .read_valid         (1'b1           ),  //SDRAM 读使能
    .pingpang_en        (1'b1           ),  //SDRAM 乒乓操作使能
    .init_end           (sdram_init_done),  //SDRAM 初始化完成标志
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

//------------- image_format_inst -------------
image_format    image_format_inst
(
    .sys_clk            (mii_clk                ),  //系统时钟
    .sys_rst_n          (rst_n && sys_init_done ),  //系统复位，低电平有效
    .eth_tx_req         (eth_tx_req && (~i_config_end)),//以太网数据请求信号
    .eth_tx_done        (eth_tx_done            ),  //单包以太网数据发送完成信号

    .eth_tx_start       (eth_tx_start_f         ),  //以太网发送数据开始信号
    .eth_tx_data        (eth_tx_data_f          ),  //以太网发送数据
    .i_config_end       (i_config_end           ),  //图像格式包发送完成
    .eth_tx_data_num    (eth_tx_data_num_f      )   //以太网单包数据有效字节数
);

//------------- image_data_inst -------------
image_data
#(
    .H_PIXEL            (H_PIXEL            ),  //图像水平方向像素个数
    .V_PIXEL            (V_PIXEL            )   //图像竖直方向像素个数
)
image_data_inst
(
    .sys_clk            (mii_clk            ),  //系统时钟,频率25MHz
    .sys_rst_n          (rst_n & sys_init_done& i_config_end),  //复位信号,低电平有效eth_tx_end
    .image_data         (rd_data            ),  //自SDRAM中读取的16位图像数据
    .eth_tx_req         (eth_tx_req         ),  //以太网发送数据请求信号
    .eth_tx_done        (eth_tx_done        ),  //以太网发送数据完成信号

    .data_rd_req        (rd_en              ),  //图像数据请求信号
    .eth_tx_start       (eth_tx_start_i     ),  //以太网发送数据开始信号
    .eth_tx_data        (eth_tx_data_i      ),  //以太网发送数据
    .eth_tx_data_num    (eth_tx_data_num_i  )   //以太网单包数据有效字节数
);

//------------- eth_udp_rmii_inst -------------
eth_udp_rmii
#(
    .BOARD_MAC      (BOARD_MAC      ),  //板卡MAC地址
    .BOARD_IP       (BOARD_IP       ),  //板卡IP地址
    .BOARD_PORT     (BOARD_PORT     ),  //板卡端口号
    .DES_MAC        (DES_MAC        ),  //PC机MAC地址
    .DES_IP         (DES_IP         ),  //PC机IP地址
    .DES_PORT       (DES_PORT       )   //PC机端口号
)
eth_udp_rmii_inst
(
    .eth_rmii_clk   (eth_clk        ),  //rmii时钟
    .eth_mii_clk    (mii_clk        ),  //mii时钟
    .sys_rst_n      (rst_n          ),  //复位信号,低电平有效
    .rx_dv          (eth_rxdv_r     ),  //输入数据有效信号(rmii)
    .rx_data        (eth_rx_data_r  ),  //输入数据(rmii)
    .send_en        (eth_tx_start   ),  //开始发送信号
    .send_data      (eth_tx_data    ),  //发送数据
    .send_data_num  (eth_tx_data_num),  //发送有效数据字节数

    .send_end       (eth_tx_done    ),  //单包数据发送完成信号
    .read_data_req  (eth_tx_req     ),  //读数据请求信号
    .rec_end        (               ),  //单包数据接收完成信号
    .rec_en         (               ),  //接收数据使能信号
    .rec_data       (               ),  //接收数据
    .rec_data_num   (               ),  //接收有效数据字节数
    .eth_tx_dv      (eth_tx_en_r    ),  //输出数据有效信号(rmii)
    .eth_tx_data    (eth_tx_data_r  ),  //输出数据(rmii)
    .eth_rst_n      (eth_rst_n      )   //PHY芯片复位信号,低电平有效
);

endmodule