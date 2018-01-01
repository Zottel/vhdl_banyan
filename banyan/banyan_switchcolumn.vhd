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
USE IEEE.NUMERIC_STD.ALL;


LIBRARY work;
USE work.common.ALL;


ENTITY banyan_switchcolumn IS
	GENERIC (
		log_size: INTEGER; -- given as log2(number of elements)
		log_size_network: INTEGER
	);
	
	PORT (
		clk: IN STD_LOGIC;
		rst: IN STD_LOGIC;
		inputs: IN data_port_sending_array(0 TO 2**log_size - 1);
		inputs_fb: OUT data_port_receiving_array(0 TO 2**log_size - 1);
		outputs: OUT data_port_sending_array(0 TO ((2**log_size) - 1));
		outputs_fb: IN data_port_receiving_array(0 TO ((2**log_size) - 1))
	);
	
	CONSTANT size: INTEGER := 2**log_size;
END banyan_switchcolumn;

ARCHITECTURE banyan_switchcolumn OF banyan_switchcolumn IS

BEGIN
	assert log_size > 0
		report "switches of size 1 is impossible";
	
	switches:
	FOR I IN 0 TO (size/2)-1 GENERATE
		-- a switch every second row
		CONSTANT POS: integer := I * 2;
	BEGIN
		switch:
		ENTITY work.banyan_switch
			GENERIC MAP(log_size, log_size_network)
			PORT MAP(clk, rst,
			         inputs(POS TO POS+1), inputs_fb(POS TO POS+1),
			         outputs(POS TO POS+1), outputs_fb(POS TO POS+1));
	END GENERATE switches;
END banyan_switchcolumn;
