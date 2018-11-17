----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date:    17:03:30 11/12/2018 
-- Design Name: 
-- Module Name:    CtrlUnit - Behavioral 
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
-- Uncomment the following library declaration if using
-- arithmetic functions with Signed or Unsigned values
use IEEE.NUMERIC_STD.ALL;
-- Uncomment the following library declaration if using
-- arithmetic functions with Signed or Unsigned values
--use IEEE.NUMERIC_STD.ALL;

-- Uncomment the following library declaration if instantiating
-- any Xilinx primitives in this code.
--library UNISIM;
--use UNISIM.VComponents.all;

entity CtrlUnit is
    Port ( --clk : in STD_LOGIC;
			  opcode : in STD_LOGIC_VECTOR(5 downto 0);
			  func : in STD_LOGIC_VECTOR(5 downto 0);
           MemtoReg : out  STD_LOGIC;
           MemWrite : out  STD_LOGIC;
           Branch : out  STD_LOGIC;
           ALUControl : out  STD_LOGIC_VECTOR(2 downto 0);
			  -- ALUctrl : 
			  -- 000 Add / Load / Store
			  -- 001 Sub / BEQ
			  -- 010 And
			  -- 011 Or
			  -- 100 Nor
			  -- 101 Lshift
			  -- 110 BLT
			  -- 111 BNE
           ALUsrc : out  STD_LOGIC;
           RegDst : out  STD_LOGIC;
--           jmp : out  STD_LOGIC_VECTOR(1 downto 0);
           RegWrite : out  STD_LOGIC);
end CtrlUnit;

architecture Behavioral of CtrlUnit is

SIGNAL MemtoRegS: STD_LOGIC := '0';
SIGNAL MemWriteS: STD_LOGIC := '0';
SIGNAL BranchS:  STD_LOGIC := '0';
SIGNAL ALUControlS: STD_LOGIC_VECTOR(2 downto 0);
SIGNAL ALUsrcS: STD_LOGIC := '0';
SIGNAL RegDstS: STD_LOGIC := '0';
SIGNAL RegWriteS: STD_LOGIC := '0';
--SIGNAL jmpS: STD_LOGIC_VECTOR(1 downto 0) := "00";

begin
Process(opcode)
BEGIN

-- IF(clk'EVENT and clk = '1') THEN
MemtoRegS <= '0';
MemWriteS <= '0';
BranchS <= '0';
ALUsrcS <= '0';
RegDstS <= '0';
RegWriteS <= '0';
--jmpS <= "00";
IF(opcode = "000000")	THEN
	RegDstS <= '1';
	RegWriteS <= '1';
	IF(func = "000001") THEN
		ALUControlS <= "000";
	ELSIF(func = "000011") THEN
		ALUControlS <= "001";
	ELSIF(func = "000101") THEN
		ALUControlS <= "010";
	ELSIF(func = "000111") THEN
		ALUControlS <= "011";
	ELSIF(func = "001001") THEN
		ALUControlS <= "100";
	END IF;
ELSE
	IF(opcode = "000001") THEN
		ALUControlS <= "000";
		RegDstS <= '0';
		RegWriteS <= '1';
		ALUSrcS <= '1';
	ELSIF(opcode = "000010") THEN
		ALUControlS <= "001";
		RegDstS <= '0';
		RegWriteS <= '1';
		ALUSrcS <= '1';
	ELSIF(opcode = "000011") THEN
		ALUControlS <= "010";
		RegDstS <= '0';
		RegWriteS <= '1';
		ALUSrcS <= '1';
	ELSIF(opcode = "000100") THEN
		ALUControlS <= "011";
		RegDstS <= '0';
		RegWriteS <= '1';
		ALUSrcS <= '1';
	ELSIF(opcode = "000101") THEN
		ALUControlS <= "101";
		RegDstS <= '0';
		RegWriteS <= '1';
		ALUSrcS <= '1';
		
	ELSIF(opcode = "000111") THEN
		ALUControlS <= "000";
		MemtoRegS <= '1';
		RegDstS <= '0';
		RegWriteS <= '1';
		ALUSrcS <= '1';
	ELSIF(opcode = "001000") THEN
		ALUControlS <= "000";
		MemWriteS <= '1';
		RegDstS <= '0';
		ALUSrcS <= '1';
		
	ELSIF(opcode = "001001") THEN
		ALUControlS <= "110";
		BranchS <= '1';
	ELSIF(opcode = "001010") THEN
		ALUControlS <= "001";
		BranchS <= '1';
	ELSIF(opcode = "001011") THEN
		ALUControlS <= "111";
		BranchS <= '1';
		
	ELSIF(opcode = "001100") THEN
		ALUControlS <= "010";
		BranchS <= '1'; -- for jump instruction
	ELSIF(opcode = "111111") THEN
		NULL;
	END IF;
END IF;
end process;
MemtoReg <= MemtoRegS;
MemWrite <= MemWriteS;
Branch <= BranchS;
ALUControl <= ALUControlS;
ALUsrc <= ALUsrcS;
RegDst <= RegDstS;
RegWrite <= RegWriteS;
--jmp <= jmpS;
end Behavioral;

