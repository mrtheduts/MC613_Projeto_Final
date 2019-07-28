library ieee;
use ieee.std_logic_1164.all;

entity kbd_alphanum is
  port (
    clk : in std_logic;
    key_on : in std_logic;
    key_code : in std_logic_vector(15 downto 0);
	 numpad_elevator : out std_logic_vector(7 downto 0);
	 call_elevator : out std_logic_vector(7 downto 0)
  );
end kbd_alphanum;

architecture rtl of kbd_alphanum is
	
	signal key: std_logic_vector(7 downto 0);
	
begin

	
	key <= key_code(7 downto 0);

	process(clk)
	begin
	
		if (clk'EVENT and clk ='1') then
		
			CASE key IS
			
				WHEN x"23" => call_elevator <= x"64"; --d
				WHEN x"24" => call_elevator <= x"65"; --e
				WHEN x"2B" => call_elevator <= x"66"; --f
				WHEN x"34" => call_elevator <= x"67"; --g
				WHEN x"33" => call_elevator <= x"68"; --h
				WHEN x"3B" => call_elevator <= x"6A"; --j
				WHEN x"42" => call_elevator <= x"6B"; --k
				WHEN x"15" => call_elevator <= x"71"; --q
				WHEN x"2D" => call_elevator <= x"72"; --r
				WHEN x"1B" => call_elevator <= x"73"; --s
				WHEN x"2C" => call_elevator <= x"74"; --t
				WHEN x"3C" => call_elevator <= x"75"; --u
				WHEN x"1D" => call_elevator <= x"77"; --w
				WHEN x"35" => call_elevator <= x"79"; --y
				
				WHEN OTHERS => call_elevator <= x"00";
			END CASE;
			
			
			CASE key IS  
				
				WHEN x"69" => numpad_elevator <= x"31"; --1
				WHEN x"72" => numpad_elevator <= x"32"; --2
				WHEN x"7A" => numpad_elevator <= x"33"; --3
				WHEN x"6B" => numpad_elevator <= x"34"; --4
				WHEN x"73" => numpad_elevator <= x"35"; --5
				WHEN x"74" => numpad_elevator <= x"36"; --6
				WHEN x"6C" => numpad_elevator <= x"37"; --7
				WHEN x"75" => numpad_elevator <= x"38"; --8
				
				WHEN OTHERS => numpad_elevator <= x"00";
			END CASE;
			
		end if;
		
	end process;

end rtl;

