library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity instructMem is
port (
  instructAddr : in std_logic_vector(31 downto 0); --input instruction from PC
  rd           : out std_logic_vector(31 downto 0) --output instruction to decoder and register file
);
end instructMem;

architecture rtl of instructMem is

-- --OPCODES
-- signal ARITH    : std_logic_vector(5 downto 0) := "000000"; --OPCODE00
-- signal ADDIMM   : std_logic_vector(5 downto 0) := "000001"; --OPCODE01
-- signal SUBIMM   : std_logic_vector(5 downto 0) := "000010"; --OPCODE02
-- signal ANDIMM   : std_logic_vector(5 downto 0) := "000011"; --OPCODE03
-- signal ORIMM    : std_logic_vector(5 downto 0) := "000100"; --OPCODE04
-- signal SHFLFT   : std_logic_vector(5 downto 0) := "000101"; --OPCODE05
-- signal LOAD     : std_logic_vector(5 downto 0) := "000111"; --OPCODE07
-- signal STORE    : std_logic_vector(5 downto 0) := "001000"; --OPCODE08
-- signal BLT      : std_logic_vector(5 downto 0) := "001001"; --OPCODE09
-- signal BEQ      : std_logic_vector(5 downto 0) := "001010"; --OPCODE0A
-- signal BNE      : std_logic_vector(5 downto 0) := "001011"; --OPCODE0B
-- signal JUMP     : std_logic_vector(5 downto 0) := "001100"; --OPCODE0C
-- signal HALT     : std_logic_vector(5 downto 0) := "111111"; --OPCODE3F

-- --FUNCTIONS
-- signal ADDREG   : std_logic_vector(5 downto 0) := "000001"; --FUNC1
-- signal SUBREG   : std_logic_vector(5 downto 0) := "000011"; --FUNC3
-- signal ANDREG   : std_logic_vector(5 downto 0) := "000101"; --FUNC5
-- signal ORREG    : std_logic_vector(5 downto 0) := "000111"; --FUNC7
-- signal NORREG   : std_logic_vector(5 downto 0) := "001001"; --FUNC9

begin

instruct : process (instructAddr)
begin
case instructAddr(31 downto 0) is
                            -- OPCODE&   RS    &  RT     &  RD     &  SHAMT  & FUNCT (R-TYPE)
				            -- OPCODE&   RS    &  RT     & Address/Immediate         (I-TYPE)
				            -- OPCODE&   Address (26-bits)                           (J-TYPE)
  when x"00000000" => rd <= "000001" & "00000" & "00001" & "00000" & "00000" & "000010";  --ADDI R1, R0, 2
  when x"00000004" => rd <= "000001" & "00000" & "00011" & "00000" & "00000" & "001010";  --ADDI R3, R0, 10
  when x"00000008" => rd <= "000001" & "00000" & "00100" & "00000" & "00000" & "001110";  --ADDI R4, R0, 14
  when x"0000000C" => rd <= "000001" & "00000" & "00101" & "00000" & "00000" & "000010";  --ADDI R5, R0, 2
  when x"00000010" => rd <= "001000" & "00011" & "00100" & "00000" & "00000" & "000010";  --SW   R4, 2(R3)
  when x"00000014" => rd <= "001000" & "00011" & "00011" & "00000" & "00000" & "000001";  --SW R3, 1(R3)
  when x"00000018" => rd <= "000000" & "00100" & "00011" & "00100" & "00000" & "000011";  --SUB R4, R4, R3
  when x"0000001C" => rd <= "000010" & "00000" & "00100" & "00000" & "00000" & "000001";  --SUBI R4, R0, 1
  when x"00000020" => rd <= "000000" & "00011" & "00010" & "00100" & "00000" & "000101";  --AND R4, R2, R3
  when x"00000024" => rd <= "000011" & "00010" & "00100" & "00000" & "00000" & "001010";  --ANDI R4, R2, 10
  when x"00000028" => rd <= "000000" & "00011" & "00010" & "00100" & "00000" & "000111";  --OR R4, R2, 10
  when x"0000002C" => rd <= "000111" & "00011" & "00010" & "00000" & "00000" & "000001";  --LW R2, 1(R3)
  when x"00000030" => rd <= "000100" & "00010" & "00100" & "00000" & "00000" & "001010";  --ORI R4, R2, R3
  when x"00000034" => rd <= "000000" & "00011" & "00010" & "00100" & "00000" & "001001";  --NOR R4, R2, R3
  when x"00000038" => rd <= "000101" & "00010" & "00100" & "00000" & "00000" & "001010";  --SHL/R4, R2, 10
  when x"0000003C" => rd <= "001010" & "00000" & "00101" & "11111" & "11111" & "111110";  --BEQ R5, R0, -2
  when x"00000040" => rd <= "001001" & "00100" & "00101" & "00000" & "00000" & "000000";  --BLT R5, R4, 0
  when x"00000044" => rd <= "001011" & "00100" & "00101" & "00000" & "00000" & "000000";  --BNE R5, R4, 0
  when x"00000048" => rd <= "001100" & "00000" & "00000" & "00000" & "00000" & "010100";  --JMP 20
  when x"0000004C" => rd <= "111111" & "00000" & "00000" & "00000" & "00000" & "000000";  --HALT
  when x"00000050" => rd <= "111111" & "00000" & "00000" & "00000" & "00000" & "000000";  --HALT
  when x"00000054" => rd <= (others => '0');
  when x"00000058" => rd <= (others => '0');
  when x"0000005C" => rd <= (others => '0');
  when x"00000060" => rd <= (others => '0');
  when x"00000064" => rd <= (others => '0');
  when x"00000068" => rd <= (others => '0');
  when x"0000006C" => rd <= (others => '0');
  when x"00000070" => rd <= (others => '0');
  when x"00000074" => rd <= (others => '0');
  when x"00000078" => rd <= (others => '0');
  when x"0000007C" => rd <= (others => '0');
  when others  => rd <= (others => '0');         
end case;
end process;

end rtl;