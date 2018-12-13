library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use ieee.std_logic_unsigned.all;

entity nyuProcessor is
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
  RegWrite    : out std_logic;
  jmp         : out std_logic
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
  clk_din    : in std_logic;
  din        : in std_logic_vector(63 downto 0);
  dout       : out std_logic_vector(63 downto 0);
  userKey    : in STD_LOGIC_VECTOR(127 downto 0);
  skey       : out STD_LOGIC_VECTOR(63 downto 0);
  ALUResult  : in std_logic_vector(31 downto 0); --input address from ALU
  MemWrite   : in std_logic; --write enable if memory to write
  WriteData  : in std_logic_vector(31 downto 0); --input of rd2
  ReadData   : out std_logic_vector(31 downto 0)
);
end component;


--===========================
--== SIGNALS FOR PROCESSOR ==
--===========================
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
signal jmp          : std_logic := '0';
signal PCjmp        : std_logic_vector(31 downto 0) := (others => '0');
signal instructAddr : std_logic_vector(31 downto 0) := (others => '0');
signal halt         : std_logic := '0';
signal clk          : std_logic := '0';
signal din          : std_logic_vector(63 downto 0) ;
signal din_d1        : std_logic_vector(63 downto 0);
signal din_d2        : std_logic_vector(63 downto 0);
signal din_d3        : std_logic_vector(63 downto 0);
signal din_d4        : std_logic_vector(63 downto 0);
signal din_d        : std_logic_vector(63 downto 0); --:= x"00000000_00000000";
signal dout         : std_logic_vector(63 downto 0) ;
signal dout_d       : std_logic_vector(63 downto 0);
signal userKey      : std_logic_vector(127 downto 0);
signal skey         : std_logic_vector(63 downto 0 );

--================================
--== SIGNALS FOR IMPLEMENTATION ==
--================================
signal SecCnt           : std_logic_vector (31 downto 0) := x"00000000";
signal counterEnable    : std_logic;
signal display          : std_logic_vector (31 downto 0);
signal segDecoder       : std_logic_vector (3 downto  0);
signal refresh_counter  : std_logic_vector (15 downto 0) := x"0000";
signal segActiveCnt     : std_logic_vector (2 downto  0);
signal btnCntL          : std_logic_vector (3 downto  0) := x"0";
signal btnCntU          : std_logic_vector (3 downto  0);
signal btnCntR          : std_logic_vector (3 downto  0);
signal di_valid         : std_logic;
signal key_valid         : std_logic;
signal fastCnt          : std_logic_vector(2 downto 0);
signal fastCounter      : std_logic;
signal clk_din          : std_logic;
--Debounce Signals
signal btn_d1   : std_logic;
signal btn_d2   : std_logic;
signal btn_db   : std_logic;
signal nbitCnt  : std_logic_vector(19 downto 0);
signal xorBtn   : std_logic;

signal jmp_d    : std_logic;
signal branch_d : std_logic;

begin

--halt <= jmp and branch; --halt when jump = '1' and branch = '1'
clk <= fastCounter and (not (halt) and (di_valid and key_valid)); --halting will stop clk thus stopping the program counter
clk_din <= fastCounter;

--led <= sw;
--======================
--== DISPLAY ON BOARD ==
--======================
 process (clk100m, jmp, branch)
 begin
   if rising_edge(clk100m) then
     if jmp_d = '1' and branch_d = '1' then
       halt <= '1';
     else
       halt <= '0';
     end if;
   end if;
 end process;

--delay din and dout
process(clk100m, rst)
begin
  if rst = '1' then
    dout_d  <= (others => '0');
	din_d1  <= (others => '0');
	din_d2  <= (others => '0');
	din_d3  <= (others => '0');
	din_d4  <= (others => '0');
	jmp_d   <= '0';
	branch_d <= '0';
  elsif rising_edge(clk100m) then
    dout_d <= dout;
    din_d1 <= din;
    din_d2 <= din_d1;
	din_d3 <= din_d2;
	din_d4 <= din_d3;
	jmp_d <= jmp;
	branch_d <= branch;
  end if;
end process;

din_d <= din_d1 or din_d2 or din_d3 or din_d4;

--This is the binary count decoder
segDecoder_proc : process(segDecoder)
begin
    case segDecoder is   
    when x"1" => cath <= x"F9"; --1 
    when x"2" => cath <= x"A4"; --2 
    when x"3" => cath <= x"B0"; --3 
    when x"4" => cath <= x"99"; --4 
    when x"5" => cath <= x"92"; --5 
    when x"6" => cath <= x"82"; --6 
    when x"7" => cath <= x"F8"; --7 
    when x"8" => cath <= x"80"; --8     
    when x"9" => cath <= x"98"; --9 
    when x"A" => cath <= x"88"; --a
    when x"B" => cath <= x"83"; --b
    when x"C" => cath <= x"C6"; --C
    when x"D" => cath <= x"A1"; --d
    when x"E" => cath <= x"86"; --E
    when x"F" => cath <= x"8E"; --F
    when others => cath <= x"C0"; --0
    end case;
end process;

--This process refreshs the 7-seg display every 6.5 ms
refreshRate : process(clk100m, rst)
begin 
  if(rst = '1') then
    refresh_counter <= (others => '0');
  elsif rising_edge(clk100m) then
    refresh_counter <= refresh_counter + 1;
  end if;
end process;

segActiveCnt <= refresh_counter(15 downto 13);

--This process activates the 7-segment at the refresh rate of 6.5 ms
segActive : process(segActiveCnt)
begin
  case segActiveCnt is
    when "001"   => an <= "11111101"; segDecoder <= display(7  downto 4); 
    when "010"   => an <= "11111011"; segDecoder <= display(11 downto 8); 
    when "011"   => an <= "11110111"; segDecoder <= display(15 downto 12); 
	when "100"   => an <= "11101111"; segDecoder <= display(19 downto 16); 
    when "101"   => an <= "11011111"; segDecoder <= display(23 downto 20); 
    when "110"   => an <= "10111111"; segDecoder <= display(27 downto 24); 
	when "111"   => an <= "01111111"; segDecoder <= display(31 downto 28); 
    when others  => an <= "11111110"; segDecoder <= display(3  downto 0);
  end case;
end process;

--This process toggles the clk
fastCounter_proc : process(clk100m, rst)
begin
  if(rst = '1') then
    fastCnt <= (others => '0');
  elsif rising_edge(clk100m) then
    if (fastCnt >= x"3") then 
      fastCnt <= (others => '0');
    else
      fastCnt <= fastCnt + 1;
    end if;
  end if;
end process;

fastCounter <= '1' when fastCnt = x"3" else '0';

--This process toggles the counter enable every 0.25 second
quarterCounter : process(clk100m, rst)
begin
  if(rst = '1') then
    SecCnt <= (others => '0');
  elsif rising_edge(clk100m) then
    if (SecCnt >= x"00000001") then --017D7840 / 640
      SecCnt <= (others => '0');
    else
      SecCnt <= SecCnt + 1;
    end if;
  end if;
end process;

counterEnable <= '1' when SecCnt = x"00000001" else '0';

--===================
--======DOUT=========
--===================
--This process keeps count on how many times the left button has been pressed
btnCntL_proc : process (counterEnable, rst)
begin
  if rst = '1' then
    btnCntL <= x"0";
  elsif rising_edge(counterEnable) then
    if btnL = '1' then
      if btnCntL = x"5" then
        btnCntL <= x"1";
      else
        btnCntL <= btnCntL + 1;
      end if;
    end if;
  end if;
end process;

--displays dout in 32 bit chunks everytime btnCntL is incremented
segDisplay_proc : process (btnCntL, skey, dout_d)
begin
  case btnCntL is 
    when x"4"   =>  display <= skey(31 downto  0);   
    when x"3"   =>  display <= skey(63 downto 32);   
    when x"2"   =>  display <= dout_d(31 downto  0); 
    when x"1"   =>  display <= dout_d(63 downto 32); 
    when others =>  NULL; 
  end case;
end process;

--===================
--=======DIN=========
--===================
--This process keeps count on how many times the up button has been pressed
btnCntU_proc : process (counterEnable, rst)
begin
  if rst = '1' then
    btnCntU <= x"0";
    di_valid <= '0';
  elsif rising_edge(counterEnable) then 
    if btnU = '1' then
      if btnCntU = x"4" then
        di_valid <= '1';
        btnCntU <= x"1";
      else
        btnCntU <= btnCntU + 1;
      end if;
    end if;
  end if;
end process;

led(2) <= di_valid;

--sets the din input in 16 bit chunks everytime btnCntU is incremented
dinInput_proc : process (btnCntU)
begin
  case btnCntU is
    when x"4"   =>  din(15 downto  0) <= sw(15 downto 0); 
    when x"3"   =>  din(31 downto 16) <= sw(15 downto 0); 
    when x"2"   =>  din(47 downto 32) <= sw(15 downto 0); 
    when x"1"   =>  din(63 downto 48) <= sw(15 downto 0); 
    when others =>  NULL; 
  end case;
end process;

--===================
--=======KEY=========
--===================
--This process keeps count on how many times the right button has been pressed
btnCntR_proc : process (counterEnable, rst)
begin
  if rst = '1' then
    btnCntR <= x"0";
    key_valid <= '0';
  elsif rising_edge(counterEnable) then 
    if btnR = '1' then
      if btnCntR = x"8" then
        key_valid <= '1';
        btnCntR <= x"1";
      else
        btnCntR <= btnCntR + 1;
      end if;
    end if;
  end if;
end process;

led(1) <= key_valid;

--sets the key input in 16 bit chunks everytime btnCntR is incremented
keyInput_proc : process (btnCntR)
begin
  case btnCntR is
    when x"8"   =>  userKey(15  downto  0 ) <= sw(15 downto 0); 
    when x"7"   =>  userKey(31  downto 16 ) <= sw(15 downto 0); 
    when x"6"   =>  userKey(47  downto 32 ) <= sw(15 downto 0); 
    when x"5"   =>  userKey(63  downto 48 ) <= sw(15 downto 0); 
    when x"4"   =>  userKey(79  downto 64 ) <= sw(15 downto 0); 
    when x"3"   =>  userKey(95  downto 80 ) <= sw(15 downto 0); 
    when x"2"   =>  userKey(111 downto 96 ) <= sw(15 downto 0); 
    when x"1"   =>  userKey(127 downto 112) <= sw(15 downto 0); 
    when others =>  NULL; 
  end case;
end process;

--===================
--==Program Counter==
--===================
PC_proc : process (clk)
begin
  if rising_edge(clk) then
    PC_d <= PC; 
  end if;
end process;

--===================
--====== MUXES ======
--===================
--This process executes if we're doing a load byte
result_mux : process (memtoReg, readData, dataMemAddr)
begin
  if memtoReg = '1' then
    result <= readData;
  else
    result <= dataMemAddr;
  end if;
end process;

--This process chooses between signext and srcB depending on ALUsrc
srcB_mux : process (ALUsrc, signext, rd2)
begin
  if ALUsrc = '1' then
    srcB <= signext;
  else
    srcB <= rd2;
  end if;
end process;

--This process stores the instruction to A3
a3_mux : process (regDst, instruction)
begin
  if regDst = '1' then
    writeReg <= instruction(15 downto 11); --Rs
  else
    writeReg <= instruction(20 downto 16); --Rt
  end if;
end process;

--Program Counter addressing
PC_mux : process (jmp, branch, PCbranch, PCplus4, PCjmp, PCSrc, rst)
begin
	if(jmp = '1' and branch = '0') then
		PC <= PCjmp;
	elsif(jmp = '0') then
		if(PCSrc = '1') then
			PC <= PCbranch;
	    else
		    PC <= PCplus4;
		end if;
	end if;
end process;

--==========================
--==Sign Ext and Additions==
--==========================
signImm <= instruction(15 downto 0);

signext <=  x"0000" & signImm; --extend the signed immediate address

signext_lshf <= signext(29 downto 0) & "00"; --shift left by 2 of signext

PCplus4  <= PC_d + 4; --byte addressing
PCbranch <= signext_lshf + PCplus4; --addressing if branch

PCjmp <= PCplus4(31 downto 28) & instruction(25 downto 0) & "00"; --jump to the address specified

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
  RegWrite   => regWr                     , --out std_logic
  jmp        => jmp
);

regFile_map : RegisterFile
port map(
  clk     => clk                       , --in std_logic;
  a1      => instruction(25 downto 21) , --in std_logic_vector(4 downto 0); --Bits 25 downto 21 of instruction (Rs)
  a2      => instruction(20 downto 16) , --in std_logic_vector(4 downto 0); --Bits 20 downto 16 of instruction (Rt)
  a3      => writeReg                  , --in std_logic_vector(4 downto 0); --Depending on the MUX Rt(20:16) or Rd(15:11)
  wd3     => result                    , --in std_logic_vector(31 downto 0); --ALU result
  we3     => regWr                     , --in std_logic; --Register Write
  rd1     => rd1                       , --out std_logic_vector(31 downto 0); --SrcA of ALU
  rd2     => rd2                         --out std_logic_vector(31 downto 0) --input to ALUsrc mux
);

ALU_map : ALU
port map(
  ALUControl => ALUctrl     ,
  srcA       => rd1         ,      --in std_logic_vector(31 downto 0); --input of rd1
  srcB       => srcB        ,      --in std_logic_vector(31 downto 0); --input of rd2
  zero       => zero        ,      --out std_logic; --Depending if branch is active
  ALUresult  => dataMemAddr        --out std_logic_vector(31 downto 0) --result fo the computation from ALU 
);

dataMem_map : DataMemory
port map(
  clk           => clk         , --in std_logic_vector(31 downto 0);
  clk_din       => clk_din     ,
  din           => din_d       , --din_d  ,
  dout          => dout        ,
  userKey       => userKey     ,
  skey          => skey        ,
  ALUResult     => dataMemAddr , --in std_logic_vector(31 downto 0); --input address from ALU
  MemWrite      => memWrite    , --in std_logic; --write enable if memory to write
  WriteData     => rd2         , --in std_logic_vector(31 downto 0); --input of rd2
  ReadData      => readData      --out std_logic_vector(31 downto 0)
);

end top;