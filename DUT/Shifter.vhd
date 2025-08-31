LIBRARY ieee;
USE ieee.std_logic_1164.all;
USE IEEE.STD_LOGIC_ARITH.ALL;
USE IEEE.STD_LOGIC_SIGNED.ALL;
use ieee.numeric_std.all;
-------------------------------------
ENTITY Shifter IS
  GENERIC (n : INTEGER := 8);
  PORT (     ALUFN: IN STD_LOGIC_VECTOR (2 DOWNTO 0);
			 x: in std_logic_vector(4 downto 0);
			 y: IN STD_LOGIC_VECTOR (n-1 DOWNTO 0);
             cout: OUT STD_LOGIC;
             ALUout: OUT STD_LOGIC_VECTOR(n-1 downto 0));
END Shifter;
--------------------------------------------------------------
ARCHITECTURE arc_shift OF Shifter IS
	-- signal temp_y_R : std_logic_vector (n-1 downto 0);
	-- signal temp_y_L : std_logic_vector (n-1 downto 0);
	-- signal carry_out_R : std_logic ;
	-- SIGNAL carry_out_L: std_logic;
	signal y_local_w, y_out_w : std_logic_vector (n-1 downto 0);
	signal mux0_w, mux1_w, mux2_w, mux3_w, mux4_w : std_logic_vector (n-1 downto 0);

BEGIN

	init: for i in 0 to n-1 generate
		y_local_w(i) <= y(i) when (ALUFN(1) = '1') else y(n-1-i);
	end generate;

	mux_0: with x(0) select
		mux0_w <= y_local_w when '0',
				'0' & y_local_w(n-1 downto 1) when others;

	mux_1: with x(1) select
		mux1_w <= mux0_w when '0',
				"00" & mux0_w(n-1 downto 2) when others;

	mux_2: with x(2) select
		mux2_w <= mux1_w when '0',
				"0000" & mux1_w(n-1 downto 4) when others;

	mux_3: with x(3) select
		mux3_w <= mux2_w when '0',
				"00000000" & mux2_w(n-1 downto 8) when others;

	mux_4: with x(4) select
		mux4_w <= mux3_w when '0',
				"0000000000000000" & mux3_w(n-1 downto 16) when others;

	finish: for i in 0 to n-1 generate
		y_out_w(i) <= mux4_w(i) when (ALUFN(1) ='1') else mux4_w(n-1-i);
	end generate;

	ALUout <= y_out_w;
	cout <= y_out_w(n-1-to_integer(ieee.NUMERIC_STD.UNSIGNED(x)));
end architecture;