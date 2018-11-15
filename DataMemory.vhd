----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date:    20:30:31 11/12/2018 
-- Design Name: 
-- Module Name:    DataMemory - Behavioral 
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
USE IEEE.STD_LOGIC_UNSIGNED.ALL;
use IEEE.NUMERIC_STD.ALL;

-- Uncomment the following library declaration if using
-- arithmetic functions with Signed or Unsigned values
--use IEEE.NUMERIC_STD.ALL;

-- Uncomment the following library declaration if instantiating
-- any Xilinx primitives in this code.
--library UNISIM;
--use UNISIM.VComponents.all;

entity DataMemory is
    Port ( clk : in  STD_LOGIC;
           ALUResult : in  STD_LOGIC_VECTOR(7 downto 0);
           WriteData : in  STD_LOGIC_VECTOR(7 downto 0);
			  MemtoReg : in STD_LOGIC;
           MemWrite : in  STD_LOGIC;
           ReadData : out  STD_LOGIC_VECTOR(7 downto 0));
end DataMemory;

architecture Behavioral of DataMemory is

SIGNAL ReadD : STD_LOGIC_VECTOR(7 downto 0);
TYPE memory IS ARRAY (0 TO 255) OF STD_LOGIC_VECTOR(7 DOWNTO 0);
SIGNAL DataMem : memory := memory'(others=>"00000000");
begin

Process(clk)
Begin
IF(clk'event AND clk = '1') THEN
-- WE can not access the Mem to Write and Read at the same time, so I made these 2 signals not be '1' simultaneously.

-- Load
if(MemtoReg = '1' And MemWrite = '0') THEN
	ReadD <= DataMem(CONV_INTEGER(ALUResult));
	
-- Store
ELSIF(MemtoReg = '0' And MemWrite = '1') THEN
	ReadD <= ALUResult;
	DataMem(CONV_INTEGER(ALUResult)) <= WriteData;
END IF;
ReadData <= ReadD;
END IF;
END PROCESS;
end Behavioral;

