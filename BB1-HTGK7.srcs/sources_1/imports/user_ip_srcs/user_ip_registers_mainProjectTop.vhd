library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

library WAVIS_LIB;
use WAVIS_LIB.wAvisPackage.all; use WAVIS_LIB.wAvisPackage.all;
                                use WAVIS_LIB.standard_pack.all;

entity user_ip_registers_mainProjectTop is
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
		DMA_DATA_DEPTH  : out std_logic_vector(DMA_DATA_WIDTH-1 downto 0);	--number of 64 bits that will be data sent with DMA; width set to 11 for 1024 pixels
		DMA_DATA		: out std_logic_vector(63 downto 0);			--64 bit data from user IP blocks 
		DMA_DATA_ADDR	: out std_logic_vector(DMA_DATA_ADDR_WIDTH-1 downto 0);	--current addr to DMA block
		DMA_DATA_WR_EN	: out std_logic;
		
		--Debug signals
		interrupt_req   : out std_logic;
		soft_reset		: out std_logic	
	);
end user_ip_registers_mainProjectTop;

architecture arch_imp of user_ip_registers_mainProjectTop is

	signal WR_EN_DELAY        : std_logic_vector(1 downto 0);
	signal RD_REQ_DELAY       : std_logic_vector(2 downto 0);
	signal reg_data_out       : std_logic_vector(31 downto 0);
	
	signal FPGA_ID            : std_logic_vector(11 downto 0);
	signal softReset          : std_logic;
	signal DIFF_IO_LA_i_o	  : std_logic_vector(31 downto 0);
	signal DIFF_IO_LA_HA_i_o  : std_logic_vector(31 downto 0);
	signal DIFF_IO_HB_i_o     : std_logic_vector(31 downto 0);
	signal DIFF_DIR_LA_reg    : std_logic_vector(31 downto 0);
	signal DIFF_DIR_LA_HA_reg : std_logic_vector(31 downto 0);
	signal DIFF_DIR_HB_reg    : std_logic_vector(31 downto 0);
	
	    --REGISTER SIGNALS
    signal halfClkPerIn        : std_logic_vector(31 downto 0);
    signal mstHighTimeIn       : std_logic_vector(31 downto 0);
    signal mstLowTimeIn        : std_logic_vector(31 downto 0);
    signal spiConfigIn         : std_logic_vector(31 downto 0);
    signal spiRwCtrlIn         : std_logic_vector(31 downto 0);
    signal spiStartPixelOut    : std_logic_vector(31 downto 0);
    signal spiReadoutPixelsOut : std_logic_vector(31 downto 0);
    signal spiSkippedPixelsOut : std_logic_vector(31 downto 0);
    signal spiOffsetShiftOut   : std_logic_vector(31 downto 0);
    signal spiLsEnIn           : std_logic;
    signal ctrlRegIn           : std_logic_vector(31 downto 0);
    signal pixelNumSelIn_L1	: std_logic_vector(ADDR_WIDTH-1 downto 0);
	signal pixelNumSelIn_L2	: std_logic_vector(ADDR_WIDTH-1 downto 0);
	signal pixelNumSelIn_L3	: std_logic_vector(ADDR_WIDTH-1 downto 0);
	signal pixelNumSelIn_L4	: std_logic_vector(ADDR_WIDTH-1 downto 0);
    signal pixelValueOut_L1    : std_logic_vector(DATA_WIDTH-1 downto 0);
	signal pixelValueOut_L2    : std_logic_vector(DATA_WIDTH-1 downto 0);
	signal pixelValueOut_L3    : std_logic_vector(DATA_WIDTH-1 downto 0);
	signal pixelValueOut_L4    : std_logic_vector(DATA_WIDTH-1 downto 0);
    signal pixelValueAuxOut_L1 : std_logic_vector(DATA_WIDTH-1 downto 0);
	signal pixelValueAuxOut_L2 : std_logic_vector(DATA_WIDTH-1 downto 0);
	signal pixelValueAuxOut_L3 : std_logic_vector(DATA_WIDTH-1 downto 0);
	signal pixelValueAuxOut_L4 : std_logic_vector(DATA_WIDTH-1 downto 0);
    signal pixelNumDebugOut_L1 : std_logic_vector(31 downto 0);
	signal pixelNumDebugOut_L2 : std_logic_vector(31 downto 0);
	signal pixelNumDebugOut_L3 : std_logic_vector(31 downto 0);
	signal pixelNumDebugOut_L4 : std_logic_vector(31 downto 0);
    signal pixelCntDebugOut_L1 : std_logic_vector(31 downto 0);
    signal pixelCntDebugOut_L2 : std_logic_vector(31 downto 0);
	signal pixelCntDebugOut_L3 : std_logic_vector(31 downto 0);
	signal pixelCntDebugOut_L4 : std_logic_vector(31 downto 0);
	signal pixelBufferRdySig   : std_logic;
	signal fastModePixelData   : std_logic_vector(31 downto 0);
    signal rdRdy	           : std_logic_vector(3 downto 0);
    signal lsDebug             : std_logic_vector(3 downto 0);
    signal lsAdcConfig         : std_logic_vector(31 downto 0);
    signal bufferDebugSig      : std_logic_vector(31 downto 0);
    signal interrupt_reqSig    : std_logic;
	signal dmaDataDepthReg     : std_logic_vector(DMA_DATA_WIDTH-1 downto 0);
	signal WR_EN_rising        : std_logic;
	signal RD_REQ_rising     : std_logic;
	signal RESET               : std_logic;
    --I/O SIGNALS
    signal MST_o       : std_logic;
    signal MCLK_o      : std_logic;
    signal L1_PCLK_i   : std_logic;
    signal L1_SYNC_i   : std_logic;
    signal L1_DOUT_i   : std_logic_vector(11 downto 0);
    signal L1_MISO_i   : std_logic;
    signal L1_CS_o     : std_logic;
    signal L2_PCLK_i   : std_logic;
    signal L2_SYNC_i   : std_logic;
    signal L2_DOUT_i   : std_logic_vector(11 downto 0);
    signal L2_MISO_i   : std_logic;
    signal L2_CS_o     : std_logic;
    signal L3_PCLK_i   : std_logic;
    signal L3_SYNC_i   : std_logic;
    signal L3_DOUT_i   : std_logic_vector(11 downto 0);
    signal L3_MISO_i   : std_logic;
    signal L3_CS_o     : std_logic;
    signal L4_PCLK_i   : std_logic;
    signal L4_SYNC_i   : std_logic;
    signal L4_DOUT_i   : std_logic_vector(11 downto 0);
    signal L4_MISO_i   : std_logic;
    signal L4_CS_o     : std_logic;
    signal SCLK_o       : std_logic;
    signal MOSI_o       : std_logic;
    --STROBE SIGNALS
    signal fastModePixelDataReadReq : std_logic;

	component DirectionChange is port(
        RESETN			: in std_logic;
        CLK				: in std_logic;
        DIR				: in std_logic;  -- direction control
        ON_CHIP_TRI 	: out std_logic;  -- tri-state control for FPGA buffer
        EXTERNAL_TRI	: out std_logic  -- tri-state control for external buffer
    );  	 
    end component DirectionChange;

begin
    RESET <= not RESETN;
	--outputs
	--RD_VALID		<= RD_REQ_DELAY(2);
	RD_DATA			<= reg_data_out;
	DMA_DATA_DEPTH	<= dmaDataDepthReg;
	interrupt_req   <= interrupt_reqSig;
	
	OneShot(WR_EN_rising,  WR_EN, WR_EN_DELAY(0), RESET, CLK_125MHZ, '1');
	OneShot(RD_VALID,  RD_REQ_DELAY(1),RD_REQ_DELAY(2), RESET, CLK_125MHZ, '1');
	
	soft_reset <= softReset;
		
	process (CLK_125MHZ)
	begin
	  if rising_edge(CLK_125MHZ) then 
	    if RESETN = '0' or softReset = '1' then
			softReset <= '0';
			FPGA_ID <= x"671";
			DIFF_IO_LA_i_o <= (others => '0');
			DIFF_IO_LA_HA_i_o <= (others => '0');
			DIFF_IO_HB_i_o <= (others => '0');
			DIFF_DIR_LA_reg <= x"00001170";
			DIFF_DIR_LA_HA_reg <= x"00000100";
			DIFF_DIR_HB_reg <= x"00080008";
			halfClkPerIn <= x"00000007";
			mstHighTimeIn <= x"00003E12";
			mstLowTimeIn <= x"0000038E";
			spiConfigIn <= x"00000F03"; --15 clock cycles (125MHz) per half period SCLK (125/(25*2) MHz); CPOL/CPHA: 1,1
			spiRwCtrlIn <= (others => '0');
			pixelNumSelIn_L1 <= (others => '0');
			pixelNumSelIn_L2 <= (others => '0');
			pixelNumSelIn_L3 <= (others => '0');
			pixelNumSelIn_L4 <= (others => '0');
			lsAdcConfig <= (others  => '0');
			ctrlRegIn <= (others  => '0');
			dmaDataDepthReg <= b"0000010000000000";
			interrupt_reqSig <= '0';

	    else
	      if (WR_EN_rising = '1') then
	        case REG_ADDR is
			  when x"00" => -- Board status and software reset
				softReset <= WR_DATA(31);
				interrupt_reqSig <= WR_DATA(0);
				
			  when x"01" => -- LA DIFF IO 
	            DIFF_IO_LA_i_o(31 downto 0) <= WR_DATA(31 downto 0);
				
	          when x"02" => -- LA HA DIFF IO 
	            DIFF_IO_LA_HA_i_o(31 downto 0) <= WR_DATA(31 downto 0);
			
	          when x"03" => -- HB DIFF IO
	            DIFF_IO_HB_i_o(31 downto 0) <= WR_DATA(31 downto 0);
				
			  when x"04" => --LA IO DIR
	            DIFF_DIR_LA_reg(31 downto 0) <= WR_DATA(31 downto 0);
				
			  when x"05" => -- LA HA IO DIR
	            DIFF_DIR_LA_HA_reg(31 downto 0) <= WR_DATA(31 downto 0);
				
	          when x"06" => -- HB IO DIR
	            DIFF_DIR_HB_reg(31 downto 0) <= WR_DATA(31 downto 0);
				
	          when x"07" => -- Half Clk Period of LS
	            halfClkPerIn(31 downto 0) <= WR_DATA(31 downto 0);
				
			  when x"08" => -- MST High Time
	            mstHighTimeIn(31 downto 0) <= WR_DATA(31 downto 0);
				
	          when x"09" =>  -- MST Low Time
	            mstLowTimeIn(31 downto 0) <= WR_DATA(31 downto 0);
				
	          when x"0A" =>  -- LS Control/Status(bit0:master enable, bit1:PC ReadACK, bit4-6:LS mode, bit7: LS buffer Ready [RO], bit8-11:LS1-4 Read Ready [RO])
	            if (WR_DATA(1) = '1') then
	               ctrlRegIn(1) <= WR_DATA(1);
	            else
	               ctrlRegIn(31 downto 12) <= WR_DATA(31 downto 12);
	               ctrlRegIn(6 downto 0)   <= WR_DATA(6 downto 0);
	            end if;
	            
			  when x"0B" => --L1 Pixel number select
	            pixelNumSelIn_L1(9 downto 0) <= WR_DATA(9 downto 0);
				  
			  when x"0C" => -- L2 Pixel number select
	            pixelNumSelIn_L2(9 downto 0) <= WR_DATA(9 downto 0);
				
	          when x"0D" =>  -- L3 Pixel number select
	            pixelNumSelIn_L3(9 downto 0) <= WR_DATA(9 downto 0);
				
	          when x"0E" =>  -- L4 Pixel number select
	            pixelNumSelIn_L4(9 downto 0) <= WR_DATA(9 downto 0);
			  
			  when x"1F" =>  -- SPI Config Reg
	            spiConfigIn(31 downto 0) <= WR_DATA(31 downto 0);
				
			  when x"20" =>  -- SPI R/W Control 
	            spiRwCtrlIn(31 downto 0) <= WR_DATA(31 downto 0);
	            	
			  when x"26" =>  -- LS ADC CONFIG
	            lsAdcConfig(31 downto 0) <= WR_DATA(31 downto 0);
			  
			  when x"29" => --DMA Data Depth
				dmaDataDepthReg <= WR_DATA(DMA_DATA_WIDTH-1 downto 0);
			

	          when others => null;
				-- softReset <= softReset;
				-- DIFF_IO_LA_i_o
				-- DIFF_IO_LA_HA_i_o
				-- DIFF_IO_HB_i_o
				-- DIFF_DIR_LA
				-- DIFF_DIR_LA_HA
				-- DIFF_DIR_HB
	            -- testRegister0 <= testRegister0;
				-- testRegister1 <= testRegister1;
				-- testRegister2 <= testRegister2;
				-- testRegister3 <= testRegister3;
	        end case;
		  else 
		        interrupt_reqSig <= '0';
				ctrlRegIn(1) <= '0'; --clears bit after 1 clock cycle
		  end if;
	    end if;
	  end if;                   
	end process; 
	
	process (FPGA_ID,DIFF_IO_LA_i,DIFF_IO_HA_i,DIFF_IO_HB_i,DIFF_DIR_LA_reg,DIFF_DIR_LA_HA_reg,DIFF_DIR_HB_reg,
	halfClkPerIn, mstHighTimeIn, mstLowTimeIn, spiConfigIn, spiRwCtrlIn, spiStartPixelOut, spiReadoutPixelsOut,
	spiSkippedPixelsOut, spiOffsetShiftOut, ctrlRegIn, pixelNumSelIn_L1, pixelNumSelIn_L2, pixelNumSelIn_L3,
	pixelNumSelIn_L4, pixelValueOut_L1, pixelValueOut_L2, pixelValueOut_L3, pixelValueOut_L4,
	pixelValueAuxOut_L1, pixelValueAuxOut_L2, pixelValueAuxOut_L3, pixelValueAuxOut_L4, pixelNumDebugOut_L1,
	pixelNumDebugOut_L2, pixelNumDebugOut_L3, pixelNumDebugOut_L4, pixelCntDebugOut_L1, pixelCntDebugOut_L2,
	pixelCntDebugOut_L3, pixelCntDebugOut_L4, RESETN,lsAdcConfig,fastModePixelData, REG_ADDR,
	rdRdy,pixelBufferRdySig,lsDebug,bufferDebugSig)
	begin
	  if RESETN = '0' then
	    reg_data_out  <= (others => '0');
	  else
	    case REG_ADDR is
	      when x"00" => -- Board status, software reset and force interrupt request
	        reg_data_out <= x"0000" & "000" & FPGA_ID & interrupt_reqSig;
	      when x"01" => -- LA DIFF IO
	        reg_data_out <= DIFF_IO_LA_i(31 downto 0);
	      when x"02" => -- LA HA DIFF IO
	        reg_data_out <= b"000000" & DIFF_IO_LA_i(33 downto 32) & DIFF_IO_HA_i;
	      when x"03" => -- HB DIFF IO
	        reg_data_out <= x"00" & b"00" & DIFF_IO_HB_i(21 downto 0);
		  when x"04" => -- LA IO DIR
	        reg_data_out <= DIFF_DIR_LA_reg;
	      when x"05" => -- LA HA IO DIR
	        reg_data_out <= DIFF_DIR_LA_HA_reg;
	      when x"06" => -- HB IO DIR
	        reg_data_out <= DIFF_DIR_HB_reg;
			
	      when x"07" => -- Half Clk Period of LS
	        reg_data_out <= halfClkPerIn;
		  when x"08" => -- MST High Time
	        reg_data_out <= mstHighTimeIn;
	      when x"09" => -- MST Low Time 
	        reg_data_out <= mstLowTimeIn;
	      when x"0A" => -- LS Control/Status(bit0:master enable, bit1:PC ReadACK, bit4-6:LS mode, bit7: LS buffer Ready [RO], bit8-11:LS1-4 Read Ready [RO])
	        reg_data_out <= ctrlRegIn(31 downto 12) & rdRdy & pixelBufferRdySig & ctrlRegIn(6 downto 0);
		    	
		  when x"0B" => -- L1 Pixel number select
	        reg_data_out <= x"00000" & b"00" & pixelNumSelIn_L1;
		  when x"0C" => -- L2 Pixel number select
	        reg_data_out <= x"00000" & b"00" &  pixelNumSelIn_L2;
		  when x"0D" => -- L3 Pixel number select
	        reg_data_out <= x"00000" & b"00" &  pixelNumSelIn_L3;
		  when x"0E" => -- L4 Pixel number select
	        reg_data_out <= x"00000" & b"00" &  pixelNumSelIn_L4;
			
		  when x"0F" => -- L1 Pixel value select
	        reg_data_out <= x"00000" & pixelValueOut_L1;
		  when x"10" => -- L2 Pixel value select
	        reg_data_out <= x"00000" & pixelValueOut_L2;
		  when x"11" => -- L3 Pixel value select
	        reg_data_out <= x"00000" & pixelValueOut_L3;
		  when x"12" => -- L4 Pixel value select
	        reg_data_out <= x"00000" & pixelValueOut_L4;
			
		  when x"13" => -- L1 Pixel value aux select
	        reg_data_out <= x"00000" & pixelValueAuxOut_L1;
		  when x"14" => -- L2 Pixel value aux select
	        reg_data_out <= x"00000" & pixelValueAuxOut_L2;
		  when x"15" => -- L3 Pixel value aux select
	        reg_data_out <= x"00000" & pixelValueAuxOut_L3;
		  when x"16" => -- L4 Pixel value aux select
	        reg_data_out <= x"00000" & pixelValueAuxOut_L4;
			
		  when x"17" => -- L1 Pixel value debug
	        reg_data_out <= pixelNumDebugOut_L1;
		  when x"18" => -- L2 Pixel value debug
	        reg_data_out <= pixelNumDebugOut_L2;
		  when x"19" => -- L3 Pixel value debug
	        reg_data_out <= pixelNumDebugOut_L3;
		  when x"1A" => -- L4 Pixel value debug
	        reg_data_out <= pixelNumDebugOut_L4;
		  
		  when x"1B" => -- L1 Pixel count debug
	        reg_data_out <= pixelCntDebugOut_L1;
		  when x"1C" => -- L2 Pixel count debug
	        reg_data_out <= pixelCntDebugOut_L2;
		  when x"1D" => -- L3 Pixel count debug
	        reg_data_out <= pixelCntDebugOut_L3;
		  when x"1E" => -- L4 Pixel count debug
	        reg_data_out <= pixelCntDebugOut_L4;
			
		  when x"1F" => -- SPI Config Reg
	        reg_data_out <= spiConfigIn;
		  when x"20" => -- SPI R/W Control 
	        reg_data_out <= spiRwCtrlIn;
	      when x"21" => -- SPI Start Pixel Reg
	        reg_data_out <= spiStartPixelOut;
		  when x"22" => -- SPI Total readout Reg
	        reg_data_out <= spiReadoutPixelsOut;
		  when x"23" => -- SPI Skipped pixels reg 
	        reg_data_out <= spiSkippedPixelsOut;
	      when x"24" => -- SPI offset Reg
	        reg_data_out <= spiOffsetShiftOut;
	          
		  when x"25" => --debug register
		    reg_data_out <= x"0000000" & lsDebug;
		  when x"26" => --LS ADC Config register
		    reg_data_out <= lsAdcConfig;
		  when x"27" => --LS Fast Mode Pixel Data register
		    reg_data_out <= fastModePixelData;
		  when x"28" =>
		    reg_data_out <= bufferDebugSig;
		  when x"29" =>
		    reg_data_out <= x"0000" & dmaDataDepthReg;
	      when others =>
	        reg_data_out  <= (others => '0');
	    end case;
	  end if;
	end process; 
	
	process( CLK_125MHZ ) is
	begin
	  if (rising_edge (CLK_125MHZ)) then
	    if ( RESETN = '0' ) then
			WR_EN_DELAY  <= (others => '0');
			RD_REQ_DELAY <= (others => '0');
	 
		else
			WR_EN_DELAY(1) <= WR_EN_DELAY(0);
			WR_EN_DELAY(0) <= WR_EN;
			RD_REQ_DELAY(2 downto 1) <= RD_REQ_DELAY(1 downto 0);
			RD_REQ_DELAY(0) <= RD_REQ;
	    end if;
	  end if;
	end process;
	
	-- Strobe Generation
	process( CLK_125MHZ ) is
	begin 
	  if (rising_edge (CLK_125MHZ)) then
	    if ( RESETN = '0' ) then
	      fastModePixelDataReadReq  <= '0';
	      spiLsEnIn <= '0';
	      
	    else
	      if (RD_REQ = '1' and REG_ADDR = x"27") then --STROBE Generation for LS Buffer Reads
	          fastModePixelDataReadReq <= '1';
	      else
	          fastModePixelDataReadReq <= '0'; 
	      end if; 
	      
          if (WR_EN_DELAY(1) = '1' and REG_ADDR = x"1F" and spiConfigIn(7) = '1') then 
              spiLsEnIn <= '1';
          else
              spiLsEnIn <= '0';
          end if;
       
	    end if;
	  end if;
	end process;
	
	-- control timing of cascaded bi-dir buffer tri-state signals to prevent contention
	gen_DIFF_LA_TS : for i in 0 to 31 generate
		DIFF_LA_TS : DirectionChange 
		port map(
			RESETN => RESETN,
			CLK => CLK_125MHZ,
			DIR => DIFF_DIR_LA_reg(i),	-- register
			ON_CHIP_TRI => DIFF_IO_LA_t(i), -- FPGA I/O buffer direction control
			EXTERNAL_TRI => DIFF_DIR_LA(i) -- external bi-dir buffer control
		);
	end generate;
	
	gen_DIFF_LA_32_33_TS : for i in 32 to 33 generate
		DIFF_LA_32_33_TS : DirectionChange 
		port map(
			RESETN => RESETN,
			CLK => CLK_125MHZ,
			DIR => DIFF_DIR_LA_HA_reg(i-8),	-- register
			ON_CHIP_TRI => DIFF_IO_LA_t(i), -- FPGA I/O buffer direction control
			EXTERNAL_TRI => DIFF_DIR_LA(i) -- external bi-dir buffer control
		);
	end generate;
	
	gen_DIFF_HA_TS : for i in 0 to 23 generate
		DIFF_HA_TS : DirectionChange 
		port map(
			RESETN => RESETN,
			CLK => CLK_125MHZ,
			DIR => DIFF_DIR_LA_HA_reg(i),	-- register
			ON_CHIP_TRI => DIFF_IO_HA_t(i), -- FPGA I/O buffer direction control
			EXTERNAL_TRI => DIFF_DIR_HA(i) -- external bi-dir buffer control
		);
	end generate;
	
	gen_DIFF_HB_TS : for i in 0 to 21 generate
		DIFF_HB_TS : DirectionChange 
		port map(
			RESETN => RESETN,
			CLK => CLK_125MHZ,
			DIR => DIFF_DIR_HB_reg(i),	-- register
			ON_CHIP_TRI => DIFF_IO_HB_t(i), -- FPGA I/O buffer direction control
			EXTERNAL_TRI => DIFF_DIR_HB(i) -- external bi-dir buffer control
		);
	end generate;
-----------------------------------------------------------------------	
--FMC OUTPUTS. DEFAULT IS SET TO REGISTER/SOFTWARE CONTROL
--REPLACE RIGHT SIDE OF SIGNAL MAPPING FOR SIGNALS CONTROLLED IN FPGA
-----------------------------------------------------------------------	
	DIFF_IO_LA_o(0) <= DIFF_IO_LA_i_o(0);
	DIFF_IO_LA_o(1) <= DIFF_IO_LA_i_o(1);
	DIFF_IO_LA_o(2) <= DIFF_IO_LA_i_o(2);
	DIFF_IO_LA_o(3) <= DIFF_IO_LA_i_o(3);
	DIFF_IO_LA_o(4) <= SCLK_o;--DIFF_IO_LA_i_o(4);
	DIFF_IO_LA_o(5) <= MCLK_o;--DIFF_IO_LA_i_o(5);
	DIFF_IO_LA_o(6) <= MST_o;--DIFF_IO_LA_i_o(6);
	DIFF_IO_LA_o(7) <= DIFF_IO_LA_i_o(7);
	DIFF_IO_LA_o(8) <= L4_CS_o;--DIFF_IO_LA_i_o(8);
	DIFF_IO_LA_o(9) <= DIFF_IO_LA_i_o(9);
	DIFF_IO_LA_o(10) <= DIFF_IO_LA_i_o(10);
	DIFF_IO_LA_o(11) <= DIFF_IO_LA_i_o(11);
	DIFF_IO_LA_o(12) <= L3_CS_o;--DIFF_IO_LA_i_o(12);
	DIFF_IO_LA_o(13) <= DIFF_IO_LA_i_o(13);
	DIFF_IO_LA_o(14) <= DIFF_IO_LA_i_o(14);
	DIFF_IO_LA_o(15) <= DIFF_IO_LA_i_o(15);
	DIFF_IO_LA_o(16) <= DIFF_IO_LA_i_o(16);
	DIFF_IO_LA_o(17) <= DIFF_IO_LA_i_o(17);
	DIFF_IO_LA_o(18) <= DIFF_IO_LA_i_o(18);
	DIFF_IO_LA_o(19) <= DIFF_IO_LA_i_o(19);
	DIFF_IO_LA_o(20) <= DIFF_IO_LA_i_o(20);
	DIFF_IO_LA_o(21) <= DIFF_IO_LA_i_o(21);
	DIFF_IO_LA_o(22) <= DIFF_IO_LA_i_o(22);
	DIFF_IO_LA_o(23) <= DIFF_IO_LA_i_o(23);
	DIFF_IO_LA_o(24) <= DIFF_IO_LA_i_o(24);
	DIFF_IO_LA_o(25) <= DIFF_IO_LA_i_o(25);
	DIFF_IO_LA_o(26) <= DIFF_IO_LA_i_o(26);
	DIFF_IO_LA_o(27) <= DIFF_IO_LA_i_o(27);
	DIFF_IO_LA_o(28) <= DIFF_IO_LA_i_o(28);
	DIFF_IO_LA_o(29) <= DIFF_IO_LA_i_o(29);
	DIFF_IO_LA_o(30) <= DIFF_IO_LA_i_o(30);
	DIFF_IO_LA_o(31) <= DIFF_IO_LA_i_o(31);
	DIFF_IO_LA_o(32) <= DIFF_IO_LA_HA_i_o(24);
	DIFF_IO_LA_o(33) <= DIFF_IO_LA_HA_i_o(25);
	
	DIFF_IO_HA_o(0) <= DIFF_IO_LA_HA_i_o(0);
	DIFF_IO_HA_o(1) <= DIFF_IO_LA_HA_i_o(1);
	DIFF_IO_HA_o(2) <= DIFF_IO_LA_HA_i_o(2);
	DIFF_IO_HA_o(3) <= DIFF_IO_LA_HA_i_o(3);
	DIFF_IO_HA_o(4) <= DIFF_IO_LA_HA_i_o(4);
	DIFF_IO_HA_o(5) <= DIFF_IO_LA_HA_i_o(5);
	DIFF_IO_HA_o(6) <= DIFF_IO_LA_HA_i_o(6);
	DIFF_IO_HA_o(7) <= DIFF_IO_LA_HA_i_o(7);
	DIFF_IO_HA_o(8) <= MOSI_o;--DIFF_IO_LA_HA_i_o(8);
	DIFF_IO_HA_o(9) <= DIFF_IO_LA_HA_i_o(9);
	DIFF_IO_HA_o(10) <= DIFF_IO_LA_HA_i_o(10);
	DIFF_IO_HA_o(11) <= DIFF_IO_LA_HA_i_o(11);
	DIFF_IO_HA_o(12) <= DIFF_IO_LA_HA_i_o(12);
	DIFF_IO_HA_o(13) <= DIFF_IO_LA_HA_i_o(13);
	DIFF_IO_HA_o(14) <= DIFF_IO_LA_HA_i_o(14);
	DIFF_IO_HA_o(15) <= DIFF_IO_LA_HA_i_o(15);
	DIFF_IO_HA_o(16) <= DIFF_IO_LA_HA_i_o(16);
	DIFF_IO_HA_o(17) <= DIFF_IO_LA_HA_i_o(17);
	DIFF_IO_HA_o(18) <= DIFF_IO_LA_HA_i_o(18);
	DIFF_IO_HA_o(19) <= DIFF_IO_LA_HA_i_o(19);
	DIFF_IO_HA_o(20) <= DIFF_IO_LA_HA_i_o(20);
	DIFF_IO_HA_o(21) <= DIFF_IO_LA_HA_i_o(21);
	DIFF_IO_HA_o(22) <= DIFF_IO_LA_HA_i_o(22);
	DIFF_IO_HA_o(23) <= DIFF_IO_LA_HA_i_o(23);
	
	DIFF_IO_HB_o(0) <= DIFF_IO_HB_i_o(0);
	DIFF_IO_HB_o(1) <= DIFF_IO_HB_i_o(1);
	DIFF_IO_HB_o(2) <= DIFF_IO_HB_i_o(2);
	DIFF_IO_HB_o(3) <= L1_CS_o;--DIFF_IO_HB_i_o(3);
	DIFF_IO_HB_o(4) <= DIFF_IO_HB_i_o(4);
	DIFF_IO_HB_o(5) <= DIFF_IO_HB_i_o(5);
	DIFF_IO_HB_o(6) <= DIFF_IO_HB_i_o(6);
	DIFF_IO_HB_o(7) <= DIFF_IO_HB_i_o(7);
	DIFF_IO_HB_o(8) <= DIFF_IO_HB_i_o(8);
	DIFF_IO_HB_o(9) <= DIFF_IO_HB_i_o(9);
	DIFF_IO_HB_o(10) <= DIFF_IO_HB_i_o(10);
	DIFF_IO_HB_o(11) <= DIFF_IO_HB_i_o(11);
	DIFF_IO_HB_o(12) <= DIFF_IO_HB_i_o(12);
	DIFF_IO_HB_o(13) <= DIFF_IO_HB_i_o(13);
	DIFF_IO_HB_o(14) <= DIFF_IO_HB_i_o(14);
	DIFF_IO_HB_o(15) <= DIFF_IO_HB_i_o(15);
	DIFF_IO_HB_o(16) <= DIFF_IO_HB_i_o(16);
	DIFF_IO_HB_o(17) <= DIFF_IO_HB_i_o(17);
	DIFF_IO_HB_o(18) <= DIFF_IO_HB_i_o(18);
	DIFF_IO_HB_o(19) <= L2_CS_o; --DIFF_IO_HB_i_o(19);
	DIFF_IO_HB_o(20) <= DIFF_IO_HB_i_o(20);
	DIFF_IO_HB_o(21) <= DIFF_IO_HB_i_o(21);
	
---------------------------------------------------------	
--FMC INPUTS. UNCOMMENT AND ADD FPGA CONTROLLED----------
--SIGNALS ON LEFT SIDE OF MAPPING------------------------
--------------------------------------------------------- 	

	L4_DOUT_i(3) <= DIFF_IO_LA_i(0);
--	<= DIFF_IO_LA_i(1);
	L4_DOUT_i(8) <= DIFF_IO_LA_i(2);
	L4_PCLK_i <= DIFF_IO_LA_i(3);
--	<= DIFF_IO_LA_i(4);
--	<= DIFF_IO_LA_i(5);
--	<= DIFF_IO_LA_i(6);
--	<= DIFF_IO_LA_i(7);
--	<= DIFF_IO_LA_i(8);
	L4_SYNC_i <= DIFF_IO_LA_i(9);
	L4_DOUT_i(0) <= DIFF_IO_LA_i(10);
	L1_DOUT_i(10)<= DIFF_IO_LA_i(11);
--	<= DIFF_IO_LA_i(12);
	L1_DOUT_i(8) <= DIFF_IO_LA_i(13);
	L1_DOUT_i(9) <= DIFF_IO_LA_i(14);
	L1_DOUT_i(3) <= DIFF_IO_LA_i(15);
	L1_DOUT_i(2) <= DIFF_IO_LA_i(16);
	L1_DOUT_i(5) <= DIFF_IO_LA_i(17);
	L1_PCLK_i <= DIFF_IO_LA_i(18);
--	<= DIFF_IO_LA_i(19);
--	<= DIFF_IO_LA_i(20);
--	<= DIFF_IO_LA_i(21);
	L2_DOUT_i(0) <= DIFF_IO_LA_i(22);
	L2_DOUT_i(9) <= DIFF_IO_LA_i(23);
	L2_DOUT_i(3) <= DIFF_IO_LA_i(24);
--	<= DIFF_IO_LA_i(25);
--	<= DIFF_IO_LA_i(26);
	L2_PCLK_i <= DIFF_IO_LA_i(27);
	L2_MISO_i <= DIFF_IO_LA_i(28);
	L3_DOUT_i(6) <= DIFF_IO_LA_i(29);
	L3_DOUT_i(3) <= DIFF_IO_LA_i(30);
	L3_SYNC_i <= DIFF_IO_LA_i(31);
	L3_DOUT_i(10) <= DIFF_IO_LA_i(32);
	L3_DOUT_i(7) <= DIFF_IO_LA_i(33);
	
	L4_DOUT_i(1) <= DIFF_IO_HA_i(0);
	L4_DOUT_i(2) <= DIFF_IO_HA_i(1);
	L4_DOUT_i(10)<= DIFF_IO_HA_i(2);
	L4_DOUT_i(5) <= DIFF_IO_HA_i(3);
	L4_DOUT_i(4) <= DIFF_IO_HA_i(4);
	L4_MISO_i <= DIFF_IO_HA_i(5);
	L1_DOUT_i(0) <= DIFF_IO_HA_i(6);
	L4_DOUT_i(7) <= DIFF_IO_HA_i(7);
--	<= DIFF_IO_HA_i(8);
	L4_DOUT_i(9) <= DIFF_IO_HA_i(9);
	L4_DOUT_i(11)<= DIFF_IO_HA_i(10);
	L4_DOUT_i(6) <= DIFF_IO_HA_i(11);
--	<= DIFF_IO_HA_i(12);
	L1_DOUT_i(11) <= DIFF_IO_HA_i(13);
	L3_MISO_i <= DIFF_IO_HA_i(14);
	L3_DOUT_i(1) <= DIFF_IO_HA_i(15);
	L1_DOUT_i(6) <= DIFF_IO_HA_i(16);
	L3_DOUT_i(2) <= DIFF_IO_HA_i(17);
	L1_DOUT_i(7) <= DIFF_IO_HA_i(18);
	L1_MISO_i <= DIFF_IO_HA_i(19);
	L1_SYNC_i <= DIFF_IO_HA_i(20);
	L2_DOUT_i(7) <= DIFF_IO_HA_i(21);
	L2_DOUT_i(10)<= DIFF_IO_HA_i(22);
	L1_DOUT_i(4) <= DIFF_IO_HA_i(23);
	
--	<= DIFF_IO_HB_i(0);
--	<= DIFF_IO_HB_i(1);
	L2_DOUT_i(8) <= DIFF_IO_HB_i(2);
--	<= DIFF_IO_HB_i(3);
	L2_SYNC_i <= DIFF_IO_HB_i(4);
	L1_DOUT_i(1) <= DIFF_IO_HB_i(5);
--	<= DIFF_IO_HB_i(6);
--	<= DIFF_IO_HB_i(7);
	L2_DOUT_i(5) <= DIFF_IO_HB_i(8);
	L2_DOUT_i(6) <= DIFF_IO_HB_i(9);
	L2_DOUT_i(2) <= DIFF_IO_HB_i(10);
	L2_DOUT_i(4) <= DIFF_IO_HB_i(11);
	L3_DOUT_i(0) <= DIFF_IO_HB_i(12);
	L2_DOUT_i(11) <= DIFF_IO_HB_i(13);
	L3_PCLK_i <= DIFF_IO_HB_i(14);
	L3_DOUT_i(5) <= DIFF_IO_HB_i(15);
	L3_DOUT_i(11)<= DIFF_IO_HB_i(16);
	L3_DOUT_i(9) <= DIFF_IO_HB_i(17);
	L3_DOUT_i(8) <= DIFF_IO_HB_i(18);
--	<= DIFF_IO_HB_i(19);
	L3_DOUT_i(4) <= DIFF_IO_HB_i(20);
	L2_DOUT_i(1) <= DIFF_IO_HB_i(21);
	

wAvisTop_inst : entity WAVIS_LIB.wAvisTop(rtl)
    port map (
        RESETN => RESETN,--  : in std_logic;
        CLK => CLK_125MHZ,--     : in std_logic;
        SOFT_RST => softReset,
        --REGISTER SIGNALS
        halfClkPerIn => halfClkPerIn,--        : in std_logic_vector(31 downto 0);
        mstHighTimeIn => mstHighTimeIn,--       : in std_logic_vector(31 downto 0);
        mstLowTimeIn => mstLowTimeIn,--        : in std_logic_vector(31 downto 0);
        spiConfigIn => spiConfigIn(27 downto 0),--         : in std_logic_vector(27 downto 0);
        spiRwCtrlIn => spiRwCtrlIn,--         : in std_logic_vector(31 downto 0);
        spiStartPixelOut => spiStartPixelOut,--    : out std_logic_vector(31 downto 0);
        spiReadoutPixelsOut => spiReadoutPixelsOut,-- : out std_logic_vector(31 downto 0);
        spiSkippedPixelsOut => spiSkippedPixelsOut,-- : out std_logic_vector(31 downto 0);
        spiOffsetShiftOut => spiOffsetShiftOut,--   : out std_logic_vector(31 downto 0);
        spiLsEnIn => spiLsEnIn,
        ctrlRegIn => ctrlRegIn,--          : in std_logic_vector(31 downto 0);
        pixelNumSelIn_L1 => pixelNumSelIn_L1,--    : in std_logic_vector(9 downto 0);
		pixelNumSelIn_L2 => pixelNumSelIn_L2,--    : in std_logic_vector(9 downto 0);
		pixelNumSelIn_L3 => pixelNumSelIn_L3,--    : in std_logic_vector(9 downto 0);
		pixelNumSelIn_L4 => pixelNumSelIn_L4,--    : in std_logic_vector(9 downto 0);
		pixelValueOut_L1 => pixelValueOut_L1,--    : out std_logic_vector(DATA_WIDTH-1 downto 0);
		pixelValueOut_L2 => pixelValueOut_L2,--    : out std_logic_vector(DATA_WIDTH-1 downto 0);
		pixelValueOut_L3 => pixelValueOut_L3,--    : out std_logic_vector(DATA_WIDTH-1 downto 0);
		pixelValueOut_L4 => pixelValueOut_L4,--    : out std_logic_vector(DATA_WIDTH-1 downto 0);
		pixelValueAuxOut_L1 => pixelValueAuxOut_L1,-- : out std_logic_vector(DATA_WIDTH-1 downto 0);
		pixelValueAuxOut_L2 => pixelValueAuxOut_L2,-- : out std_logic_vector(DATA_WIDTH-1 downto 0);
		pixelValueAuxOut_L3 => pixelValueAuxOut_L3,-- : out std_logic_vector(DATA_WIDTH-1 downto 0);
		pixelValueAuxOut_L4 => pixelValueAuxOut_L4,-- : out std_logic_vector(DATA_WIDTH-1 downto 0);
		pixelNumDebugOut_L1 => pixelNumDebugOut_L1,-- : out std_logic_vector(31 downto 0);
		pixelNumDebugOut_L2 => pixelNumDebugOut_L2,-- : out std_logic_vector(31 downto 0);
		pixelNumDebugOut_L3 => pixelNumDebugOut_L3,-- : out std_logic_vector(31 downto 0);
		pixelNumDebugOut_L4 => pixelNumDebugOut_L4,-- : out std_logic_vector(31 downto 0);
		pixelCntDebugOut_L1 => pixelCntDebugOut_L1,-- : out std_logic_vector(31 downto 0);
		pixelCntDebugOut_L2 => pixelCntDebugOut_L2,-- : out std_logic_vector(31 downto 0);
		pixelCntDebugOut_L3 => pixelCntDebugOut_L3,-- : out std_logic_vector(31 downto 0);
		pixelCntDebugOut_L4 => pixelCntDebugOut_L4,-- : out std_logic_vector(31 downto 0);
        rdRdy => rdRdy,
        lsDebug => lsDebug,
        lsAdcConfig => lsAdcConfig,
        pixelBufferRdyOut => pixelBufferRdySig,
        fastModePixelDataReadReqIn => fastModePixelDataReadReq,
        fastModePixelDataOut  => fastModePixelData,
        bufferDebugOut => bufferDebugSig,
        --I/O SIGNALS
        MST_o => MST_o,--       : out std_logic;
        MCLK_o => MCLK_o,--      : out std_logic;
        L1_PCLK_i => L1_PCLK_i,--   : in std_logic;
        L1_SYNC_i => L1_SYNC_i,--   : in std_logic;
        L1_DOUT_i => L1_DOUT_i,--   : in std_logic_vector(11 downto 0);
        L1_MISO_i => L1_MISO_i,--   : in std_logic;
        L1_CS_o => L1_CS_o,--     : out std_logic;
        L2_PCLK_i => L2_PCLK_i,--   : in std_logic;
        L2_SYNC_i => L2_SYNC_i,--   : in std_logic;
        L2_DOUT_i => L2_DOUT_i,--   : in std_logic_vector(11 downto 0);
        L2_MISO_i => L2_MISO_i,--   : in std_logic;
        L2_CS_o => L2_CS_o,--     : out std_logic;
        L3_PCLK_i => L3_PCLK_i,--   : in std_logic;
        L3_SYNC_i => L3_SYNC_i,--   : in std_logic;
        L3_DOUT_i => L3_DOUT_i,--   : in std_logic_vector(11 downto 0);
        L3_MISO_i => L3_MISO_i,--   : in std_logic;
        L3_CS_o => L3_CS_o,--     : out std_logic;
        L4_PCLK_i => L4_PCLK_i,--   : in std_logic;
        L4_SYNC_i => L4_SYNC_i,--   : in std_logic;
        L4_DOUT_i => L4_DOUT_i,--   : in std_logic_vector(11 downto 0);
        L4_MISO_i => L4_MISO_i,--   : in std_logic;
        L4_CS_o => L4_CS_o,--     : out std_logic;
        SCLK => SCLK_o,--        : out std_logic;
        MOSI => MOSI_o,--        : out std_logic
		--DMA signals
		DMA_START => DMA_START,
		DMA_DATA  => DMA_DATA,
		DMA_DATA_ADDR => DMA_DATA_ADDR,
		DMA_DATA_WR_EN => DMA_DATA_WR_EN
    );	
end arch_imp;
