library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

library WAVIS_LIB;
use  WAVIS_LIB.wAvisPackage.all;

-- Uncomment the following library declaration if instantiating
-- any Xilinx leaf cells in this code.
--library UNISIM;
--use UNISIM.VComponents.all;

entity wAvisTop is
port(
    RESETN  : in std_logic;
    CLK     : in std_logic;
    SOFT_RST: in std_logic;
    --REGISTER SIGNALS
    halfClkPerIn        : in std_logic_vector(31 downto 0);
    mstHighTimeIn       : in std_logic_vector(31 downto 0);
    mstLowTimeIn        : in std_logic_vector(31 downto 0);
    spiConfigIn         : in std_logic_vector(27 downto 0);
    spiRwCtrlIn         : in std_logic_vector(31 downto 0);
    spiStartPixelOut    : out std_logic_vector(31 downto 0);
    spiReadoutPixelsOut : out std_logic_vector(31 downto 0);
    spiSkippedPixelsOut : out std_logic_vector(31 downto 0);
    spiOffsetShiftOut   : out std_logic_vector(31 downto 0);
    spiLsEnIn           : in std_logic;
    ctrlRegIn           : in std_logic_vector(31 downto 0);
    pixelNumSelIn_L1    : in std_logic_vector(9 downto 0);
	pixelNumSelIn_L2    : in std_logic_vector(9 downto 0);
	pixelNumSelIn_L3    : in std_logic_vector(9 downto 0);
	pixelNumSelIn_L4    : in std_logic_vector(9 downto 0);
    pixelValueOut_L1    : out std_logic_vector(DATA_WIDTH-1 downto 0);
	pixelValueOut_L2    : out std_logic_vector(DATA_WIDTH-1 downto 0);
	pixelValueOut_L3    : out std_logic_vector(DATA_WIDTH-1 downto 0);
	pixelValueOut_L4    : out std_logic_vector(DATA_WIDTH-1 downto 0);
    pixelValueAuxOut_L1 : out std_logic_vector(DATA_WIDTH-1 downto 0);
	pixelValueAuxOut_L2 : out std_logic_vector(DATA_WIDTH-1 downto 0);
	pixelValueAuxOut_L3 : out std_logic_vector(DATA_WIDTH-1 downto 0);
	pixelValueAuxOut_L4 : out std_logic_vector(DATA_WIDTH-1 downto 0);
    pixelNumDebugOut_L1 : out std_logic_vector(31 downto 0);
	pixelNumDebugOut_L2 : out std_logic_vector(31 downto 0);
	pixelNumDebugOut_L3 : out std_logic_vector(31 downto 0);
	pixelNumDebugOut_L4 : out std_logic_vector(31 downto 0);
    pixelCntDebugOut_L1 : out std_logic_vector(31 downto 0);
    pixelCntDebugOut_L2 : out std_logic_vector(31 downto 0);
	pixelCntDebugOut_L3 : out std_logic_vector(31 downto 0);
	pixelCntDebugOut_L4 : out std_logic_vector(31 downto 0);
	rdRdy               : out std_logic_vector(3 downto 0);
	lsDebug             : out std_logic_vector(3 downto 0);
	lsAdcConfig         : in std_logic_vector(31 downto 0);
	pixelBufferRdyOut   : out std_logic;
	fastModePixelDataReadReqIn : in std_logic;
	fastModePixelDataOut: out std_logic_vector(31 downto 0);
	bufferDebugOut      : out std_logic_vector(31 downto 0);
    --I/O SIGNALS
    MST_o       : out std_logic;
    MCLK_o      : out std_logic;
    L1_PCLK_i   : in std_logic;
    L1_SYNC_i   : in std_logic;
    L1_DOUT_i   : in std_logic_vector(11 downto 0);
    L1_MISO_i   : in std_logic;
    L1_CS_o     : out std_logic;
    L2_PCLK_i   : in std_logic;
    L2_SYNC_i   : in std_logic;
    L2_DOUT_i   : in std_logic_vector(11 downto 0);
    L2_MISO_i   : in std_logic;
    L2_CS_o     : out std_logic;
    L3_PCLK_i   : in std_logic;
    L3_SYNC_i   : in std_logic;
    L3_DOUT_i   : in std_logic_vector(11 downto 0);
    L3_MISO_i   : in std_logic;
    L3_CS_o     : out std_logic;
    L4_PCLK_i   : in std_logic;
    L4_SYNC_i   : in std_logic;
    L4_DOUT_i   : in std_logic_vector(11 downto 0);
    L4_MISO_i   : in std_logic;
    L4_CS_o     : out std_logic;
    SCLK        : out std_logic;
    MOSI        : out std_logic;
	--DMA Signals
	DMA_START		: out std_logic;								--strobe to indicate data from user IP is ready to be sent to DMA 
	DMA_DATA		: out std_logic_vector(63 downto 0);			--64 bit data from user IP blocks 
	DMA_DATA_ADDR	: out std_logic_vector(DMA_DATA_ADDR_WIDTH-1 downto 0);	--current addr to DMA block
	DMA_DATA_WR_EN	: out std_logic									--strobe to enable 1 64 bit write to DMA block
	);
end wAvisTop;

architecture rtl of wAvisTop is

signal sensorSpiSel : std_logic_vector(1 downto 0);
signal SCLKin : std_logic_vector(3 downto 0);
signal MOSIin : std_logic_vector(3 downto 0);

signal spiStartPixel_L1 : std_logic_vector(31 downto 0);
signal spiStartPixel_L2 : std_logic_vector(31 downto 0);
signal spiStartPixel_L3 : std_logic_vector(31 downto 0);
signal spiStartPixel_L4 : std_logic_vector(31 downto 0);   

signal spiReadoutPixels_L1 : std_logic_vector(31 downto 0);
signal spiReadoutPixels_L2 : std_logic_vector(31 downto 0);
signal spiReadoutPixels_L3 : std_logic_vector(31 downto 0);
signal spiReadoutPixels_L4 : std_logic_vector(31 downto 0); 

signal spiSkippedPixels_L1 : std_logic_vector(31 downto 0);
signal spiSkippedPixels_L2 : std_logic_vector(31 downto 0);
signal spiSkippedPixels_L3 : std_logic_vector(31 downto 0);
signal spiSkippedPixels_L4 : std_logic_vector(31 downto 0); 

signal spiOffsetShift_L1 : std_logic_vector(31 downto 0);
signal spiOffsetShift_L2 : std_logic_vector(31 downto 0);
signal spiOffsetShift_L3 : std_logic_vector(31 downto 0);
signal spiOffsetShift_L4 : std_logic_vector(31 downto 0); 

signal spiBusy	: std_logic_vector(3 downto 0);
signal spiEn	: std_logic_vector(3 downto 0);

signal syncCntDebug_L1 : std_logic_vector(31 downto 0);
signal syncCntDebug_L2 : std_logic_vector(31 downto 0);
signal syncCntDebug_L3 : std_logic_vector(31 downto 0);
signal syncCntDebug_L4 : std_logic_vector(31 downto 0);

signal rdRdySig       : std_logic_vector(NUMBER_OF_LINE_SENSORS - 1 downto 0);
signal dataStrobeSig  : std_logic;
signal fifoDataLSxSig : lsPixelDataArrayType;
signal newDataIdxSig  : lsPixelNumberArrayType;
signal RESET : std_logic;
--THINGS TO DO:
--CREATE SPI ENABLE BASED ON CONFIG VALUE
--CHECK READ RDY REGISTER
--PUSH DATA TO RAM
--HOOK UP UPPER LEVEL REGISTERS TO AXI BUS 
begin
	sensorSpiSel <= spiConfigIn(5 downto 4);
	spiEn(0) <= spiLsEnIn when sensorSpiSel = "00" else '0';
	spiEn(1) <= spiLsEnIn when sensorSpiSel = "01" else '0';
	spiEn(2) <= spiLsEnIn when sensorSpiSel = "10" else '0';
	spiEn(3) <= spiLsEnIn when sensorSpiSel = "11" else '0';
	
	with sensorSpiSel select SCLK <=
			SCLKin(0) when "00",
			SCLKin(1) when "01",
			SCLKin(2) when "10",
			SCLKin(3) when "11",
			SCLKin(0) when others;
			
    with sensorSpiSel select MOSI <=
			MOSIin(0) when "00",
			MOSIin(1) when "01",
			MOSIin(2) when "10",
			MOSIin(3) when "11",
			MOSIin(0) when others;
	
	with sensorSpiSel select spiStartPixelOut <=
			spiStartPixel_L1 when "00",
			spiStartPixel_L2 when "01",
			spiStartPixel_L3 when "10",
			spiStartPixel_L4 when "11",
			spiStartPixel_L1 when others;
	
	with sensorSpiSel select spiReadoutPixelsOut <=
			spiReadoutPixels_L1 when "00",
			spiReadoutPixels_L2 when "01",
			spiReadoutPixels_L3 when "10",
			spiReadoutPixels_L4 when "11",
			spiReadoutPixels_L1 when others;
	
	with sensorSpiSel select spiSkippedPixelsOut <=
			spiSkippedPixels_L1 when "00",
			spiSkippedPixels_L2 when "01",
			spiSkippedPixels_L3 when "10",
			spiSkippedPixels_L4 when "11",
			spiSkippedPixels_L1 when others;
	
	with sensorSpiSel select spiOffsetShiftOut <=
			spiOffsetShift_L1 when "00",
			spiOffsetShift_L2 when "01",
			spiOffsetShift_L3 when "10",
			spiOffsetShift_L4 when "11",
			spiOffsetShift_L1 when others;

rdRdy <= rdRdySig;
RESET <= not RESETN or SOFT_RST;	
L1_inst : entity WAVIS_LIB.line_sensor_core(rtl)
	port map (
		clkIn			=> CLK,
		rstIn 			=> RESET,
		halfClkPerIn 	=> unsigned(halfClkPerIn),
		mstHighTimeIn 	=> unsigned(mstHighTimeIn),
		mstLowTimeIn 	=> unsigned(mstLowTimeIn),
		-- Timing I/F
		mstOut 			=> MST_o,
		mClkOut 		=> MCLK_o,
		-- ADC I/F
		adcDataIn 		=> L1_DOUT_i,
		pClkIn 			=> L1_PCLK_i,
		sensorSyncIn 	=> L1_SYNC_i,
		-- SPI I/F
		spiClkOut 		=> SCLKin(0),
		spiCSnOut 		=> L1_CS_o,
		spiMosiOut 		=> MOSIin(0),
		spiMisoIn 		=> L1_MISO_i,
		spiRstBOut 		=> open,
		-- SPI Control/Status
		spiRwEnIn 			=> spiEn(0),          
		spiBusyOut 			=> spiBusy(0),
		spiConfigIn 		=> spiConfigIn,
		spiRwCtrlIn 		=> spiRwCtrlIn,
		spiStartPixelOut 	=> spiStartPixel_L1,
		spiReadoutPixelsOut => spiReadoutPixels_L1,
		spiSkippedPixelsOut => spiSkippedPixels_L1,
		spiOffsetShiftOut 	=> spiOffsetShift_L1,
		--LS Control/Status
		ctrlRegIn 			=> ctrlRegIn,
		rdRdyOut 			=> rdRdySig(0),
		dataStrobeOut       => dataStrobeSig,
        newDataIdxOut       => newDataIdxSig(0),
        fifoDataOut         => fifoDataLSxSig(0),
		pixelNumSelIn 		=> pixelNumSelIn_L1,
		pixelValueOut 		=> pixelValueOut_L1,
		pixelValueAuxOut 	=> pixelValueAuxOut_L1,
		syncCntBi 			=> unsigned(syncCntDebug_L1),
		pixelRdStrobeIn 	=> '0',
		pixelNumDebugOut 	=> pixelNumDebugOut_L1,
		pixelCntDebugOut 	=> pixelCntDebugOut_L1,
		lsDebug             => lsDebug,
		lsAdcConfig         => lsAdcConfig
		--sortedDataArrayOut => open,
		--sortedIdxArrayOut => open
	);

L2_inst : entity WAVIS_LIB.line_sensor_core(rtl)
	port map (
		clkIn			=> CLK,
		rstIn 			=> RESET,
		halfClkPerIn 	=> unsigned(halfClkPerIn),
		mstHighTimeIn 	=> unsigned(mstHighTimeIn),
		mstLowTimeIn 	=> unsigned(mstLowTimeIn),
		-- Timing I/F
		mstOut 			=> open,
		mClkOut 		=> open,
		-- ADC I/F
		adcDataIn 		=> L2_DOUT_i,
		pClkIn 			=> L2_PCLK_i,
		sensorSyncIn 	=> L2_SYNC_i,
		-- SPI I/F
		spiClkOut 		=> SCLKin(1),
		spiCSnOut 		=> L2_CS_o,
		spiMosiOut 		=> MOSIin(1),
		spiMisoIn 		=> L2_MISO_i,
		spiRstBOut 		=> open,
		-- SPI Control/Status
		spiRwEnIn 			=> spiEn(1),          
		spiBusyOut 			=> spiBusy(1),
		spiConfigIn 		=> spiConfigIn,
		spiRwCtrlIn 		=> spiRwCtrlIn,
		spiStartPixelOut 	=> spiStartPixel_L2,
		spiReadoutPixelsOut => spiReadoutPixels_L2,
		spiSkippedPixelsOut => spiSkippedPixels_L2,
		spiOffsetShiftOut 	=> spiOffsetShift_L2,
		--LS Control/Status
		ctrlRegIn 			=> ctrlRegIn,
		rdRdyOut 			=> rdRdySig(1),
		dataStrobeOut       => open,
        newDataIdxOut       => newDataIdxSig(1),
        fifoDataOut         => fifoDataLSxSig(1),
		pixelNumSelIn 		=> pixelNumSelIn_L2,
		pixelValueOut 		=> pixelValueOut_L2,
		pixelValueAuxOut 	=> pixelValueAuxOut_L2,
		syncCntBi 			=> unsigned(syncCntDebug_L2),
		pixelRdStrobeIn 	=> '0',
		pixelNumDebugOut 	=> pixelNumDebugOut_L2,
		pixelCntDebugOut 	=> pixelCntDebugOut_L2,
		lsDebug             => open,
		lsAdcConfig         => lsAdcConfig
		--sortedDataArrayOut => open,
		--sortedIdxArrayOut => open
	);
	
L3_inst : entity WAVIS_LIB.line_sensor_core(rtl)
	port map (
		clkIn			=> CLK,
		rstIn 			=> RESET,
		halfClkPerIn 	=> unsigned(halfClkPerIn),
		mstHighTimeIn 	=> unsigned(mstHighTimeIn),
		mstLowTimeIn 	=> unsigned(mstLowTimeIn),
		-- Timing I/F
		mstOut 			=> open,
		mClkOut 		=> open,
		-- ADC I/F
		adcDataIn 		=> L3_DOUT_i,
		pClkIn 			=> L3_PCLK_i,
		sensorSyncIn 	=> L3_SYNC_i,
		-- SPI I/F
		spiClkOut 		=> SCLKin(2),
		spiCSnOut 		=> L3_CS_o,
		spiMosiOut 		=> MOSIin(2),
		spiMisoIn 		=> L3_MISO_i,
		spiRstBOut 		=> open,
		-- SPI Control/Status
		spiRwEnIn 			=> spiEn(2),          
		spiBusyOut 			=> spiBusy(2),
		spiConfigIn 		=> spiConfigIn,
		spiRwCtrlIn 		=> spiRwCtrlIn,
		spiStartPixelOut 	=> spiStartPixel_L3,
		spiReadoutPixelsOut => spiReadoutPixels_L3,
		spiSkippedPixelsOut => spiSkippedPixels_L3,
		spiOffsetShiftOut 	=> spiOffsetShift_L3,
		--LS Control/Status
		ctrlRegIn 			=> ctrlRegIn,
		rdRdyOut 			=> rdRdySig(2),
		dataStrobeOut       => open,
        newDataIdxOut       => newDataIdxSig(2),
        fifoDataOut         => fifoDataLSxSig(2),
		pixelNumSelIn 		=> pixelNumSelIn_L3,
		pixelValueOut 		=> pixelValueOut_L3,
		pixelValueAuxOut 	=> pixelValueAuxOut_L3,
		syncCntBi 			=> unsigned(syncCntDebug_L3),
		pixelRdStrobeIn 	=> '0',
		pixelNumDebugOut 	=> pixelNumDebugOut_L3,
		pixelCntDebugOut 	=> pixelCntDebugOut_L3,
		lsDebug             => open,
		lsAdcConfig         => lsAdcConfig
		--sortedDataArrayOut => open,
		--sortedIdxArrayOut => open
	);
	
L4_inst : entity WAVIS_LIB.line_sensor_core(rtl)
	port map (
		clkIn			=> CLK,
		rstIn 			=> RESET,
		halfClkPerIn 	=> unsigned(halfClkPerIn),
		mstHighTimeIn 	=> unsigned(mstHighTimeIn),
		mstLowTimeIn 	=> unsigned(mstLowTimeIn),
		-- Timing I/F
		mstOut 			=> open,
		mClkOut 		=> open,
		-- ADC I/F
		adcDataIn 		=> L4_DOUT_i,
		pClkIn 			=> L4_PCLK_i,
		sensorSyncIn 	=> L4_SYNC_i,
		-- SPI I/F
		spiClkOut 		=> SCLKin(3),
		spiCSnOut 		=> L4_CS_o,
		spiMosiOut 		=> MOSIin(3),
		spiMisoIn 		=> L4_MISO_i,
		spiRstBOut 		=> open,
		-- SPI Control/Status
		spiRwEnIn 			=> spiEn(3),          
		spiBusyOut 			=> spiBusy(3),
		spiConfigIn 		=> spiConfigIn,
		spiRwCtrlIn 		=> spiRwCtrlIn,
		spiStartPixelOut 	=> spiStartPixel_L4,
		spiReadoutPixelsOut => spiReadoutPixels_L4,
		spiSkippedPixelsOut => spiSkippedPixels_L4,
		spiOffsetShiftOut 	=> spiOffsetShift_L4,
		--LS Control/Status
		ctrlRegIn 			=> ctrlRegIn,
		rdRdyOut 			=> rdRdySig(3),
		dataStrobeOut       => open,
        newDataIdxOut       => newDataIdxSig(3),
        fifoDataOut         => fifoDataLSxSig(3),
		pixelNumSelIn 		=> pixelNumSelIn_L4,
		pixelValueOut 		=> pixelValueOut_L4,
		pixelValueAuxOut 	=> pixelValueAuxOut_L4,
		syncCntBi 			=> unsigned(syncCntDebug_L4),
		pixelRdStrobeIn 	=> '0',
		pixelNumDebugOut 	=> pixelNumDebugOut_L4,
		pixelCntDebugOut 	=> pixelCntDebugOut_L4,
		lsDebug             => open,
		lsAdcConfig         => lsAdcConfig
		--sortedDataArrayOut => open,
		--sortedIdxArrayOut => open
	);
LS_Buffering_inst:  entity WAVIS_LIB.line_sensor_buffering(rtl)
    port map (
       clkIn => CLK,
       rstIn => RESET,
       crtlRegIn => ctrlRegIn,
	   dataStrobeIn => dataStrobeSig,
	   newDataIdxIn => newDataIdxSig,
	   fifoDataLSxIn => fifoDataLSxSig,
	   rdRdyIn => rdRdySig,
	   pcReadReqIn => fastModePixelDataReadReqIn,
	   bufferDebugOut => bufferDebugOut,
	   bufferReadyOut => pixelBufferRdyOut,
	   dualSensorDataOut => fastModePixelDataOut
    );
dmaSignalsGeneratorInst : entity WAVIS_LIB.dmaSignalsGenerator(rtl)
	port map (
		CLK => CLK,--     : in std_logic;
		RESET => RESET,--	: in std_logic;
		ctrlRegIn => ctrlRegIn,--		: in std_logic_vector(31 downto 0);
		dataStrobeSig => dataStrobeSig,--   : in std_logic;
		fifoDataLSxSig => fifoDataLSxSig,--  : in lsPixelDataArrayType;
		newDataIdxSig => newDataIdxSig(0),
		DMA_START => DMA_START,--		: out std_logic;								--strobe to indicate data from user IP is ready to be sent to DMA 
		DMA_DATA => DMA_DATA,--		: out std_logic_vector(63 downto 0);			--64 bit data from user IP blocks 
		DMA_DATA_ADDR => DMA_DATA_ADDR,--	: out unsigned(DMA_DATA_ADDR_WIDTH-1 downto 0);	--current addr to DMA block
		DMA_DATA_WR_EN =>DMA_DATA_WR_EN --	: out std_logic	
	);

--fakePixelDataInst : entity WAVIS_LIB.fakePixelData(rtl)
--    port map (
--       clkIn => CLK,--           : in std_logic;
--       rstIn => RESETN,--            : in std_logic;
--       SOFT_RST => SOFT_RST,
--       ctrlRegIn => ctrlRegIn,
--       LS_Data_Ready => DMA_START,--    : out std_logic; --indicates that a full frame has been collected to DMA controller
--	   LS_Data_Strobe_FIFO => DMA_DATA_WR_EN ,--   : out std_logic; --write enable to FIFO
--	   LS_Combined_Data_FIFO => DMA_DATA,-- : out std_logic_vector(47 downto 0); --Data out to FIFO: LS4 LS3 LS2 LS1
--       LS_Pixel_Number_FIFO => DMA_DATA_ADDR,--  : out std_logic_vector(ADDR_WIDTH -1 downto 0); --indicates the pixel number of current data out from 0-1023
--	   LS_Buffer_Sent => '1',--   : in std_logic; --from BRAM module to acknowledge that buffer data has finished transmission
--       LS_Read_Ack => ctrlRegIn(1)--      : in std_logic --ack from PC that is had received all frames
--    );
end rtl;
