--------------------------------------------------------------------------------
-- NN     NN  RRRRRRRR    CCCCCCC      AAA
-- NNN    NN  RR     RR  CCC    CC    AA AA
-- NNNN   NN  RR     RR  CC          AA   AA
-- NNNN   NN  RR    RR   CC         AA     AA
-- NN NN  NN  RRRRRRR    CC         AAAAAAAAA
-- NN  NN NN  RR  RR     CC         AA     AA
-- NN   NNNN  RR   RR    CC         AA     AA
-- NN    NNN  RR    RR   CCC    CC  AA     AA
-- NN     NN  RR     RR   CCCCCCC   AA     AA
--------------------------------------------------------------------------------
--------------------------------------------------------------------------------
-- MODULE NAME : line_sensor_adc
-- DESIGNER    : VS
-- BRIEF       : 
-- HISTORY     : Initial 03-02-2022
--             : 
-- 
--------------------------------------------------------------------------------
library ieee;           use ieee.std_logic_1164.all;
                        use ieee.numeric_std.all;
library WAVIS_LIB; use WAVIS_LIB.wAvisPackage.all;
                        use WAVIS_LIB.standard_pack.all;
                        
--------------------------------------------------------------------------------
-- ENTITY
-------------------------------------------------------------------------------
entity line_sensor_buffering is
  port (
    clkIn            : in std_logic;
    rstIn            : in std_logic;
	
    crtlRegIn        : in std_logic_vector(31 downto 0);
	dataStrobeIn	 : in std_logic;
	newDataIdxIn     : in lsPixelNumberArrayType;
	fifoDataLSxIn    : in lsPixelDataArrayType;
	rdRdyIn          : in std_logic_vector(3 downto 0);
	pcReadReqIn      : in std_logic;
  	
  	bufferDebugOut   : out std_logic_vector(31 downto 0);
	bufferReadyOut   : out std_logic;
	dualSensorDataOut: out std_logic_vector(31 downto 0)); --bit29to28: qtr section,bit26to23: mode, bit23to12: line sensor A, bit11to0: line sensor B
end line_sensor_buffering;

--------------------------------------------------------------------------------
-- ARCHITECTURE
--------------------------------------------------------------------------------
architecture rtl of line_sensor_buffering is
  -- TYPES -----------------------------------------------------------------------
  type dataGatherFSMType is (ST_RESET, IDLE, CHECK_CAMERA_MODE, GATHER_REGISTER_DATA);
  -- SIGNALS ---------------------------------------------------------------------
  signal dataGatherState : dataGatherFSMType;
  signal masterEnSig : std_logic;
  signal pcReadReqR : std_logic;
  signal pcReadReqRR : std_logic;
  signal pcReadReqRising : std_logic;
  signal rdRdyR : std_logic_vector(3 downto 0);
  signal rdRdyRR : std_logic_vector(3 downto 0);
  signal rdRdyFalling : std_logic_vector(3 downto 0);
 -- signal rdRdyRising : std_logic_vector(3 downto 0);
  signal cameraModeSel : std_logic_vector(2 downto 0);
  signal currentCameraMode : std_logic_vector(2 downto 0);
  signal dataLocation: std_logic_vector(3 downto 0);
  signal dataOutIdxIn: unsigned(ADDR_WIDTH - 1 downto 0);
  signal fifoDataLSxOut : lsPixelDataArrayType;
  signal lsAPixelData : std_logic_vector(DATA_WIDTH-1 downto 0);
  signal lsBPixelData : std_logic_vector(DATA_WIDTH-1 downto 0); 
  signal adcDataRdy : std_logic;
  signal bufferReadySig : std_logic;
  signal bufferDebugSig : std_logic_vector(31 downto 0);
begin
  FlipFlop(pcReadReqR,   pcReadReqIn, '0', rstIn, clkIn);
  --FlipFlop(pcReadReqRR,   pcReadReqR, '0', rstIn, clkIn);
  -- Find Rising edge of Data Strobe
  OneShot(pcReadReqRising,  pcReadReqIn, pcReadReqR, rstIn, clkIn, '1');
  	
  FlipFlop(rdRdyR(0), rdRdyIn(0), '0', rstIn, clkIn);
  --FlipFlop(rdRdyRR(0), rdRdyR(0), '0', rstIn, clkIn);
  OneShot(rdRdyFalling(0), rdRdyIn(0), rdRdyR(0), rstIn, clkIn, '0');
--  OneShot(rdRdyRising(0), rdRdyIn(0), rdRdyR(0), rstIn, clkIn, '1');
  FlipFlop(rdRdyR(1), rdRdyIn(1), '0', rstIn, clkIn);
  --FlipFlop(rdRdyRR(1), rdRdyR(1), '0', rstIn, clkIn);
  OneShot(rdRdyFalling(1), rdRdyIn(1), rdRdyR(1), rstIn, clkIn, '0');
--  OneShot(rdRdyRising(1), rdRdyIn(1), rdRdyR(1), rstIn, clkIn, '1');
  FlipFlop(rdRdyR(2), rdRdyIn(2), '0', rstIn, clkIn);
  --FlipFlop(rdRdyRR(2), rdRdyR(2), '0', rstIn, clkIn);
  OneShot(rdRdyFalling(2), rdRdyIn(2), rdRdyR(2), rstIn, clkIn, '0');
--  OneShot(rdRdyRising(2), rdRdyIn(2), rdRdyR(2), rstIn, clkIn, '1');
  FlipFlop(rdRdyR(3), rdRdyIn(3), '0', rstIn, clkIn);
  --FlipFlop(rdRdyRR(3), rdRdyR(3), '0', rstIn, clkIn);
  OneShot(rdRdyFalling(3), rdRdyIn(3), rdRdyR(3), rstIn, clkIn, '0');
-- OneShot(rdRdyRising(3), rdRdyIn(3), rdRdyR(3), rstIn, clkIn, '1');
  
  --outputs
  bufferReadyOut <= bufferReadySig;
  dualSensorDataOut <= dataLocation & '0'& currentCameraMode & lsAPixelData & lsBPixelData;
  bufferDebugOut <= bufferDebugSig;
  --Register Decoding
  masterEnSig <= crtlRegIn(0);
  cameraModeSel <= crtlRegIn(6 downto 4);
  
--create process to update dpAddr
  adcDataRdy <= '0' when (rdRdyIn = x"0") else '1';
  
dpAddr_proc: process(clkIn)
begin
  if (rising_edge(clkIn)) then
    if (rstIn /= '0') then
		dataOutIdxIn <= (others => '0');
		bufferDebugSig(31 downto 22) <= (others => '0');
    else
        bufferDebugSig(31 downto 22) <= std_logic_vector(dataOutIdxIn);
		if (masterEnSig = '1') then
			if (adcDataRdy = '1' and pcReadReqRising = '1') then
			    if (dataOutIdxIn < 1023) then 
				    dataOutIdxIn <= dataOutIdxIn + 1;
				end if;
			elsif (adcDataRdy = '0') then
				dataOutIdxIn <= (others => '0');
			end if;
		else
			dataOutIdxIn <= (others => '0');
		end if;
    end if;
  end if;
end process dpAddr_proc;

--create process to update qtr section
dataLocation_proc: process(clkIn)
begin
  if (rising_edge(clkIn)) then
    if (rstIn /= '0') then
		dataLocation <= (others => '1');
		bufferDebugSig(21 downto 16) <= (others => '0');
    else
        bufferDebugSig(21) <= adcDataRdy;
		bufferDebugSig(20) <= masterEnSig;
		bufferDebugSig(19 downto 16) <= dataLocation; 
		if (masterEnSig = '1') then
			if (adcDataRdy = '1') then
				if (dataOutIdxIn = "00000000000") then
					dataLocation <= "1000"; --to be non zero
				elsif (dataOutIdxIn = "01111111111") then 
					dataLocation <= (others => '1');
				elsif (dataOutIdxIn >= "00000000000" and dataOutIdxIn < "00100000000") then 
					dataLocation <= "0001";
				elsif (dataOutIdxIn >= "00100000000" and dataOutIdxIn < "01000000000") then 
					dataLocation <= "0010";
				elsif (dataOutIdxIn >= "01000000000" and dataOutIdxIn < "01100000000") then
					dataLocation <= "0011";
				elsif (dataOutIdxIn >= "01100000000" and dataOutIdxIn < "01111111111") then 
					dataLocation <= "0100";
				end if;
			else
				dataLocation <= (others => '1');
			end if;
		else
			dataLocation <= (others => '1');
		end if;
    end if;
  end if;
end process dataLocation_proc;

--create process to create register output currentCameraMode lsAPixelData lsBPixelData
--STATE1 check for masterEnable
--STATE2 check the current mode
--STATE3 begin setting pixel data and camera mode while checking for rdRdyFalling  
--MODE0 : 1 & 2 
--MODE1 : 1 & 3 
--MODE2 : 1 & 4 
--MODE3 : 2 & 3 
--MODE4 : 2 & 4 
--MODE5 : 3 & 4 
dataGather_proc: process(clkIn)
begin
	if (rising_edge(clkIn)) then
		if (rstIn /= '0') then
			dataGatherState <= ST_RESET;
			currentCameraMode <= (others => '0');
			lsAPixelData <= (others => '0');
			lsBPixelData <= (others => '0');
			bufferReadySig <= '0';
			bufferDebugSig(15 downto 0) <= (others => '0'); 
		else
		    bufferDebugSig(15 downto 13) <= cameraModeSel;  
			case dataGatherState is 
				when ST_RESET =>
					dataGatherState <= IDLE;
					currentCameraMode <= (others => '0');
					lsAPixelData <= (others => '0');
					lsBPixelData <= (others => '0');
					bufferReadySig <= '0';
					bufferDebugSig(3 downto 0) <= x"0";
					 
				when IDLE =>
				    bufferDebugSig(3 downto 0) <= x"1";
					currentCameraMode <= (others => '0');
					lsAPixelData <= (others => '0');
					lsBPixelData <= (others => '0');
					bufferReadySig <= '0';
					if (masterEnSig = '1') then
						dataGatherState <= CHECK_CAMERA_MODE;
					end if;
					
				when CHECK_CAMERA_MODE =>
				    bufferDebugSig(3 downto 0) <= x"2";
					currentCameraMode <= cameraModeSel;
					dataGatherState <= GATHER_REGISTER_DATA;
					
				when GATHER_REGISTER_DATA =>
				    bufferDebugSig(3 downto 0) <= x"3";
					if (masterEnSig = '0') then
						dataGatherState <= IDLE;
					elsif (currentCameraMode = "000") then --MODE0: CAMS 1 & 2
					    if (rdRdyIn(0) = '1' and rdRdyIn(1) = '1') then
					       bufferReadySig <= '1';
                        else
                           bufferReadySig <= '0'; 
                        end if;
						if (rdRdyFalling(0) = '1' or rdRdyFalling(1) = '1') then
							dataGatherState <= CHECK_CAMERA_MODE;
						else
							lsAPixelData <= fifoDataLSxOut(0);
							lsBPixelData <= fifoDataLSxOut(1);
						end if;
					elsif (currentCameraMode = "001") then --MODE1: CAMS 1 & 3
					    if (rdRdyIn(0) = '1' and rdRdyIn(2) = '1') then
					       bufferReadySig <= '1';
                        else
                           bufferReadySig <= '0'; 
                        end if;
						if (rdRdyFalling(0) = '1' or rdRdyFalling(2) = '1') then
							dataGatherState <= CHECK_CAMERA_MODE;
						else
							lsAPixelData <= fifoDataLSxOut(0);
							lsBPixelData <= fifoDataLSxOut(2);
						end if;
					elsif (currentCameraMode = "010") then --MODE2: CAMS 1 & 4
					    if (rdRdyIn(0) = '1' and rdRdyIn(3) = '1') then
					       bufferReadySig <= '1';
                        else
                           bufferReadySig <= '0'; 
                        end if;
						if (rdRdyFalling(0) = '1' or rdRdyFalling(3) = '1') then
							dataGatherState <= CHECK_CAMERA_MODE;
						else
							lsAPixelData <= fifoDataLSxOut(0);
							lsBPixelData <= fifoDataLSxOut(3);
						end if;
					elsif (currentCameraMode = "011") then --MODE3: CAMS 2 & 3
					    if (rdRdyIn(1) = '1' and rdRdyIn(2) = '1') then
					       bufferReadySig <= '1';
                        else
                           bufferReadySig <= '0'; 
                        end if;
						if (rdRdyFalling(1) = '1' or rdRdyFalling(2) = '1') then
							dataGatherState <= CHECK_CAMERA_MODE;
						else
							lsAPixelData <= fifoDataLSxOut(1);
							lsBPixelData <= fifoDataLSxOut(2);
						end if;
					elsif (currentCameraMode = "100") then --MODE4: CAMS 2 & 4
					    if (rdRdyIn(1) = '1' and rdRdyIn(3) = '1') then
					       bufferReadySig <= '1';
                        else
                           bufferReadySig <= '0'; 
                        end if;
						if (rdRdyFalling(1) = '1' or rdRdyFalling(3) = '1') then
							dataGatherState <= CHECK_CAMERA_MODE;
						else
							lsAPixelData <= fifoDataLSxOut(1);
							lsBPixelData <= fifoDataLSxOut(3);
						end if;
					elsif (currentCameraMode = "101") then --MODE5: CAMS 3 & 4
					    if (rdRdyIn(2) = '1' and rdRdyIn(3) = '1') then
					       bufferReadySig <= '1';
                        else
                           bufferReadySig <= '0'; 
                        end if;
						if (rdRdyFalling(2) = '1' or rdRdyFalling(3) = '1') then
							dataGatherState <= CHECK_CAMERA_MODE;
						else
							lsAPixelData <= fifoDataLSxOut(2);
							lsBPixelData <= fifoDataLSxOut(3);
						end if;
					end if;
				
				when others => dataGatherState <= ST_RESET;
			end case;
		end if;
	end if;
end process dataGather_proc;

 
gen_ls_ram : for I in 0 to (NUMBER_OF_LINE_SENSORS - 1) generate
	ram_lsX : entity WAVIS_LIB.dpRam(rtl)
	port map (
		clk      => clkIn,
		writeEn  => dataStrobeIn,
		addr     => std_logic_vector(newDataIdxIn(I)),
		dpAddr   => std_logic_vector(dataOutIdxIn),
		dataIn   => fifoDataLSxIn(I),
		spDataOut=> open,
		dpDataOut=> fifoDataLSxOut(I)
	);
end generate gen_ls_ram;

end architecture rtl;
