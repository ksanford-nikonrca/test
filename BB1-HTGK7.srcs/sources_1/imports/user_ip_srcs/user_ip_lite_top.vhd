library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

library UNISIM;
use UNISIM.VCOMPONENTS.ALL;
library WAVIS_LIB; use WAVIS_LIB.wAvisPackage.all;
                   use WAVIS_LIB.standard_pack.all;
                        
entity user_ip_lite_top is
	port (
		CLK_125MHZ		: in std_logic; 
		RESETN			: in std_logic; --synchronous low true reset
		
		--FMC I/O ports
        LA_P            : inout std_logic_vector(33 downto 0);
        LA_N            : inout std_logic_vector(33 downto 0);
        HA_P            : inout std_logic_vector(23 downto 0);
        HA_N            : inout std_logic_vector(23 downto 0);
        HB_P            : inout std_logic_vector(21 downto 0);
        HB_N            : inout std_logic_vector(21 downto 0);
		
		--Register Signals
		REG_ADDR		: in std_logic_vector(REG_ADDR_WIDTH-1 downto 0);--address of register to read or write to
		WR_EN			: in std_logic; 					--write enable strobe for register write
		WR_DATA			: in std_logic_vector(31 downto 0);	--data that is written to specified register
		RD_REQ			: in std_logic;						--read request strobe for register read
		RD_VALID		: out std_logic;					--strobe that indicates RD_DATA is valid
		RD_DATA			: out std_logic_vector(31 downto 0);--read data from register specified by address
		
		--DMA Signals
		DMA_START		: out std_logic;								--strobe to indicate data from user IP is ready to be sent to DMA 
		DMA_DATA_DEPTH  : out std_logic_vector(DMA_DATA_WIDTH-1 downto 0);	--number of 64 bits that will be data sent with DMA; width set to 10 for 1024 pixels
		DMA_DATA		: out std_logic_vector(63 downto 0);			--64 bit data from user IP blocks 
		DMA_DATA_ADDR	: out std_logic_vector(DMA_DATA_ADDR_WIDTH-1 downto 0);	--current addr to DMA block
		DMA_DATA_WR_EN	: out std_logic;									--strobe to indicate the write data to DMA is valid
		
		--Debug signals
		interrupt_req   : out std_logic;
		soft_reset		: out std_logic	 
	);
end user_ip_lite_top;

architecture arch_imp of user_ip_lite_top is
	--USER SIGNAL DECLARATION
	signal DIFF_IO_LA_i : std_logic_vector(33 downto 0);
	signal DIFF_IO_HA_i : std_logic_vector(23 downto 0);
	signal DIFF_IO_HB_i : std_logic_vector(21 downto 0);
	signal DIFF_IO_LA_o : std_logic_vector(33 downto 0);
	signal DIFF_IO_HA_o : std_logic_vector(23 downto 0);
	signal DIFF_IO_HB_o : std_logic_vector(21 downto 0);
	signal DIFF_IO_LA_t : std_logic_vector(33 downto 0);
	signal DIFF_IO_HA_t : std_logic_vector(23 downto 0);
	signal DIFF_IO_HB_t : std_logic_vector(21 downto 0);
	signal DIFF_DIR_LA   : std_logic_vector(33 downto 0);
	signal DIFF_DIR_HA   : std_logic_vector(23 downto 0);
	signal DIFF_DIR_HB   : std_logic_vector(21 downto 0);
	signal DIFF_IO_LA   : std_logic_vector(33 downto 0);
	signal DIFF_IO_HA   : std_logic_vector(23 downto 0);
	signal DIFF_IO_HB   : std_logic_vector(21 downto 0);
	--END USER SIGNAL DECLARATION
	
	-- component declaration
	component user_ip_registers_mainProjectTop is
		port (
		CLK_125MHZ	: in std_logic;
		RESETN		: in std_logic;
		
		-- Users to add ports here
        DIFF_IO_LA_i : in std_logic_vector(33 downto 0);
		DIFF_IO_HA_i : in std_logic_vector(23 downto 0);
		DIFF_IO_HB_i : in std_logic_vector(21 downto 0);
		DIFF_IO_LA_o : out std_logic_vector(33 downto 0);
		DIFF_IO_HA_o : out std_logic_vector(23 downto 0);
		DIFF_IO_HB_o : out std_logic_vector(21 downto 0);
		DIFF_IO_LA_t : out std_logic_vector(33 downto 0);
		DIFF_IO_HA_t : out std_logic_vector(23 downto 0);
		DIFF_IO_HB_t : out std_logic_vector(21 downto 0);
		DIFF_DIR_LA   : out std_logic_vector(33 downto 0);
		DIFF_DIR_HA   : out std_logic_vector(23 downto 0);
		DIFF_DIR_HB   : out std_logic_vector(21 downto 0);
		
		--Register Signals
		REG_ADDR		: in std_logic_vector(REG_ADDR_WIDTH-1 downto 0);	--address of register to read or write to
		WR_EN			: in std_logic; 					--write enable strobe for register write
		WR_DATA			: in std_logic_vector(31 downto 0);	--data that is written to specified register
		RD_REQ			: in std_logic;						--read request strobe for register read
		RD_VALID		: out std_logic;					--strobe that indicates RD_DATA is valid
		RD_DATA			: out std_logic_vector(31 downto 0);--read data from register specified by address
		
		--DMA Signals
		DMA_START		: out std_logic;								--strobe to indicate data from user IP is ready to be sent to DMA 
		DMA_DATA_DEPTH  : out std_logic_vector(DMA_DATA_WIDTH-1 downto 0);	--number of 64 bits that will be data sent with DMA; width set to 10 for 1024 pixels
		DMA_DATA		: out std_logic_vector(63 downto 0);			--64 bit data from user IP blocks 
		DMA_DATA_ADDR	: out std_logic_vector(DMA_DATA_ADDR_WIDTH-1 downto 0);	--current addr to DMA block
		DMA_DATA_WR_EN	: out std_logic;
		
		--Debug signals
		interrupt_req   : out std_logic;
		soft_reset		: out std_logic	 	
		);
	end component user_ip_registers_mainProjectTop;

begin

-- Instantiation of Axi Bus Interface S00_AXI
user_ip_registers_mainProjectTop_inst : user_ip_registers_mainProjectTop
	port map (
		CLK_125MHZ	=> CLK_125MHZ,
		RESETN		=> RESETN,
	    DIFF_IO_LA_i=> DIFF_IO_LA_i,
		DIFF_IO_HA_i=> DIFF_IO_HA_i,
		DIFF_IO_HB_i=> DIFF_IO_HB_i,
		DIFF_IO_LA_o=> DIFF_IO_LA_o,
		DIFF_IO_HA_o=> DIFF_IO_HA_o,
		DIFF_IO_HB_o=> DIFF_IO_HB_o,
		DIFF_IO_LA_t=> DIFF_IO_LA_t,
		DIFF_IO_HA_t=> DIFF_IO_HA_t,
		DIFF_IO_HB_t=> DIFF_IO_HB_t,
		DIFF_DIR_LA	=> DIFF_DIR_LA,
		DIFF_DIR_HA	=> DIFF_DIR_HA,
		DIFF_DIR_HB	=> DIFF_DIR_HB,
		REG_ADDR	=> REG_ADDR,
		WR_EN		=> WR_EN,
		WR_DATA		=> WR_DATA,
		RD_REQ		=> RD_REQ,
		RD_VALID	=> RD_VALID,
		RD_DATA		=> RD_DATA,
		DMA_START		=> DMA_START,
		DMA_DATA_DEPTH	=> DMA_DATA_DEPTH,
		DMA_DATA		=> DMA_DATA, 
		DMA_DATA_ADDR	=> DMA_DATA_ADDR,
		DMA_DATA_WR_EN	=> DMA_DATA_WR_EN,
		interrupt_req => interrupt_req,
		soft_reset => soft_reset
	);

	-- Add user logic here
	DIFF_LA_IOB: for i in 0 to 33 generate
	begin
		DIFF_LA_IO_BUFF : IOBUF
			generic map (
				DRIVE => 12,
				IOSTANDARD => "default",
				SLEW => "SLOW")
			port map (
				O =>  DIFF_IO_LA_i(i),     -- Buffer output
				IO => DIFF_IO_LA(i),   	-- Buffer inout port (connect directly to top-level port)
				I =>  DIFF_IO_LA_o(i),     -- Buffer input
				T =>  DIFF_IO_LA_t(i)      -- 3-state enable input, high=input, low=output 
			);
	end generate;
	
	DIFF_HA_IOB: for i in 0 to 23 generate
	begin
		DIFF_HA_IO_BUFF : IOBUF
			generic map (
				DRIVE => 12,
				IOSTANDARD => "default",
				SLEW => "SLOW")
			port map (
				O =>  DIFF_IO_HA_i(i),     -- Buffer output
				IO => DIFF_IO_HA(i),   	-- Buffer inout port (connect directly to top-level port)
				I =>  DIFF_IO_HA_o(i),     -- Buffer input
				T =>  DIFF_IO_HA_t(i)      -- 3-state enable input, high=input, low=output 
			);
	end generate;
	
	DIFF_HB_IOB: for i in 0 to 21 generate
	begin
		DIFF_HB_IO_BUFF : IOBUF
			generic map (
				DRIVE => 12,
				IOSTANDARD => "default",
				SLEW => "SLOW")
			port map (
				O =>  DIFF_IO_HB_i(i),     -- Buffer output
				IO => DIFF_IO_HB(i),   	-- Buffer inout port (connect directly to top-level port)
				I =>  DIFF_IO_HB_o(i),     -- Buffer input
				T =>  DIFF_IO_HB_t(i)      -- 3-state enable input, high=input, low=output 
			);
	end generate;
	
	
	LA_P(0)		<= DIFF_IO_LA(0);
	LA_P(1)		<= DIFF_IO_LA(1);
	LA_P(2)		<= DIFF_IO_LA(2);
	LA_P(3)		<= DIFF_IO_LA(3);
	LA_P(4)		<= DIFF_IO_LA(4);
	LA_P(5)		<= DIFF_IO_LA(5);
	LA_P(6)		<= DIFF_IO_LA(6);
	LA_P(7)		<= DIFF_IO_LA(7);
	LA_P(8)		<= DIFF_IO_LA(8);
	LA_P(9)		<= DIFF_IO_LA(9);
	LA_P(10)	<= DIFF_IO_LA(10);
	LA_P(11)	<= DIFF_IO_LA(11);
	LA_P(12)	<= DIFF_IO_LA(12);
	LA_P(13)	<= DIFF_IO_LA(13);
	LA_P(14)	<= DIFF_IO_LA(14);
	LA_P(15)	<= DIFF_IO_LA(15);
	LA_P(16)	<= DIFF_IO_LA(16);
	LA_P(17)	<= DIFF_IO_LA(17);
	LA_P(18)	<= DIFF_IO_LA(18);
	LA_P(19)	<= DIFF_IO_LA(19);
	LA_P(20)	<= DIFF_IO_LA(20);
	LA_P(21)	<= DIFF_IO_LA(21);
	LA_P(22)	<= DIFF_IO_LA(22);
	LA_P(23)	<= DIFF_IO_LA(23);
	LA_P(24)	<= DIFF_IO_LA(24);
	LA_P(25)	<= DIFF_IO_LA(25);
	LA_P(26)	<= DIFF_IO_LA(26);
	LA_P(27)	<= DIFF_IO_LA(27);
	LA_P(28)	<= DIFF_IO_LA(28);
	LA_P(29)	<= DIFF_IO_LA(29);
	LA_P(30)	<= DIFF_IO_LA(30);
	LA_P(31)	<= DIFF_IO_LA(31);
	LA_P(32)	<= DIFF_IO_LA(32);
	LA_P(33)	<= DIFF_IO_LA(33);
	
	HA_P(0)		<= DIFF_IO_HA(0);
	HA_P(1)		<= DIFF_IO_HA(1);
	HA_P(2)		<= DIFF_IO_HA(2);
	HA_P(3)		<= DIFF_IO_HA(3);
	HA_P(4)		<= DIFF_IO_HA(4);
	HA_P(5)		<= DIFF_IO_HA(5);
	HA_P(6)		<= DIFF_IO_HA(6);
	HA_P(7)		<= DIFF_IO_HA(7);
	HA_P(8)		<= DIFF_IO_HA(8);
	HA_P(9)		<= DIFF_IO_HA(9);
	HA_P(10)	<= DIFF_IO_HA(10);
	HA_P(11)	<= DIFF_IO_HA(11);
	HA_P(12)	<= DIFF_IO_HA(12);
	HA_P(13)	<= DIFF_IO_HA(13);
	HA_P(14)	<= DIFF_IO_HA(14);
	HA_P(15)	<= DIFF_IO_HA(15);
	HA_P(16)	<= DIFF_IO_HA(16);
	HA_P(17)	<= DIFF_IO_HA(17);
	HA_P(18)	<= DIFF_IO_HA(18);
	HA_P(19)	<= DIFF_IO_HA(19);
	HA_P(20)	<= DIFF_IO_HA(20);
	HA_P(21)	<= DIFF_IO_HA(21);
	HA_P(22)	<= DIFF_IO_HA(22);
	HA_P(23)	<= DIFF_IO_HA(23);
	
	HB_P(0)		<= DIFF_IO_HB(0);
	HB_P(1)		<= DIFF_IO_HB(1);
	HB_P(2)		<= DIFF_IO_HB(2);
	HB_P(3)		<= DIFF_IO_HB(3);
	HB_P(4)		<= DIFF_IO_HB(4);
	HB_P(5)		<= DIFF_IO_HB(5);
	HB_P(6)		<= DIFF_IO_HB(6);
	HB_P(7)		<= DIFF_IO_HB(7);
	HB_P(8)		<= DIFF_IO_HB(8);
	HB_P(9)		<= DIFF_IO_HB(9);
	HB_P(10)	<= DIFF_IO_HB(10);
	HB_P(11)	<= DIFF_IO_HB(11);
	HB_P(12)	<= DIFF_IO_HB(12);
	HB_P(13)	<= DIFF_IO_HB(13);
	HB_P(14)	<= DIFF_IO_HB(14);
	HB_P(15)	<= DIFF_IO_HB(15);
	HB_P(16)	<= DIFF_IO_HB(16);
	HB_P(17)	<= DIFF_IO_HB(17);
	HB_P(18)	<= DIFF_IO_HB(18);
	HB_P(19)	<= DIFF_IO_HB(19);
	HB_P(20)	<= DIFF_IO_HB(20);
	HB_P(21)	<= DIFF_IO_HB(21);
	
	LA_N(0)		<= DIFF_DIR_LA(0);
	LA_N(1)		<= DIFF_DIR_LA(1);
	LA_N(2)		<= DIFF_DIR_LA(2);
	LA_N(3)		<= DIFF_DIR_LA(3);
	LA_N(4)		<= DIFF_DIR_LA(4);
	LA_N(5)		<= DIFF_DIR_LA(5);
	LA_N(6)		<= DIFF_DIR_LA(6);
	LA_N(7)		<= DIFF_DIR_LA(7);
	LA_N(8)		<= DIFF_DIR_LA(8);
	LA_N(9)		<= DIFF_DIR_LA(9);
	LA_N(10)	<= DIFF_DIR_LA(10);
	LA_N(11)	<= DIFF_DIR_LA(11);
	LA_N(12)	<= DIFF_DIR_LA(12);
	LA_N(13)	<= DIFF_DIR_LA(13);
	LA_N(14)	<= DIFF_DIR_LA(14);
	LA_N(15)	<= DIFF_DIR_LA(15);
	LA_N(16)	<= DIFF_DIR_LA(16);
	LA_N(17)	<= DIFF_DIR_LA(17);
	LA_N(18)	<= DIFF_DIR_LA(18);
	LA_N(19)	<= DIFF_DIR_LA(19);
	LA_N(20)	<= DIFF_DIR_LA(20);
	LA_N(21)	<= DIFF_DIR_LA(21);
	LA_N(22)	<= DIFF_DIR_LA(22);
	LA_N(23)	<= DIFF_DIR_LA(23);
	LA_N(24)	<= DIFF_DIR_LA(24);
	LA_N(25)	<= DIFF_DIR_LA(25);
	LA_N(26)	<= DIFF_DIR_LA(26);
	LA_N(27)	<= DIFF_DIR_LA(27);
	LA_N(28)	<= DIFF_DIR_LA(28);
	LA_N(29)	<= DIFF_DIR_LA(29);
	LA_N(30)	<= DIFF_DIR_LA(30);
	LA_N(31)	<= DIFF_DIR_LA(31);
	LA_N(32)	<= DIFF_DIR_LA(32);
	LA_N(33)	<= DIFF_DIR_LA(33);
	
	HA_N(0)		<= DIFF_DIR_HA(0);
	HA_N(1)		<= DIFF_DIR_HA(1);
	HA_N(2)		<= DIFF_DIR_HA(2);
	HA_N(3)		<= DIFF_DIR_HA(3);
	HA_N(4)		<= DIFF_DIR_HA(4);
	HA_N(5)		<= DIFF_DIR_HA(5);
	HA_N(6)		<= DIFF_DIR_HA(6);
	HA_N(7)		<= DIFF_DIR_HA(7);
	HA_N(8)		<= DIFF_DIR_HA(8);
	HA_N(9)		<= DIFF_DIR_HA(9);
	HA_N(10)	<= DIFF_DIR_HA(10);
	HA_N(11)	<= DIFF_DIR_HA(11);
	HA_N(12)	<= DIFF_DIR_HA(12);
	HA_N(13)	<= DIFF_DIR_HA(13);
	HA_N(14)	<= DIFF_DIR_HA(14);
	HA_N(15)	<= DIFF_DIR_HA(15);
	HA_N(16)	<= DIFF_DIR_HA(16);
	HA_N(17)	<= DIFF_DIR_HA(17);
	HA_N(18)	<= DIFF_DIR_HA(18);
	HA_N(19)	<= DIFF_DIR_HA(19);
	HA_N(20)	<= DIFF_DIR_HA(20);
	HA_N(21)	<= DIFF_DIR_HA(21);
	HA_N(22)	<= DIFF_DIR_HA(22);
	HA_N(23)	<= DIFF_DIR_HA(23);
	
	HB_N(0)		<= DIFF_DIR_HB(0);
	HB_N(1)		<= DIFF_DIR_HB(1);
	HB_N(2)		<= DIFF_DIR_HB(2);
	HB_N(3)		<= DIFF_DIR_HB(3);
	HB_N(4)		<= DIFF_DIR_HB(4);
	HB_N(5)		<= DIFF_DIR_HB(5);
	HB_N(6)		<= DIFF_DIR_HB(6);
	HB_N(7)		<= DIFF_DIR_HB(7);
	HB_N(8)		<= DIFF_DIR_HB(8);
	HB_N(9)		<= DIFF_DIR_HB(9);
	HB_N(10)	<= DIFF_DIR_HB(10);
	HB_N(11)	<= DIFF_DIR_HB(11);
	HB_N(12)	<= DIFF_DIR_HB(12);
	HB_N(13)	<= DIFF_DIR_HB(13);
	HB_N(14)	<= DIFF_DIR_HB(14);
	HB_N(15)	<= DIFF_DIR_HB(15);
	HB_N(16)	<= DIFF_DIR_HB(16);
	HB_N(17)	<= DIFF_DIR_HB(17);
	HB_N(18)	<= DIFF_DIR_HB(18);
	HB_N(19)	<= DIFF_DIR_HB(19);
	HB_N(20)	<= DIFF_DIR_HB(20);
	HB_N(21)	<= DIFF_DIR_HB(21);
	-- User logic ends
end arch_imp;
