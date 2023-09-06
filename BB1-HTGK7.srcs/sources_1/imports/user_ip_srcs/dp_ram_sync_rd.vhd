library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_unsigned.all;
library WAVIS_LIB; use WAVIS_LIB.wAvisPackage.all;
entity dpRam is
	port (
		clk       : in std_logic; --fpga clock
		writeEn   : in std_logic; --write enable
		addr      : in std_logic_vector(ADDR_WIDTH -1 downto 0); --address (for write and read through)
		dpAddr    : in std_logic_vector(ADDR_WIDTH -1 downto 0); --read address (read select address)
		dataIn    : in std_logic_vector(DATA_WIDTH - 1 downto 0); --data in
		spDataOut : out std_logic_vector(DATA_WIDTH - 1 downto 0); --read out at address 'a' (read through)
		dpDataOut : out std_logic_vector(DATA_WIDTH - 1 downto 0) --read out at address 'dpra' (read select)
	);
end dpRam;

architecture rtl of dpRam is

type ram_type is array (NUMBER_OF_PIXELS - 1 downto 0)
of std_logic_vector (DATA_WIDTH - 1 downto 0);

signal RAM : ram_type;
signal read_a : std_logic_vector(ADDR_WIDTH -1 downto 0);
signal read_dpra : std_logic_vector(ADDR_WIDTH -1 downto 0);

begin

process (clk)
begin
	if (rising_edge(clk)) then
		if (writeEn = '1') then
			RAM(conv_integer(addr)) <= dataIn; --write data in address 'a'
		end if;
		read_a <= addr; --read through address
		read_dpra <= dpAddr; --read select address
	end if;
end process;
	
spDataOut <= RAM(conv_integer(read_a)); 
dpDataOut <= RAM(conv_integer(read_dpra));

end rtl;