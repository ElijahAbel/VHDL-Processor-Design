library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

-- Uncomment the following library declaration if using
-- arithmetic functions with Signed or Unsigned values
--use IEEE.NUMERIC_STD.ALL;

entity RegisterFile is
PORT(
	clk : in STD_LOGIC;
	A1 : in STD_LOGIC_VECTOR(4 DOWNTO 0); --Rs
	A2 : in STD_LOGIC_VECTOR(4 DOWNTO 0); --Rt
	A3 : in STD_LOGIC_VECTOR(4 DOWNTO 0); -- Either Rt or Rd dependent on RegDst from Control Unit
	WD3 : in STD_LOGIC_VECTOR(31 DOWNTO 0); --32 bit value to be stored in register
	WE3 : in STD_LOGIC; --RegWrite from Control Unit
	RD1 : out STD_LOGIC_VECTOR(31 DOWNTO 0);
	RD2 : out STD_LOGIC_VECTOR(31 DOWNTO 0)
);

end RegisterFile;

architecture Behavioral of RegisterFile is

begin


end Behavioral;

