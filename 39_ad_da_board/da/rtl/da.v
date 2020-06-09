`timescale  1ns/1ns
////////////////////////////////////////////////////////////////////////
// Author        : EmbedFire
// Create Date   : 2019/04/01
// Module Name   : da
// Project Name  : da
// Target Devices: Altera EP4CE10F17C8N
// Tool Versions : Quartus 13.0
// Description   : da顶层模块
//
// Revision      : V1.0
// Additional Comments:
// 
// 实验平台: 野火_征途Pro_FPGA开发板
// 公司    : http://www.embedfire.com
// 论坛    : http://www.firebbs.cn
// 淘宝    : https://fire-stm32.taobao.com
////////////////////////////////////////////////////////////////////////

module  da
(
    input   wire            sys_clk     ,   //输入系统时钟,50MHz
    input   wire            sys_rst_n   ,   //输入复位信号,低电平有效
    input   wire            key_add     ,   //电压加按键
    input   wire            key_sub     ,   //电压减按键
    input   wire            key_2_5     ,   //输出电压2.5V按键
    input   wire            key_3_3     ,   //输出电压3.3V按键

    output  wire            i2c_scl     ,   //输出至i2c设备的串行时钟信号scl
    inout   wire            i2c_sda     ,   //输出至i2c设备的串行数据信号sda
    output  wire            stcp        ,   //输出数据存储寄时钟
    output  wire            shcp        ,   //移位寄存器的时钟输入
    output  wire            ds          ,   //串行数据输入
    output  wire            oe              //使能信号
);

//********************************************************************//
//****************** Parameter and Internal Signal *******************//
//********************************************************************//
//parameter define
parameter   DEVICE_ADDR     =   7'h48           ;   //i2c设备地址
parameter   SYS_CLK_FREQ    =   26'd50_000_000  ;   //输入系统时钟频率
parameter   SCL_FREQ        =   18'd250_000     ;   //i2c设备scl时钟频率
parameter   CNT_MAX         =   20'd999_999     ;   //计数器计数最大值

//wire define
wire            i2c_clk     ;   //i2c驱动时钟
wire            i2c_start   ;   //i2c触发信号
wire    [15:0]  byte_addr   ;   //i2c字节地址
wire    [ 7:0]  wr_data     ;   //i2c设备数据
wire            i2c_end     ;   //i2c一次读/写操作完成
wire    [19:0]  data        ;   //数码管待显示数据
wire            wr_en       ;   //写使能信号
wire            add         ;   //电压加按键
wire            add_valid   ;   //电压加按键有效
wire            sub         ;   //电压减按键
wire            sub_valid   ;   //电压减按键有效
wire            v_2_5       ;   //电压2.5V按键
wire            v_2_5_valid ;   //电压2.5V按键有效
wire            v_3_3       ;   //电压3.3V按键
wire            v_3_3_valid ;   //电压3.3V按键有效

//********************************************************************//
//**************************** Instantiation *************************//
//********************************************************************//
//------------- key_fifter_inst --------------
key_filter 
#(
    .CNT_MAX      (CNT_MAX  )       //计数器计数最大值
)
key_add_inst
(
    .sys_clk      (sys_clk  )   ,   //系统时钟50Mhz
    .sys_rst_n    (sys_rst_n)   ,   //全局复位
    .key_in       (key_add  )   ,   //按键输入信号

    .key_flag     (add      )       //按键消抖后标志信号
);

//------------- cross_clk_add_inst -------------
cross_clk   cross_clk_add_inst
(
    .clk_a      (sys_clk    ),  //时钟a
    .clk_b      (i2c_clk    ),  //时钟b
    .sys_rst_n  (sys_rst_n  ),  //复位信号
    .en_a       (add        ),  //a使能信号

    .en_b       (add_valid  )   //b使能信号
);

//------------- key_sub_inst -------------
key_filter 
#(
    .CNT_MAX      (CNT_MAX  )       //计数器计数最大值
)
key_sub_inst
(
    .sys_clk    (sys_clk    ),  //系统时钟50Mhz
    .sys_rst_n  (sys_rst_n  ),  //全局复位
    .key_in     (key_sub    ),  //按键输入信号

    .key_flag   (sub        )   //key_flag为1时表示按键有效，0表示按键无效
);

//------------- cross_clk_sub_inst -------------
cross_clk   cross_clk_sub_inst
(
    .clk_a      (sys_clk    ),  //时钟a
    .clk_b      (i2c_clk    ),  //时钟b
    .sys_rst_n  (sys_rst_n  ),  //复位信号
    .en_a       (sub        ),  //a使能信号

    .en_b       (sub_valid  )   //b使能信号
);

//------------- key_2_5_inst -------------
key_filter 
#(
    .CNT_MAX      (CNT_MAX  )       //计数器计数最大值
)
key_2_5_inst
(
    .sys_clk    (sys_clk    ),  //系统时钟50Mhz
    .sys_rst_n  (sys_rst_n  ),  //全局复位
    .key_in     (key_2_5    ),  //按键输入信号

    .key_flag   (v_2_5      )   //key_flag为1时表示按键有效，0表示按键无效
);

//------------- cross_clk_2_5_inst -------------
cross_clk   cross_clk_2_5_inst
(
    .clk_a      (sys_clk    ),  //时钟a
    .clk_b      (i2c_clk    ),  //时钟b
    .sys_rst_n  (sys_rst_n  ),  //复位信号
    .en_a       (v_2_5      ),  //a使能信号

    .en_b       (v_2_5_valid)   //b使能信号
);

//------------- key_3_3_inst -------------
key_filter 
#(
    .CNT_MAX      (CNT_MAX  )       //计数器计数最大值
)
key_3_3_inst
(
    .sys_clk    (sys_clk    ),  //系统时钟50Mhz
    .sys_rst_n  (sys_rst_n  ),  //全局复位
    .key_in     (key_3_3    ),  //按键输入信号

    .key_flag   (v_3_3      )   //key_flag为1时表示按键有效，0表示按键无效
);

//------------- cross_clk_3_3_inst -------------
cross_clk   cross_clk_3_3_inst
(
    .clk_a      (sys_clk    ),  //时钟a
    .clk_b      (i2c_clk    ),  //时钟b
    .sys_rst_n  (sys_rst_n  ),  //复位信号
    .en_a       (v_3_3      ),  //a使能信号

    .en_b       (v_3_3_valid)   //b使能信号
);

//------------- pcf8591_adda_inst -------------
pcf8591_da  pcf8591_da_inst
(
    .sys_clk     (i2c_clk       ),  //输入系统时钟
    .sys_rst_n   (sys_rst_n     ),  //输入复位信号,低电平有效
    .add         (add_valid     ),  //电压加按键有效
    .sub         (sub_valid     ),  //电压减按键有效
    .v_2_5       (v_2_5_valid   ),  //电压2.5V按键有效
    .v_3_3       (v_3_3_valid   ),  //电压3.3V按键有效
    .i2c_end     (i2c_end       ),  //i2c设备一次读/写操作完成

    .wr_en       (wr_en         ),  //输入i2c设备写使能信号
    .i2c_start   (i2c_start     ),  //输入i2c设备触发信号
    .byte_addr   (byte_addr     ),  //输入i2c设备字节地址
    .wr_data     (wr_data       ),  //输入i2c设备数据
    .po_data     (data          )   //数码管待显示数据
);

//------------- i2c_ctrl_inst -------------
i2c_ctrl
#(
    .DEVICE_ADDR    (DEVICE_ADDR    ),  //i2c设备器件地址
    .SYS_CLK_FREQ   (SYS_CLK_FREQ   ),  //i2c_ctrl模块系统时钟频率
    .SCL_FREQ       (SCL_FREQ       )   //i2c的SCL时钟频率
)
i2c_ctrl_inst
(
    .sys_clk     (sys_clk   ),  //输入系统时钟,50MHz
    .sys_rst_n   (sys_rst_n ),  //输入复位信号,低电平有效
    .wr_en       (wr_en     ),  //输入写使能信号
    .rd_en       (          ),  //输入读使能信号
    .i2c_start   (i2c_start ),  //输入i2c触发信号
    .addr_num    (1'b0      ),  //输入i2c字节地址字节数
    .byte_addr   (byte_addr ),  //输入i2c字节地址
    .wr_data     (wr_data   ),  //输入i2c设备数据

    .rd_data     (          ),  //输出i2c设备读取数据
    .i2c_end     (i2c_end   ),  //i2c一次读/写操作完成
    .i2c_clk     (i2c_clk   ),  //i2c驱动时钟
    .i2c_scl     (i2c_scl   ),  //输出至i2c设备的串行时钟信号scl
    .i2c_sda     (i2c_sda   )   //输出至i2c设备的串行数据信号sda
);

//------------- seg_595_dynamic_inst -------------
seg_595_dynamic     seg_595_dynamic_inst
(
    .sys_clk    (sys_clk    ),  //系统时钟，频率50MHz
    .sys_rst_n  (sys_rst_n  ),  //复位信号，低有效
    .data       (data       ),  //数码管要显示的值
    .point      (6'b001000  ),  //小数点显示,高电平有效
    .seg_en     (1'b1       ),  //数码管使能信号，高电平有效
    .sign       (1'b0       ),  //符号位，高电平显示负号

    .stcp       (stcp       ),   //输出数据存储寄时钟
    .shcp       (shcp       ),   //移位寄存器的时钟输入
    .ds         (ds         ),   //串行数据输入
    .oe         (oe         )    //使能信号
);

endmodule
