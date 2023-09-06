----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date:    10:29:59 05/21/2015 
-- Design Name: 
-- Module Name:    pcie_bars_dma - Behavioral 
-- Project Name: 
-- Target Devices: 
-- Tool versions: 
-- Description: 
--
-- Dependencies: 
--
-- Revision: 
-- Revision 0.01 - File Created
-- Additional Comments: 
--
----------------------------------------------------------------------------------
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

-- Uncomment the following library declaration if using
-- arithmetic functions with Signed or Unsigned values
use IEEE.NUMERIC_STD.ALL;
use IEEE.std_logic_signed.all;

-- Uncomment the following library declaration if instantiating
-- any Xilinx primitives in this code.
library UNISIM;
use UNISIM.VComponents.all;

entity pcie_bars_dma is port(
	clk : in std_logic;
	rst_n	: in std_logic;
	
	-- pcie rx interface
	rx_tdata        : in std_logic_vector(63 downto 0);
	rx_tkeep        : in std_logic_vector(7 downto 0);
	rx_tlast        : in std_logic;
	rx_tvalid       : in std_logic;
	rx_tready       : out std_logic;
	rx_bar_hit      : in std_logic_vector(6 downto 0);
	
	-- pcie tx interface
	tx_tready               : in  std_logic;
	tx_tdata                : out std_logic_vector(63 downto 0);
	tx_tkeep                : out std_logic_vector(7 downto 0);
	tx_tlast                : out std_logic;
	tx_tvalid               : out std_logic;
	
	req_completer_id  : in std_logic_vector(15 downto 0);
	
	
	cfg_interrupt 		: out std_logic;
	cfg_interrupt_di 	: out std_logic_vector(7 downto 0);
	cfg_interrupt_rdy 	: in std_logic;
	max_payload_size	: in std_logic_vector(2 downto 0);				--000 = 128 bytes; 001 = 256 bytes; 010 = 512 bytes
	
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
end pcie_bars_dma;

architecture Behavioral of pcie_bars_dma is

type rx_fsm_state_type is(
	RST_STATE,
	BAR2_RD_START,
	BAR2_RD_REPLY_QW1,
	BAR2_RD_REPLY_QW2,
	BAR2_RD_REPLY_QW3,
	BAR0_RD_START,
	BAR0_RD_WAIT_DATA,
	BAR0_RD_REPLY_QW1,
	BAR0_RD_REPLY_QW2,
	BAR2_WR_START,
	BAR2_WR_QW2,
	BAR0_WR_START,
	DUMMY_CPLD
);

type int_fsm_state_type is(
	RST_STATE,
	WAIT_MSI_STATE
);

type dma_fsm_state_type is(
	RST_STATE,
	DMA_START,
	DMA_WAIT_ADDR,
	DMA_WAIT_DATA,
	DMA_WR_QW1,
	DMA_WR_QW2,
	DMA_WR_PAYLOAD,
	DMA_END_TLP,
	DMA_DUMMY_READ_QW1,
	DMA_DUMMY_READ_QW2,
	DMA_DUMMY_CPL_QW1,
	DMA_DUMMY_CPL_QW2
);

constant WR_32BIT_MEM : std_logic_vector(6 downto 0) := "1000000";
constant RD_32BIT_MEM : std_logic_vector(6 downto 0) := "0000000";
constant COMPLETION   : std_logic_vector(6 downto 0) := "1001010";

signal ram_dout : std_logic_vector(63 downto 0);
signal ram_rd_addr : std_logic_vector(15 downto 0);
signal ram_wr_en : std_logic;
signal ram_wr_addr : std_logic_vector(15 downto 0);
signal ram_din : std_logic_vector(63 downto 0);


signal rx_fsm_state : rx_fsm_state_type := RST_STATE;

signal req_tc : std_logic_vector(2 downto 0);
signal req_td : std_logic;
signal req_ep : std_logic;
signal req_attr : std_logic_vector(1 downto 0);
signal req_requester_id : std_logic_vector(15 downto 0);
signal req_tag : std_logic_vector(7 downto 0);

signal temp_start_value : std_logic_vector(63 downto 0) := x"01500D000005010F"; 

signal target_bar	:	std_logic_vector(4 downto 0);
signal payload_len  :	std_logic_vector(1 downto 0);
signal bar2_wr_en_v	:	std_logic_vector(0 downto 0);
signal bar2_wr_en	:	std_logic;
signal bar2_wr_addr	:	std_logic_vector(7 downto 0);
signal bar2_din		:	std_logic_vector(63 downto 0);
signal bar2_rd_addr	:	std_logic_vector(7 downto 0);
signal bar2_dout	:	std_logic_vector(63 downto 0);

signal bar0_reg_sel	:	std_logic_vector(5 downto 0);
signal bar0_data_buffer		: std_logic_vector(31 downto 0);

signal int_fsm_state : int_fsm_state_type := RST_STATE;
--signal interrupt_delivered	:	std_logic;
signal interrupt_req_i		:	std_logic;
signal int_req_dma			:	std_logic;
--signal start_acquisition	:	std_logic;
--signal acquisition_length	:	std_logic_vector(15 downto 0);

signal pcie_intrf_avail		:	std_logic;
signal bars_claim_pcie		:	std_logic;
signal bars_has_pcie		:	std_logic;
signal dma_claim_pcie		:	std_logic;
signal dma_has_pcie			:	std_logic;

signal bars_tx_tdata		:	std_logic_vector(63 downto 0);
signal bars_tx_tlast		:	std_logic;
signal bars_tx_tkeep		:	std_logic_vector(7 downto 0);
signal bars_tx_tvalid		:	std_logic;
signal dma_tx_tdata			:	std_logic_vector(63 downto 0);
signal dma_tx_tlast			:	std_logic;
signal dma_tx_tkeep			:	std_logic_vector(7 downto 0);
signal dma_tx_tvalid		:	std_logic;

signal bars_claim_ram		:	std_logic;
signal bars_has_ram			:	std_logic;
signal dma_claim_ram		:	std_logic;
signal dma_has_ram			:	std_logic;
signal dma_ram_rd_addr		:	std_logic_vector(7 downto 0);
signal bars_ram_rd_addr		:	std_logic_vector(7 downto 0);


signal dma_fsm_state : dma_fsm_state_type := RST_STATE;
signal dma_tag : std_logic_vector(7 downto 0);
signal dma_start_value : std_logic_vector(63 downto 0);
signal dma_payload_len : std_logic_vector(7 downto 0);
signal dma_addr_offset : std_logic_vector(11 downto 0);
signal dma_payload_remaining : std_logic_vector(15 downto 0);
signal dma_addr_offset_sel : std_logic_vector(4 downto 0);
signal dma_data_rd_addr_i: std_logic_vector(9 downto 0);

signal probe4 : std_logic_vector(0 downto 0);
signal probe5 : std_logic_vector(21 downto 0);
signal probe2 : std_logic_vector(0 downto 0);
signal probe3 : std_logic_vector(0 downto 0);

component bar_ram IS
  PORT (
    clka : IN STD_LOGIC;
    wea : IN STD_LOGIC_VECTOR(0 DOWNTO 0);
    addra : IN STD_LOGIC_VECTOR(7 DOWNTO 0);
    dina : IN STD_LOGIC_VECTOR(63 DOWNTO 0);
    clkb : IN STD_LOGIC;
    addrb : IN STD_LOGIC_VECTOR(7 DOWNTO 0);
    doutb : OUT STD_LOGIC_VECTOR(63 DOWNTO 0)
  );
end component;

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

begin

--	debug_probe_2: ila_0
--	PORT map(
--		clk => clk,            
--		trig_in => dma_begin,
--		trig_in_ack => open,
--		probe0 => dma_tx_tdata,
--		probe1 => dma_tx_tkeep,
--		probe2 => probe2,
--		probe3 => probe3,
--		probe4 => probe4,
--		probe5 => probe5
--	);
	probe2(0) <= dma_tx_tlast;
	probe3(0) <= dma_tx_tvalid;
	probe4(0) <= dma_begin;

	probe5(8) <= tx_tready;
	probe5(13 downto 9) <= dma_addr_offset_sel(4 downto 0);
	probe5(7 downto 0) <= dma_payload_remaining(7 downto 0);
	

	bar2_ram_comp : bar_ram port map
	(
		clka => clk,
		wea => bar2_wr_en_v,
		addra => bar2_wr_addr,
		dina => bar2_din,
		clkb => clk,
		addrb => bar2_rd_addr,
		doutb => bar2_dout
	);

	bar2_wr_en_v(0) <= bar2_wr_en;


	pcie_tx_intrf_claim : process(clk)							--process than handles the pcie core interface allocation to either the bar read/write or the dma engine
	begin
		if(rst_n = '0') then
			bars_has_pcie <= '0';
			dma_has_pcie <= '0';
		elsif(rising_edge(clk)) then
			if(bars_claim_pcie = '1') then
				if(dma_has_pcie = '0') then
					bars_has_pcie <= '1';
				else
					bars_has_pcie <= '0';
				end if;
			elsif(dma_claim_pcie = '1') then
				if(bars_has_pcie = '0') then
					dma_has_pcie <= '1';
				else
					dma_has_pcie <= '0';
				end if;
			else
				dma_has_pcie <= '0';
				bars_has_pcie <= '0';
			end if;
		end if;
	end process;
	
	tx_tlast <= bars_tx_tlast when bars_has_pcie='1' else
				dma_tx_tlast when dma_has_pcie='1'	else
				'0';
	tx_tkeep <= bars_tx_tkeep when bars_has_pcie='1' else
				dma_tx_tkeep when dma_has_pcie='1'	else
				(others => '0');
	tx_tvalid <= bars_tx_tvalid when bars_has_pcie='1' else
				dma_tx_tvalid when dma_has_pcie='1'	else
				'0';
	tx_tdata <= bars_tx_tdata when bars_has_pcie='1' else
				dma_tx_tdata when dma_has_pcie='1'	else
				(others => '0');
	
	
	
	bar2_ram_claim : process(clk)								--process that handles the bar2 ram read interface allocation to either the bar read or the dma engine
	begin
		if(rst_n = '0') then
			bars_has_ram <= '0';
			dma_has_ram <= '0';
		elsif(rising_edge(clk)) then
			if(bars_claim_ram = '1') then
				if(dma_has_ram = '0') then
					bars_has_ram <= '1';
				else
					bars_has_ram <= '0';
				end if;
			elsif(dma_claim_ram = '1') then
				if(bars_has_ram = '0') then
					dma_has_ram <= '1';
				else
					dma_has_ram <= '0';
				end if;
			else
				dma_has_ram <= '0';
				bars_has_ram <= '0';
			end if;
		end if;
	end process;
	
	bar2_rd_addr <= bars_ram_rd_addr when bars_has_ram='1' 	else
					dma_ram_rd_addr when dma_has_ram='1'	else
					(others => '0');
	

	rx_tready <= '1';				--signal the PCIe core we are always ready to accept data
	rx_machine : process(clk,rst_n)
	begin
		if(rst_n = '0') then
			rx_fsm_state <= RST_STATE;
			bars_tx_tvalid <= '0';
			bars_tx_tlast <= '0';
			bar2_wr_en <= '0';
			bar0_reg_wen <= '0';
			bars_claim_pcie <= '0';
			bars_claim_ram	<= '0';
			bar0_reg_ren <= '0';
		elsif(rising_edge(clk)) then
			case rx_fsm_state is
				when RST_STATE =>
					status_leds <= "00000";
					bars_tx_tlast <= '0';
					bars_tx_tvalid <= '0';
					bar2_wr_en <= '0';
					bar0_reg_wen <= '0';
					bars_claim_pcie <= '0';
					bars_claim_ram <= '0';
					bar0_reg_ren <= '0';
					if(rx_tvalid = '1' and rx_tlast = '0') then											--start of TLP, first QuadWord received
						if(rx_tdata(33 downto 32) = "10" or rx_tdata(33 downto 32) = "01") then			--we accept TLP with either 1 or 2 DW as payload only
							payload_len <= rx_tdata(33 downto 32);										--length in DW (32 bits)
							target_bar <= rx_bar_hit(4 downto 0);
							req_tc <= rx_tdata(54 downto 52);
							req_td <= rx_tdata(47);
							req_ep <= rx_tdata(46);
							req_attr <= rx_tdata(45 downto 44);
							req_requester_id <= rx_tdata(31 downto 16);
							req_tag <= rx_tdata(15 downto 8); 
							case rx_tdata(62 downto 56) is
								when WR_32BIT_MEM =>	--the TLP is a write to Bar memory (32 bits)
									if(rx_bar_hit(2) = '1'and rx_tdata(33 downto 32) = "10") then		--bar2 read can only be 64bits (1QW or 2DW) at a time
										rx_fsm_state <= BAR2_WR_START;
									elsif(rx_bar_hit(0) = '1' and rx_tdata(33 downto 32) = "01") then	--bar0 read can only be 32bits (1DW) at a time
										rx_fsm_state <= BAR0_WR_START;
									end if;
								when RD_32BIT_MEM =>	--the TLP is a read from Bar memory (32 bits)
									if(rx_bar_hit(2) = '1' and rx_tdata(33 downto 32) = "10") then		--bar2 read can only be 64bits (1QW or 2DW) at a time
										rx_fsm_state <= BAR2_RD_START;
										bars_claim_ram <= '1';
									elsif(rx_bar_hit(0) = '1' and rx_tdata(33 downto 32) = "01") then	--bar0 read can only be 32bits (1DW) at a time
										rx_fsm_state <= BAR0_RD_START;
									else
										rx_fsm_state <= DUMMY_CPLD;										--respond with a dummy completion
									end if;
								when others =>
									rx_fsm_state <= RST_STATE;	--go back to rst_state and do nothing;
							end case;
						else
							rx_fsm_state <= RST_STATE;
						end if;
					else
						rx_fsm_state <= RST_STATE;	--go back to rst_State and wait
					end if;
				when BAR2_RD_START =>
					status_leds <= "00001";
					if(rx_tvalid = '1') then				--if PCIe core is presenting valid data
						bars_ram_rd_addr <= rx_tdata(42 downto 35);	--this holds the address the PCIe is asking data from, in QW (64 bits)
															--the rest of the data is meaningless and invalid
						bars_claim_pcie <= '1';				--I cailm the pcie interface for the read reply
						rx_fsm_state <= BAR2_RD_REPLY_QW1;
					else
						rx_fsm_state <= BAR2_RD_START;
					end if;										
				when BAR2_RD_REPLY_QW1 =>			--reply to the read request. we start by sending the first 64bit: TLP header 
					status_leds <= "00010";
					if(bars_has_ram = '1') then		--I must wait for access granted to Bar2 ram memory read
						if(bars_has_pcie = '1') then	--I must wait for the interface to be assigned to me
							if(tx_tready = '1') then	--if PCIe core is ready to accept data
								bars_tx_tlast <= '0';		--signal the PCIe core this is not the last QW in the TLP
								bars_tx_tkeep <= X"FF";		--signal the PCIe core data valid on the whole 64bits
								bars_tx_tvalid <= '1';		--signal the PCIe core we are presenting valid data
																													 --payload len (10 bits)                    			--byte count of transmission (12bits)
								bars_tx_tdata <= "01001010" & '0' & req_tc & "0000" & req_td & req_ep & req_attr & "00" & "00000000" & payload_len & req_completer_id & "0000" & "00000000" & payload_len & "00";
								rx_fsm_state <= BAR2_RD_REPLY_QW2;
							else
								bars_tx_tvalid <= '0';
								rx_fsm_state <= BAR2_RD_REPLY_QW1;
							end if;
						else
							rx_fsm_state <= BAR2_RD_REPLY_QW1;
						end if;
					else
						rx_fsm_state <= BAR2_RD_REPLY_QW1;
					end if;
				when BAR2_RD_REPLY_QW2 =>			--send the second 64 bits: some TLP header fields and first 32 bits of the data
					status_leds <= "00011";
					if(tx_tready = '1') then	--if PCIe core is ready to accept data
						
						bars_tx_tvalid <= '1';		--signal the PCIe core we are presenting valid data
						if(payload_len = "01") then
							bars_tx_tlast <= '1';		--signal the PCIe core this is the last QW in the TLP
							bars_tx_tkeep <= X"FF";
							rx_fsm_state <= RST_STATE;		--we are done sending stuff, this was the last QW
						else
							bars_tx_tlast <= '0';		--signal the PCIe core this is not the last QW in the TLP
							bars_tx_tkeep <= X"FF";		--signal the PCIe core data valid on the whole 64bits
							rx_fsm_state <= BAR2_RD_REPLY_QW3;	--one more QW to be sent with the last 32 bits of the data
						end if;
																	   --lower 7 bits of the address we read from							
						bars_tx_tdata <= req_requester_id & req_tag & '0' & bars_ram_rd_addr(6 downto 0) & bar2_dout(63 downto 32);
						
					else
						bars_tx_tvalid <= '0';
						rx_fsm_state <= BAR2_RD_REPLY_QW2;
					end if;
				when BAR2_RD_REPLY_QW3 =>			--send the last 64 bits: the remaining 32 bits of data. the packet has only 32 bit (DW) valid data
					status_leds <= "00100";
					if(tx_tready = '1') then	--if PCIe core is ready to accept data
						bars_tx_tlast <= '1';		--signal the PCIe core this is the last QW in the TLP
						bars_tx_tvalid <= '1';		--signal the PCIe core we are presenting valid data
						bars_tx_tkeep <= X"0F";		--signal the PCIe core data valid only on 32 bits
						bars_tx_tdata <= bar2_dout(31 downto 0) & X"00000000";
						--temp_start_value <= temp_start_value + 1;
						rx_fsm_state <= RST_STATE;
					else
						bars_tx_tvalid <= '0';
						rx_fsm_state <= BAR2_RD_REPLY_QW3;
					end if;
				when BAR0_RD_START =>
					status_leds <= "00101";
					if(rx_tvalid = '1') then				--if PCIe core is presenting valid data
						--bar0_reg_sel <= rx_tdata(35 downto 34);	--this holds the address the PCIe is asking data from, in DW (32 bits)
						bar0_reg_addr <= rx_tdata(39 downto 34);	--this holds the address the PCIe is asking data from, in DW (32 bits)
						bar0_reg_sel <= rx_tdata(39 downto 34);
						bar0_reg_ren <= '1';				--signal we want to read the bar0 address
															--the rest of the data is meaningless and invalid
						bars_claim_pcie <= '1';				--I claim the PCIe interface for the read reply
						rx_fsm_state <= BAR0_RD_WAIT_DATA;
					else
						rx_fsm_state <= BAR0_RD_START;
					end if;
				when BAR0_RD_WAIT_DATA =>
					status_leds <= "10000";
					if(bar0_reg_valid = '1') then	--I need to wait untill the bar0 reg data is valid and lath it before sending the packed
						bar0_reg_ren <= '0';
						bar0_data_buffer <= bar0_reg_dout;
						rx_fsm_state <= BAR0_RD_REPLY_QW1;
					else
						rx_fsm_state <= BAR0_RD_WAIT_DATA;
					end if;
				when BAR0_RD_REPLY_QW1 =>			--reply to the read request. we start by sending the first 64bit: TLP header 
					status_leds <= "00110";
					if(bars_has_pcie = '1') then	--I must wait for the interface to be assigned to me						
						if(tx_tready = '1') then	--if PCIe core is ready to accept data
							bars_tx_tlast <= '0';		--signal the PCIe core this is not the last QW in the TLP
							bars_tx_tkeep <= X"FF";		--signal the PCIe core data valid on the whole 64bits
							bars_tx_tvalid <= '1';		--signal the PCIe core we are presenting valid data
																												 --payload len (10 bits)                    			--byte count of transmission (12bits)
							bars_tx_tdata <= "01001010" & '0' & req_tc & "0000" & req_td & req_ep & req_attr & "00" & "00000000" & payload_len & req_completer_id & "0000" & "00000000" & payload_len & "00";
							rx_fsm_state <= BAR0_RD_REPLY_QW2;
						else
							bars_tx_tvalid <= '0';
							rx_fsm_state <= BAR0_RD_REPLY_QW1;
						end if;
					else							--otherwise wait to become available
						rx_fsm_state <= BAR0_RD_REPLY_QW1;						
					end if;
				when BAR0_RD_REPLY_QW2 =>			--send the second 64 bits: some TLP header fields and first 32 bits of the data
					status_leds <= "00111";
					
					if(tx_tready = '1') then	--if PCIe core is ready to accept data						
						bars_tx_tvalid <= '1';		--signal the PCIe core we are presenting valid data
						bars_tx_tlast <= '1';		--signal the PCIe core this is the last QW in the TLP
						bars_tx_tkeep <= X"FF";
						rx_fsm_state <= RST_STATE;		--we are done sending stuff, this was the last QW
																	   --lower 7 bits of the address we read from							
						bars_tx_tdata <= req_requester_id & req_tag & '0' & '0' & bar0_reg_sel & bar0_data_buffer;	
										
					else
						bars_tx_tvalid <= '0';
						rx_fsm_state <= BAR0_RD_REPLY_QW2;
					end if;
					
				when BAR2_WR_START =>
					status_leds <= "01000";
					if(rx_tvalid = '1') then				--if PCIe core is presenting valid data
						bar2_wr_addr <= rx_tdata(42 downto 35);	--this holds the address the PCIe is writing data to, in DW
						bar2_din(63 downto 32) <= rx_tdata(31 downto 0);	--first 32 bits of the data to be written in bar2 block ram
						rx_fsm_state <= BAR2_WR_QW2;
					else
						rx_fsm_state <= BAR2_WR_START;
					end if;
				when BAR2_WR_QW2 =>
					status_leds <= "01001";
					if(rx_tvalid = '1') then				--if PCIe core is presenting valid data
						bar2_din(31 downto 0) <= rx_tdata(63 downto 32);
															--the rest of the data is meaningless and invalid
						bar2_wr_en <= '1';
						rx_fsm_state <= RST_STATE;
					else
						rx_fsm_state <= BAR2_WR_START;
					end if;
				when BAR0_WR_START =>
					status_leds <= "01010";
					if(rx_tvalid = '1') then				--if PCIe core is presenting valid data
						bar0_reg_addr <= rx_tdata(39 downto 34);	--this holds the address the PCIe is writing data to, in DW
						bar0_reg_din <= rx_tdata(31 downto 0);		--first, and only, 32 bits of the data to be written in bar0 block ram
						bar0_reg_wen <= '1';	
						rx_fsm_state <= RST_STATE;
					else
						rx_fsm_state <= BAR0_WR_START;
					end if;
				when DUMMY_CPLD =>
					status_leds <= "11111";
					rx_fsm_state <= RST_STATE;
			end case; 
		end if;
	end process;
	
--	bar0_reg_ram : process(clk)
--	begin
--		if(rising_edge(clk)) then
--			if(bar0_reg_wen = '1') then
--				case bar0_reg_sel is
--					when "00" =>
--						bar0_reg_0 <= bar0_din;
--					when "01" =>
--						bar0_reg_1 <= bar0_din;
--					when "10" =>
--						bar0_reg_2 <= bar0_din;
--					when "11" =>
--						bar0_reg_3 <= bar0_din;
--				end case;
--			else
--				bar0_reg_0(31) <= '0';			--clear the bit for interrupt request
--				bar0_reg_0(0) <= '0';			--clear the bit for start acquisition
--			end if;
--			bar0_reg_0(3 downto 1) <= max_payload_size;
--			case bar0_reg_sel is
--				when "00" =>
--					bar0_dout <= bar0_reg_0;
--				when "01" =>
--					bar0_dout <= bar0_reg_1;
--				when "10" =>
--					bar0_dout <= bar0_reg_2;
--				when "11" =>
--					bar0_dout <= bar0_reg_3;
--			end case;
--			int_req_bram0 <= bar0_reg_0(31);
--			start_acquisition <= bar0_reg_0(0);
--			acquisition_length <= bar0_reg_1(15 downto 0);		--number of QW (8 bytes) to be acquired. max lenght is 131072
--		end if;
--	end process;
	
	interrupt_req_i <= interrupt_req or int_req_dma;
	
	interrupt_gen_fsm : process(clk)
	begin
		if(rst_n = '0') then
			int_fsm_state <= RST_STATE;
			--interrupt_delivered <= '0';
			cfg_interrupt <= '0';
		elsif(rising_edge(clk)) then
			case int_fsm_state is
				when RST_STATE =>
					--interrupt_delivered <= '0';
					if(interrupt_req_i = '1') then
						cfg_interrupt <= '1';					--signal the PCIe core we want to send and interrupt MSI
						cfg_interrupt_di <= (others => '0');	--only one element in the interrupt vector, pad to 0s
						int_fsm_state <= WAIT_MSI_STATE;			--wait for the PCIe core to deliver the interrupt
					else
						cfg_interrupt <= '0';
						int_fsm_state <= RST_STATE;
					end if;
				
				when WAIT_MSI_STATE =>
					if(cfg_interrupt_rdy = '1') then	--if interrupt has been delivered by the PCIe core
						cfg_interrupt <= '0';				--stop signaling willingness for interrupt
						int_fsm_state <= RST_STATE;
						--interrupt_delivered <= '1';
					else
						int_fsm_state <= WAIT_MSI_STATE; --wait for core to signal interrupt sent
					end if;
			end case;
		end if;
	end process;
	
	
	--map the dma_offset to address
	
----when max payload is 128 bytes------------------------------------------------
	dma_addr_offset(7 downto 0) <= 	X"00" when dma_addr_offset_sel(0) = '0' else
									X"80" when dma_addr_offset_sel(0) = '1';
									
	dma_addr_offset(11 downto 8) <= dma_addr_offset_sel(4 downto 1);
---------------------------------------------------------------------------------

----when max payload is 256 bytes------------------------------------------------
--dma_addr_offset(7 downto 0) <= 	X"00";
									
--dma_addr_offset(11 downto 8) <= dma_addr_offset_sel(3 downto 0);
---------------------------------------------------------------------------------

	
	probe5(17 downto 14) <= dma_data_rd_addr_i(3 downto 0);
	dma_data_rd_addr <= dma_data_rd_addr_i;
	
	dma_fsm : process(clk)
	begin
		if(rst_n = '0') then
			int_req_dma <= '0';
			dma_fsm_state <= RST_STATE;
			dma_claim_pcie	<= '0';
			dma_tx_tvalid <= '0';
			dma_tx_tlast <= '0';
			dma_claim_ram <= '0';
			dma_addr_offset_sel <= (others => '0');
		elsif(rising_edge(clk)) then
			if(soft_reset = '1') then
				dma_fsm_state <= RST_STATE;
			else
				case dma_fsm_state is
					when RST_STATE =>
						probe5(21 downto 18) <= "0000";
						dma_tx_tvalid <= '0';
						dma_tx_tlast <= '0';
						int_req_dma <= '0';
						dma_claim_pcie <= '0';
						dma_claim_ram <= '0';
						dma_tag <= (others => '0');
						dma_ram_rd_addr <= (others => '0');
						dma_addr_offset_sel <= (others => '0');
						dma_data_rd_addr_i <= (others => '0');
						if(dma_begin = '1') then	--data acquisition started. start dma process
							dma_claim_pcie <= '1';
							dma_payload_remaining <= dma_data_length;
							--dma_start_value <= X"00000000"  & X"00000000";
							dma_claim_ram <= '1';	
							dma_fsm_state <= DMA_START;	
						else
							dma_fsm_state <= RST_STATE;
						end if;
					when DMA_START =>
						probe5(21 downto 18) <= "0001";
						if(dma_payload_remaining > X"0010") then					--maximum payload length per TLP, 128 bytes (16 QW or 32 DW)
							dma_payload_len <= X"10";								--16 QW = 128 bytes, or 32 DW
							dma_payload_remaining <= dma_payload_remaining - X"0010";
						else
							dma_payload_len <= dma_payload_remaining(7 downto 0);
							dma_payload_remaining <= (others => '0');
						end if;
						dma_fsm_state <= DMA_WAIT_ADDR;	
					when DMA_WAIT_ADDR =>
						probe5(21 downto 18) <= "0010";
						if(dma_has_ram = '1') then			--I must wait for access to the Bar2 ram
							dma_fsm_state <= DMA_WAIT_DATA;
						else
							dma_fsm_state <= DMA_WAIT_ADDR;
						end if;
					when DMA_WAIT_DATA => 				--I must wait for 32 QW to be ready in the dma_bram because the PCIe core is expecting data at every clock cycle and I cannot throttle
														--32 QWs are available when the dma_data_curr_addr is greater than 32, then greater than 64, 96 etc...
														--this happens when the last 5 bits of dma_data_curr_addr are all 1s (31)
														-- I am assuming that the dma transfer is much faster than the ram getting filled by data and so at the next round I will be here waiting and
														--the current address will never pass the 31 threshold during the dma transfer, otherwise I am stuck and lose data
						if(dma_data_curr_addr(4 downto 0) = "11111") then
							dma_fsm_state <= DMA_WR_QW1;
						else
							dma_fsm_state <= DMA_WAIT_DATA;
						end if;
						probe5(21 downto 18) <= "1111";
					when DMA_WR_QW1 =>
						probe5(21 downto 18) <= "0011";
						if(dma_has_pcie = '1') then
							if(tx_tready = '1') then	--if PCIe core is ready to accept data
								dma_tx_tlast <= '0';		--signal the PCIe core this is not the last QW in the TLP
								dma_tx_tkeep <= X"FF";		--signal the PCIe core data valid on the whole 64bits
								dma_tx_tvalid <= '1';		--signal the PCIe core we are presenting valid data
												 --1 because it is a 4DW header								  --the payload_lenght is in multiples of QW but we need to specify the number of DW. That's why the '0' after
								dma_tx_tdata <= "011" & "00000" & '0' & "000" & "0000" & "00" & "00" & "00" & '0' & dma_payload_len(7 downto 0) & '0' & req_completer_id & dma_tag & X"FF";	--payload_length is in unit of DW (32 bits) it is a 4DW header
								dma_tag <= dma_tag + 1;
								--dma_tx_tdata <= "01001010" & '0' & req_tc & "0000" & req_td & req_ep & req_attr & "00" & "00000000" & payload_len & req_completer_id & "0000" & "00000000" & payload_len & "00";
								dma_fsm_state <= DMA_WR_QW2;
							else
								dma_tx_tvalid <= '0';
								dma_fsm_state <= DMA_START;
							end if;
						else
							dma_fsm_state <= DMA_START;
						end if;
					when DMA_WR_QW2 =>
						probe5(21 downto 18) <= "0100";
						if(tx_tready = '1') then	--if PCIe core is ready to accept data
							dma_tx_tlast <= '0';		--signal the PCIe core this is not the last QW in the TLP
							dma_tx_tkeep <= X"FF";		--signal the PCIe core data valid on the whole 64bits
							dma_tx_tvalid <= '1';		--signal the PCIe core we are presenting valid data
							dma_tx_tdata <= bar2_dout(63 downto 12) & dma_addr_offset;	--get the address from the Bar ram and add offset
	
							dma_data_rd_addr_i <= dma_data_rd_addr_i +1;		--I do increment it here because there is 1clk latency between address and data 
							dma_fsm_state <= DMA_WR_PAYLOAD;
						else
							dma_fsm_state <= DMA_WR_QW2;
						end if;
					when DMA_WR_PAYLOAD =>
						probe5(21 downto 18) <= "0101";
						if(tx_tready = '1') then	--if PCIe core is ready to accept data
							dma_tx_tkeep <= X"FF";		--signal the PCIe core data valid on the whole 64bits
							dma_tx_tvalid <= '1';		--signal the PCIe core we are presenting valid data
							--dma_tx_tdata <= dma_start_value;
							--FPGA works in Big Endian while the Intel Arch is Little Endian, I swap the bytes here so I will have the data in the correct endianess on the PC side
							
							dma_tx_tdata(63 downto 56) <= dma_data(7 downto 0);
							dma_tx_tdata(55 downto 48) <= dma_data(15 downto 8);
							dma_tx_tdata(47 downto 40) <= dma_data(23 downto 16);
							dma_tx_tdata(39 downto 32) <= dma_data(31 downto 24);
							dma_tx_tdata(31 downto 24) <= dma_data(39 downto 32);
							dma_tx_tdata(23 downto 16) <= dma_data(47 downto 40);
							dma_tx_tdata(15 downto 8) <= dma_data(55 downto 48);
							dma_tx_tdata(7 downto 0) <= dma_data(63 downto 56);
							
							
							--dma_start_value <= dma_start_value + 1;
							dma_payload_len <= dma_payload_len - 1;
							if(dma_payload_len = X"01") then	--we reached the end of the current TLP
								dma_fsm_state <= DMA_END_TLP;
								dma_tx_tlast <= '1';		--signal the PCIe core this is the last QW in the TLP
							else
								dma_data_rd_addr_i <= dma_data_rd_addr_i +1;
								dma_fsm_state <= DMA_WR_PAYLOAD;
								dma_tx_tlast <= '0';		--signal the PCIe core this is not the last QW in the TLP
							end if;
						else
							dma_fsm_state <= DMA_WR_PAYLOAD;
						end if;
					when DMA_END_TLP =>
						probe5(21 downto 18) <= "0110";
						dma_tx_tvalid <= '0';
						
						if(dma_payload_remaining = 0) then					--we completed the transmission of acquisition_len QW
							dma_fsm_state <= DMA_DUMMY_READ_QW1;
						else
							dma_fsm_state <= DMA_START;
							if(dma_addr_offset_sel = 31) then					--we filled up one page, lets get a new page address
								dma_ram_rd_addr <= dma_ram_rd_addr + 1;			--we fetch the next page bus address for dma transfer
								dma_addr_offset_sel <= (others => '0');
							else
								dma_addr_offset_sel <= dma_addr_offset_sel + 1;	--increment the offset by 128 bytes, where the next data will be transmitted to
							end if;	
						end if;
						
					when DMA_DUMMY_READ_QW1 =>		--I need to ask for a dummy read in order to force flush the TLP buffer
						probe5(21 downto 18) <= "0111";
						if(tx_tready = '1') then	--if PCIe core is ready to accept data
							dma_tx_tlast <= '0';		--signal the PCIe core this is not the last QW in the TLP
							dma_tx_tkeep <= X"FF";		--signal the PCIe core data valid on the whole 64bits
							dma_tx_tvalid <= '1';		--signal the PCIe core we are presenting valid data
							dma_tx_tdata <= "001" & "00000" & '0' & "000" & "0000" & "00" & "00" & "00" & "0000000001" & req_completer_id & X"00" & X"00";	--memory read of 1DW with no bytes enabled
							dma_fsm_state <= DMA_DUMMY_READ_QW2;
						else
							dma_tx_tvalid <= '0';
							dma_fsm_state <= DMA_DUMMY_READ_QW1;
						end if;
						
					when DMA_DUMMY_READ_QW2 =>
						probe5(21 downto 18) <= "1000";
						if(tx_tready = '1') then	--if core ready to receive data
							dma_tx_tlast <= '1';		--signal the PCIe core this is the last QW in the TLP
							dma_tx_tkeep <= X"FF";		--signal the PCIe core data valid on the whole 64bits
							dma_tx_tvalid <= '1';		--signal the PCIe core we are presenting valid data
							dma_tx_tdata <= bar2_dout(63 downto 12) & dma_addr_offset;	--address for the dummy read, same as last dma address
							dma_fsm_state <= DMA_DUMMY_CPL_QW1;
						else
							dma_tx_tvalid <= '0';
							dma_fsm_state <= DMA_DUMMY_READ_QW2;
						end if;
						
					when DMA_DUMMY_CPL_QW1 =>									--wait for the completion of the dummy read
						probe5(21 downto 18) <= "1001";
						dma_tx_tvalid <= '0';
						dma_tx_tlast <= '0';
						dma_claim_ram <= '0';									--release the request to access bar2 ram
						if(rx_tvalid = '1' and rx_tlast = '0') then				--first completion QW received
							if(rx_tdata(62 downto 56) = COMPLETION) then		--We accept only a 64bit completion. The other rx fsm should be triggered but the request is discarded because it doesn't handle completions
								if(rx_tdata(41 downto 32) = "0000000001") then	--if payload length is 1DW, we expect a completion with 1DW
									dma_fsm_state <= DMA_DUMMY_CPL_QW2;			--if all the conditions are met, we accept the completion
								else
									dma_fsm_state <= DMA_DUMMY_CPL_QW1;			--not a completion from our request
								end if;
							else
								dma_fsm_state <= DMA_DUMMY_CPL_QW1;				--not a completion from our request
							end if;
						else
							dma_fsm_state <= DMA_DUMMY_CPL_QW1;					--wait for the competion
						end if;
						
					when DMA_DUMMY_CPL_QW2 =>
						probe5(21 downto 18) <= "1010";
						if(rx_tvalid = '1') then 							--core presenting valid data
							dma_fsm_state <= RST_STATE;						--we discard the data as not important
							int_req_dma <= '1';								--we send a trigger to tell PC we are done
						else
							dma_fsm_state <= DMA_DUMMY_CPL_QW2;
						end if;
				end case;
			end if;
		end if;
	end process;

end Behavioral;