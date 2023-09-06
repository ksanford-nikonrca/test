----------------------------------------------------------------------------------------
------------------------------------------------------------------------------------
-- handles timing bus direction switch of cascaded bi-directional buffers
-- DIR = 0 FPGA I/O port is input
-- DIR = 1 FPGA drives I/O port
------------------------------------------------------------------------------------
------------------------------------------------------------------------------------

LIBRARY IEEE;
USE IEEE.STD_LOGIC_1164.ALL;
USE IEEE.STD_LOGIC_ARITH.ALL;
USE IEEE.STD_LOGIC_UNSIGNED.ALL;

entity DirectionChange is port(
	RESETN			: in std_logic;
	CLK				: in std_logic;
	DIR				: in std_logic;  -- direction control
	ON_CHIP_TRI 	: out std_logic;  -- tri-state control for FPGA buffer
	EXTERNAL_TRI	: out std_logic  -- tri-state control for external buffer
);  	 
END DirectionChange;

ARCHITECTURE arch_imp OF DirectionChange IS

type STATE_TYPE is (DIR_IN, DIR_IN_OUT, DIR_OUT, DIR_OUT_IN);
signal current_state : STATE_TYPE;

begin

	process (CLK, RESETN)
	begin
		if(RESETN = '0') then
			current_state <= DIR_IN;
			ON_CHIP_TRI <= '1';	-- on chip driver off
			EXTERNAL_TRI<= '0'; -- external driver on
		else
			if(rising_edge(CLK)) then
				case current_state is  
				 when DIR_IN => 
					if(DIR = '1') then
						current_state <= DIR_IN_OUT; -- direction change
						ON_CHIP_TRI <= '1';	-- on chip driver off
						EXTERNAL_TRI<= '1'; -- external driver off
					else 
						current_state <= DIR_IN; -- no change in direction
						ON_CHIP_TRI <= '1';	-- on chip driver off
						EXTERNAL_TRI<= '0'; -- external driver on
					end if;
				 when DIR_IN_OUT => 
					current_state <= DIR_OUT;
					ON_CHIP_TRI <= '0';	-- on chip driver on
					EXTERNAL_TRI<= '1'; -- external driver off
				 when DIR_OUT => 
					if(DIR = '1') then
						current_state <= DIR_OUT;
						ON_CHIP_TRI <= '0';	-- on chip driver on
						EXTERNAL_TRI<= '1'; -- external driver off
					else 
						current_state <= DIR_OUT_IN;
						ON_CHIP_TRI <= '1';	-- on chip driver off
						EXTERNAL_TRI<= '1'; -- external driver off
					end if;
				 when DIR_OUT_IN => 
					current_state <= DIR_IN;
					ON_CHIP_TRI <= '1';	-- on chip driver off
					EXTERNAL_TRI<= '0'; -- external driver on
				end case;  
			end if;
		end if;
	end process;
end arch_imp;