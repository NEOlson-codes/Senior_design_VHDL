LIBRARY IEEE ;
USE IEEE.STD_LOGIC_1164.ALL ;
USE IEEE.STD_LOGIC_ARITH.ALL;
USE IEEE.STD_LOGIC_UNSIGNED.ALL;


ENTITY encoders IS
	PORT(clk_out : IN STD_LOGIC;
		 reset_l : IN STD_LOGIC;
		 buttonState : IN STD_LOGIC;
		 enc_in : IN STD_LOGIC_VECTOR(1 DOWNTO 0); 
		 countMax : IN STD_LOGIC_VECTOR(4 DOWNTO 0);
		 count_out : OUT STD_LOGIC_VECTOR(4 DOWNTO 0)
		 );
END encoders;


ARCHITECTURE behavioral OF encoders IS
    SIGNAL enc_count0, enc_count1 : STD_LOGIC_VECTOR(4 DOWNTO 0) := "00000";     --32 different values
    SIGNAL enc_temp, enc : STD_LOGIC_VECTOR(1 DOWNTO 0) := "00";
    SIGNAL enc_en : STD_LOGIC := '0';
    SIGNAL enc_dir : STD_LOGIC := '0'; 
    SIGNAL enc_vec : STD_LOGIC_VECTOR(2 DOWNTO 0) := "000";         
	
BEGIN
        --Encoder Counters
    enc_en<=enc(1) XOR enc(0) XOR enc_temp(1) XOR enc_temp(0);
    enc_dir<=enc(1) XOR enc_temp(0);
    enc_vec<=buttonState & enc_en & enc_dir;
    
    WITH buttonState SELECT
        count_out<=enc_count0 WHEN '0',
                   enc_count1 WHEN OTHERS; 
    
    
    --Add counter limiters
    encoder_counters: PROCESS(clk_out) BEGIN
        IF (RISING_EDGE(clk_out)) THEN
            IF(reset_l='0') THEN
                enc_count0<="00000";
                enc_temp<="00";
                enc<="00";
            ELSE
                --Sync the encoder input
                enc_temp<=enc_in;  
                enc<=enc_temp;
                
                --Update the correct counter
                CASE enc_vec IS
                    WHEN "011" => 
                        IF (enc_count0 = countMax) THEN
                            enc_count0<=enc_count0;
                        ELSE
                            enc_count0<=enc_count0+1;
                        END IF;
                    WHEN "010" =>
                        IF (enc_count0 = 0) THEN
                            enc_count0<=enc_count0;
                        ELSE
                            enc_count0<=enc_count0-1; 
                        END IF;
                    WHEN "111" => 
                        IF (enc_count1 = countMax) THEN
                            enc_count1<=enc_count1;
                        ELSE
                            enc_count1<=enc_count1+1;
                        END IF;
                    WHEN "110" =>
                        IF (enc_count1 = 0) THEN
                            enc_count1<=enc_count1;
                        ELSE
                            enc_count1<=enc_count1-1; 
                        END IF;
                    WHEN OTHERS =>
                        enc_count0<=enc_count0;
                        enc_count1<=enc_count1;
                END CASE;
            END IF;    
        END IF;
    END PROCESS;
    

END behavioral;
