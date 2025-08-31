library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_arith.all;
use ieee.std_logic_unsigned.all;
-------------------------------------
ENTITY basic_timer IS
    GENERIC (
        DATA_BUS_WIDTH : INTEGER := 32;
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
END basic_timer;
--------------------------------------------------------------
architecture basic_timer_arc of basic_timer is
    signal BTCNT_w: std_logic_vector(DATA_BUS_WIDTH-1 downto 0) := (others=>'0');
    signal HEU0_w: std_logic := '0';
    signal wave: std_logic;
    signal clk_w: std_logic;
    signal en_w: std_logic;
    signal BTCCR0_w : std_logic_vector(DATA_BUS_WIDTH-1 downto 0) := (others=>'0');
    signal BTCCR1_w : std_logic_vector(DATA_BUS_WIDTH-1 downto 0) := (others=>'0');
    signal BTCNT_eq_0 : std_logic;
    signal zero_vec_w    : std_logic_vector (DATA_BUS_WIDTH-1 downto 0) := (others=>'0');
begin

    BTCNT_io <= BTCNT_w when (addr_bus_i=X"820" and MemRead_i='1') else (others=>'Z');

    R_latch: process(MCLK_i, BTCNT_eq_0)
    begin
        if (falling_edge(MCLK_i)) then
            if (BTCNT_eq_0='1') then
                BTCCR0_w <= BTCCR0_i;
                BTCCR1_w <= BTCCR1_i;
            end if;
        end if;
    end process;

    clk_mux: with BTSSELx_i select
        clk_w <= MCLK_i when "00",
                MCLK2_i when "01",
                MCLK4_i when "10",
                MCLK8_i when "11",
                '0' when others;

    en_w <= not(BTHOLD_i);

	count: process(clk_w, BTCLR_i, en_w)
    begin
        if (BTCLR_i='1') then
            BTCNT_w <= (others => '0');
            BTCNT_eq_0 <= '1';
        elsif (clk_w'event and clk_w='1') then
            if (addr_bus_i=X"820" and MemWrite_i='1') then
                BTCNT_w <= BTCNT_io;
            end if;
            if (en_w='1') then
                if (HEU0_w='1') then
                    BTCNT_w <= (others=>'0');
                    BTCNT_eq_0 <= '1';
                else
                    BTCNT_w <= BTCNT_w+1;
                    BTCNT_eq_0 <= '0';
                end if;
            end if;
        end if;
    end process;

    output_unit: process(clk_w, BTOUTEN_i, BTOUTMD_i)
    begin
        if (BTCNT_w=BTCCR0_w and BTCCR0_w /= zero_vec_w) then
            HEU0_w <= '1';
        else
            HEU0_w <= '0';
        end if;
        if (clk_w'event and clk_w='1') then
            if (BTOUTEN_i='1') then
                case BTOUTMD_i is
                    when '0' =>
                        if (BTCNT_w < BTCCR1_w) then
                            wave <= '0';
                        else
                            wave <= '1';
                        end if;
                    when '1' =>
                        if (BTCNT_w < BTCCR1_w) then
                            wave <= '1';
                        else
                            wave <= '0';
                        end if;
                    when others =>
                        wave <= '0';
                end case;
            end if;
        end if;
    end process;
	
    flag_mux: with BTIPx_i select
        BTIFG_o <= HEU0_w when "00",
                    BTCNT_w(23) when "01",
                    BTCNT_w(27) when "10",
                    BTCNT_w(31) when "11",
                    '0' when others;

    PWM_o <= wave;
end architecture;