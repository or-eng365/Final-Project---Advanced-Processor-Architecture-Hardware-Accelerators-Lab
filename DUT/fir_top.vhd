library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_arith.all;
use ieee.std_logic_unsigned.all;
use ieee.numeric_std.all;
use work.aux_package.all;
-------------------------------------
ENTITY fir_top IS
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
END fir_top;
--------------------------------------------------------------
architecture fir_top_arc of fir_top is
    signal FIRIN_w      : std_logic_vector(DATA_BUS_WIDTH-1 downto 0);
    signal FIROUT_w     : std_logic_vector(DATA_BUS_WIDTH-1 downto 0) := (others=>'0');
    signal FIRCTL_w     : std_logic_vector(7 downto 0) := (others=>'0');
    signal COEF3_0_w    : std_logic_vector(DATA_BUS_WIDTH-1 downto 0);
    signal COEF7_4_w    : std_logic_vector(DATA_BUS_WIDTH-1 downto 0);
    signal read_en_w    : std_logic_vector(4 downto 0) := (others=>'0');
    signal zero_vec_w   : std_logic_vector(23 downto 0) := (others=>'0');
    signal fir_ena_w    : std_logic;
    signal fir_rst_w    : std_logic;
    signal fifo_empty_w : std_logic;
    signal fifo_full_w  : std_logic;
    signal fifo_rst_w    : std_logic;
    signal fifo_wen_w    : std_logic;
begin
    -- registers --
    fir_regs: process (clk_i)
    begin
        if (rst_i='1') then
            --- FIRCTL ---
            fir_ena_w   <= '0';
            fir_rst_w   <= '0';
            fifo_rst_w   <= '0';
            fifo_wen_w   <= '0';

            FIRIN_w     <= (others=>'0');
            COEF3_0_w   <= (others=>'0');
            COEF7_4_w   <= (others=>'0');
        elsif (falling_edge(clk_i)) then
            if (mem_wr_i='1') then
                case addr_bus_i is
                    when X"82C" =>
                        fir_ena_w <= data_bus_io(0);
                        fir_rst_w <= data_bus_io(1);
                        fifo_rst_w <= data_bus_io(4);
                        fifo_wen_w <= data_bus_io(5);
                    when X"830" =>
                        FIRIN_w <= data_bus_io;
                    when X"838" =>
                        COEF3_0_w <= data_bus_io;
                    when X"83C" =>
                        COEF7_4_w <= data_bus_io;
                    when others => 
                        null;
                end case;
            end if;
            if (fifo_wen_w='1') then
                fifo_wen_w <= '0';
            end if;
        end if;
    end process;

    FIRCTL_w <= (0=> fir_ena_w, 1=> fir_rst_w, 2=> fifo_empty_w, 3=> fifo_full_w, 
                    4=> fifo_rst_w, 5=> fifo_wen_w,6=> '0', 7=> '0');

    read_en_w(0) <= '1' when (addr_bus_i=X"82C" and mem_rd_i='1') else '0';
    read_en_w(1) <= '1' when (addr_bus_i=X"830" and mem_rd_i='1') else '0';
    read_en_w(2) <= '1' when (addr_bus_i=X"834" and mem_rd_i='1') else '0';
    read_en_w(3) <= '1' when (addr_bus_i=X"838" and mem_rd_i='1') else '0';
    read_en_w(4) <= '1' when (addr_bus_i=X"83C" and mem_rd_i='1') else '0';

    data_bus_io <= zero_vec_w & FIRCTL_w when read_en_w(0)='1' else
                    FIRIN_w  when read_en_w(1)='1' else
                    FIROUT_w when read_en_w(2)='1' else
                    COEF3_0_w when read_en_w(3)='1' else
                    COEF7_4_w when read_en_w(4)='1' else
                    (others=>'Z');

    -- logic --
    FIR_filter: FIR port map(
        FIRIN_i     =>  FIRIN_w,
        coef0_i     =>  COEF3_0_w(7 downto 0),
        coef1_i     =>  COEF3_0_w(15 downto 8),
        coef2_i     =>  COEF3_0_w(23 downto 16),
        coef3_i     =>  COEF3_0_w(DATA_BUS_WIDTH-1 downto 24),
        coef4_i     =>  COEF7_4_w(7 downto 0),
        coef5_i     =>  COEF7_4_w(15 downto 8),
        coef6_i     =>  COEF7_4_w(23 downto 16),
        coef7_i     =>  COEF7_4_w(DATA_BUS_WIDTH-1 downto 24),
        FIFORST_i   =>  fifo_rst_w,
        FIFOCLK_i   =>  clk_i,
        FIFOWEN_i   =>  fifo_wen_w,
        FIRCLK_i    =>  clk2_i,
        FIRRST_i    =>  fir_rst_w,
        FIRENA_i    =>  fir_ena_w,
        FIROUT_o    =>  FIROUT_w,
        FIFOFULL_o  =>  fifo_full_w,
        FIFOEMPTY_o =>  fifo_empty_w,
        fir_ifg_o   =>  fir_ifg_o,
        fifo_ifg_o  => fifo_ifg_o
    );

    fifo_empty_o <= fifo_empty_w;
end architecture;