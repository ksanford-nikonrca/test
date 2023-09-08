library ieee;
use ieee.std_logic_1164.all;
--use ieee.std_logic_unsigned.all;
--use IEEE.STD_LOGIC_ARITH.ALL;
use ieee.numeric_std.all;

entity LSR_CNTRL is
	port (
		CLK		: in std_logic;
		RESET	: in std_logic;
		
		lsr_enable_in     : in std_logic;
		lsr_pulse_in      : in std_logic;
		lsr_enable_out    : out std_logic;
		lsr_pulse_out      : out std_logic

	);
end LSR_CNTRL;

architecture rtl of LSR_CNTRL is

type LASER_state_type is (st0_DISABLED, st1_ENABLED, st2_PULSE_RDY, st3_PULSE_ON, st4_PULSE_OFF, st5_DISABLE_RDY);
signal LASER_state : LASER_state_type;

begin

lsr_cntrl_proc: process(CLK)
variable delay_count : integer;
constant delay_set : integer := 125000000;    -- 1 second delay with 125MHz clock

begin
	if (rising_edge(CLK)) then
		if (RESET = '1') then
			lsr_enable_out <= '0';
			lsr_pulse_out <= '0';			
		else
            case (LASER_state) is
                when st0_DISABLED =>
                    lsr_enable_out <= '0';
                    lsr_pulse_out <= '0';
                    delay_count := 0;
                    if(lsr_enable_in = '1') then
                        LASER_state <= st1_ENABLED;
                    end if;
                when st1_ENABLED =>
                    lsr_enable_out <= '1';
                    lsr_pulse_out <= '0';
                    if(lsr_enable_in = '0') then
                        LASER_state <= st0_DISABLED;
                    elsif(delay_count <= delay_set) then
                        delay_count := delay_count + 1;
                    else
                        delay_count := 0;
                        LASER_state <= st2_PULSE_RDY;
                    end if;
                when st2_PULSE_RDY =>
                    if(lsr_enable_in = '0') then
                        LASER_state <= st0_DISABLED;
                    elsif(lsr_pulse_in = '1') then
                        LASER_state <= st3_PULSE_ON;
                    end if;
                when st3_PULSE_ON =>
                    lsr_enable_out <= '1';
                    lsr_pulse_out <= '1';
                    if(lsr_enable_in = '0' or lsr_pulse_in = '0') then
                        LASER_state <= st4_PULSE_OFF;
                    end if;
                when st4_PULSE_OFF =>
                    lsr_enable_out <= '1';
                    lsr_pulse_out <= '0';
                    if(lsr_enable_in = '1' and lsr_pulse_in = '1') then
                        delay_count := 0;
                        LASER_state <= st3_PULSE_ON;
                    elsif(delay_count <= delay_set) then
                        delay_count := delay_count + 1;
                    else
                        delay_count := 0;
                        LASER_state <= st5_DISABLE_RDY;
                    end if;
                when st5_DISABLE_RDY =>
                    if(lsr_enable_in = '0') then
                        LASER_state <= st0_DISABLED;
                    elsif(lsr_pulse_in = '1') then
                        LASER_state <= st3_PULSE_ON;
                    end if;
                end case;
		end if;
	end if;
end process  lsr_cntrl_proc;

end rtl;