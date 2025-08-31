library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_arith.all;
use ieee.std_logic_unsigned.all;
-------------------------------------
ENTITY pulse_synchronizer IS
    PORT ( 
        FIRCLK_i     : in std_logic;
        FIRENA_i     : in std_logic;
        FIFOCLK_i    : in std_logic;
        FIFOREN_o    : out std_logic
    );
END pulse_synchronizer;
--------------------------------------------------------------
architecture pulse_synchronizer_arc of pulse_synchronizer is
    signal ready:     std_logic := '0';
    signal wait_w:      std_logic := '0';
    signal sending:    std_logic := '0';
begin 

    slow_dff: process (FIRCLK_i, sending)
    begin
        if (sending ='1') then
            ready <= '0';
        elsif (rising_edge(FIRCLK_i)) then
            ready <= FIRENA_i;
        end if ;
    end process;

    fast_dff: process (FIFOCLK_i)
    begin
        if (rising_edge(FIFOCLK_i)) then
            if (sending='1') then
                wait_w <= '0';
                sending <= '0';
            else
                wait_w <= ready;
                sending <= wait_w;
            end if;
        end if;
    end process;  

    FIFOREN_o <= sending;
end architecture;