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


ENTITY banyan_switch IS
	GENERIC (
		log_step: INTEGER; -- given as log2(number of elements)
		log_size_network: INTEGER
	);
	
	PORT (
		clk: IN STD_LOGIC;
		rst: IN STD_LOGIC;
		inputs: IN data_port_sending_array(0 TO 1);
		inputs_fb: OUT data_port_receiving_array(0 TO 1);
		outputs: OUT data_port_sending_array(0 TO 1);
		outputs_fb: IN data_port_receiving_array(0 TO 1)
	);
	
	CONSTANT size: INTEGER := 2;
END banyan_switch;

ARCHITECTURE banyan_switch OF banyan_switch IS
	SIGNAL straigth, cross: STD_LOGIC;
	
	SIGNAL out_regs: data_port_sending_array(0 TO 1);
	SIGNAL fb_regs: data_port_receiving_array(0 TO 1);
	
	CONSTANT addr_bit: INTEGER := log_size_network - log_step;
	
	CONSTANT ADRZERO: address_fu_buff := (fu => (OTHERS => '0'), buff => '0');
	CONSTANT PORTZERO: data_port_sending := (
		valid => '0',
		message => (
			data => (OTHERS => '0'),
			src => (fu => (OTHERS => '0'), buff => '0'),
			dest => (fu => (OTHERS => '0'), buff => '0')
		)
	);
BEGIN
	-- connect output registers to outputs
	outputs <= out_regs;
	inputs_fb <= fb_regs;
	
	-- first input is always preferred when there's a conflict
	-- basic idea:
	--   if first output is empty or will be empty (is acknowledged) then
	--       if first input needs to go to first output then
	--           do that
	--       elseif second input needs to go to the first output
	--           do that
	--       else
	--           set first output to zero
	--       end
	--   end
	behaviour: PROCESS(clk)
	BEGIN
		IF rising_edge(clk) THEN
			-- is_read signals should be reset every cycle
			fb_regs <= (OTHERS => (OTHERS => '0'));
			
			IF rst = '1' THEN
				out_regs <= (OTHERS => PORTZERO);
			ELSE
				-- If first output register can be written this cycle
				IF (NOT (out_regs(0).valid = '1')) OR (outputs_fb(0).is_read = '1') THEN
					IF ((inputs(0).valid = '1') -- there is input data
					    AND (NOT(fb_regs(0).is_read = '1')) -- it is not already ACKed
					    AND (inputs(0).message.dest.fu(addr_bit) = '0')) THEN
					-- first input needs to go to first output
						out_regs(0) <= inputs(0);
						fb_regs(0) <= (is_read => '1');
					ELSIF ((inputs(1).valid = '1')
					       AND (NOT(fb_regs(1).is_read = '1'))
					       AND (inputs(1).message.dest.fu(addr_bit) = '0')) THEN
					-- if second input needs to go here...
						out_regs(0) <= inputs(1);
						fb_regs(1) <= (is_read => '1');
					ELSE -- else: empty output because it was read
						out_regs(0) <= PORTZERO;
					END IF;
				END IF;
				
				-- If second output register can be written this cycle
				IF (NOT (out_regs(1).valid = '1')) OR (outputs_fb(1).is_read = '1') THEN
					IF ((inputs(0).valid = '1')
					    AND (NOT(fb_regs(0).is_read = '1'))
					    AND (inputs(0).message.dest.fu(addr_bit) = '1')) THEN
					-- first input needs to go to first output
						out_regs(1) <= inputs(0);
						fb_regs(0) <= (is_read => '1');
					ELSIF ((inputs(1).valid = '1')
					       AND (NOT(fb_regs(1).is_read = '1'))
					       AND (inputs(1).message.dest.fu(addr_bit) = '1')) THEN
					-- if second input needs to go here...
						out_regs(1) <= inputs(1);
						fb_regs(1) <= (is_read => '1');
					ELSE -- else: empty output because it was read
						out_regs(1) <= PORTZERO;
					END IF;
				END IF;
			END IF;
		END IF;
	END PROCESS;
END banyan_switch;

