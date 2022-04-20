LIBRARY IEEE;
USE IEEE.STD_LOGIC_1164.ALL ;
USE IEEE.STD_LOGIC_ARITH.ALL;
USE IEEE.STD_LOGIC_UNSIGNED.ALL;


ENTITY triggering IS
	PORT(clk_out : IN STD_LOGIC;
		 reset_l : IN STD_LOGIC;
		 voltage_in : IN STD_LOGIC_VECTOR(13 DOWNTO 0); --13 Bits allows up to 8000mv (need 5000mV) and 1 sign bit
		 edge_detected : OUT STD_LOGIC
		 );
END triggering;


ARCHITECTURE behavioral OF triggering IS
    --Sets the threshold voltage
    CONSTANT threshold : UNSIGNED(12 DOWNTO 0) := CONV_UNSIGNED(50,13);
    SIGNAL voltage_in_prev : STD_LOGIC_VECTOR(13 DOWNTO 0) := CONV_STD_LOGIC_VECTOR(0,14); --13 Bits allows up to 5000mv and 1 sign bit
	
BEGIN
    trigger: PROCESS(clk_out) BEGIN
        IF (RISING_EDGE(clk_out)) THEN
            IF (reset_l ='0') THEN
                edge_detected<='0';
                voltage_in_prev<=CONV_STD_LOGIC_VECTOR(0,14);
            ELSE
                --Store the last voltage for 1 clock cycle
                voltage_in_prev<=voltage_in;
            
                --Look at just the unsigned magnitude of the voltage
                --Allows for both rising and falling edge triggering
                IF ((UNSIGNED(voltage_in_prev(12 DOWNTO 0)) <= threshold) AND (UNSIGNED(voltage_in(12 DOWNTO 0)) >= threshold)) THEN
                    edge_detected<='1';
                ELSE
                    edge_detected<='0';
                END IF;
                
            END IF;
        END IF;
    END PROCESS;



END behavioral;
