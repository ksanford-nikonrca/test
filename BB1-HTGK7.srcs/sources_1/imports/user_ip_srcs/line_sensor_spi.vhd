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
-- MODULE NAME : line_sensor_spi
-- DESIGNER    : VS, James King
-- BRIEF       : 
-- HISTORY     : Initial 03-08-2021
--               Refactor 10-11-2021
-- 
--------------------------------------------------------------------------------
library ieee; use ieee.std_logic_1164.all;
              use ieee.numeric_std.all;
library WAVIS_LIB; use WAVIS_LIB.wAvisPackage.all;
                        use WAVIS_LIB.standard_pack.all;
              
--------------------------------------------------------------------------------
-- ENTITY
--------------------------------------------------------------------------------
entity line_sensor_spi is
  port (
    clkIn               : in    std_logic;
    rstIn               : in    std_logic;
    -- I/F
    spiClkOut           :   out std_logic;
    spiCSnOut           :   out std_logic;
    spiMisoIn           :   in std_logic;
    spiMosiOut          :   out std_logic;
    spiRstBOut          :   out std_logic;
    -- Control/Status
    spiRwEnIn          :   in std_logic;
    spiBusyOut          : out std_logic;
    spiConfigIn         : in std_logic_vector(27 downto 0);
    spiRwCtrlIn         : in std_logic_vector(31 downto 0);
    spiStartPixelOut    :   out std_logic_vector(31 downto 0);
    spiReadoutPixelsOut :   out std_logic_vector(31 downto 0);
    spiSkippedPixelsOut :   out std_logic_vector(31 downto 0);
    spiOffsetShiftOut   :   out std_logic_vector(31 downto 0));
end line_sensor_spi;

--------------------------------------------------------------------------------
-- ARCHITECTURE
--------------------------------------------------------------------------------
architecture rtl of line_sensor_spi is
  -- CONSTANTS -----------------------------------------------------------------
  constant SPI_SLAVE_NUM    : natural := 1;
  constant SPI_DATA_WIDTH   : natural := 16;

  -- SIGNALS -------------------------------------------------------------------
  signal spiBusy            : std_logic;
  signal spiBusyR           : std_logic;
  signal spiBusyRR          : std_logic;
  signal spiBusyFalling     : std_logic;

  signal spiEnR             : std_logic;
  signal spiStartPixelR     : std_logic_vector(spiStartPixelOut'range);
  signal spiReadoutPixelsR  : std_logic_vector(spiReadoutPixelsOut'range);
  signal spiSkippedPixelsR  : std_logic_vector(spiSkippedPixelsOut'range);
  signal spiOffsetShiftR    : std_logic_vector(spiOffsetShiftOut'range);
  signal spiBusyEdgeR       : std_logic;
  signal spiBusyEdgeRR      : std_logic;
  
  signal spiAddressDecimalR : unsigned(31 downto 0);

  signal spiRstB            : std_logic;
  signal WRn                : std_logic;
  signal spiAddress         : std_logic_vector(6 downto 0);
  signal spiData            : std_logic_vector(15 downto 0);
  
  signal csVec              : std_logic_vector(0 downto 0);
  signal clkDiv             : unsigned(31 downto 0);
  signal spiClkBuf          : std_logic;
  signal flipFlopEnable     : std_logic;
  
begin

  clkDiv(15 downto 0)  <= unsigned(spiConfigIn(23 downto 8));
  clkDiv(31 downto 16) <= (others => '0');
  spiRstB              <= spiConfigIn(24);
  WRn                  <= spiRwCtrlIn(8);
  spiAddress           <= spiRwCtrlIn(15 downto 9);
  
  -- Interface Output
  spiRstBOut           <= spiRstB;
  spiCSnOut            <= csVec(0);
  spiBusyOut           <= spiBusy;

  -- Register Output
  spiStartPixelOut     <= spiStartPixelR;
  spiReadoutPixelsOut  <= spiReadoutPixelsR;
  spiSkippedPixelsOut  <= spiSkippedPixelsR;
  spiOffsetShiftOut    <= spiOffsetShiftR;

  -- Double Register Busy and falling edge of Busy
  FlipFlop(spiBusyEdgeR,  spiBusy,    '0', rstIn, clkIn, flipFlopEnable);
  FlipFlop(spiBusyEdgeRR, spiBusyEdgeR, '0', rstIn, clkIn, flipFlopEnable);
  OneShot(spiBusyFalling, spiBusyEdgeR, spiBusyEdgeRR, rstIn, clkIn, '0');

  spi_en_proc: process(clkIn)
  begin
    if (rising_edge(clkIn)) then
      if (rstIn /= '0') then
        spiEnR            <= '0';
        spiStartPixelR    <= (others => '0');
        spiReadoutPixelsR <= X"00000400";
        spiSkippedPixelsR <= (others => '0');
        spiOffsetShiftR   <= X"00000007";
        spiAddressDecimalR <= (others => '0');
        flipFlopEnable <= '1';
      else
        flipFlopEnable <= '1';
        spiAddressDecimalR(6 downto 0) <= unsigned(spiRwCtrlIn(15 downto 9));
        if (spiBusy = '0') then
          spiEnR <= spiRwEnIn; --just to add delay
        else
          spiEnR <= '0';
        end if;

        -- Reset Total ReadoutPixels and Offset Shift
        if (spiRstB = '1') then
          spiReadoutPixelsR <= X"00000400";
          spiOffsetShiftR  <= X"00000007";
        end if;
        
        -- Register Updates
        if (spiAddressDecimalR = 11 and WRn = '0' and spiBusyFalling = '1') then
          spiStartPixelR(10 downto 8) <= spiData(2 downto 0);
        end if;

        if (spiAddressDecimalR = 12 and WRn = '0' and spiBusyFalling = '1') then
          spiStartPixelR(7 downto 0) <= spiData(7 downto 0);
        end if;

        if (spiAddressDecimalR = 15 and WRn = '0' and spiBusyFalling = '1') then
          spiReadoutPixelsR(10 downto 8) <= spiData(2 downto 0);
        end if;

        if (spiAddressDecimalR = 16 and WRn = '0' and spiBusyFalling = '1') then
          spiReadoutPixelsR(7 downto 0) <= spiData(7 downto 0);
        end if;

        if (spiAddressDecimalR = 18 and WRn = '0' and spiBusyFalling = '1') then
          spiSkippedPixelsR(1 downto 0) <= spiData(1 downto 0);
        end if;

        if (spiAddressDecimalR = 22 and WRn = '0' and spiBusyFalling = '1') then
          spiOffsetShiftR(3 downto 0) <= spiData(3 downto 0);
        end if;
      end if;
    end if;
  end process;
  
   spiClkOut <= spiClkBuf;
   
  spi_master_inst: entity WAVIS_LIB.spi_master(rtl)
    generic map (
      slaves  => SPI_SLAVE_NUM,
      d_width => SPI_DATA_WIDTH)
    port map (
      clock   => clkIn,
      RST     => rstIn,
      enable  => spiEnR,
      cpol    => spiConfigIn(0),
      cpha    => spiConfigIn(1),
      cont    => '0',
      clk_div => to_integer(clkDiv),
      addr    => 0,
      tx_data => spiRwCtrlIn(15 downto 0),
      miso    => spiMisoIn,
      sclk    => spiClkBuf,
      ss_n    => csVec,
      mosi    => spiMosiOut,
      busy    => spiBusy,
      rx_data => spiData);
end rtl;


