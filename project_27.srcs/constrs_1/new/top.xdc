## =====================================================
## ZYBO Z7-10 CLOCK INPUT (125 MHz)
## =====================================================
set_property PACKAGE_PIN K17 [get_ports clk]
set_property IOSTANDARD LVCMOS33 [get_ports clk]
create_clock -period 8.000 -name sys_clk [get_ports clk]

## =====================================================
## RESET BUTTON
## =====================================================
set_property PACKAGE_PIN R18 [get_ports reset]
set_property IOSTANDARD LVCMOS33 [get_ports reset]
set_property PULLUP true [get_ports reset]

## =====================================================
## DEBUG LEDs
## =====================================================
set_property PACKAGE_PIN M14 [get_ports {debug_pc[0]}]
set_property PACKAGE_PIN M15 [get_ports {debug_pc[1]}]
set_property PACKAGE_PIN G14 [get_ports {debug_pc[2]}]
set_property PACKAGE_PIN D18 [get_ports {debug_pc[3]}]

set_property IOSTANDARD LVCMOS33 [get_ports {debug_pc[*]}]

## =====================================================
## ACTIVE LED
## =====================================================
set_property PACKAGE_PIN P14 [get_ports debug_active]
set_property IOSTANDARD LVCMOS33 [get_ports debug_active]

## =====================================================
## DEBUG HUB
## =====================================================
set_property C_USER_SCAN_CHAIN 1 [get_debug_cores dbg_hub]
connect_debug_port dbg_hub/clk [get_nets clk_wiz_out]