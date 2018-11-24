library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use ieee.std_logic_unsigned.all;

entity nyuProcessor_tb is
end entity;

architecture tb of nyuProcessor_tb is

signal clk100m : std_logic := '1';
signal myclk: std_logic;
signal tosel:std_logic_vector(1 downto 0):="00";
signal an:std_logic_vector(7 downto 0);
signal cath:std_logic_vector(6 downto 0);
component nyuProcessor is
port (
  clk100m : in std_logic;
    myclk: in std_logic;
 tosel: in std_logic_vector(1 downto 0):="00";
  an      : out std_logic_vector(7 downto 0);
  cath    : out std_logic_vector(6 downto 0)
);
end component ;

begin

clk100m <= not clk100m after 5 ns;

uut: nyuProcessor 
port map (
  clk100m => clk100m,
    myclk=>myclk,
 tosel=>tosel,
  an=>an,
  cath=>cath
);

process 
begin
  
wait ;

end process;

end tb;