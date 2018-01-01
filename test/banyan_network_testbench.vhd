--   Copyright 2018 Julius Roob <julius@juliusroob.de>
--
--   Licensed under the Apache License, Version 2.0 (the "License");
--   you may not use this file except in compliance with the License.
--   You may obtain a copy of the License at
--
--       http://www.apache.org/licenses/LICENSE-2.0
--
--   Unless required by applicable law or agreed to in writing, software
--   distributed under the License is distributed on an "AS IS" BASIS,
--   WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
--   See the License for the specific language governing permissions and
--   limitations under the License.


LIBRARY IEEE;
USE IEEE.STD_LOGIC_1164.ALL;
USE IEEE.STD_LOGIC_UNSIGNED.ALL;
USE IEEE.NUMERIC_STD.ALL;


LIBRARY work;
USE work.common.ALL;


ENTITY banyan_network_testbench IS
END banyan_network_testbench;

ARCHITECTURE banyan_network_testbench OF banyan_network_testbench IS
	CONSTANT LOG_SIZE: INTEGER := 5;
	CONSTANT SIZE: INTEGER := 2**LOG_SIZE;
	CONSTANT ZERO: data_port_sending := (
		message => (
			src => (fu => (OTHERS => '0'), buff => '0'),
			dest => (fu => (OTHERS => '0'), buff => '0'),
			data => (OTHERS => '0')),
		valid => '0');
	
	TYPE INT_ARRAY IS ARRAY (INTEGER RANGE <>) OF INTEGER;
	CONSTANT DESTINATIONS: INT_ARRAY(0 TO SIZE-1) := (24, 9, 16, 4, 1, 11, 0, 7, 23, 17, 10, 8, 14, 22, 29, 21, 5, 19, 6, 13, 2, 28, 25, 12, 31, 27, 20, 30, 18, 3, 15, 26);
	
	SIGNAL inputs: data_port_sending_array(0 TO (SIZE - 1)) :=
		(OTHERS => ZERO);
	SIGNAL inputs_fb: data_port_receiving_array(0 TO (SIZE - 1)) :=
		(OTHERS => (OTHERS => '0'));
	SIGNAL outputs: data_port_sending_array(0 TO (SIZE - 1)) :=
		(OTHERS => ZERO);
	-- feedback defaults to 1 so each arriving message is cleared after one cycle
	SIGNAL outputs_fb: data_port_receiving_array(0 TO (SIZE - 1)) :=
		(OTHERS => (OTHERS => '1'));
	
	SIGNAL clk: STD_LOGIC;
	SIGNAL rst: STD_LOGIC;
	
	constant clk_period : time := 10 ns;
BEGIN
	uut: ENTITY work.banyan_network
		GENERIC MAP(LOG_SIZE, LOG_SIZE)
		PORT MAP(clk, rst, inputs, inputs_fb, outputs, outputs_fb);
		
		-- send random messages - 32 at once
		testsender: FOR I IN 0 TO SIZE - 1 GENERATE
			send00: ENTITY work.data_testsender GENERIC MAP(I, DESTINATIONS(I), I) PORT MAP(clk, rst, inputs(I), inputs_fb(I));
		END GENERATE testsender;
	
	reset: PROCESS BEGIN
		rst <= '1';
		wait for clk_period; -- wait for stuff to settle?
		rst <= '0';
		wait;
	END PROCESS;
	
	clk_proc: PROCESS BEGIN
		clk <= '0';
		wait for clk_period/2;
		clk <= '1';
		wait for clk_period/2;
	END PROCESS;
END banyan_network_testbench;
