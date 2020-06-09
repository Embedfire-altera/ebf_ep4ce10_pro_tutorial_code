`timescale  1ns/1ns
////////////////////////////////////////////////////////////////////////
// Author        : EmbedFire
// Create Date   : 2019/09/06
// Module Name   : pcf8563_ctrl
// Project Name  : rtc
// Target Devices: Altera EP4CE10F17C8N
// Tool Versions : Quartus 13.0
// Description   : 
// 
// Revision      : V1.0
// Additional Comments:
// 
// ʵ��ƽ̨: Ұ��_��;Pro_FPGA������
// ��˾    : http://www.embedfire.com
// ��̳    : http://www.firebbs.cn
// �Ա�    : https://fire-stm32.taobao.com
////////////////////////////////////////////////////////////////////////

module  pcf8563_ctrl 
#(
    parameter   TIME_INIT = 48'h19_09_07_16_00_00
)
(
    input   wire            sys_clk     ,   //ϵͳʱ�ӣ�Ƶ��50MHz
    input   wire            i2c_clk     ,   //i2c����ʱ��
    input   wire            sys_rst_n   ,   //��λ�źţ�����Ч
    input   wire            i2c_end     ,   //i2cһ�ζ�/д�������
    input   wire    [7:0]   rd_data     ,   //���i2c�豸��ȡ����
    input   wire            key_flag    ,   //�����������־�ź�

    output  reg             wr_en       ,   //���дʹ���ź�
    output  reg             rd_en       ,   //�����ʹ���ź�
    output  reg             i2c_start   ,   //���i2c�����ź�
    output  reg     [15:0]  byte_addr   ,   //���i2c�ֽڵ�ַ
    output  reg     [7:0]   wr_data     ,   //���i2c�豸����
    output  reg     [23:0]  data_out        //������������ʾ��bcd������
    
);

//********************************************************************//
//******************** Parameter and Internal Signal *****************//
//********************************************************************//

//parameter define  
localparam   S_WAIT         =   4'd1    ,   //�ϵ�ȴ�״̬
             INIT_SEC       =   4'd2    ,   //��ʼ����
             INIT_MIN       =   4'd3    ,   //��ʼ����
             INIT_HOUR      =   4'd4    ,   //��ʼ��Сʱ
             INIT_DAY       =   4'd5    ,   //��ʼ���� 
             INIT_MON       =   4'd6    ,   //��ʼ���� 
             INIT_YEAR      =   4'd7    ,   //��ʼ���� 
             RD_SEC         =   4'd8    ,   //����
             RD_MIN         =   4'd9    ,   //����
             RD_HOUR        =   4'd10   ,   //��Сʱ
             RD_DAY         =   4'd11   ,   //����
             RD_MON         =   4'd12   ,   //����
             RD_YEAR        =   4'd13   ;   //����
localparam   CNT_WAIT_8MS   =   8000    ;   //8msʱ�����ֵ

//reg   define
reg [7:0]   year        ;   //������
reg [7:0]   month       ;   //������
reg [7:0]   day         ;   //������
reg [7:0]   hour        ;   //Сʱ����
reg [7:0]   minute      ;   //������
reg [7:0]   second      ;   //������
reg         data_flag   ;   //�����л���־�ź�
reg [3:0]   state       ;   //״̬��״̬
reg [12:0]  cnt_wait    ;   //�ȴ�������

//********************************************************************//
//***************************** Main Code ****************************//
//********************************************************************//

//���������л��ı�־�ź�
always@(posedge sys_clk or  negedge sys_rst_n)
    if(sys_rst_n == 1'b0)
        data_flag   <=  1'b0;
    else    if(key_flag ==  1'b1)
        data_flag   <=  ~data_flag;
    else
        data_flag   <=  data_flag;

//data_flagΪ0ʱ��ʾʱ���룬Ϊ1ʱ��ʾ������
always@(posedge sys_clk or  negedge sys_rst_n)
    if(sys_rst_n == 1'b0)
        data_out    <=  24'd0;
    else    if(data_flag == 1'b0)
        data_out    <=  {hour,minute,second};
    else
        data_out    <=  {year,month,day};

//״̬��״̬��ת
always@(posedge i2c_clk or  negedge sys_rst_n)
    if(sys_rst_n == 1'b0)
        begin
            state   <=  S_WAIT;
            cnt_wait    <=  13'd0;
        end
    //״̬����ת����һ��״̬ʱ��������0���ڵ�ǰ״̬һֱ����
    else    case(state)
    //�ϵ�ȴ�8ms����ת��ϵͳ����״̬
        S_WAIT:
            if(cnt_wait == CNT_WAIT_8MS)
                begin
                    state       <=  INIT_SEC;
                    cnt_wait    <=  13'd0;
                end
            else
                begin
                    state       <=  S_WAIT;
                    cnt_wait    <=  cnt_wait + 1'b1;
                end
    //��ʼ����״̬����ʼ�����i2c_end == 1'b1������ת����һ״̬
        INIT_SEC:
            if(i2c_end == 1'b1)
                begin
                    state       <=  INIT_MIN;
                    cnt_wait    <=  13'd0;
                end
            else
                begin
                    state       <=  INIT_SEC;
                    cnt_wait    <=  cnt_wait+1;
                end
    //��ʼ����״̬����ʼ���ֺ�i2c_end == 1'b1������ת����һ״̬
        INIT_MIN:
            if(i2c_end == 1'b1)
                begin
                    state       <=  INIT_HOUR ;
                    cnt_wait    <=  13'd0      ;
                end
            else
                begin
                    state       <=  INIT_MIN       ;
                    cnt_wait    <=  cnt_wait + 1'b1 ;
                end
                    
    //��ʼ��ʱ״̬����ʼ��ʱ��i2c_end == 1'b1������ת����һ״̬
        INIT_HOUR:
            if(i2c_end == 1'b1)
                begin
                    state       <=  INIT_DAY;
                    cnt_wait    <=  13'd0;
                end
            else
                begin
                    state       <=  INIT_HOUR       ;
                    cnt_wait    <=  cnt_wait + 1'b1 ;
                end
    //��ʼ����״̬����ʼ���պ�i2c_end == 1'b1������ת����һ״̬
        INIT_DAY:
            if(i2c_end == 1'b1)
                begin
                    state       <=  INIT_MON;
                    cnt_wait    <=  13'd0;
                end
            else
                begin
                    state       <=  INIT_DAY       ;
                    cnt_wait    <=  cnt_wait + 1'b1 ;
                end
    //��ʼ����״̬����ʼ���º�i2c_end == 1'b1������ת����һ״̬
        INIT_MON:
            if(i2c_end == 1'b1)
                begin
                    state       <=  INIT_YEAR;
                    cnt_wait    <=  13'd0;
                end
            else
                begin
                    state       <=  INIT_MON;
                    cnt_wait    <=  cnt_wait +  1'b1;
                end
    //��ʼ����״̬����ʼ�����i2c_end == 1'b1������ת����һ״̬
        INIT_YEAR:
            if(i2c_end == 1)
                begin
                    state   <=  RD_SEC;
                    cnt_wait    <=  13'd0;
                end
            else
                begin
                    state       <=  INIT_YEAR;
                    cnt_wait    <=  cnt_wait +  1'b1;
                end
    //����״̬����ȡ�������ݺ���ת����һ״̬
        RD_SEC:
            if(i2c_end == 1'b1)
                begin
                    state       <=  RD_MIN;
                    cnt_wait    <=  13'd0;
                end
            else
                begin
                    state       <=  RD_SEC;
                    cnt_wait    <=  cnt_wait +  1'b1;
                end
    //����״̬����ȡ������ݺ���ת����һ״̬
        RD_MIN:
            if(i2c_end == 1'b1)
                begin
                    state       <=  RD_HOUR;
                    cnt_wait    <=  13'd0;
                end
            else
                begin
                    state       <=  RD_MIN;
                    cnt_wait    <=  cnt_wait +  1'b1;
                end
    //��ʱ״̬����ȡ��Сʱ���ݺ���ת����һ״̬
        RD_HOUR:
            if(i2c_end == 1'b1)
                begin
                    state       <=  RD_DAY;
                    cnt_wait    <=  13'd0;
                end
            else
                begin
                    state       <=  RD_HOUR;
                    cnt_wait    <=  cnt_wait +  1'b1;
                end
    //����״̬����ȡ�������ݺ���ת����һ״̬
        RD_DAY:
            if(i2c_end == 1'b1)
                begin
                    state       <=  RD_MON;
                    cnt_wait    <=  13'd0;
                end
            else
                begin
                    state       <=  RD_DAY;
                    cnt_wait    <=  cnt_wait +  1'b1;
                end
    //����״̬����ȡ�������ݺ���ת����һ״̬
        RD_MON:
            if(i2c_end == 1'b1)
                begin
                    state       <=  RD_YEAR;
                    cnt_wait    <=  13'd0  ;
                end
            else
                begin
                    state       <=  RD_MON;
                    cnt_wait    <=  cnt_wait +  1'b1;
                end
    //����״̬����ȡ�������ݺ���ת�ض���״̬��ʼ��һ�����ݶ�ȡ
        RD_YEAR:
            if(i2c_end == 1'b1)
                begin
                    state       <=  RD_SEC;
                    cnt_wait    <=  13'd0 ;
                end
            else
                begin
                    state       <=  RD_YEAR;
                    cnt_wait    <=  cnt_wait +  1'b1;
                end
        default:
            begin
                state       <=  S_WAIT;
                cnt_wait    <=  13'd0    ;
            end
    endcase
        
//��״̬�µ��źŸ�ֵ
always@(posedge i2c_clk or  negedge sys_rst_n)
    if(sys_rst_n == 1'b0)
        begin
            wr_en       <=  1'b0    ;
            rd_en       <=  1'b0    ;
            i2c_start   <=  1'b0    ;
            byte_addr   <=  16'd0   ;
            wr_data     <=  8'd0    ;
            year        <=  8'd0    ;
            month       <=  8'd0    ;
            day         <=  8'd0    ;
            hour        <=  8'd0    ;
            minute      <=  8'd0    ;
            second      <=  8'd0    ;
        end
    else    case(state)
        S_WAIT: //�ϵ�ȴ�״̬
            begin
                wr_en       <=  1'b0    ;
                rd_en       <=  1'b0    ;
                i2c_start   <=  1'b0    ;
                byte_addr   <=  16'h0   ;
                wr_data     <=  8'h00   ;
            end 
        INIT_SEC:  //��ʼ����
            if(cnt_wait == 13'd1)
                begin
                    wr_en       <=  1'b1    ;
                    i2c_start   <=  1'b1    ;
                    byte_addr   <=  16'h02  ;
                    wr_data     <=  TIME_INIT[7:0];
                end
            else
                begin
                    wr_en       <=  1'b1    ;
                    i2c_start   <=  1'b0    ;
                    byte_addr   <=  16'h02  ;
                    wr_data     <=  TIME_INIT[7:0];
                end
        INIT_MIN:  //��ʼ����
            if(cnt_wait == 13'd1)
                begin
                    i2c_start   <=  1'b1    ;
                    byte_addr   <=  16'h03  ;
                    wr_data     <=  TIME_INIT[15:8];
                end
            else
                begin
                    i2c_start   <=  1'b0    ;
                    byte_addr   <=  16'h03  ;
                    wr_data     <=  TIME_INIT[15:8];
                end
        INIT_HOUR: //��ʼ��Сʱ
            if(cnt_wait == 13'd1)
                begin
                    i2c_start   <=  1'b1    ;   
                    byte_addr   <=  16'h04  ;
                    wr_data     <=  TIME_INIT[23:16];
                end
            else
                begin
                    i2c_start   <=  1'b0    ;
                    byte_addr   <=  16'h04  ;
                    wr_data     <=  TIME_INIT[23:16];
                end
        INIT_DAY: //��ʼ����
            if(cnt_wait == 13'd1)
                begin
                    i2c_start   <=  1'b1    ;   
                    byte_addr   <=  16'h05  ;
                    wr_data     <=  TIME_INIT[31:24];
                end
            else
                begin
                    i2c_start   <=  1'b0    ;
                    byte_addr   <=  16'h05  ;
                    wr_data     <=  TIME_INIT[31:24];
                end
        INIT_MON: //��ʼ����
            if(cnt_wait == 13'd1)
                begin
                    i2c_start   <=  1'b1    ;   
                    byte_addr   <=  16'h07  ;
                    wr_data     <=  TIME_INIT[39:32];
                end
            else
                begin
                    i2c_start   <=  1'b0    ;
                    byte_addr   <=  16'h07  ;
                    wr_data     <=  TIME_INIT[39:32];
                end
        INIT_YEAR: //��ʼ����
            if(cnt_wait == 13'd1)
                begin
                    i2c_start   <=  1'b1    ;
                    byte_addr   <=  16'h08  ;
                    wr_data     <=  TIME_INIT[47:40];
                end
            else
                begin
                    i2c_start   <=  1'b0    ;
                    byte_addr   <=  16'h08  ;
                    wr_data     <=  TIME_INIT[47:40];
                end
        RD_SEC: //����
            if(cnt_wait == 13'd1)
                i2c_start   <=  1'b1;
            else    if(i2c_end == 1'b1)
                second      <=  rd_data[6:0];
            else
                begin
                    wr_en       <=  1'b0    ;
                    rd_en       <=  1'b1    ;
                    i2c_start   <=  1'b0    ;
                    byte_addr   <=  16'h02  ;
                    wr_data     <=  8'd0    ;
                end
        RD_MIN: //����
            if(cnt_wait == 13'd1)
                i2c_start   <=  1'b1;
            else    if(i2c_end == 1'b1)
                minute      <=  rd_data[6:0];
            else
                begin
                    rd_en       <=  1'b1    ;
                    i2c_start   <=  1'b0    ;
                    byte_addr   <=  16'h03  ;
                end
        RD_HOUR: //��ʱ
            if(cnt_wait == 13'd1)
                i2c_start   <=  1'b1;
            else    if(i2c_end == 1'b1)
                hour        <=  rd_data[5:0];
            else
                begin
                    rd_en       <=  1'b1    ;
                    i2c_start   <=  1'b0    ;
                    byte_addr   <=  16'h04  ;
                end
        RD_DAY: //����
            if(cnt_wait == 13'd1)
                i2c_start   <=  1'b1;
            else    if(i2c_end == 1'b1)
                day      <=  rd_data[5:0];
            else
                begin
                    rd_en       <=  1'b1    ;
                    i2c_start   <=  1'b0    ;
                    byte_addr   <=  16'h05  ;
                end
        RD_MON: //����
            if(cnt_wait == 13'd1)
                i2c_start   <=  1'b1;
            else    if(i2c_end == 1'b1)
                month      <=  rd_data[4:0];
            else
                begin
                    rd_en       <=  1'b1    ;
                    i2c_start   <=  1'b0    ;
                    byte_addr   <=  16'h07  ;
                end
        RD_YEAR: //����
            if(cnt_wait == 13'd1)
                i2c_start   <=  1'b1;
            else    if(i2c_end == 1'b1)
                year        <=  rd_data[7:0];
            else
                begin
                    rd_en       <=  1'b1    ;
                    i2c_start   <=  1'b0    ;
                    byte_addr   <=  16'h08  ;
                end
        default:
        begin
            wr_en       <=  1'b0    ;
            rd_en       <=  1'b0    ;
            i2c_start   <=  1'b0    ;
            byte_addr   <=  16'd0   ;
            wr_data     <=  8'd0    ;
            year        <=  8'd0    ;
            month       <=  8'd0    ;
            day         <=  8'd0    ;
            hour        <=  8'd0    ;
            minute      <=  8'd0    ;
            second      <=  8'd0    ;
        end
    endcase

endmodule
