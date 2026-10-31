set_property -dict { PACKAGE_PIN F14 IOSTANDARD LVCMOS33 } [get_ports { CLK12MHZ }]
create_clock -add -name sys_clk_pin -period 83.333 -waveform {0 41.667} [get_ports { CLK12MHZ }]

## Switch 0
set_property -dict { PACKAGE_PIN H14 IOSTANDARD LVCMOS33 } [get_ports { sw[0] }]

## RGB LED - Red component
set_property -dict { PACKAGE_PIN J15 IOSTANDARD LVCMOS33 } [get_ports { led }]

## Configuration
set_property BITSTREAM.CONFIG.CONFIGRATE 50 [current_design]
set_property CONFIG_VOLTAGE 3.3 [current_design]
set_property CFGBVS VCCO [current_design]
set_property BITSTREAM.CONFIG.SPI_BUSWIDTH 4 [current_design]
set_property CONFIG_MODE SPIx4 [current_design]
