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


PACKAGE permutations IS
	FUNCTION butterfly(log_size, index: INTEGER) RETURN INTEGER;
END permutations;

PACKAGE BODY permutations IS
	FUNCTION butterfly(log_size, index: INTEGER) RETURN INTEGER IS
	--CONSTANT size: INTEGER := 2**log_size;
	VARIABLE result: INTEGER;
	VARIABLE old_index: STD_LOGIC_VECTOR(log_size-1 downto 0);
	VARIABLE new_index: STD_LOGIC_VECTOR(log_size-1 downto 0);
	BEGIN
		old_index := std_logic_vector(to_unsigned(index, log_size));
		new_index(log_size-1) := old_index(0);
		new_index(log_size-2 downto 1) := old_index((log_size-2) downto 1);
		new_index(0) := old_index(log_size-1);
		result := to_integer(unsigned(new_index));
		return result;
	END butterfly;
END permutations;
