library ieee;           use ieee.std_logic_1164.all;
                        use ieee.std_logic_unsigned.all;
                        use ieee.numeric_std.all;
library WAVIS_LIB; use WAVIS_LIB.wAvisPackage.all;
                        use WAVIS_LIB.standard_pack.all;

entity fakePixelData is
  Port ( 
    clkIn           : in std_logic;
    rstIn           : in std_logic;
    SOFT_RST         : in std_logic;
    ctrlRegIn       : in std_logic_vector(31 downto 0);
    LS_Data_Ready   : out std_logic; --indicates to DMA that data is ready to be sent
	LS_Data_Strobe_FIFO  : out std_logic; --write enable to FIFO
	LS_Combined_Data_FIFO: out std_logic_vector(63 downto 0); --Data out to FIFO: LS4 LS3 LS2 LS1
    LS_Pixel_Number_FIFO : out std_logic_vector(ADDR_WIDTH -1 downto 0); --indicates the pixel number of current data out from 0-1023
	LS_Buffer_Sent  : in std_logic; --from BRAM module to acknowledge that buffer data has finished transmission
    LS_Read_Ack     : in std_logic --ack from PC that is had received all frames
  );
end fakePixelData;

architecture rtl of fakePixelData is
type fakePixelFSM is (ST_RESET, WAIT_FIRST_CAPTURE, WAIT_FAKE_SYNC, WAIT_FOR_DMA, SET_PIXEL_DATA, SEND_STROBE, WAIT_FOR_NEXT_DATA, WAIT_FOR_PC_ACK);
signal frameCapture   : std_logic;
signal fakePixelState : fakePixelFSM;
signal LS_Data_ReadySig    : std_logic;
signal LS_Data_StrobeSig   : std_logic;
signal LS_Pixel_DataSig   : unsigned(DATA_WIDTH -1 downto 0);
signal LS_Pixel_NumberSig : unsigned(ADDR_WIDTH -1 downto 0);
signal LS_Pixel_Offset    : unsigned(DATA_WIDTH -1 downto 0);
signal resetCountFlag  : std_logic;

begin
LS_Data_Ready <= LS_Data_ReadySig;
LS_Data_Strobe_FIFO <= LS_Data_StrobeSig;
LS_Pixel_Number_FIFO <= std_logic_vector(LS_Pixel_NumberSig);
LS_Combined_Data_FIFO <= x"0000" & std_logic_vector(LS_Pixel_DataSig) & std_logic_vector(LS_Pixel_DataSig) & std_logic_vector(LS_Pixel_DataSig) & std_logic_vector(LS_Pixel_DataSig);
frameCapture <= ctrlRegIn(1);

fsmstateProc: process(clkIn)
variable clkCounter : integer := 0;
variable pixelCounter : integer := 0;
variable ackFromPCCounter : integer := 0;
begin
  if (rising_edge(clkIn)) then
    if (rstIn = '0') then
      fakePixelState      <= ST_RESET;
      LS_Data_ReadySig    <= '0';
      LS_Data_StrobeSig   <= '0';
      LS_Pixel_DataSig   <= (others => '1');
      LS_Pixel_NumberSig <= (others => '1');
      LS_Pixel_Offset <= (others => '0');
      clkCounter := 0;
      pixelCounter := 0;
      ackFromPCCounter := 0;
      resetCountFlag <= '0';
      
    else
      if (SOFT_RST = '1') then
         resetCountFlag <= '1';
      end if;
      case fakePixelState is 
        when ST_RESET =>
          fakePixelState      <= WAIT_FIRST_CAPTURE;
          LS_Data_ReadySig    <= '0';
		  LS_Data_StrobeSig   <= '0';
          LS_Pixel_DataSig   <= (others => '1');
          LS_Pixel_NumberSig <= (others => '1');
          LS_Pixel_Offset    <= (others => '0');
          resetCountFlag     <= '0';
          clkCounter := 0;
          pixelCounter := 0;
          ackFromPCCounter := 0;
		
		when WAIT_FIRST_CAPTURE =>
		  if (frameCapture = '1') then
		      fakePixelState <= WAIT_FAKE_SYNC;
		  end if;
		  
        when WAIT_FAKE_SYNC => --wait for fake sync signal from line sensors
          LS_Data_StrobeSig   <= '0';
          --LS_Pixel_DataSig   <= (others => '1');
          LS_Pixel_NumberSig <= (others => '1');
          pixelCounter := 0;
          if (clkCounter = 550) then
            LS_Pixel_DataSig   <= LS_Pixel_Offset;
            LS_Pixel_Offset    <= LS_Pixel_Offset + 1;
            fakePixelState <= SET_PIXEL_DATA;
			LS_Data_ReadySig    <= '1';
            clkCounter := 0;
          else
            clkCounter := clkCounter + 1;
          end if;
        
        when SET_PIXEL_DATA =>
--          if (pixelCounter >= 1023) then
--            fakePixelState <= WAIT_FOR_DMA;
--            pixelCounter := 0;
--          else
          fakePixelState <= SEND_STROBE;
          --end if;
          if (LS_Pixel_NumberSig >= 1023) then
            LS_Pixel_NumberSig <= (others => '0');
          else
            LS_Pixel_NumberSig <= LS_Pixel_NumberSig + 1;
          end if;
          if (resetCountFlag = '1') then
		    resetCountFlag <= '0';
		    LS_Pixel_Offset    <= (others => '0');
		    LS_Pixel_DataSig   <= (others => '0');
          elsif (LS_Pixel_DataSig >= 4095) then
            LS_Pixel_DataSig   <= (others => '0');
            LS_Pixel_Offset    <= (others => '0');
          else
            LS_Pixel_DataSig   <= LS_Pixel_DataSig + 1;
          end if;
          LS_Data_ReadySig    <= '0';
		  
        when SEND_STROBE =>
            LS_Data_StrobeSig   <= '1';
            fakePixelState <= WAIT_FOR_NEXT_DATA;
            pixelCounter := pixelCounter + 1;
             
        when WAIT_FOR_NEXT_DATA =>
          LS_Data_StrobeSig   <= '0';
          if (clkCounter >= 3) then 
            if (pixelCounter > 1023) then
                fakePixelState <= WAIT_FOR_DMA;
            else
                fakePixelState <= SET_PIXEL_DATA;
            end if;
            clkCounter := 0;
          else
            clkCounter := clkCounter + 1;
          end if;
        
        when WAIT_FOR_DMA =>
          if (LS_Buffer_Sent = '1') then
             LS_Data_ReadySig    <= '0'; --will need to set bit to indicate to PC data is ready to read if polling
             fakePixelState <= WAIT_FOR_PC_ACK;
          end if;
            
        when WAIT_FOR_PC_ACK => --wait for PC ack to start capturing full frame
         if (frameCapture = '1') then
             clkCounter := 0;
             fakePixelState <= WAIT_FAKE_SYNC;
         end if;
--            if (ackFromPCCounter >= 25000) then --200us
--				ackFromPCCounter := 0;
--				fakePixelState <= WAIT_FAKE_SYNC;
--			else
--				ackFromPCCounter := ackFromPCCounter + 1;
--			end if;
			
        when others => fakePixelState <= ST_RESET;
      end case;
    end if;   
  end if;
end process;

end rtl;
