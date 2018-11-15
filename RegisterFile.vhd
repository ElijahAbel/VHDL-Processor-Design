----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date:    14:22:45 11/11/2018 
-- Design Name: 
-- Module Name:    RegisterFile - Behavioral 
-- Project Name: 
-- Target Devices: 
-- Tool versions: 
-- Description: 
--
-- Dependencies: 
--
-- Revision: 
-- Revision 0.01 - File Created
-- Additional Comments: 
--
----------------------------------------------------------------------------------
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
USE IEEE.STD_LOGIC_UNSIGNED.ALL; --use CONV_INTEGER


entity RegisterFile is
PORT  (
  clk : IN STD_LOGIC;  -- Clock signal
  A1 : IN STD_LOGIC_VECTOR(4 DOWNTO 0); --Rs
  A2 : IN STD_LOGIC_VECTOR(4 DOWNTO 0); -- Rt
  A3 : IN STD_LOGIC_VECTOR(4 DOWNTO 0); --Rt or Rd
  WD3 : IN STD_LOGIC_VECTOR(31 DOWNTO 0); --32 bits to be stored in Reg
  WE3 : IN STD_LOGIC; --Flag to determine if we store in Register this clock cycle
  RD1 : OUT STD_LOGIC_VECTOR(31 DOWNTO 0); --Output 1, always a register value
  RD2 : OUT STD_LOGIC_VECTOR(31 DOWNTO 0) --Output 2, Could be regist or immediate value
  );
end RegisterFile;

architecture Behavioral of RegisterFile is

TYPE regMem IS ARRAY (0 TO 31) OF STD_LOGIC_VECTOR(31 DOWNTO 0); --Register memory type
Signal regArray : regMem;

Signal i_RD1: STD_LOGIC_VECTOR(31 DOWNTO 0);
Signal i_RD2: STD_LOGIC_VECTOR(31 DOWNTO 0);

	
begin
PROCESS(clk)
BEGIN

if(clk'EVENT and clk='1') then
	
	--Since the WD3 value is from the previous cycle, we will write to the register
	--before we set our ouput signals in case the regist we have just written to is used in the next line of code
	if(WE3='1') then --If RegWrite from the Control Unit is '1' then we write to a register
		regArray(CONV_INTEGER(A3(4 DOWNTO 0))) <= WD3(31 DOWNTO 0);
	end if;
	
	i_RD1 <= regArray(CONV_INTEGER(A1(4 DOWNTO 0)));
	i_RD2 <= regArray(CONV_INTEGER(A2(4 DOWNTO 0)));
end if;
	
END PROCESS;

RD1 <= i_RD1(31 DOWNTO 0);
RD2 <= i_RD2(31 DOWNTO 0);

end Behavioral;

