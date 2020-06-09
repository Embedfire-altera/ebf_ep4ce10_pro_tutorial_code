//////////////////////////////////////////////////////////////////////////////////
// Author: EmbedFire
// Create Date: 2019/08/19
// Module Name: audio_rcv
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
module  audio_rcv
(
    input   wire        audio_bclk     ,   //WM8978�����λʱ��
    input   wire        sys_rst_n      ,   //ϵͳ��λ������Ч
    input   wire        audio_lrc      ,   //WM8978�����������/�Ҷ���ʱ��
    input   wire        audio_adcdat   ,   //WM8978ADC�������

    output  reg [23:0]  adc_data       ,   //һ�ν��յ�����
    output  reg         rcv_done           //һ�����ݽ������

);

//********************************************************************//
//****************** Parameter and Internal Signal *******************//
//********************************************************************//

//reg   define
reg             audio_lrc_d1;   //����ʱ�Ӵ�һ���ź�
reg     [4:0]   adcdat_cnt  ;   //WM8978ADC�������λ��������
reg     [23:0]  data_reg    ;   //adc_data���ݼĴ���

//wire  define
wire            lrc_edge    ;   //����ʱ���ź��ر�־�ź�

//********************************************************************//
//***************************** Main Code ****************************//
//********************************************************************//

//ʹ���������������ź��ر�־�ź�
assign  lrc_edge    =   audio_lrc   ^   audio_lrc_d1; 

//��audio_lrc�źŴ�һ���Է������ź��ر�־�ź�
always@(posedge audio_bclk  or  negedge sys_rst_n)
    if(sys_rst_n == 1'b0)
        audio_lrc_d1    <=  1'b0;
    else
        audio_lrc_d1    <=  audio_lrc;
        
//adcdat_cnt:���ź��ر�־�ź�Ϊ�ߵ�ƽʱ������������
always@(posedge audio_bclk  or  negedge sys_rst_n)
    if(sys_rst_n == 1'b0)
        adcdat_cnt    <=  5'b0;
    else    if(lrc_edge == 1'b1)
        adcdat_cnt    <=  5'b0;
    else    if(adcdat_cnt < 5'd26)
        adcdat_cnt  <=  adcdat_cnt + 1'b1;
    else
        adcdat_cnt  <=  adcdat_cnt;

//��WM8978�����ADC���ݼĴ���data_reg�У�һ�μĴ�24λ
always@(posedge audio_bclk  or  negedge sys_rst_n)
    if(sys_rst_n == 1'b0)
        data_reg    <=  24'b0;
    else    if(adcdat_cnt <= 5'd23)
        data_reg[23-adcdat_cnt] <=  audio_adcdat;
    else
        data_reg    <=  data_reg;
        
//�����һλ���ݴ���֮�󣬶����Ĵ�����ֵ��adc_data
always@(posedge audio_bclk  or  negedge sys_rst_n)
    if(sys_rst_n == 1'b0)
        adc_data    <=  24'b0;
    else    if(adcdat_cnt == 5'd24)
        adc_data    <=  data_reg;
    else
        adc_data    <=  adc_data;
        
//�����һλ���ݴ���֮�����һ��ʱ�ӵ���ɱ�־�ź�
always@(posedge audio_bclk  or  negedge sys_rst_n)
    if(sys_rst_n == 1'b0)
        rcv_done    <=  1'b0;
    else    if(adcdat_cnt == 5'd24)
        rcv_done    <=  1'b1;
    else
        rcv_done    <=  1'b0;

endmodule
