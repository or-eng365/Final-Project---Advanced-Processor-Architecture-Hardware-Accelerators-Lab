---------------------------------------------------------------------------------------------
-- Copyright 2025 Hananya Ribo 
-- Advanced CPU architecture and Hardware Accelerators Lab 361-1-4693 BGU
---------------------------------------------------------------------------------------------
LIBRARY IEEE;
USE IEEE.STD_LOGIC_1164.ALL;
USE IEEE.STD_LOGIC_ARITH.ALL;
use ieee.std_logic_unsigned.all;
use ieee.numeric_std.all;
USE work.cond_comilation_package.all;
USE work.aux_package.all;


ENTITY fir_tb IS
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
		INST_CNT_WIDTH : integer 	:= 16;
        Q              : integer    := 8;
        W              : integer    := 24
	);
END fir_tb ;


ARCHITECTURE fir_tb_arc OF fir_tb IS
	SIGNAL clk_tb_i         : STD_LOGIC;
    signal rst_tb_i         : std_logic;
    signal MCLK2_i_tb     	: std_logic;
    signal MCLK4_i_tb     	: std_logic;
    signal MCLK8_i_tb     	: std_logic;
    signal div4         	: std_logic;
    signal div8         	: std_logic_vector(1 downto 0);
    --- filter signals ---
    TYPE arr IS ARRAY (0 TO 15) OF STD_LOGIC_VECTOR(W-1 DOWNTO 0);
    signal FIRIN_i     : std_logic_vector(DATA_BUS_WIDTH-1 downto 0);
    signal coef0_i     : std_logic_vector(q-1 downto 0) := X"20";
    signal coef1_i     : std_logic_vector(q-1 downto 0) := X"20";
    signal coef2_i     : std_logic_vector(q-1 downto 0) := X"20";
    signal coef3_i     : std_logic_vector(q-1 downto 0) := X"20";
    signal coef4_i     : std_logic_vector(q-1 downto 0) := X"20";
    signal coef5_i     : std_logic_vector(q-1 downto 0) := X"20";
    signal coef6_i     : std_logic_vector(q-1 downto 0) := X"20";
    signal coef7_i     : std_logic_vector(q-1 downto 0) := X"20";
    signal FIFOWEN_i   : std_logic;
    signal FIRENA_i    : std_logic := '0';
    signal FIROUT_o    : std_logic_vector(DATA_BUS_WIDTH-1 downto 0);
    signal FIFOFULL_o  : std_logic;
    signal FIFOEMPTY_o : std_logic;
    signal FIRIFG_o    : std_logic;
    signal sample_idx_w: std_logic_vector(2 downto 0) := "000";
    signal output_idx_w: std_logic_vector(2 downto 0) := "000";
    signal samples_w   : arr := (X"5b9a1e", X"ac0b0b", X"a9c269", X"dc61d8", X"f0cad5",
                                    X"e71f3f", X"100000", X"dbc67b", X"a948b6", X"8547e4",
                                    X"6773c8", X"54c726", X"29826d", X"2a2df2", X"0ec383",
                                    X"164e73");
    signal output_w    : arr := (others => (others=>'0'));
    signal zero_vec_w  : std_logic_vector(7 downto 0) := (others=>'0');
    signal flag        : boolean := false;
BEGIN
	fir_filter: FIR port map (
        FIRIN_i     => FIRIN_i,
        coef0_i     => coef0_i,
        coef1_i     => coef1_i,
        coef2_i     => coef2_i,
        coef3_i     => coef3_i,
        coef4_i     => coef4_i,
        coef5_i     => coef5_i,
        coef6_i     => coef6_i,
        coef7_i     => coef7_i,
        FIFORST_i   => rst_tb_i,
        FIFOCLK_i   => clk_tb_i,
        FIFOWEN_i   => FIFOWEN_i,
        FIRCLK_i    => MCLK8_i_tb,
        FIRRST_i    => rst_tb_i,
        FIRENA_i    => FIRENA_i,
        FIROUT_o    => FIROUT_o,
        FIFOFULL_o  => FIFOFULL_o,
        FIFOEMPTY_o =>  FIFOEMPTY_o,
        FIRIFG_o    =>  FIRIFG_o
    );
--------------------------------------------------------------------
	gen_clk : 
	process
        begin
		  clk_tb_i <= '1';
		  wait for 50 ns;
		  clk_tb_i <= not clk_tb_i;
		  wait for 50 ns;
    end process;
	
	gen_rst : 
	process
        begin
		  rst_tb_i <='1','0' after 120 ns;
		  wait;
    end process;
--------------------------------------------------------------------
    div_cnt: process(clk_tb_i,rst_tb_i)
    begin 
        if (rst_tb_i='1') then
            MCLK2_i_tb <= '0';
			MCLK4_i_tb <= '0';
			MCLK8_i_tb <= '0';
            div4 <= '0';
            div8 <= "00";
        end if;
        if (rising_edge(clk_tb_i)) then
            MCLK2_i_tb <= not (MCLK2_i_tb);
            div4 <= not(div4);
			if (div4='1') then
				MCLK4_i_tb <= not(MCLK4_i_tb);
			end if;
            div8 <= std_logic_vector(ieee.numeric_std.unsigned(div8) + 1);
			if (div8="11") then
				MCLK8_i_tb <= not(MCLK8_i_tb);
			end if;
        end if;
    end process;
--------------------------------------------------------------------
    fill_fifo: process (clk_tb_i)
    begin
        if (rising_edge(clk_tb_i)) then
            if (FIFOFULL_o='0' and rst_tb_i='0' and not(flag)) then
                FIRIN_i <= zero_vec_w & samples_w(conv_integer(sample_idx_w));
                sample_idx_w <= std_logic_vector(ieee.numeric_std.unsigned(sample_idx_w)+1);
                FIFOWEN_i <= '1';
            elsif (rst_tb_i='0' and FIFOEMPTY_o='0') then
                FIFOWEN_i <= '0';
                flag <= true;
                FIRENA_i <= '1';
            end if;
        end if;
    end process;

    output_data: process (clk_tb_i)
    begin
        if (rising_edge(clk_tb_i)) then
            if (FIFOEMPTY_o='0' and FIRIFG_o='1' and rst_tb_i='0') then
                output_w(conv_integer(output_idx_w)) <= FIROUT_o(23 downto 0);
                output_idx_w <= std_logic_vector(ieee.numeric_std.unsigned(output_idx_w)+1);
            end if;
        end if;
    end process;
--------------------------------------------------------------------		
END architecture;
