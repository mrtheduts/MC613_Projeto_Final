LIBRARY ieee;
USE ieee.std_logic_1164.all;
use ieee.numeric_std.all;


entity muda_andar is
	port (
		andar_atual 	: inout integer range 0 to 7;
		andar_destino 	: in integer range 0 to 7;
		clock 			: in std_logic -- clock_div
    );
end muda_andar;

architecture comportamento of muda_andar is
begin
	
	
	process(clock)
	begin
		if clock'EVENT and clock = '1' then
			if(andar_atual < andar_destino) then
				andar_atual <= andar_atual + 1;
			elsif(andar_atual > andar_destino) then
				andar_atual <= andar_atual - 1;
			end if;
		end if;
	end process;
	
end comportamento;

