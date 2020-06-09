//////////////////////////////////////////////////////////////////////////////////
// Author: EmbedFire
// Create Date: 2019/08/20
// Module Name: audio_loopback
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
module  audio_loopback
(
    input   wire            sys_clk     ,   //ϵͳʱ�ӣ�Ƶ��50MHz
    input   wire            sys_rst_n   ,   //ϵͳ��λ���͵�ƽ��Ч
    input   wire            audio_bclk  ,   //WM8978�����λʱ��
    input   wire            audio_lrc   ,   //WM8978�����������/�Ҷ���ʱ��
    input   wire            audio_adcdat,   //WM8978ADC�������

    output  wire            scl         ,   //�����wm8978�Ĵ���ʱ���ź�scl
    output  wire            audio_mclk  ,   //���WM8978��ʱ��,Ƶ��12MHz
    output  wire            audio_dacdat,   //���DAC���ݸ�WM8978

    inout   wire            sda         ,   //�����wm8978�Ĵ��������ź�sda
    
    output  wire    [23:0]  adc_data    ,   //һ�ν��յ�����
    output  wire            rcv_done    ,   //һ�����ݽ������
    input   wire    [23:0]  dac_data    ,   //��WM8978���͵�����
    output  wire            send_done       //һ�����ݷ������
    
);

//********************************************************************//
//*************************** Instantiation **************************//
//********************************************************************//

//------------------- clk_gen_inst ----------------------
clk_gen     clk_gen_inst
(
    .areset (~sys_rst_n ),  //�첽��λ��ȡ������
    .inclk0 (sys_clk    ),  //����ʱ�ӣ�50MHz��

    .c0     (audio_mclk ),  //���ʱ�ӣ�12MHz��
    .locked ()              //����ȶ�ʱ�ӱ�־�ź�

    );

//------------------- audio_rcv_inst -------------------
audio_rcv   audio_rcv_inst
(
    .audio_bclk      (audio_bclk  ),   //WM8978�����λʱ��
    .sys_rst_n       (sys_rst_n   ),   //ϵͳ��λ������Ч
    .audio_lrc       (audio_lrc   ),   //WM8978�����������/�Ҷ���ʱ��
    .audio_adcdat    (audio_adcdat),   //WM8978ADC�������

    .adc_data        (adc_data    ),   //һ�ν��յ�����
    .rcv_done        (rcv_done    )    //һ�����ݽ������

);

//------------------ audio_send_inst ------------------
audio_send  audio_send_inst
(
    .audio_bclk      (audio_bclk  ),   //WM8978�����λʱ��
    .sys_rst_n       (sys_rst_n   ),   //ϵͳ��λ������Ч
    .audio_lrc       (audio_lrc   ),   //WM8978���������/�Ҷ���ʱ��
    .dac_data        (dac_data    ),   //��WM8978���͵�����

    .audio_dacdat    (audio_dacdat),   //����DAC���ݸ�WM8978
    .send_done       (send_done   )    //һ�����ݷ������

);

//----------------- wm8978_cfg_inst --------------------
wm8978_cfg  wm8978_cfg_inst
(
    .sys_clk     (sys_clk   ),  //ϵͳʱ�ӣ�Ƶ��50MHz
    .sys_rst_n   (sys_rst_n ),  //ϵͳ��λ���͵�ƽ��Ч

    .i2c_scl     (scl       ),  //�����wm8978�Ĵ���ʱ���ź�scl
    .i2c_sda     (sda       )   //�����wm8978�Ĵ��������ź�sda

);

endmodule
