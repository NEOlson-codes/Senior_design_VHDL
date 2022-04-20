LIBRARY IEEE ;
USE IEEE.STD_LOGIC_1164.ALL ;
USE IEEE.STD_LOGIC_ARITH.ALL;
USE IEEE.STD_LOGIC_UNSIGNED.ALL;


ENTITY vgaDAC IS
	PORT(clk_out : IN STD_LOGIC;
		 reset_l : IN STD_LOGIC;
		 resampleVoltageSetting : IN STD_LOGIC_VECTOR(2 DOWNTO 0);
		 dacOut : OUT STD_LOGIC_VECTOR(5 DOWNTO 0)
		 );
END vgaDAC;


ARCHITECTURE behavioral OF vgaDAC IS
    
	
BEGIN


    dac_out: PROCESS(clk_out)BEGIN
        IF(RISING_EDGE(clk_out))THEN
            IF(reset_l='0')THEN
                dacOut<=CONV_STD_LOGIC_VECTOR(0, dacOut'LENGTH);
            ELSE
                CASE CONV_INTEGER(resampleVoltageSetting) IS
                    WHEN 0 => dacOut <= CONV_STD_LOGIC_VECTOR(57, dacOut'LENGTH);               --50mV
                    WHEN 1 => dacOut <= CONV_STD_LOGIC_VECTOR(49, dacOut'LENGTH);               --100mV
                    WHEN 2 => dacOut <= CONV_STD_LOGIC_VECTOR(39, dacOut'LENGTH);               --250mV
                    WHEN 3 => dacOut <= CONV_STD_LOGIC_VECTOR(31, dacOut'LENGTH);               --500mV
                    WHEN 4 => dacOut <= CONV_STD_LOGIC_VECTOR(24, dacOut'LENGTH);               --1000mV
                    WHEN OTHERS => dacOut <= CONV_STD_LOGIC_VECTOR(0, dacOut'LENGTH);           --Have no gain (displays 69) 
                END CASE;
            END IF; 
        END IF;
    END PROCESS;

END behavioral;
