
LIBRARY ieee;
USE ieee.std_logic_1164.ALL;
USE ieee.numeric_std.ALL;


ENTITY binToBCD IS
	PORT(clk : IN STD_LOGIC;
		 reset_l : IN STD_LOGIC;
		 adc_in : IN STD_LOGIC_VECTOR(9 DOWNTO 0);
		 num_in : IN STD_LOGIC_VECTOR(9 DOWNTO 0);
		 ones : OUT STD_LOGIC_VECTOR(3 DOWNTO 0);
		 tens : OUT STD_LOGIC_VECTOR(3 DOWNTO 0);
		 hundreds : OUT STD_LOGIC_VECTOR(3 DOWNTO 0);
		 thousands : OUT STD_LOGIC_VECTOR(3 DOWNTO 0)
		 );
END binToBCD;


ARCHITECTURE behavioral OF conv_ADC IS
	SIGNAL shift : STD_LOGIC_VECTOR(25 DOWNTO 0) := CONV_STD_LOGIC_VECTOR(0, 25);
	--SIGNAL num_in : STD_LOGIC_VECTOR(9 DOWNTO 0) := "0000000000";
	
	--Create aliases for the parts of the numbers
	ALIAS num IS shift(9 DOWNTO 0);
	ALIAS one IS shift(13 DOWNTO 10);
	ALIAS ten IS shift(17 DOWNTO 14);
	ALIAS hun IS shift(21 DOWNTO 18);
	ALIAS thous IS shift(25 DOWNTO 22);
	
	
BEGIN

	--num_in<=adc_minV;

	bin2BCD:PROCESS (num_in) BEGIN
		FOR i IN 1 TO num'LENGTH loop
			IF (one>=5) THEN
				one:=one+3;
			END IF;
			
			IF (ten>=5) THEN
				ten:=ten+3;
			END IF;
			
			IF (hun>=5) THEN
				hun:=hun+3;
			END IF;
			
			IF (thous>=5) THEN
				thous:=thous+3;
			END IF;
			
			shift := shift_left(shift,1);
		END LOOP;
		
		ones<=STD_LOGIC_VECTOR(one);
		tens<=STD_LOGIC_VECTOR(ten);
		hundreds<= STD_LOGIC_VECTOR(hun);
		thousands<=STD_LOGIC_VECTOR(thous);
		
		
		
		
	END
	
	




END behavioral;


