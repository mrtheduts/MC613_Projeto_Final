LIBRARY ieee;
USE ieee.std_logic_1164.all;
use ieee.numeric_std.all;


entity decide_andar is
	port (
		estado 			: inout std_logic;
		andar_atual 	: inout integer range 0 to 7;
		paradas_subida : in std_logic_vector(7 downto 0); 	-- or dos dois vetores de subida
		paradas_descida: in std_logic_vector(7 downto 0); -- or dos dois vetores de descida
		paradas_subida_out : out std_logic_vector(7 downto 0); 	-- or dos dois vetores de subida
		paradas_descida_out: out std_logic_vector(7 downto 0); -- or dos dois vetores de descida
		mascara_subir 	: inout std_logic_vector(7 downto 0);
		mascara_descer : inout std_logic_vector(7 downto 0);
		clock_div 			: in std_logic; 							-- clock_div
		clock_50				: in std_logic;
		andar_destino 	: inout integer range 0 to 7;
		LEDR				: out std_logic;
		HEX4				: out std_logic_vector(6 downto 0);
		HEX5				: out std_logic_vector(6 downto 0)
    );
end decide_andar;

architecture comportamento of decide_andar is

	component bin2hex is
	port (
		bin_in: in std_logic_vector(3 downto 0);
		bcd_out: out std_logic_vector(6 downto 0)
	);
	end component;

	signal tempo_estado : integer := 0; -- tempo para mudar de estado
	signal tempo_parado : integer := 0;
	signal mudar_andar : std_logic;
	signal subida_aux, descida_aux: std_logic_vector(7 downto 0);
	signal comecou_subida, comecou_descida, espera_ativa : std_logic;

	begin
	
	bintohex_atual: bin2hex port map(std_logic_vector(to_unsigned(andar_atual, 4)), HEX4);
	bintohex_destino: bin2hex port map(std_logic_vector(to_unsigned(andar_destino, 4)), HEX5);
	
	LEDR <= estado;
	
	process(clock_50)
	begin
		mascara_subir <= subida_aux;
		mascara_descer <= descida_aux;
		
--		paradas_subida_out <= paradas_subida AND (NOT mascara_subir);
--		paradas_descida_out <= paradas_descida AND (NOT mascara_descer);
	
	end process;
	
	process(clock_div)
	begin
		if clock_div'EVENT and clock_div = '1' then
			subida_aux <= (others => '0');
			descida_aux <= (others => '0');
			
			if(andar_atual = andar_destino and mudar_andar = '0') and 
				(paradas_subida(andar_atual) = '1' or paradas_descida(andar_atual) = '1') then
				
				if(tempo_parado <= (5)) then
					tempo_parado <= tempo_parado + 1;
					
					
				else
					
					tempo_parado <= 0;
					mudar_andar <= '1';
					
					if(estado = '0') then
						subida_aux(andar_atual) <= '1';
					elsif(estado = '1') then
						descida_aux(andar_atual) <= '1';
					end if;
				end if;
				
			elsif(estado = '0' and paradas_subida /= x"00") then -- subida
				
				mudar_andar <= '0';
				
				if(paradas_subida(0) = '1' and andar_atual >= 0 and comecou_subida = '1') then
					andar_destino <= 0;
					tempo_estado <= 0;
					comecou_subida <= '0';
				elsif(paradas_subida(1) = '1' and andar_atual > 1 and comecou_subida = '1') then
					andar_destino <= 1;
					tempo_estado <= 0;
					comecou_subida <= '0';
				elsif(paradas_subida(2) = '1' and andar_atual > 2 and comecou_subida = '1') then
					andar_destino <= 2;
					tempo_estado <= 0;
					comecou_subida <= '0';
				elsif(paradas_subida(3) = '1' and andar_atual > 3 and comecou_subida = '1') then
					andar_destino <= 3;
					tempo_estado <= 0;
					comecou_subida <= '0';
				elsif(paradas_subida(4) = '1' and andar_atual > 4 and comecou_subida = '1') then
					andar_destino <= 4;
					tempo_estado <= 0;
					comecou_subida <= '0';
				elsif(paradas_subida(5) = '1' and andar_atual > 5 and comecou_subida = '1') then
					andar_destino <= 5;
					tempo_estado <= 0;
					comecou_subida <= '0';
				elsif(paradas_subida(6) = '1' and andar_atual > 6 and comecou_subida = '1') then
					andar_destino <= 6;
					tempo_estado <= 0;
					comecou_subida <= '0';
				elsif(paradas_subida(0) = '1' and andar_atual < 0) then
					andar_destino <= 0;
					tempo_estado <= 0;
				elsif(paradas_subida(1) = '1' and andar_atual < 1) then
					andar_destino <= 1;
					tempo_estado <= 0;
				elsif(paradas_subida(2) = '1' and andar_atual < 2) then
					andar_destino <= 2;
					tempo_estado <= 0;
				elsif(paradas_subida(3) = '1' and andar_atual < 3) then
					andar_destino <= 3;
					tempo_estado <= 0;
				elsif(paradas_subida(4) = '1' and andar_atual < 4) then
					andar_destino <= 4;
					tempo_estado <= 0;
				elsif(paradas_subida(5) = '1' and andar_atual < 5) then
					andar_destino <= 5;
					tempo_estado <= 0;
				elsif(paradas_subida(6) = '1' and andar_atual < 6) then
					andar_destino <= 6;
					tempo_estado <= 0;
				elsif(paradas_subida(7) = '1' and andar_atual < 7) then
					andar_destino <= 7;
					tempo_estado <= 0;
				else
					mudar_andar <= '1';
					if(tempo_estado >= 2) then
						tempo_estado <= 0;
						estado <= '1';
						comecou_descida <= '1';
					else
						tempo_estado <= tempo_estado + 1;
					end if;
				end if;
				
			elsif(estado = '1' and paradas_descida /= x"00") then -- descida
				
				mudar_andar <= '0';
				
				if(paradas_descida(7) = '1' and andar_atual <= 7 and comecou_descida = '1') then
					andar_destino <= 7;
					tempo_estado <= 0;
					comecou_descida <= '0';
				elsif(paradas_descida(6) = '1' and andar_atual < 6 and comecou_descida = '1') then
					andar_destino <= 6;
					tempo_estado <= 0;
					comecou_descida <= '0';
				elsif(paradas_descida(5) = '1' and andar_atual < 5 and comecou_descida = '1') then
					andar_destino <= 5;
					tempo_estado <= 0;
					comecou_descida <= '0';
				elsif(paradas_descida(4) = '1' and andar_atual < 4 and comecou_descida = '1') then
					andar_destino <= 4;
					tempo_estado <= 0;
					comecou_descida <= '0';
				elsif(paradas_descida(3) = '1' and andar_atual < 3 and comecou_descida = '1') then
					andar_destino <= 3;
					tempo_estado <= 0;
					comecou_descida <= '0';
				elsif(paradas_descida(2) = '1' and andar_atual < 2 and comecou_descida = '1') then
					andar_destino <= 2;
					tempo_estado <= 0;
					comecou_descida <= '0';
				elsif(paradas_descida(1) = '1' and andar_atual < 1 and comecou_descida = '1') then
					andar_destino <= 1;
					tempo_estado <= 0;
					comecou_descida <= '0';
				elsif(paradas_descida(7) = '1' and andar_atual > 7) then
					andar_destino <= 7;
					tempo_estado <= 0;
				elsif(paradas_descida(6) = '1' and andar_atual > 6) then
					andar_destino <= 6;
					tempo_estado <= 0;
				elsif(paradas_descida(5) = '1' and andar_atual > 5) then
					andar_destino <= 5;
					tempo_estado <= 0;
				elsif(paradas_descida(4) = '1' and andar_atual > 4) then
					andar_destino <= 4;
					tempo_estado <= 0;
				elsif(paradas_descida(3) = '1' and andar_atual > 3) then
					andar_destino <= 3;
					tempo_estado <= 0;
				elsif(paradas_descida(2) = '1' and andar_atual > 2) then
					andar_destino <= 2;
					tempo_estado <= 0;
				elsif(paradas_descida(1) = '1' and andar_atual > 1) then
					andar_destino <= 1;
					tempo_estado <= 0;
				elsif(paradas_descida(0) = '1' and andar_atual > 0) then
					andar_destino <= 0;
					tempo_estado <= 0;
				else
					mudar_andar <= '1';
					if(tempo_estado >= 2) then
						tempo_estado <= 0;
						estado <= '0';
						comecou_subida <= '1';
					else
						tempo_estado <= tempo_estado + 1;
					end if;
				end if;
				
			else
					if(estado = '0') then
						estado <= '1';
						comecou_descida <= '1';
					else
						estado <= '0';
						comecou_subida <= '1';
					end if;
--					
			end if;
			
		end if;

	end process;
	
end comportamento;

