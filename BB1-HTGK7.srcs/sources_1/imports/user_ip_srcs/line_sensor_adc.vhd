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
-- DESIGNER    : VS, James King
-- BRIEF       : 
-- HISTORY     : Initial 03-08-2021
--             : Refactor 10-11-2021
-- 
--------------------------------------------------------------------------------
library ieee;           use ieee.std_logic_1164.all;
                        use ieee.numeric_std.all;
library WAVIS_LIB; use WAVIS_LIB.wAvisPackage.all;
                        use WAVIS_LIB.standard_pack.all;
                        
--------------------------------------------------------------------------------
-- ENTITY
-------------------------------------------------------------------------------
entity line_sensor_adc is
  port (
    clkIn            : in    std_logic;
    rstIn            : in    std_logic;
    masterEnIn       : in    std_logic;
    ppcRdIn          : in    std_logic;
    rdRdyOut         :   out std_logic;
    adcDataIn        : in    std_logic_vector(DATA_WIDTH-1 downto 0);
    sensorSyncIn     : in    std_logic;
    pClkIn           : in    std_logic;
    dataStrobeOut    :   out std_logic;
    fifoDataOut      :   out std_logic_vector(DATA_WIDTH-1 downto 0);
    pixelCntDebugOut :   out std_logic_vector(31 downto 0);
    pixelRdCntIn     : in    std_logic_vector(31 downto 0);
    syncCntBi        : inout unsigned(31 downto 0);
    pixelNumOut      :   out unsigned(31 downto 0);
    lsAdcDebug       : out std_logic_vector(3 downto 0);
    lsAdcConfig      : in std_logic_vector(31 downto 0));
end line_sensor_adc;

--------------------------------------------------------------------------------
-- ARCHITECTURE
--------------------------------------------------------------------------------
architecture rtl of line_sensor_adc is
  -- TYPES -----------------------------------------------------------------------
  type StrobeFSMType is (ST_RESET, IDLE, WAIT_SYNC_RISE, WAIT_PIXEL_CLK_RISE, SEND_STROBE, CHECK_PIXEL_CNT);
  -- SIGNALS ---------------------------------------------------------------------
  signal strobeStateR    : StrobeFSMType;

  signal adcDataR          : std_logic_vector(adcDataIn'range);
  signal adcDataRR         : std_logic_vector(adcDataIn'range);

  signal sensorSyncR       : std_logic;
  signal sensorSyncRR      : std_logic;
  signal sensorSyncRRR     : std_logic;
  signal sensorSyncRising  : std_logic;
  signal sensorSyncFalling : std_logic;
--  signal sensorSyncRRR     : std_logic;

  signal pClkR         : std_logic;
  signal pClkRR        : std_logic;
  signal pClkRRR       : std_logic;
  signal pClkRising1   : std_logic;
  signal pClkRisingA   : std_logic;
  signal pClkRising   : std_logic;
--  signal pClkRRR       : std_logic;

  signal masterEnR     : std_logic;
  signal masterEnRR    : std_logic;

  signal dataStrobeR        : std_logic;
  signal strobeCntR         : unsigned(31 downto 0);
  signal pixelClkCntR       : unsigned(31 downto 0);
  signal pixelCntR          : unsigned(pixelNumOut'range);
  signal pixelCntTot        : unsigned(pixelNumOut'range);
  signal pixelClkSkip       : unsigned(3 downto 0); 
  signal pixelClkSkipCnt    : unsigned(3 downto 0); 
  signal rdRdyR             : std_logic;
  
  signal doNotUse      : std_logic_vector(2 downto 0);
    
--  signal fifoDataR     : std_logic_vector(fifoDataOut'range);
  
begin
  -- Used to debug MCLKs between each sync
  pixelCntDebugOut <= std_logic_vector(pixelClkCntR);
  
  -- Double Register the data output from the ADC
  FlipFlop(adcDataR,  adcDataIn, x"000", rstIn, clkIn);
  FlipFlop(adcDataRR, adcDataR, x"000", rstIn, clkIn);
  fifoDataOut <= adcDataRR;

  -- Double Register the sensor sync
  FlipFlop(sensorSyncR,   sensorSyncIn, '0', rstIn, clkIn);
  FlipFlop(sensorSyncRR,  sensorSyncR,  '0', rstIn, clkIn);
  FlipFlop(sensorSyncRRR,  sensorSyncRR,  '0', rstIn, clkIn);
  -- Find Rising edge of sensor sync
  OneShot(sensorSyncRising,  sensorSyncR, sensorSyncRR, rstIn, clkIn, '1');
  OneShot(sensorSyncFalling, sensorSyncR, sensorSyncRR, rstIn, clkIn, '0');
  --FlipFlop(sensorSyncRRR, sensorSyncRR, '0', rstIn, clkIn);

  -- Double Register the pClk
  FlipFlop(pClkR,   pClkIn, '0', rstIn, clkIn);
  FlipFlop(pClkRR,  pClkR,  '0', rstIn, clkIn);
  FlipFlop(pClkRRR,  pClkRR,  '0', rstIn, clkIn);
  -- Find Rising edge of pClk
  OneShot(pClkRisingA, pClkR, pClkRR, rstIn, clkIn, '1');
  OneShot(pClkRising1, pClkRR, pClkRRR, rstIn, clkIn, '1');
  --FlipFlop(pClkRRR, pClkRR, '0', rstIn, clkIn);

  -- (UNUSED) Double Register the master enable
  FlipFlop(masterEnR, masterEnIn, '0', rstIn, clkIn);
  FlipFlop(masterEnRR, masterEnR, '0', rstIn, clkIn);

  pixelClkSkip <= unsigned(lsAdcConfig(3 downto 0));
  pixelCntTot <= unsigned(pixelRdCntIn) - 1;
  pClkRising <= pClkRising1 when (pixelCntR = 0) else pClkRisingA;
  --------------------------------------------------------------------------------
  -- Increase the Sync Count each time we see the sensor sync rise
  --------------------------------------------------------------------------------
  sync_count_proc: process(clkIn)
  begin
    if (rising_edge(clkIn)) then
      if (rstIn /= '0') then
        syncCntBi <= (others => '0');
      else
        if (sensorSyncRising = '1') then
          syncCntBi <= syncCntBi + 1;
        end if;
      end if;
    end if;
  end process sync_count_proc;

  ------------------------------------------------------------------------------
  -- Increment the pixelCnt
  ------------------------------------------------------------------------------
--  adc_data_rx_data_cnt_proc: process(clkIn)
--  begin
--    if (rising_edge(clkIn)) then
--      if (rstIn /= '0') then
--        pixelCntR <= (others => '0');
--      else
--        if (masterEnIn = '1') then
--          if (sensorSyncRising = '1') then
--            pixelCntR <= (others => '0');
--          elsif (pclkRising = '1' and (pixelCntR < pixelRdCntIn)) then
--            pixelCntR <= pixelCntR + 1;
--          end if;
--        else
--          pixelCntR <= (others => '0');
--        end if;
--      end if;
--    end if;
--  end process adc_data_rx_data_cnt_proc;
--  -- Output
--  pixelNumOut <= pixelCntR;

  ------------------------------------------------------------------------------
  -- Move data to fifoData output when master is enabled and rising pclk
  ------------------------------------------------------------------------------
--  adc_data_rx_data_proc: process(clkIn)
--  begin
--    if (rising_edge(clkIn)) then
--      if (rstIn /= '0') then
--        fifoDataR <= (others => '0');
--      else
--        if (masterEnIn = '1') then
--          if (pClkRising = '1') then
--            fifoDataR <= adcDataRR;
--          end if;
--        else
--          fifoDataR <= (others => '0');
--        end if;
--      end if;
--    end if;
--  end process adc_data_rx_data_proc;
--  -- Output
--  fifoDataOut <= fifoDataR;

  ------------------------------------------------------------------------------
  -- FSM for data strobe
  ------------------------------------------------------------------------------
  adc_data_rx_write_strobe_proc: process(clkIn)
  begin
    if (rising_edge(clkIn)) then
      if (rstIn /= '0') then
        strobeStateR <= ST_RESET;
        dataStrobeR  <= '0';
        strobeCntR   <= (others => '0');
        pixelClkCntR <= (others => '0');
        pixelCntR    <= (others => '0');
        rdRdyR       <= '0';
        lsAdcDebug   <= (others => '0');
        pixelClkSkipCnt <= (others => '0');
      else
        case strobeStateR is
          when ST_RESET =>
            strobeStateR <= IDLE;
            dataStrobeR  <= '0';
            strobeCntR   <= (others => '0');
            pixelClkCntR <= (others => '0');
            pixelCntR    <= (others => '0');
            rdRdyR       <= '0';
            lsAdcDebug   <= (others => '0');
            pixelClkSkipCnt <= (others => '0');
            
          when IDLE =>
            dataStrobeR <= '0';
            strobeCntR  <= (others => '0');
            pixelCntR   <= (others => '0');
            rdRdyR <= '0';
            pixelClkSkipCnt <= (others => '0');
            if (masterEnIn = '1' and ppcRdIn = '1') then
              strobeStateR <= WAIT_SYNC_RISE;
            end if;
            lsAdcDebug <= x"1";
            
          when WAIT_SYNC_RISE =>
            rdRdyR <= '0';
            if (masterEnIn = '0') then
              strobeStateR <= IDLE;
            elsif (sensorSyncRising = '1') then
              strobeStateR <= WAIT_PIXEL_CLK_RISE;
              strobeCntR   <= (others => '0');
              pixelCntR    <= (others => '0');
            end if;
            lsAdcDebug <= x"2";   
            
          when WAIT_PIXEL_CLK_RISE =>
            if (masterEnIn = '0') then
              strobeStateR <= IDLE;
            elsif (pClkRising = '1') then
               if (pixelClkSkipCnt >= pixelClkSkip) then
                   strobeStateR <= CHECK_PIXEL_CNT;
                   dataStrobeR  <= '1';
                   strobeCntR   <= strobeCntR + 1;
               else
                   pixelClkSkipCnt <= pixelClkSkipCnt + 1;
               end if;
            end if;
            lsAdcDebug <= x"3";

          when CHECK_PIXEL_CNT =>
            dataStrobeR <= '0';
            if (masterEnIn = '0') then
              strobeStateR <= IDLE;
            elsif (pixelCntR >= pixelCntTot) then
              rdRdyR <= '1';
              pixelClkCntR <= strobeCntR;
              if (ppcRdIn = '1') then
                pixelCntR    <= (others => '0');
                pixelClkSkipCnt <= (others => '0');
                strobeStateR <= WAIT_SYNC_RISE;
              end if;
            else
              strobeStateR <= WAIT_PIXEL_CLK_RISE;
              pixelCntR     <= pixelCntR + 1;
            end if;
            lsAdcDebug <= x"5";
            
          when others =>
            strobeStateR <= ST_RESET;
        end case;
      end if;
    end if;
  end process adc_data_rx_write_strobe_proc;

  -- Output
  pixelNumOut   <= pixelCntR;
  dataStrobeOut <= dataStrobeR;
  rdRdyOut <= rdRdyR;   
end architecture rtl;
