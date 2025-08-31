LIBRARY ieee;
USE ieee.std_logic_1164.all;
use ieee.numeric_std.all;
USE work.cond_comilation_package.all;
USE work.aux_package.all;
-------------------------------------
ENTITY mcu IS
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
        clk_i               : IN std_logic;
        rst_i               : IN std_logic;
        --- interrupts ---
        key1_i              : in std_logic;
        key2_i              : in std_logic;
        key3_i              : in std_logic;
        --- GPIO ---
        sw_i                : in  std_logic_vector(7 downto 0);
        hex0_o              : out std_logic_vector(6 downto 0);
        hex1_o              : out std_logic_vector(6 downto 0);
        hex2_o              : out std_logic_vector(6 downto 0);
        hex3_o              : out std_logic_vector(6 downto 0);
        hex4_o              : out std_logic_vector(6 downto 0);
        hex5_o              : out std_logic_vector(6 downto 0);
        led_o               : out std_logic_vector(7 downto 0);
        pc_o                : out std_logic_vector(PC_WIDTH-1 downto 0);
        instruction_o       : out std_logic_vector(DATA_BUS_WIDTH-1 downto 0);
        ifg_o               : out std_logic_vector(7 downto 0);
        data_bus_o          : inout std_logic_vector (DATA_BUS_WIDTH-1 downto 0);
        -- address_bus_o       : out std_logic_vector (DTCM_ADDR_WIDTH-1 downto 0);
        -- mem_wr_o            : out std_logic;
        -- mem_rd_o            : out std_logic;
		-- alu_result_o 		: OUT STD_LOGIC_VECTOR(DATA_BUS_WIDTH-1 DOWNTO 0);
		-- read_data1_o 		: OUT STD_LOGIC_VECTOR(DATA_BUS_WIDTH-1 DOWNTO 0);
		-- read_data2_o 		: OUT STD_LOGIC_VECTOR(DATA_BUS_WIDTH-1 DOWNTO 0);
		-- write_data_o		: OUT STD_LOGIC_VECTOR(DATA_BUS_WIDTH-1 DOWNTO 0);
		-- Branch_ctrl_o		: OUT STD_LOGIC;
		-- Zero_o				: OUT STD_LOGIC; 
		-- RegWrite_ctrl_o		: OUT STD_LOGIC;
		-- inst_cnt_o 			: OUT STD_LOGIC_VECTOR(INST_CNT_WIDTH-1 DOWNTO 0);
        pwm_o               : out std_logic
    );
END mcu;
--------------------------------------------------------------
ARCHITECTURE mcu_arc OF mcu is
    --- clocks ---
    signal MCLK_w   : std_logic:= '0';
    signal SMCLK_w   : std_logic;
    signal clk_cnt_sm_w : std_logic_vector(8 downto 0) := (others=>'0');
    --- tri bus ---
    signal data_bus_w   : std_logic_vector(DATA_BUS_WIDTH-1 downto 0);
    signal addr_bus_w   : std_logic_vector(11 downto 0);
    signal mem_wr_en_w  : std_logic;
    signal mem_rd_en_w  : std_logic;
    --- address decoder ---
    signal cs_vec_w     : std_logic_vector(7 downto 0) := (others=> '0');
    --- hex displays ---
    signal A0_not_w     : std_logic;
    signal hex0_data_w  : std_logic_vector(3 downto 0);
    signal hex1_data_w  : std_logic_vector(3 downto 0);
    signal hex2_data_w  : std_logic_vector(3 downto 0);
    signal hex3_data_w  : std_logic_vector(3 downto 0);
    signal hex4_data_w  : std_logic_vector(3 downto 0);
    signal hex5_data_w  : std_logic_vector(3 downto 0);
    --- basic timer ---
    signal BTIFG_w      : std_logic;
    --- FIR filter ---
    signal fir_ifg_w   : std_logic;
    signal fifo_ifg_w  : std_logic;
    signal fifo_empty_w: std_logic;
    --- interrupts ---
    signal gie_w       : std_logic;
    signal inta_w      : std_logic;
    signal intr_w      : std_logic;
    signal intr_cs_w   : std_logic;
    --- random ---
    signal zero_vec_w   : std_logic_vector(23 downto 0);
    signal not_rst_w    : std_logic := '1';
    signal not_key1_w   : std_logic;
    signal not_key2_w   : std_logic;
    signal not_key3_w   : std_logic;
begin
    data_bus_o <= data_bus_w;
    --- not signals ---
    not_rst_w   <= '1' when rst_i='0' else '0';
    not_key1_w  <= '1' when key1_i='0' else '0';
    not_key2_w  <= '1' when key2_i='0' else '0';
    not_key3_w  <= '1' when key3_i='0' else '0';
    --- PLLs ---
    MCLK: PLL 
    generic map (DIVIDE_BY=>2)
    PORT MAP (
        -- areset   => not_rst_w,
        inclk0 	 => clk_i,
        c0 		 => MCLK_w
    );

    SMCLK: process (MCLK_w, not_rst_w)
    begin
        if (not_rst_w='1') then
            SMCLK_w <= '0';
        elsif (rising_edge(MCLK_w)) then
            clk_cnt_sm_w <= std_logic_vector(ieee.numeric_std.unsigned(clk_cnt_sm_w) + 1);
			if (clk_cnt_sm_w="111111111") then
				SMCLK_w <= not(SMCLK_w);
            else
			end if;
        end if;
    end process;


    --- mips core ---
    core: mips 
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
    port map (
        rst_i           => not_rst_w,
        clk_i           => MCLK_w,
        data_bus_io     => data_bus_w,
        addr_bus_o      => addr_bus_w,
        MemWrite_ctrl_o => mem_wr_en_w,
        MemRead_ctrl_o  => mem_rd_en_w,
        pc_o            => pc_o,
        instruction_o   => instruction_o,
        -- Branch_ctrl_o   => Branch_ctrl_o,
        -- Zero_o          => Zero_o,
        -- RegWrite_ctrl_o => RegWrite_ctrl_o,
        -- alu_result_o    => alu_result_o,
        -- read_data1_o    => read_data1_o,
        -- read_data2_o    => read_data2_o,
        -- inst_cnt_o      => inst_cnt_o,
        -- write_data_o    => write_data_o,
        INTR_i          => intr_w,
        INTA_o          => inta_w,
        GIE_o           => gie_w
    );

    --- address decoder
    addr_decoder: address_decoder port map (
        address_bus_i   => addr_bus_w,
        cs_vec_o        => cs_vec_w
    );

    --- switches ---
    switch: sw_io port map (
        data_i          => sw_i,
        MemRead_i       => mem_rd_en_w,
        CS_i            => cs_vec_w(4),
        data_bus_io     => data_bus_w        
    );

    --- LEDs ---
    leds: led_io port map (
        clk_i           => MCLK_w,
        rst_i           => not_rst_w,
        MemRead_i       => mem_rd_en_w,
        MemWrite_i      => mem_wr_en_w,
        CS_i            => cs_vec_w(0),
        data_bus_io     => data_bus_w,
        data_o          => led_o
    );

    --- hex displays ---
    A0_not_w <= not(addr_bus_w(0));
    hex0: hex_seg port map (
        clk_i           => MCLK_w,
        rst_i           => not_rst_w,
        MemRead_i       => mem_rd_en_w,
        MemWrite_i      => mem_wr_en_w,
        A0_i            => A0_not_w,
        CS_i            => cs_vec_w(1),
        data_bus_io     => data_bus_w,
        data_o          => hex0_data_w
    );
    seg0: hex_decoder port map (
        Hex_in          => hex0_data_w,
        seg             => hex0_o
    );
    hex1: hex_seg port map (
        clk_i           => MCLK_w,
        rst_i           => not_rst_w,
        MemRead_i       => mem_rd_en_w,
        MemWrite_i      => mem_wr_en_w,
        A0_i            => addr_bus_w(0),
        CS_i            => cs_vec_w(1),
        data_bus_io     => data_bus_w,
        data_o          => hex1_data_w
    );
    seg1: hex_decoder port map (
        Hex_in          => hex1_data_w,
        seg             => hex1_o
    );
    hex2: hex_seg port map (
        clk_i           => MCLK_w,
        rst_i           => not_rst_w,
        MemRead_i       => mem_rd_en_w,
        MemWrite_i      => mem_wr_en_w,
        A0_i            => A0_not_w,
        CS_i            => cs_vec_w(2),
        data_bus_io     => data_bus_w,
        data_o          => hex2_data_w
    );
    seg2: hex_decoder port map (
        Hex_in          => hex2_data_w,
        seg             => hex2_o
    );
    hex3: hex_seg port map (
        clk_i           => MCLK_w,
        rst_i           => not_rst_w,
        MemRead_i       => mem_rd_en_w,
        MemWrite_i      => mem_wr_en_w,
        A0_i            => addr_bus_w(0),
        CS_i            => cs_vec_w(2),
        data_bus_io     => data_bus_w,
        data_o          => hex3_data_w
    );
    seg3: hex_decoder port map (
        Hex_in          => hex3_data_w,
        seg             => hex3_o
    );
    hex4: hex_seg port map (
        clk_i           => MCLK_w,
        rst_i           => not_rst_w,
        MemRead_i       => mem_rd_en_w,
        MemWrite_i      => mem_wr_en_w,
        A0_i            => A0_not_w,
        CS_i            => cs_vec_w(3),
        data_bus_io     => data_bus_w,
        data_o          => hex4_data_w
    );
    seg4: hex_decoder port map (
        Hex_in          => hex4_data_w,
        seg             => hex4_o
    );
    hex5: hex_seg port map (
        clk_i           => MCLK_w,
        rst_i           => not_rst_w,
        MemRead_i       => mem_rd_en_w,
        MemWrite_i      => mem_wr_en_w,
        A0_i            => addr_bus_w(0),
        CS_i            => cs_vec_w(3),
        data_bus_io     => data_bus_w,
        data_o          => hex5_data_w
    );
    seg5: hex_decoder port map (
        Hex_in          => hex5_data_w,
        seg             => hex5_o
    );

    --- basic timer ---
    timer: timer_top port map (
        clk_i       => MCLK_w,
        rst_i       => not_rst_w,
        mem_rd_i    => mem_rd_en_w,
        mem_wr_i    => mem_wr_en_w,
        addr_bus_i  => addr_bus_w,
        data_bus_io => data_bus_w,
        bt_ifg_o    => BTIFG_w,
        pwm_o       => pwm_o
    );

    --- FIR filter ---
    fir_filter: fir_top port map (
        clk_i           => MCLK_w,
        rst_i           => not_rst_w,
        clk2_i          => SMCLK_w,
        mem_rd_i        => mem_rd_en_w,
        mem_wr_i        => mem_wr_en_w,
        addr_bus_i      => addr_bus_w,
        data_bus_io     => data_bus_w,
        fifo_empty_o    => fifo_empty_w,
        fir_ifg_o       => fir_ifg_w,
        fifo_ifg_o      => fifo_ifg_w
    );

    -- interrupts ---
    intr_cs_w <= '1' when addr_bus_w=X"840" or addr_bus_w=X"841" else '0';
    intr: int_ctrl port map (
        clk_i           => MCLK_w,
        rst_i           => not_rst_w,
        RX_INT_i        => '0',
        TX_INT_i        => '0',
        BT_INT_i        => BTIFG_w,
        KEY1_INT_i      => not_key1_w,
        KEY2_INT_i      => not_key2_w,
        KEY3_INT_i      => not_key3_w,
        FIR_INT_i       => fir_ifg_w,
        FIFO_INT_i      => fifo_ifg_w,
        CS_i            => intr_cs_w,
        INTA_i          => inta_w,
        GIE             => gie_w,
        MemRead_ctrl_i  => mem_rd_en_w,
        MemWrite_ctrl_i => mem_wr_en_w,
        A0_i            => addr_bus_w(0),
        fir_empty_i     => fir_ifg_w,
        ifg_o           => ifg_o,
        INTR_o          => intr_w,
        data_bus_io     => data_bus_w
    );
end architecture;