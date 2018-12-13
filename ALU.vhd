--Added BEQ in SUB. Added BLT and BNE in seperate if condition. Added Load/Store in ADD. 
--Commented out ALUresult when branching. I don't think we need to output a result .

LIBRARY IEEE;
USE IEEE.STD_LOGIC_1164.ALL;
use IEEE.numeric_std.all;
USE IEEE.STD_LOGIC_UNSIGNED.ALL; 




entity ALU is
port ( 


ALUControl: in std_logic_vector(2 downto 0);
SrcA:in std_logic_vector(31 downto 0);
SrcB:in std_logic_vector(31 downto 0);
Zero: out std_logic;
ALUResult: out std_logic_vector(31 downto 0));


end ALU;
architecture do_it of ALU is
signal AluOut: std_logic_vector(31 downto 0);
signal zeroo: std_logic;

Begin
PROCESS(ALUControl,SrcA,SrcB)
BEGIN



IF ALUControl="000" then-- ADD/STORE/LOAD

AluOut<=SrcA + SrcB;
zeroo<='0';
end if;


IF ALUControl="001" then--SUBTRACT
  if SrcA = SrcB then
    zeroo <= '1';
	AluOut<=SrcA - SrcB; --+ NOT(SrcB) + '1';
  else
    AluOut<=SrcA - SrcB;--+ NOT(SrcB) + '1';
    zeroo<='0';
  end if;
end if;

IF ALUControl="010" then--AND/JMP

AluOut<=SrcA AND SrcB;
--zeroo<='1'; --set zero flag if jump
end if;

IF ALUControl="011" then--OR

AluOut<=SrcA OR SrcB;
zeroo<='0';
end if;

IF ALUControl="100" then--NOR

AluOut<=SrcA NOR SrcB;
zeroo<='0';
end if;


IF ALUControl="101" then--LSHIFT


CASE SrcB(4 DOWNTO 0) IS
WHEN "00001"=> AluOut<= SrcA(30 DOWNTO 0)&"0";
WHEN "00010"=> AluOut<=SrcA(29 DOWNTO 0)&"00";
WHEN "00011"=> AluOut<= SrcA(28 DOWNTO 0) &"000";
WHEN "00100"=> AluOut<= SrcA(27 DOWNTO 0) & "0000";
WHEN "00101"=> AluOut<= SrcA(26 DOWNTO 0) & "00000";
WHEN "00110"=> AluOut<= SrcA(25 DOWNTO 0) & "000000";
WHEN "00111" => AluOut<= SrcA(24 DOWNTO 0) & "0000000";
WHEN "01000" => AluOut<= SrcA(23 DOWNTO 0) & "00000000";
WHEN "01001" => AluOut<= SrcA(22 DOWNTO 0) & "000000000";
WHEN "01010" => AluOut<= SrcA(21 DOWNTO 0) & "0000000000";
WHEN "01011" => AluOut<= SrcA(20 DOWNTO 0) & "00000000000";
WHEN "01100" => AluOut<= SrcA(19 DOWNTO 0) & "000000000000";
WHEN "01101" => AluOut<= SrcA(18 DOWNTO 0) & "0000000000000";
WHEN "01110" => AluOut<= SrcA(17 DOWNTO 0) & "00000000000000";
WHEN "01111" => AluOut<= SrcA(16 DOWNTO 0) & "000000000000000";
WHEN "10000" => AluOut<= SrcA(15 DOWNTO 0) & "0000000000000000";
WHEN "10001" =>AluOut<= SrcA(14 DOWNTO 0) & "00000000000000000";
WHEN "10010" =>AluOut<= SrcA(13 DOWNTO 0) & "000000000000000000";
WHEN "10011" =>AluOut<= SrcA(12 DOWNTO 0) & "0000000000000000000";
WHEN "10100" =>AluOut<= SrcA(11 DOWNTO 0) & "00000000000000000000";
WHEN "10101" =>AluOut<= SrcA(10 DOWNTO 0) & "000000000000000000000";
WHEN "10110" =>AluOut<= SrcA(9 DOWNTO 0) & "0000000000000000000000";
WHEN "10111" =>AluOut<= SrcA(8 DOWNTO 0) & "00000000000000000000000";
WHEN "11000" =>AluOut<= SrcA(7 DOWNTO 0) & "000000000000000000000000";
WHEN "11001" =>AluOut<= SrcA(6 DOWNTO 0) & "0000000000000000000000000";
WHEN "11010" =>AluOut<= SrcA(5 DOWNTO 0) & "00000000000000000000000000";
WHEN "11011" =>AluOut<= SrcA(4 DOWNTO 0) & "000000000000000000000000000";
WHEN "11100" =>AluOut<= SrcA(3 DOWNTO 0) & "0000000000000000000000000000";
WHEN "11101" =>AluOut<= SrcA(2 DOWNTO 0) & "00000000000000000000000000000";
WHEN "11110" =>AluOut<= SrcA(1 DOWNTO 0) & "000000000000000000000000000000";
WHEN "11111" =>AluOut<= SrcA(0) & "0000000000000000000000000000000";
WHEN OTHERS =>AluOut<="00000000000000000000000000000000";
END CASE;

zeroo<='0';


end if;


IF ALUControl="110" then --  BRANCH LESS THAN

--AluOut<=x"ffffffff";
    if SrcA <SrcB then
    zeroo<='1';
    else   
    zeroo<='0';
    end if;
end if;

IF ALUControl="111" then --BRANCH NOT EQUAL
--AluOut<=x"ffffffff";
    if SrcA /=SrcB then
    zeroo<='1';
    else   
    zeroo<='0';
    end if;
end if;







END PROCESS;
AluResult<=AluOut;
Zero<=zeroo;

End do_it;