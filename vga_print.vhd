library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_unsigned.all;

entity vga_print is
  port (
	 dest_subida					: in 	std_logic_vector(7 downto 0);
	 dest_descida					: in 	std_logic_vector(7 downto 0);
	 botao_subir					: in 	std_logic_vector(7 downto 0);
	 botao_descer					: in 	std_logic_vector(7 downto 0);
	 andar							: in 	integer range 1 to 8;
    CLOCK_50                  : in  std_logic;
    KEY                       : in  std_logic_vector(0 downto 0);
    VGA_R, VGA_G, VGA_B       : out std_logic_vector(7 downto 0);
    VGA_HS, VGA_VS            : out std_logic;
    VGA_BLANK_N, VGA_SYNC_N   : out std_logic;
    VGA_CLK                   : out std_logic
    );
end vga_print;

architecture comportamento of vga_print is
	
	signal bloco : std_logic_vector(7 downto 0);
	signal cor_normal, cor_chamada, ligado, desligado, preto: std_logic_vector(2 downto 0);

  -- Interface com a memória de vídeo do controlador

	signal addr : integer range 0 to 12287;       -- endereco mem. vga
	signal pixel : std_logic_vector(2 downto 0);  -- valor de cor do pixel
	signal pixel_bit : std_logic;                 -- um bit do vetor acima
   signal sync, blank: std_logic;

  
	signal line : integer range 0 to 95;  -- linha atual
	signal col : integer range 0 to 127;  -- coluna atual

--	signal fim_escrita : std_logic;       -- '1' quando um quadro terminou de ser
                                        -- escrito na memória de vídeo

  
begin  -- comportamento


  vga_controller: entity work.vgacon port map (
    clk50M       => CLOCK_50,
    rstn         => '1',
    red          => VGA_R,
    green        => VGA_G,
    blue         => VGA_B,
    hsync        => VGA_HS,
    vsync        => VGA_VS,
    write_clk    => CLOCK_50,
    write_enable => '1',
    write_addr   => addr,
    data_in      => pixel,
    vga_clk      => VGA_CLK,
    sync         => sync,
    blank        => blank);
  VGA_SYNC_N <= NOT sync;
  VGA_BLANK_N <= NOT blank;


  conta_coluna: process (CLOCK_50)
  begin  -- process conta_coluna
	if CLOCK_50'event and CLOCK_50 = '1' then  -- rising clock edge
      if col = 127 then               -- conta de 0 a 127 (128 colunas)
         col <= 0;
      else
         col <= col + 1;  
      end if;
    end if;
  end process conta_coluna;
    

  conta_linha: process (CLOCK_50)
  begin  -- process conta_linha
    if CLOCK_50'event and CLOCK_50 = '1' then  -- rising clock edge
      -- o contador de linha só incrementa quando o contador de colunas
      -- chegou ao fim (valor 127)
      if col = 127 then
        if line = 95 then               -- conta de 0 a 95 (96 linhas)
          line <= 0;
        else
          line <= line + 1;  
        end if;        
      end if;
    end if;
  end process conta_linha;


	-- definicao das cores de impressao
	ligado <= "010"; -- verde
	desligado <= "100"; -- vermelho
	cor_normal <= "111"; -- branco
	cor_chamada <= "001"; -- azul
	preto <= "000"; -- preto
	bloco <= dest_subida or dest_descida;

	
  
  -- Esse processo define a cor dos pixels a serem impressos
  
  imprimindo_tela: process(CLOCK_50)
  begin -- process imprimindo_tela
  
	if CLOCK_50'event and CLOCK_50 = '1' then
	
		-- Impressao dos blocos que representam os andares do predio
		if(line >= 48 and line <= 55) then
		
			if(col >= 6 and col <= 18) then
				if bloco(0) = '1' then
					pixel <= cor_chamada;
				else
					pixel <= cor_normal;
				end if;
				
			elsif (col >= 21 and col <= 33) then
				if bloco(1) = '1' then
					pixel <= cor_chamada;
				else
					pixel <= cor_normal;
				end if;
				
			elsif (col >= 36 and col <= 48) then
				if bloco(2) = '1' then
					pixel <= cor_chamada;
				else
					pixel <= cor_normal;
				end if;
				
			elsif (col >= 51 and col <= 63) then
				if bloco(3) = '1' then
					pixel <= cor_chamada;
				else
					pixel <= cor_normal;
				end if;
				
			elsif (col >= 66 and col <= 78) then
				if bloco(4) = '1' then
					pixel <= cor_chamada;
				else
					pixel <= cor_normal;
				end if;
				
			elsif (col >= 81 and col <= 93) then
				if bloco(5) = '1' then
					pixel <= cor_chamada;
				else
					pixel <= cor_normal;
				end if;
				
			elsif (col >= 96 and col <= 108) then
				if bloco(6) = '1' then
					pixel <= cor_chamada;
				else
					pixel <= cor_normal;
				end if;
				
			elsif (col >= 111 and col <= 123) then
				if bloco(7) = '1' then
					pixel <= cor_chamada;
				else
					pixel <= cor_normal;
				end if;
				
			else -- restante dos pixels nessas linhas serao pretos
				pixel <= preto;
			end if;
		
		-- impressao dos botoes de subida de cada andar. Eh verde se o botao de subida 
		-- foi apertado e vermelho caso contrario. O oitavo andar nao possui o botao
		-- de subida.
		elsif(line >= 58 and line <= 59) then
		
			if(col >= 12 and col <= 13) then
				if botao_subir(0) = '1' then
					pixel <= ligado;
				else
					pixel <= desligado;
				end if;
				
			elsif (col >= 27 and col <= 28) then
				if botao_subir(1) = '1' then
					pixel <= ligado;
				else
					pixel <= desligado;
				end if;
				
			elsif (col >= 42 and col <= 43) then
				if botao_subir(2) = '1' then
					pixel <= ligado;
				else
					pixel <= desligado;
				end if;
				
			elsif (col >= 57 and col <= 58) then
				if botao_subir(3) = '1' then
					pixel <= ligado;
				else
					pixel <= desligado;
				end if;
				
			elsif (col >= 72 and col <= 73) then
				if botao_subir(4) = '1' then
					pixel <= ligado;
				else
					pixel <= desligado;
				end if;
				
			elsif (col >= 87 and col <= 88) then
				if botao_subir(5) = '1' then
					pixel <= ligado;
				else
					pixel <= desligado;
				end if;
				
			elsif (col >= 102 and col <= 103) then
				if botao_subir(6) = '1' then
					pixel <= ligado;
				else
					pixel <= desligado;
				end if;
				
			else -- restante dos pixels nessas linhas serao pretos
				pixel <= preto;
			end if;
		
		-- Impressao dos botoes de descida de cada andar. Eh verde se o botao de descida 
		-- foi apertado e vermelho caso contrario. O primeiro andar nao possui botao de
		-- descida.
		elsif (line >= 61 and line <= 62) then
		
			if (col >= 27 and col <= 28) then
				if botao_descer(1) = '1' then
					pixel <= ligado;
				else
					pixel <= desligado;
				end if;
				
			elsif (col >= 42 and col <= 43) then
				if botao_descer(2) = '1' then
					pixel <= ligado;
				else
					pixel <= desligado;
				end if;
				
			elsif (col >= 57 and col <= 58) then
				if botao_descer(3) = '1' then
					pixel <= ligado;
				else
					pixel <= desligado;
				end if;
				
			elsif (col >= 72 and col <= 73) then
				if botao_descer(4) = '1' then
					pixel <= ligado;
				else
					pixel <= desligado;
				end if;
				
			elsif (col >= 87 and col <= 88) then
				if botao_descer(5) = '1' then
					pixel <= ligado;
				else
					pixel <= desligado;
				end if;
				
			elsif (col >= 102 and col <= 103) then
				if botao_descer(6) = '1' then
					pixel <= ligado;
				else
					pixel <= desligado;
				end if;
				
			elsif (col >= 117 and col <= 118) then
				if botao_descer(7) = '1' then
					pixel <= ligado;
				else
					pixel <= desligado;
				end if;
				
			else
				pixel <= preto;
			end if;
		elsif(line >= 43 and line <= 46) then
			if(col = 12 and andar = 1) then
				pixel <= ligado;
				
			elsif (col = 27 and andar = 2) then
				pixel <= ligado;
				
			elsif (col = 42 and andar = 3) then
				pixel <= ligado;
				
			elsif (col = 57 and andar = 4) then
				pixel <= ligado;
				
			elsif (col = 72 and andar = 5) then
				pixel <= ligado;
				
			elsif (col = 87 and andar = 6) then
				pixel <= ligado;
				
			elsif (col = 102 and andar = 7) then
				pixel <= ligado;
				
			elsif (col = 117 and andar = 8) then
				pixel <= ligado;
				
			else 
				pixel <= preto;
			end if;
		else -- todos os demais blocos serao pretos
			pixel <= preto;
		end if;
	
	end if;
	
  end process;
  
	
--   fim_escrita <= '1' when ((line = 95) and (col = 127))  else '0'; 
	


  -- O endereço de memória pode ser construído com essa fórmula simples,
  -- a partir da linha e coluna atual
  addr  <= col + (128 * line);

  
end comportamento;

