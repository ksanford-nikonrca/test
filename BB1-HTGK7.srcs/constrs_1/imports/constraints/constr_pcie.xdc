##-----------------------------------------------------------------------------
##
## (c) Copyright 2010-2011 Xilinx, Inc. All rights reserved.
##
## This file contains confidential and proprietary information
## of Xilinx, Inc. and is protected under U.S. and
## international copyright and other intellectual property
## laws.
##
## DISCLAIMER
## This disclaimer is not a license and does not grant any
## rights to the materials distributed herewith. Except as
## otherwise provided in a valid license issued to you by
## Xilinx, and to the maximum extent permitted by applicable
## law: (1) THESE MATERIALS ARE MADE AVAILABLE "AS IS" AND
## WITH ALL FAULTS, AND XILINX HEREBY DISCLAIMS ALL WARRANTIES
## AND CONDITIONS, EXPRESS, IMPLIED, OR STATUTORY, INCLUDING
## BUT NOT LIMITED TO WARRANTIES OF MERCHANTABILITY, NON-
## INFRINGEMENT, OR FITNESS FOR ANY PARTICULAR PURPOSE; and
## (2) Xilinx shall not be liable (whether in contract or tort,
## including negligence, or under any other theory of
## liability) for any loss or damage of any kind or nature
## related to, arising under or in connection with these
## materials, including for any direct, or any indirect,
## special, incidental, or consequential loss or damage
## (including loss of data, profits, goodwill, or any type of
## loss or damage suffered as a result of any action brought
## by a third party) even if such damage or loss was
## reasonably foreseeable or Xilinx had been advised of the
## possibility of the same.
##
## CRITICAL APPLICATIONS
## Xilinx products are not designed or intended to be fail-
## safe, or for use in any application requiring fail-safe
## performance, such as life-support or safety devices or
## systems, Class III medical devices, nuclear facilities,
## applications related to the deployment of airbags, or any
## other applications that could lead to death, personal
## injury, or severe property or environmental damage
## (individually and collectively, "Critical
## Applications"). Customer assumes the sole risk and
## liability of any use of Xilinx products in Critical
## Applications, subject only to applicable laws and
## regulations governing limitations on product liability.
##
## THIS COPYRIGHT NOTICE AND DISCLAIMER MUST BE RETAINED AS
## PART OF THIS FILE AT ALL TIMES.
##
##-----------------------------------------------------------------------------
## Project    : Series-7 Integrated Block for PCI Express
## File       : xilinx_pcie_7x_ep_x8g2.xdc
## Version    : 2.1
#
###############################################################################
# User Configuration
# Link Width   - x8
# Link Speed   - gen2
# Family       - kintex7
# Part         - xc7k325t
# Package      - fbg900
# Speed grade  - -2
# PCIe Block   - X0Y0
###############################################################################
#
###############################################################################
# User Time Names / User Time Groups / Time Specs
###############################################################################

###############################################################################
# User Physical Constraints
###############################################################################

#set_property BITSTREAM.CONFIG.BPI_1ST_READ_CYCLE 4 [current_design]
#set_property BITSTREAM.CONFIG.BPI_PAGE_SIZE 8 [current_design]
#set_property BITSTREAM.CONFIG.BPI_SYNC_MODE Type1 [current_design]
#set_property BITSTREAM.CONFIG.CONFIGRATE 40 [current_design]
#set_property BITSTREAM.GENERAL.COMPRESS True [current_design]

###############################################################################
# Pinout and Related I/O Constraints
###############################################################################

#
# SYS reset (input) signal.  The sys_reset_n signal should be
# obtained from the PCI Express interface if possible.  For
# slot based form factors, a system reset signal is usually
# present on the connector.  For cable based form factors, a
# system reset signal may not be available.  In this case, the
# system reset signal must be generated locally by some form of
# supervisory circuit.  You may change the IOSTANDARD and LOC
# to suit your requirements and VCCO voltage banking rules.
# Some 7 series devices do not have 3.3 V I/Os available.
# Therefore the appropriate level shift is required to operate
# with these devices that contain only 1.8 V banks.
#


set_property LOC GTXE2_CHANNEL_X0Y7 [get_cells {pcie_support_i/PCIe_IP_i/U0/inst/gt_top_i/pipe_wrapper_i/pipe_lane[0].gt_wrapper_i/gtx_channel.gtxe2_channel_i}]
set_property PACKAGE_PIN M5 [get_ports {pci_exp_rxn[0]}]
set_property PACKAGE_PIN M6 [get_ports {pci_exp_rxp[0]}]
set_property PACKAGE_PIN L3 [get_ports {pci_exp_txn[0]}]
set_property PACKAGE_PIN L4 [get_ports {pci_exp_txp[0]}]
set_property LOC GTXE2_CHANNEL_X0Y6 [get_cells {pcie_support_i/PCIe_IP_i/U0/inst/gt_top_i/pipe_wrapper_i/pipe_lane[1].gt_wrapper_i/gtx_channel.gtxe2_channel_i}]
set_property PACKAGE_PIN P5 [get_ports {pci_exp_rxn[1]}]
set_property PACKAGE_PIN P6 [get_ports {pci_exp_rxp[1]}]
set_property PACKAGE_PIN M1 [get_ports {pci_exp_txn[1]}]
set_property PACKAGE_PIN M2 [get_ports {pci_exp_txp[1]}]
set_property LOC GTXE2_CHANNEL_X0Y5 [get_cells {pcie_support_i/PCIe_IP_i/U0/inst/gt_top_i/pipe_wrapper_i/pipe_lane[2].gt_wrapper_i/gtx_channel.gtxe2_channel_i}]
set_property PACKAGE_PIN R3 [get_ports {pci_exp_rxn[2]}]
set_property PACKAGE_PIN R4 [get_ports {pci_exp_rxp[2]}]
set_property PACKAGE_PIN N3 [get_ports {pci_exp_txn[2]}]
set_property PACKAGE_PIN N4 [get_ports {pci_exp_txp[2]}]
set_property LOC GTXE2_CHANNEL_X0Y4 [get_cells {pcie_support_i/PCIe_IP_i/U0/inst/gt_top_i/pipe_wrapper_i/pipe_lane[3].gt_wrapper_i/gtx_channel.gtxe2_channel_i}]
set_property PACKAGE_PIN T5 [get_ports {pci_exp_rxn[3]}]
set_property PACKAGE_PIN T6 [get_ports {pci_exp_rxp[3]}]
set_property PACKAGE_PIN P1 [get_ports {pci_exp_txn[3]}]
set_property PACKAGE_PIN P2 [get_ports {pci_exp_txp[3]}]
set_property LOC GTXE2_CHANNEL_X0Y3 [get_cells {pcie_support_i/PCIe_IP_i/U0/inst/gt_top_i/pipe_wrapper_i/pipe_lane[4].gt_wrapper_i/gtx_channel.gtxe2_channel_i}]
set_property PACKAGE_PIN V5 [get_ports {pci_exp_rxn[4]}]
set_property PACKAGE_PIN V6 [get_ports {pci_exp_rxp[4]}]
set_property PACKAGE_PIN T1 [get_ports {pci_exp_txn[4]}]
set_property PACKAGE_PIN T2 [get_ports {pci_exp_txp[4]}]
set_property LOC GTXE2_CHANNEL_X0Y2 [get_cells {pcie_support_i/PCIe_IP_i/U0/inst/gt_top_i/pipe_wrapper_i/pipe_lane[5].gt_wrapper_i/gtx_channel.gtxe2_channel_i}]
set_property PACKAGE_PIN W3 [get_ports {pci_exp_rxn[5]}]
set_property PACKAGE_PIN W4 [get_ports {pci_exp_rxp[5]}]
set_property PACKAGE_PIN U3 [get_ports {pci_exp_txn[5]}]
set_property PACKAGE_PIN U4 [get_ports {pci_exp_txp[5]}]
set_property LOC GTXE2_CHANNEL_X0Y1 [get_cells {pcie_support_i/PCIe_IP_i/U0/inst/gt_top_i/pipe_wrapper_i/pipe_lane[6].gt_wrapper_i/gtx_channel.gtxe2_channel_i}]
set_property PACKAGE_PIN Y5 [get_ports {pci_exp_rxn[6]}]
set_property PACKAGE_PIN Y6 [get_ports {pci_exp_rxp[6]}]
set_property PACKAGE_PIN V1 [get_ports {pci_exp_txn[6]}]
set_property PACKAGE_PIN V2 [get_ports {pci_exp_txp[6]}]
set_property LOC GTXE2_CHANNEL_X0Y0 [get_cells {pcie_support_i/PCIe_IP_i/U0/inst/gt_top_i/pipe_wrapper_i/pipe_lane[7].gt_wrapper_i/gtx_channel.gtxe2_channel_i}]
set_property PACKAGE_PIN AA3 [get_ports {pci_exp_rxn[7]}]
set_property PACKAGE_PIN AA4 [get_ports {pci_exp_rxp[7]}]
set_property PACKAGE_PIN Y1 [get_ports {pci_exp_txn[7]}]
set_property PACKAGE_PIN Y2 [get_ports {pci_exp_txp[7]}]

set_property PACKAGE_PIN L8 [get_ports sys_clk_pcie_clk_p]
set_property PACKAGE_PIN L7 [get_ports sys_clk_pcie_clk_n]

set_property IOSTANDARD LVCMOS33 [get_ports sys_rst_n_pcie]
set_property PULLUP true [get_ports sys_rst_n_pcie]
set_property PACKAGE_PIN AA21 [get_ports sys_rst_n_pcie]


###############################################################################
# Physical Constraints
###############################################################################
#
# SYS clock 100 MHz (input) signal. The sys_clk_p and sys_clk_n
# signals are the PCI Express reference clock. Virtex-7 GT
# Transceiver architecture requires the use of a dedicated clock
# resources (FPGA input pins) associated with each GT Transceiver.
# To use these pins an IBUFDS primitive (refclk_ibuf) is
# instantiated in user's design.
# Please refer to the Virtex-7 GT Transceiver User Guide
# (UG) for guidelines regarding clock resource selection.
#

#set_property LOC IBUFDS_GTE2_X0Y3 [get_cells refclk_ibuf]

###############################################################################
# Timing Constraints
###############################################################################

#
# Timing requirements and related constraints.
#

#create_clock -period 10.000 -name sys_clk_pcie_ibuf_o [get_pins top_level_i/util_ds_buf_0/IBUF_OUT]

#set_false_path -to [get_pins {ext_clk.pipe_clock_i/pclk_i1_bufgctrl.pclk_i1/S*}]

#create_generated_clock -name clk_125mhz_mux #                        -source [get_pins ext_clk.pipe_clock_i/pclk_i1_bufgctrl.pclk_i1/I0] #                        -divide_by 1 #                        [get_pins ext_clk.pipe_clock_i/pclk_i1_bufgctrl.pclk_i1/O]

#create_generated_clock -name clk_250mhz_mux #                        -source [get_pins ext_clk.pipe_clock_i/pclk_i1_bufgctrl.pclk_i1/I1] #                        -divide_by 1 -add -master_clock [get_clocks -of [get_pins ext_clk.pipe_clock_i/pclk_i1_bufgctrl.pclk_i1/I1]] #                        [get_pins ext_clk.pipe_clock_i/pclk_i1_bufgctrl.pclk_i1/O]

#set_clock_groups -name pcieclkmux -physically_exclusive -group clk_125mhz_mux -group clk_250mhz_mux
# Timing ignoring the below pins to avoid CDC analysis, but care has been taken in RTL to sync properly to other clock domain.




###############################################################################
# Tandem Configuration Constraints
###############################################################################

set_false_path -from [get_ports sys_rst_n_pcie]

###############################################################################
# End
###############################################################################

create_clock -period 10.000 -name sys_clk_pcie_clk_p -waveform {0.000 5.000} [get_ports sys_clk_pcie_clk_p]

#create_debug_core u_ila_0 ila
#set_property ALL_PROBE_SAME_MU true [get_debug_cores u_ila_0]
#set_property ALL_PROBE_SAME_MU_CNT 4 [get_debug_cores u_ila_0]
#set_property C_ADV_TRIGGER true [get_debug_cores u_ila_0]
#set_property C_DATA_DEPTH 1024 [get_debug_cores u_ila_0]
#set_property C_EN_STRG_QUAL true [get_debug_cores u_ila_0]
#set_property C_INPUT_PIPE_STAGES 0 [get_debug_cores u_ila_0]
#set_property C_TRIGIN_EN false [get_debug_cores u_ila_0]
#set_property C_TRIGOUT_EN false [get_debug_cores u_ila_0]
#set_property port_width 1 [get_debug_ports u_ila_0/clk]
#connect_debug_port u_ila_0/clk [get_nets [list top_level_i/axi_pcie_0/inst/comp_axi_enhanced_pcie/comp_enhanced_core_top_wrap/axi_pcie_enhanced_core_top_i/pcie_7x_v2_0_2_inst/pcie_top_with_gt_top.gt_ges.gt_top_i/pipe_wrapper_i/pipe_clock_int.pipe_clock_i/CLK_RXUSRCLK]]
#set_property PROBE_TYPE DATA_AND_TRIGGER [get_debug_ports u_ila_0/probe0]
#set_property port_width 2 [get_debug_ports u_ila_0/probe0]
#connect_debug_port u_ila_0/probe0 [get_nets [list {top_level_i/smartconnect_0_M00_AXI_ARSIZE[0]} {top_level_i/smartconnect_0_M00_AXI_ARSIZE[1]}]]
#create_debug_port u_ila_0 probe
#set_property PROBE_TYPE DATA_AND_TRIGGER [get_debug_ports u_ila_0/probe1]
#set_property port_width 8 [get_debug_ports u_ila_0/probe1]
#connect_debug_port u_ila_0/probe1 [get_nets [list {top_level_i/smartconnect_0_M00_AXI_AWLEN[0]} {top_level_i/smartconnect_0_M00_AXI_AWLEN[1]} {top_level_i/smartconnect_0_M00_AXI_AWLEN[2]} {top_level_i/smartconnect_0_M00_AXI_AWLEN[3]} {top_level_i/smartconnect_0_M00_AXI_AWLEN[4]} {top_level_i/smartconnect_0_M00_AXI_AWLEN[5]} {top_level_i/smartconnect_0_M00_AXI_AWLEN[6]} {top_level_i/smartconnect_0_M00_AXI_AWLEN[7]}]]
#create_debug_port u_ila_0 probe
#set_property PROBE_TYPE DATA_AND_TRIGGER [get_debug_ports u_ila_0/probe2]
#set_property port_width 4 [get_debug_ports u_ila_0/probe2]
#connect_debug_port u_ila_0/probe2 [get_nets [list {top_level_i/smartconnect_0_M00_AXI_ARCACHE[0]} {top_level_i/smartconnect_0_M00_AXI_ARCACHE[1]} {top_level_i/smartconnect_0_M00_AXI_ARCACHE[2]} {top_level_i/smartconnect_0_M00_AXI_ARCACHE[3]}]]
#create_debug_port u_ila_0 probe
#set_property PROBE_TYPE DATA_AND_TRIGGER [get_debug_ports u_ila_0/probe3]
#set_property port_width 3 [get_debug_ports u_ila_0/probe3]
#connect_debug_port u_ila_0/probe3 [get_nets [list {top_level_i/smartconnect_0_M00_AXI_AWPROT[0]} {top_level_i/smartconnect_0_M00_AXI_AWPROT[1]} {top_level_i/smartconnect_0_M00_AXI_AWPROT[2]}]]
#create_debug_port u_ila_0 probe
#set_property PROBE_TYPE DATA_AND_TRIGGER [get_debug_ports u_ila_0/probe4]
#set_property port_width 22 [get_debug_ports u_ila_0/probe4]
#connect_debug_port u_ila_0/probe4 [get_nets [list {top_level_i/smartconnect_0_M00_AXI_ARADDR[0]} {top_level_i/smartconnect_0_M00_AXI_ARADDR[1]} {top_level_i/smartconnect_0_M00_AXI_ARADDR[2]} {top_level_i/smartconnect_0_M00_AXI_ARADDR[3]} {top_level_i/smartconnect_0_M00_AXI_ARADDR[4]} {top_level_i/smartconnect_0_M00_AXI_ARADDR[5]} {top_level_i/smartconnect_0_M00_AXI_ARADDR[6]} {top_level_i/smartconnect_0_M00_AXI_ARADDR[7]} {top_level_i/smartconnect_0_M00_AXI_ARADDR[8]} {top_level_i/smartconnect_0_M00_AXI_ARADDR[9]} {top_level_i/smartconnect_0_M00_AXI_ARADDR[10]} {top_level_i/smartconnect_0_M00_AXI_ARADDR[11]} {top_level_i/smartconnect_0_M00_AXI_ARADDR[12]} {top_level_i/smartconnect_0_M00_AXI_ARADDR[13]} {top_level_i/smartconnect_0_M00_AXI_ARADDR[14]} {top_level_i/smartconnect_0_M00_AXI_ARADDR[15]} {top_level_i/smartconnect_0_M00_AXI_ARADDR[16]} {top_level_i/smartconnect_0_M00_AXI_ARADDR[17]} {top_level_i/smartconnect_0_M00_AXI_ARADDR[18]} {top_level_i/smartconnect_0_M00_AXI_ARADDR[19]} {top_level_i/smartconnect_0_M00_AXI_ARADDR[20]} {top_level_i/smartconnect_0_M00_AXI_ARADDR[21]}]]
#create_debug_port u_ila_0 probe
#set_property PROBE_TYPE DATA_AND_TRIGGER [get_debug_ports u_ila_0/probe5]
#set_property port_width 4 [get_debug_ports u_ila_0/probe5]
#connect_debug_port u_ila_0/probe5 [get_nets [list {top_level_i/smartconnect_0_M00_AXI_AWCACHE[0]} {top_level_i/smartconnect_0_M00_AXI_AWCACHE[1]} {top_level_i/smartconnect_0_M00_AXI_AWCACHE[2]} {top_level_i/smartconnect_0_M00_AXI_AWCACHE[3]}]]
#create_debug_port u_ila_0 probe
#set_property PROBE_TYPE DATA_AND_TRIGGER [get_debug_ports u_ila_0/probe6]
#set_property port_width 22 [get_debug_ports u_ila_0/probe6]
#connect_debug_port u_ila_0/probe6 [get_nets [list {top_level_i/smartconnect_0_M00_AXI_AWADDR[0]} {top_level_i/smartconnect_0_M00_AXI_AWADDR[1]} {top_level_i/smartconnect_0_M00_AXI_AWADDR[2]} {top_level_i/smartconnect_0_M00_AXI_AWADDR[3]} {top_level_i/smartconnect_0_M00_AXI_AWADDR[4]} {top_level_i/smartconnect_0_M00_AXI_AWADDR[5]} {top_level_i/smartconnect_0_M00_AXI_AWADDR[6]} {top_level_i/smartconnect_0_M00_AXI_AWADDR[7]} {top_level_i/smartconnect_0_M00_AXI_AWADDR[8]} {top_level_i/smartconnect_0_M00_AXI_AWADDR[9]} {top_level_i/smartconnect_0_M00_AXI_AWADDR[10]} {top_level_i/smartconnect_0_M00_AXI_AWADDR[11]} {top_level_i/smartconnect_0_M00_AXI_AWADDR[12]} {top_level_i/smartconnect_0_M00_AXI_AWADDR[13]} {top_level_i/smartconnect_0_M00_AXI_AWADDR[14]} {top_level_i/smartconnect_0_M00_AXI_AWADDR[15]} {top_level_i/smartconnect_0_M00_AXI_AWADDR[16]} {top_level_i/smartconnect_0_M00_AXI_AWADDR[17]} {top_level_i/smartconnect_0_M00_AXI_AWADDR[18]} {top_level_i/smartconnect_0_M00_AXI_AWADDR[19]} {top_level_i/smartconnect_0_M00_AXI_AWADDR[20]} {top_level_i/smartconnect_0_M00_AXI_AWADDR[21]}]]
#create_debug_port u_ila_0 probe
#set_property PROBE_TYPE DATA_AND_TRIGGER [get_debug_ports u_ila_0/probe7]
#set_property port_width 3 [get_debug_ports u_ila_0/probe7]
#connect_debug_port u_ila_0/probe7 [get_nets [list {top_level_i/smartconnect_0_M00_AXI_ARPROT[0]} {top_level_i/smartconnect_0_M00_AXI_ARPROT[1]} {top_level_i/smartconnect_0_M00_AXI_ARPROT[2]}]]
#create_debug_port u_ila_0 probe
#set_property PROBE_TYPE DATA_AND_TRIGGER [get_debug_ports u_ila_0/probe8]
#set_property port_width 4 [get_debug_ports u_ila_0/probe8]
#connect_debug_port u_ila_0/probe8 [get_nets [list {top_level_i/smartconnect_0_M00_AXI_AWQOS[0]} {top_level_i/smartconnect_0_M00_AXI_AWQOS[1]} {top_level_i/smartconnect_0_M00_AXI_AWQOS[2]} {top_level_i/smartconnect_0_M00_AXI_AWQOS[3]}]]
#create_debug_port u_ila_0 probe
#set_property PROBE_TYPE DATA_AND_TRIGGER [get_debug_ports u_ila_0/probe9]
#set_property port_width 8 [get_debug_ports u_ila_0/probe9]
#connect_debug_port u_ila_0/probe9 [get_nets [list {top_level_i/smartconnect_0_M00_AXI_ARLEN[0]} {top_level_i/smartconnect_0_M00_AXI_ARLEN[1]} {top_level_i/smartconnect_0_M00_AXI_ARLEN[2]} {top_level_i/smartconnect_0_M00_AXI_ARLEN[3]} {top_level_i/smartconnect_0_M00_AXI_ARLEN[4]} {top_level_i/smartconnect_0_M00_AXI_ARLEN[5]} {top_level_i/smartconnect_0_M00_AXI_ARLEN[6]} {top_level_i/smartconnect_0_M00_AXI_ARLEN[7]}]]
#create_debug_port u_ila_0 probe
#set_property PROBE_TYPE DATA_AND_TRIGGER [get_debug_ports u_ila_0/probe10]
#set_property port_width 2 [get_debug_ports u_ila_0/probe10]
#connect_debug_port u_ila_0/probe10 [get_nets [list {top_level_i/smartconnect_0_M00_AXI_AWSIZE[0]} {top_level_i/smartconnect_0_M00_AXI_AWSIZE[1]}]]
#create_debug_port u_ila_0 probe
#set_property PROBE_TYPE DATA_AND_TRIGGER [get_debug_ports u_ila_0/probe11]
#set_property port_width 4 [get_debug_ports u_ila_0/probe11]
#connect_debug_port u_ila_0/probe11 [get_nets [list {top_level_i/smartconnect_0_M00_AXI_ARQOS[0]} {top_level_i/smartconnect_0_M00_AXI_ARQOS[1]} {top_level_i/smartconnect_0_M00_AXI_ARQOS[2]} {top_level_i/smartconnect_0_M00_AXI_ARQOS[3]}]]
#create_debug_port u_ila_0 probe
#set_property PROBE_TYPE DATA_AND_TRIGGER [get_debug_ports u_ila_0/probe12]
#set_property port_width 4 [get_debug_ports u_ila_0/probe12]
#connect_debug_port u_ila_0/probe12 [get_nets [list {top_level_i/smartconnect_0_M00_AXI_WSTRB[0]} {top_level_i/smartconnect_0_M00_AXI_WSTRB[1]} {top_level_i/smartconnect_0_M00_AXI_WSTRB[2]} {top_level_i/smartconnect_0_M00_AXI_WSTRB[3]}]]
#create_debug_port u_ila_0 probe
#set_property PROBE_TYPE DATA_AND_TRIGGER [get_debug_ports u_ila_0/probe13]
#set_property port_width 32 [get_debug_ports u_ila_0/probe13]
#connect_debug_port u_ila_0/probe13 [get_nets [list {top_level_i/smartconnect_0_M00_AXI_WDATA[0]} {top_level_i/smartconnect_0_M00_AXI_WDATA[1]} {top_level_i/smartconnect_0_M00_AXI_WDATA[2]} {top_level_i/smartconnect_0_M00_AXI_WDATA[3]} {top_level_i/smartconnect_0_M00_AXI_WDATA[4]} {top_level_i/smartconnect_0_M00_AXI_WDATA[5]} {top_level_i/smartconnect_0_M00_AXI_WDATA[6]} {top_level_i/smartconnect_0_M00_AXI_WDATA[7]} {top_level_i/smartconnect_0_M00_AXI_WDATA[8]} {top_level_i/smartconnect_0_M00_AXI_WDATA[9]} {top_level_i/smartconnect_0_M00_AXI_WDATA[10]} {top_level_i/smartconnect_0_M00_AXI_WDATA[11]} {top_level_i/smartconnect_0_M00_AXI_WDATA[12]} {top_level_i/smartconnect_0_M00_AXI_WDATA[13]} {top_level_i/smartconnect_0_M00_AXI_WDATA[14]} {top_level_i/smartconnect_0_M00_AXI_WDATA[15]} {top_level_i/smartconnect_0_M00_AXI_WDATA[16]} {top_level_i/smartconnect_0_M00_AXI_WDATA[17]} {top_level_i/smartconnect_0_M00_AXI_WDATA[18]} {top_level_i/smartconnect_0_M00_AXI_WDATA[19]} {top_level_i/smartconnect_0_M00_AXI_WDATA[20]} {top_level_i/smartconnect_0_M00_AXI_WDATA[21]} {top_level_i/smartconnect_0_M00_AXI_WDATA[22]} {top_level_i/smartconnect_0_M00_AXI_WDATA[23]} {top_level_i/smartconnect_0_M00_AXI_WDATA[24]} {top_level_i/smartconnect_0_M00_AXI_WDATA[25]} {top_level_i/smartconnect_0_M00_AXI_WDATA[26]} {top_level_i/smartconnect_0_M00_AXI_WDATA[27]} {top_level_i/smartconnect_0_M00_AXI_WDATA[28]} {top_level_i/smartconnect_0_M00_AXI_WDATA[29]} {top_level_i/smartconnect_0_M00_AXI_WDATA[30]} {top_level_i/smartconnect_0_M00_AXI_WDATA[31]}]]
#create_debug_port u_ila_0 probe
#set_property PROBE_TYPE DATA_AND_TRIGGER [get_debug_ports u_ila_0/probe14]
#set_property port_width 32 [get_debug_ports u_ila_0/probe14]
#connect_debug_port u_ila_0/probe14 [get_nets [list {top_level_i/smartconnect_0_M00_AXI_RDATA[0]} {top_level_i/smartconnect_0_M00_AXI_RDATA[1]} {top_level_i/smartconnect_0_M00_AXI_RDATA[2]} {top_level_i/smartconnect_0_M00_AXI_RDATA[3]} {top_level_i/smartconnect_0_M00_AXI_RDATA[4]} {top_level_i/smartconnect_0_M00_AXI_RDATA[5]} {top_level_i/smartconnect_0_M00_AXI_RDATA[6]} {top_level_i/smartconnect_0_M00_AXI_RDATA[7]} {top_level_i/smartconnect_0_M00_AXI_RDATA[8]} {top_level_i/smartconnect_0_M00_AXI_RDATA[9]} {top_level_i/smartconnect_0_M00_AXI_RDATA[10]} {top_level_i/smartconnect_0_M00_AXI_RDATA[11]} {top_level_i/smartconnect_0_M00_AXI_RDATA[12]} {top_level_i/smartconnect_0_M00_AXI_RDATA[13]} {top_level_i/smartconnect_0_M00_AXI_RDATA[14]} {top_level_i/smartconnect_0_M00_AXI_RDATA[15]} {top_level_i/smartconnect_0_M00_AXI_RDATA[16]} {top_level_i/smartconnect_0_M00_AXI_RDATA[17]} {top_level_i/smartconnect_0_M00_AXI_RDATA[18]} {top_level_i/smartconnect_0_M00_AXI_RDATA[19]} {top_level_i/smartconnect_0_M00_AXI_RDATA[20]} {top_level_i/smartconnect_0_M00_AXI_RDATA[21]} {top_level_i/smartconnect_0_M00_AXI_RDATA[22]} {top_level_i/smartconnect_0_M00_AXI_RDATA[23]} {top_level_i/smartconnect_0_M00_AXI_RDATA[24]} {top_level_i/smartconnect_0_M00_AXI_RDATA[25]} {top_level_i/smartconnect_0_M00_AXI_RDATA[26]} {top_level_i/smartconnect_0_M00_AXI_RDATA[27]} {top_level_i/smartconnect_0_M00_AXI_RDATA[28]} {top_level_i/smartconnect_0_M00_AXI_RDATA[29]} {top_level_i/smartconnect_0_M00_AXI_RDATA[30]} {top_level_i/smartconnect_0_M00_AXI_RDATA[31]}]]
#create_debug_port u_ila_0 probe
#set_property PROBE_TYPE DATA_AND_TRIGGER [get_debug_ports u_ila_0/probe15]
#set_property port_width 1 [get_debug_ports u_ila_0/probe15]
#connect_debug_port u_ila_0/probe15 [get_nets [list top_level_i/smartconnect_0_M00_AXI_ARREADY]]
#create_debug_port u_ila_0 probe
#set_property PROBE_TYPE DATA_AND_TRIGGER [get_debug_ports u_ila_0/probe16]
#set_property port_width 1 [get_debug_ports u_ila_0/probe16]
#connect_debug_port u_ila_0/probe16 [get_nets [list top_level_i/smartconnect_0_M00_AXI_ARVALID]]
#create_debug_port u_ila_0 probe
#set_property PROBE_TYPE DATA_AND_TRIGGER [get_debug_ports u_ila_0/probe17]
#set_property port_width 1 [get_debug_ports u_ila_0/probe17]
#connect_debug_port u_ila_0/probe17 [get_nets [list top_level_i/smartconnect_0_M00_AXI_AWREADY]]
#create_debug_port u_ila_0 probe
#set_property PROBE_TYPE DATA_AND_TRIGGER [get_debug_ports u_ila_0/probe18]
#set_property port_width 1 [get_debug_ports u_ila_0/probe18]
#connect_debug_port u_ila_0/probe18 [get_nets [list top_level_i/smartconnect_0_M00_AXI_AWVALID]]
#create_debug_port u_ila_0 probe
#set_property PROBE_TYPE DATA_AND_TRIGGER [get_debug_ports u_ila_0/probe19]
#set_property port_width 1 [get_debug_ports u_ila_0/probe19]
#connect_debug_port u_ila_0/probe19 [get_nets [list top_level_i/smartconnect_0_M00_AXI_BREADY]]
#create_debug_port u_ila_0 probe
#set_property PROBE_TYPE DATA_AND_TRIGGER [get_debug_ports u_ila_0/probe20]
#set_property port_width 1 [get_debug_ports u_ila_0/probe20]
#connect_debug_port u_ila_0/probe20 [get_nets [list top_level_i/smartconnect_0_M00_AXI_BVALID]]
#create_debug_port u_ila_0 probe
#set_property PROBE_TYPE DATA_AND_TRIGGER [get_debug_ports u_ila_0/probe21]
#set_property port_width 1 [get_debug_ports u_ila_0/probe21]
#connect_debug_port u_ila_0/probe21 [get_nets [list top_level_i/smartconnect_0_M00_AXI_RLAST]]
#create_debug_port u_ila_0 probe
#set_property PROBE_TYPE DATA_AND_TRIGGER [get_debug_ports u_ila_0/probe22]
#set_property port_width 1 [get_debug_ports u_ila_0/probe22]
#connect_debug_port u_ila_0/probe22 [get_nets [list top_level_i/smartconnect_0_M00_AXI_RREADY]]
#create_debug_port u_ila_0 probe
#set_property PROBE_TYPE DATA_AND_TRIGGER [get_debug_ports u_ila_0/probe23]
#set_property port_width 1 [get_debug_ports u_ila_0/probe23]
#connect_debug_port u_ila_0/probe23 [get_nets [list top_level_i/smartconnect_0_M00_AXI_RVALID]]
#create_debug_port u_ila_0 probe
#set_property PROBE_TYPE DATA_AND_TRIGGER [get_debug_ports u_ila_0/probe24]
#set_property port_width 1 [get_debug_ports u_ila_0/probe24]
#connect_debug_port u_ila_0/probe24 [get_nets [list top_level_i/smartconnect_0_M00_AXI_WLAST]]
#create_debug_port u_ila_0 probe
#set_property PROBE_TYPE DATA_AND_TRIGGER [get_debug_ports u_ila_0/probe25]
#set_property port_width 1 [get_debug_ports u_ila_0/probe25]
#connect_debug_port u_ila_0/probe25 [get_nets [list top_level_i/smartconnect_0_M00_AXI_WREADY]]
#create_debug_port u_ila_0 probe
#set_property PROBE_TYPE DATA_AND_TRIGGER [get_debug_ports u_ila_0/probe26]
#set_property port_width 1 [get_debug_ports u_ila_0/probe26]
#connect_debug_port u_ila_0/probe26 [get_nets [list top_level_i/smartconnect_0_M00_AXI_WVALID]]
#set_property C_CLK_INPUT_FREQ_HZ 300000000 [get_debug_cores dbg_hub]
#set_property C_ENABLE_CLK_DIVIDER false [get_debug_cores dbg_hub]
#set_property C_USER_SCAN_CHAIN 1 [get_debug_cores dbg_hub]
#connect_debug_port dbg_hub/clk [get_nets u_ila_0_CLK_RXUSRCLK]


