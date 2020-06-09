
create_clock -name "eth_rx_clk" -period 40.000ns [get_ports {eth_rx_clk}]
#create_clock -name "eth_tx_clk" -period 40.000ns [get_ports {eth_tx_clk}]

derive_pll_clocks -create_base_clocks

derive_clock_uncertainty
