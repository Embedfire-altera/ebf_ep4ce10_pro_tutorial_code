##create work library
vlib work


vlog	"../rtl/ov5640/ov5640_iic.v"
vlog	"../rtl/ov5640/power_ctrl.v"
vlog	"./*.v"


vsim	-voptargs=+acc work.tb_ov5640

# Set the window types
view wave
view structure
view signals


add wave -divider {tb_ov5640}
add wave tb_ov5640/*
add wave -divider {power_ctrl}
add wave tb_ov5640/power_ctrl_inst/*
add wave -divider {ov5640_iic}
add wave tb_ov5640/ov5640_iic_inst/*


run 5us