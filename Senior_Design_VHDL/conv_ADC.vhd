
LIBRARY ieee;
USE ieee.std_logic_1164.ALL;
USE ieee.numeric_std.ALL;



ENTITY conv_ADC IS
	PORT(clk : IN STD_LOGIC;
		 reset_l : IN STD_LOGIC;
		 adc_in : IN STD_LOGIC_VECTOR(9 DOWNTO 0);
		 --adc_scale : IN STD_LOGIC_VECTOR
		 adc_min : OUT STD_LOGIC_VECTOR(9 DOWNTO 0);
		 adc_max : OUT STD_LOGIC_VECTOR(9 DOWNTO 0);
		 
	
	
	
		);
END conv_ADC;


ARCHITECTURE behavioral OF conv_ADC IS
	SIGNAL adc_sMag : STD_LOGIC_VECTOR(9 DOWNTO 0) := "0000000000";

BEGIN

	signedMag:PROCESS (clk) BEGIN
		IF (RISING_EDGE(clk)) THEN
			IF (reset_l='0') THEN
				adc_sMag<="0000000000";
			ELSE
				--The voltage is positive
				IF (adc_in(9)=1)
					adc_sMag<= "0" & adc_in(8 DOWNTO 0);
				--The voltage is negative
				--Flips the data around to make the magnitude usable
				ELSE	
					adc_sMag<= "1" & (512-adc_in(8 DOWNTO 0));
				END IF;
			END IF;
		END IF;
	END
	
	




END behavioral;


