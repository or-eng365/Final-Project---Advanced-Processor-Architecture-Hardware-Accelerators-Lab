---------------------------------------------------------------------------------------------
-- Copyright 2025 Hananya Ribo 
-- Advanced CPU architecture and Hardware Accelerators Lab 361-1-4693 BGU
---------------------------------------------------------------------------------------------
--  Idecode module (implements the register file for the MIPS computer
LIBRARY IEEE; 		
USE IEEE.STD_LOGIC_1164.ALL;
USE IEEE.STD_LOGIC_ARITH.ALL;
USE IEEE.STD_LOGIC_UNSIGNED.ALL;


ENTITY Idecode IS
	generic(
		DATA_BUS_WIDTH : integer := 32;
		PC_WIDTH		: integer := 10
	);
	PORT(	clk_i,rst_i		: IN 	STD_LOGIC;
			instruction_i 	: IN 	STD_LOGIC_VECTOR(DATA_BUS_WIDTH-1 DOWNTO 0);
			alu_result_i	: IN 	STD_LOGIC_VECTOR(DATA_BUS_WIDTH-1 DOWNTO 0);
			RegWrite_ctrl_i : IN 	std_logic;
			MemtoReg_ctrl_i : IN 	STD_LOGIC_VECTOR(1 downto 0);
			RegDst_ctrl_i 	: IN 	std_logic_vector(1 downto 0);
			Jal_ctrl_i		: in	std_logic;
			pc_plus_4_i		: in 	std_logic_vector(PC_WIDTH-1 downto 0);
			--- interrupts ---
			next_addr_i		: in 	std_logic_vector(PC_WIDTH-1 downto 0);
			in_intr_i		: in    boolean;
			--- out signal ---
			read_data1_o	: OUT 	STD_LOGIC_VECTOR(DATA_BUS_WIDTH-1 DOWNTO 0);
			read_data2_o	: OUT 	STD_LOGIC_VECTOR(DATA_BUS_WIDTH-1 DOWNTO 0);
			sign_extend_o 	: OUT 	STD_LOGIC_VECTOR(DATA_BUS_WIDTH-1 DOWNTO 0);
			gie_o			: out	std_logic;
			--- tri bus ---
			data_bus_i 		: in std_logic_vector(DATA_BUS_WIDTH-1 downto 0)	 
	);
END Idecode;


ARCHITECTURE behavior OF Idecode IS
TYPE register_file IS ARRAY (0 TO 31) OF STD_LOGIC_VECTOR(DATA_BUS_WIDTH-1 DOWNTO 0);

	SIGNAL RF_q					: register_file;
	SIGNAL write_reg_addr_w 	: STD_LOGIC_VECTOR( 4 DOWNTO 0 );
	SIGNAL write_reg_data_w		: STD_LOGIC_VECTOR( DATA_BUS_WIDTH-1 DOWNTO 0 );
	SIGNAL write_reg_mux_w		: STD_LOGIC_VECTOR( DATA_BUS_WIDTH-1 DOWNTO 0 );
	SIGNAL lui_value_w			: STD_LOGIC_VECTOR( DATA_BUS_WIDTH-1 DOWNTO 0 );
	SIGNAL rs_register_w		: STD_LOGIC_VECTOR( 4 DOWNTO 0 );
	SIGNAL rt_register_w		: STD_LOGIC_VECTOR( 4 DOWNTO 0 );
	SIGNAL rd_register_w		: STD_LOGIC_VECTOR( 4 DOWNTO 0 );
	SIGNAL imm_value_w			: STD_LOGIC_VECTOR( 15 DOWNTO 0 );
	signal zero_vec_w			: std_logic_vector(DATA_BUS_WIDTH-1 downto PC_WIDTH) := (others=>'0');
	signal zero_vec2_w			: std_logic_vector(15 downto 0) := (others=>'0');

BEGIN
	rs_register_w 			<= instruction_i(25 DOWNTO 21);
   	rt_register_w 			<= instruction_i(20 DOWNTO 16);
   	rd_register_w			<= instruction_i(15 DOWNTO 11);
   	imm_value_w 			<= instruction_i(15 DOWNTO 0);
	
	-- Read Register 1 Operation
	read_data1_o <= RF_q(CONV_INTEGER(rs_register_w));
	
	-- Read Register 2 Operation		 
	read_data2_o <= RF_q(CONV_INTEGER(rt_register_w));
	
	-- Mux for Register Write Address
	write_reg_addr_w <= rd_register_w WHEN RegDst_ctrl_i = "01" ELSE
						"11111"	when RegDst_ctrl_i = "10" else
						"11011" when RegDst_ctrl_i = "11" else
						rt_register_w;

	-- load upper immediate
	lui_value_w <= instruction_i(15 downto 0) & zero_vec2_w;
	
	-- Mux to bypass data memory for Rformat instructions
	reg_data_mux: with MemtoReg_ctrl_i select
		write_reg_mux_w	<= alu_result_i(DATA_BUS_WIDTH-1 DOWNTO 0) WHEN "00",
							data_bus_i when "01",
							lui_value_w	when "10",
							(others=>'0') when others;

	write_reg_data_w <= zero_vec_w & next_addr_i when (Jal_ctrl_i = '1' and in_intr_i) else
						zero_vec_w & pc_plus_4_i when Jal_ctrl_i = '1' else
						write_reg_mux_w;
	
	-- Sign Extend 16-bits to 32-bits
    sign_extend_o <= 	X"0000" & imm_value_w WHEN imm_value_w(15) = '0' ELSE
						X"FFFF" & imm_value_w;

	--- set GIE bit in $k0[0] ---
	gie_o <= RF_q(26)(0);

	process(clk_i,rst_i)
	begin
		if (rst_i='1') then
			FOR i IN 0 TO 31 LOOP
				-- RF_q(i) <= CONV_STD_LOGIC_VECTOR(i,32);
				RF_q(i) <= CONV_STD_LOGIC_VECTOR(0,32);
			END LOOP;
		elsif (clk_i'event and clk_i='1') then
			if (RegWrite_ctrl_i = '1' AND write_reg_addr_w /= 0) then
				RF_q(CONV_INTEGER(write_reg_addr_w)) <= write_reg_data_w;
				-- index is integer type so we must use conv_integer for type casting
			end if;
		end if;
end process;

END behavior;





