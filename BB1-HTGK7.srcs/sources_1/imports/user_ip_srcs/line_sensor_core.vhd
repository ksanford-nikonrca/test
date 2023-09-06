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
-- MODULE NAME : line_sensor_core
-- DESIGNER    : VS, James King
-- BRIEF       : 
-- HISTORY     : Initial 03-08-2021
--               Refactor 10-13-2021
-- 
--------------------------------------------------------------------------------
library ieee;           use ieee.std_logic_1164.all;
                        --use ieee.std_logic_arith.all;
                        use ieee.std_logic_unsigned.all;
                        use ieee.numeric_std.all;
library WAVIS_LIB; use WAVIS_LIB.wAvisPackage.all;
                        use WAVIS_LIB.standard_pack.all;


--library UNISIM;
--use UNISIM.VComponents.all;

--------------------------------------------------------------------------------
-- ENTITY
--------------------------------------------------------------------------------
entity line_sensor_core is
--  generic (
--    HALF_CLK_PER        : natural := 2;
--    MST_HIGH_TIME       : natural := ;
--    MST_LOW_TIME        : natural := );
  port (
    clkIn               : in    std_logic;                      -- 75MHz FPGA System Clock
    rstIn               : in    std_logic;                      -- System Reset
    halfClkPerIn        : in    unsigned(31 downto 0);
    mstHighTimeIn       : in    unsigned(31 downto 0);          -- Counts of 150MHz clock cycles
    mstLowTimeIn        : in    unsigned(31 downto 0);          -- Counts of 150MHz clock cycles
    -- Timing I/F
    mstOut              :   out std_logic;
    mClkOut             :   out std_logic;
    -- ADC I/F
    adcDataIn           : in    std_logic_vector(DATA_WIDTH-1 downto 0);  -- dout
    pClkIn              : in    std_logic;
    sensorSyncIn        : in    std_logic;
    -- SPI I/F
    spiClkOut           :   out std_logic;
    spiCSnOut           :   out std_logic;
    spiMosiOut          :   out std_logic;
    spiMisoIn           : in    std_logic;
    spiRstBOut          :   out std_logic;
    -- SPI Control/Status
    spiRwEnIn           : in std_logic;                   
    spiBusyOut          : out std_logic;                   
    spiConfigIn         : in std_logic_vector(27 downto 0);
    spiRwCtrlIn         : in std_logic_vector(31 downto 0);
    spiStartPixelOut    : out std_logic_vector(31 downto 0);
    spiReadoutPixelsOut : out std_logic_vector(31 downto 0);
    spiSkippedPixelsOut : out std_logic_vector(31 downto 0);
    spiOffsetShiftOut   : out std_logic_vector(31 downto 0);
    -- ???
    ctrlRegIn           : in std_logic_vector(31 downto 0);
    rdRdyOut            : out std_logic;
    dataStrobeOut       : out std_logic;
    newDataIdxOut       : out unsigned(ADDR_WIDTH-1 downto 0);
    fifoDataOut         : out std_logic_vector(DATA_WIDTH-1 downto 0);
    pixelNumSelIn       : in std_logic_vector(ADDR_WIDTH-1 downto 0);
    pixelValueOut       : out std_logic_vector(DATA_WIDTH-1 downto 0);
    pixelValueAuxOut    : out std_logic_vector(DATA_WIDTH-1 downto 0);
    syncCntBi           : inout unsigned(31 downto 0);
    pixelRdStrobeIn     : in  std_logic;
    pixelNumDebugOut    : out std_logic_vector(31 downto 0);
    pixelCntDebugOut    : out std_logic_vector(31 downto 0);
    lsDebug             : out std_logic_vector(3 downto 0);
    lsAdcConfig         : in std_logic_vector(31 downto 0));
    --sortedDataArrayOut  :   out SortDataArrayType;
    --sortedIdxArrayOut   :   out SortIdxArrayType);
end line_sensor_core;

--------------------------------------------------------------------------------
-- ARCHITECTURE
--------------------------------------------------------------------------------
architecture rtl of line_sensor_core is
  -- CONSTANTS -----------------------------------------------------------------
  --constant HALF_CLK_PER_U : unsigned(31 downto 0) := to_unsigned(HALF_CLK_PER, 32);
  -- TYPES ---------------------------------------------------------------------
  type MstFsmType        is (RESET, IDLE, MST_HIGH, MST_LOW, CHECK_ENABLE);
  type PixelRwRamFsmType is (RESET, RAM0_SEL, RAM1_SEL, WAIT_FULL_FRAME1, WAIT_FULL_FRAME2);
  type RamType           is array (0 to 1023) of std_logic_vector (DATA_WIDTH-1 downto 0);
  -- SIGNALS -------------------------------------------------------------------
  signal pixelWrStateR       : PixelRwRamFsmType;
  signal pixelRdStateR       : PixelRwRamFsmType;
  signal memArrayR           : RamType;

  signal masterEnSig         : std_logic;
  signal ppcRdSig            : std_logic;
  signal rdRdySig            : std_logic;
  signal dataStrobeSig       : std_logic;
  signal fifoDataSig         : std_logic_vector(DATA_WIDTH-1 downto 0);
  --signal newDataIdxSig       : std_logic_vector(ADDR_WIDTH-1 downto 0);
  signal pixelCntDebugSig    : std_logic_vector(31 downto 0);
  signal spiReadoutPixelsSig : std_logic_vector(31 downto 0);
  signal sortedDataArraySig  : SortDataArrayType;
  signal sortedIdxArraySig   : SortIdxArrayType;
  signal pixelNumSig         : unsigned(31 downto 0);
  
  signal mClkR               : std_logic;
  signal mClkCntR            : unsigned(31 downto 0);

  signal mstStateR           : mstFsmType;
  signal mstR                : std_logic;
  signal mstCntR             : unsigned(31 downto 0);
  signal clkEnR              : std_logic;

  signal pixelValueAuxSig    : std_logic_vector(pixelValueAuxOut'range);
  signal pixelValueSig       : std_logic_vector(pixelValueOut'range);
 -- signal pixelAddrCntR       : unsigned(31 downto 0);
  signal dataMemAddrSig      : unsigned(31 downto 0);
  --signal frameRxAckSig       : std_logic;
  signal ramAddrSig          : std_logic_vector(9 downto 0);
  signal ramRdAddrSig        : std_logic_vector(9 downto 0);
  
  --signal ram0ReadoutSig      : std_logic_vector(11 downto 0);
  --signal ram1ReadoutSig      : std_logic_vector(11 downto 0);
  --signal ramRdSelSig         : std_logic;
  --signal ramWrSelSig         : std_logic;
  --signal frameRxAckRiseSig   : std_logic;
  --signal ram0WrEnSig         : std_logic;
  --signal ram1WrEnSig         : std_logic;

  begin
    masterEnSig         <= ctrlRegIn(0); --start MST and MCLK
    ppcRdSig            <= ctrlRegIn(1); --from PC after reading all 1024 pixels
    --frameRxAckSig       <= ctrlRegIn(4); --from PC after reading all 1024 pixels
    --newDataIdxSig       <= pixelNumSig(ADDR_WIDTH-1 downto 0);

    -- Outputs
    mClkOut             <= mClkR;
    mstOut              <= mstR;
    rdRdyOut            <= rdRdySig;
    pixelCntDebugOut    <= pixelCntDebugSig;
    spiReadoutPixelsOut <= spiReadoutPixelsSig;
    dataStrobeOut       <= dataStrobeSig;
    newDataIdxOut       <= pixelNumSig(ADDR_WIDTH-1 downto 0);
    fifoDataOut         <= fifoDataSig;
--    sortedDataArrayOut  <= sortedDataArraySig;
--    sortedIdxArrayOut   <= sortedIdxArraySig;
    pixelNumDebugOut    <= std_logic_vector(dataMemAddrSig);
    pixelValueAuxOut    <= pixelValueAuxSig;
    pixelValueOut       <= (others => '0');
    
    ----------------------------------------------------------------------------
    -- MCLK Pulse Process
    -- Enable Clock with MST
    ----------------------------------------------------------------------------
    mclk_proc: process (clkIn) is
    begin
      if (rising_edge(clkIn)) then
        if (rstIn /= '0') then
          mClkR    <= '0';
          mClkCntR <= (others => '0');
        else
          if (clkEnR = '1') then
            if (mClkCntR >= halfClkPerIn-1) then
              mClkCntR <= (others => '0');
              mClkR    <= not mClkR;
            else
              mClkCntR <= mClkCntR + 1;
            end if;
          else
            mClkR <= '0';
          end if;
        end if;
      end if;
    end process mclk_proc;

    ----------------------------------------------------------------------------
    -- MST Pulse Process
    ----------------------------------------------------------------------------
    mst_proc: process (clkIn) is
    begin
      if (rising_edge(clkIn)) then
        if (rstIn /= '0') then
          mstStateR <= RESET;
          mstR      <= '0';
          mstCntR   <= (others => '0');
          clkEnR    <= '0';
        else
          case mstStateR is
            when RESET =>
              mstStateR <= IDLE;
              mstR      <= '0';
              mstCntR   <= (others => '0');
              clkEnR    <= '0';
            when IDLE =>
              if (masterEnSig = '1' and ppcRdSig = '1') then
                mstStateR <= MST_HIGH;
                mstR      <= '1';
                mstCntR   <= (others => '0');
                clkEnR    <= '1';
              end if;
            when MST_HIGH =>
              mstR <= '1';
              if (mstCntR >= mstHighTimeIn) then
                mstStateR <= MST_LOW;
                mstCntR   <= (others => '0');
              else
                mstCntR   <= mstCntR + 1;
              end if;
            when MST_LOW =>
              mstR <= '0';
              if (mstCntR >= (mstLowTimeIn-1)) then
                mstStateR <= CHECK_ENABLE;
                mstCntR   <= (others => '0');
              else
                mstCntR   <= mstCntR + 1;
              end if;
            when CHECK_ENABLE =>
              mstR    <= '1';
              mstCntR <= (others => '0');
              if (masterEnSig = '0') then
                mstStateR <= IDLE;
                clkEnR    <= '0';
              elsif(ppcRdSig ='1') then
                mstStateR <= MST_LOW;
              end if;
            when others =>
              mstStateR <= RESET;
          end case;
        end if;
      end if;
    end process mst_proc;

    ----------------------------------------------------------------------------
    -- Write Array Process
    ----------------------------------------------------------------------------
    wr_array_proc : process (clkIn) is
    begin
      if (rising_edge(clkIn)) then
        if (rstIn /= '0') then
          memArrayR <= (others => (others => '0'));
        else
          if (dataStrobeSig = '1') then
            memArrayR(to_integer(dataMemAddrSig)) <= fifoDataSig;
          end if;
        end if;
      end if;
    end process wr_array_proc;

    pixelValueAuxSig <= memArrayR(to_integer(unsigned(pixelNumSelIn)));

--    ----------------------------------------------------------------------------
--    -- (UNUSED) Read Process
--    ----------------------------------------------------------------------------
--    rd_proc: process (clkIn) is
--    begin
--      if (rising_edge(clkIn)) then
--        if (rstIn /= '0') then
--          pixelRdStateR <= RESET;
--          ramRdSelSig   <= '0';
--        else
--          case pixelRdStateR is
--            when RESET =>
--              ramRdSelSig   <= '0';
--              pixelRdStateR <= RAM0_SEL;
--            when RAM0_SEL =>
--              ramRdSelSig <= '0';
--              if (frameRxAckRiseSig = '1') then
--                pixelRdStateR <= RAM1_SEL;
--              end if;
--            when RAM1_SEL =>
--              ramRdSelSig <= '1';
--              if (frameRxAckRiseSig = '1') then
--                pixelRdStateR <= RAM0_SEL;
--              end if;
--          end case;
--        end if;
--      end if;
--    end process rd_proc;


--    ---------------------------------------------------------------------------
--    -- (UNUSED Write Process
--    ---------------------------------------------------------------------------
--    wr_proc: process (clkIn) is
--    begin
--      if (rising_edge(clkIn)) then
--        if (rstIn = '1') then
--          PIXEL_WRITE_STATE <= st_RESET;
--          ramWrSelSig <= '0';
--        else
--          case pixelWrStateR is
--            when RESET =>
--              ramWrSelSig   <= '0';
--              pixelWrStateR <= RAM0_SEL;
--            when RAM0_SEL =>
--              ramWrSelSig <= '0';
--              if (frameRxAckRiseSig = '1') then
--                pixelWrStateR <= WAIT_FULL_FRAME1;
--              end if;
--            when WAIT_FULL_FRAME1 =>
--              if (pixelNumSig >= unsigned(spiReadoutPixelsSig) then
--                pixelWrStateR <= RAM1_SEL;
--              end if;
--            when RAM1_SEL =>
--              ramWrSelSig <= '1';
--              if (frameRxAckRiseSig = '1') then
--                pixelWrStateR <= WAIT_FULL_FRAME2;
--              end if;
--            when WAIT_FULL_FRAME2 =>
--              if (pixelNumSig >= unsigned(spiReadoutPixelsSig) then
--                pixelWrStateR <= RAM0_SEL;
--              end if;
--          end case;
--        end if;
--      end if;
--    end process wr_proc;

    -----------------------------------------------------------------------------
    -- (UNUSED) Increate the Pixel Address Count
    -----------------------------------------------------------------------------
--    pixel_cnt_proc : process (clkIn) is
--    begin
--      if (rising_edge(clkIn)) then
--        if (rstIn /= '0') then
--          pixelAddrCntR <= (others => '0');
--        else
--          if (pixelRdStrobeIn = '1') then
--            if (pixelAddrCntR >= 1023) then
--              pixelAddrCntR <= (others => '0');
--            else
--              pixelAddrCntR <= pixelAddrCntR + 1;
--            end if;
--          end if;
--        end if;
--      end if;
--    end process pixel_cnt_proc;

--    ----------------------------------------------------------------------------
--    -- DP RAM Instantiation
--    ----------------------------------------------------------------------------
--    pixel_fifo_inst : entity wavis_fpga_lib.dp_ram_sync_rd(rtl)
--      generic map (
--        ADR_SIZE   => 10,
--        DATA_SIZE  => 12,
--        DEPTH_SIZE => 1024)
--      port map (
--        clk  => clkIn,
--        we   => dataStrobeSig,
--        a    => ramAddrSig,
--        dpra => pixelNumSelIn,
--        di   => fifoDataSig,
--        spo  => pixelValueSig,
--        dpo  => pixelValueAuxSig);
    
    ramAddrSig <= std_logic_vector(dataMemAddrSig(ramAddrSig'range));
    --ramRdAddrSig <= std_logic_vector(pixelNumSelIn);

    dataMemAddrSig <= pixelNumSig when pixelNumSig < 1024 else (others => '0');
    --pixelValueSIg <= (others => '1');

    --pixelValueSig <= ram1ReadoutSig when ramRdSelSig = '1' else ram0ReadoutSig;
    --ram0WrEnSig   <= dataStrobeSig and not ramWrSelSig;
    --ram1WrEnSig   <= dataStrobeSig and ramWrSelSig;
    --ramAddrSig    <= std_logic_vector(dataMemAddrSig(ramAddrSig'range));

    ----------------------------------------------------------------------------
    -- Line Sensor ADC Instantiation
    ----------------------------------------------------------------------------
    adc_inst: entity WAVIS_LIB.line_sensor_adc(rtl)
      port map (
        clkIn            => clkIn,
        rstIn            => rstIn,
        masterEnIn       => masterEnSig,
        ppcRdIn          => ppcRdSig,
        rdRdyOut         => rdRdySig,
        adcDataIn        => adcDataIn,
        sensorSyncIn     => sensorSyncIn,
        pClkIn           => pClkIn,
        dataStrobeOut    => dataStrobeSig,
        fifoDataOut      => fifoDataSig,
        pixelCntDebugOut => pixelCntDebugSig,
        pixelRdCntIn     => spiReadoutPixelsSig,
        syncCntBi        => syncCntBi,
        pixelNumOut      => pixelNumSig,
        lsAdcDebug       => lsDebug,
        lsAdcConfig      => lsAdcConfig);
    
    ----------------------------------------------------------------------------
    -- Sorting Cell Array Instantiation
    ----------------------------------------------------------------------------
    -- sorting_cell_array_inst: entity WAVIS_LIB.sorting_cell_array(rtl)
      -- port map (
        -- clkIn              => clkIn,
        -- rstIn              => rstIn,
        -- newDataStrobeIn    => dataStrobeSig,
        -- rstCellIn          => ppcRdSig,
        -- newDataIn          => fifoDataSig,
        -- newDataIdxIn       => newDataIdxSig,
        -- sortedDataArrayOut => sortedDataArraySig,
        -- sortedIdxArrayOut  => sortedIdxArraySig);

    ----------------------------------------------------------------------------
    -- Line Sensor SPI Instantiation
    ----------------------------------------------------------------------------
    spi_inst: entity WAVIS_LIB.line_sensor_spi(rtl)
      port map (
        clkIn               => clkIn,
        rstIn               => rstIn,
        -- I/F
        spiClkOut           => spiClkOut,
        spiCSnOut           => spiCSnOut,
        spiMisoIn           => spiMisoIn,
        spiMosiOut          => spiMosiOut,
        spiRstBOut          => spiRstBOut,
        -- Control/Status
        spiRwEnIn          => spiRwEnIn,
        spiBusyOut          => spiBusyOut,
        spiConfigIn         => spiConfigIn,
        spiRwCtrlIn         => spiRwCtrlIn,
        spiStartPixelOut    => spiStartPixelOut,
        spiReadoutPixelsOut => spiReadoutPixelsSig,
        spiSkippedPixelsOut => spiSkippedPixelsOut,
        spiOffsetShiftOut   => spiOffsetShiftOut);
    
end rtl;
