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


library IEEE;
use IEEE.STD_LOGIC_1164.all;
use IEEE.numeric_std.all;
use IEEE.STD_LOGIC_unsigned.all;


PACKAGE common IS
-- BASICS ------------------------------------------------------------------- --
	CONSTANT DATA_WIDTH: NATURAL := 32;
	SUBTYPE data_word IS STD_LOGIC_VECTOR(DATA_WIDTH-1 DOWNTO 0);
	
	-- instruction memory (i.e. pc) address width
	-- out of comission - pc IS just another data word
	--CONSTANT PC_WIDTH := FU_DATA_W;
	
	CONSTANT ADDRESS_FU_WIDTH: NATURAL := 5;
	CONSTANT ADDRESS_BUFF_WIDTH: NATURAL := 1;
	SUBTYPE address_fu IS STD_LOGIC_VECTOR((ADDRESS_FU_WIDTH - 1) downto 0);
	SUBTYPE buff_num IS STD_LOGIC_VECTOR((ADDRESS_BUFF_WIDTH - 1) downto 0);
	
	TYPE address_fu_buff IS RECORD
		fu: address_fu;
		buff: buff_num;
	END RECORD;
	CONSTANT ZERO_ADDRESS: address_fu_buff := (fu => (OTHERS => '0'),
	                                           buff => (OTHERS => '0'));
	
-- MOVE INSTRUCTION BUS ----------------------------------------------------- --
	-- 2-phase commit for instructions required for broadcasting to work
	TYPE mib_phase IS (CHECK, COMMIT);
	
	-- input of FU, output of CTRL
	TYPE mib_ctrl_out IS RECORD
		phase: mib_phase;
		valid: STD_LOGIC;
		src: address_fu_buff;
		dest: address_fu_buff;
	END RECORD;
	
	-- output of FU, input of CTRL
	TYPE mib_stalls IS RECORD
		src_stalled: STD_LOGIC;
		dest_stalled: STD_LOGIC;
	END RECORD;
	TYPE mib_stalls_array IS ARRAY(NATURAL RANGE <>) OF mib_stalls;
	
	
-- DATA NETWORK ------------------------------------------------------------- --
	TYPE data_message IS RECORD
		src: address_fu_buff;
		dest: address_fu_buff;
		data: data_word;
	END RECORD;
	
	TYPE data_port_sending IS RECORD
		message: data_message;
		valid: STD_LOGIC;
	END RECORD;
	
	TYPE data_port_sending_array
		IS ARRAY(NATURAL RANGE <>) OF data_port_sending;
	
	TYPE data_port_receiving IS RECORD
		is_read: STD_LOGIC;
	END RECORD;
	
	TYPE data_port_receiving_array
		IS ARRAY(NATURAL RANGE <>) OF data_port_receiving;
	
	CONSTANT ZERO_PORT: data_port := (
		valid => '0',
		message => (
			data => (OTHERS => '0'),
			src => (fu => (OTHERS => '0'), buff => (OTHERS => '0')),
			dest => (fu => (OTHERS => '0'), buff => (OTHERS => '0'))
		)
	);
	
END common;
