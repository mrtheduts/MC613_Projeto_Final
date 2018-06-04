library ieee;
use ieee.std_logic_1164.all;

entity keyboard_call_test is
  port (
  
	CLOCK_50 : in std_logic;
	PS2_DAT : inout STD_LOGIC;
	PS2_CLK : inout STD_LOGIC;
	KEY : in std_logic_vector(3 downto 0);
	HEX3 : out std_logic_vector(6 downto 0);
	HEX2 : out std_logic_vector(6 downto 0);
	HEX1 : out std_logic_vector(6 downto 0);
	HEX0 : out std_logic_vector(6 downto 0);
	LEDR: out std_logic_vector(8 downto 0)
  
  );
end keyboard_call_test;

architecture behavior of keyboard_call_test is

	component bin2hex is
		port (
			bin_in: in std_logic_vector(3 downto 0);
			bcd_out: out std_logic_vector(6 downto 0)
		);
	end component;

	component kbdex_ctrl is
	   generic (
			clkfreq : integer := 50000
		);
		port(
			ps2_data	:	inout	std_logic;
			ps2_clk		:	inout	std_logic;
			clk				:	in 	std_logic;
			en				:	in 	std_logic;
			resetn		:	in 	std_logic;		
			lights		: in	std_logic_vector(2 downto 0); -- lights(Caps, Nun, Scroll)
			key_on		:	out	std_logic_vector(2 downto 0);
			key_code	:	out	std_logic_vector(47 downto 0)
		);
		
	end component;

	component call_ctrl is
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
	end component;

	component kbd_alphanum is
	  port (
		 clk : in std_logic;
		 key_on : in std_logic;
		 key_code : in std_logic_vector(15 downto 0);
		 numpad_elevator : out std_logic_vector(7 downto 0);
		 call_elevator : out std_logic_vector(7 downto 0)
		);
	end component;
	
	signal andares_req_up_in : std_logic_vector(7 downto 0) := x"00";
	signal andares_req_down_in : std_logic_vector(7 downto 0) := x"00";
	signal andares_dest_in : std_logic_vector(7 downto 0) := x"00";
	signal andares_req_up_out : std_logic_vector(7 downto 0) := x"00";
	signal andares_req_down_out : std_logic_vector(7 downto 0) := x"00";
	signal andares_dest_out : std_logic_vector(7 downto 0) := x"00";
	
	signal key_on : std_logic_vector(2 downto 0);
	signal key_code : std_logic_vector(47 downto 0);
	signal numpad_elevator : std_logic_vector(7 downto 0);
	signal call_elevator : std_logic_vector(7 downto 0);
	
begin

	bin2hex3: bin2hex port map(andares_req_up_in(7 downto 4), HEX3);
	bin2hex2: bin2hex port map(andares_req_up_in(3 downto 0), HEX2);
	bin2hex1: bin2hex port map(andares_req_down_in(7 downto 4), HEX1);
	bin2hex0: bin2hex port map(andares_req_down_in(3 downto 0), HEX0);
	
	LEDR(7 downto 0) <= andares_dest_in;
	LEDR(8) <= key_on(0);
	kbdex_ctrl_inst: kbdex_ctrl port map(PS2_DAT, PS2_CLK, CLOCK_50, KEY(1), KEY(2), "000", key_on, key_code);
	kbd_alphanum_inst: kbd_alphanum port map(CLOCK_50, key_on(0), key_code(15 downto 0), numpad_elevator, call_elevator);
	call_ctrl_inst: call_ctrl port map(CLOCK_50, call_elevator, numpad_elevator, andares_req_up_in, andares_req_down_in, andares_dest_in, andares_req_up_out, andares_req_down_out, andares_dest_out);

	
	process (KEY(0))
	begin
		if(KEY(0) = '0') then
			andares_req_up_in <= x"00";
			andares_req_down_in <= x"00";
			andares_dest_in <= x"00";
		else		
			andares_req_up_in <= andares_req_up_in or andares_req_up_out;
			andares_req_down_in <= andares_req_down_in or andares_req_down_out;
			andares_dest_in <= andares_dest_in or andares_dest_out;
		end if;
	end process;
	
end behavior;