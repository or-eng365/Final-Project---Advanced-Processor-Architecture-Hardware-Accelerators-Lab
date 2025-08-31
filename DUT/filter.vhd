library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_arith.all;
use ieee.numeric_std.all;
use ieee.std_logic_unsigned.all;
-------------------------------------
ENTITY filter IS
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
            ifg_o       : out std_logic;
            data_o      : out std_logic_vector(DATA_BUS_WIDTH-1 downto 0)
    );
END filter;
--------------------------------------------------------------
architecture filter_arch of filter is
    signal x_n_1    : std_logic_vector(W-1 downto 0) := (others=>'0');
    signal x_n_2    : std_logic_vector(W-1 downto 0) := (others=>'0');
    signal x_n_3    : std_logic_vector(W-1 downto 0) := (others=>'0');
    signal x_n_4    : std_logic_vector(W-1 downto 0) := (others=>'0');
    signal x_n_5    : std_logic_vector(W-1 downto 0) := (others=>'0');
    signal x_n_6    : std_logic_vector(W-1 downto 0) := (others=>'0');
    signal x_n_7    : std_logic_vector(W-1 downto 0) := (others=>'0');
    signal y_n_1    : std_logic_vector(W+Q-1 downto 0) := (others=>'0');
    signal mul_1_w  : ieee.numeric_std.unsigned(W+Q-1 downto 0);
    signal mul_2_w  : ieee.numeric_std.unsigned(W+Q-1 downto 0);
    signal mul_3_w  : ieee.numeric_std.unsigned(W+Q-1 downto 0);
    signal mul_4_w  : ieee.numeric_std.unsigned(W+Q-1 downto 0);
    signal mul_5_w  : ieee.numeric_std.unsigned(W+Q-1 downto 0);
    signal mul_6_w  : ieee.numeric_std.unsigned(W+Q-1 downto 0);
    signal mul_7_w  : ieee.numeric_std.unsigned(W+Q-1 downto 0);
    signal mul_8_w  : ieee.numeric_std.unsigned(W+Q-1 downto 0);
    signal new_out_w: std_logic := '0';
    signal ifg_w    : std_logic := '0';
    signal data_out_w : std_logic_vector(DATA_BUS_WIDTH-1 downto 0) := (others=>'0');
    signal zero_vec2_w: std_logic_vector(q-1 downto 0) := (others=>'0');
begin

    --- calculations ---
    mul_1_w <= (ieee.numeric_std.unsigned(sample_i) * ieee.numeric_std.unsigned(coef_0));
    mul_2_w <= (ieee.numeric_std.unsigned(x_n_1) * ieee.numeric_std.unsigned(coef_1));
    mul_3_w <= (ieee.numeric_std.unsigned(x_n_2) * ieee.numeric_std.unsigned(coef_2));
    mul_4_w <= (ieee.numeric_std.unsigned(x_n_3) * ieee.numeric_std.unsigned(coef_3));
    mul_5_w <= (ieee.numeric_std.unsigned(x_n_4) * ieee.numeric_std.unsigned(coef_4));
    mul_6_w <= (ieee.numeric_std.unsigned(x_n_5) * ieee.numeric_std.unsigned(coef_5));
    mul_7_w <= (ieee.numeric_std.unsigned(x_n_6) * ieee.numeric_std.unsigned(coef_6));
    mul_8_w <= (ieee.numeric_std.unsigned(x_n_7) * ieee.numeric_std.unsigned(coef_7));

    y_n_1 <= std_logic_vector(mul_1_w + mul_2_w + mul_3_w + mul_4_w + 
                                mul_5_w + mul_6_w + mul_7_w + mul_8_w);

    final_result: process (FIRCLK_i, FIRRST_i, FIRENA_i, new_out_i)
    begin
        if (FIRRST_i='1') then
            data_out_w <= (others=>'0');
            --- sample registers ---
            x_n_1   <= (others =>'0');
            x_n_2   <= (others =>'0');
            x_n_3   <= (others =>'0');
            x_n_4   <= (others =>'0');
            x_n_5   <= (others =>'0');
            x_n_6   <= (others =>'0');
            x_n_7   <= (others =>'0');
        elsif (new_out_i='1') then
            new_out_w <= '1';
            ifg_w <= '0';
        elsif (falling_edge(FIRCLK_i)) then
            if (FIRENA_i ='1') then
                --- out logic ---
                data_out_w <= zero_vec2_w & y_n_1(DATA_BUS_WIDTH-1 downto q);
                new_out_w <= '0';
                --- register logic ---
                if (new_out_w='1') then
                    new_out_w <= '0';
                    ifg_w <= '1';
                    x_n_1 <= sample_i;
                    x_n_2 <= x_n_1;
                    x_n_3 <= x_n_2;
                    x_n_4 <= x_n_3;
                    x_n_5 <= x_n_4;
                    x_n_6 <= x_n_5;
                    x_n_7 <= x_n_6;
                end if;
            else
                data_out_w <= (others=>'0');
            end if;
        end if;
    end process;
 
    data_o <= data_out_w;
    ifg_o <= ifg_w;

end architecture;