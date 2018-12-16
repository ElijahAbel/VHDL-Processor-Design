--===========================
--====STEPS TO SUCCESSS======
--===========================
--1. Pulse the reset using the center button if switches were not set to zero
--2. Press the up button once to start storing keys
--3. Toggle the switches to your choosing and then press the up button to store them each time
--4. The last key stored will send a key_valid and will now accept inputs for din
--5. Press the up button once to start storing din
--6. Toggle the switches for each 16-bit segment of din and press up button to store each one
--7. The last din stored will send a din_valid and will ready up for enc or dec
--8. Set SW(0) to '1' for enc or '0' for dec.
--9. Press the up button twice to send out encdec_chosen which will start enc or dec process
--10. Enc/Dec will complete and give a dout
--11. Once completed the processor will accept din inputs
--12. Repeat steps 5-9 to run enc/dec
--============================
library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use ieee.std_logic_unsigned.all;

entity nyuProcessor_tb is
end entity;

architecture tb of nyuProcessor_tb is

signal clk100m : std_logic := '0';
signal sw      : std_logic_vector(15 downto 0); -- set values for key or din
signal rst     : std_logic;                     -- reset 
signal btnL    : std_logic;                     -- display dout
signal btnU    : std_logic;                     -- store din
signal an      : std_logic_vector(7 downto 0);
signal cath    : std_logic_vector(7 downto 0);
signal led     : std_logic_vector(15 downto 0);

component nyuProcessor is
port (
  clk100m : in std_logic;
  sw      : in std_logic_vector(15 downto 0); -- set values for key or din
  rst     : in std_logic;                     -- reset
  btnL    : in std_logic;                     -- display dout
  btnU    : in std_logic;                     -- store din
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
	
	wait for period;
	
	rst <= '0';
	wait for period*2;
	
    --key generation
    for i in 0 to 8 loop
      wait until rising_edge(clk100m);
      btnU <= '1';
      wait for PERIOD * 8;
      wait until rising_edge(clk100m);
      btnU <= '0';
      wait for 41 ns;
    end loop;
   
   --testing for diff key gen inputs
--   sw <= x"eedb";
--   wait until rising_edge(clk100m);
--   btnU <= '1';
--   wait until rising_edge(clk100m);
--   btnU <= '0';
--   wait for 41 ns;
   
--   sw <= x"a521";
--   wait until rising_edge(clk100m);
--   btnU <= '1';
--   wait until rising_edge(clk100m);
--   btnU <= '0';
--   wait for 41 ns;
   
--   sw <= x"6d8f";
--   wait until rising_edge(clk100m);
--   btnU <= '1';
--   wait until rising_edge(clk100m);
--   btnU <= '0';
--   wait for 41 ns;
   
--   sw <= x"4b15";
--   wait until rising_edge(clk100m);
--   btnU <= '1';
--   wait until rising_edge(clk100m);
--   btnU <= '0';
--   wait for 41 ns;
   
--   sw <= x"eedb";
--   wait until rising_edge(clk100m);
--   btnU <= '1';
--   wait until rising_edge(clk100m);
--   btnU <= '0';
--   wait for 41 ns;
     
--   sw <= x"a521";
--   wait until rising_edge(clk100m);
--   btnU <= '1';
--   wait until rising_edge(clk100m);
--   btnU <= '0';
--   wait for 41 ns;
     
--   sw <= x"6d8f";
--   wait until rising_edge(clk100m);
--   btnU <= '1';
--   wait until rising_edge(clk100m);
--   btnU <= '0';
--   wait for 41 ns;
     
--   sw <= x"4b15";
--   wait until rising_edge(clk100m);
--   btnU <= '1';
--   wait until rising_edge(clk100m);
--   btnU <= '0';
--   wait for 41 ns;
	
  --time it takes to finish key gen
   wait for 7.5 ms;
	
  --din inputs
   for i in 0 to 3 loop
      wait until rising_edge(clk100m);
      btnU <= '1';
      wait until rising_edge(clk100m);
      btnU <= '0';
      wait for 41 ns;
    end loop;
    
   wait for 100 us;
   
   --set whether you want enc or dec
   sw(0) <= '1';

   wait for 250 us;
  
  --encdec chosen set to 1
  for i in 0 to 1 loop
   wait until rising_edge(clk100m);
   btnU <= '1';
   wait until rising_edge(clk100m);
   btnU <= '0';
   wait for 41 ns;
  end loop;
    
   wait for 2 ms;
   
   --time for decryption
   --eedba5216d8f4b15
   sw <= x"eedb";
   wait until rising_edge(clk100m);
   btnU <= '1';
   wait until rising_edge(clk100m);
   btnU <= '0';
   wait for 41 ns;
   
   sw <= x"a521";
   wait until rising_edge(clk100m);
   btnU <= '1';
   wait until rising_edge(clk100m);
   btnU <= '0';
   wait for 41 ns;
   
   sw <= x"6d8f";
   wait until rising_edge(clk100m);
   btnU <= '1';
   wait until rising_edge(clk100m);
   btnU <= '0';
   wait for 41 ns;
   
   sw <= x"4b15";
   wait until rising_edge(clk100m);
   btnU <= '1';
   wait until rising_edge(clk100m);
   btnU <= '0';
   wait for 41 ns;
   
   --wait until rising_edge(clk100m);
   --btnU <= '1';
   --wait until rising_edge(clk100m);
   --btnU <= '0';
   --wait for 41 ns;
   
   --change to dec
   sw(0) <= '0';
   
   wait for 100 us;
   
   --run encdec chosen
  for i in 0 to 1 loop 
   wait until rising_edge(clk100m);
   btnU <= '1';
   wait until rising_edge(clk100m);
   btnU <= '0';
   wait for 41 ns;
  end loop;
    
  wait;

end process;

end tb;