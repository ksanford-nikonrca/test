
Q
Command: %s
53*	vivadotcl2 
route_design2default:defaultZ4-113h px� 
�
@Attempting to get a license for feature '%s' and/or device '%s'
308*common2"
Implementation2default:default2
xc7k325t2default:defaultZ17-347h px� 
�
0Got license for feature '%s' and/or device '%s'
310*common2"
Implementation2default:default2
xc7k325t2default:defaultZ17-349h px� 
�
�The version limit for your license is '%s' and has expired for new software. A version limit expiration means that, although you may be able to continue to use the current version of tools or IP with this license, you will not be eligible for any updates or new releases.
719*common2
2020.072default:defaultZ17-1540h px� 
p
,Running DRC as a precondition to command %s
22*	vivadotcl2 
route_design2default:defaultZ4-22h px� 
P
Running DRC with %s threads
24*drc2
22default:defaultZ23-27h px� 
V
DRC finished with %s
79*	vivadotcl2
0 Errors2default:defaultZ4-198h px� 
e
BPlease refer to the DRC report (report_drc) for more information.
80*	vivadotclZ4-199h px� 
V

Starting %s Task
103*constraints2
Routing2default:defaultZ18-103h px� 
}
BMultithreading enabled for route_design using a maximum of %s CPUs17*	routeflow2
22default:defaultZ35-254h px� 
p

Phase %s%s
101*constraints2
1 2default:default2#
Build RT Design2default:defaultZ18-101h px� 
C
.Phase 1 Build RT Design | Checksum: 1332638cf
*commonh px� 
�

%s
*constraints2q
]Time (s): cpu = 00:01:00 ; elapsed = 00:00:34 . Memory (MB): peak = 2433.027 ; gain = 133.8052default:defaulth px� 
v

Phase %s%s
101*constraints2
2 2default:default2)
Router Initialization2default:defaultZ18-101h px� 
o

Phase %s%s
101*constraints2
2.1 2default:default2 
Create Timer2default:defaultZ18-101h px� 
B
-Phase 2.1 Create Timer | Checksum: 1332638cf
*commonh px� 
�

%s
*constraints2q
]Time (s): cpu = 00:01:01 ; elapsed = 00:00:36 . Memory (MB): peak = 2449.863 ; gain = 150.6412default:defaulth px� 
{

Phase %s%s
101*constraints2
2.2 2default:default2,
Fix Topology Constraints2default:defaultZ18-101h px� 
N
9Phase 2.2 Fix Topology Constraints | Checksum: 1332638cf
*commonh px� 
�

%s
*constraints2q
]Time (s): cpu = 00:01:02 ; elapsed = 00:00:36 . Memory (MB): peak = 2463.883 ; gain = 164.6602default:defaulth px� 
t

Phase %s%s
101*constraints2
2.3 2default:default2%
Pre Route Cleanup2default:defaultZ18-101h px� 
G
2Phase 2.3 Pre Route Cleanup | Checksum: 1332638cf
*commonh px� 
�

%s
*constraints2q
]Time (s): cpu = 00:01:02 ; elapsed = 00:00:37 . Memory (MB): peak = 2463.883 ; gain = 164.6602default:defaulth px� 
p

Phase %s%s
101*constraints2
2.4 2default:default2!
Update Timing2default:defaultZ18-101h px� 
B
-Phase 2.4 Update Timing | Checksum: f32c6596
*commonh px� 
�

%s
*constraints2q
]Time (s): cpu = 00:01:33 ; elapsed = 00:00:58 . Memory (MB): peak = 2570.836 ; gain = 271.6132default:defaulth px� 
�
Intermediate Timing Summary %s164*route2L
8| WNS=-0.256 | TNS=-0.256 | WHS=-0.726 | THS=-1395.968|
2default:defaultZ35-416h px� 
I
4Phase 2 Router Initialization | Checksum: 19133c87c
*commonh px� 
�

%s
*constraints2q
]Time (s): cpu = 00:01:44 ; elapsed = 00:01:04 . Memory (MB): peak = 2570.836 ; gain = 271.6132default:defaulth px� 
p

Phase %s%s
101*constraints2
3 2default:default2#
Initial Routing2default:defaultZ18-101h px� 
C
.Phase 3 Initial Routing | Checksum: 144572274
*commonh px� 
�

%s
*constraints2q
]Time (s): cpu = 00:02:16 ; elapsed = 00:01:21 . Memory (MB): peak = 2573.871 ; gain = 274.6482default:defaulth px� 
�
>Design has %s pins with tight setup and hold constraints.

%s
244*route2
152default:default2�
�The top 5 pins with tight setup and hold constraints:

+--------------------------+--------------------------+----------------------------------------------------------------------------------------------------------+
|       Launch Clock       |      Capture Clock       |                                                 Pin                                                      |
+--------------------------+--------------------------+----------------------------------------------------------------------------------------------------------+
|               clk_125mhz |               clk_125mhz |pcie_support_i/PCIe_IP_i/U0/inst/gt_top_i/gt_rx_valid_filter[0].GT_RX_VALID_FILTER_7x_inst/gt_rxvalid_q_reg/D|
|               clk_125mhz |               clk_125mhz |pcie_support_i/PCIe_IP_i/U0/inst/gt_top_i/gt_rx_valid_filter[1].GT_RX_VALID_FILTER_7x_inst/gt_rxvalid_q_reg/D|
|               clk_125mhz |               clk_125mhz |pcie_support_i/PCIe_IP_i/U0/inst/gt_top_i/gt_rx_valid_filter[2].GT_RX_VALID_FILTER_7x_inst/gt_rxvalid_q_reg/D|
|               clk_125mhz |               clk_125mhz |pcie_support_i/PCIe_IP_i/U0/inst/gt_top_i/gt_rx_valid_filter[6].GT_RX_VALID_FILTER_7x_inst/gt_rxvalid_q_reg/D|
|               clk_125mhz |               clk_125mhz |pcie_support_i/PCIe_IP_i/U0/inst/gt_top_i/gt_rx_valid_filter[0].GT_RX_VALID_FILTER_7x_inst/gt_rx_status_q_reg[2]/D|
+--------------------------+--------------------------+----------------------------------------------------------------------------------------------------------+

File with complete list of pins: tight_setup_hold_pins.txt
2default:defaultZ35-580h px� 
s

Phase %s%s
101*constraints2
4 2default:default2&
Rip-up And Reroute2default:defaultZ18-101h px� 
u

Phase %s%s
101*constraints2
4.1 2default:default2&
Global Iteration 02default:defaultZ18-101h px� 
�
Intermediate Timing Summary %s164*route2J
6| WNS=-0.276 | TNS=-0.276 | WHS=N/A    | THS=N/A    |
2default:defaultZ35-416h px� 
H
3Phase 4.1 Global Iteration 0 | Checksum: 1b4dc6fba
*commonh px� 
�

%s
*constraints2q
]Time (s): cpu = 00:03:13 ; elapsed = 00:01:56 . Memory (MB): peak = 2579.785 ; gain = 280.5622default:defaulth px� 
F
1Phase 4 Rip-up And Reroute | Checksum: 1b4dc6fba
*commonh px� 
�

%s
*constraints2q
]Time (s): cpu = 00:03:13 ; elapsed = 00:01:56 . Memory (MB): peak = 2579.785 ; gain = 280.5622default:defaulth px� 
|

Phase %s%s
101*constraints2
5 2default:default2/
Delay and Skew Optimization2default:defaultZ18-101h px� 
p

Phase %s%s
101*constraints2
5.1 2default:default2!
Delay CleanUp2default:defaultZ18-101h px� 
r

Phase %s%s
101*constraints2
5.1.1 2default:default2!
Update Timing2default:defaultZ18-101h px� 
E
0Phase 5.1.1 Update Timing | Checksum: 1dee0de2b
*commonh px� 
�

%s
*constraints2q
]Time (s): cpu = 00:03:16 ; elapsed = 00:01:58 . Memory (MB): peak = 2579.785 ; gain = 280.5622default:defaulth px� 
�
Intermediate Timing Summary %s164*route2J
6| WNS=-0.276 | TNS=-0.276 | WHS=N/A    | THS=N/A    |
2default:defaultZ35-416h px� 
C
.Phase 5.1 Delay CleanUp | Checksum: 1dee0de2b
*commonh px� 
�

%s
*constraints2q
]Time (s): cpu = 00:03:17 ; elapsed = 00:01:59 . Memory (MB): peak = 2579.785 ; gain = 280.5622default:defaulth px� 
z

Phase %s%s
101*constraints2
5.2 2default:default2+
Clock Skew Optimization2default:defaultZ18-101h px� 
M
8Phase 5.2 Clock Skew Optimization | Checksum: 1dee0de2b
*commonh px� 
�

%s
*constraints2q
]Time (s): cpu = 00:03:17 ; elapsed = 00:01:59 . Memory (MB): peak = 2579.785 ; gain = 280.5622default:defaulth px� 
O
:Phase 5 Delay and Skew Optimization | Checksum: 1dee0de2b
*commonh px� 
�

%s
*constraints2q
]Time (s): cpu = 00:03:17 ; elapsed = 00:01:59 . Memory (MB): peak = 2579.785 ; gain = 280.5622default:defaulth px� 
n

Phase %s%s
101*constraints2
6 2default:default2!
Post Hold Fix2default:defaultZ18-101h px� 
p

Phase %s%s
101*constraints2
6.1 2default:default2!
Hold Fix Iter2default:defaultZ18-101h px� 
r

Phase %s%s
101*constraints2
6.1.1 2default:default2!
Update Timing2default:defaultZ18-101h px� 
E
0Phase 6.1.1 Update Timing | Checksum: 1e9eebfde
*commonh px� 
�

%s
*constraints2q
]Time (s): cpu = 00:03:21 ; elapsed = 00:02:02 . Memory (MB): peak = 2579.785 ; gain = 280.5622default:defaulth px� 
�
Intermediate Timing Summary %s164*route2J
6| WNS=-0.276 | TNS=-0.276 | WHS=0.021  | THS=0.000  |
2default:defaultZ35-416h px� 
C
.Phase 6.1 Hold Fix Iter | Checksum: 1df11f574
*commonh px� 
�

%s
*constraints2q
]Time (s): cpu = 00:03:21 ; elapsed = 00:02:02 . Memory (MB): peak = 2579.785 ; gain = 280.5622default:defaulth px� 
A
,Phase 6 Post Hold Fix | Checksum: 1df11f574
*commonh px� 
�

%s
*constraints2q
]Time (s): cpu = 00:03:22 ; elapsed = 00:02:02 . Memory (MB): peak = 2579.785 ; gain = 280.5622default:defaulth px� 
o

Phase %s%s
101*constraints2
7 2default:default2"
Route finalize2default:defaultZ18-101h px� 
B
-Phase 7 Route finalize | Checksum: 1a2ab48ad
*commonh px� 
�

%s
*constraints2q
]Time (s): cpu = 00:03:22 ; elapsed = 00:02:03 . Memory (MB): peak = 2579.785 ; gain = 280.5622default:defaulth px� 
v

Phase %s%s
101*constraints2
8 2default:default2)
Verifying routed nets2default:defaultZ18-101h px� 
I
4Phase 8 Verifying routed nets | Checksum: 1a2ab48ad
*commonh px� 
�

%s
*constraints2q
]Time (s): cpu = 00:03:23 ; elapsed = 00:02:03 . Memory (MB): peak = 2579.785 ; gain = 280.5622default:defaulth px� 
r

Phase %s%s
101*constraints2
9 2default:default2%
Depositing Routes2default:defaultZ18-101h px� 
�
,Router swapped GT pin %s to physical pin %s
200*route2�
xpcie_support_i/PCIe_IP_i/U0/inst/gt_top_i/pipe_wrapper_i/pipe_lane[4].gt_wrapper_i/gtx_channel.gtxe2_channel_i/GTREFCLK0xpcie_support_i/PCIe_IP_i/U0/inst/gt_top_i/pipe_wrapper_i/pipe_lane[4].gt_wrapper_i/gtx_channel.gtxe2_channel_i/GTREFCLK02default:default2Z
!GTXE2_CHANNEL_X0Y3/GTSOUTHREFCLK0!GTXE2_CHANNEL_X0Y3/GTSOUTHREFCLK02default:default8Z35-467h px� 
�
,Router swapped GT pin %s to physical pin %s
200*route2�
�pcie_support_i/PCIe_IP_i/U0/inst/gt_top_i/pipe_wrapper_i/pipe_lane[4].pipe_quad.gt_common_enabled.gt_common_int.gt_common_i/qpll_wrapper_i/gtx_common.gtxe2_common_i/GTREFCLK0�pcie_support_i/PCIe_IP_i/U0/inst/gt_top_i/pipe_wrapper_i/pipe_lane[4].pipe_quad.gt_common_enabled.gt_common_int.gt_common_i/qpll_wrapper_i/gtx_common.gtxe2_common_i/GTREFCLK02default:default2X
 GTXE2_COMMON_X0Y0/GTSOUTHREFCLK0 GTXE2_COMMON_X0Y0/GTSOUTHREFCLK02default:default8Z35-467h px� 
�
,Router swapped GT pin %s to physical pin %s
200*route2�
xpcie_support_i/PCIe_IP_i/U0/inst/gt_top_i/pipe_wrapper_i/pipe_lane[5].gt_wrapper_i/gtx_channel.gtxe2_channel_i/GTREFCLK0xpcie_support_i/PCIe_IP_i/U0/inst/gt_top_i/pipe_wrapper_i/pipe_lane[5].gt_wrapper_i/gtx_channel.gtxe2_channel_i/GTREFCLK02default:default2Z
!GTXE2_CHANNEL_X0Y2/GTSOUTHREFCLK0!GTXE2_CHANNEL_X0Y2/GTSOUTHREFCLK02default:default8Z35-467h px� 
�
,Router swapped GT pin %s to physical pin %s
200*route2�
xpcie_support_i/PCIe_IP_i/U0/inst/gt_top_i/pipe_wrapper_i/pipe_lane[6].gt_wrapper_i/gtx_channel.gtxe2_channel_i/GTREFCLK0xpcie_support_i/PCIe_IP_i/U0/inst/gt_top_i/pipe_wrapper_i/pipe_lane[6].gt_wrapper_i/gtx_channel.gtxe2_channel_i/GTREFCLK02default:default2Z
!GTXE2_CHANNEL_X0Y1/GTSOUTHREFCLK0!GTXE2_CHANNEL_X0Y1/GTSOUTHREFCLK02default:default8Z35-467h px� 
�
,Router swapped GT pin %s to physical pin %s
200*route2�
xpcie_support_i/PCIe_IP_i/U0/inst/gt_top_i/pipe_wrapper_i/pipe_lane[7].gt_wrapper_i/gtx_channel.gtxe2_channel_i/GTREFCLK0xpcie_support_i/PCIe_IP_i/U0/inst/gt_top_i/pipe_wrapper_i/pipe_lane[7].gt_wrapper_i/gtx_channel.gtxe2_channel_i/GTREFCLK02default:default2Z
!GTXE2_CHANNEL_X0Y0/GTSOUTHREFCLK0!GTXE2_CHANNEL_X0Y0/GTSOUTHREFCLK02default:default8Z35-467h px� 
E
0Phase 9 Depositing Routes | Checksum: 119491f42
*commonh px� 
�

%s
*constraints2q
]Time (s): cpu = 00:03:30 ; elapsed = 00:02:12 . Memory (MB): peak = 2579.785 ; gain = 280.5622default:defaulth px� 
t

Phase %s%s
101*constraints2
10 2default:default2&
Post Router Timing2default:defaultZ18-101h px� 
�
Estimated Timing Summary %s
57*route2J
6| WNS=-0.276 | TNS=-0.276 | WHS=0.021  | THS=0.000  |
2default:defaultZ35-57h px� 
B
!Router estimated timing not met.
128*routeZ35-328h px� 
G
2Phase 10 Post Router Timing | Checksum: 119491f42
*commonh px� 
�

%s
*constraints2q
]Time (s): cpu = 00:03:31 ; elapsed = 00:02:12 . Memory (MB): peak = 2579.785 ; gain = 280.5622default:defaulth px� 
@
Router Completed Successfully
2*	routeflowZ35-16h px� 
�

%s
*constraints2q
]Time (s): cpu = 00:03:31 ; elapsed = 00:02:12 . Memory (MB): peak = 2579.785 ; gain = 280.5622default:defaulth px� 
Z
Releasing license: %s
83*common2"
Implementation2default:defaultZ17-83h px� 
�
G%s Infos, %s Warnings, %s Critical Warnings and %s Errors encountered.
28*	vivadotcl2
952default:default2
1822default:default2
02default:default2
02default:defaultZ4-41h px� 
^
%s completed successfully
29*	vivadotcl2 
route_design2default:defaultZ4-42h px� 
�
I%sTime (s): cpu = %s ; elapsed = %s . Memory (MB): peak = %s ; gain = %s
268*common2"
route_design: 2default:default2
00:03:402default:default2
00:02:172default:default2
2579.7852default:default2
280.5622default:defaultZ17-268h px� 
�
I%sTime (s): cpu = %s ; elapsed = %s . Memory (MB): peak = %s ; gain = %s
268*common2.
Netlist sorting complete. 2default:default2
00:00:002default:default2 
00:00:00.0242default:default2
2579.7852default:default2
0.0002default:defaultZ17-268h px� 
H
&Writing timing data to binary archive.266*timingZ38-480h px� 
D
Writing placer database...
1603*designutilsZ20-1893h px� 
=
Writing XDEF routing.
211*designutilsZ20-211h px� 
J
#Writing XDEF routing logical nets.
209*designutilsZ20-209h px� 
J
#Writing XDEF routing special nets.
210*designutilsZ20-210h px� 
�
I%sTime (s): cpu = %s ; elapsed = %s . Memory (MB): peak = %s ; gain = %s
268*common2)
Write XDEF Complete: 2default:default2
00:00:222default:default2
00:00:102default:default2
2579.7852default:default2
0.0002default:defaultZ17-268h px� 
�
 The %s '%s' has been generated.
621*common2

checkpoint2default:default2L
8C:/BB1-HTGK7/BB1-HTGK7.runs/impl_1/Top_Module_routed.dcp2default:defaultZ17-1381h px� 
�
I%sTime (s): cpu = %s ; elapsed = %s . Memory (MB): peak = %s ; gain = %s
268*common2&
write_checkpoint: 2default:default2
00:00:272default:default2
00:00:162default:default2
2579.7852default:default2
0.0002default:defaultZ17-268h px� 
�
%s4*runtcl2�
sExecuting : report_drc -file Top_Module_drc_routed.rpt -pb Top_Module_drc_routed.pb -rpx Top_Module_drc_routed.rpx
2default:defaulth px� 
�
Command: %s
53*	vivadotcl2z
freport_drc -file Top_Module_drc_routed.rpt -pb Top_Module_drc_routed.pb -rpx Top_Module_drc_routed.rpx2default:defaultZ4-113h px� 
>
IP Catalog is up to date.1232*coregenZ19-1839h px� 
P
Running DRC with %s threads
24*drc2
22default:defaultZ23-27h px� 
�
#The results of DRC are in file %s.
168*coretcl2�
<C:/BB1-HTGK7/BB1-HTGK7.runs/impl_1/Top_Module_drc_routed.rpt<C:/BB1-HTGK7/BB1-HTGK7.runs/impl_1/Top_Module_drc_routed.rpt2default:default8Z2-168h px� 
\
%s completed successfully
29*	vivadotcl2

report_drc2default:defaultZ4-42h px� 
�
I%sTime (s): cpu = %s ; elapsed = %s . Memory (MB): peak = %s ; gain = %s
268*common2 
report_drc: 2default:default2
00:00:282default:default2
00:00:152default:default2
2579.7852default:default2
0.0002default:defaultZ17-268h px� 
�
%s4*runtcl2�
�Executing : report_methodology -file Top_Module_methodology_drc_routed.rpt -pb Top_Module_methodology_drc_routed.pb -rpx Top_Module_methodology_drc_routed.rpx
2default:defaulth px� 
�
Command: %s
53*	vivadotcl2�
�report_methodology -file Top_Module_methodology_drc_routed.rpt -pb Top_Module_methodology_drc_routed.pb -rpx Top_Module_methodology_drc_routed.rpx2default:defaultZ4-113h px� 
E
%Done setting XDC timing constraints.
35*timingZ38-35h px� 
Y
$Running Methodology with %s threads
74*drc2
22default:defaultZ23-133h px� 
�
2The results of Report Methodology are in file %s.
450*coretcl2�
HC:/BB1-HTGK7/BB1-HTGK7.runs/impl_1/Top_Module_methodology_drc_routed.rptHC:/BB1-HTGK7/BB1-HTGK7.runs/impl_1/Top_Module_methodology_drc_routed.rpt2default:default8Z2-1520h px� 
d
%s completed successfully
29*	vivadotcl2&
report_methodology2default:defaultZ4-42h px� 
�
I%sTime (s): cpu = %s ; elapsed = %s . Memory (MB): peak = %s ; gain = %s
268*common2(
report_methodology: 2default:default2
00:00:412default:default2
00:00:232default:default2
2758.6372default:default2
178.8522default:defaultZ17-268h px� 
�
%s4*runtcl2�
�Executing : report_power -file Top_Module_power_routed.rpt -pb Top_Module_power_summary_routed.pb -rpx Top_Module_power_routed.rpx
2default:defaulth px� 
�
Command: %s
53*	vivadotcl2�
vreport_power -file Top_Module_power_routed.rpt -pb Top_Module_power_summary_routed.pb -rpx Top_Module_power_routed.rpx2default:defaultZ4-113h px� 
E
%Done setting XDC timing constraints.
35*timingZ38-35h px� 
K
,Running Vector-less Activity Propagation...
51*powerZ33-51h px� 
P
3
Finished Running Vector-less Activity Propagation
1*powerZ33-1h px� 
�
�Detected over-assertion of set/reset/preset/clear net with high fanouts, power estimation might not be accurate. Please run Tool - Power Constraint Wizard to set proper switching activities for control signals.282*powerZ33-332h px� 
�
G%s Infos, %s Warnings, %s Critical Warnings and %s Errors encountered.
28*	vivadotcl2
1072default:default2
1832default:default2
02default:default2
02default:defaultZ4-41h px� 
^
%s completed successfully
29*	vivadotcl2 
report_power2default:defaultZ4-42h px� 
�
I%sTime (s): cpu = %s ; elapsed = %s . Memory (MB): peak = %s ; gain = %s
268*common2"
report_power: 2default:default2
00:00:302default:default2
00:00:202default:default2
2758.6372default:default2
0.0002default:defaultZ17-268h px� 
�
%s4*runtcl2u
aExecuting : report_route_status -file Top_Module_route_status.rpt -pb Top_Module_route_status.pb
2default:defaulth px� 
�
%s4*runtcl2�
�Executing : report_timing_summary -max_paths 10 -file Top_Module_timing_summary_routed.rpt -pb Top_Module_timing_summary_routed.pb -rpx Top_Module_timing_summary_routed.rpx -warn_on_violation 
2default:defaulth px� 
r
UpdateTimingParams:%s.
91*timing29
% Speed grade: -2, Delay Type: min_max2default:defaultZ38-91h px� 
|
CMultithreading enabled for timing update using a maximum of %s CPUs155*timing2
22default:defaultZ38-191h px� 
�
rThe design failed to meet the timing requirements. Please see the %s report for details on the timing violations.
188*timing2"
timing summary2default:defaultZ38-282h px� 
�
%s4*runtcl2g
SExecuting : report_incremental_reuse -file Top_Module_incremental_reuse_routed.rpt
2default:defaulth px� 
g
BIncremental flow is disabled. No incremental reuse Info to report.423*	vivadotclZ4-1062h px� 
�
%s4*runtcl2g
SExecuting : report_clock_utilization -file Top_Module_clock_utilization_routed.rpt
2default:defaulth px� 
�
I%sTime (s): cpu = %s ; elapsed = %s . Memory (MB): peak = %s ; gain = %s
268*common2.
report_clock_utilization: 2default:default2
00:00:052default:default2
00:00:052default:default2
2758.6372default:default2
0.0002default:defaultZ17-268h px� 
�
%s4*runtcl2�
�Executing : report_bus_skew -warn_on_violation -file Top_Module_bus_skew_routed.rpt -pb Top_Module_bus_skew_routed.pb -rpx Top_Module_bus_skew_routed.rpx
2default:defaulth px� 
r
UpdateTimingParams:%s.
91*timing29
% Speed grade: -2, Delay Type: min_max2default:defaultZ38-91h px� 
|
CMultithreading enabled for timing update using a maximum of %s CPUs155*timing2
22default:defaultZ38-191h px� 


End Record