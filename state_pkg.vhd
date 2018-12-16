library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

PACKAGE state_pkg IS
    TYPE RCStateType is (PRE_KEY_GEN,
					KEY_GEN,
					INP_RC,
					INP_RDY,
					ENC,
					DEC);
END state_pkg;
