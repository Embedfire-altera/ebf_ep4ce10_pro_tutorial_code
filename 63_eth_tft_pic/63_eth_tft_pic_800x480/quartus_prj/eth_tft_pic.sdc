create_clock -name "eth_rx_clk" -period 40.000ns [get_ports {eth_rx_clk}]

derive_pll_clocks -create_base_clocks

derive_clock_uncertainty
