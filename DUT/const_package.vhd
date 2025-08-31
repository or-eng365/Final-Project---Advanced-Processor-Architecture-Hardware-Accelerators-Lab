---------------------------------------------------------------------------------------------
-- Copyright 2025 Hananya Ribo 
-- Advanced CPU architecture and Hardware Accelerators Lab 361-1-4693 BGU
---------------------------------------------------------------------------------------------
library IEEE;
use ieee.std_logic_1164.all;


package const_package is
---------------------------------------------------------
--	IDECODE constants
---------------------------------------------------------
	constant R_TYPE_OPC : 	STD_LOGIC_VECTOR(5 DOWNTO 0) := "000000";
	constant LUI_OPC : 		STD_LOGIC_VECTOR(5 DOWNTO 0) := "001111";
	constant LW_OPC : 		STD_LOGIC_VECTOR(5 DOWNTO 0) := "100011";
	constant SW_OPC : 		STD_LOGIC_VECTOR(5 DOWNTO 0) := "101011";
	constant BEQ_OPC : 		STD_LOGIC_VECTOR(5 DOWNTO 0) := "000100";
	constant BNEQ_OPC : 	STD_LOGIC_VECTOR(5 DOWNTO 0) := "000101";
	constant ANDI_OPC : 	STD_LOGIC_VECTOR(5 DOWNTO 0) := "001100";
	constant ADDU_OPC : 	STD_LOGIC_VECTOR(5 DOWNTO 0) := "100001";
	constant ADDUI_OPC : 	STD_LOGIC_VECTOR(5 DOWNTO 0) := "001001";
	constant ORI_OPC : 		STD_LOGIC_VECTOR(5 DOWNTO 0) := "001101";
	constant ADDI_OPC : 	STD_LOGIC_VECTOR(5 DOWNTO 0) := "001000";
	constant XORI_OPC :		std_logic_vector(5 downto 0) := "001110";
	constant STLI_OPC :		std_logic_vector(5 downto 0) := "001010";
	constant ADD_OPC :		std_logic_vector(5 downto 0) := "100000";
	constant SUBTRACT_OPC:	std_logic_vector (5 downto 0):= "100010";
	constant AND_OPC:		std_logic_vector (5 downto 0):= "100100";
	constant OR_OPC:		std_logic_vector (5 downto 0) := "100101";
	constant XOR_OPC:		std_logic_vector ( 5 downto 0):= "100110";
	constant SLL_OPC:		std_logic_vector (5 downto 0):= "000000";
	constant SRL_OPC:		std_logic_vector (5 downto 0):= "000010";
	constant JUMP_OPC:		std_logic_vector (5 downto 0):= "000010";
	constant JR_OPC:		std_logic_vector (5 downto 0):= "001000";
	constant JAL_OPC:		std_logic_vector (5 downto 0):= "000011";
	constant MUL_OPC:		std_logic_vector (5 downto 0):= "011100";
	
--------------------------------------------------------	
	
	
	

end const_package;