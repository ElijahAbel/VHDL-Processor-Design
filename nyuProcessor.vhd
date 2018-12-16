library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use ieee.std_logic_unsigned.all;
use work.state_pkg.all;

entity nyuProcessor is
port (
  clk100m : in std_logic;
  sw      : in std_logic_vector(15 downto 0); -- set din values in 16 bit segments
  rst     : in std_logic;                     -- reset (display only)
  btnL    : in std_logic;                     -- display dout
  btnU    : in std_logic;                     -- store din
--  btnR    : in std_logic;                     -- valid
  an      : out std_logic_vector(7 downto 0);
  cath    : out std_logic_vector(7 downto 0);
  led     : out std_logic_vector(15 downto 0)
);

end entity;

architecture top of nyuProcessor is

component instructMem is
port (
  instructAddr : in std_logic_vector(31 downto 0); --input instruction from PC
  RCState      : in RCStateType;
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
  RCState : in RCStateType;
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
  --skey       : out STD_LOGIC_VECTOR(63 downto 0);
  userKey    : in STD_LOGIC_VECTOR(127 downto 0);
  RCState : in RCStateType;
  ALUResult  : in std_logic_vector(31 downto 0); --input address from ALU
  MemWrite   : in std_logic; --write enable if memory to write
  WriteData  : in std_logic_vector(31 downto 0); --input of rd2
  ReadData   : out std_logic_vector(31 downto 0)
);
end component;


--component DBounce is
--    Port(
--        clk, nreset : in std_logic;
--        button_in   : in std_logic;
--        DB_out      : buffer std_logic
--        );
--end component;

-- component DeBounce is
    -- port(   Clock : in std_logic;
                -- Reset : in std_logic;
            -- button_in : in std_logic;
            -- pulse_out : out std_logic
        -- );
-- end component;

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
signal RCState        : RCStateType := PRE_KEY_GEN;
signal key_inp_vld : std_logic := '0';
signal rc_inp_vld   : std_logic := '0';
signal encdec_chosen       : std_logic := '0';
signal encdec       : std_logic;
signal userkey      : std_logic_vector(127 DOWNTO 0);
signal userkey_d1      : std_logic_vector(127 DOWNTO 0);
signal userkey_d2      : std_logic_vector(127 DOWNTO 0);
signal proc_state   : std_logic :='0'; --Tells us if we are in a state where the clock should run
signal last_inp_btnU : std_logic :='0';
signal last_inp_btnL : std_logic :='0';

--================================
--== SIGNALS FOR IMPLEMENTATION ==
--================================
signal SecCnt           : std_logic_vector (31 downto 0);
signal counterEnable    : std_logic;
signal display          : std_logic_vector (31 downto 0);
signal segDecoder       : std_logic_vector (3 downto  0);
signal refresh_counter  : std_logic_vector (15 downto 0);
signal segActiveCnt     : std_logic_vector (2 downto  0);
signal btnCntL          : std_logic_vector (3 downto  0);
signal btnCntU          : std_logic_vector (2 downto  0) := "000";
signal di_valid         : std_logic;
signal fastCnt          : std_logic_vector(3 downto 0);
signal fastCounter      : std_logic;
signal clk_din          : std_logic;
signal btnR_i           : std_logic;
signal inp_btnU         : std_logic := '0';
signal inp_btnL         : std_logic := '0';

--Kris's ebouncing code
signal btn_d1   : std_logic;
signal btn_d2   : std_logic;
signal btn_d3   : std_logic;
signal btn_d4   : std_logic;
constant nbitCntSize  : integer := 20;
signal nbitCnt  : std_logic_vector(nbitCntSize downto 0) := (others => '0');
signal nbitCnt1  : std_logic_vector(nbitCntSize downto 0) := (others => '0');
signal xorBtn : std_logic;
signal xorBtn1 : std_logic;

signal jmp_d    : std_logic;
signal branch_d : std_logic;

begin

clk <= fastCounter and proc_state; --This clock should only move if the we are in a processing state
clk_din <= fastCounter;

--================
--== DEBOUNCERS ==
--================

db_proc : process(clk100m)
begin
if rising_edge(clk100m) then
   btn_d1 <= btnU;
   btn_d2 <= btn_d1;
   if(xorBtn = '1') then            --reset counter because input is changing
     nbitCnt <= (others => '0');
   elsif(nbitCnt(nbitCntSize) = '0') then    --stable input time is not yet met
     nbitCnt <= nbitCnt + 1;
   else                             --stable input time is met
     inp_btnU <= btn_d2;
   end if;    
end if;
end process;
 
xorBtn <= btn_d1 xor btn_d2;   --determine when to start/reset counter

db_proc1 : process(clk100m)
begin
if rising_edge(clk100m) then
   btn_d3 <= btnL;
   btn_d4 <= btn_d3;
   if(xorBtn1 = '1') then            --reset counter because input is changing
     nbitCnt1 <= (others => '0');
   elsif(nbitCnt1(nbitCntSize) = '0') then    --stable input time is not yet met
     nbitCnt1 <= nbitCnt1 + 1;
   else                             --stable input time is met
     inp_btnL <= btn_d4;
   end if;    
end if;
end process;
 
xorBtn1 <= btn_d3 xor btn_d4;   --determine when to start/reset counter

--============
--== STATES ==
--============

process(RCState)
begin
if(RCState=KEY_GEN or RCState=ENC or RCState=DEC) then
    proc_state<='1';
else
    proc_state<='0';
end if;
end process;

state_machine : process(fastCounter, rst, key_inp_vld, halt, encdec_chosen)
begin
if(rst='1') then RCState<=PRE_KEY_GEN;
elsif(fastCounter'EVENT and fastCounter='1') then
    case RCState is
    when PRE_KEY_GEN    => led(15) <= '1';
                            led(14 DOWNTO 10) <= "00000"; 
                            if(key_inp_vld='1') then RCState <= KEY_GEN;
                           end if;
    when KEY_GEN        =>      led(15)<='0';
                                led(14)<='1';
                                led(13 DOWNTO 10) <= "0000";                          
                                if(halt='1') then 
                                RCState <= INP_RC;
                                --key_rdy <= '1';  
                           end if;
   when INP_RC          => led(15 DOWNTO 14) <= "00";
                            led(13) <= '1';
                            led(12 DOWNTO 10) <= "000";
                            if(rc_inp_vld='1') then RCState <= INP_RDY;
                           end if;
   when INP_RDY         => led(15 DOWNTO 13) <="000";
                            led(12) <='1';
                            led(11 DOWNTO 10) <= "00";
                                if(encdec_chosen='1') then 
                                case encdec is
                                    when '1' => RCState <= ENC;
                                    --when '0' => RCState <= PRE_DEC;
                                    when others => RCState <= DEC;--PRE_DEC;
                                end case;
                            end if;
   when ENC             => led(15 DOWNTO 12) <="0000";
                           led(11) <='1';
                            led(10) <= '0';
                            if(halt='1') then RCState <= INP_RC;
                           end if;
   when DEC             => led(15 DOWNTO 11) <= "00000";
                            led(10) <= '1';
                            if(halt='1') then RCState <= INP_RC;             
                           end if;
   end case;
end if;
end process;

--======================
--== DISPLAY ON BOARD ==
--======================

 process (fastCounter, jmp, branch, jmp_d, branch_d)
 begin
   if rising_edge(fastCounter) then
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
	jmp_d   <= '0';
	branch_d <= '0';
  elsif rising_edge(clk100m) then
	jmp_d <= jmp;
	branch_d <= branch;
  end if;
end process;

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
    if (fastCnt >= x"4") then 
      fastCnt <= (others => '0');
    else
      fastCnt <= fastCnt + 1;
    end if;
  end if;
end process;

fastCounter <= '1' when fastCnt = x"4" else '0';

--This process keeps count on how many times the left button has been pressed
btnCntL_proc : process (inp_btnL, rst)
begin
 if rst = '1' then
   btnCntL <= x"0";
 elsif rising_edge(clk100m) then
   if inp_btnL = '1' and last_inp_btnL = '0' then
     if btnCntL = x"7" then
        btnCntL <= x"0";
     else
        btnCntL <= btnCntL + 1;
     end if;
   end if;
   last_inp_btnL <= inp_btnL;
 end if;
end process;

--displays dout in 32 bit chunks everytime btnCntL is incremented
segDisplay_proc : process (btnCntL)
begin
 case btnCntL is 
   when x"7"   =>  display <= dout(31 downto  0); led(7 downto 4) <= x"8";
   when x"6"   =>  display <= dout(63 downto 32); led(7 downto 4) <= x"7";
   when x"5"   =>  display <= din (31 downto  0); led(7 downto 4) <= x"6";
   when x"4"   =>  display <= din (63 downto 32); led(7 downto 4) <= x"5";
   when x"3"   =>  display <= userkey(31 downto 0)  ; led(7 downto 4) <= x"4";
   when x"2"   =>  display <= userkey(63 downto 32)  ; led(7 downto 4) <= x"3";
   when x"1"   =>  display <= userkey(95 downto 64) ; led(7 downto 4) <= x"2";
   when x"0"  =>  display <= userkey(127 downto 96); led(7 downto 4) <= x"1";
   when others =>  NULL;
 end case;
end process;
	
newbtnCntU_proc : process(clk100m, rst,inp_btnU)
begin
	if(rst='1') then
	   btnCntU <= "000";
       key_inp_vld<='0';
       rc_inp_vld<='0';
	elsif(clk100m'EVENT and clk100m='1') then
    
      if(inp_btnU='1' and last_inp_btnU='0') then
            if(RCState=INP_RC) then 
               case btnCntU is
                 when "011"    =>  din(15 downto  0) <= sw(15 downto 0); led(3 downto 0) <= x"4";
                 when "010"    =>  din(31 downto 16) <= sw(15 downto 0); led(3 downto 0) <= x"3";
                 when "001"    =>  din(47 downto 32) <= sw(15 downto 0); led(3 downto 0) <= x"2";
                 when "000"    =>  din(63 downto 48) <= sw(15 downto 0); led(3 downto 0) <= x"1";
                 when others   =>  NULL;
               end case;
               
               if(btnCntU="011") then
                    btnCntU<="000";
                    rc_inp_vld<='1';
               else
                    btnCntU <= btnCntU + '1';
               end if;
             elsif(RCState=PRE_KEY_GEN) then
               case btnCntU is
                 when "111"    =>  userkey(15 downto  0) <= sw(15 downto 0); led(3 downto 0) <= x"8";
                 when "110"    =>  userkey(31 downto 16) <= sw(15 downto 0); led(3 downto 0) <= x"7";
                 when "101"    =>  userkey(47 downto 32) <= sw(15 downto 0); led(3 downto 0) <= x"6";
                 when "100"    =>  userkey(63 downto 48) <= sw(15 downto 0); led(3 downto 0) <= x"5";
                 when "011"    =>  userkey(79 downto  64) <= sw(15 downto 0); led(3 downto 0) <= x"4";
                 when "010"    =>  userkey(95 downto 80) <= sw(15 downto 0); led(3 downto 0) <= x"3";
                 when "001"    =>  userkey(111 downto 96) <= sw(15 downto 0); led(3 downto 0) <= x"2";
                 when "000"    =>  userkey(127 downto 112) <= sw(15 downto 0); led(3 downto 0) <= x"1";
                 when others    =>  NULL;
               end case;
               
               if(btnCntU="111") then
                        btnCntU<="000";
                        key_inp_vld<='1';
                else
                        btnCntU <= btnCntU + '1';
                end if;
          elsif(RCState=INP_RDY) then 
              encdec <= sw(0);
              encdec_chosen <= '1'; 
          end if;
          
          if (RCState/=INP_RDY) then
              encdec_chosen <= '0';
          end if;
          
          if (proc_state='1') then
             btnCntU <= "000";
             key_inp_vld<='0';
             rc_inp_vld<='0';
          end if;
          
      end if;
      last_inp_btnU <= inp_btnU;
          
end if;
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
result_mux : process (memtoReg, readData, dataMemAddr, rst, proc_state)
begin
  if rst = '1' or proc_state = '0' then
    result <= (others => '0');
  end if;
  
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
PC_mux : process (jmp, branch, PCbranch, PCplus4, PCjmp, PCSrc, proc_state, halt,rst)
begin
    if(proc_state = '0' or halt = '1' or rst='1') then
        PC <= (others=>'0');

	elsif(jmp = '1' and branch = '0') then
		PC <= PCjmp;
	elsif(jmp = '0') then
		if(PCSrc = '1') then
			PC <= PCbranch;
	    elsif (proc_state = '0' or halt = '1') then
		    PC <= (others=>'0');
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
  RCState      => RCState    ,
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
  RCState => RCState                   ,
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
  din           => din         , --din_d  ,
  dout          => dout        ,
  userKey       => userkey_d2  ,
  RCState       => RCState     ,
  ALUResult     => dataMemAddr , --in std_logic_vector(31 downto 0); --input address from ALU
  MemWrite      => memWrite    , --in std_logic; --write enable if memory to write
  WriteData     => rd2         , --in std_logic_vector(31 downto 0); --input of rd2
  ReadData      => readData      --out std_logic_vector(31 downto 0)
);

end top;