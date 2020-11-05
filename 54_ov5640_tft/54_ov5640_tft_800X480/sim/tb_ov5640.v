`timescale  1ns/1ps

module  tb_ov5640();

wire    ov5640_pwdn ;
wire    ov5640_rst_n;
wire    power_done  ;
wire    busy        ;
wire    rd_iic_data ;
wire    iic_clk     ;
wire    iic_sda     ;

reg     sys_clk     ;
reg     sys_rst_n   ;
reg     start       ;
reg     [31:0]  wr_data;

initial
    begin
        sys_clk     =   1'b0;
        sys_rst_n   <=   1'b0;
        start       <=  1'b0;
        wr_data     <=  32'h78300a56;
        #100
        sys_rst_n   <=  1'b1;
        #100
        start       <=  1'b1;
        #20
        start       <=  1'b0;
        #2000
        start       <=  1'b1;
        wr_data     <=  32'h79300a56;
        #20
        start       <=  1'b0;
    end

always  #10 sys_clk =   ~sys_clk;

power_ctrl  power_ctrl_inst(
    .sclk        (sys_clk        ),
    .s_rst_n      (sys_rst_n      ),

    .ov5640_pwdn    (ov5640_pwdn    ),
    .ov5640_rst_n   (ov5640_rst_n   ),
    .power_done     (power_done     )

);

ov5640_iic     ov5640_iic_inst(
    .sclk     (sys_clk    ),
    .s_rst_n   (sys_rst_n ),
    .start       (start      ),   //iic总线工作的触发信号
    .wdata     (wr_data    ),

    .busy        (busy       ),   //iic总线处于忙碌状态
    .riic_data (rd_iic_data),
    .iic_scl     (iic_clk    ),
    .iic_sda     (iic_sda    )

);

endmodule