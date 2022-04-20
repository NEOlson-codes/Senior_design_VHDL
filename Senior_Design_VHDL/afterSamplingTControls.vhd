LIBRARY IEEE ;
USE IEEE.STD_LOGIC_1164.ALL;
USE IEEE.STD_LOGIC_ARITH.ALL;
USE IEEE.STD_LOGIC_UNSIGNED.ALL;


ENTITY afterSamplingTControls IS
	PORT(clk_out : IN STD_LOGIC;
		 reset_l : IN STD_LOGIC;  
		 timePanEnc_in : IN STD_LOGIC_VECTOR(1 DOWNTO 0);             --Real time time panning encoder    
		 timeDivRTEnc : IN STD_LOGIC_VECTOR(1 DOWNTO 0);              --Real time sample decimation encoder
		 tDivRTValue : OUT STD_LOGIC_VECTOR(9 DOWNTO 0);              --Real time division value
		 tDivRTUnit : OUT STD_LOGIC_VECTOR(1 DOWNTO 0);		          --Real time division unit
		 tDivRTSetting : INOUT STD_LOGIC_VECTOR(4 DOWNTO 0);          --Real time time division setting
		 tPanPosition : OUT STD_LOGIC_VECTOR(13 DOWNTO 0);            --Shifts the address into the sample RAM
		 tDivPrevSamplingSetting : IN STD_LOGIC_VECTOR(4 DOWNTO 0)    --Take in the previous sampling decimation setting        
		 );
END afterSamplingTControls;


ARCHITECTURE behavioral OF afterSamplingTControls IS
    --SIGNAL tDivRTSetting : STD_LOGIC_VECTOR(4 DOWNTO 0) := CONV_STD_LOGIC_VECTOR(0,5);
    SIGNAL countInt, tDivInt : INTEGER := 0;
    CONSTANT countMax : STD_LOGIC_VECTOR(4 DOWNTO 0) := CONV_STD_LOGIC_VECTOR(5,5);     --There are 6 different RT decimation factors
    CONSTANT one : STD_LOGIC_VECTOR(9 DOWNTO 0) := CONV_STD_LOGIC_VECTOR(1,10);
    SIGNAL settingDiff : STD_LOGIC_VECTOR(4 DOWNTO 0) := CONV_STD_LOGIC_VECTOR(0,5);
    
    --Signals for tPan and its encoder
    SIGNAL tPanEnc_temp, tPanEnc : STD_LOGIC_VECTOR(1 DOWNTO 0) := "00";
    SIGNAL tPanEnc_en, tPanEnc_dir : STD_LOGIC := '0';
    SIGNAL tPanEnc_vec : STD_LOGIC_VECTOR(1 DOWNTO 0) :="00";    
    SIGNAL tPanEncCounter : STD_LOGIC_VECTOR(13 DOWNTO 0) := CONV_STD_LOGIC_VECTOR(0,14);
    SIGNAL tPanEncDifference : STD_LOGIC_VECTOR(5 DOWNTO 0) := CONV_STD_LOGIC_VECTOR(0,6);
       
    COMPONENT encoders
    PORT(clk_out: IN STD_LOGIC;
         reset_l: IN STD_LOGIC;
         buttonState: IN STD_LOGIC;
         enc_in : IN STD_LOGIC_VECTOR(1 DOWNTO 0);
         countMax: IN STD_LOGIC_VECTOR(4 DOWNTO 0);
         countOut: OUT STD_LOGIC_VECTOR(4 DOWNTO 0)
        );
    END COMPONENT;    
    
    
BEGIN

    timeDivRTEncoder: encoders
    PORT MAP(clk_out=>clk_out,
             reset_l=>reset_l,
             buttonState=>'0',
             enc_in=>timeDivRTEnc,
             countMax=>countMax,
             countOut=> tDivRTSetting);
    
    
    --Convert the encoder to counter to an Integer for CASE statement below     
    countInt<=CONV_INTEGER(UNSIGNED(tDivRTSetting));
    
    
    realTimeDecimation: PROCESS(clk_out) BEGIN
        IF (RISING_EDGE(clk_out)) THEN
            IF (reset_l='0') THEN
                settingDiff<=CONV_STD_LOGIC_VECTOR(0, settingDiff'LENGTH);
                tDivRTValue<=CONV_STD_LOGIC_VECTOR(500, tDivRTValue'LENGTH);
                tDivRTUnit<="00";
            ELSE
                settingDiff<=tDivPrevSamplingSetting+tDivRTSetting;
                
                CASE countInt IS
                    WHEN 0       => tDivRTUnit<="00"; tDivRTValue<=CONV_STD_LOGIC_VECTOR(500, tDivRTValue'LENGTH);
--                    WHEN 1 TO 10 => tDivRTUnit<="01"; tDivRTValue<=CONV_STD_LOGIC_VECTOR(UNSIGNED(1) SHL CONV_INTEGER(settingDiff-1), tDivRTValue'LENGTH);
--                    WHEN 11 TO 20=> tDivRTUnit<="10"; tDivRTValue<=CONV_STD_LOGIC_VECTOR(UNSIGNED(1) SHL CONV_INTEGER(settingDiff-11), tDivRTValue'LENGTH);
                    WHEN 1 TO 10 => tDivRTUnit<="01"; tDivRTValue<=STD_LOGIC_VECTOR(SHL(one, UNSIGNED(settingDiff)-1));
                    WHEN 11 TO 20=> tDivRTUnit<="10"; tDivRTValue<=STD_LOGIC_VECTOR(SHL(one, UNSIGNED(settingDiff)-11));
                    
                    WHEN OTHERS  => tDivRTUnit<="00"; tDivRTValue<=CONV_STD_LOGIC_VECTOR(500, tDivRTValue'LENGTH);
                END CASE;
                
                
                
            END IF;
        END IF;
    
    END PROCESS;
    
    
    
    
    
    
    
    
    tPanEnc_en<=tPanEnc(1) XOR tPanEnc(0) XOR tPanEnc_temp(1) XOR tPanEnc_temp(0);
    tPanEnc_dir<=tPanEnc(1) XOR tPanEnc_temp(0);
    tPanPosition<=tPanEncCounter;
    tPanEnc_vec<=tPanEnc_en & tPanEnc_dir;
    
    timePanEncoder: PROCESS(clk_out) BEGIN
        IF (RISING_EDGE(clk_out)) THEN
            IF (reset_l='0') THEN
                tPanEnc_temp<="00";
                tPanEnc<="00";
                
                --tPanValue<=CONV_STD_LOGIC_VECTOR(0, tPanValue'LENGTH);
                tPanEncDifference<=CONV_STD_LOGIC_VECTOR(1, tPanEncDifference'LENGTH);
                tPanEncCounter<=CONV_STD_LOGIC_VECTOR(0, tPanEncCounter'LENGTH);
            ELSE
                --Input Synchronizer
                tPanEnc_temp<=timePanEnc_in;
                tPanEnc<=tPanEnc_temp;
                
                --Update the value to be incremented or decremented
--                tPanEncDifference<=CONV_STD_LOGIC_VECTOR(UNSIGNED(1) SHL CONV_INTEGER(tDivRTSetting), tPanEncDifference'LENGTH);
                tPanEncDifference<=STD_LOGIC_VECTOR(SHL(CONV_UNSIGNED(1,tPanEncDifference'Length), UNSIGNED(tDivRTSetting)));
                 
                --Gets directly mapped to the first input in RAM
                CASE tPanEnc_vec IS
                    WHEN "10" =>
                        tPanEncCounter<=tPanEncCounter-tPanEncDifference;
                    WHEN "11" =>
                        tPanEncCounter<=tPanEncCounter+tPanEncDifference;
                    WHEN OTHERS =>
                        tPanEncCounter<=tPanEncCounter;
                END CASE;
            END IF;
        END IF;
    
    END PROCESS;
    


END behavioral;
