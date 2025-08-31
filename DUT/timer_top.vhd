library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_arith.all;
use ieee.std_logic_unsigned.all;
use ieee.numeric_std.all;
use work.aux_package.all;
-------------------------------------
ENTITY timer_top IS
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
END timer_top;
--------------------------------------------------------------
architecture timer_top_arc of timer_top is
    signal BTCTL_w      : std_logic_vector(7 downto 0) := (5=>'1', others=>'0');
    signal BTCNT_w      : std_logic_vector(DATA_BUS_WIDTH-1 downto 0);
    signal BTCCR0_w     : std_logic_vector(DATA_BUS_WIDTH-1 downto 0);
    signal BTCCR1_w     : std_logic_vector(DATA_BUS_WIDTH-1 downto 0);
    signal mclk2_w      : std_logic;
    signal mclk4_w      : std_logic;
    signal mclk8_w      : std_logic;
    signal read_en_w    : std_logic_vector(3 downto 0) := (others=>'0');
    signal zero_vec_w   : std_logic_vector(23 downto 0) := (others=>'0');
begin
    -- registers --
    bt_regs: process (clk_i)
    begin
        if (rst_i='1') then
            BTCTL_w    <= (others=>'0');
            BTCNT_w    <= (others=>'Z');
            BTCCR0_w   <= (others=>'0');
            BTCCR1_w   <= (others=>'0');
        elsif (falling_edge(clk_i)) then
            if (mem_wr_i='1') then
                case addr_bus_i is
                    when X"81C" =>
                        BTCTL_w <= data_bus_io(7 downto 0);
                    when X"820" =>
                        BTCNT_w <= data_bus_io;
                    when X"824" =>
                        BTCCR0_w <= data_bus_io;
                    when X"828" =>
                        BTCCR1_w <= data_bus_io;
                    when others =>
                        null;
                end case;
            end if;
        end if;
    end process;

    read_en_w(0) <= '1' when (addr_bus_i=X"81C" and mem_rd_i='1') else '0';
    read_en_w(1) <= '1' when (addr_bus_i=X"820" and mem_rd_i='1') else '0';
    read_en_w(2) <= '1' when (addr_bus_i=X"824" and mem_rd_i='1') else '0';
    read_en_w(3) <= '1' when (addr_bus_i=X"828" and mem_rd_i='1') else '0';

    data_bus_io <= zero_vec_w & BTCTL_w when read_en_w(0)='1' else
                    BTCNT_w  when read_en_w(1)='1' else
                    BTCCR0_w when read_en_w(2)='1' else
                    BTCCR1_w when read_en_w(3)='1' else
                    (others=>'Z');

    div_cnt: process(clk_i,rst_i)
        variable div4 : std_logic := '0';
        variable div8 : std_logic_vector(1 downto 0) := "00";
    begin 
        if (rst_i='1') then
            mclk2_w <= '0';
			mclk4_w <= '0';
			mclk8_w <= '0';
            div4 := '0';
            div8 := "00";
        elsif (rising_edge(clk_i)) then
            mclk2_w <= not (mclk2_w);
            div4 := not(div4);
			if (div4='1') then
				mclk4_w <= not(mclk4_w);
			end if;
            div8 := std_logic_vector(ieee.numeric_std.unsigned(div8) + 1);
			if (div8="11") then
				mclk8_w <= not(mclk8_w);
			end if;
        end if;
    end process;

    timer: basic_timer port map (
        addr_bus_i      => addr_bus_i,
        BTCCR0_i        => BTCCR0_w,
        BTCCR1_i        => BTCCR1_w,
        BTCLR_i         => BTCTL_w(2),
        BTHOLD_i        => BTCTL_w(5),
        BTSSELx_i       => BTCTL_w(4 downto 3),
        MCLK_i          => clk_i,
        MCLK2_i         => mclk2_w,
        MCLK4_i         => mclk4_w,
        MCLK8_i         => mclk8_w,
        BTIPx_i         => BTCTL_w(1 downto 0),
        BTOUTMD_i       => BTCTL_w(7),
        BTOUTEN_i       => BTCTL_w(6),
        MemWrite_i      => mem_wr_i,
        MemRead_i       => mem_rd_i,
        PWM_o           => pwm_o,
        BTIFG_o         => bt_ifg_o,
        BTCNT_io         => BTCNT_w
    );
end architecture;