LIBRARY ieee;
USE ieee.std_logic_1164.all;
use ieee.numeric_std.all;
USE work.cond_comilation_package.all;
USE work.aux_package.all;
-------------------------------------
ENTITY FIR IS
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
END FIR;
--------------------------------------------------------------
ARCHITECTURE FIR_arc OF FIR is
    signal data_out_w   : std_logic_vector(W-1 downto 0) := (others=>'0');
    signal fifo_ren_w   : std_logic;
    signal calc_ifg_w   : std_logic;
    signal new_out_w    : std_logic := '0';
    signal fifo_empty_w : std_logic := '0';
begin

    p_syn: pulse_synchronizer port map (
        FIRCLK_i    => FIRCLK_i,
        FIRENA_i    => FIRENA_i,
        FIFOCLK_i   => FIFOCLK_i,
        FIFOREN_o   => fifo_ren_w
    );

    fifo_reg: fifo port map (
        FIFORST_i   => FIFORST_i,
        FIFOCLK_i   => FIFOCLK_i,
        FIFOWEN_i   => FIFOWEN_i,
        FIFOIN_i    => FIRIN_i,
        FIFOREN_i   => fifo_ren_w,
        FIFOFULL_o  => FIFOFULL_o,
        FIFOEMPTY_o => fifo_empty_w,
        new_out_o   => new_out_w,
        DATAOUT_o   => data_out_w
    );

    calculation: filter port map (
        coef_0      => coef0_i,
        coef_1      => coef1_i,
        coef_2      => coef2_i,
        coef_3      => coef3_i,
        coef_4      => coef4_i,
        coef_5      => coef5_i,
        coef_6      => coef6_i,
        coef_7      => coef7_i,
        sample_i    => data_out_w,
        FIRCLK_i    => FIRCLK_i,
        FIRRST_i    => FIRRST_i,
        FIRENA_i    => FIRENA_i,
        new_out_i   => new_out_w,
        ifg_o       => calc_ifg_w,
        data_o      => FIROUT_o
    );

    fir_ifg_o <= '1' when calc_ifg_w='1' else '0';
    fifo_ifg_o <= '1' when fifo_empty_w='1' else '0';
    FIFOEMPTY_o <= '1' when fifo_empty_w='1' else '0';
end architecture;