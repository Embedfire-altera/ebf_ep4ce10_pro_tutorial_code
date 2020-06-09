//////////////////////////////////////////////////////////////////////////////////
// Author: EmbedFire
// Create Date: 2019/08/20
// Module Name: audio_send
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
module  audio_send
(
    input   wire            audio_bclk    ,  //WM8978�����λʱ��
    input   wire            sys_rst_n     ,  //ϵͳ��λ������Ч
    input   wire            audio_lrc     ,  //WM8978���������/�Ҷ���ʱ��
    input   wire    [23:0]  dac_data      ,  //��WM8978���͵�����

    output  reg             audio_dacdat  ,  //����DACDAT���ݸ�WM8978
    output  reg             send_done        //һ�����ݷ������

);

//********************************************************************//
//****************** Parameter and Internal Signal *******************//
//********************************************************************//

//reg   define
reg             audio_lrc_d1;   //����ʱ�Ӵ�һ���ź�
reg     [4:0]   dacdat_cnt  ;   //DACDAT���ݷ���λ��������
reg     [23:0]  data_reg    ;   //dac_data���ݼĴ���

//wire  define
wire            lrc_edge    ;   //����ʱ���ź��ر�־�ź�

//********************************************************************//
//***************************** Main Code ****************************//
//********************************************************************//

//ʹ���������������ź��ر�־�ź�
assign  lrc_edge = audio_lrc ^ audio_lrc_d1; 

//��audio_lcr�źŴ�һ���Է������ź��ر�־�ź�
always@(posedge audio_bclk  or  negedge sys_rst_n)
    if(sys_rst_n == 1'b0)
        audio_lrc_d1    <=  1'b0;
    else
        audio_lrc_d1    <=  audio_lrc;
        
//dacdat_cnt:���ź��ر�־�ź�Ϊ�ߵ�ƽʱ������������
always@(posedge audio_bclk  or  negedge sys_rst_n)
    if(sys_rst_n == 1'b0)
        dacdat_cnt    <=  5'b0;
    else    if(lrc_edge == 1'b1)
        dacdat_cnt    <=  5'b0;
    else    if(dacdat_cnt < 5'd26)
        dacdat_cnt  <=  dacdat_cnt + 1'b1;
    else
        dacdat_cnt  <=  dacdat_cnt;

//��Ҫ���͵�dac_data���ݼĴ���data_reg��
always@(posedge audio_bclk  or  negedge sys_rst_n)
    if(sys_rst_n == 1'b0)
        data_reg    <=  24'b0;
    else    if(lrc_edge == 1'b1)
        data_reg <=  dac_data;
    else
        data_reg    <=  data_reg;
        
//�½��ص���ʱ��data_reg������һλһλ����audio_dacdat
always@(negedge audio_bclk  or  negedge sys_rst_n)
    if(sys_rst_n == 1'b0)
        audio_dacdat    <=  1'b0;
    else    if(dacdat_cnt <= 5'd23)
        audio_dacdat    <=  data_reg[23 - dacdat_cnt];
    else
        audio_dacdat    <=  audio_dacdat;

//�����һλ���ݴ���֮�����һ��ʱ�ӵķ�����ɱ�־�ź�
always@(posedge audio_bclk  or  negedge sys_rst_n)
    if(sys_rst_n == 1'b0)
        send_done    <=  1'b0;
    else    if(dacdat_cnt == 5'd24)
        send_done    <=  1'b1;
    else
        send_done    <=  1'b0;

endmodule
