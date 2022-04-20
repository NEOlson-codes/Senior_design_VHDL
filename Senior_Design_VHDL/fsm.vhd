LIBRARY IEEE;
USE IEEE.STD_LOGIC_1164.ALL ;
USE IEEE.STD_LOGIC_ARITH.ALL;
USE IEEE.STD_LOGIC_UNSIGNED.ALL;

--The FSM controller for the Oscilloscope
ENTITY fsm IS
	PORT(clk : IN STD_LOGIC;
		 reset_l : IN STD_LOGIC;
		 resample : IN STD_LOGIC;                    --button1
		 decimationFactor : IN UNSIGNED(20 DOWNTO 0);     --Incoming Decimation Rate
		 sampleAddr : OUT STD_LOGIC_VECTOR(13 DOWNTO 0);     --Use to address into the RAM and store data (also the number of samples obtained)
		 storeSample : OUT STD_LOGIC;
		 state_out : OUT STD_LOGIC_VECTOR(1 DOWNTO 0);
		 adc_in : IN STD_LOGIC_VECTOR(9 DOWNTO 0);
		 adcMin : INOUT STD_LOGIC_VECTOR(9 DOWNTO 0);
		 adcMax : INOUT STD_LOGIC_VECTOR(9 DOWNTO 0)	
		);
END fsm;


ARCHITECTURE behavioral OF fsm IS

	 TYPE states IS (triggerState,sampleState, displayState);
	 SIGNAL state: states := displayState;
	 SIGNAL nextState : states := displayState;
	 
	 
	 CONSTANT nsamples : INTEGER := 16384; --2^14 (16k)
	 
	 --Rename for button input
	 --SIGNAL resample : STD_LOGIC := '1';
	 
	 --Edge Detection 
	 SIGNAL edge_detected : STD_LOGIC := '0';
	 
	 --
	 SIGNAL sampleSkipper : UNSIGNED(decimationFactor'LENGTH-1 DOWNTO 0) := CONV_UNSIGNED(0,decimationFactor'LENGTH);
	 SIGNAL sampleCount : UNSIGNED(13 DOWNTO 0) := CONV_UNSIGNED(0,14); 
	  	

BEGIN
	--Transfers the state vector to the top layer
	WITH state SELECT 
	   state_out<= "00" WHEN triggerState,
	               "01" WHEN sampleState,
	               "10" WHEN OTHERS; 
	
    --Create the state flops
    state_reg: PROCESS(clk) BEGIN 
        IF (RISING_EDGE(clk)) THEN
           IF (reset_l = '0') THEN
               state<=triggerState;
           ELSE
               state<=nextState;
           END IF;
        END IF;  
    END PROCESS;
    
    
    --Implement the transition logic
    state_trans: PROCESS(state,resample,edge_detected) BEGIN
        state<=nextState;
        CASE state IS
            --Keep looking for an edge
            WHEN triggerState=> IF (edge_detected='1') THEN
                                    nextState<=sampleState;
                                ELSE
                                    nextState<=triggerState;
                                END IF;
            --Sample for nSamples (2^14) to get the waveform
            WHEN sampleState => IF (sampleCount < nSamples) THEN
                                    nextState<=sampleState;
                                ELSE
                                    nextState<=displayState;
                                END IF;
            --Stay in the displayState and show the waveform data
            --Unless the user prompts a resample
            WHEN displayState => IF (resample = '0') THEN
                                    nextState<=triggerState;
                                ELSE
                                    nextState<=displayState;
                                END IF;            
        END CASE;        
    END PROCESS;
    
    
    --The sample address is the same as the number of samples obtained
    sampleAddr<=CONV_STD_LOGIC_VECTOR(sampleCount,sampleCount'LENGTH);
    
    --Implements the sample counter 
    sample_counter: PROCESS(clk) BEGIN
        IF (RISING_EDGE(clk)) THEN
            --Reset the sample count when waiting for the trigger
            IF (reset_l = '0' OR (state=triggerState) OR (state=displayState)) THEN
                sampleSkipper<=CONV_UNSIGNED(0,sampleSkipper'LENGTH);
                sampleCount <= CONV_UNSIGNED(0,sampleCount'LENGTH);
                storeSample<='0';
                
            --If we are in the sampling state, keep incrementing every time we sample
            ELSIF(state=sampleState) THEN
                --Reset to not sampling (is overrided by IF statement below if valid)
                storeSample<='0';
                --If the skip Counter has reached the decimation factor, we are ready to sample
                IF (sampleSkipper = decimationFactor) THEN
                    --Reset the skip counter
                    sampleSkipper<=CONV_UNSIGNED(0,sampleSkipper'LENGTH);
                    --Increment the number of samples collected (doubles as the address)
                    sampleCount <= sampleCount+1;
                    --Tell the RAM to store the current ADC value
                    storeSample<='1';
                    
                --Increment the sample skipper if we arent ready to store a sample yet
                ELSIF(sampleSkipper<decimationFactor) THEN
                    sampleSkipper<=sampleSkipper+1;
                END IF;
               
            END IF;
        END IF;
    END PROCESS;
    
    
    
    --Find the minimum and maximum values out of the ADC
    minMax: PROCESS(clk) BEGIN
        IF(RISING_EDGE(clk))THEN
            IF (reset_l = '0') OR (state=triggerState) THEN
                adcMin<="1111111111";
                adcMax<="0000000000";
            --As the samples come in, compare to find the min and max
            ELSIF (state=sampleState) THEN
                --Find the Minimum
                IF (adc_in < adcMin) THEN
                    adcMin<=adc_in;
                END IF;
                --Find the maximum
                IF (adc_in > adcMax) THEN
                    adcMax<=adc_in;
                END IF;
            END IF;   
         END IF;    
    END PROCESS;
    
    --Add "state output" logic
    
    
    
    --Do the settings for resampling
    
    

	




END behavioral;




