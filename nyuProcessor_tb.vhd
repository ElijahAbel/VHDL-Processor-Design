library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use ieee.std_logic_unsigned.all;

entity nyuProcessor_tb is
end entity;

architecture tb of nyuProcessor_tb is

signal clk100m : std_logic := '0';
signal sw      : std_logic_vector(15 downto 0); -- set din values in 16 bit segments
signal rst     : std_logic;                     -- reset (display only)
signal btnL    : std_logic;                     -- display dout
signal btnU    : std_logic;                     -- store din
signal btnR    : std_logic;                     -- store user key
signal an      : std_logic_vector(7 downto 0);
signal cath    : std_logic_vector(7 downto 0);
signal led     : std_logic_vector(15 downto 0);

component nyuProcessor is
port (
  clk100m : in std_logic;
  sw      : in std_logic_vector(15 downto 0); -- set din values in 16 bit segments
  rst     : in std_logic;                     -- reset (display only)
  btnL    : in std_logic;                     -- display dout
  btnU    : in std_logic;                     -- store din
  btnR    : in std_logic;                     --store user key
  an      : out std_logic_vector(7 downto 0);
  cath    : out std_logic_vector(7 downto 0);
  led     : out std_logic_vector(15 downto 0)
);
end component ;

begin

clk100m <= not clk100m after 5 ns;

uut: nyuProcessor 
port map (
  clk100m => clk100m ,
  sw      => sw      ,
  rst     => rst     ,
  btnL    => btnL    ,
  btnU    => btnU    ,
  btnR    => btnR    ,
  an      => an      ,
  cath    => cath    ,
  led     => led     
);

process 

constant period : time := 10 ns;

begin
    rst <= '1';
    sw <= x"0000"; 
	btnU <= '0';
	btnR <= '0';
	
	wait for period;
	
	rst <= '0';
	wait for period*2;
    
	--enc/dec
  -- for i in 0 to 4 loop
     -- wait until rising_edge(clk100m);
     -- btnU <= '1';
     -- wait until rising_edge(clk100m);
     -- btnU <= '0';
     -- wait for 21 ns;
   -- end loop;
	
    --key generation
  for i in 0 to 9 loop
     wait until rising_edge(clk100m);
     btnR <= '1';
     wait until rising_edge(clk100m);
     btnR <= '0';
     wait for 21 ns;
   end loop;
	
	wait;

end process;

end tb;