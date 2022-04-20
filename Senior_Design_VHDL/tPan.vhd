LIBRARY IEEE ;
USE IEEE.STD_LOGIC_1164.ALL;
USE IEEE.STD_LOGIC_ARITH.ALL;
USE IEEE.STD_LOGIC_UNSIGNED.ALL;


ENTITY tPan IS
	PORT(clk_out : IN STD_LOGIC;
		 reset_l : IN STD_LOGIC;  
		 timePanEnc : IN STD_LOGIC_VECTOR(1 DOWNTO 0);
		 tDiv : OUT STD_LOGIC_VECTOR(13 DOWNTO 0)     --Allows representation up to 1000
		 );
END tPan;


ARCHITECTURE behavioral OF tPan IS
    SIGNAL t
    SIGNAL count_out : STD_LOGIC_VECTOR(4 DOWNTO 0) := CONV_STD_LOGIC_VECTOR(0,5);
    SIGNAL countInt, tDivInt : INTEGER := 0;   
        
    
    
    
BEGIN
    
    
    --Convert the encoder to counter to an Integer for CASE statement below     
    countInt<=CONV_INTEGER(UNSIGNED(count_out));
    


END behavioral;

