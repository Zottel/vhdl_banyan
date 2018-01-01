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


ENTITY banyan_network IS
	GENERIC (
		log_size: INTEGER := ADDRESS_FU_WIDTH; -- given as log2(number of elements)
		log_size_network: INTEGER := ADDRESS_FU_WIDTH
	);
	
	PORT (
		clk: IN STD_LOGIC;
		rst: IN STD_LOGIC;
		--input_messages: IN data_message(((2**log_size) - 1) DOWNTO 0);
		inputs: IN data_port_sending_array(0 TO 2**log_size - 1);
		inputs_fb: OUT data_port_receiving_array(0 TO 2**log_size - 1);
		
		outputs: OUT data_port_sending_array(0 TO ((2**log_size) - 1));
		outputs_fb: IN data_port_receiving_array(0 TO ((2**log_size) - 1))
	);
	
	CONSTANT size: INTEGER := 2**log_size;
END banyan_network;

-- ------------------------------------------------------------------------- --
--                                                                           --
--        banyan_network(s, s_n)       +     inputs                          --
--                                     |                                     --
--       +-----------------------------------------------------------+       --
--       |                             |                             |       --
--       |                        +----+----+                        |       --
--       |                        |         |                        |       --
--       | +----------------------v---+ +---v----------------------+ |       --
--       | |                          | |                          | |       --
--       | | banyan_network(s-1, s_n) | | banyan_network(s-1, s_n) | |       --
--       | |                          | |                          | |       --
--       | +----------------------+---+ +---+----------------------+ |       --
--       |                        |         |                        |       --
--       |                        +----+----+ pre_permutation        |       --
--       |                             |                             |       --
--       | +---------------------------v---------------------------+ |       --
--       | |                                                       | |       --
--       | | banyan_permutation_butterfly(s)                       | |       --
--       | |                                                       | |       --
--       | +---------------------------+---------------------------+ |       --
--       |                             |                             |       --
--       |                             |      post_permutation       |       --
--       |                             |                             |       --
--       | +---------------------------v---------------------------+ |       --
--       | |                                                       | |       --
--       | | switch_column(s, s_n)                                 | |       --
--       | |                                                       | |       --
--       | +---------------------------+---------------------------+ |       --
--       |                             |                             |       --
--       +-----------------------------------------------------------+       --
--                                     |                                     --
--                                     +      outputs                        --
--                                                                           --
-- ------------------------------------------------------------------------- --

ARCHITECTURE banyan_network of banyan_network IS
	SIGNAL pre_permutation:     data_port_sending_array(0 TO size - 1);
	SIGNAL pre_permutation_fb:  data_port_receiving_array(0 TO size - 1);
	SIGNAL post_permutation:    data_port_sending_array(0 TO size - 1);
	SIGNAL post_permutation_fb: data_port_receiving_array(0 TO size - 1);

BEGIN
	assert log_size > 0
		report "making a banyan network for 1 element or less is not supported";
	
	simple_case:
	IF log_size = 1 GENERATE
	BEGIN
		simple_switches: ENTITY work.banyan_switchcolumn
			GENERIC MAP(log_size, log_size_network)
			PORT MAP(clk, rst, inputs, inputs_fb, outputs, outputs_fb);
	END GENERATE simple_case;
	
	recursive_case:
	if log_size > 1 GENERATE
		subnetwork1:
		ENTITY work.banyan_network
			GENERIC MAP (log_size - 1, log_size_network)
			PORT MAP(clk, rst,
			         inputs(0 TO ((size / 2) - 1)),
			         inputs_fb(0 TO ((size / 2) - 1)),
			         pre_permutation(0 TO ((size / 2) - 1)),
			         pre_permutation_fb(0 TO ((size / 2) - 1)));
		
		subnetwork2:
		ENTITY work.banyan_network
			GENERIC MAP (log_size - 1, log_size_network)
			PORT MAP(clk, rst,
			         inputs((size / 2) TO (size - 1)),
			         inputs_fb((size / 2) TO (size - 1)),
			         pre_permutation((size / 2) TO (size - 1)),
			         pre_permutation_fb((size / 2) TO (size - 1)));
		
		permutation:
		ENTITY work.banyan_permutation_butterfly
			GENERIC MAP(log_size)
			PORT MAP(pre_permutation, pre_permutation_fb,
			         post_permutation, post_permutation_fb);
		
		switches:
		ENTITY work.banyan_switchcolumn
			GENERIC MAP(log_size, log_size_network)
			PORT MAP(clk, rst,
			         post_permutation, post_permutation_fb,
			         outputs, outputs_fb);
		
		-- output_messages
	END GENERATE recursive_case;
END banyan_network;


