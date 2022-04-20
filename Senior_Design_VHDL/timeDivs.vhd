LIBRARY IEEE ;
USE IEEE.STD_LOGIC_1164.ALL;
USE IEEE.STD_LOGIC_ARITH.ALL;
USE IEEE.STD_LOGIC_UNSIGNED.ALL;


ENTITY timeDivs IS
	PORT(clk_out : IN STD_LOGIC;
		 reset_l : IN STD_LOGIC;  
		 timeDivEnc : IN STD_LOGIC_VECTOR(1 DOWNTO 0);
		 tDivSamplingValue : OUT STD_LOGIC_VECTOR(9 DOWNTO 0);         --Allows representation up to 1024 
		 tDivSamplingUnit : OUT STD_LOGIC_VECTOR(1 DOWNTO 0);         --Provides the Unit of the time division
		 tDivSamplingSetting : OUT STD_LOGIC_VECTOR(4 DOWNTO 0)
		 );
END timeDivs;


ARCHITECTURE behavioral OF timeDivs IS
        
    CONSTANT countMax : STD_LOGIC_VECTOR(4 DOWNTO 0) := CONV_STD_LOGIC_VECTOR(20,5);
    CONSTANT one : STD_LOGIC_VECTOR(9 DOWNTO 0):= CONV_STD_LOGIC_VECTOR(1, 10);
    
    SIGNAL count_out : STD_LOGIC_VECTOR(4 DOWNTO 0) := CONV_STD_LOGIC_VECTOR(0,5);
    SIGNAL countInt, tDivInt : INTEGER := 0;   
        
        
    COMPONENT encoders
    PORT(clk_out: IN STD_LOGIC;
         reset_l: IN STD_LOGIC;
         buttonState: IN STD_LOGIC;
         enc_in : IN STD_LOGIC_VECTOR(1 DOWNTO 0);
         countMax: IN STD_LOGIC_VECTOR(4 DOWNTO 0);
         count_out: OUT STD_LOGIC_VECTOR(4 DOWNTO 0)
        );
    END COMPONENT;	
    
    
BEGIN

    timeDivSamplingEncoder: encoders
    PORT MAP(clk_out=>clk_out,
             reset_l=>reset_l,
             buttonState=>'0',
             enc_in=>timeDivEnc,
             countMax=>countMax,
             count_out=> count_out);
    
    --Convert the encoder to counter to an Integer for CASE statement below     
    countInt<=CONV_INTEGER(UNSIGNED(count_out));
    
    --Map count_out to the output "tDivSampleSetting"
    tDivSamplingSetting<=count_out;
    
    --Sampling at 100MHz => 10ns/sample
    --50 Samples/Div => 500ns/Div
    timeDivisions: PROCESS(clk_out) BEGIN
        IF(RISING_EDGE(clk_out)) THEN
            IF(reset_l ='0') THEN
                tDivSamplingUnit<="00";
                tDivSamplingValue<= CONV_STD_LOGIC_VECTOR(500, tDivSamplingValue'LENGTH);
            --If we are in normal display mode
            ELSE
                CASE countInt IS
                     WHEN 0        => tDivSamplingUnit <= "00"; tDivSamplingValue <= CONV_STD_LOGIC_VECTOR(500, tDivSamplingValue'LENGTH);                            --ns division
--                     WHEN 1 TO 10  => tDivSamplingUnit <= "01"; tDivSamplingValue <= CONV_STD_LOGIC_VECTOR(INTEGER(one SLL (countInt-1)), tDivSamplingValue'LENGTH);   --us division
--                     WHEN 11 TO 20 => tDivSamplingUnit <= "10"; tDivSamplingValue <= CONV_STD_LOGIC_VECTOR(INTEGER(one SLL (countInt-11)), tDivSamplingValue'LENGTH);  --ms divisons
                     WHEN 1 TO 10  => tDivSamplingUnit <= "01"; tDivSamplingValue <= STD_LOGIC_VECTOR(SHL(one, UNSIGNED(count_out)-1));   --us division
                     WHEN 11 TO 20 => tDivSamplingUnit <= "10"; tDivSamplingValue <= STD_LOGIC_VECTOR(SHL(one, UNSIGNED(count_out)-11));  --ms divisons
                     WHEN OTHERS => tDivSamplingUnit <= "00"; tDivSamplingValue <= CONV_STD_LOGIC_VECTOR(500, tDivSamplingValue'LENGTH);                              --Defaults to ns time step
                END CASE;
            END IF;
        END IF; 
    END PROCESS; 
    
    
--    --Sets the decimation factor for all incoming samples
--    inc_decimation: PROCESS(clk_out) THEN
--        IF (RISING_EDGE(clk_out)) THEN
--            --Reset the decimation rate to 0 (100MHz Sample rate)
--            IF (reset_l ='0') THEN
--                incomingDecRate<=CONV_STD_LOGIC_VECTOR(0,incomingDecRate'LENGTH);
--            ELSIF(changeResampleSettingsState='1') THEN
--                --If we want to downsample such that we have a 1Hz wave on the screen
--                --We need an effective sampling rate of 100Hz to make it look decent 
--                CASE countInt IS
--                    --With 16KSamples and 512 pixels on screen, we can get 6 different screens out of our samples
--                    WHEN 0 TO 3 => incomingDecRate<=0;      --We dont need to immediately start decimating the incoming data
--                    WHEN 4 TO 21=> incomingDecRate<= CONV_STD_LOGIC_VECTOR(UNSIGNED(1) shl (countInt), incomingDecRate'LENGTH);
--                    WHEN OTHERS => incomingDecRate<=0;
--                END CASE;
            
--            END IF;
--        END IF;
--    END PROCESS;
    


END behavioral;
