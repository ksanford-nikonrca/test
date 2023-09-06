----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 08/02/2022 01:06:35 PM
-- Design Name: 
-- Module Name: tb_dmaSignalsGenerator - tb
-- Project Name: 
-- Target Devices: 
-- Tool Versions: 
-- Description: 
-- 
-- Dependencies: 
-- 
-- Revision:
-- Revision 0.01 - File Created
-- Additional Comments:
-- 
----------------------------------------------------------------------------------


library ieee;           use ieee.std_logic_1164.all;
                        use ieee.std_logic_unsigned.all;
                        use ieee.numeric_std.all;
library WAVIS_LIB; use WAVIS_LIB.wAvisPackage.all;
                        use WAVIS_LIB.standard_pack.all;
                        
entity tb_dmaSignalsGenerator is
end tb_dmaSignalsGenerator;

architecture tb of tb_dmaSignalsGenerator is

signal CLK: std_logic;
signal RESET : std_logic;
signal ctrlRegIn : std_logic_vector(31 downto 0);
signal dataStrobeSig  : std_logic;
signal newDataIdxSig  : unsigned(ADDR_WIDTH-1 downto 0);
signal fifoDataLSxSig : lsPixelDataArrayType;
		
signal DMA_START: std_logic;								--strobe to indicate data from user IP is ready to be sent to DMA 
signal DMA_DATA : std_logic_vector(63 downto 0);			--64 bit data from user IP blocks 
signal DMA_DATA_ADDR : std_logic_vector(DMA_DATA_ADDR_WIDTH-1 downto 0);	--current addr to DMA block
signal DMA_DATA_WR_EN: std_logic;

signal startFrame : std_logic;
constant CLK_period : time := 8 ns;

begin
startFrame <= ctrlRegIn(1);

CLK_process :process
begin
	CLK <= '0';
	wait for CLK_period / 2;
	CLK <= '1';
	wait for CLK_period / 2;
end process;

startProcess: process
begin
    wait until falling_edge(RESET);
    dataStrobeSig <= '0';
    newDataIdxSig <= (others => '0');
    fifoDataLSxSig <= (others => (others => '0'));
    wait until rising_edge(startFrame);
    wait for CLK_period * 10;
    for i in 0 to 1023 loop
    wait until rising_edge(CLK);
    dataStrobeSig <= '1';
    wait until rising_edge(CLK);
    dataStrobeSig <= '0';
    newDataIdxSig <= newDataIdxSig + 1;
    fifoDataLSxSig(0) <= fifoDataLSxSig(0) + 1;
    fifoDataLSxSig(1) <= fifoDataLSxSig(1) + 1;
    fifoDataLSxSig(2) <= fifoDataLSxSig(2) + 1;
    fifoDataLSxSig(3) <= fifoDataLSxSig(3) + 1;
    wait until rising_edge(CLK);
    wait for CLK_period * 7;
    end loop;
end process;

stim_proc : process
begin
    wait for CLK_period * 2;
    RESET <= '1';
    ctrlRegIn <= (others => '0');
    wait until rising_edge(CLK);
    RESET <= '0';
    wait for CLK_period * 3;
    wait until rising_edge(CLK);
    ctrlRegIn <= x"8000_0002";
    wait until rising_edge(CLK);
    ctrlRegIn <= x"8000_0000";
    wait;
end process;

uut : entity WAVIS_LIB.dmaSignalsGenerator(rtl)
port map (
    CLK  => CLK,--    : in std_logic;
	RESET => RESET,--	: in std_logic;
	
	ctrlRegIn => ctrlRegIn,--		: in std_logic_vector(31 downto 0);
	dataStrobeSig => dataStrobeSig,--   : in std_logic;
	newDataIdxSig => newDataIdxSig,--   : in unsigned(ADDR_WIDTH-1 downto 0);
	fifoDataLSxSig => fifoDataLSxSig,--  : in lsPixelDataArrayType;
	
	DMA_START => DMA_START,--		: out std_logic;								--strobe to indicate data from user IP is ready to be sent to DMA 
	DMA_DATA => DMA_DATA,--		: out std_logic_vector(63 downto 0);			--64 bit data from user IP blocks 
	DMA_DATA_ADDR => DMA_DATA_ADDR,--	: out std_logic_vector(DMA_DATA_ADDR_WIDTH-1 downto 0);	--current addr to DMA block
	DMA_DATA_WR_EN => DMA_DATA_WR_EN--	: out std_logic
);

end tb;
