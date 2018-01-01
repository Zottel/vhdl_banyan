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
USE work.permutations.ALL;


ENTITY banyan_permutation_butterfly IS
	GENERIC (
		log_size: INTEGER := 3 -- given as log2(number of elements)
	);
	
	PORT (
		inputs: IN data_port_sending_array(0 TO 2**log_size - 1);
		inputs_fb: OUT data_port_receiving_array(0 TO 2**log_size - 1);
		
		outputs: OUT data_port_sending_array(0 TO ((2**log_size) - 1));
		outputs_fb: IN data_port_receiving_array(0 TO ((2**log_size) - 1))
	);
	
	CONSTANT size: INTEGER := 2**log_size;
END banyan_permutation_butterfly;

ARCHITECTURE banyan_permutation_butterfly OF banyan_permutation_butterfly IS
BEGIN
	gen_mapping:
	FOR index IN 0 TO size-1 GENERATE
		CONSTANT dest_index: INTEGER := butterfly(log_size, index);
	BEGIN
		outputs(dest_index) <= inputs(index);
		inputs_fb(index) <= outputs_fb(dest_index);
	END GENERATE gen_mapping;
END banyan_permutation_butterfly;

