library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use ieee.std_logic_unsigned.all;

entity nyuProcessor is
port (
  clk100m : in std_logic
--  btnL    : in std_logic;
--  an      : out std_logic_vector(3 downto 0);
--  cath    : out std_logic_vector(7 downto 0)
);

end entity;

architecture top of nyuProcessor is

component instructMem is
port (
  instructAddr : in std_logic_vector(31 downto 0); --input instruction from PC
  rd           : out std_logic_vector(31 downto 0) --output instruction to decoder and register file
);
end component;

component CtrlUnit is
port (
  opcode      : in std_logic_vector(5 downto 0); --Bits 31 downto 26 of instruction (Opcode)
  func        : in std_logic_vector(5 downto 0); --Bits 5 downto 0 of instruction (Function)
  memtoReg    : out std_logic;
  memWrite    : out std_logic;
  branch      : out std_logic;
  ALUControl  : out std_logic_vector(2 downto 0);
  ALUsrc      : out std_logic;
  regDst      : out std_logic;
  RegWrite    : out std_logic
--  jmp      : out std_logic_vector(1 downto 0)
);
end component;

component RegisterFile is
port (
  clk     : in std_logic;
  a1      : in std_logic_vector(4 downto 0); --Bits 25 downto 21 of instruction (Rs)
  a2      : in std_logic_vector(4 downto 0); --Bits 20 downto 16 of instruction (Rt)
  a3      : in std_logic_vector(4 downto 0); --Depending on the MUX Rt(20:16) or Rd(15:11)
  wd3     : in std_logic_vector(31 downto 0); --ALU result
  we3     : in std_logic; --Register Write
  rd1     : out std_logic_vector(31 downto 0); --SrcA of ALU
  rd2     : out std_logic_vector(31 downto 0) --input to ALUsrc mux
);
end component;

component ALU is
port (
  ALUControl : in std_logic_vector(2 downto 0);
  srcA       : in std_logic_vector(31 downto 0); --input of rd1
  srcB       : in std_logic_vector(31 downto 0); --input of rd2
  zero       : out std_logic; --Depending if branch is active
  ALUresult  : out std_logic_vector(31 downto 0) --result fo the computation from ALU 
);
end component;

component DataMemory is
port (
  clk        : in std_logic;
  ALUResult  : in std_logic_vector(31 downto 0); --input address from ALU
  MemWrite   : in std_logic; --write enable if memory to write
  WriteData  : in std_logic_vector(31 downto 0); --input of rd2
  ReadData   : out std_logic_vector(31 downto 0)
);
end component;

signal PC           : std_logic_vector(31 downto 0) := (others => '0');
signal PC_d         : std_logic_vector(31 downto 0) := (others => '0');
signal instruction  : std_logic_vector(31 downto 0) := (others => '0');
signal regDst_mux   : std_logic_vector(4 downto 0)  := (others => '0');
signal result       : std_logic_vector(31 downto 0) := (others => '0');
signal memtoReg     : std_logic := '0';
signal memWrite     : std_logic := '0';
signal branch       : std_logic := '0';
signal ALUctrl      : std_logic_vector(2 downto 0)  := (others => '0');
signal ALUsrc       : std_logic := '0';
signal regDst       : std_logic := '0';
signal regWr        : std_logic := '0';
signal dataMemAddr  : std_logic_vector(31 downto 0) := (others => '0');
signal zero         : std_logic := '0';
signal srcA         : std_logic_vector(31 downto 0) := (others => '0');
signal srcB         : std_logic_vector(31 downto 0) := (others => '0');
signal rd1          : std_logic_vector(31 downto 0) := (others => '0');
signal rd2          : std_logic_vector(31 downto 0) := (others => '0');
signal readData     : std_logic_vector(31 downto 0) := (others => '0');
signal signImm      : std_logic_vector(15 downto 0) := (others => '0');
signal writeReg     : std_logic_vector(4 downto 0)  := (others => '0');
signal PCSrc        : std_logic := '0';
signal PCplus4      : std_logic_vector(31 downto 0) := (others => '0');
signal PCbranch     : std_logic_vector(31 downto 0) := (others => '0');
signal signext      : std_logic_vector(31 downto 0) := (others => '0');
signal signext_lshf : std_logic_vector(31 downto 0) := (others => '0');
--signal jmp          : std_logic_vector(1 downto 0);
--signal PCjmp        : std_logic_vector(31 downto 0);
signal instructAddr : std_logic_vector(31 downto 0) := (others => '0');
--signal dataAddr     : std_logic_vector(31 downto 0) := (others => '0');

begin

--===================
--==Program Counter==
--===================

PC_proc : process (clk100m)
begin
  if rising_edge(clk100m) then
    PC_d <= PC;
  end if;
end process;

--===================
--====== MUXES ======
--===================

result_mux : process (memtoReg, readData, dataMemAddr)
begin
  if memtoReg = '1' then
    result <= readData;
  else
    result <= dataMemAddr;
  end if;
end process;

srcB_mux : process (ALUsrc, signext, rd2)
begin
  if ALUsrc = '1' then
    srcB <= signext;
  else
    srcB <= rd2;
  end if;
end process;

a3_mux : process (regDst, instruction)
begin
  if regDst = '1' then
    writeReg <= instruction(15 downto 11); --Rs
  else
    writeReg <= instruction(20 downto 16); --Rt
  end if;
end process;

PC_mux : process (PCSrc, PCbranch, PCplus4)
begin
  if PCSrc = '1' then
    PC <= PCbranch;
  else
    PC <= PCplus4; 
  end if;
end process;

--PCjmp <= PCplus4(31 downto 28) + instruction(25 downto 0) + "00"; --jump to the address specified

--==========================
--==Sign Ext and Additions==
--==========================
signImm <= instruction(15 downto 0);

signext <=  x"0000" & signImm; --extend the signed immediate address

signext_lshf <= signext(31 downto 2) & "00"; --shift left by 2 of signext

PCplus4  <= PC_d + 4; --byte addressing
PCbranch <= signext_lshf + PCplus4; --addressing if branch

PCsrc <= branch and zero; --set the PC to branch address

--=============
--==PORT MAPS==
--=============

instructMem_map : instructMem 
port map(
  instructAddr => PC_d       ,  --input instruction from PC
  rd   => instruction   --output instruction to decoder and register file
);

controlUnit_map : CtrlUnit
port map(
  opcode     => instruction(31 downto 26) , --in std_logic_vector(5 downto 0); --Bits 31 downto 26 of instruction (Opcode)
  func       => instruction(5 downto 0)   , --in std_logic_vector(5 downto 0); --Bits 5 downto 0 of instruction (Function)
  memtoReg   => memtoReg                  , --out std_logic;
  memWrite   => memWrite                  , --out std_logic;
  branch     => branch                    , --out std_logic;
  ALUControl => ALUctrl                   , --out std_logic_vector(2 downto 0);
  ALUsrc     => ALUsrc                    , --out std_logic;
  regDst     => regDst                    , --out std_logic;
  RegWrite   => regWr                       --out std_logic
--  jmp      => jmp
);

regFile_map : RegisterFile
port map(
  clk     => clk100m                   , --in std_logic;
  a1      => instruction(25 downto 21) , --in std_logic_vector(4 downto 0); --Bits 25 downto 21 of instruction (Rs)
  a2      => instruction(20 downto 16) , --in std_logic_vector(4 downto 0); --Bits 20 downto 16 of instruction (Rt)
  a3      => writeReg                , --in std_logic_vector(4 downto 0); --Depending on the MUX Rt(20:16) or Rd(15:11)
  wd3     => result                    , --in std_logic_vector(31 downto 0); --ALU result
  we3     => regWr                     , --in std_logic; --Register Write
  rd1     => rd1                       , --out std_logic_vector(31 downto 0); --SrcA of ALU
  rd2     => rd2                         --out std_logic_vector(31 downto 0) --input to ALUsrc mux
);

ALU_map : ALU
port map(
  ALUControl => ALUctrl ,
  srcA       => rd1  ,      --in std_logic_vector(31 downto 0); --input of rd1
  srcB       => srcB  ,      --in std_logic_vector(31 downto 0); --input of rd2
  zero       => zero ,      --out std_logic; --Depending if branch is active
  ALUresult  => dataMemAddr --out std_logic_vector(31 downto 0) --result fo the computation from ALU 
);

dataMem_map : DataMemory
port map(
  clk           => clk100m  , --in std_logic_vector(31 downto 0);
  ALUResult     => dataMemAddr , --in std_logic_vector(31 downto 0); --input address from ALU
  MemWrite      => memWrite , --in std_logic; --write enable if memory to write
  WriteData     => rd2      , --in std_logic_vector(31 downto 0); --input of rd2
  ReadData      => readData   --out std_logic_vector(31 downto 0)
);

end top;