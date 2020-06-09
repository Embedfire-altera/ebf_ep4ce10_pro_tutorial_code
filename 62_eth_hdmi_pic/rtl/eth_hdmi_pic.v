`timescale  1ns/1ns
////////////////////////////////////////////////////////////////////////
// Author        : EmbedFire
// Create Date   : 2019/10/25
// Module Name   : eth_hdmi_pic
// Project Name  : eth_hdmi_pic
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

module eth_hdmi_pic
(
    input   wire            sys_clk     ,   //系统时钟
    input   wire            sys_rst_n   ,   //复位信号,低电平有效
//Ethernet
    input   wire            eth_rx_clk  ,   //PHY芯片接收数据时钟信号
    input   wire            eth_rxdv_r  ,   //PHY芯片输入数据有效信号
    input   wire    [1:0]   eth_rx_data_r,  //PHY芯片输入数据
    output  wire            eth_tx_en   ,   //PHY芯片输出数据有效信号
    output  wire            eth_rst_n   ,   //PHY芯片复位信号,低电平有效
//SDRAM
    output  wire            sdram_clk   ,   //SDRAM芯片时钟
    output  wire            sdram_cke   ,   //SDRAM时钟有效信号
    output  wire            sdram_cs_n  ,   //SDRAM片选信号
    output  wire            sdram_ras_n ,   //SDRAM行地址选通信号
    output  wire            sdram_cas_n ,   //SDRAM列地址选通信号
    output  wire            sdram_we_n  ,   //SDRAM写允许信号
    output  wire    [1:0]   sdram_ba    ,   //SDRAM的L-Bank地址线
    output  wire    [12:0]  sdram_addr  ,   //SDRAM地址总线
    output  wire    [1:0]   sdram_dqm   ,   //SDRAM数据掩码
    inout   wire    [15:0]  sdram_dq    ,   //SDRAM数据总线

//hdmi
    output  wire            ddc_scl     ,
    output  wire            ddc_sda     ,
    output  wire            tmds_clk_p  ,
    output  wire            tmds_clk_n  ,   //HDMI时钟差分信号
    output  wire    [2:0]   tmds_data_p ,
    output  wire    [2:0]   tmds_data_n     //HDMI图像差分信号
);

//********************************************************************//
//****************** Parameter and Internal Signal *******************//
//********************************************************************//
//parameter define
parameter   BOARD_MAC   = 48'hFF_FF_FF_FF_FF_FF ;   //板卡MAC地址
parameter   BOARD_IP    = 32'hFF_FF_FF_FF       ;   //板卡IP地址
parameter   BOARD_PORT  = 16'd1234              ;   //板卡端口号
parameter   PC_MAC      = 48'hE0_D5_5E_4A_DB_2D ;   //PC机MAC地址
parameter   PC_IP       = 32'hC0_A8_64_02       ;   //PC机IP地址
parameter   PC_PORT     = 16'd1234              ;   //PC机端口号

/* parameter   BOARD_MAC   = 48'h12_34_56_78_9a_bc ;   //板卡MAC地址
parameter   BOARD_IP    = 32'hA9_FE_01_17       ;   //板卡IP地址
parameter   BOARD_PORT  = 16'd1234              ;   //板卡端口号
parameter   PC_MAC      = 48'hE0_D5_5E_4A_DB_2D ;   //PC机MAC地址
parameter   PC_IP       = 32'hA9_FE_F2_37       ;   //PC机IP地址
parameter   PC_PORT     = 16'd1234              ;   //PC机端口号 */

parameter   H_VALID  =   24'd640;   //行有效数据
parameter   V_VALID  =   24'd480;   //列有效数据

//wire  define
wire            clk_25m         ;   //25MHz
wire            clk_100m        ;   //100MHz
wire            clk_100m_shift  ;   //100MHz,做相位偏移处理
wire            clk_125m        ;
wire            locked          ;   //时钟输出有效
wire            rst_n           ;   //系统复位信号
wire            sdram_init_done ;   //SDRAM完成初始化
wire            rec_en_in       ;   //UDP接收有效数据使能
wire    [31:0]  rec_data_in     ;   //UDP接收有效数据
wire            wr_en           ;   //SDRAM写端口写使能
wire    [15:0]  wr_data         ;   //SDRAM写端口写数据
wire            rd_en           ;   //SDRAM读端口读使能
wire    [15:0]  rd_data         ;   //SDRAM读端口读数据
wire            hsync           ;   //输出行同步信号
wire            vsync           ;   //输出场同步信号
wire    [15:0]  vga_rgb         ;   //输出像素点色彩信息
wire            rgb_valid       ;
wire            eth_rxdv        ;
wire    [3:0]   eth_rx_data     ;

//reg   define
reg             mii_clk         ;

//********************************************************************//
//***************************** Main Code ****************************//
//********************************************************************//
//rst_n:/系统复位信号
assign  rst_n   = sys_rst_n & locked;
assign  ddc_scl = 1'b1;
assign  ddc_sda = 1'b1;

always@(negedge eth_rx_clk or negedge sys_rst_n)
    if(sys_rst_n == 1'b0)
        mii_clk <=  1'b1;
    else
        mii_clk <=  ~mii_clk;

//********************************************************************//
//*************************** Instantiation **************************//
//********************************************************************//
//------------ clk_gen_inst -------------
clk_gen clk_gen_inst
(
    .inclk0     (sys_clk        ),  //输入时钟
    .areset     (~sys_rst_n     ),  //复位信号,高有效

    .c0         (clk_25m        ),  //输出25MHz时钟
    .c1         (clk_100m       ),  //输出100MHz时钟
    .c2         (clk_100m_shift ),  //输出100MHz时钟,相位偏移
    .c3         (clk_125m       ),
    .locked     (locked         )   //时钟信号有效标志
);

//------------ rmii_to_mii_inst -------------
rmii_to_mii rmii_to_mii_inst
(
    .eth_rmii_clk(eth_rx_clk    ),
    .eth_mii_clk (mii_clk       ),
    .sys_rst_n   (sys_rst_n     ),
    .rx_dv       (eth_rxdv_r    ),
    .rx_data     (eth_rx_data_r ),

    .eth_rx_dv   (eth_rxdv      ),
    .eth_rx_data (eth_rx_data   )
);

//------------ eth_udp_inst -------------
eth_udp_mii
#(
    .BOARD_MAC      (BOARD_MAC      ),  //板卡MAC地址
    .BOARD_IP       (BOARD_IP       ),  //板卡IP地址
    .BOARD_PORT     (BOARD_PORT     ),  //板卡端口号
    .PC_MAC         (PC_MAC         ),  //PC机MAC地址
    .PC_IP          (PC_IP          ),  //PC机IP地址
    .PC_PORT        (PC_PORT        )   //PC机端口号
)
eth_udp_mii_inst
(
    .eth_rx_clk     (mii_clk    ),  //PHY芯片接收数据时钟信号
    .sys_rst_n      (rst_n          ),  //复位信号,低电平有效
    .eth_rxdv       (eth_rxdv       ),  //PHY芯片输入数据有效信号
    .eth_rx_data    (eth_rx_data    ),  //PHY芯片输入数据
    .eth_tx_clk     (               ),  //PHY芯片发送数据时钟信号
    .send_en        (               ),  //开始发送信号
    .send_data      (               ),  //发送数据
    .send_data_num  (               ),  //发送有效数据字节数

    .send_end       (               ),  //单包数据发送完成信号
    .read_data_req  (               ),  //读数据请求信号
    .rec_end        (               ),  //单包数据接收完成信号
    .rec_en         (rec_en_in      ),  //接收数据使能信号
    .rec_data       (rec_data_in    ),  //接收数据
    .rec_data_num   (               ),  //接收有效数据字节数
    .eth_tx_en      (eth_tx_en      ),  //PHY芯片输出数据有效信号
    .eth_tx_data    (               ),  //PHY芯片输出数据
    .eth_rst_n      (eth_rst_n      )   //PHY芯片复位信号,低电平有效
);

//------------ data32_to_data16_inst -------------
data32_to_data16    data32_to_data16_inst
(
    .sys_clk        (mii_clk    ),   //系统时钟
    .sys_rst_n      (rst_n      ),   //复位信号,低有效
    .rec_en_in      (rec_en_in  ),   //输入32位数据使能信号
    .rec_data_in    (rec_data_in),   //输入32位数据

    .rec_en_out     (wr_en      ),   //输出16位数据使能信号
    .rec_data_out   (wr_data    )    //输出16位数据
);

//------------- sdram_top_inst -------------
sdram_top   sdram_top_inst
(
    .sys_clk            (clk_100m       ),  //sdram 控制器参考时钟
    .clk_out            (clk_100m_shift ),  //用于输出的相位偏移时钟
    .sys_rst_n          (rst_n          ),  //系统复位
//用户写端口
    .wr_fifo_wr_clk     (mii_clk        ),  //写端口FIFO: 写时钟
    .wr_fifo_wr_req     (wr_en          ),  //写端口FIFO: 写使能
    .wr_fifo_wr_data    (wr_data        ),  //写端口FIFO: 写数据
    .sdram_wr_b_addr    (24'd0          ),  //写SDRAM的起始地址
    .sdram_wr_e_addr    (H_VALID*V_VALID),  //写SDRAM的结束地址
    .wr_burst_len       (10'd512        ),  //写SDRAM时的数据突发长度
    .wr_rst             (~rst_n         ),  //写端口复位: 复位写地址,清空写FIFO
//用户读端口
    .rd_fifo_rd_clk     (clk_25m        ),  //读端口FIFO: 读时钟
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


//------------ vga_ctrl_inst -------------
vga_ctrl    vga_ctrl_inst
(
    .vga_clk     (clk_25m           ),  //输入工作时钟,频率25MHz
    .sys_rst_n   (sdram_init_done   ),  //输入复位信号,低电平有效
    .pix_data    (rd_data           ),  //输入待显示像素信息

    .rgb_valid   (rgb_valid         ),   //VGA有效显示区域
    .pix_data_req(rd_en             ),  //VGA数据请求信号
    .hsync       (hsync             ),  //输出行同步信号
    .vsync       (vsync             ),  //输出场同步信号
    .rgb         (vga_rgb           )   //输出像素信息
);

//------------- hdmi_ctrl_inst -------------
hdmi_ctrl   hdmi_ctrl_inst
(
    .clk_1x      (clk_25m           ),   //输入系统时钟
    .clk_5x      (clk_125m          ),   //输入5倍系统时钟
    .sys_rst_n   (rst_n             ),   //复位信号,低有效
    .rgb_blue    ({vga_rgb[4:0],3'b0}   ),   //蓝色分量
    .rgb_green   ({vga_rgb[10:5],2'b0}  ),   //绿色分量
    .rgb_red     ({vga_rgb[15:11],3'b0} ),   //红色分量
    .hsync       (hsync             ),   //行同步信号
    .vsync       (vsync             ),   //场同步信号
    .de          (rgb_valid         ),   //使能信号
    .hdmi_clk_p  (tmds_clk_p        ),
    .hdmi_clk_n  (tmds_clk_n        ),   //时钟差分信号
    .hdmi_r_p    (tmds_data_p[2]    ),
    .hdmi_r_n    (tmds_data_n[2]    ),   //红色分量差分信号
    .hdmi_g_p    (tmds_data_p[1]    ),
    .hdmi_g_n    (tmds_data_n[1]    ),   //绿色分量差分信号
    .hdmi_b_p    (tmds_data_p[0]    ),
    .hdmi_b_n    (tmds_data_n[0]    )    //蓝色分量差分信号
);

endmodule

