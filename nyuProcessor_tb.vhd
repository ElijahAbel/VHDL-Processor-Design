library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use ieee.std_logic_unsigned.all;

entity nyuProcessor_tb is
end entity;

architecture tb of nyuProcessor_tb is

signal clk100m : std_logic := '1';
signal din     : std_logic_vector(63 downto 0) := x"00000000_00000000";
signal dout    : std_logic_vector(63 downto 0) := x"00000000_00000000";
-- signal myclk: std_logic;
-- signal tosel:std_logic_vector(1 downto 0):="00";
-- signal an:std_logic_vector(7 downto 0);
-- signal cath:std_logic_vector(6 downto 0);

component nyuProcessor is
port (
  clk100m : in std_logic;
  din     : in std_logic_vector(63 downto 0);
  dout    : out std_logic_vector(63 downto 0)
    -- myclk: in std_logic;
 -- tosel: in std_logic_vector(1 downto 0):="00";
  -- an      : out std_logic_vector(7 downto 0);
  -- cath    : out std_logic_vector(6 downto 0)
);
end component ;

begin

clk100m <= not clk100m after 5 ns;

uut: nyuProcessor 
port map (
  clk100m => clk100m,
  din     => din    ,
  dout    => dout
  -- myclk => myclk,
  -- tosel => tosel,
  -- an    => an   ,
  -- cath  => cath
);

process 
begin
  
  din <= x"ffffffff_ffffffff";
--  wait for 100 ns;
--  assert(dout = x"a2b568bac7edc2c1") report "dout is not expected value" severity failure;
  
--  din <= x"00000000_00000000";
--  wait for 100 ns;
--  assert(dout = x"f5761122979178f1") report "dout is not expected value" severity failure;
  
--  din <= x"10101010_10101010";
--  wait for 100 ns;
--  assert(dout = x"76fd266150686d21") report "dout is not expected value" severity failure;
  
  wait ;

end process;

end tb;