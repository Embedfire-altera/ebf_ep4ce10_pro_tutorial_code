`timescale  1ns/1ns
////////////////////////////////////////////////////////////////////////
// Author        : EmbedFire
// Create Date   : 2019/10/10
// Module Name   : ip_send
// Project Name  : eth_vga_pic
// Target Devices: Altera EP4CE10F17C8N
// Tool Versions : Quartus 13.0
// Description   : UDP协议数据发送模块
// 
// Revision      : V1.0
// Additional Comments:
// 
// 实验平台: 野火_征途Pro_FPGA开发板
// 公司    : http://www.embedfire.com
// 论坛    : http://www.firebbs.cn
// 淘宝    : https://fire-stm32.taobao.com
////////////////////////////////////////////////////////////////////////

module ip_send
#(
    parameter   BOARD_MAC   = 48'hFF_FF_FF_FF_FF_FF ,   //板卡MAC地址
    parameter   BOARD_IP    = 32'hFF_FF_FF_FF       ,   //板卡IP地址
    parameter   BOARD_PORT  = 16'd1234              ,   //板卡端口号
    parameter   PC_MAC      = 48'hFF_FF_FF_FF_FF_FF ,   //PC机MAC地址
    parameter   PC_IP       = 32'hFF_FF_FF_FF       ,   //PC机IP地址
    parameter   PC_PORT     = 16'd1234                  //PC机端口号
)
(
    input   wire            sys_clk         ,   //时钟信号
    input   wire            sys_rst_n       ,   //复位信号,低电平有效
    input   wire            send_en         ,   //数据发送开始信号
    input   wire    [31:0]  send_data       ,   //发送数据
    input   wire    [15:0]  send_data_num   ,   //发送数据有效字节数
    input   wire    [31:0]  crc_data        ,   //CRC校验数据
    input   wire    [3:0]   crc_next        ,   //CRC下次校验完成数据

    output  reg             send_end        ,   //单包数据发送完成标志信号
    output  reg             read_data_req   ,   //读FIFO使能信号
    output  reg             eth_tx_en       ,   //输出数据有效信号
    output  reg     [3:0]   eth_tx_data     ,   //输出数据
    output  reg             crc_en          ,   //CRC开始校验使能
    output  reg             crc_clr             //CRC复位信号
);

//********************************************************************//
//****************** Parameter and Internal Signal *******************//
//********************************************************************//
//parameter define
localparam  IDLE        =   7'b000_0001 ,    //初始状态
            CHECK_SUM   =   7'b000_0010 ,    //IP首部校验
            PACKET_HEAD =   7'b000_0100 ,    //发送数据包头
            ETH_HEAD    =   7'b000_1000 ,    //发送以太网首部
            IP_UDP_HEAD =   7'b001_0000 ,    //发送IP首部和UDP首部
            SEND_DATA   =   7'b010_0000 ,    //发送数据
            CRC         =   7'b100_0000 ;    //发送CRC校验

localparam  ETH_TYPE    =   16'h0800    ;    //协议类型 IP协议

//wire define
wire            rise_send_en    ;   //数据发送开始信号上升沿
wire   [15:0]   send_data_len   ;   //实际发送的数据字节数

//reg define
reg             send_en_dly     ;   //数据发送开始信号打拍
reg     [7:0]   packet_head[7:0];   //数据包头
reg     [7:0]   eth_head[13:0]  ;   //以太网首部
reg     [31:0]  ip_udp_head[6:0];   //IP首部 + UDP首部
reg     [31:0]  check_sum       ;   //IP首部check_sum校验
reg     [15:0]  data_len        ;   //有效数据字节个数
reg     [15:0]  ip_len          ;   //IP字节数
reg     [15:0]  udp_len         ;   //UDP字节数
reg     [6:0]   state           ;   //状态机状态变量
reg             sw_en           ;   //状态跳转标志信号
reg     [4:0]   cnt             ;   //数据计数器
reg     [2:0]   cnt_send_bit    ;   //发送数据比特计数器
reg     [15:0]  data_cnt        ;   //发送有效数据个数计数器
reg     [4:0]   cnt_add         ;   //发送有效数据小于18字节,补充字节计数器

//****************************************************************//
//*************************** Main Code **************************//
//****************************************************************//

//send_en_dly:数据发送开始信号打拍
always @(posedge sys_clk or negedge sys_rst_n)
    if(sys_rst_n == 1'b0)
        send_en_dly <= 1'b0;
    else
        send_en_dly <= send_en;

//rise_send_en:数据发送开始信号上升沿
assign  rise_send_en = ((send_en == 1'b1) && (send_en_dly == 1'b0))
                        ? 1'b1 : 1'b0;

//packet_head:数据包头,数据包头7个8'h55 + 1个8'hd5
always @(posedge sys_clk or negedge sys_rst_n)
    if(sys_rst_n == 1'b0)
        begin
            packet_head[0]  <=  8'h00;
            packet_head[1]  <=  8'h00;
            packet_head[2]  <=  8'h00;
            packet_head[3]  <=  8'h00;
            packet_head[4]  <=  8'h00;
            packet_head[5]  <=  8'h00;
            packet_head[6]  <=  8'h00;
            packet_head[7]  <=  8'h00;
        end
    else
        begin
            packet_head[0]  <=  8'h55;
            packet_head[1]  <=  8'h55;
            packet_head[2]  <=  8'h55;
            packet_head[3]  <=  8'h55;
            packet_head[4]  <=  8'h55;
            packet_head[5]  <=  8'h55;
            packet_head[6]  <=  8'h55;
            packet_head[7]  <=  8'hd5;
        end

//eth_head:以太网首部
always @(posedge sys_clk or negedge sys_rst_n)
    if(sys_rst_n == 1'b0)
        begin
            eth_head[0]     <=  8'h00;
            eth_head[1]     <=  8'h00;
            eth_head[2]     <=  8'h00;
            eth_head[3]     <=  8'h00;
            eth_head[4]     <=  8'h00;
            eth_head[5]     <=  8'h00;
            eth_head[6]     <=  8'h00;
            eth_head[7]     <=  8'h00;
            eth_head[8]     <=  8'h00;
            eth_head[9]     <=  8'h00;
            eth_head[10]    <=  8'h00;
            eth_head[11]    <=  8'h00;
            eth_head[12]    <=  8'h00;
            eth_head[13]    <=  8'h00;
        end
    else
        begin
            eth_head[0]     <=  PC_MAC[47:40]   ;
            eth_head[1]     <=  PC_MAC[39:32]   ;
            eth_head[2]     <=  PC_MAC[31:24]   ;
            eth_head[3]     <=  PC_MAC[23:16]   ;
            eth_head[4]     <=  PC_MAC[15:8]    ;
            eth_head[5]     <=  PC_MAC[7:0]     ;
            eth_head[6]     <=  BOARD_MAC[47:40];
            eth_head[7]     <=  BOARD_MAC[39:32];
            eth_head[8]     <=  BOARD_MAC[31:24];
            eth_head[9]     <=  BOARD_MAC[23:16];
            eth_head[10]    <=  BOARD_MAC[15:8] ;
            eth_head[11]    <=  BOARD_MAC[7:0]  ;
            eth_head[12]    <=  ETH_TYPE[15:8]  ;
            eth_head[13]    <=  ETH_TYPE[7:0]   ;
        end

//ip_udp_head:IP首部 + UDP首部
always @(posedge sys_clk or negedge sys_rst_n)
    if(sys_rst_n == 1'b0)
        ip_udp_head[1][31:16]   <=  16'd0;
    else    if((state == IDLE) && (sw_en == 1'b1))
        begin
            ip_udp_head[0]  <= {8'h45,8'h00,ip_len};
            ip_udp_head[1][31:16] <= ip_udp_head[1][31:16] + 1'b1;
            ip_udp_head[1][15:0] <= 16'h4000;
            ip_udp_head[2] <= {8'h40,8'd17,16'h0};
            ip_udp_head[3] <= BOARD_IP;
            ip_udp_head[4] <= PC_IP;
            ip_udp_head[5] <= {BOARD_PORT,PC_PORT};
            ip_udp_head[6] <= {udp_len,16'h0000};
        end
    else    if((state == CHECK_SUM) && (cnt == 5'd3))
        ip_udp_head[2][15:0] <= ~check_sum[15:0];

//check_sum:IP首部check_sum校验
always @(posedge sys_clk or negedge sys_rst_n)
    if(sys_rst_n == 1'b0)
        check_sum    <=  32'd0;
    else    if(state == CHECK_SUM)
        if(cnt == 5'd0)
            check_sum   <=  ip_udp_head[0][31:16] + ip_udp_head[0][15:0]
                        + ip_udp_head[1][31:16] + ip_udp_head[1][15:0]
                        + ip_udp_head[2][31:16] + ip_udp_head[2][15:0]
                        + ip_udp_head[3][31:16] + ip_udp_head[3][15:0]
                        + ip_udp_head[4][31:16] + ip_udp_head[4][15:0];
        else    if(cnt == 5'd1)
            check_sum   <=  check_sum[31:16] + check_sum[15:0];
        else    if(cnt == 5'd2)
            check_sum   <=  check_sum[31:16] + check_sum[15:0];
        else
            check_sum   <=  check_sum;
    else
        check_sum   <=  check_sum;

//data_len:有效数据字节个数
//ip_len:IP字节数
//udp_len:UDP字节数
always @(posedge sys_clk or negedge sys_rst_n)
    if(sys_rst_n == 1'b0)
        begin
            data_len    <=  16'd0;
            ip_len      <=  16'd0;
            udp_len     <=  16'd0;
        end
    else    if((rise_send_en == 1'b1) && (state == IDLE))
        begin
            data_len    <=  send_data_num;
            ip_len      <=  send_data_num + 16'd28;
            udp_len     <=  send_data_num + 16'd8;
        end

//send_data_len:实际发送的数据字节数
//以太网传输字节数最小为46个字节,其中包括20字节的IP首部和8字节的UDP首部
//有效数据最少为18字节
assign  send_data_len = (data_len >= 16'd18) ? data_len : 16'd18;

//state:状态机状态变量
always @(posedge sys_clk or negedge sys_rst_n)
    if(sys_rst_n == 1'b0)
        state   <=  IDLE;
    else    case(state)
        IDLE:
            if(sw_en == 1'b1)
                state   <=  CHECK_SUM;
            else
                state   <=  IDLE;
        CHECK_SUM:
            if(sw_en == 1'b1)
                state   <=  PACKET_HEAD;
            else
                state   <=  CHECK_SUM;
        PACKET_HEAD:
            if(sw_en == 1'b1)
                state   <=  ETH_HEAD;
            else
                state   <=  PACKET_HEAD;
        ETH_HEAD:
            if(sw_en == 1'b1)
                state   <=  IP_UDP_HEAD;
            else
                state   <=  ETH_HEAD;
        IP_UDP_HEAD:
            if(sw_en == 1'b1)
                state   <=  SEND_DATA;
            else
                state   <=  IP_UDP_HEAD;
        SEND_DATA:
            if(sw_en == 1'b1)
                state   <=  CRC;
            else
                state   <=  SEND_DATA;
        CRC:
            if(sw_en == 1'b1)
                state   <=  IDLE;
            else
                state   <=  CRC;
        default:state   <=  IDLE;
    endcase

//sw_en:状态跳转标志信号
always @(posedge sys_clk or negedge sys_rst_n)
    if(sys_rst_n == 1'b0)
        sw_en <=  1'b0;
    else    if((state == IDLE) && (rise_send_en == 1'b1))
        sw_en <=  1'b1;
    else    if((state == CHECK_SUM) && (cnt == 5'd2))
        sw_en <=  1'b1;
    else    if((state == PACKET_HEAD) && (cnt_send_bit == 3'd0)
                && (cnt == 5'd7))
        sw_en <=  1'b1;
    else    if((state == ETH_HEAD) && (cnt_send_bit == 3'd0)
                && (cnt == 5'd13))
        sw_en <=  1'b1;
    else    if((state == IP_UDP_HEAD) && (cnt_send_bit == 3'd6)
                && (cnt == 5'd6))
        sw_en <=  1'b1;
    else    if((state == SEND_DATA) && (cnt_send_bit[0] == 1'd0)
                && (data_cnt == data_len - 16'd1)
                && (data_cnt + cnt_add >= (send_data_len - 16'd1)))
        sw_en <=  1'b1;
    else    if((state == CRC) && (cnt_send_bit == 3'd6))
        sw_en <=  1'b1;
    else
        sw_en <=  1'b0;

//cnt:数据计数器,对以太网传输的除有效字节数据之外的其他数据计数,不同状态下单位不同
always @(posedge sys_clk or negedge sys_rst_n)
    if(sys_rst_n == 1'b0)
        cnt <=  5'd0;
    else    if(state == CHECK_SUM)
        if(cnt == 5'd3)
            cnt <=  5'd0;
        else
            cnt <=  cnt + 5'd1;
    else    if(state == PACKET_HEAD)
        if(cnt_send_bit != 3'd0)
            if(sw_en == 1'b1)
                cnt <=  5'd0;
            else
                cnt <=  cnt + 5'd1;
        else
            cnt <=  cnt;
    else    if(state == ETH_HEAD)
        if(cnt_send_bit != 3'd0)
            if(sw_en == 1'b1)
                cnt <=  5'd0;
            else
                cnt <=  cnt + 5'd1;
        else
            cnt <=  cnt;
    else    if(state == IP_UDP_HEAD)
        if(cnt_send_bit == 3'd7)
            if(sw_en == 1'b1)
                cnt <=  5'd0;
            else
                cnt <=  cnt + 5'd1;
        else
            cnt <=  cnt;
    else
        cnt <=  cnt;

//cnt_send_bit:发送数据bit计数器
always @(posedge sys_clk or negedge sys_rst_n)
    if(sys_rst_n == 1'b0)
        cnt_send_bit    <=  3'd0;
    else    if(state == PACKET_HEAD)
        if(cnt_send_bit == 3'd0)
            cnt_send_bit    <=  cnt_send_bit + 3'd1;
        else
            cnt_send_bit  <=  3'd0;
    else    if(state == ETH_HEAD)
        if(cnt_send_bit == 3'd0)
            cnt_send_bit    <=  cnt_send_bit + 3'd1;
        else
            cnt_send_bit    <=  3'd0;
    else    if(state == IP_UDP_HEAD)
        cnt_send_bit    <=  cnt_send_bit + 3'd1;
    else    if(state == SEND_DATA)
        if(sw_en == 1'b1)
            cnt_send_bit    <=  3'd0;
        else
            cnt_send_bit    <=  cnt_send_bit + 3'd1;
    else    if(state == CRC)
        cnt_send_bit    <=  cnt_send_bit + 3'd1;
    else
        cnt_send_bit    <=  cnt_send_bit;

//read_data_req:读FIFO使能信号
always @(posedge sys_clk or negedge sys_rst_n)
    if(sys_rst_n == 1'b0)
        read_data_req  <=  1'b0;
    else    if((state == IP_UDP_HEAD) && (cnt_send_bit == 3'd6)
            && (cnt == 5'd6))
        read_data_req  <=  1'b1;
    else    if((state == SEND_DATA) && (cnt_send_bit == 3'd6)
            && (data_cnt != data_len - 16'd1))
        read_data_req  <=  1'b1;
    else
        read_data_req  <=  1'b0;

//eth_tx_en:输出数据有效信号
always @(posedge sys_clk or negedge sys_rst_n)
    if(sys_rst_n == 1'b0)
        eth_tx_en   <=  1'b0;
    else    if((state != IDLE) && (state != CHECK_SUM))
        eth_tx_en   <=  1'b1;
    else
        eth_tx_en   <=  1'b0;

//eth_tx_data:输出数据
always @(posedge sys_clk or negedge sys_rst_n)
    if(sys_rst_n == 1'b0)
        eth_tx_data <=  4'b0;
    else    if(state == PACKET_HEAD)
        if(cnt_send_bit == 3'd0)
            eth_tx_data <=  packet_head[cnt][3:0];
        else
            eth_tx_data <=  packet_head[cnt][7:4];
    else    if(state == ETH_HEAD)
        if(cnt_send_bit == 3'd0)
            eth_tx_data <=  eth_head[cnt][3:0];
        else
            eth_tx_data <=  eth_head[cnt][7:4];
    else    if(state == IP_UDP_HEAD)
        if(cnt_send_bit == 3'd0)
            eth_tx_data <=  ip_udp_head[cnt][27:24];
        else    if(cnt_send_bit == 3'd1)
            eth_tx_data <=  ip_udp_head[cnt][31:28];
        else    if(cnt_send_bit == 3'd2)
            eth_tx_data <=  ip_udp_head[cnt][19:16];
        else    if(cnt_send_bit == 3'd3)
            eth_tx_data <=  ip_udp_head[cnt][23:20];
        else    if(cnt_send_bit == 3'd4)
            eth_tx_data <=  ip_udp_head[cnt][11:8];
        else    if(cnt_send_bit == 3'd5)
            eth_tx_data <=  ip_udp_head[cnt][15:12];
        else    if(cnt_send_bit == 3'd6)
            eth_tx_data <=  ip_udp_head[cnt][3:0];
        else    if(cnt_send_bit == 3'd7)
            eth_tx_data <=  ip_udp_head[cnt][7:4];
        else
            eth_tx_data <=  eth_tx_data;
    else    if(state == SEND_DATA)
        if(cnt_send_bit == 3'd0)
            eth_tx_data <=  send_data[27:24];
        else    if(cnt_send_bit == 3'd1)
            eth_tx_data <=  send_data[31:28];
        else    if(cnt_send_bit == 3'd2)
            eth_tx_data <=  send_data[19:16];
        else    if(cnt_send_bit == 3'd3)
            eth_tx_data <=  send_data[23:20];
        else    if(cnt_send_bit == 3'd4)
            eth_tx_data <=  send_data[11:8];
        else    if(cnt_send_bit == 3'd5)
            eth_tx_data <=  send_data[15:12];
        else    if(cnt_send_bit == 3'd6)
            eth_tx_data <=  send_data[3:0];
        else    if(cnt_send_bit == 3'd7)
            eth_tx_data <=  send_data[7:4];
        else
            eth_tx_data <=  eth_tx_data;
    else    if(state == CRC)
        if(cnt_send_bit == 3'd0)
            eth_tx_data <=  {~crc_next[0], ~crc_next[1], ~crc_next[2], ~crc_next[3]};
        else    if(cnt_send_bit == 3'd1)
            eth_tx_data <=  {~crc_data[24],~crc_data[25],~crc_data[26],~crc_data[27]};
        else    if(cnt_send_bit == 3'd2)
            eth_tx_data <=  {~crc_data[20],~crc_data[21],~crc_data[22],~crc_data[23]};
        else    if(cnt_send_bit == 3'd3)
            eth_tx_data <=  {~crc_data[16],~crc_data[17],~crc_data[18],~crc_data[19]};
        else    if(cnt_send_bit == 3'd4)
            eth_tx_data <=  {~crc_data[12],~crc_data[13],~crc_data[14],~crc_data[15]};
        else    if(cnt_send_bit == 3'd5)
            eth_tx_data <=  {~crc_data[8],~crc_data[9],~crc_data[10],~crc_data[11]};
        else    if(cnt_send_bit == 3'd6)
            eth_tx_data <=  {~crc_data[4],~crc_data[5],~crc_data[6],~crc_data[7]};
        else    if(cnt_send_bit == 3'd7)
            eth_tx_data <=  {~crc_data[0],~crc_data[1],~crc_data[2],~crc_data[3]};
        else
            eth_tx_data <=  eth_tx_data;
    else
        eth_tx_data <=  eth_tx_data;

//crc_en:CRC开始校验使能
always @(posedge sys_clk or negedge sys_rst_n)
    if(sys_rst_n == 1'b0)
        crc_en  <=  1'b0;
    else    if((state == ETH_HEAD) || (state == IP_UDP_HEAD) || (state == SEND_DATA))
        crc_en  <=  1'b1;
    else
        crc_en  <=  1'b0;

//data_cnt:发送有效数据个数计数器
always @(posedge sys_clk or negedge sys_rst_n)
    if(sys_rst_n == 1'b0)
        data_cnt    <=  16'b0;
    else    if(state == SEND_DATA)
        if(sw_en == 1'b1)
            data_cnt    <=  16'd0;
        else    if((cnt_send_bit[0] == 1'b0) && (data_cnt < data_len - 16'd1))
            data_cnt <= data_cnt + 16'd1;
    else
        data_cnt    <=  data_cnt;

//cnt_add:发送有效数据小于18字节,补充字节计数器
always @(posedge sys_clk or negedge sys_rst_n)
    if(sys_rst_n == 1'b0)
        cnt_add <=  5'b0;
    else    if(state == SEND_DATA)
        if(sw_en == 1'b1)
            cnt_add <=  5'd0;
        else    if((cnt_send_bit[0] == 1'b0) && (data_cnt == data_len - 16'd1)
                && (data_cnt + cnt_add < send_data_len - 16'd1))
            cnt_add <= cnt_add + 5'd1;
        else
            cnt_add <=  cnt_add;
    else
        cnt_add <=  cnt_add;

//send_end:单包数据发送完成标志信号
always @(posedge sys_clk or negedge sys_rst_n)
    if(sys_rst_n == 1'b0)
        send_end    <=  1'b0;
    else    if((state == CRC) && (cnt_send_bit == 3'd7))
        send_end    <=  1'b1;
    else
        send_end    <=  1'b0;

//crc_clr:crc值复位信号
always @(posedge sys_clk or negedge sys_rst_n)
    if(sys_rst_n == 1'b0)
        crc_clr <= 1'b0;
    else
        crc_clr <= send_end;

endmodule
