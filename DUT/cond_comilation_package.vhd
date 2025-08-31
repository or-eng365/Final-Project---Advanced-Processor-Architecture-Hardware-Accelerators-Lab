---------------------------------------------------------------------------------------------
-- Copyright 2025 Hananya Ribo 
-- Advanced CPU architecture and Hardware Accelerators Lab 361-1-4693 BGU
---------------------------------------------------------------------------------------------
library IEEE;
use ieee.std_logic_1164.all;


package cond_comilation_package is
---------------------------------------------------------
--	List of 4 local constants
---------------------------------------------------------
	constant MODELSIM_M9K_ADDRWIDTH : integer := 8;
	constant M4K_ADDRWIDTH : integer := 10;
	constant M4K_MEM_WORDS_NUM : integer := 1024;
	constant MODELSIM_M9K_MEM_WORDS_NUM : integer := 256;
--------------------------------------------------------	
	
	
	
--------------------------------------------------------
-- List of 4 DUT Conditional Compilation Global Constants
--------------------------------------------------------
--	if G_MODELSIM=1 then 
--		IDE=Modelsim 
--  elsif G_MODELSIM=0 then
--      IDE=Quartus
--------------------------------------------------------
--  if G_WORD_GRANULARITY=True then 
--		Each WORD has a unike address
--	elsif G_WORD_GRANULARITY=False
-- 		Each BYTE has a unike address
--------------------------------------------------------
--  if G_ADDRWIDTH=MODELSIM_M9K_ADDRWIDTH then
--		ITCM_ADDR_WIDTH=DTCM_ADDR_WIDTH=8
--	elsif  G_ADDRWIDTH=M4K_ADDRWIDTH then
--		ITCM_ADDR_WIDTH=DTCM_ADDR_WIDTH=10
--------------------------------------------------------
--	if G_DATA_WORDS_NUM=MODELSIM_M9K_ADDRWIDTH then
--		ITCM_WORDS_NUM=DTCM_WORDS_NUM=256
--	elsif  G_DATA_WORDS_NUM=M4K_MEM_WORDS_NUM then
--		ITCM_WORDS_NUM=DTCM_WORDS_NUM=1024
--------------------------------------------------------
	constant G_MODELSIM	: integer 			:= 1;
	constant G_WORD_GRANULARITY : boolean 	:= True;
	constant G_ADDRWIDTH : integer 			:= MODELSIM_M9K_ADDRWIDTH;
	constant G_DATA_WORDS_NUM : integer 	:= 1024;
--------------------------------------------------------

end cond_comilation_package;

