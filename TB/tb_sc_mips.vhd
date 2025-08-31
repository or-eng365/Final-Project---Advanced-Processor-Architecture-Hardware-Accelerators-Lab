---------------------------------------------------------------------------------------------
-- Copyright 2025 Hananya Ribo 
-- Advanced CPU architecture and Hardware Accelerators Lab 361-1-4693 BGU
---------------------------------------------------------------------------------------------
LIBRARY IEEE;
USE IEEE.STD_LOGIC_1164.ALL;
USE IEEE.STD_LOGIC_ARITH.ALL;
use ieee.std_logic_unsigned.all;
USE work.cond_comilation_package.all;
USE work.aux_package.all;


ENTITY MIPS_tb IS
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
END MIPS_tb ;


ARCHITECTURE struct OF MIPS_tb IS
	-- Internal signal declarations
	SIGNAL rst_tb_i           	: STD_LOGIC;
	SIGNAL clk_tb_i           	: STD_LOGIC;
	SIGNAL clk2_tb_i           	: STD_LOGIC;
	--- interrupts ---
	signal key1_tb_i	: std_logic:= '1';
	signal key2_tb_i	: std_logic := '1';
	signal key3_tb_i	: std_logic := '1';
	--- GPIO ---
	SIGNAL sw_tb_i    	: std_logic_vector(7 downto 0) := (others => '0');
	SIGNAL hex0_tb_o 	 : std_logic_vector(6 downto 0);
	SIGNAL hex1_tb_o  	: std_logic_vector(6 downto 0);
	SIGNAL hex2_tb_o  	: std_logic_vector(6 downto 0);
	SIGNAL hex3_tb_o  	: std_logic_vector(6 downto 0);
	SIGNAL hex4_tb_o  	: std_logic_vector(6 downto 0);
	SIGNAL hex5_tb_o  	: std_logic_vector(6 downto 0);
	SIGNAL led_tb_o  	: std_logic_vector(7 downto 0);
	signal pc_tb_o	  	:	 std_logic_vector(PC_WIDTH-1 downto 0);
	signal instruction_o:std_logic_vector (DATA_BUS_WIDTH-1 downto 0);
	signal data_bus_o   :  std_logic_vector (DATA_BUS_WIDTH-1 downto 0) ;
    signal address_bus_o: std_logic_vector (12-1 downto 0);
	signal mem_wr_o		:std_logic;
	signal mem_rd_o		: std_logic;
	signal alu_result_o 		:	STD_LOGIC_VECTOR(DATA_BUS_WIDTH-1 DOWNTO 0);
	signal read_data1_o 		:	STD_LOGIC_VECTOR(DATA_BUS_WIDTH-1 DOWNTO 0);
	signal read_data2_o 		:	STD_LOGIC_VECTOR(DATA_BUS_WIDTH-1 DOWNTO 0);
	signal write_data_o		:	STD_LOGIC_VECTOR(DATA_BUS_WIDTH-1 DOWNTO 0);
	signal Branch_ctrl_o		:	STD_LOGIC;
	signal Zero_o				: 	STD_LOGIC; 
	signal RegWrite_ctrl_o		: 	STD_LOGIC;
	signal inst_cnt_o 			:	STD_LOGIC_VECTOR(INST_CNT_WIDTH-1 DOWNTO 0);
	signal pwm_tb_o				: std_logic;
	signal ifg_tb_o				: std_logic_vector(7 downto 0);

   
BEGIN
	CORE : mcu
	generic map(
		WORD_GRANULARITY 			=> WORD_GRANULARITY,
	    MODELSIM 					=> MODELSIM,
		DATA_BUS_WIDTH				=> DATA_BUS_WIDTH,
		ITCM_ADDR_WIDTH				=> ITCM_ADDR_WIDTH,
		DTCM_ADDR_WIDTH				=> DTCM_ADDR_WIDTH,
		PC_WIDTH					=> PC_WIDTH,
		FUNCT_WIDTH					=> FUNCT_WIDTH,
		DATA_WORDS_NUM				=> DATA_WORDS_NUM,
		CLK_CNT_WIDTH				=> CLK_CNT_WIDTH,
		INST_CNT_WIDTH				=> INST_CNT_WIDTH
		
	)
	PORT MAP (
		rst_i           	=> rst_tb_i,
		clk_i           	=> clk_tb_i,
		--- interrupts ---
		key1_i				=> key1_tb_i,
		key2_i				=> key2_tb_i,
		key3_i				=> key3_tb_i,
		--- GPIO ---
		sw_i  				=> sw_tb_i,
		hex0_o				=> hex0_tb_o,
		hex1_o				=> hex1_tb_o,
		hex2_o				=> hex2_tb_o,
		hex3_o				=> hex3_tb_o,
		hex4_o				=> hex4_tb_o,
		hex5_o				=> hex5_tb_o,
		led_o				=> led_tb_o,
		pc_o 				=> pc_tb_o,
		instruction_o		=> instruction_o,
		ifg_o				=> ifg_tb_o,
		data_bus_o			=> data_bus_o,
		-- address_bus_o		=>address_bus_o,
		-- mem_wr_o			=> mem_wr_o,
		-- mem_rd_o			=> mem_rd_o,
		-- Branch_ctrl_o  		=> Branch_ctrl_o,
        -- Zero_o          	=> Zero_o,
        -- RegWrite_ctrl_o 	=> RegWrite_ctrl_o,
        -- alu_result_o    	=> alu_result_o,
        -- read_data1_o    	=> read_data1_o,
        -- read_data2_o    	=> read_data2_o,
        -- inst_cnt_o  		=> inst_cnt_o,
        -- write_data_o		=> write_data_o,
		pwm_o				=> pwm_tb_o
	);	
--------------------------------------------------------------------	
	gen_clk : 
	process
        begin
		  clk_tb_i <= '1';
		  wait for 10 ns;
		  clk_tb_i <= not clk_tb_i;
		  wait for 10 ns;
    end process;

	gen_clk2 : 
	process
        begin
		  clk2_tb_i <= '1';
		  wait for 50 ns;
		  clk2_tb_i <= not clk2_tb_i;
		  wait for 50 ns;
    end process;
	
	gen_rst : 
	process
        begin
		rst_tb_i <= '0';
		wait for 100 ns;
		rst_tb_i <= '1';
		-- wait for 100 ns;
		-- rst_tb_i <= '1';
		
	  wait;
    end process;

	KEYS :
	process
  begin
	sw_tb_i(1) <= '1';
	wait for 2000 ns;
	key1_tb_i <= '1';
	key2_tb_i <= '1';
	key3_tb_i <= '0';
	-- wait for 400 ns;
	-- sw_tb_i(0) <= '1';
	-- key1_tb_i <= '0';
	-- key2_tb_i <= '1';
	-- key3_tb_i <= '1';
	-- wait for 100 ns;
	-- sw_tb_i(2) <= '1';
	-- key1_tb_i <= '1';
	-- key2_tb_i <= '1';
	-- key3_tb_i <= '1';
	-- sw_tb_i(3)  <= '1';
	-- wait for 2000 ns;
	-- key1_tb_i <= '1';
	-- key2_tb_i <= '0';
	-- key3_tb_i <= '1';
	-- wait for 100 ns;
	-- key1_tb_i <= '1';
	-- key2_tb_i <= '1';
	-- key3_tb_i <= '1';
	-- key1_tb_i <= '1';
	-- key2_tb_i <= '1';
	-- wait for 100 ns;
	-- sw_tb_i(0) <= '0';
	-- key1_tb_i <= '0';
	-- key2_tb_i <= '0';

	-- wait for 3000 ns;
	-- key2_tb_i <= '1';
	-- wait for 100 ns;
	-- key2_tb_i <= '0';
	
	-- wait for 3000 ns;
	-- key3_tb_i <= '1';
	-- wait for 100 ns;
	-- key3_tb_i <= '0';
	wait;
  end process;
--------------------------------------------------------------------		
END struct;
