---------------------------------------------------------------------------------------------
-- Copyright 2025 Hananya Ribo 
-- Advanced CPU architecture and Hardware Accelerators Lab 361-1-4693 BGU
---------------------------------------------------------------------------------------------
-- control module (implements MIPS control unit)
LIBRARY IEEE;
USE IEEE.STD_LOGIC_1164.ALL;
USE IEEE.STD_LOGIC_ARITH.ALL;
USE IEEE.STD_LOGIC_SIGNED.ALL;
USE work.const_package.all;


ENTITY control IS
   PORT( 	
		opcode_i 			: IN 	STD_LOGIC_VECTOR(5 DOWNTO 0);
		funct_i				: in	STD_LOGIC_VECTOR(5 DOWNTO 0);
		in_intr_i			: in	boolean;
		RegDst_ctrl_o 		: OUT 	STD_LOGIC_vector(1 downto 0);
		ALUSrc_ctrl_o 		: OUT 	STD_LOGIC;
		MemtoReg_ctrl_o 	: OUT 	STD_LOGIC_VECTOR(1 downto 0);
		RegWrite_ctrl_o 	: OUT 	STD_LOGIC;
		MemRead_ctrl_o 		: OUT 	STD_LOGIC;
		MemWrite_ctrl_o	 	: OUT 	STD_LOGIC;
		Branch_ctrl_o 		: OUT 	STD_LOGIC;
		BranchN_ctrl_o		: out	std_logic;
		JR_ctrl_o			: out	std_logic;
		Jump_ctrl_o			: out	std_logic;
		Jal_ctrl_o			: out	std_logic;
		ALUOp_ctrl_o	 	: OUT 	STD_LOGIC_VECTOR(1 DOWNTO 0)
	);
END control;

ARCHITECTURE behavior OF control IS

	SIGNAL  rtype_w, lw_w, sw_w, beq_w, bneq_w, itype_imm_w, lui_w, jump_w, jr_w, jal_w, mul_w : STD_LOGIC;

BEGIN           
				-- Code to generate control signals using opcode bits
	lui_w 				<=  '1' WHEN	opcode_i = LUI_OPC			ELSE '0';
	rtype_w 			<=  '1'	WHEN	opcode_i = R_TYPE_OPC  		ELSE '0'; -- Rtype is 000000
	lw_w          		<=  '1'	WHEN  	opcode_i = LW_OPC  			ELSE '0';
 	sw_w          		<=  '1'	WHEN  	opcode_i = SW_OPC  			ELSE '0';
   	beq_w         		<=  '1'	WHEN  	opcode_i = BEQ_OPC 			ELSE '0';
	bneq_w         		<=  '1'	WHEN  	opcode_i = BNEQ_OPC   	    ELSE '0'; 
	itype_imm_w			<=	'1'	WHEN	((opcode_i = ADDI_OPC) or
										(opcode_i = ADDUI_OPC) or 
										( opcode_i = ORI_OPC)  or 
										( opcode_i = ANDI_OPC)	or
										( opcode_i = STLI_OPC)	or
										(opcode_i = XORI_OPC))		ELSE '0';
	jump_w				<=	'1' when 	opcode_i = JUMP_OPC			else '0';
	jr_w				<=	'1' when 	funct_i = JR_OPC			else '0';
	jal_w				<=	'1' when 	opcode_i = JAL_OPC			else '0';
	mul_w				<=	'1' when 	opcode_i = MUL_OPC			else '0';

							
  	RegDst_ctrl_o    	<=  "01" when ((rtype_w='1' or mul_w='1') and not(in_intr_i)) else "10" when jal_w='1' else "11" when (jr_w='1' and in_intr_i) else "00";
 	ALUSrc_ctrl_o  		<=  lw_w OR sw_w or itype_imm_w;
	MemtoReg_ctrl_o 	<=  "01" when lw_w='1' else "10" when lui_w='1' else "00";
  	RegWrite_ctrl_o 	<= '1' when ((rtype_w='1' and jr_w='0') OR lw_w='1' or itype_imm_w='1' or lui_w='1' or mul_w='1' or jal_w='1' or (jr_w='1' and in_intr_i)) else '0';
  	MemRead_ctrl_o 		<=  lw_w;
   	MemWrite_ctrl_o 	<=  sw_w; 
 	Branch_ctrl_o      	<=  beq_w;
	BranchN_ctrl_o      <=  bneq_w;
	Jump_ctrl_o			<=  jump_w or jal_w;
	Jal_ctrl_o			<=  '1' when (jal_w='1' or (jr_w='1' and in_intr_i)) else '0';
	JR_ctrl_o			<=  jr_w and rtype_w;
	
	ALUOp_ctrl_o(0) 	<=  beq_w OR bneq_w OR itype_imm_w;
	ALUOp_ctrl_o(1) 	<=  rtype_w OR itype_imm_w;
	
	-- 00 is not Rtype and not Branche
	-- 01 is Branch operation
	-- 10 is R_type 
	-- 11 is I_type


   END behavior;


