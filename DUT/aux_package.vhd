---------------------------------------------------------------------------------------------
-- Copyright 2025 Hananya Ribo 
-- Advanced CPU architecture and Hardware Accelerators Lab 361-1-4693 BGU
---------------------------------------------------------------------------------------------
library IEEE;
use ieee.std_logic_1164.all;
USE work.cond_comilation_package.all;


package aux_package is

	component MIPS is
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
			-- Output important signals to pins for easy display in Simulator
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
	end component;
---------------------------------------------------------  
	component control is
		PORT( 	
		opcode_i 			: IN 	STD_LOGIC_VECTOR(5 DOWNTO 0);
		funct_i				: in	STD_LOGIC_VECTOR(5 DOWNTO 0);
		in_intr_i			: in	boolean;
		RegDst_ctrl_o 		: OUT 	std_logic_vector(1 downto 0);
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
	end component;
---------------------------------------------------------	
	component dmemory is
		generic(
		DATA_BUS_WIDTH : integer := 32;
		DTCM_ADDR_WIDTH : integer := 12;
		WORDS_NUM : integer := 1024
	);
	PORT(	clk_i,rst_i			: IN 	STD_LOGIC;
			dtcm_addr_i 		: IN 	STD_LOGIC_VECTOR(DTCM_ADDR_WIDTH-1 DOWNTO 0);
			dtcm_data_wr_i 		: IN 	STD_LOGIC_VECTOR(DATA_BUS_WIDTH-1 DOWNTO 0);
			MemRead_ctrl_i  	: IN 	STD_LOGIC;
			MemWrite_ctrl_i 	: IN 	STD_LOGIC;
			dtcm_data_rd_o 		: OUT 	STD_LOGIC_VECTOR(DATA_BUS_WIDTH-1 DOWNTO 0)
	);
	end component;
---------------------------------------------------------		
	component Execute is
		generic(
		DATA_BUS_WIDTH : integer := 32;
		FUNCT_WIDTH : integer := 6;
		PC_WIDTH : integer := 10
	);
	PORT(	read_data1_i 	: IN 	STD_LOGIC_VECTOR(DATA_BUS_WIDTH-1 DOWNTO 0);
			read_data2_i 	: IN 	STD_LOGIC_VECTOR(DATA_BUS_WIDTH-1 DOWNTO 0);
			sign_extend_i 	: IN 	STD_LOGIC_VECTOR(DATA_BUS_WIDTH-1 DOWNTO 0);
			instruction_i 	: IN 	STD_LOGIC_VECTOR(DATA_BUS_WIDTH-1 DOWNTO 0);
			opcode_i		: in 	std_logic_vector(5 downto 0);
			funct_i 		: IN 	STD_LOGIC_VECTOR(FUNCT_WIDTH-1 DOWNTO 0);
			ALUOp_ctrl_i 	: IN 	STD_LOGIC_VECTOR(1 DOWNTO 0);
			ALUSrc_ctrl_i 	: IN 	STD_LOGIC;
			Jump_ctrl_i		: in 	std_logic;
			JR_ctrl_i		: in	std_logic;
			pc_plus4_i 		: IN 	STD_LOGIC_VECTOR(PC_WIDTH-1 DOWNTO 0);
			zero_o 			: OUT	STD_LOGIC;
			alu_res_o 		: OUT	STD_LOGIC_VECTOR(DATA_BUS_WIDTH-1 DOWNTO 0);
			addr_res_o 		: OUT	STD_LOGIC_VECTOR( 7 DOWNTO 0 )
	);
	end component;
---------------------------------------------------------		
	component Idecode is
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
			read_data1_o	: OUT 	STD_LOGIC_VECTOR(DATA_BUS_WIDTH-1 DOWNTO 0);
			read_data2_o	: OUT 	STD_LOGIC_VECTOR(DATA_BUS_WIDTH-1 DOWNTO 0);
			sign_extend_o 	: OUT 	STD_LOGIC_VECTOR(DATA_BUS_WIDTH-1 DOWNTO 0);
			gie_o			: out	std_logic;
			--- tri bus ---
			data_bus_i 		: in std_logic_vector(DATA_BUS_WIDTH-1 downto 0)		 
	);
	end component;
---------------------------------------------------------		
	component Ifetch is
		generic(
		WORD_GRANULARITY : boolean 	:= False;
		DATA_BUS_WIDTH : integer 	:= 32;
		PC_WIDTH : integer 			:= 10;
		NEXT_PC_WIDTH : integer 	:= 8; -- NEXT_PC_WIDTH = PC_WIDTH-2
		ITCM_ADDR_WIDTH : integer 	:= 8;
		WORDS_NUM : integer 		:= 256;
		INST_CNT_WIDTH : integer 	:= 16
	);
	PORT(	
		clk_i, rst_i 	: IN 	STD_LOGIC;
		ena_i			: in	boolean;
		add_result_i 	: IN 	STD_LOGIC_VECTOR(7 DOWNTO 0);
        Branch_ctrl_i 	: IN 	STD_LOGIC;
		BranchN_ctrl_i	: in	std_logic;
		Jump_ctrl_i		: in	std_logic;
		JR_ctrl_i		: in	std_logic;
        zero_i 			: IN 	STD_LOGIC;	
		pc_o 			: OUT	STD_LOGIC_VECTOR(PC_WIDTH-1 DOWNTO 0);
		pc_plus4_o 		: OUT	STD_LOGIC_VECTOR(PC_WIDTH-1 DOWNTO 0);
		instruction_o 	: OUT	STD_LOGIC_VECTOR(DATA_BUS_WIDTH-1 DOWNTO 0);
		inst_cnt_o 		: OUT	STD_LOGIC_VECTOR(INST_CNT_WIDTH-1 DOWNTO 0);
		--- interrupts ---
		next_addr_o		: out	std_logic_vector(PC_WIDTH-1 downto 0)
	);
	end component;
---------------------------------------------------------
	COMPONENT PLL 
	generic (DIVIDE_BY : natural := 2);
	port(
	    areset		: IN STD_LOGIC  := '0';
		inclk0		: IN STD_LOGIC  := '0';
		c0     		: OUT STD_LOGIC ;
		locked		: OUT STD_LOGIC );
    END COMPONENT;
---------------------------------------------------------	
	component Shifter IS
		GENERIC (n : INTEGER := 8);
		PORT (  ALUFN: IN STD_LOGIC_VECTOR (2 DOWNTO 0);
				x: in std_logic_vector(4 downto 0);
				y: IN STD_LOGIC_VECTOR (n-1 DOWNTO 0);
				cout: OUT STD_LOGIC;
				ALUout: OUT STD_LOGIC_VECTOR(n-1 downto 0));

	end component;
---------------------------------------------------------
	component hex_decoder   
		PORT (
			Hex_in		: in STD_LOGIC_VECTOR (3 DOWNTO 0);
			seg   		: out STD_LOGIC_VECTOR (6 downto 0));
	end component;
---------------------------------------------------------
	component hex_seg
		generic (
			DATA_BUS_WIDTH : integer := 32
		);
		PORT (
        	clk_i, rst_i: in std_logic;
			MemRead_i   : in std_logic;
			MemWrite_i  : in std_logic;
			A0_i        : in std_logic;
			CS_i        : in std_logic;
			data_bus_io : inout std_logic_vector(DATA_BUS_WIDTH-1 downto 0);
			data_o      : out std_logic_vector(3 downto 0)
		);
	END component;
--------------------------------------------------------------
	component led_io
		generic (
			DATA_BUS_WIDTH : integer := 32
		);
		PORT (
			clk_i, rst_i: in std_logic;
			MemRead_i   : in std_logic;
			MemWrite_i  : in std_logic;
			CS_i        : in std_logic;
			data_bus_io : inout std_logic_vector(DATA_BUS_WIDTH-1 downto 0);
			data_o      : out std_logic_vector(7 downto 0)
		);
	END component;
--------------------------------------------------------------
	component sw_io
		generic (
			DATA_BUS_WIDTH : integer := 32
		);
		PORT (
			data_i      : in std_logic_vector(7 downto 0);
			MemRead_i   : in std_logic;
			CS_i        : in std_logic;
			data_bus_io : inout std_logic_vector(DATA_BUS_WIDTH-1 downto 0)
		);
	END component;
--------------------------------------------------------------
	component address_decoder
		generic (
			ADDRESS_BUS_WIDTH : integer := 12
		);
		PORT (
			address_bus_i : in std_logic_vector(ADDRESS_BUS_WIDTH-1 downto 0);
			cs_vec_o      : out std_logic_vector(7 downto 0)
		);
	END component;
--------------------------------------------------------------
	component mcu
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
		PORT (
			clk_i   			: in std_logic;
			rst_i   			: in std_logic;
			--- interrupts ---
			key1_i              : in std_logic;
			key2_i              : in std_logic;
			key3_i              : in std_logic;
			--- GPIO ---
			sw_i    			: in  std_logic_vector(7 downto 0);
			hex0_o  			: out std_logic_vector(6 downto 0);
			hex1_o  			: out std_logic_vector(6 downto 0);
			hex2_o  			: out std_logic_vector(6 downto 0);
			hex3_o  			: out std_logic_vector(6 downto 0);
			hex4_o  			: out std_logic_vector(6 downto 0);
			hex5_o  			: out std_logic_vector(6 downto 0);
			led_o   			: out std_logic_vector(7 downto 0);
        	pc_o    			: out std_logic_vector(PC_WIDTH-1 downto 0);
        	instruction_o 		: out std_logic_vector(DATA_BUS_WIDTH-1 downto 0);
        	data_bus_o    		: inout std_logic_vector (DATA_BUS_WIDTH-1 downto 0);
        	ifg_o               : out std_logic_vector(7 downto 0);
        	-- address_bus_o 		: out std_logic_vector (12-1 downto 0);
        	-- mem_wr_o      		: out std_logic;
        	-- mem_rd_o      		: out std_logic;
			-- alu_result_o 		: OUT STD_LOGIC_VECTOR(DATA_BUS_WIDTH-1 DOWNTO 0);
			-- read_data1_o 		: OUT STD_LOGIC_VECTOR(DATA_BUS_WIDTH-1 DOWNTO 0);
			-- read_data2_o 		: OUT STD_LOGIC_VECTOR(DATA_BUS_WIDTH-1 DOWNTO 0);
			-- write_data_o		: OUT STD_LOGIC_VECTOR(DATA_BUS_WIDTH-1 DOWNTO 0);
			-- Branch_ctrl_o		: OUT STD_LOGIC;
			-- Zero_o				: OUT STD_LOGIC; 
			-- RegWrite_ctrl_o		: OUT STD_LOGIC;
			-- inst_cnt_o 			: OUT STD_LOGIC_VECTOR(INST_CNT_WIDTH-1 DOWNTO 0);
			pwm_o				: out std_logic
		);
	END component;
--------------------------------------------------------------
	component basic_timer
		GENERIC (DATA_BUS_WIDTH : INTEGER := 32;
       		 	DTCM_ADDR_WIDTH : integer 	:= 12);
		PORT ( 
			addr_bus_i  : in std_logic_vector(DTCM_ADDR_WIDTH-1 downto 0);
			BTCCR0_i    : in std_logic_vector(DATA_BUS_WIDTH-1 downto 0);
			BTCCR1_i    : in std_logic_vector(DATA_BUS_WIDTH-1 downto 0);
			BTCLR_i     : in std_logic;
			BTHOLD_i    : in std_logic;
			BTSSELx_i   : in std_logic_vector(1 downto 0);
			MCLK_i      : in std_logic;
			MCLK2_i     : in std_logic;
			MCLK4_i     : in std_logic;
			MCLK8_i     : in std_logic;
			BTIPx_i     : in std_logic_vector(1 downto 0);
			BTOUTMD_i   : in std_logic;
			BTOUTEN_i   : in std_logic;
			MemWrite_i  : in std_logic;
			MemRead_i   : in std_logic;
			PWM_o       : out std_logic;
			BTIFG_o     : out std_logic;
        	BTCNT_io    : inout std_logic_vector(DATA_BUS_WIDTH-1 downto 0)
		);
	END component;
--------------------------------------------------------------
component timer_top
    GENERIC (
        DATA_BUS_WIDTH : INTEGER := 32);
    PORT (
        clk_i, rst_i: in    std_logic;
        mem_rd_i    : in    std_logic;
        mem_wr_i    : in    std_logic;
        addr_bus_i  : in    std_logic_vector(11 downto 0);
        data_bus_io : inout std_logic_vector(DATA_BUS_WIDTH-1 downto 0);
        bt_ifg_o    : out   std_logic;
        pwm_o       : out   std_logic
    );
END component;
--------------------------------------------------------------
component pulse_synchronizer
    PORT ( 
        FIRCLK_i     : in std_logic;
        FIRENA_i     : in std_logic;
        FIFOCLK_i    : in std_logic;
        FIFOREN_o    : out std_logic
    );
END component;
--------------------------------------------------------------
component FIFO
    GENERIC (
        DATA_BUS_WIDTH : INTEGER := 32;
        K              : integer := 8;
        W              : integer := 24
    );
    PORT ( 
        FIFORST_i     : in    std_logic;
        FIFOCLK_i     : in    std_logic;
        FIFOWEN_i     : in    std_logic;
        FIFOIN_i      : in    std_logic_vector(DATA_BUS_WIDTH-1 downto 0);
        FIFOREN_i     : in    std_logic;
        FIFOFULL_o    : out   std_logic;
        FIFOEMPTY_o   : out   std_logic;
        new_out_o     : out   std_logic;
        DATAOUT_o     : out   std_logic_vector(W-1 downto 0)
    );
END component;
--------------------------------------------------------------
component filter
    GENERIC (
        DATA_BUS_WIDTH : INTEGER := 32;
        Q              : integer := 8;
        W              : integer := 24
    );
    PORT ( 
		coef_0      : in std_logic_vector(q-1 downto 0);
		coef_1      : in std_logic_vector(q-1 downto 0);
		coef_2      : in std_logic_vector(q-1 downto 0);
		coef_3      : in std_logic_vector(q-1 downto 0);
		coef_4      : in std_logic_vector(q-1 downto 0);
		coef_5      : in std_logic_vector(q-1 downto 0);
		coef_6      : in std_logic_vector(q-1 downto 0);
		coef_7      : in std_logic_vector(q-1 downto 0);
		sample_i    : in std_logic_vector(W-1 downto 0);
		FIRCLK_i    : in std_logic;
		FIRRST_i    : in std_logic;
		FIRENA_i    : in std_logic;
		new_out_i   : in std_logic;
		ifg_o    	: out std_logic;
		data_o      : out std_logic_vector(DATA_BUS_WIDTH-1 downto 0)
    );
END component;
--------------------------------------------------------------
component FIR
    generic( 
		DATA_BUS_WIDTH : integer := 32;
        Q              : integer := 8;
        W              : integer := 24
);
PORT (
    FIRIN_i     : in std_logic_vector(DATA_BUS_WIDTH-1 downto 0);
    coef0_i     : in std_logic_vector(q-1 downto 0);
    coef1_i     : in std_logic_vector(q-1 downto 0);
    coef2_i     : in std_logic_vector(q-1 downto 0);
    coef3_i     : in std_logic_vector(q-1 downto 0);
    coef4_i     : in std_logic_vector(q-1 downto 0);
    coef5_i     : in std_logic_vector(q-1 downto 0);
    coef6_i     : in std_logic_vector(q-1 downto 0);
    coef7_i     : in std_logic_vector(q-1 downto 0);
    FIFORST_i   : in std_logic;
    FIFOCLK_i   : in std_logic;
    FIFOWEN_i   : in std_logic;
    FIRCLK_i    : in std_logic;
    FIRRST_i    : in std_logic;
    FIRENA_i    : in std_logic;
    FIROUT_o    : out std_logic_vector(DATA_BUS_WIDTH-1 downto 0);
    FIFOFULL_o  : out std_logic;
    FIFOEMPTY_o : out std_logic;
    fifo_ifg_o  : out std_logic;
    fir_ifg_o    : out std_logic
);
END component;
--------------------------------------------------------------
component fir_top
    GENERIC (
        DATA_BUS_WIDTH : INTEGER := 32);
    PORT (
        clk_i, rst_i    : in    std_logic;
        clk2_i          : in    std_logic;
        mem_rd_i        : in    std_logic;
        mem_wr_i        : in    std_logic;
        addr_bus_i      : in    std_logic_vector(11 downto 0);
        data_bus_io     : inout std_logic_vector(DATA_BUS_WIDTH-1 downto 0);
        fifo_empty_o    : out   std_logic;
        fir_ifg_o       : out   std_logic;
        fifo_ifg_o      : out   std_logic
    );
END component;
--------------------------------------------------------------
component int_ctrl
    GENERIC (
        DATA_BUS_WIDTH : INTEGER := 32);
    PORT (
        clk_i           : in std_logic;
        rst_i           : in std_logic;
        RX_INT_i        : in std_logic;
        TX_INT_i        : in std_logic;
        BT_INT_i        : in std_logic;
        KEY1_INT_i      : in std_logic;
        KEY2_INT_i      : in std_logic;
        KEY3_INT_i      : in std_logic;
        FIR_INT_i       : in std_logic;
        FIFO_INT_i      : in std_logic;
        CS_i            : in std_logic;
        INTA_i          : in std_logic;
        GIE             : in std_logic;
        MemRead_ctrl_i  : in std_logic;
        MemWrite_ctrl_i : in std_logic;
        A0_i            : in std_logic;
        fir_empty_i     : in std_logic;
        ifg_o           : out std_logic_vector(7 downto 0);
        INTR_o          : out std_logic;  
        data_bus_io     : inout std_logic_vector(DATA_BUS_WIDTH-1 downto 0)
    );
END component;
--------------------------------------------------------------

end aux_package;

