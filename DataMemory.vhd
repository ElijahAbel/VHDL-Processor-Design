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
----------------------------------------------------------------------------------
-- removed memtoreg, this signal should be in top-level
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
	       din : in STD_LOGIC_VECTOR(63 downto 0);
		   dout : out STD_LOGIC_VECTOR(63 downto 0);
           ALUResult : in  STD_LOGIC_VECTOR(31 downto 0);
           WriteData : in  STD_LOGIC_VECTOR(31 downto 0);
           MemWrite : in  STD_LOGIC;
           ReadData : out  STD_LOGIC_VECTOR(31 downto 0));
end DataMemory;

architecture Behavioral of DataMemory is

SIGNAL immAddr : STD_LOGIC_VECTOR(7 downto 0) := x"00"; --used to address the memory 
TYPE memory IS ARRAY (0 TO 255) OF STD_LOGIC_VECTOR(31 DOWNTO 0);
SIGNAL DataMem : memory := memory'(	0 => x"00000000", 1 => x"00000000", 2 => x"46F8E8C5", 3 => x"460C6085",
                                    4 => x"70F83B8A", 5 => x"284B8303", 6 => x"513E1454", 7 => x"F621ED22",
                                    8 => x"3125065D", 9 => x"11A83A5D",10 => x"D427686B",11 => x"713AD82D",
                                   12 => x"4B792F99",13 => x"2799A4DD",14 => x"A7901C49",15 => x"DEDE871A",
                                   16 => x"36C03196",17 => x"A7EFC249",18 => x"61A78BB8",19 => x"3B0A1D2B",
                                   20 => x"4DBFCA76",21 => x"AE162167",22 => x"30D76B0A",23 => x"43192304",
                                   24 => x"F6CC1431",25 => x"65046380", 
									100 => x"00000002" , --2
									101 => x"00000004" , --4
									102 => x"00000008" , --8
									103 => x"00000010" , --16
									104 => x"00000020" , --32
									105 => x"00000040" , --64
									106 => x"00000080" , --128
									107 => x"00000100" , --256
									108 => x"00000200" , --512
									109 => x"00000400" , --1024
									110 => x"00000800" , --2048
									111 => x"00001000" , --4096
									112 => x"00002000" , --8192
									113 => x"00004000" , --16384
									114 => x"00008000" , --32768
									115 => x"00010000" , --65536
									116 => x"00020000" , --131072
									117 => x"00040000" , --262144
									118 => x"00080000" , --524288
									119 => x"00100000" , --1048576
									120 => x"00200000" , --2097152
									121 => x"00400000" , --4194304
									122 => x"00800000" , --8388608
									123 => x"01000000" , --16777216
									124 => x"02000000" , --33554432
									125 => x"04000000" , --67108864
									126 => x"08000000" , --134217728
									127 => x"10000000" , --268435456
									128 => x"20000000" , --536870912
									129 => x"40000000" , --1073741824
									130 => x"80000000" , --2147483648
									others => x"00000000");
begin
immAddr <= ALUResult(7 downto 0);
--dout <= DataMem(222) & DataMem(223);

Process(clk, MemWrite, DataMem)
Begin
IF(clk'event AND clk = '1') THEN
-- Store

IF(MemWrite = '1') THEN
	ReadData <= ALUResult;
	DataMem(CONV_INTEGER(immAddr)) <= WriteData;
-- Inputs from FPGA
ELSE
    DataMem(26) <= din(63 downto 32);
	DataMem(27) <= din(31 downto  0);

	
END IF;
dout <= DataMem(222) & DataMem(223);
--ReadData <= ReadD;
END IF;

	ReadData <= DataMem(CONV_INTEGER(immAddr));
END PROCESS;
end Behavioral;

