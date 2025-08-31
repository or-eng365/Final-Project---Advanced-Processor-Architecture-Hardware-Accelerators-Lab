---------------------------------------------------------------------------------------------
-- Copyright 2025 Hananya Ribo 
-- Advanced CPU architecture and Hardware Accelerators Lab 361-1-4693 BGU
---------------------------------------------------------------------------------------------
-- Top Level Structural Model for MIPS Processor Core
LIBRARY IEEE;
USE IEEE.STD_LOGIC_1164.ALL;
USE IEEE.STD_LOGIC_ARITH.ALL;
use ieee.std_logic_unsigned.all;
USE work.cond_comilation_package.all;
USE work.aux_package.all;


ENTITY MIPS IS
	generic( 
		WORD_GRANULARITY : boolean 	:= G_WORD_GRANULARITY;
		MODELSIM : integer 			:= G_MODELSIM;
		DATA_BUS_WIDTH : integer 	:= 32;
		ITCM_ADDR_WIDTH : integer 	:= G_ADDRWIDTH;
		DTCM_ADDR_WIDTH : integer 	:= 12;
		PC_WIDTH : integer 			:= 10;
		FUNCT_WIDTH : integer 		:= 6;
		DATA_WORDS_NUM : integer 	:= G_DATA_WORDS_NUM;
		CLK_CNT_WIDTH : integer 	:= 16;
		INST_CNT_WIDTH : integer 	:= 16
	);
	PORT(	
		rst_i		 		:IN	STD_LOGIC;
		clk_i				:IN	STD_LOGIC; 
		-- Output important signals to pins for easy display in SignalTap
		pc_o				:OUT	STD_LOGIC_VECTOR(PC_WIDTH-1 DOWNTO 0);
		alu_result_o 		:OUT	STD_LOGIC_VECTOR(DATA_BUS_WIDTH-1 DOWNTO 0);
		read_data1_o 		:OUT	STD_LOGIC_VECTOR(DATA_BUS_WIDTH-1 DOWNTO 0);
		read_data2_o 		:OUT	STD_LOGIC_VECTOR(DATA_BUS_WIDTH-1 DOWNTO 0);
		write_data_o		:OUT	STD_LOGIC_VECTOR(DATA_BUS_WIDTH-1 DOWNTO 0);
		instruction_o		:OUT	STD_LOGIC_VECTOR(DATA_BUS_WIDTH-1 DOWNTO 0);
		Branch_ctrl_o		:OUT 	STD_LOGIC;
		Zero_o				:OUT 	STD_LOGIC; 
		RegWrite_ctrl_o		:OUT 	STD_LOGIC;
		mclk_cnt_o			:OUT	STD_LOGIC_VECTOR(CLK_CNT_WIDTH-1 DOWNTO 0);
		inst_cnt_o 			:OUT	STD_LOGIC_VECTOR(INST_CNT_WIDTH-1 DOWNTO 0);
		--- tri-bus ---
		data_bus_io			: inout std_logic_vector(DATA_BUS_WIDTH-1 downto 0);
		addr_bus_o			: out	std_logic_vector(DTCM_ADDR_WIDTH-1 downto 0);
		MemWrite_ctrl_o		: out	std_logic;
		MemRead_ctrl_o		: out	std_logic;
		--- interrupts ---
		INTR_i				: in	std_logic;
		INTA_o				: out	std_logic;
		GIE_o				: out	std_logic
	);		
END MIPS;
-------------------------------------------------------------------------------------
ARCHITECTURE structure OF MIPS IS
	-- declare signals used to connect VHDL components
	SIGNAL pc_plus4_w 		: STD_LOGIC_VECTOR(PC_WIDTH-1 DOWNTO 0);
	SIGNAL read_data1_w 	: STD_LOGIC_VECTOR(DATA_BUS_WIDTH-1 DOWNTO 0);
	SIGNAL read_data2_w 	: STD_LOGIC_VECTOR(DATA_BUS_WIDTH-1 DOWNTO 0);
	SIGNAL sign_extend_w 	: STD_LOGIC_VECTOR(DATA_BUS_WIDTH-1 DOWNTO 0);
	SIGNAL addr_res_w 		: STD_LOGIC_VECTOR(7 DOWNTO 0 );
	SIGNAL alu_result_w 	: STD_LOGIC_VECTOR(DATA_BUS_WIDTH-1 DOWNTO 0);
	SIGNAL dtcm_data_rd_w 	: STD_LOGIC_VECTOR(DATA_BUS_WIDTH-1 DOWNTO 0);
	SIGNAL alu_src_w 		: STD_LOGIC;
	SIGNAL branch_w 		: STD_LOGIC;
	signal branchN_w		: std_logic;
	SIGNAL reg_dst_w 		: std_logic_vector(1 downto 0);
	SIGNAL reg_write_w 		: STD_LOGIC;
	SIGNAL zero_w 			: STD_LOGIC;
	SIGNAL mem_write_w 		: STD_LOGIC;
	SIGNAL MemtoReg_w 		: std_logic_vector(1 downto 0);
	SIGNAL mem_read_w 		: STD_LOGIC;
	signal Jump_ctrl_w		: std_logic;
	signal JR_ctrl_w		: std_logic;
	signal Jal_ctrl_w		: std_logic;
	SIGNAL alu_op_w 		: STD_LOGIC_VECTOR(1 DOWNTO 0);
	SIGNAL instruction_w	: STD_LOGIC_VECTOR(DATA_BUS_WIDTH-1 DOWNTO 0);
	SIGNAL mclk_cnt_q		: STD_LOGIC_VECTOR(CLK_CNT_WIDTH-1 DOWNTO 0);
	SIGNAL inst_cnt_w		: STD_LOGIC_VECTOR(INST_CNT_WIDTH-1 DOWNTO 0);
	--- tri_bus ---
	signal mem_read_en_w	: std_logic;
	--- interrupts ---
	signal next_addr_w		: std_logic_vector(PC_WIDTH-1 downto 0);
	signal f_inst_w			: std_logic_vector (DATA_BUS_WIDTH-1 downto 0);
	signal int_type_addr_w	: std_logic_vector(DATA_BUS_WIDTH-1 downto 0);
	signal mod_jr_w			: std_logic_vector(DATA_BUS_WIDTH-1 downto 0) := X"03600008";
	signal mod_lw_start_w	: std_logic_vector(15 downto 0) := X"8C1B";
	signal nop_inst_w		: std_logic_vector(DATA_BUS_WIDTH-1 downto 0) := X"00000020";
	signal inta_w			: std_logic := '1';
	signal d_gie_w			: std_logic;
	signal m_gie_w			: std_logic := '1';
	signal cur_inst_w		: std_logic_vector(1 downto 0) := "00";
	signal not_in_intr_w	: boolean := true;
	signal fetch_ena_w  	: boolean := true;

BEGIN
	-- copy important signals to output pins for easy 
	-- display in Simulator
   instruction_o 		<= 	instruction_w;
   alu_result_o 		<= 	alu_result_w;
   read_data1_o 		<= 	read_data1_w;
   read_data2_o 		<= 	read_data2_w;
   write_data_o  		<= 	dtcm_data_rd_w WHEN MemtoReg_w = "01" ELSE 
							alu_result_w;
							
   Branch_ctrl_o 		<= 	branch_w;
   Zero_o 				<= 	zero_w;
   RegWrite_ctrl_o 		<= 	reg_write_w;	

	--- tri bus ---
	mem_read_en_w 	<= mem_read_w and not(alu_result_w(DTCM_ADDR_WIDTH-1));
	data_bus_io 	<= dtcm_data_rd_w when (mem_read_en_w='1' and (not_in_intr_w or cur_inst_w="01")) else 
						read_data2_w when (mem_write_w='1' and not_in_intr_w) else
						(others=>'Z');
	addr_bus_o 		<= alu_result_w(DTCM_ADDR_WIDTH-1 DOWNTO 0) when (mem_read_w = '1' or mem_write_w='1') else
						(others =>'0'); 
	MemRead_ctrl_o 	<= mem_read_w;
	MemWrite_ctrl_o	<= 	mem_write_w;

	--- interrupts ---
	int_ack: process(INTR_i, clk_i)
	begin
		if (rst_i='1') then
			inta_w <= '1';
			m_gie_w <= '1';
			not_in_intr_w <= true;
			fetch_ena_w   <= true;
		elsif (rising_edge(clk_i)) then
			if (INTR_i='1') then
				inta_w <= '0';
				m_gie_w <= '0';
				not_in_intr_w <= false;
				fetch_ena_w   <= false;
			elsif (inta_w='0') then
				inta_w <= '1';
			elsif (cur_inst_w = "01" ) then
				fetch_ena_w <= true;
			elsif (cur_inst_w = "10") then
				not_in_intr_w <= true;
			elsif (instruction_w=mod_jr_w and not_in_intr_w) then
				m_gie_w <= '1';
			end if;
		end if;
	end process;

	intr_inst: process (rst_i, clk_i, not_in_intr_w)
	begin
		if (rst_i='1') then
			cur_inst_w <= "00";
		elsif (rising_edge(clk_i)) then
			if (not(not_in_intr_w)) then
				if (cur_inst_w="00") then
					cur_inst_w <= "01"; 
				elsif (cur_inst_w = "01") then
					cur_inst_w <= "10";
				elsif (cur_inst_w = "10") then
					cur_inst_w <= "00";
				end if;
			end if;
		end if;
	end process;

	int_type_addr_w <= data_bus_io when inta_w='0' else int_type_addr_w;
	instruction_w <= f_inst_w when (not_in_intr_w) else 
						nop_inst_w when cur_inst_w = "00" else
						mod_lw_start_w & X"00" & int_type_addr_w(7 downto 0) when cur_inst_w = "01" else
						mod_jr_w when cur_inst_w = "10";
	INTA_o <= inta_w;
	GIE_o <= m_gie_w and d_gie_w;
	
	-- connect the 5 MIPS components   
	IFE : Ifetch
	generic map(
		WORD_GRANULARITY	=> 	WORD_GRANULARITY,
		DATA_BUS_WIDTH		=> 	DATA_BUS_WIDTH, 
		PC_WIDTH			=>	PC_WIDTH,
		ITCM_ADDR_WIDTH		=>	ITCM_ADDR_WIDTH,
		WORDS_NUM			=>	256,
		INST_CNT_WIDTH		=>	INST_CNT_WIDTH
	)
	PORT MAP (	
		clk_i 			=> clk_i,  
		rst_i 			=> rst_i, 
		ena_i			=> fetch_ena_w,
		add_result_i 	=> addr_res_w,
		Branch_ctrl_i 	=> branch_w,
		BranchN_ctrl_i	=> branchN_w,
		Jump_ctrl_i		=> Jump_ctrl_w,
		JR_ctrl_i		=> JR_ctrl_w,
		zero_i 			=> zero_w,
		pc_o 			=> pc_o,
		instruction_o 	=> f_inst_w,
    	pc_plus4_o	 	=> pc_plus4_w,
		inst_cnt_o		=> inst_cnt_w,
		next_addr_o		=> next_addr_w
	);

	ID : Idecode
   	generic map(
		DATA_BUS_WIDTH		=>  DATA_BUS_WIDTH
	)
	PORT MAP (	
			clk_i 				=> clk_i,  
			rst_i 				=> rst_i,
        	instruction_i 		=> instruction_w,
			alu_result_i 		=> alu_result_w,
			RegWrite_ctrl_i 	=> reg_write_w,
			MemtoReg_ctrl_i 	=> MemtoReg_w,
			RegDst_ctrl_i 		=> reg_dst_w,
			Jal_ctrl_i			=> Jal_ctrl_w,
			pc_plus_4_i			=> pc_plus4_w,
			next_addr_i			=> next_addr_w,
			in_intr_i			=> not not_in_intr_w,
			read_data1_o 		=> read_data1_w,
        	read_data2_o 		=> read_data2_w,
			sign_extend_o 		=> sign_extend_w,
			gie_o				=> d_gie_w,
			data_bus_i			=> data_bus_io 
		);

	CTL:   control
	PORT MAP ( 	
			opcode_i 			=> instruction_w(DATA_BUS_WIDTH-1 DOWNTO 26),
			funct_i				=> instruction_w(5 downto 0),
			in_intr_i			=> not(not_in_intr_w),
			Jump_ctrl_o			=> Jump_ctrl_w,
			JR_ctrl_o			=> JR_ctrl_w,
			Jal_ctrl_o			=> Jal_ctrl_w,
			RegDst_ctrl_o 		=> reg_dst_w,
			ALUSrc_ctrl_o 		=> alu_src_w,
			MemtoReg_ctrl_o 	=> MemtoReg_w,
			RegWrite_ctrl_o 	=> reg_write_w,
			MemRead_ctrl_o 		=> mem_read_w,
			MemWrite_ctrl_o 	=> mem_write_w,
			Branch_ctrl_o 		=> branch_w,
			branchN_ctrl_o		=> branchN_w,
			ALUOp_ctrl_o 		=> alu_op_w
		);

	EXE:  Execute
   	generic map(
		DATA_BUS_WIDTH 		=> 	DATA_BUS_WIDTH,
		FUNCT_WIDTH 		=>	FUNCT_WIDTH,
		PC_WIDTH 			=>	PC_WIDTH
	)
	PORT MAP (	
		pc_plus4_i		=> pc_plus4_w,
		instruction_i	=> instruction_w,
		opcode_i		=> instruction_w(DATA_BUS_WIDTH-1 downto 26),
		read_data1_i 	=> read_data1_w,
        read_data2_i 	=> read_data2_w,
		sign_extend_i 	=> sign_extend_w,
        funct_i			=> instruction_w(5 DOWNTO 0),
		ALUOp_ctrl_i 	=> alu_op_w,
		ALUSrc_ctrl_i 	=> alu_src_w,
		Jump_ctrl_i		=> Jump_ctrl_w,
		JR_ctrl_i		=> JR_ctrl_w,
		zero_o 			=> zero_w,
        alu_res_o		=> alu_result_w,
		addr_res_o 		=> addr_res_w			
	);

	G1: 
	if (WORD_GRANULARITY = True) generate -- i.e. each WORD has a unike address
		MEM:  dmemory
			generic map(
				DATA_BUS_WIDTH		=> 	DATA_BUS_WIDTH, 
				DTCM_ADDR_WIDTH		=> 	DTCM_ADDR_WIDTH,
				WORDS_NUM			=>	DATA_WORDS_NUM
			)
			PORT MAP (	
				clk_i 				=> clk_i,  
				rst_i 				=> rst_i,
				dtcm_addr_i 		=> alu_result_w((DTCM_ADDR_WIDTH+2)-1 DOWNTO 2), -- increment memory address by 4
				dtcm_data_wr_i 		=> read_data2_w,
				MemRead_ctrl_i 		=> mem_read_w, 
				MemWrite_ctrl_i 	=> mem_write_w,
				dtcm_data_rd_o 		=> dtcm_data_rd_w 
			);	
	elsif (WORD_GRANULARITY = False) generate -- i.e. each BYTE has a unike address	
		MEM:  dmemory
			generic map(
				DATA_BUS_WIDTH		=> 	DATA_BUS_WIDTH, 
				DTCM_ADDR_WIDTH		=> 	DTCM_ADDR_WIDTH,
				WORDS_NUM			=>	DATA_WORDS_NUM
			)
			PORT MAP (	
				clk_i 				=> clk_i,  
				rst_i 				=> rst_i,
				dtcm_addr_i 		=> alu_result_w(DTCM_ADDR_WIDTH-1 DOWNTO 2)&"00",
				dtcm_data_wr_i 		=> read_data2_w,
				MemRead_ctrl_i 		=> mem_read_w, 
				MemWrite_ctrl_i 	=> mem_write_w,
				dtcm_data_rd_o 		=> dtcm_data_rd_w
			);
	end generate;
---------------------------------------------------------------------------------------
--									IPC - MCLK counter register
---------------------------------------------------------------------------------------
process (clk_i , rst_i)
begin
	if rst_i = '1' then
		mclk_cnt_q	<=	(others	=> '0');
	elsif rising_edge(clk_i) then
		mclk_cnt_q	<=	mclk_cnt_q + '1';
	end if;
end process;

mclk_cnt_o	<=	mclk_cnt_q;
inst_cnt_o	<=	inst_cnt_w;
---------------------------------------------------------------------------------------
END structure;

