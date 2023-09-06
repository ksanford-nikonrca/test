library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

package wAvisPackage is

--constants for Sorting Cell
constant NUMBER_OF_CELLS		: integer := 30;
constant DATA_WIDTH				: integer := 12;
constant ADDR_WIDTH				: integer := 10;
constant EMPTY					: std_logic	:= '0';
constant OCCUPIED				: std_logic	:= '1';
constant NUMBER_OF_LINE_SENSORS	: integer := 4;
constant NUMBER_OF_PIXELS		: integer := 1024;
constant DMA_DATA_ADDR_WIDTH	: integer := 10;
constant REG_ADDR_WIDTH			: integer := 8;
constant DMA_DATA_WIDTH			: integer := 16;
constant COMBINED_PIXEL_DATA_WIDTH : integer := 48;
--bits 0-11 is pixel data; bits 12-21 is data location
type SortDataArrayType is array (0 to NUMBER_OF_CELLS - 1) of std_logic_vector(DATA_WIDTH - 1 downto 0);
type SortIdxArrayType is array (0 to NUMBER_OF_CELLS - 1) of std_logic_vector(ADDR_WIDTH - 1 downto 0);
type lsPixelNumberArrayType is array (0 to NUMBER_OF_LINE_SENSORS - 1) of unsigned(ADDR_WIDTH - 1 downto 0);
type lsPixelDataArrayType is array (0 to NUMBER_OF_LINE_SENSORS - 1) of std_logic_vector(DATA_WIDTH - 1 downto 0);

end package;