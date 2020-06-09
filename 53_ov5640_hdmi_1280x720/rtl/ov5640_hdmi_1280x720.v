`timescale  1ns/1ns
////////////////////////////////////////////////////////////////////////
// Author        : EmbedFire
// Create Date   : 2019/11/15
// Module Name   : ov5640_hdmi_1280x720
// Project Name  : ov5640_hdmi_1280x720
// Target Devices: Altera EP4CE10F17C8N
// Tool Versions : Quartus 13.0
// Description   : 顶层文件
// 
// Revision      : V1.0
// Additional Comments:
// 
// 实验平台: 野火_征途Pro_FPGA开发板
// 公司    : http://www.embedfire.com
// 论坛    : http://www.firebbs.cn
// 淘宝    : https://fire-stm32.taobao.com
////////////////////////////////////////////////////////////////////////

module  ov5640_hdmi_1280x720
(
    input   wire            sys_clk     ,   //输入系统时钟,50MHz
    input   wire            sys_rst_n   ,   //输入复位信号,低电平有效
//CMOS
    input   wire    [7:0]   ov5640_data   ,   //摄像头采集图像数据
    input   wire            ov5640_vsync  ,   //摄像头采集图像场同步信号
    input   wire            ov5640_href   ,   //摄像头采集图像行同步信号
    input   wire            ov5640_pclk   ,   //摄像头像素时钟
    output  wire            ov5640_rst_n  ,   //
    output  wire            ov5640_pwdn   ,   //
    output  wire            sccb_scl    ,   //SCCB串行时钟
    inout   wire            sccb_sda    ,   //SCCB串行数据
//SDRAM
    output  wire            sdram_clk   ,   //SDRAM 芯片时钟
    output  wire            sdram_cke   ,   //SDRAM 时钟有效
    output  wire            sdram_cs_n  ,   //SDRAM 片选
    output  wire            sdram_ras_n ,   //SDRAM 行有效
    output  wire            sdram_cas_n ,   //SDRAM 列有效
    output  wire            sdram_we_n  ,   //SDRAM 写有效
    output  wire    [1:0]   sdram_dqm   ,   //SDRAM 数据掩码
    output  wire    [1:0]   sdram_ba    ,   //SDRAM Bank地址
    output  wire    [12:0]  sdram_addr  ,   //SDRAM 行/列地址
    inout   wire    [15:0]  sdram_dq    ,   //SDRAM 数据
//HDMI
    output  wire            tmds_clk_p  ,
    output  wire            tmds_clk_n  ,   //HDMI时钟差分信号
    output  wire    [2:0]   tmds_data_p ,
    output  wire    [2:0]   tmds_data_n     //HDMI图像差分信号
);

//********************************************************************//
//****************** Parameter and Internal Signal *******************//
//********************************************************************//
//parameter     define
parameter   H_PIXEL = 1280;
parameter   V_PIXEL = 720 ;

//wire  define
wire            clk_125m        ;
wire            clk_125m_shift  ;
wire            clk_25m         ;
wire            locked1         ;
wire            clk_74m         ;
wire            clk_371m        ;
wire            locked2         ;
wire            rst_n           ;
wire            sdram_init_done ;
wire            cfg_done        ;
wire            sys_init_done   ;
wire    [15:0]  image_data      ;
wire            image_data_en   ;
wire    [15:0]  vga_rgb         ;
wire            rdreq           ;
wire            vga_hs          ;
wire            vga_vs          ;
wire            vga_de          ;
wire    [7:0]   vga_r           ;
wire    [7:0]   vga_g           ;
wire    [7:0]   vga_b           ;


assign  ov5640_pwdn = 1'b0;
assign  ov5640_rst_n = 1'b1;
assign  rst_n = (sys_rst_n & locked1 & locked2);
assign  sys_init_done = sdram_init_done & cfg_done;

//********************************************************************//
//**************************** Instantiate ***************************//
//********************************************************************//
//------------- clk_gen_inst -------------
clk_gen clk_gen_inst
(
    .areset (~sys_rst_n     ),
    .inclk0 (sys_clk        ),
    .c0     (clk_125m       ),
    .c1     (clk_125m_shift ),
    .c2     (clk_25m        ),
    .locked (locked1        )
);

//------------- clk_hdmi_inst -------------
clk_hdmi    clk_hdmi_inst
(
    .areset (~sys_rst_n),
    .inclk0 (sys_clk    ),
    .c0     (clk_74m    ),
    .c1     (clk_371m   ),
    .locked (locked2    )
);

//------------- ov5640_top_inst -------------
ov5640_top  ov5640_top_inst
(
    .sys_clk         (clk_25m       ),   //系统时钟
    .sys_rst_n       (rst_n         ),   //复位信号
    .sys_init_done   (sys_init_done ),   //系统初始化完成(SDRAM + 摄像头)

    .ov5640_pclk     (ov5640_pclk     ),   //摄像头像素时钟
    .ov5640_href     (ov5640_href     ),   //摄像头行同步信号
    .ov5640_vsync    (ov5640_vsync    ),   //摄像头场同步信号
    .ov5640_data     (ov5640_data     ),   //摄像头图像数据

    .cfg_done        (cfg_done      ),   //寄存器配置完成
    .sccb_scl        (sccb_scl      ),   //SCL
    .sccb_sda        (sccb_sda      ),   //SDA
    .ov5640_wr_en    (image_data_en ),   //图像数据有效使能信号
    .ov5640_data_out (image_data    )    //图像数据

);

//------------- sdram_top_inst -------------
sdram_top   sdram_top_inst
(
    .sys_clk            (clk_125m       ),  //sdram 控制器参考时钟
    .clk_out            (clk_125m_shift ),  //用于输出的相位偏移时钟
    .sys_rst_n          (rst_n          ),  //系统复位
//用户写端口
    .wr_fifo_wr_clk     (ov5640_pclk      ),  //写端口FIFO: 写时钟
    .wr_fifo_wr_req     (image_data_en  ),  //写端口FIFO: 写使能
    .wr_fifo_wr_data    (image_data     ),  //写端口FIFO: 写数据
    .sdram_wr_b_addr    (24'd0          ),  //写SDRAM的起始地址
    .sdram_wr_e_addr    (H_PIXEL*V_PIXEL),  //写SDRAM的结束地址
    .wr_burst_len       (10'd512        ),  //写SDRAM时的数据突发长度
    .wr_rst             (~rst_n         ),  //写端口复位: 复位写地址,清空写FIFO
//用户读端口
    .rd_fifo_rd_clk     (clk_74m        ),  //读端口FIFO: 读时钟
    .rd_fifo_rd_req     (rdreq          ),  //读端口FIFO: 读使能
    .rd_fifo_rd_data    (vga_rgb        ),  //读端口FIFO: 读数据
    .sdram_rd_b_addr    (24'd0          ),  //读SDRAM的起始地址
    .sdram_rd_e_addr    (H_PIXEL*V_PIXEL),  //读SDRAM的结束地址
    .rd_burst_len       (10'd512        ),  //从SDRAM中读数据时的突发长度
    .rd_fifo_num        (               ),  //读fifo中的数据量
    .rd_rst             (~rst_n         ),  //读端口复位: 复位读地址,清空读FIFO
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

//------------- vga_ctrl_inst -------------
vga_ctrl    vga_ctrl_inst
(
    .vga_clk     (clk_74m   ),   //输入工作时钟,频率25MHz
    .sys_rst_n   (rst_n     ),   //输入复位信号,低电平有效
    .pix_data    ({vga_rgb[15:11], 3'd0, vga_rgb[10:5], 2'd0,
                    vga_rgb[4:0], 3'd0}),   //输入像素点色彩信息

    .pix_data_req(rdreq     ),  //
    .hsync       (vga_hs    ),  //输出行同步信号
    .vsync       (vga_vs    ),  //输出场同步信号
    .rgb_valid   (vga_de    ),  //
    .red         (vga_r     ),
    .green       (vga_g     ),
    .blue        (vga_b     )
);

//------------- hdmi_ctrl_inst -------------
hdmi_ctrl   hdmi_ctrl_inst
(
    .clk_1x      (clk_74m       ),   //输入系统时钟
    .clk_5x      (clk_371m      ),   //输入5倍系统时钟
    .sys_rst_n   (rst_n     ),   //复位信号,低有效
    .rgb_blue    (vga_b         ),   //蓝色分量
    .rgb_green   (vga_g         ),   //绿色分量
    .rgb_red     (vga_r         ),   //红色分量
    .hsync       (vga_hs        ),   //行同步信号
    .vsync       (vga_vs        ),   //场同步信号
    .de          (vga_de        ),   //使能信号
    .hdmi_clk_p  (tmds_clk_p    ),
    .hdmi_clk_n  (tmds_clk_n    ),   //时钟差分信号
    .hdmi_r_p    (tmds_data_p[2]),
    .hdmi_r_n    (tmds_data_n[2]),   //红色分量差分信号
    .hdmi_g_p    (tmds_data_p[1]),
    .hdmi_g_n    (tmds_data_n[1]),   //绿色分量差分信号
    .hdmi_b_p    (tmds_data_p[0]),
    .hdmi_b_n    (tmds_data_n[0])    //蓝色分量差分信号
);

endmodule
