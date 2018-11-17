library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use ieee.std_logic_unsigned.all;

entity nyuProcessor_tb is
end entity;

architecture tb of nyuProcessor_tb is

signal clk100m : std_logic := '1';

component nyuProcessor is
port (
  clk100m : in std_logic
);
end component ;

begin

clk100m <= not clk100m after 5 ns;

uut: nyuProcessor 
port map (
  clk100m => clk100m
);

process 
begin
  
wait ;

end process;

end tb;