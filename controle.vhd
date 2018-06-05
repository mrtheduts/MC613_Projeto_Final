library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_unsigned.all;

entity controle is
	port (
		CLOCK_50 : in std_logic;
		KEY : in std_logic_vector(3 downto 0)
    );
end controle;

architecture comportamento of controle is
	
	signal bloco, botao_subir, botao_descer, bloco_parada: std_logic_vector(7 downto 0) := x"00";
	signal andar: integer range 0 to 7;
	signal preciso_parar_s, preciso_parar_d : std_logic := '0';

	type estado_t is (inicio, subindo, descendo, parado);
	signal estado : estado_t := inicio;
	signal proximo_estado : estado_t;
	
	begin
	
	vga_control: entity work.vga_ball port map (
		 bloco							=> bloco,
		 botao_subir					=> botao_subir,
		 botao_descer					=> botao_descer,
		 andar							=> andar,
		 CLOCK_50   					=> CLOCK_50,
		 KEY    							=> KEY,
		 VGA_R							=> ,
		 VGA_G							=> ,
		 VGA_B 							=> ,
		 VGA_HS							=> ,
		 VGA_VS  						=> ,
		 VGA_BLANK_N					=> ,
		 VGA_SYNC_N  					=> ,
		 VGA_CLK      					=> );

	
	-- bloco: guarda todos os andares destino
	bloco <= BLOCO and (not mascara_bloco) when(estado /= inicio) else x"00";
	
	-- parada_subir: guarda todas as chamadas de subida
	parada_subir <= BOTAO_SUBIR and (not mascara_subida) when(estado /= inicio) else x"00";
	
	-- parada_descer: guarda todas as chamadas de descida
	parada_descer <= BOTAO_DESCER and (not mascara_descida) when(estado /= inicio) else x"00";
	
	-- verifica se para no andar (ciclo subida)
	process(CLOCK_50)
	variable controle_local : std_logic_vector(7 downto 0);
	begin
		if (CLOCK_50'event and CLOCK_50 = '1') then
			if(estado = subindo) then
				mascara_bloco <= x"00";
				mascara_subida <= x"00";
				controle_local := bloco or parada_subir;
				if(controle_local(andar) = '1') then
					preciso_parar_s <= '1';
					mascara_bloco(andar) <= '1';
					mascara_subida(andar) <= '1';
				else
					preciso_parar_s <= '0'; 
				end if;
			end if;
		end if;
	end process;
	
	-- verifica se para no andar (ciclo descida)
	process(CLOCK_50)
	variable controle_local : std_logic_vector(7 downto 0);
	begin
		if (CLOCK_50'event and CLOCK_50 = '1') then
			if(estado = descendo) then
				mascara_bloco <= "00000000";
				mascara_subida <= "00000000";
				controle_local := bloco or parada_descer;
				if(controle_local(andar) = '1') then
					preciso_parar_d <= '1';
					mascara_bloco(andar) <= '1';
					mascara_descida(andar) <= '1';
				else
					preciso_parar_d <= '0'; 
				end if;
			end if;
		end if;
	end process;
	
		
	process (CLOCK_50)
		variable flag_subindo : boolean;
	begin
		if CLOCK_50'event and CLOCK_50 = '1' then
			if (estado = subindo) then
				flag_subindo := '0';
				for i in 7 downto andar loop
					if(botao_subir(i) = '1') then
						flag_subindo := '1';
						menor_andar <= i;
					end if;
				end loop;
				
				if(flag_subindo = '1') then
					continua_subindo <= '1';
				else
					continua_subindo <= '0';
				end if;
			end if;
		end if;
	end process;
	
	
	process (CLOCK_50)
		variable flag_descendo : boolean;
	begin
		if CLOCK_50'event and CLOCK_50 = '1' then
			if (estado = descendo) then
				flag_descendo := '0';
				for i in andar to 7 loop
					if(botao_descer(i) = '1') then
						flag_descendo := '1';
						maior_andar <= i;
					end if;
				end loop;
				
				if(flag_descendo = '1') then
					continua_descendo <= '1';
				else
					continua_descendo <= '0';
				end if;
			end if;
		end if;
	end process;
	
	
	fsm: process (estado, fechar_porta)
	begin  -- process logica_mealy
    case estado is
      when inicio        => proximo_estado <= descansando;

      when descansando 	=> if (botao_subir /= x"00") then
                               proximo_estado <= subindo;
									elsif (botao_descer /= x"00") then
									 proximo_estado <= descendo;
									else
									 proximo_estado <= descansando;
									end if;

      when subindo      =>  if(preciso_parar_s = '1') then
										proximo_estado <= parado;
									 elsif(continua_subindo = '1') then
										 proximo_estado <= subindo;
									 elsif(botao_descer /= x"00") then
										 proximo_estado <= descendo;
									 else
										 proximo_estado <= descansando;
									 end if;
									 
									 estado_anterior <= estado;
									  
		when descendo      => if(preciso_parar_d = '1') then
										proximo_estado <= parado;
									 elsif(continua_descendo = '1') then
										 proximo_estado <= descendo;
									 elsif(botao_subir /= x"00") then
										 proximo_estado <= subindo;
									 else
										 proximo_estado <= descansando;
									 end if;
									 
									 estado_anterior <= estado;
		when parado     	 => if(fechar_porta'event and fechar_porta = '1') then
										 proximo_estado <= estado_anterior;
									 end if;
		
		-- descanso
      when others         => proximo_estado <= descansando;
                             
      
    end case;
  end process logica_mealy;
  
    -- purpose: Avança a FSM para o próximo estado
  -- type   : sequential
  -- inputs : CLOCK_50, rstn, proximo_estado
  -- outputs: estado
	seq_fsm: process (CLOCK_50)
	begin  -- process seq_fsm
	 if rstn = '0' then                  -- asynchronous reset (active low)
		estado <= inicio;
	 elsif CLOCK_50'event and CLOCK_50 = '1' then  -- rising clock edge
		estado <= proximo_estado;
	 end if;
	end process seq_fsm;
  
  -- atualiza o andar
	process (CLOCK_DIV)
	begin
		if CLOCK_DIV'event and CLOCK_DIV = '1' then
			if(continua_subindo = '1' or (ajusta_andar_d = '1' and andar < maior_andar)) and andar < 7 then
				andar <= andar + 1;
			elsif(continua_descendo = '1' or (ajusta_andar_s = '1' and andar > menor_andar)) and andar > 0 then
				andar <= andar - 1;
				
			end if;
		end if;
	end process;
	
	--sobe para o andar mais alto que chamou p/ descer
	process(estado)
	begin
		if(estado = descendo and estado_anterior /= descendo ) then
			ajusta_andar_d = '1';
		else
			ajusta_andar_d = '0';
		end if;
	end process;
	
	--desce para o andar mais baixo que chamou p/ descer
	process(estado)
	begin
		if(estado = subindo and estado_anterior /= subindo) then
			ajusta_andar_s = '1';
		else
			ajusta_andar_s = '0';
		end if;
	end process;
	
	-- define tempo de porta aberta (parado)
	process (CLOCK_DIV)
		variable numero : integer := 5;
	begin
		if(estado = parado) then
			if CLOCK_DIV'event and CLOCK_DIV = '1' then
				if(contador < numero) then
					fechar_porta <= '0';
					contador <= contador + 1;
				else
					fechar_porta <= '1';
					contador <= 0;
				end if;
			end if;
		end if;
	end process;
	
	-- define tempo entre andares
	process (CLOCK_DIV)
		variable numero : integer := 3;
	begin
		if(estado = parado) then
			if CLOCK_DIV'event and CLOCK_DIV = '1' then
				if(contador < numero) then
					proximo_andar <= '0';
					contador <= contador + 1;
				else
					fechar_porta <= '1';
					contador <= 0;
				end if;
			end if;
		end if;
	end process;
	
	end comportamento;
	