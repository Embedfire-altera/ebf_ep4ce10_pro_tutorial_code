`timescale  1ns/1ns
////////////////////////////////////////////////////////////////////////
// Author        : EmbedFire
// Create Date   : 2019/10/10
// Module Name   : ip_receive
// Project Name  : eth_tft_pic
// Target Devices: Altera EP4CE10F17C8N
// Tool Versions : Quartus 13.0
// Description   : UDP协议数据接收模块
// 
// Revision      : V1.0
// Additional Comments:
// 
// 实验平台: 野火_征途Pro_FPGA开发板
// 公司    : http://www.embedfire.com
// 论坛    : http://www.firebbs.cn
// 淘宝    : https://fire-stm32.taobao.com
////////////////////////////////////////////////////////////////////////

module  ip_receive
#(
    parameter   BOARD_MAC   = 48'hFF_FF_FF_FF_FF_FF ,   //板卡MAC地址
    parameter   BOARD_IP    = 32'hFF_FF_FF_FF           //板卡IP地址
)
(
    input   wire            sys_clk     ,   //时钟信号
    input   wire            sys_rst_n   ,   //复位信号,低电平有效
    input   wire            eth_rxdv    ,   //数据有效信号
    input   wire    [3:0]   eth_rx_data ,   //输入数据

    output  reg             rec_data_en ,   //数据接收使能信号
    output  reg     [31:0]  rec_data    ,   //接收数据
    output  reg             rec_end     ,   //数据包接收完成信号
    output  reg     [15:0]  rec_data_num    //接收数据字节数
);

//********************************************************************//
//****************** Parameter and Internal Signal *******************//
//********************************************************************//
//parameter define
localparam  IDLE        =   7'b000_0001, //初始状态
            PACKET_HEAD =   7'b000_0010, //接收数据包头
            ETH_HEAD    =   7'b000_0100, //接收以太网首部
            IP_HEAD     =   7'b000_1000, //接收IP首部
            UDP_HEAD    =   7'b001_0000, //接收UDP首部
            REC_DATA    =   7'b010_0000, //接收数据
            REC_END     =   7'b100_0000; //单包数据传输结束

//wire  define
wire            ip_flag         ;   //IP地址正确标志
wire            mac_flag        ;   //MAC地址正确标志
wire            rd_data_fall    ;   //数据接收状态下降沿

//reg   define
reg             eth_rxdv_reg    ;   //数据有效信号打拍
reg     [3:0]   eth_rx_data_reg ;   //输入数据打拍
reg             data_sw_en      ;   //数据拼接使能信号
reg             data_en         ;   //拼接后的数据使能信号
reg     [7:0]   data            ;   //拼接后的数据
reg     [6:0]   state           ;   //状态机状态变量
reg             sw_en           ;   //状态跳转标志信号
reg             err_en          ;   //数据读取错误信号
reg     [4:0]   cnt_byte        ;   //字节计数器
reg     [47:0]  des_mac         ;   //目的MAC地址,本模块中表示开发板MAC地址
reg     [31:0]  des_ip          ;   //目的IP地址,本模块中表示开发板IP地址
reg     [5:0]   ip_len          ;   //IP首部字节长度
reg     [15:0]  udp_len         ;   //UDP部分字节长度
reg     [15:0]  data_len        ;   //有效数据字节长度
reg     [15:0]  cnt_data        ;   //接收数据字节计数器
reg     [1:0]   cnt_rec_data    ;   //数据计数器,单位4字节
reg     [2:0]   cnt_pkb         ;   //数据包计数器
reg     [7:0]   cnt_pkb_b       ;   //大包计数器
reg             rd_data_flag_d1 ;   //数据接收状态标志信号打一拍
reg             rd_data_flag_d2 ;   //数据接收状态标志信号打两拍

//********************************************************************//
//***************************** Main Code ****************************//
//********************************************************************//
//eth_rxdv_reg:数据有效信号打拍
always@(negedge sys_clk or negedge sys_rst_n)
    if(sys_rst_n == 1'b0)
        eth_rxdv_reg    <=  1'b0;
    else
        eth_rxdv_reg    <=  eth_rxdv;

//eth_rx_data_reg:输入数据打拍
always@(negedge sys_clk or negedge sys_rst_n)
    if(sys_rst_n == 1'b0)
        eth_rx_data_reg <=  4'b0;
    else
        eth_rx_data_reg <=  eth_rx_data;

//data_sw_en:数据拼接使能
always@(negedge sys_clk or negedge sys_rst_n)
    if(sys_rst_n == 1'b0)
        data_sw_en  <=  1'b0;
    else    if(eth_rxdv_reg == 1'b1)
        data_sw_en  <=  ~data_sw_en;
    else
        data_sw_en  <=  1'b0;

//data_en:拼接后的数据使能信号
always@(negedge sys_clk or negedge sys_rst_n)
    if(sys_rst_n == 1'b0)
        data_en <=  1'b0;
    else
        data_en <=  data_sw_en;

//data:拼接后的数据
always@(posedge sys_clk or negedge sys_rst_n)
    if(sys_rst_n == 1'b0)
        data    <=  8'b0;
    else    if((eth_rxdv_reg == 1'b1) && (data_sw_en == 1'b0))
        data    <=  {eth_rx_data,eth_rx_data_reg};
    else
        data    <=  data;

//state:状态机状态变量
always@(posedge sys_clk or negedge sys_rst_n)
    if(sys_rst_n == 1'b0)
        state   <=  IDLE;
    else    case(state)
        IDLE:
            if(sw_en == 1'b1)
                state   <=  PACKET_HEAD;
            else
                state   <=  IDLE;
        PACKET_HEAD:
            if(sw_en == 1'b1)
                state   <=  ETH_HEAD;
            else    if(err_en == 1'b1)
                state   <=  REC_END;
            else
                state   <=  PACKET_HEAD;
        ETH_HEAD:
            if(sw_en == 1'b1)
                state   <=  IP_HEAD;
            else    if(err_en == 1'b1)
                state   <=  REC_END;
            else
                state   <=  ETH_HEAD;
        IP_HEAD:
            if(sw_en == 1'b1)
                if(cnt_pkb == 3'd0)
                    state   <=  UDP_HEAD;
                else
                    state   <=  REC_DATA;
                
            else    if(err_en == 1'b1)
                state   <=  REC_END;
            else
                state   <=  IP_HEAD;
        UDP_HEAD:
            if(sw_en == 1'b1)
                state   <=  REC_DATA;
            else
                state   <=  UDP_HEAD;
        REC_DATA:
            if(sw_en == 1'b1)
                state   <=  REC_END;
            else
                state   <=  REC_DATA;
        REC_END:
            if(sw_en == 1'b1)
                state   <=  IDLE;
            else
                state   <=  REC_END;
        default:state   <=  IDLE;
    endcase

//sw_en:状态跳转标志信号
always @(posedge sys_clk or negedge sys_rst_n)
    if(sys_rst_n == 1'b0)
        sw_en   <=  1'b0;
    else    if((state == IDLE) && (data_en == 1'b1) && (data == 8'h55))
        sw_en   <=  1'b1;
    else    if((state == PACKET_HEAD) && (data_en == 1'b1)
            && (cnt_byte == 5'd6) && (data == 8'hd5))
        sw_en   <=  1'b1;
    else    if((state == ETH_HEAD) && (data_en == 1'b1) && (cnt_byte == 8'd13)
            && ((des_mac == BOARD_MAC) || (des_mac == 48'hFF_FF_FF_FF_FF_FF)))
        sw_en   <=  1'b1;
    else    if((state == IP_HEAD) && (data_en == 1'b1)
            && (cnt_byte == ip_len - 1'b1) && (des_ip[23:0] == BOARD_IP[31:8])
            && (data == BOARD_IP[7:0]))
        sw_en   <=  1'b1;
    else    if((state == UDP_HEAD) && (data_en == 1'b1) && (cnt_byte == 8'd7))
        sw_en   <=  1'b1;
    else    if((state == REC_DATA) && (data_en == 1'b1)
            && (cnt_data == data_len - 1'b1))
        sw_en   <=  1'b1;
    else    if((state == REC_END) && (eth_rxdv_reg == 1'b0) && (sw_en == 1'b0))
        sw_en   <=  1'b1;
    else
        sw_en   <=  1'b0;

//err_en:数据读取错误信号
always@(posedge sys_clk or negedge sys_rst_n)
    if(sys_rst_n == 1'b0)
        err_en  <=  1'b0;
    else    if((state == PACKET_HEAD) && (data_en == 1'b1)
                && (cnt_byte < 5'd6) && (data != 8'h55))
        err_en  <=  1'b1;
    else    if((state == PACKET_HEAD) && (data_en == 1'b1)
                && (cnt_byte == 5'd6) && (data != 8'hd5))
        err_en  <=  1'b1;
    else    if((state == ETH_HEAD) && (data_en == 1'b1)
                && (cnt_byte == 5'd13) && (mac_flag == 1'b0))
        err_en  <=  1'b1;
    else    if((state == IP_HEAD) && (data_en == 1'b1)
                && (cnt_byte == 5'd19) && (ip_flag == 1'b0))
        err_en  <=  1'b1;
    else
        err_en  <=  1'b0;

//cnt_byte:字节计数器
always @(posedge sys_clk or negedge sys_rst_n)
    if(sys_rst_n == 1'b0)
        cnt_byte    <=  5'd0;
    else    if((state == PACKET_HEAD) && (data_en == 1'b1))
        if(cnt_byte == 5'd6)
            cnt_byte <= 5'd0;
        else
            cnt_byte <= cnt_byte + 5'd1;
    else    if((state == ETH_HEAD) && (data_en == 1'b1))
        if(cnt_byte == 5'd13)
            cnt_byte    <=  5'd0;
        else
            cnt_byte    <=  cnt_byte + 5'b1;
    else    if((state == IP_HEAD) && (data_en == 1'b1))
        if(cnt_byte == 5'd19)
            if(ip_flag == 1'b1)
                begin
                    if(cnt_byte == ip_len - 1'b1)
                        cnt_byte    <=  5'd0;
                end
            else
                cnt_byte <= 5'd0;
        else    if(cnt_byte == ip_len - 1'b1)
            cnt_byte    <=  5'd0;
        else
            cnt_byte    <=  cnt_byte + 5'd1;
    else    if((state == UDP_HEAD) && (data_en == 1'b1))
        if(cnt_byte == 5'd7)
            cnt_byte <= 5'd0;
        else
            cnt_byte    <=  cnt_byte + 5'd1;
    else
        cnt_byte    <=  cnt_byte;

//des_mac:目的MAC地址,本模块中表示开发板MAC地址
always@(posedge sys_clk or negedge sys_rst_n)
    if(sys_rst_n == 1'b0)
        des_mac <=  48'h0;
    else    if((state == ETH_HEAD) && (data_en == 1'b1)
                && (cnt_byte < 8'd6))
        des_mac <= {des_mac[39:0],data};

//mac_flag:MAC地址正确标志
assign  mac_flag = ((state == ETH_HEAD) && (des_mac == BOARD_MAC))
                    ? 1'b1 : 1'b0;

//des_ip:目的IP地址,本模块中表示开发板IP地址
always @(posedge sys_clk or negedge sys_rst_n)
    if(sys_rst_n == 1'b0)
        des_ip  <=  32'd0;
    else    if((state == IP_HEAD) && (data_en == 1'b1)
            && (cnt_byte > 5'd15) && (cnt_byte <= 5'd19))
        des_ip  <=  {des_ip[23:0],data};
    else
        des_ip  <=  des_ip;

//ip_flag:IP地址正确标志
assign  ip_flag = ((des_ip[23:0] == BOARD_IP[31:8])
                && (data == BOARD_IP[7:0])) ? 1'b1 : 1'b0;

//ip_len:IP首部字节长度
always@(posedge sys_clk or negedge sys_rst_n)
    if(sys_rst_n == 1'b0)
        ip_len  <=  6'b0;
    else    if((state == IP_HEAD) && (data_en == 1'b1)
                && (cnt_byte == 8'd0))
        ip_len  <=  {data[3:0],2'b00};

//udp_len:UDP部分字节长度
always@(posedge sys_clk or negedge sys_rst_n)
    if(sys_rst_n == 1'b0)
        udp_len <=  16'd0;
    else    if((state == UDP_HEAD) && (data_en == 1'b1)
            && (cnt_byte >= 8'd4) && (cnt_byte <= 8'd5))
        udp_len <=  {udp_len[7:0],data};

//data_len:有效数据字节长度
always@(posedge sys_clk or negedge sys_rst_n)
    if(sys_rst_n == 1'b0)
        data_len    <=  16'd0;
    else    if(cnt_pkb_b < 93)
        if(cnt_pkb == 3'd0)
            data_len    <=  16'd1472;
        else    if(cnt_pkb == 3'd5)
            data_len    <=  16'd800;
        else
            data_len    <=  16'd1480;
    else    if(cnt_pkb_b == 93)
        if(cnt_pkb == 3'd0)
            data_len    <=  16'd1472;
        else    if(cnt_pkb == 3'd4)
            data_len    <=  16'd232;
        else
            data_len    <=  16'd1480;

//cnt_data:接收数据字节计数器
always@(posedge sys_clk or negedge sys_rst_n)
    if(sys_rst_n == 1'b0)
        cnt_data    <=  16'd0;
    else    if((state == REC_DATA) && (data_en == 1'b1))
        if(cnt_data == (data_len - 1'b1))
            cnt_data    <=  16'd0;
        else
            cnt_data    <=  cnt_data + 16'd1;

//  rec_data_en:数据接收使能信号
always@(posedge sys_clk or negedge sys_rst_n)
    if(sys_rst_n == 1'b0)
        rec_data_en  <=  1'b0;
    else    if((state == REC_DATA) && (data_en == 1'b1)
        && ((cnt_data == (data_len - 1'b1)) || (cnt_rec_data == 2'd3)))
        rec_data_en  <=  1'b1;
    else
        rec_data_en  <=  1'b0;

//rec_data:接收数据
always@(posedge sys_clk or negedge sys_rst_n)
    if(sys_rst_n == 1'b0)
        rec_data    <=  32'b0;
    else    if((state == REC_DATA) && (data_en == 1'b1))
        if(cnt_rec_data == 2'd0)
            rec_data[31:24] <=  data;
        else    if(cnt_rec_data == 2'd1)
            rec_data[23:16] <=  data;
        else    if(cnt_rec_data == 2'd2) 
            rec_data[15:8]  <=  data;        
        else    if(cnt_rec_data==2'd3)
            rec_data[7:0]   <=  data;
        else
            rec_data    <=  rec_data;
    else
        rec_data    <=  rec_data;

//rec_data_num:接收数据字节数
always@(posedge sys_clk or negedge sys_rst_n)
    if(sys_rst_n == 1'b0)
        rec_data_num    <=  16'b0;
    else    if((state == REC_DATA) && (data_en == 1'b1)
                && (cnt_data == (data_len - 1'b1)))
        rec_data_num    <=  data_len;

//cnt_rec_data:数据计数器,单位4字节
always@(posedge sys_clk or negedge sys_rst_n)
    if(sys_rst_n == 1'b0)
        cnt_rec_data    <=  2'd0;
    else    if((state == REC_DATA) && (data_en == 1'b1))
        if(cnt_data == (data_len - 1'b1))
            cnt_rec_data    <=  2'd0;
        else
            cnt_rec_data    <=  cnt_rec_data + 2'd1;

//rd_data_flag_d1,rd_data_flag_d2
//数据接收状态标志信号打一拍,数据接收状态标志信号打两拍
always@(posedge sys_clk or negedge sys_rst_n)
    if(sys_rst_n == 1'b0)
        begin
            rd_data_flag_d1        <=  1'b0;
            rd_data_flag_d2    <=  1'b0;
        end
    else
        begin
            rd_data_flag_d1        <=  state[5];
            rd_data_flag_d2    <=  rd_data_flag_d1;
        end

//rd_data_fall:数据接收状态下降沿
assign  rd_data_fall = ((rd_data_flag_d1 == 1'b0)
                        && (rd_data_flag_d2 == 1'b1))
                        ? 1'b1 : 1'b0;

//cnt_pkb:数据包计数器
always@(posedge sys_clk or negedge sys_rst_n)
    if(sys_rst_n == 1'b0)
        cnt_pkb <=  3'd0;
    else    if(rd_data_fall == 1'b1)
        if(cnt_pkb_b < 93)
            if(cnt_pkb == 3'd5)
                cnt_pkb <=  3'd0;
            else
                cnt_pkb <=  cnt_pkb + 1'b1;
        else    if(cnt_pkb_b == 93)
            if(cnt_pkb == 3'd4)
                cnt_pkb <=  3'd0;
            else
                cnt_pkb <=  cnt_pkb + 1'b1;
    else
        cnt_pkb <=  cnt_pkb;

//cnt_pkb_b:大包计数器
always@(posedge sys_clk or negedge sys_rst_n)
    if(sys_rst_n == 1'b0)
        cnt_pkb_b   <=  8'd0;
    else    if((cnt_pkb_b == 93) && (cnt_pkb == 3'd4) && (rd_data_fall == 1'b1))
        cnt_pkb_b   <=  8'd0;
    else    if((cnt_pkb_b < 93) && (cnt_pkb == 3'd5) && (rd_data_fall == 1'b1))
        cnt_pkb_b   <=  cnt_pkb_b + 1'b1;
    else
        cnt_pkb_b   <=  cnt_pkb_b;

//rec_end:数据包接收完成信
always@(posedge sys_clk or negedge sys_rst_n)
    if(sys_rst_n == 1'b0)
        rec_end     <=  1'b0;
    else    if((state == REC_DATA) && (data_en == 1'b1)
                && (cnt_data == (data_len - 1'b1)))
        rec_end     <=  1'b1;
    else
        rec_end     <=  1'b0;

endmodule


