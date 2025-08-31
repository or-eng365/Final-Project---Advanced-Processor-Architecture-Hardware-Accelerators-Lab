library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_arith.all;
use ieee.numeric_std.all;
use ieee.std_logic_unsigned.all;
-------------------------------------
ENTITY FIFO IS
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
END FIFO;
--------------------------------------------------------------
architecture FIFO_arc of FIFO is
    TYPE reg IS ARRAY (0 TO K-1) OF STD_LOGIC_VECTOR(W-1 DOWNTO 0);

    signal fifo_count   : std_logic_vector (3 downto 0) := (others=>'0');
    signal wr_idx       : std_logic_vector(2 downto 0) := (others=>'0');
    signal rd_idx       : std_logic_vector(2 downto 0) := (others=>'0');
    signal empty_w      : std_logic;
    signal full_w       : std_logic;
    signal data_out_w   : std_logic_vector(W-1 downto 0) := (others=>'0');
    signal new_out_w    : std_logic := '0';
    signal fifo_reg     : reg := (others => (others=>'0'));
begin

    FIFO: process (FIFOCLK_i, FIFORST_i, FIFOWEN_i, FIFOREN_i, full_w, empty_w)
    begin
        if (FIFORST_i = '1') then 
            fifo_count  <= (others => '0');
            wr_idx      <= (others => '0');
            rd_idx      <= (others => '0');
            new_out_w   <= '0';
        elsif (rising_edge(FIFOCLK_i)) then
            if (new_out_w='1') then
                new_out_w <= '0';
            end if;
            --- write & read ---
            if (FIFOWEN_i ='1'  and full_w='0' and FIFOREN_i='1' and empty_w='0') then
                fifo_reg(conv_integer(wr_idx)) <= FIFOIN_i(W-1 downto 0);
                data_out_w   <= fifo_reg(conv_integer(rd_idx));
                new_out_w   <= '1';
                wr_idx     <= std_logic_vector(ieee.numeric_std.unsigned(wr_idx)+1);
                rd_idx     <= std_logic_vector(ieee.numeric_std.unsigned(rd_idx)+1);
            --- write only ---
            elsif (FIFOWEN_i ='1'  and full_w='0') then
                fifo_count <= std_logic_vector(ieee.numeric_std.unsigned(FIFO_COUNT)+1);
                fifo_reg(conv_integer(wr_idx)) <= FIFOIN_i(W-1 downto 0);
                wr_idx     <= std_logic_vector(ieee.numeric_std.unsigned(wr_idx)+1);
            --- read only ---
            elsif (FIFOREN_i='1' and empty_w='0') then
                fifo_count  <= std_logic_vector(ieee.numeric_std.unsigned(fifo_count)-1);
                data_out_w   <= fifo_reg(conv_integer(rd_idx));
                new_out_w   <= '1';
                rd_idx      <= std_logic_vector(ieee.numeric_std.unsigned(rd_idx)+1);
            end if;
        end if;
    end process;

    full_w <= '1' when ((FIFO_COUNT = X"8") and wr_idx=rd_idx and empty_w='0') else '0';
    empty_w <= '1' when ((FIFO_COUNT = X"0") and wr_idx=rd_idx) else '0';

    FIFOFULL_o <= full_w;
    FIFOEMPTY_o <= empty_w;
    new_out_o <= new_out_w;
    DATAOUT_o <= data_out_w;

end architecture;