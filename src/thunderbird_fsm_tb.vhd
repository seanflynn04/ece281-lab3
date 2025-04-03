--+----------------------------------------------------------------------------
--| 
--| COPYRIGHT 2017 United States Air Force Academy All rights reserved.
--| 
--| United States Air Force Academy     __  _______ ___    _________ 
--| Dept of Electrical &               / / / / ___//   |  / ____/   |
--| Computer Engineering              / / / /\__ \/ /| | / /_  / /| |
--| 2354 Fairchild Drive Ste 2F6     / /_/ /___/ / ___ |/ __/ / ___ |
--| USAF Academy, CO 80840           \____//____/_/  |_/_/   /_/  |_|
--| 
--| ---------------------------------------------------------------------------
--|
--| FILENAME      : thunderbird_fsm_tb.vhd (TEST BENCH)
--| AUTHOR(S)     : Capt Phillip Warner
--| CREATED       : 03/2017
--| DESCRIPTION   : This file tests the thunderbird_fsm modules.
--|
--|
--+----------------------------------------------------------------------------
--|
--| REQUIRED FILES :
--|
--|    Libraries : ieee
--|    Packages  : std_logic_1164, numeric_std
--|    Files     : thunderbird_fsm_enumerated.vhd, thunderbird_fsm_binary.vhd, 
--|				   or thunderbird_fsm_onehot.vhd
--|
--+----------------------------------------------------------------------------
--|
--| NAMING CONVENSIONS :
--|
--|    xb_<port name>           = off-chip bidirectional port ( _pads file )
--|    xi_<port name>           = off-chip input port         ( _pads file )
--|    xo_<port name>           = off-chip output port        ( _pads file )
--|    b_<port name>            = on-chip bidirectional port
--|    i_<port name>            = on-chip input port
--|    o_<port name>            = on-chip output port
--|    c_<signal name>          = combinatorial signal
--|    f_<signal name>          = synchronous signal
--|    ff_<signal name>         = pipeline stage (ff_, fff_, etc.)
--|    <signal name>_n          = active low signal
--|    w_<signal name>          = top level wiring signal
--|    g_<generic name>         = generic
--|    k_<constant name>        = constant
--|    v_<variable name>        = variable
--|    sm_<state machine type>  = state machine type definition
--|    s_<signal name>          = state name
--|
--+----------------------------------------------------------------------------
library ieee;
  use ieee.std_logic_1164.all;
  use ieee.numeric_std.all;
  
entity thunderbird_fsm_tb is
end thunderbird_fsm_tb;

architecture test_bench of thunderbird_fsm_tb is 
	
	component thunderbird_fsm is 
	  port(
	   i_clk, i_reset  : in    std_logic;
       i_left, i_right : in    std_logic;
       o_lights_L      : out   std_logic_vector(2 downto 0);
       o_lights_R      : out   std_logic_vector(2 downto 0)
	  );
	end component thunderbird_fsm;
    
    signal w_left : std_logic := '0';
    signal w_right : std_logic := '0';
	signal w_reset : std_logic := '0';
	signal w_clk : std_logic := '0';
	
	signal w_left_light : std_logic_vector (2 downto 0) := "000";
	signal w_right_light : std_logic_vector (2 downto 0) := "000";
	
	-- test I/O signals
	
	-- constants
	
	constant k_clk_period : time := 10 ns;
	
begin
	-- PORT MAPS ----------------------------------------
	uut: thunderbird_fsm port map (
          i_clk => w_clk,
          i_reset => w_reset,
          i_left => w_left,
          i_right => w_right,
          o_lights_L => w_left_light,
          o_lights_R => w_right_light       
        );
	-----------------------------------------------------
	
	-- PROCESSES ----------------------------------------	
    -- Clock process ------------------------------------
    clk_proc : process
	begin
		w_clk <= '0';
        wait for k_clk_period/2;
		w_clk <= '1';
		wait for k_clk_period/2;
	end process;
	-----------------------------------------------------
	
	-- Test Plan Process --------------------------------
	sim_proc: process
	begin
		-- sequential timing		
		w_reset <= '1';
		wait for k_clk_period*1;
		assert w_left_light and w_right_light = "000" report "bad reset" severity failure;
		
		 -- check if reset is correct
		w_reset <= '0';
		wait for k_clk_period*1;
		--check if left blinker is correctly flashing
		w_left <= '1'; wait for k_clk_period;
           assert w_left_light = "001" report "should be one light on left blinker on" severity failure;
        wait for k_clk_period;
          assert w_left_light = "011" report "should be two lights on left blinker on" severity failure;
        wait for k_clk_period;
          assert w_left_light = "111" report "should be three lights on left blinker on" severity failure;
        wait for k_clk_period;
          assert w_left_light = "000" report "no lights should be on" severity failure;
          --reset the blinkers
        w_reset <= '1';
		wait for k_clk_period*1;
		w_reset <= '0';
		 --check if right blinker is correctly flashing
		w_right <= '1'; wait for k_clk_period;
           assert w_right_light = "001" report "should be one light on right blinker on" severity failure;
        wait for k_clk_period;
          assert w_right_light = "011" report "should be two lights on right blinker on" severity failure;
        wait for k_clk_period;
          assert w_right_light = "111" report "should be three lights on right blinker on" severity failure;
        wait for k_clk_period;
          assert w_right_light = "000" report "no lights should be on" severity failure;
          --reset the blinkers
        w_reset <= '1';
		wait for k_clk_period*1;
		w_reset <= '0';
		
		 --check if the hazards are working properly
        --w_right <= '1'; w_left <= '1'; wait for k_clk_period;
         --   assert w_right_light and w_left_light = "111" report "lights should be blinking for hazards" severity failure;
        --wait for k_clk_period;
          --   assert w_right_light and w_left_light = "000" report "lights should be blinking for hazards" severity failure; 
             
        wait;
      end process;
          
	-----------------------------------------------------	
	
end test_bench;
