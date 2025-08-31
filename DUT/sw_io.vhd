LIBRARY ieee;
USE ieee.std_logic_1164.all;
USE work.aux_package.all;
-------------------------------------
ENTITY sw_io IS
    generic (
        DATA_BUS_WIDTH : integer := 32
    );
    PORT (
        data_i      : in std_logic_vector(7 downto 0);
        MemRead_i   : in std_logic;
        CS_i        : in std_logic;
        data_bus_io : inout std_logic_vector(DATA_BUS_WIDTH-1 downto 0)
    );
END sw_io;
--------------------------------------------------------------
ARCHITECTURE sw_io_arc OF sw_io IS
    signal read_en  : std_logic;
    signal zero_vec_w   : std_logic_vector(DATA_BUS_WIDTH-1 downto 8) := (others=>'0');
begin
    read_en  <= CS_i and MemRead_i;

    data_bus_io <= zero_vec_w & data_i when read_en='1' else (others => 'Z');
end architecture;