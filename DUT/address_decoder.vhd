LIBRARY ieee;
USE IEEE.STD_LOGIC_1164.ALL;
USE IEEE.STD_LOGIC_ARITH.ALL;
USE IEEE.STD_LOGIC_UNSIGNED.ALL;
USE work.aux_package.all;
-------------------------------------
ENTITY address_decoder IS
    generic (
        ADDRESS_BUS_WIDTH : integer := 12
    );
    PORT (
        address_bus_i : in std_logic_vector(ADDRESS_BUS_WIDTH-1 downto 0);
        cs_vec_o      : out std_logic_vector(7 downto 0)
    );
END address_decoder;
--------------------------------------------------------------
ARCHITECTURE address_decoder_arc OF address_decoder IS
begin
    cs_vec_o(0) <= '1' when address_bus_i=X"800" else '0';
    cs_vec_o(1) <= '1' when (address_bus_i=X"804" or address_bus_i=X"805") else '0';
    cs_vec_o(2) <= '1' when (address_bus_i=X"808" or address_bus_i=X"809") else '0';
    cs_vec_o(3) <= '1' when (address_bus_i=X"80C" or address_bus_i=X"80D") else '0';
    cs_vec_o(4) <= '1' when address_bus_i=X"810" else '0';
    cs_vec_o(7 downto 5) <= (others=>'0');
end architecture;