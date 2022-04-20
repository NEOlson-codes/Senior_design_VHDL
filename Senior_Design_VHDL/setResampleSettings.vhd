LIBRARY IEEE;
USE IEEE.STD_LOGIC_1164.ALL ;
USE IEEE.STD_LOGIC_ARITH.ALL;
USE IEEE.STD_LOGIC_UNSIGNED.ALL;



--Might be unnecessary
ENTITY setResampleSettings IS
	PORT(clk_out : IN STD_LOGIC;
		 reset_l : IN STD_LOGIC;
		 timeDivsInc : IN STD_LOGIC;          --Button to increase the sample time division (decrease FS)
		 timeDivsDec : IN STD_LOGIC;          --Button to decrease the sample time division (increase FS)
		 vDivsInc : IN STD_LOGIC;             --Button to increase the target voltage
		 vDivsDec : IN STD_LOGIC;             --Button to decrease the target voltage
		 incomingDecimationRate : OUT STD_LOGIC_VECTOR(20 DOWNTO 0);       --Set the incoming number of samples to be skipped
		 resampleVoltageSetting : OUT STD_LOGIC_VECTOR(2 DOWNTO 0);               
		 resampleVoltageValue : OUT STD_LOGIC_VECTOR(9 DOWNTO 0); --Allows for value up to 8000mV+
		 resampleTDivValue : OUT STD_LOGIC_VECTOR(9 DOWNTO 0);
         resampleTDivUnit : OUT STD_LOGIC_VECTOR(1 DOWNTO 0)
		 );
END setResampleSettings;


ARCHITECTURE behavioral OF setResampleSettings IS
    CONSTANT numOfTimeDivisions : INTEGER := incomingDecimationRate'LENGTH;        --Actual number of divisions minus 1
    CONSTANT numOfVoltDivisions : INTEGER := 4;                                    --Actual number of divisions minus 1
    CONSTANT one : STD_LOGIC_VECTOR(9 DOWNTO 0) := CONV_STD_LOGIC_VECTOR(1,10);
    SIGNAL timeDivResampleCounter : UNSIGNED(4 DOWNTO 0) := CONV_UNSIGNED(0, 5);
    SIGNAL voltageDivResampleCounter : UNSIGNED(2 DOWNTO 0) := CONV_UNSIGNED(0,3);
    
    
BEGIN

    


    division_counters: PROCESS(clk_out) BEGIN
        IF (RISING_EDGE(clk_out)) THEN
            IF (reset_l ='0') THEN
                incomingDecimationRate<=CONV_STD_LOGIC_VECTOR(0,incomingDecimationRate'LENGTH);
                timeDivResampleCounter <= CONV_UNSIGNED(0, 5);
                voltageDivResampleCounter <= CONV_UNSIGNED(0,3);
            ELSE
                --Implement the counter for the time divisions
                IF (timeDivsInc='0') THEN
                    IF(timeDivResampleCounter>=numOfTimeDivisions) THEN
                        timeDivResampleCounter<=timeDivResampleCounter;
                    ELSE
                        timeDivResampleCounter<=timeDivResampleCounter+1;
                    END IF;
                ELSIF (timeDivsDec='0') THEN
                    IF (timeDivResampleCounter=0) THEN
                        timeDivResampleCounter<=timeDivResampleCounter;
                    ELSE
                        timeDivResampleCounter<=timeDivResampleCounter-1;
                    END IF;
                END IF;
                
                --Implement the counter for the voltage divisions
                IF (vDivsInc='0') THEN
                    IF (voltageDivResampleCounter>=numOfVoltDivisions) THEN
                        voltageDivResampleCounter<=voltageDivResampleCounter;
                    ELSE
                        voltageDivResampleCounter<=voltageDivResampleCounter+1;
                    END IF;
                ELSIF (vDivsDec='0') THEN
                    IF (voltageDivResampleCounter=0) THEN
                        voltageDivResampleCounter<=voltageDivResampleCounter;
                    ELSE
                        voltageDivResampleCounter<=voltageDivResampleCounter-1;
                    END IF;
                END IF; 
                
                  
            END IF;
        END IF;
    END PROCESS;
    
    
    
    
    
    
    inc_decimation: PROCESS(clk_out) BEGIN
        IF (RISING_EDGE(clk_out)) THEN
            IF (reset_l='0') THEN
                incomingDecimationRate<=CONV_STD_LOGIC_VECTOR(0,incomingDecimationRate'LENGTH);
            ELSE
--                incomingDecimationRate<= CONV_STD_LOGIC_VECTOR(UNSIGNED(1) shl CONV_INTEGER(timeDivResampleCounter-1), incomingDecimationRate'LENGTH);        
                incomingDecimationRate<= STD_LOGIC_VECTOR(SHL(CONV_UNSIGNED(1,incomingDecimationRate'Length), UNSIGNED(timeDivResampleCounter)-1));        
                
            END IF;
        END IF; 
    END PROCESS;
    
    
    
    tDiv_display: PROCESS(clk_out) BEGIN
        IF (RISING_EDGE(clk_out)) THEN
            IF(reset_l='0') THEN
                resampleTDivValue<=CONV_STD_LOGIC_VECTOR(500,resampleTDivValue'LENGTH);
                resampleTDivUnit<="00";    
            ELSE
                CASE CONV_INTEGER(timeDivResampleCounter) IS
                    WHEN 0        => resampleTDivUnit <= "00"; resampleTDivValue <= CONV_STD_LOGIC_VECTOR(500, resampleTDivValue'LENGTH);                                                      --ns division
--                    WHEN 1 TO 10  => resampleTDivUnit <= "01"; resampleTDivValue <= CONV_STD_LOGIC_VECTOR(UNSIGNED(1) shl CONV_INTEGER(timeDivResampleCounter-1), resampleTDivValue'LENGTH);   --us division
--                    WHEN 11 TO 20 => resampleTDivUnit <= "10"; resampleTDivValue <= CONV_STD_LOGIC_VECTOR(UNSIGNED(1) shl CONV_INTEGER(timeDivResampleCounter-11), resampleTDivValue'LENGTH);  --ms divisons
                    WHEN 1 TO 10  => resampleTDivUnit <= "01"; resampleTDivValue <= STD_LOGIC_VECTOR(SHL(one, UNSIGNED(timeDivResampleCounter)-1));     --us division
                    WHEN 11 TO 20 => resampleTDivUnit <= "10"; resampleTDivValue <= STD_LOGIC_VECTOR(SHL(one, UNSIGNED(timeDivResampleCounter)-11));    --ms divisons        
                    WHEN OTHERS => resampleTDivUnit <= "00"; resampleTDivValue <= CONV_STD_LOGIC_VECTOR(500, resampleTDivValue'LENGTH);
                END CASE;
            END IF;
        
        END IF;
    END PROCESS;
    
    
    
--resampleVoltageSetting<=CONV_STD_LOGIC_VECTOR(voltageDivResampleCounter, resampleVoltageSetting'LENGTH);
    vDiv_setting: PROCESS(clk_out) BEGIN
        IF(RISING_EDGE(clk_out))THEN
            IF(reset_l='0')THEN
                resampleVoltageValue<=CONV_STD_LOGIC_VECTOR(50,resampleVoltageValue'LENGTH);
                resampleVoltageSetting<="000"; 
            ELSE
                resampleVoltageSetting<=CONV_STD_LOGIC_VECTOR(voltageDivResampleCounter, resampleVoltageSetting'LENGTH);
                
                CASE CONV_INTEGER(voltageDivResampleCounter) IS 
                    WHEN 0 => resampleVoltageValue<=CONV_STD_LOGIC_VECTOR(50,resampleVoltageValue'LENGTH);
                    WHEN 1 => resampleVoltageValue<=CONV_STD_LOGIC_VECTOR(100,resampleVoltageValue'LENGTH);
                    WHEN 2 => resampleVoltageValue<=CONV_STD_LOGIC_VECTOR(250,resampleVoltageValue'LENGTH);
                    WHEN 3 => resampleVoltageValue<=CONV_STD_LOGIC_VECTOR(500,resampleVoltageValue'LENGTH);
                    WHEN 4 => resampleVoltageValue<=CONV_STD_LOGIC_VECTOR(1000,resampleVoltageValue'LENGTH);
                    WHEN OTHERS => resampleVoltageValue<=CONV_STD_LOGIC_VECTOR(69,resampleVoltageValue'LENGTH);
                END CASE;
            END IF;
        END IF;
    END PROCESS;
    
    



END behavioral;
