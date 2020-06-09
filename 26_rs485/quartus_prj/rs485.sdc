create_clock -name "sys_clk" -period 20.000ns [get_ports {sys_clk}]

derive_pll_clocks -create_base_clocks

derive_clock_uncertainty