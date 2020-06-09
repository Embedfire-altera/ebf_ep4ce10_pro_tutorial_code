`timescale  1ns/1ns
////////////////////////////////////////////////////////////////////////
// Author        : EmbedFire
// Create Date   : 2019/09/05
// Module Name   : sd_hdmi_pic
// Project Name  : sd_hdmi_pic
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

module  sd_hdmi_pic
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
    //HDMI
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
parameter  H_VALID  =   24'd640 ;   //行有效数据
parameter  V_VALID  =   24'd480 ;   //列有效数据

//wire define
wire            rst_n           ;   //复位信号
wire            clk_125m        ;   //生成100MHz时钟
wire            clk_125m_shift  ;   //生成100MHz时钟,相位偏移180度
wire            clk_50m         ;   //生成50MHz时钟
wire            clk_50m_shift   ;   //生成50MHz时钟,相位偏移180度
wire            clk_25m         ;   //生成25MHz时钟
wire            locked          ;   //时钟锁定信号
wire            sys_init_end    ;  //系统初始化完成

wire            vga_hs          ;  //输出行同步信号
wire            vga_vs          ;  //输出场同步信号
wire    [15:0]  vga_rgb         ;  //输出像素信息
wire            rgb_valid       ;   //VGA有效显示区域

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
assign  rst_n   = sys_rst_n && locked;
assign  ddc_scl = 1'b1;
assign  ddc_sda = 1'b1;

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

    .c0           (clk_125m         ),  //生成100MHz时钟
    .c1           (clk_125m_shift   ),  //生成100MHz时钟,相位偏移180度
    .c2           (clk_50m          ),  //生成50MHz时钟
    .c3           (clk_50m_shift    ),  //生成50MHz时钟,相位偏移180度
    .c4           (clk_25m          ),  //生成25MHz时钟
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
    .sys_clk            (clk_125m       ),  //sdram 控制器参考时钟
    .clk_out            (clk_125m_shift ),  //用于输出的相位偏移时钟
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

//------------- vga_ctrl_inst -------------
vga_ctrl    vga_ctrl_inst
(
    .vga_clk    (clk_25m    ),  //输入工作时钟,频率25MHz
    .sys_rst_n  (rst_n      ),  //输入复位信号,低电平有效
    .data_in    (rd_data    ),  //待显示数据输入

    .rgb_valid  (rgb_valid  ),   //VGA有效显示区域
    .data_req   (rd_en      ),  //数据请求信号
    .hsync      (vga_hs     ),  //输出行同步信号
    .vsync      (vga_vs     ),  //输出场同步信号
    .rgb        (vga_rgb    )   //输出像素信息
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
    .hsync       (vga_hs            ),   //行同步信号
    .vsync       (vga_vs            ),   //场同步信号
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