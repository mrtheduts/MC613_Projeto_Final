library ieee;
use ieee.std_logic_1164.ALL;
use ieee.numeric_std.ALL;
 
entity clk_div is

	port (
		clk,reset: in std_logic;
		clock_out: out std_logic
	);
			
end clk_div;
 
architecture behavior of clk_div is
 
signal count: integer:=1;
signal tmp : std_logic := '0';
 
begin
 
	clock_out <= tmp;
 
	process(clk,reset)
	begin
	
		if(reset = '1') then
			count <= 1;
			tmp <= '0';
			
		elsif(clk'event and clk = '1') then
		
			count <= count + 1;
			
			if (count = 25000000) then
				tmp <= NOT tmp;
				count <= 1;
				
			end if;
			
		end if;
		

		
	end process;
 
end behavior;