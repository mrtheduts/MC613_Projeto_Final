library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.ALL;

entity call_ctrl is
  port (
    clk : in std_logic;
	 call_elevator : in std_logic_vector (7 downto 0);
	 numpad_elevator : in std_logic_vector (7 downto 0);
    andares_req_up_in : in std_logic_vector (7 downto 0);
	 andares_req_down_in : in std_logic_vector (7 downto 0);
	 andares_dest_in : in std_logic_vector (7 downto 0);
	 andares_req_up_out : out std_logic_vector (7 downto 0);
	 andares_req_down_out : out std_logic_vector (7 downto 0);
	 andares_dest_out : out std_logic_vector (7 downto 0)
  );
end call_ctrl;

architecture behavior of call_ctrl is
	
	signal andares_req_up_aux : std_logic_vector (7 downto 0) := x"00";
	signal andares_req_down_aux : std_logic_vector (7 downto 0) := x"00";
	signal andares_dest_aux : std_logic_vector (7 downto 0) := x"00";
	
begin

andares_req_up_out <= andares_req_up_in or andares_req_up_aux;
andares_req_down_out <= andares_req_down_in or andares_req_down_aux;
andares_dest_out <= andares_dest_in or andares_dest_aux;

process(clk)
begin

	if (clk'event and clk = '1') then
	
			CASE call_elevator IS
				
				WHEN x"6B" => andares_req_down_aux <= x"80"; --8 DOWN
				
				WHEN x"75" => andares_req_up_aux <= x"40"; --7 UP
				WHEN x"6A" => andares_req_down_aux <= x"40"; --7 DOWN
				
				WHEN x"79" => andares_req_up_aux <= x"20"; --6 UP
				WHEN x"68" => andares_req_down_aux <= x"20"; --6 DOWN
				
				WHEN x"74" => andares_req_up_aux <= x"10"; --5 UP
				WHEN x"67" => andares_req_down_aux <= x"10"; --5 DOWN
				
				WHEN x"72" => andares_req_up_aux <= x"08"; --4 UP
				WHEN x"66" => andares_req_down_aux <= x"08"; --4 DOWN
				
				WHEN x"65" => andares_req_up_aux <= x"04"; --3 UP
				WHEN x"64" => andares_req_down_aux <= x"04"; --3 DOWN
				
				WHEN x"77" => andares_req_up_aux <= x"02"; --2 UP
				WHEN x"73" => andares_req_down_aux <= x"02"; --2 DOWN
				
				WHEN x"71" => andares_req_up_aux <= x"01"; --1 UP
				
				WHEN OTHERS =>
						andares_req_up_aux <= x"00";
						andares_req_down_aux <= x"00";
			END CASE;
			
			
			CASE numpad_elevator IS  
				
				WHEN x"31" => andares_dest_aux <= x"01"; --1
				WHEN x"32" => andares_dest_aux <= x"02"; --2
				WHEN x"33" => andares_dest_aux <= x"04"; --3
				WHEN x"34" => andares_dest_aux <= x"08"; --4
				WHEN x"35" => andares_dest_aux <= x"10"; --5
				WHEN x"36" => andares_dest_aux <= x"20"; --6
				WHEN x"37" => andares_dest_aux <= x"40"; --7
				WHEN x"38" => andares_dest_aux <= x"80"; --8
				
				WHEN OTHERS => andares_dest_aux <= x"00";
			END CASE;
	
	end if;
	
end process;

end behavior;