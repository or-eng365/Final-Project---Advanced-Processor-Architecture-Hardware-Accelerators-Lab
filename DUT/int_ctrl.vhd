library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_arith.all;
use ieee.std_logic_unsigned.all;
-------------------------------------
ENTITY int_ctrl IS
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
END int_ctrl;
--------------------------------------------------------------
architecture int_ctrl_arc of int_ctrl is
TYPE type_register IS ARRAY (0 TO 9) OF STD_LOGIC_VECTOR(7 DOWNTO 0);
    signal TYPE_r      : type_register := (X"00",X"04",X"08",X"0C",X"10",X"14",X"18",X"1C"
                                            ,X"20",X"24");
    signal IE_r      : std_logic_vector(7 downto 0) := (others => '0');
    signal IFG_r      : std_logic_vector(7 downto 0) := (others => '0');
    signal highest_priority_w : integer := 0;
    signal enabled_flags_w  : std_logic_vector(7 downto 0);
    signal zero_vec_w       : std_logic_vector(23 downto 0) := (others=>'0');
    signal cur_type         : std_logic_vector(7 downto 0);
    signal rx_clr_w         : std_logic := '0';
    signal rx_irq_w         : std_logic := '0';
    signal tx_clr_w         : std_logic := '0';
    signal tx_irq_w         : std_logic := '0';
    signal bt_clr_w         : std_logic := '0';
    signal bt_irq_w         : std_logic := '0';
    signal fir_clr_w        : std_logic := '0';
    signal fir_irq_w         : std_logic := '0';
    signal fifo_clr_w        : std_logic := '0';
    signal fifo_irq_w         : std_logic := '0';
    signal firo_irq_w          : std_logic := '0';
    signal fir_int_en_w        : std_logic := '0';
    signal fifo_int_en_w        : std_logic := '0';
    signal key1_irq_w         : std_logic := '0';
    signal key1_clr_w           : std_logic := '0';
    signal key2_irq_w         : std_logic := '0';
    signal key2_clr_w           : std_logic := '0';
    signal key3_irq_w         : std_logic := '0';
    signal key3_clr_w           : std_logic := '0';
    signal clk_cnt_w        : integer := 0;
begin

    rx_ifg: process (RX_INT_i, rx_clr_w)
    begin
        if (rx_clr_w='1') then
            rx_irq_w <= '0';
        elsif (rising_edge(RX_INT_i)) then
            rx_irq_w <= '1';
        end if;
    end process;

    tx_ifg: process (TX_INT_i, tx_clr_w)
    begin
        if (tx_clr_w='1') then
            tx_irq_w <= '0';
        elsif (rising_edge(TX_INT_i)) then
            tx_irq_w <= '1';
        end if;
    end process;

    bt_ifg: process (BT_INT_i, bt_clr_w)
    begin
        if (bt_clr_w='1') then
            bt_irq_w <= '0';
        elsif (rising_edge(BT_INT_i)) then
            bt_irq_w <= '1';
        end if;
    end process;

    fir_ifg: process (FIR_INT_i, fir_clr_w)
    begin
        if (fir_clr_w='1') then
            fir_irq_w <= '0';
        elsif (rising_edge(FIR_INT_i)) then
            fir_irq_w <= '1';
        end if;
    end process;

    fifo_ifg: process (FIFO_INT_i, fifo_clr_w)
    begin
        if (fifo_clr_w='1') then
            fifo_irq_w <= '0';
        elsif (rising_edge(FIFO_INT_i)) then
            fifo_irq_w <= '1';
        end if;
    end process;

    key1_ifg: process (KEY1_INT_i, key1_clr_w)
    begin
        if (key1_clr_w='1') then
            key1_irq_w <= '0';
        elsif (rising_edge(KEY1_INT_i)) then
            key1_irq_w <= '1';
        end if;
    end process;

    key2_ifg: process (KEY2_INT_i, key2_clr_w)
    begin
        if (key2_clr_w='1') then
            key2_irq_w <= '0';
        elsif (rising_edge(KEY2_INT_i)) then
            key2_irq_w <= '1';
        end if;
    end process;

    key3_ifg: process (KEY3_INT_i, key3_clr_w)
    begin
        if (key3_clr_w='1') then
            key3_irq_w <= '0';
        elsif (rising_edge(KEY3_INT_i)) then
            key3_irq_w <= '1';
        end if;
    end process;

    firo_irq_w <= '1' when (fifo_irq_w='1' or fir_irq_w='1') else '0';
    fir_int_en_w <= IE_r(6) and fir_irq_w;
    fifo_int_en_w <= IE_r(6) and fifo_irq_w;


    ifg_handle: process (clk_i, rst_i)
    begin
        if (rst_i='1') then
            IFG_r   <= (others=>'0');
            IE_r    <= (others=>'0');
        elsif (falling_edge(clk_i)) then
            --- clear clear flags ---
            if (rx_clr_w='1') then
                rx_clr_w <= '0';
            end if;
            if (tx_clr_w='1') then
                tx_clr_w <= '0';
            end if;
            if (bt_clr_w='1') then
                bt_clr_w <= '0';
            end if;
            if (fir_clr_w='1') then
                fir_clr_w <= '0';
            end if;
            if (fifo_clr_w='1') then
                fifo_clr_w <= '0';
            end if;
            if (key1_clr_w='1') then
                key1_clr_w <= '0';
            end if;
            if (key2_clr_w='1') then
                key2_clr_w <= '0';
            end if;
            if (key3_clr_w='1') then
                key3_clr_w <= '0';
            end if;
            --- set handled falg to 0 ---
            if (INTA_i = '0') then
                clk_cnt_w <= 1;
            elsif (clk_cnt_w=1) then
                if (highest_priority_w=1) then
                    rx_clr_w <= '1';
                    clk_cnt_w <= 0;
                elsif (highest_priority_w=3) then
                    tx_clr_w <= '1';
                    clk_cnt_w <= 0;
                elsif (highest_priority_w=4) then
                    bt_clr_w <= '1';
                    clk_cnt_w <= 0;
                elsif (highest_priority_w=8) then
                    fifo_clr_w <= '1';
                    clk_cnt_w <= 0;
                elsif (highest_priority_w=9) then 
                    fir_clr_w <= '1';
                    clk_cnt_w <= 0;
                else
                    clk_cnt_w <= 0;
                end if;
            end if;
            --- read / write internal registers ---
            if (CS_i='1') then
                if (MemWrite_ctrl_i='1') then 
                    if (A0_i='0') then
                        IE_r <= data_bus_io(7 downto 0);
                    else
                        IFG_r <= data_bus_io(7 downto 0);
                        rx_clr_w   <= not(data_bus_io(0));
                        tx_clr_w   <= not(data_bus_io(1));
                        bt_clr_w   <= not(data_bus_io(2));
                        key1_clr_w <= not(data_bus_io(3));
                        key2_clr_w <= not(data_bus_io(4));
                        key3_clr_w <= not(data_bus_io(5));
                        fir_clr_w  <= not(data_bus_io(6));
                        fifo_clr_w <= not(data_bus_io(6));
                    end if;
                end if;
            else
                --- set highest priority flag ---
                IFG_r <= enabled_flags_w and IE_r;
            end if;
        end if;
    end process;
    enabled_flags_w <= (0=>rx_irq_w, 1=> tx_irq_w, 2=> bt_irq_w, 3=> key1_irq_w, 
                        4=> key2_irq_w, 5=> key3_irq_w, 6=> firo_irq_w, 7=> '0');
    data_bus_io <= zero_vec_w & IE_r when (A0_i = '0' and CS_i='1' and  MemRead_ctrl_i='1') else 
                    zero_vec_w & IFG_r when (A0_i = '1' and CS_i='1' and  MemRead_ctrl_i='1') else
                    zero_vec_w & cur_type when INTA_i = '0' else 
                    (others => 'Z');

    ifg_o <= IFG_r;


    priority: process (IFG_r, fir_int_en_w, fifo_int_en_w)
    begin
        if    IFG_r(0) = '1' then highest_priority_w <= 1;
        elsif IFG_r(1) = '1' then highest_priority_w <= 3;
        elsif IFG_r(2) = '1' then highest_priority_w <= 4;
        elsif IFG_r(3) = '1' then highest_priority_w <= 5;
        elsif IFG_r(4) = '1' then highest_priority_w <= 6;
        elsif IFG_r(5) = '1' then highest_priority_w <= 7;
        elsif (IFG_r(6) and fifo_irq_w) = '1' then highest_priority_w <= 8;
        elsif (IFG_r(6) and fir_irq_w) = '1' then highest_priority_w <= 9;
        end if;
    end process;

    --- set INTR=1 when there is an interrupt to handle ---
    INTR_o <= '1' when (IFG_r /= X"00" and GIE = '1') else '0';
    
    -- write type value of highest priority to data bus ---
    cur_type <= TYPE_r(highest_priority_w);
end architecture;