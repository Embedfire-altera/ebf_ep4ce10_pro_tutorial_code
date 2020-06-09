//////////////////////////////////////////////////////////////////////////////////
// Author: EmbedFire
// Create Date: 2018/08/19
// Module Name: wm8978_cfg
// Project Name: audio_loopback
// Target Devices: Altera EP4CE10F17C8N
// Tool Versions: Quartus 13.0
// Description: 
//
// Revision:V1.1
// Additional Comments:
//
// ʵ��ƽ̨:Ұ��FPGA������
// ��˾    :http://www.embedfire.com
// ��̳    :http://www.firebbs.cn
// �Ա�    :https://fire-stm32.taobao.com
//////////////////////////////////////////////////////////////////////////////////

`timescale  1ns/1ns
module  wm8978_cfg
(
    input   wire    sys_clk     ,   //ϵͳʱ�ӣ�Ƶ��50MHz
    input   wire    sys_rst_n   ,   //ϵͳ��λ������Ч

    output  wire    i2c_scl     ,   //�����WM8978�Ĵ���ʱ���ź�scl
    inout   wire    i2c_sda         //�����WM8978�Ĵ��������ź�sda

);

//********************************************************************//
//****************** Parameter and Internal Signal *******************//
//********************************************************************//

//wire  define
wire            cfg_start   ;   //����i2c�����ź�
wire    [15:0]  cfg_data    ;   //�Ĵ�����ַ7bit+����9bit
wire            i2c_clk     ;   //i2c����ʱ��
wire            i2c_end     ;   //i2cһ�ζ�/д�������
wire            cfg_done    ;   //�Ĵ�����������ź�

//********************************************************************//
//***************************** Main Code ****************************//
//********************************************************************//

//------------------------ i2c_ctrl_inst -----------------------
i2c_ctrl
#(
    . DEVICE_ADDR     (7'b0011_010   )  ,   //i2c�豸��ַ
    . SYS_CLK_FREQ    (26'd50_000_000)  ,   //����ϵͳʱ��Ƶ��
    . SCL_FREQ        (18'd250_000   )      //i2c�豸sclʱ��Ƶ��
)
i2c_ctrl_inst
(
    .sys_clk        (sys_clk       ),  //����ϵͳʱ��,50MHz
    .sys_rst_n      (sys_rst_n     ),  //���븴λ�ź�,�͵�ƽ��Ч
    .wr_en          (1'b1          ),  //����дʹ���ź�
    .rd_en          (1'b0          ),  //�����ʹ���ź�
    .i2c_start      (cfg_start     ),  //����i2c�����ź�
    .addr_num       (1'b0          ),  //����i2c�ֽڵ�ַ�ֽ���
    .byte_addr      (cfg_data[15:8]),  //����i2c�ֽڵ�ַ+�������λ
    .wr_data        (cfg_data[7:0] ),  //����i2c�豸���ݵͰ�λ

    .rd_data        (              ),  //���i2c�豸��ȡ����
    .i2c_end        (i2c_end       ),  //i2cһ�ζ�/д�������
    .i2c_clk        (i2c_clk       ),  //i2c����ʱ��
    .i2c_scl        (i2c_scl       ),  //�����i2c�豸�Ĵ���ʱ���ź�scl
    .i2c_sda        (i2c_sda       )   //�����i2c�豸�Ĵ��������ź�sda
);

//---------------------- i2c_reg_cfg_inst ---------------------
i2c_reg_cfg     i2c_reg_cfg_inst
(
    .i2c_clk     (i2c_clk   ),   //ϵͳʱ��,��i2cģ�鴫��
    .sys_rst_n   (sys_rst_n ),   //ϵͳ��λ,����Ч
    .cfg_end     (i2c_end   ),   //�����Ĵ����������

    .cfg_start   (cfg_start ),   //�����Ĵ������ô����ź�
    .cfg_data    (cfg_data  ),   //�Ĵ����ĵ�ַ������
    .cfg_done    (cfg_done  )    //�Ĵ�����������ź�
); 

endmodule
