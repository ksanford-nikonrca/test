library ieee;           use ieee.std_logic_1164.all;
                        use ieee.std_logic_unsigned.all;
                        use ieee.numeric_std.all;
library WAVIS_LIB; use WAVIS_LIB.wAvisPackage.all;
                        use WAVIS_LIB.standard_pack.all;
						

entity dmaSignalsGenerator is
	port (
		CLK     : in std_logic;
		RESET	: in std_logic;
		
		ctrlRegIn		: in std_logic_vector(31 downto 0);
		dataStrobeSig   : in std_logic;
		newDataIdxSig   : in unsigned(ADDR_WIDTH-1 downto 0);
		fifoDataLSxSig  : in lsPixelDataArrayType;
		
		DMA_START		: out std_logic;								--strobe to indicate data from user IP is ready to be sent to DMA 
		DMA_DATA		: out std_logic_vector(63 downto 0);			--64 bit data from user IP blocks 
		DMA_DATA_ADDR	: out std_logic_vector(DMA_DATA_ADDR_WIDTH-1 downto 0);	--current addr to DMA block
		DMA_DATA_WR_EN	: out std_logic	
	);
end dmaSignalsGenerator;

architecture rtl of dmaSignalsGenerator is
	type pixelCounterFSM is (ST_RESET, WAIT_START, COUNT_STROBES, INCREMENT_COUNTER);
	signal pixelCounterState : pixelCounterFSM;
	
	signal frameCaptureSig		: std_logic;
	signal masterEnSigDelay	: std_logic;
	signal dmaStartSig		: std_logic;
	signal dmaDataSig		: std_logic_vector(COMBINED_PIXEL_DATA_WIDTH -1 downto 0);
	signal dmaDataWrEnSig	: std_logic;
	signal dmaDataWrEnSigR	: std_logic;
	signal newDataIdxSig_i  : unsigned(ADDR_WIDTH - 1 downto 0); 
	signal dataCounter		: unsigned(DMA_DATA_ADDR_WIDTH downto 0);
	signal dataValid        : std_logic_vector(3 downto 0);
	signal timeOutStrobe    : std_logic;
	signal timeOutCounter   : integer;
	signal timeOutStart     : std_logic;
begin
	--outputs
	DMA_START		<= frameCaptureSig and ctrlRegIn(31);
	DMA_DATA		<= dataValid & x"000" & dmaDataSig;
	DMA_DATA_ADDR	<= std_logic_vector(dataCounter(DMA_DATA_ADDR_WIDTH-1 downto 0));
	DMA_DATA_WR_EN	<= dmaDataWrEnSigR or timeOutStrobe;
	
	frameCaptureSig <= ctrlRegIn(1);
	FlipFlop(masterEnSigDelay, frameCaptureSig, '0', RESET, CLK);
	OneShot(dmaStartSig, frameCaptureSig, masterEnSigDelay, RESET, CLK, '1');
	
	--FlipFlop(dmaDataWrEnSig, dataStrobeSig, '0', RESET, CLK); --delay data strobe for one clock cycle
	--FlipFlop(newDataIdxSig_i, newDataIdxSig, b"0000000000", RESET, CLK); --delay data strobe for one clock cycle
	process (CLK)
	begin
		if rising_edge(CLK) then 
			if RESET = '1' then
				dmaDataSig <= (others => '0');
				dmaDataWrEnSig <= '0';
				dmaDataWrEnSigR <= '0';
				newDataIdxSig_i <= (others => '0');
				
			else
			    dmaDataWrEnSigR <= dmaDataWrEnSig;  
			    dmaDataWrEnSig <= dataStrobeSig;
			    newDataIdxSig_i <= newDataIdxSig;
				if (dataStrobeSig = '1') then
					dmaDataSig <= fifoDataLSxSig(3) & fifoDataLSxSig(2) & fifoDataLSxSig(1) & fifoDataLSxSig(0);
				end if;
			end if;
		end if;
	end process;
	
	process (CLK)
	begin
		if rising_edge(CLK) then 
			if RESET = '1' then
				pixelCounterState <= ST_RESET;
				dataCounter <= (others => '0');
				timeOutStart <= '0';
			else
				case pixelCounterState is
					when ST_RESET =>
						dataCounter <= (others => '0');	
						pixelCounterState <= WAIT_START;
						timeOutStart <= '0';
						
					when WAIT_START =>
						if (dmaStartSig = '1') then
						    timeOutStart <= '1';
							dataCounter <= (others => '0');
							pixelCounterState <= COUNT_STROBES;
						end if;
					
					when COUNT_STROBES =>
						if (dataCounter > NUMBER_OF_PIXELS-1) then
							pixelCounterState <= WAIT_START;
							timeOutStart <= '0';
						elsif (dmaDataWrEnSig = '1' or timeOutStrobe = '1') then
						    timeOutStart <= '0';
							pixelCounterState <= INCREMENT_COUNTER;
						end if;
					
					when INCREMENT_COUNTER =>
					   if (dataCounter > NUMBER_OF_PIXELS-1) then
							pixelCounterState <= WAIT_START;
							timeOutStart <= '0';
					    else
					        timeOutStart <= '1';
					        dataCounter <= dataCounter + 1;
					        pixelCounterState <= COUNT_STROBES;
					    end if;
					    
					when others => pixelCounterState <= ST_RESET;
				end case;
			end if;
		end if;
	end process;
	
	process (CLK)
	begin
		if rising_edge(CLK) then 
			if RESET = '1' then
			   dataValid <= "1010";
			   timeOutStrobe <= '0';
			   timeOutCounter <= 0;
			   
			else
			   if (timeOutStart = '0') then
			     dataValid <= "1010";
			     timeOutStrobe <= '0';
			     timeOutCounter <= 0;
			     
			   else
			     if (timeOutCounter >= 51) then
			         timeOutCounter <= 0;
			         timeOutStrobe <= '1';
			         dataValid <= (others => '0');
			     else
			         timeOutCounter <= timeOutCounter + 1;
			         timeOutStrobe <= '0';
			         dataValid <= "1010";
			     end if;
			   end if;
			end if;
		end if;
	end process;
	
end rtl;