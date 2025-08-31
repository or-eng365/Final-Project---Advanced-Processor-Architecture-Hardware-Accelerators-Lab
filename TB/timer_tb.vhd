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


ENTITY timer_tb IS
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
END timer_tb ;


ARCHITECTURE timer_tb_arc OF timer_tb IS
	SIGNAL clk_tb_i         : STD_LOGIC;
    signal BTCCR0_i_tb    	: std_logic_vector(DATA_BUS_WIDTH-1 downto 0);
    signal BTCCR1_i_tb    	: std_logic_vector(DATA_BUS_WIDTH-1 downto 0);        
	signal BTCLR_i_tb     	: std_logic;
    signal BTHOLD_i_tb    	: std_logic;
    signal BTSSELx_i_tb   	: std_logic_vector(1 downto 0);
    signal MCLK_i_tb      	: std_logic;
    signal MCLK2_i_tb     	: std_logic;
    signal MCLK4_i_tb     	: std_logic;
    signal MCLK8_i_tb     	: std_logic;
    signal BTIPx_i_tb     	: std_logic_vector(1 downto 0);
    signal BTOUTMD_i_tb   	: std_logic;
    signal BTOUTEN_i_tb   	: std_logic;
    signal PWM_o_tb       	: std_logic;
    signal BTIFG_o_tb     	: std_logic;
    signal BTCNT_o_tb     	: std_logic_vector(DATA_BUS_WIDTH-1 downto 0);
	signal div2         	: std_logic;
    signal div4         	: std_logic;
    signal div8         	: std_logic_vector(1 downto 0);
BEGIN
	timer: basic_timer port map (
		BTCCR0_i	=> BTCCR0_i_tb,
		BTCCR1_i	=> BTCCR1_i_tb,
		BTCLR_i		=> BTCLR_i_tb,
		BTHOLD_i	=> BTHOLD_i_tb,
		BTSSELx_i	=> BTSSELx_i_tb,
		MCLK_i		=> clk_tb_i,
		MCLK2_i		=> MCLK2_i_tb,
		MCLK4_i		=> MCLK4_i_tb,
		MCLK8_i		=> MCLK8_i_tb,
		BTIPx_i		=> BTIPx_i_tb,
		BTOUTMD_i	=> BTOUTMD_i_tb,
		BTOUTEN_i	=> BTOUTEN_i_tb,
		PWM_o		=> PWM_o_tb,
		BTIFG_o		=> BTIFG_o_tb,
		BTCNT_io		=> BTCNT_o_tb
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
	
	gen_BTCLR : 
	process
        begin
		  BTCLR_i_tb <='1','0' after 120 ns;
		  wait;
    end process;
--------------------------------------------------------------------
    div_cnt: process(clk_tb_i,BTCLR_i_tb)
    begin 
        if (BTCLR_i_tb='1') then
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

	BTCCR0_i_tb <= (2=> '1' , others => '0');
	BTCCR1_i_tb <= (1=> '1' , others => '0');

	gen_signals : process
	begin
		BTHOLD_i_tb <='0','1' after 100000 ns;
		BTSSELx_i_tb <= "00" , "01" after 800 ns, "10" after 1600 ns, "11" after 2400 ns;
		BTOUTEN_i_tb <= '1';
		BTOUTMD_i_tb <= '0';
		BTIPx_i_tb <= "00";
		wait;
    end process;



--------------------------------------------------------------------		
END architecture;
