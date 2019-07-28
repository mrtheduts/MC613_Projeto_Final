library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_unsigned.all;

entity controlador_geral is
	port (
		CLOCK_50 : in std_logic;
		KEY : in std_logic_vector(3 downto 0);
		PS2_DAT : inout STD_LOGIC;
		PS2_CLK : inout STD_LOGIC;
		VGA_R, VGA_G, VGA_B       : out std_logic_vector(7 downto 0);
		VGA_HS, VGA_VS            : out std_logic;
		VGA_BLANK_N, VGA_SYNC_N   : out std_logic;
		VGA_CLK                   : out std_logic;
		LEDR : out std_logic_vector(9 downto 0);
		HEX4 : out std_logic_vector(6 downto 0);
		HEX5 : out std_logic_vector(6 downto 0)
    );
end controlador_geral;

architecture comportamento of controlador_geral is 


	signal destino_subida_in, destino_subida_out : std_logic_vector(7 downto 0) := x"00";
	signal destino_descida_in, destino_descida_out : std_logic_vector(7 downto 0) := x"00";
	signal botao_subir_in, botao_subir_out : std_logic_vector(7 downto 0) := x"00";
	signal botao_descer_in, botao_descer_out : std_logic_vector(7 downto 0) := x"00";
	signal paradas_subida_in, paradas_subida_out : std_logic_vector(7 downto 0);
	signal paradas_descida_in, paradas_descida_out : std_logic_vector(7 downto 0);
	signal mascara_subir, mascara_descer: std_logic_vector(7 downto 0);
	signal andar_atual, andar_destino : integer range 0 to 7; 
	signal key_on : std_logic_vector(2 downto 0);
	signal key_code : std_logic_vector (47 downto 0);
	signal CLOCK_DIV: std_logic;
	signal estado, inicio : std_logic; -- '0' subindo e '1' descendo


begin
	
	-- inicializa os vetores com zero
	process(CLOCK_50)
	begin
		if(inicio = '1') then
		
			paradas_subida_in <= (others => '0');
			paradas_descida_in <= (others => '0');
			
			botao_subir_in <= (others => '0');
			botao_descer_in <= (others => '0');
			
			destino_subida_in <= (others => '0');
			destino_descida_in <= (others => '0');
			
		elsif CLOCK_50'event and CLOCK_50 = '1' then
		
			paradas_subida_in <= (botao_subir_out OR destino_subida_out);
			paradas_descida_in <= (botao_descer_out OR destino_descida_out);
			
			botao_subir_in <= botao_subir_out AND (NOT mascara_subir);
			botao_descer_in <= botao_descer_out AND (NOT mascara_descer);
			
			destino_subida_in <= destino_subida_out AND (NOT mascara_subir);
			destino_descida_in <= destino_descida_out AND (NOT mascara_descer);
			
		end if;
	end process;
	
	inicio <= '0';

	vga_control: entity work.vga_print
	port map (
		 dest_subida					=> destino_subida_out,
		 dest_descida					=> destino_descida_out,
		 botao_subir					=> botao_subir_out,
		 botao_descer					=> botao_descer_out,
		 andar							=> andar_atual+1,
		 CLOCK_50   					=> CLOCK_50,
		 KEY    							=> KEY(0 downto 0),
		 VGA_R							=> VGA_R,
		 VGA_G							=> VGA_G,
		 VGA_B 							=> VGA_B,
		 VGA_HS							=> VGA_HS,
		 VGA_VS  						=> VGA_VS,
		 VGA_BLANK_N					=> VGA_BLANK_N,
		 VGA_SYNC_N  					=> VGA_SYNC_N,
		 VGA_CLK      					=> VGA_CLK
	);
		 
	div: entity work.clk_div
	port map (
		clk							=> CLOCK_50,
		reset							=> '0',
		clock_out					=> CLOCK_DIV
	);
	
	keybd_call: entity work.keyboard_call_toplevel
	port map(
		clk 								=> CLOCK_50,
		PS2_DAT 							=> PS2_DAT,
		PS2_CLK							=> PS2_CLK,
		KEY								=> KEY,
		andar            				=> andar_atual,
		andares_req_up_in				=> botao_subir_in,
		andares_req_down_in			=> botao_descer_in,
		andares_dest_up_in    		=> destino_subida_in,
	   andares_dest_down_in  		=> destino_descida_in,
	   andares_req_up_out   		=> botao_subir_out,
	   andares_req_down_out   		=> botao_descer_out,
	   andares_dest_up_out   		=> destino_subida_out,
	   andares_dest_down_out 		=> destino_descida_out
  );

	dec_andar: entity work.decide_andar
	port map(
		estado 							=> estado,
		andar_atual 					=> andar_atual,
		paradas_subida 				=> paradas_subida_in,
		paradas_descida				=> paradas_descida_in,
--		paradas_subida_out 			=> paradas_subida_out,
--		paradas_descida_out			=> paradas_descida_out,
		mascara_subir					=> mascara_subir,
		mascara_descer 				=> mascara_descer,
		clock_div 						=> CLOCK_DIV,
		clock_50							=> CLOCK_50,
		andar_destino					=> andar_destino,
		LEDR => LEDR(9),
		HEX4 => HEX4,
		HEX5 => HEX5
    );
	
	mud_andar: entity work.muda_andar
	port map(
		andar_atual 					=> andar_atual,
		andar_destino 					=> andar_destino,
		clock 							=> CLOCK_DIV
    );

end comportamento;

