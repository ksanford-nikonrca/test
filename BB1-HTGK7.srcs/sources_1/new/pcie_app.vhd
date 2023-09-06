----------------------------------------------------------------------------------
-- Company: Nikon NRCA
-- Engineer: Marco Cassinerio
-- 
-- Create Date: 07/13/2022 05:26:27 PM
-- Design Name: 
-- Module Name: pcie_app - Behavioral
-- Project Name: HTGK7-NRCA-DMA
-- Target Devices: 
-- Tool Versions: 
-- Description: 
-- 
-- Dependencies: 
-- 
-- Revision:
-- Revision 0.01 - File Created
-- Additional Comments:
-- 
----------------------------------------------------------------------------------


library ieee;
use ieee.std_logic_1164.all;

library work;

entity pcie_app is
generic (
  C_DATA_WIDTH : integer range 64 to 128 := 64;
  TCQ          : time                    := 1 ps
);
port  (
  user_clk                       : in  std_logic;
  user_reset                     : in  std_logic;
  user_lnk_up                    : in  std_logic;

  s_axis_tx_tready               : in  std_logic;
  s_axis_tx_tdata                : out std_logic_vector((C_DATA_WIDTH - 1) downto 0);
  s_axis_tx_tkeep                : out std_logic_vector((C_DATA_WIDTH/8)-1 downto 0);
  s_axis_tx_tuser                : out std_logic_vector(3 downto 0);
  s_axis_tx_tlast                : out std_logic;
  s_axis_tx_tvalid               : out std_logic;

  -- RX
  m_axis_rx_tdata                : in std_logic_vector((C_DATA_WIDTH - 1) downto 0);
  m_axis_rx_tkeep                : in std_logic_vector((C_DATA_WIDTH/8)-1 downto 0);
  m_axis_rx_tlast                : in  std_logic;
  m_axis_rx_tvalid               : in  std_logic;
  m_axis_rx_tready               : out std_logic;
  m_axis_rx_tuser                : in std_logic_vector(21 downto 0);

  cfg_to_turnoff                 : in  std_logic;
  cfg_bus_number                 : in  std_logic_vector( 7 downto 0);
  cfg_device_number              : in  std_logic_vector( 4 downto 0);
  cfg_function_number            : in  std_logic_vector( 2 downto 0);

  tx_cfg_gnt                     : out std_logic;
  cfg_pm_halt_aspm_l0s           : out std_logic;
  cfg_pm_halt_aspm_l1            : out std_logic;
  cfg_pm_force_state_en          : out std_logic;
  cfg_pm_force_state             : out std_logic_vector( 1 downto 0);
  rx_np_ok                       : out std_logic;
  rx_np_req                      : out std_logic;
  cfg_turnoff_ok                 : out std_logic;
  cfg_trn_pending                : out std_logic;
  cfg_pm_wake                    : out std_logic;
  cfg_dsn                        : out std_logic_vector(63 downto 0);

  fc_sel                         : out std_logic_vector(2 downto 0);

 -- CFG
  cfg_err_cor                    : out std_logic;
  cfg_err_ur                     : out std_logic;
  cfg_err_ecrc                   : out std_logic;
  cfg_err_cpl_timeout            : out std_logic;
  cfg_err_cpl_unexpect           : out std_logic;
  cfg_err_cpl_abort              : out std_logic;
  cfg_err_atomic_egress_blocked  : out std_logic;
  cfg_err_internal_cor           : out std_logic;
  cfg_err_malformed              : out std_logic;
  cfg_err_mc_blocked             : out std_logic;
  cfg_err_poisoned               : out std_logic;
  cfg_err_norecovery             : out std_logic;
  cfg_err_acs                    : out std_logic;
  cfg_err_internal_uncor         : out std_logic;
  cfg_err_posted                 : out std_logic;
  cfg_err_locked                 : out std_logic;
  cfg_err_tlp_cpl_header         : out std_logic_vector(47 downto 0);
  cfg_err_aer_headerlog          : out std_logic_vector(127 downto 0);
  cfg_aer_interrupt_msgnum       : out std_logic_vector(4 downto 0);

  pl_directed_link_change        : out std_logic_vector( 1 downto 0);
  pl_directed_link_width         : out std_logic_vector( 1 downto 0);
  pl_directed_link_speed         : out std_logic;
  pl_directed_link_auton         : out std_logic;
  pl_upstream_prefer_deemph      : out std_logic;

  cfg_mgmt_di                    : out std_logic_vector(31 downto 0);
  cfg_mgmt_byte_en               : out std_logic_vector( 3 downto 0);
  cfg_mgmt_dwaddr                : out std_logic_vector( 9 downto 0);
  cfg_mgmt_wr_en                 : out std_logic;
  cfg_mgmt_rd_en                 : out std_logic;
  cfg_mgmt_wr_readonly           : out std_logic;
  cfg_interrupt                  : out std_logic;
  cfg_interrupt_assert           : out std_logic;
  cfg_interrupt_di               : out std_logic_vector( 7 downto 0);
  cfg_interrupt_stat             : out std_logic;
  cfg_pciecap_interrupt_msgnum   : out std_logic_vector( 4 downto 0);
  cfg_interrupt_rdy				 : in std_logic;
  cfg_dcommand					 : in std_logic_vector(15 downto 0);
  cfg_command					 : in std_logic_vector(15 downto 0);
  
  bar0_reg_addr					 : out std_logic_vector(5 downto 0);
  bar0_reg_wen					 : out std_logic;
  bar0_reg_din					 : out std_logic_vector(31 downto 0);
  bar0_reg_ren					 : out std_logic;
  bar0_reg_valid		 		 : in std_logic;
  bar0_reg_dout					 : in std_logic_vector(31 downto 0);
	
  dma_start						 : in std_logic;
  dma_data_length				 : in std_logic_vector(15 downto 0);
  dma_data						 : in std_logic_vector(63 downto 0);
  dma_data_rd_addr				 : out std_logic_vector(9 downto 0);
  dma_data_curr_addr			 : in std_logic_vector(9 downto 0);
  
  interrupt_req					 : in std_logic;
  soft_reset					 : in std_logic

);
end pcie_app;

architecture Behavioral of pcie_app is

  constant PCI_EXP_EP_OUI      : std_logic_vector(23 downto 0) := x"000A35";
  constant PCI_EXP_EP_DSN_1    : std_logic_vector(31 downto 0) := x"01" & PCI_EXP_EP_OUI;
  constant PCI_EXP_EP_DSN_2    : std_logic_vector(31 downto 0) := x"00000001";


  signal cfg_completer_id       : std_logic_vector(15 downto 0);
  signal s_axis_tx_tready_i     : std_logic;

--component ila_0 IS
--  PORT (
--	clk : IN STD_LOGIC;
--	trig_in : IN STD_LOGIC;
--	trig_in_ack : OUT STD_LOGIC;
--	probe0 : IN STD_LOGIC_VECTOR(63 DOWNTO 0);
--	probe1 : IN STD_LOGIC_VECTOR(7 DOWNTO 0);
--	probe2 : IN STD_LOGIC_VECTOR(0 DOWNTO 0);
--	probe3 : IN STD_LOGIC_VECTOR(0 DOWNTO 0);
--	probe4 : IN STD_LOGIC_VECTOR(0 DOWNTO 0);
--	probe5 : IN STD_LOGIC_VECTOR(21 DOWNTO 0)
--  );
--  END component;

component  pcie_bars_dma is port(
  	clk 					: in std_logic;
  	rst_n					: in std_logic;
  	
  	-- pcie rx interface
	rx_tdata        		: in std_logic_vector(63 downto 0);
	rx_tkeep        		: in std_logic_vector(7 downto 0);
	rx_tlast        		: in std_logic;
	rx_tvalid       		: in std_logic;
	rx_tready      			: out std_logic;
	rx_bar_hit      		: in std_logic_vector(6 downto 0);
	
	-- pcie tx interface
	tx_tready               : in  std_logic;
	tx_tdata                : out std_logic_vector(63 downto 0);
	tx_tkeep                : out std_logic_vector(7 downto 0);
	tx_tlast                : out std_logic;
	tx_tvalid               : out std_logic;
  	
  	req_completer_id  : in std_logic_vector(15 downto 0);
  	
  	cfg_interrupt	 	: out std_logic;
  	cfg_interrupt_di 	: out std_logic_vector(7 downto 0);
  	cfg_interrupt_rdy	: in std_logic;
  	max_payload_size	: in std_logic_vector(2 downto 0);
  	
  	--user ip interface
	bar0_reg_addr		: out std_logic_vector(5 downto 0);
	bar0_reg_wen		: out std_logic;
	bar0_reg_din		: out std_logic_vector(31 downto 0);
	bar0_reg_ren		: out std_logic;
	bar0_reg_valid		: in std_logic;
	bar0_reg_dout		: in std_logic_vector(31 downto 0);
	
	dma_begin			: in std_logic;
	dma_data_length		: in std_logic_vector(15 downto 0);
	dma_data			: in std_logic_vector(63 downto 0);
	dma_data_rd_addr	: out std_logic_vector(9 downto 0);
	dma_data_curr_addr	: in std_logic_vector(9 downto 0);
	
	interrupt_req		: in std_logic;
	soft_reset			: in std_logic;
  
  	status_leds : out std_logic_vector(4 downto 0)
  	);
end component;


signal clk : std_logic;
signal rst_n : std_logic;

signal req_completer_id : std_logic_vector(15 downto 0);

signal status_leds : std_logic_vector(4 downto 0);

signal s_axis_tx_tkeep_internal : std_logic_vector(7 downto 0);

signal cfg_interrupt_n  : std_logic;

signal probe2, probe3, probe4, probe4_2 : std_logic_vector(0 downto 0);
signal s_axis_tx_tvalid_i, s_axis_tx_tlast_i : std_logic_vector(0 downto 0);
signal s_axis_tx_tkeep_i : std_logic_vector(7 downto 0);
signal probe5 : std_logic_vector(21 downto 0);

signal rx_data_swpd : std_logic_vector(63 downto 0);
signal tx_data_swpd : std_logic_vector(63 downto 0);

begin

clk <= user_clk;
rst_n <= not user_reset;

req_completer_id <= cfg_completer_id;


--debug_probe: ila_0
--PORT map(
--	clk => clk,            
--   	trig_in => m_axis_rx_tvalid,
--	trig_in_ack => open,
--	probe0 => m_axis_rx_tdata,
--    probe1 => m_axis_rx_tkeep,
--    probe2 => probe2,
--    probe3 => probe3,
--    probe4 => probe4,
--    probe5 => probe5
--);


probe2(0) <= m_axis_rx_tlast;
probe3(0) <= m_axis_rx_tvalid;
probe4(0) <= soft_reset;
probe4_2(0) <= s_axis_tx_tready;
probe5 <= '0' & dma_data_length & status_leds;

s_axis_tx_tvalid <= s_axis_tx_tvalid_i(0);
s_axis_tx_tkeep <= s_axis_tx_tkeep_i;
s_axis_tx_tlast <= s_axis_tx_tlast_i(0);


rx_data_swpd <= m_axis_rx_tdata(31 downto 0) & m_axis_rx_tdata(63 downto 32);
s_axis_tx_tdata <= tx_data_swpd(31 downto 0) & tx_data_swpd(63 downto 32);

pcie_bars_dma_compoent : pcie_bars_dma 
  port map 
  (
		clk 					=> clk,
    	rst_n					=> rst_n,
    	
    	-- pcie rx interface
    	rx_tdata        		=> rx_data_swpd,
		rx_tkeep        		=> m_axis_rx_tkeep,
		rx_tlast        		=> m_axis_rx_tlast,
		rx_tvalid       		=> m_axis_rx_tvalid,
		rx_tready       		=> m_axis_rx_tready,
		rx_bar_hit      		=> m_axis_rx_tuser(8 downto 2),
		
		-- pcie tx interface
		tx_tready               => s_axis_tx_tready,
		tx_tdata                => tx_data_swpd,
		tx_tkeep                => s_axis_tx_tkeep_i,
		tx_tlast                => s_axis_tx_tlast_i(0),
		tx_tvalid               => s_axis_tx_tvalid_i(0),
    	
    	req_completer_id  		=> req_completer_id,
    	
    	cfg_interrupt	 		=> cfg_interrupt,
    	cfg_interrupt_di 		=> cfg_interrupt_di,	
    	cfg_interrupt_rdy 		=> cfg_interrupt_rdy,					
    	max_payload_size		=> cfg_dcommand(7 downto 5),
    
		--user ip interface
		bar0_reg_addr			=> bar0_reg_addr,
		bar0_reg_wen			=> bar0_reg_wen,
		bar0_reg_din			=> bar0_reg_din,
		bar0_reg_ren			=> bar0_reg_ren,
		bar0_reg_valid			=> bar0_reg_valid,
		bar0_reg_dout			=> bar0_reg_dout,
		
		dma_begin				=> dma_start,
		dma_data_length			=> dma_data_length,
		dma_data				=> dma_data,
		dma_data_rd_addr		=> dma_data_rd_addr,
		dma_data_curr_addr		=> dma_data_curr_addr,
		
		interrupt_req			=> interrupt_req,
		soft_reset				=> soft_reset,
    
    	status_leds 			=> status_leds
);

  ------------------------------------------------------------------------------------------------------------------//
  -- PCIe Block EP Tieoffs - Example PIO doesn't support the following inputs                                       //
  ------------------------------------------------------------------------------------------------------------------//

  fc_sel                       <= "000";

  tx_cfg_gnt                   <= '1';      -- Always allow transmission of Config traffic within block
  cfg_pm_halt_aspm_l0s         <= '0';      -- Allow entry into L0s
  cfg_pm_halt_aspm_l1          <= '0';      -- Allow entry into L1
  cfg_pm_force_state_en        <= '0';      -- Do not qualify cfg_pm_force_state
  cfg_pm_force_state           <= "00";     -- Do not move force core into specific PM state
  rx_np_ok                     <= '1';      -- Allow Reception of Non-posted Traffic
  rx_np_req                    <= '1';      -- Always request Non-posted Traffic if available
  cfg_trn_pending              <= '0';      -- Never set the transaction pending bit in the Device Status Register
  cfg_pm_wake                  <= '0';      -- Never direct the core to send a PM_PME Message
  cfg_dsn                      <= PCI_EXP_EP_DSN_2 & PCI_EXP_EP_DSN_1;  -- Assign the input DSN
  s_axis_tx_tuser(0)           <= '0';      -- Unused for V6
  s_axis_tx_tuser(1)           <= '0';      -- Error forward packet
  s_axis_tx_tuser(2)           <= '1';      -- Stream packet (does not allow for throttling)
  s_axis_tx_tuser(3)           <= '0';      -- Never discontinue transmission

  cfg_err_cor                  <= '0';      -- Never report Correctable Error
  cfg_err_ur                   <= '0';      -- Never report UR
  cfg_err_ecrc                 <= '0';      -- Never report ECRC Error
  cfg_err_cpl_timeout          <= '0';      -- Never report Completion Timeout
  cfg_err_cpl_abort            <= '0';      -- Never report Completion Abort
  cfg_err_cpl_unexpect         <= '0';      -- Never report unexpected completion
  cfg_err_posted               <= '0';      -- Never qualify cfg_err_* inputs
  cfg_err_locked               <= '0';      -- Never qualify cfg_err_ur or cfg_err_cpl_abort
  cfg_err_atomic_egress_blocked<= '0';      -- Never report Atomic TLP blocked
  cfg_err_internal_cor         <= '0';      -- Never report internal error occurred
  cfg_err_malformed            <= '0';      -- Never report malformed error
  cfg_err_mc_blocked           <= '0';      -- Never report multi-cast TLP blocked
  cfg_err_poisoned             <= '0';      -- Never report poisoned TLP received
  cfg_err_norecovery           <= '0';      -- Never qualify cfg_err_poisoned or cfg_err_cpl_timeout
  cfg_err_acs                  <= '0';      -- Never report an ACS violation
  cfg_err_internal_uncor       <= '0';      -- Never report internal uncorrectable error
  cfg_err_aer_headerlog        <= (others => '0');      -- Zero out the AER Header Log
  cfg_aer_interrupt_msgnum     <= "00000";  -- Zero out the AER Root Error Status Register
  cfg_err_tlp_cpl_header       <= x"000000000000";-- Zero out the header information

  cfg_interrupt_stat           <= '0';      -- Never set the Interrupt Status bit
  cfg_pciecap_interrupt_msgnum <= "00000";  -- Zero out Interrupt Message Number
  cfg_interrupt_assert         <= '0';      -- Always drive interrupt de-assert
  --cfg_interrupt                <= '0';      -- Never drive interrupt by qualifying cfg_interrupt_assert
  --cfg_interrupt_di             <= x"00";    -- Do not set interrupt fields

  pl_directed_link_change      <= "00";     -- Never initiate link change
  pl_directed_link_width       <= "00";     -- Zero out directed link width
  pl_directed_link_speed       <= '0';      -- Zero out directed link speed
  pl_directed_link_auton       <= '0';      -- Zero out link autonomous input
  pl_upstream_prefer_deemph    <= '1';      -- Zero out preferred de-emphasis of upstream port

  cfg_mgmt_di            <= x"00000000";    -- Zero out CFG MGMT input data bus
  cfg_mgmt_byte_en       <= x"0";           -- Zero out CFG MGMT byte enables
  cfg_mgmt_dwaddr        <= "0000000000";   -- Zero out CFG MGMT 10-bit address port
  cfg_mgmt_wr_en         <= '0';            -- Do not write CFG space
  cfg_mgmt_rd_en         <= '0';            -- Do not read CFG space
  cfg_mgmt_wr_readonly   <= '0';            -- Never treat RO bit as RW
  ------------------------------------------------------------------------------------------------------------------//
  -- Programmable I/O Module                                                                                        //
  ------------------------------------------------------------------------------------------------------------------//

  cfg_completer_id     <= (cfg_bus_number & cfg_device_number & cfg_function_number);

  s_axis_tx_tready_i <= s_axis_tx_tready;

end; -- pcie_app
