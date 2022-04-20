----------------------------------------------------------------------------------
-- Create Date: 01/20/2018 11:15:12 AM
-- Design Name: Digital Oscilloscope
-- ESE462 (Spring 2018)
-- Alan Coe and Neil Olson
----------------------------------------------------------------------------------




-----------------TO DO---------------
--Incoming Decimation factor
--Voltage scaling
--Horizontal Panning
--Horizontal scaling after sampling
--Var Gain DAC controller
--Fix state trans bug
--Edge triggering scanning?

--Regenerate the ADC RAM as dual port with Write Enables
--Use "storeData" as WRITE_EN (storeData is HIGH when valid)
--Use "sampleAddr" as the addr into the RAM for storage

LIBRARY IEEE;
USE IEEE.STD_LOGIC_1164.ALL ;
USE IEEE.STD_LOGIC_ARITH.ALL;
USE IEEE.STD_LOGIC_UNSIGNED.ALL;
--USE IEEE.NUMERIC_STD.ALL;


ENTITY vga IS
     PORT (clk : IN STD_LOGIC ;
	 reset_l_in : IN STD_LOGIC;
     r : OUT STD_LOGIC_VECTOR(3 DOWNTO 0) ;
     g : OUT STD_LOGIC_VECTOR(3 DOWNTO 0) ;
     b : OUT STD_LOGIC_VECTOR(3 DOWNTO 0) ;
     hs : OUT STD_LOGIC ;
     vs : OUT STD_LOGIC;
	 enc1_in : IN STD_LOGIC_VECTOR(1 DOWNTO 0);
	 enc2_in : IN STD_LOGIC_VECTOR(1 DOWNTO 0);
	 enc3_in : IN STD_LOGIC_VECTOR(1 DOWNTO 0);
	 enc4_in : IN STD_LOGIC_VECTOR(1 DOWNTO 0);
	 enc1b_in: IN STD_LOGIC;
	 enc2b_in: IN STD_LOGIC;
	 enc3b_in: IN STD_LOGIC;
	 enc4b_in: IN STD_LOGIC;
	 b1_in : IN STD_LOGIC;
	 b2_in : IN STD_LOGIC;
	 b3_in : IN STD_LOGIC;
	 b4_in : IN STD_LOGIC;
	 b5_in : IN STD_LOGIC;
	 b6_in : IN STD_LOGIC;
	 adc_in : IN STD_LOGIC_VECTOR(9 DOWNTO 0);
	 dacOut : OUT STD_LOGIC_VECTOR(5 DOWNTO 0)             --Sets the Vgain for the VarGainAmp
     );

END vga ;

ARCHITECTURE mine OF vga IS
     SIGNAL h : STD_LOGIC_VECTOR(9 downto 0) := "0000000000";
     SIGNAL v : STD_LOGIC_VECTOR(9 DOWNTO 0) := "0000000000";
     SIGNAL clk_out : STD_LOGIC ;
     
     --Constants
     
     
 
     --RGB signals
     SIGNAL hs_int0, hs_int1, hs_int2 : STD_LOGIC := '0';
     SIGNAL vs_int0, vs_int1, vs_int2 : STD_LOGIC := '0';
     SIGNAL r_int : STD_LOGIC_VECTOR(3 DOWNTO 0) := "0000";
     SIGNAL g_int : STD_LOGIC_VECTOR(3 DOWNTO 0) := "0000";
     SIGNAL b_int : STD_LOGIC_VECTOR(3 DOWNTO 0) := "0000";
     SIGNAL rgb : STD_LOGIC_VECTOR(11 DOWNTO 0) := "000000000000";
	 
	 --ADC memory IO    
	 SIGNAL addra : STD_LOGIC_VECTOR(8 DOWNTO 0) := "000000000";
     SIGNAL douta  : STD_LOGIC_VECTOR(11 DOWNTO 0) := "000000000000";
     SIGNAL douta_prev,douta_flipped : STD_LOGIC_VECTOR(11 DOWNTO 0) := "000000000000";
	 
	 --Button and encoder synchronizer
	 SIGNAL reset_l_temp, reset_l : STD_LOGIC := '0';
	 SIGNAL enc1_temp, enc1 : STD_LOGIC_VECTOR(1 DOWNTO 0) := "00";
     SIGNAL enc2_temp, enc2 : STD_LOGIC_VECTOR(1 DOWNTO 0) := "00";
     SIGNAL enc3_temp, enc3 : STD_LOGIC_VECTOR(1 DOWNTO 0) := "00";
     SIGNAL enc4_temp, enc4 : STD_LOGIC_VECTOR(1 DOWNTO 0) := "00";
	 
	 SIGNAL enc1b_temp, enc1b : STD_LOGIC := '1';
	 SIGNAL enc2b_temp, enc2b : STD_LOGIC := '1';
	 SIGNAL enc3b_temp, enc3b : STD_LOGIC := '1';
	 SIGNAL enc4b_temp, enc4b : STD_LOGIC := '1';
	
	 
	 
     	 
	
	 
	 
	 
	 
	 
	 
    --Buttons
    SIGNAL resample : STD_LOGIC := '1';  --Buttons are active LOW, so reset HIGH
    SIGNAL resampleState : STD_LOGIC := '0';
    SIGNAL changeSettings : STD_LOGIC := '1';
    SIGNAL changeResampleSettingsState : STD_LOGIC := '0';  --Is a button state, default to HIGH to show time divisions   
    
    COMPONENT buttons
    PORT(clk_out: IN STD_LOGIC;
         reset_l : IN STD_LOGIC;
         button_in : IN STD_LOGIC;
         buttonOut : OUT STD_LOGIC;
         buttonState: INOUT STD_LOGIC
         );
    END COMPONENT;
    
    
    --Right Side Display
    COMPONENT rightSideDisplay
    PORT(clk_out : IN STD_LOGIC;
         reset_l : IN STD_LOGIC;
         v, h: IN STD_LOGIC_VECTOR(9 DOWNTO 0);
         addrChar : OUT STD_LOGIC_VECTOR(13 DOWNTO 0));
     END COMPONENT;
     
     
     --State Machine
     SIGNAL stateOut : STD_LOGIC_VECTOR(1 DOWNTO 0) := "00";
     SIGNAL decimationFactor : UNSIGNED(20 DOWNTO 0) := CONV_UNSIGNED(0,21);
     SIGNAL storeSample : STD_LOGIC := '0';
     SIGNAL sampleAddr : STD_LOGIC_VECTOR(13 DOWNTO 0) := CONV_STD_LOGIC_VECTOR(0,14);
     SIGNAL adcMin, adcMax : STD_LOGIC_VECTOR(9 DOWNTO 0) := CONV_STD_LOGIC_VECTOR(0,10);
     COMPONENT fsm
     PORT(clk : IN STD_LOGIC;
          reset_l: IN STD_LOGIC;
          resample: IN STD_LOGIC;
          decimationFactor: IN UNSIGNED(20 DOWNTO 0);
          sampleAddr : OUT STD_LOGIC_VECTOR(13 DOWNTO 0);     --Use to address into the RAM and store data (also the number of samples obtained)
          storeSample : OUT STD_LOGIC;
          state_out : OUT STD_LOGIC_VECTOR(1 DOWNTO 0);
          adc_in : IN STD_LOGIC_VECTOR(9 DOWNTO 0);
          adcMin : INOUT STD_LOGIC_VECTOR(9 DOWNTO 0);
          adcMax : INOUT STD_LOGIC_VECTOR(9 DOWNTO 0));
    END COMPONENT;
 
 
 
     --DCM
     COMPONENT clk_wiz_0
     PORT (clk_out1 : OUT STD_LOGIC;
           clk_in1 : IN STD_LOGIC);
     END COMPONENT;
     
     --ADC Memory
     COMPONENT ScopeData          
     PORT (clka : IN STD_LOGIC;
           addra : IN STD_LOGIC_VECTOR(8 DOWNTO 0);
           douta : OUT STD_LOGIC_VECTOR(11 DOWNTO 0));
     END COMPONENT;
     
     --Char ROM
     --SIGNAL addrb : STD_LOGIC_VECTOR(13 DOWNTO 0);
     SIGNAL addrChar : STD_LOGIC_VECTOR(13 DOWNTO 0);
     SIGNAL doutChar : STD_LOGIC_VECTOR(0 DOWNTO 0);
     COMPONENT char_ROM          
     PORT (clka : IN STD_LOGIC;
           addra : IN STD_LOGIC_VECTOR(13 DOWNTO 0);
           douta : OUT STD_LOGIC_VECTOR(0 DOWNTO 0));
     END COMPONENT;
      
      
      
      --The current time division
     SIGNAL tDivSamplingValue : STD_LOGIC_VECTOR(9 DOWNTO 0) := CONV_STD_LOGIC_VECTOR(0, 10);
     SIGNAL tDivSamplingUnit :STD_LOGIC_VECTOR(1 DOWNTO 0) := "00";
     SIGNAL tDivSamplingSetting : STD_LOGIC_VECTOR(4 DOWNTO 0) := CONV_STD_LOGIC_VECTOR(0, 5);
     COMPONENT timeDivs
     PORT (clk_out : IN STD_LOGIC;
           reset_l : IN STD_LOGIC;  
           timeDivEnc : IN STD_LOGIC_VECTOR(1 DOWNTO 0);
           tDivSamplingValue : OUT STD_LOGIC_VECTOR(9 DOWNTO 0);      --Allows representation up to 1000 
           tDivSamplingUnit : OUT STD_LOGIC_VECTOR(1 DOWNTO 0);       --Provides the Unit of the time division
           tDivSamplingSetting : OUT STD_LOGIC_VECTOR(4 DOWNTO 0)
          );      
     END COMPONENT;
      
      
     --Set the Resample Settings
     SIGNAL timeDivsInc, timeDivsDec : STD_LOGIC := '1';
     SIGNAL vDivsInc, vDivsDec : STD_LOGIC := '1';
     SIGNAL incomingDecimationFactor : STD_LOGIC_VECTOR(20 DOWNTO 0) := CONV_STD_LOGIC_VECTOR(0, 21);
     SIGNAL resampleVoltageSetting : STD_LOGIC_VECTOR(2 DOWNTO 0) :="000";
     SIGNAL resampleVoltageValue : STD_LOGIC_VECTOR(9 DOWNTO 0) := CONV_STD_LOGIC_VECTOR(50, 10);
     SIGNAL resampleTDivValue : STD_LOGIC_VECTOR(9 DOWNTO 0) := CONV_STD_LOGIC_VECTOR(500, 10);
     SIGNAL resampleTDivUnit : STD_LOGIC_VECTOR(1 DOWNTO 0) := "00";
     
     COMPONENT setResampleSettings
     PORT(clk_out : IN STD_LOGIC;
          reset_l : IN STD_LOGIC;
          timeDivsInc : IN STD_LOGIC;          --Button to increase the sample time division (decrease FS)
          timeDivsDec : IN STD_LOGIC;          --Button to decrease the sample time division (increase FS)
          vDivsInc : IN STD_LOGIC;             --Button to increase the target voltage
          vDivsDec : IN STD_LOGIC;             --Button to decrease the target voltage
          incomingDecimationRate : OUT STD_LOGIC_VECTOR(20 DOWNTO 0);       --Set the incoming number of samples to be skipped
          resampleVoltageSetting : OUT STD_LOGIC_VECTOR(2 DOWNTO 0);
          resampleVoltageValue : OUT STD_LOGIC_VECTOR(9 DOWNTO 0);               --Allows for value up to 8000mV+
          resampleTDivValue : OUT STD_LOGIC_VECTOR(9 DOWNTO 0);
          resampleTDivUnit : OUT STD_LOGIC_VECTOR(1 DOWNTO 0)
         );
    END COMPONENT;
    
    
    
    
    
    --vgaDAC
    COMPONENT vgaDAC
    PORT(clk_out : IN STD_LOGIC;
         reset_l : IN STD_LOGIC;
         resampleVoltageSetting : IN STD_LOGIC_VECTOR(2 DOWNTO 0);
         dacOut : OUT STD_LOGIC_VECTOR(5 DOWNTO 0)
         );
    END COMPONENT;
    
    
    
           
     
     
     
     
BEGIN

    ----------------------------------BUTTONS--------------------------------- 
    button1: buttons    --Resample
    PORT MAP(clk_out=>clk_out,
             reset_l=>reset_l,
             button_in=>b1_in,
             buttonOut=>resample,                                --Used 
             buttonState=>resampleState);                        --Not used
             
    button2: buttons    --ChangeResampleSettingsState
    PORT MAP(clk_out=>clk_out,
             reset_l=>reset_l,
             button_in=>b2_in,
             buttonOut=>changeSettings,                        --Not used
             buttonState=>changeResampleSettingsState);        --Used
                          
    button3: buttons    --Unused
    PORT MAP(clk_out=>clk_out,
             reset_l=>reset_l,
             button_in=>b3_in,
             buttonOut=>timeDivsInc,                           -- used
             buttonState=>changeResampleSettingsState);        --Not Used                         
             
    button4: buttons    --Unused
    PORT MAP(clk_out=>clk_out,
             reset_l=>reset_l,
             button_in=>b4_in,
             buttonOut=>timeDivsDec,                           --Used
             buttonState=>changeResampleSettingsState);        --Not used               
             
    button5: buttons    --Unused
    PORT MAP(clk_out=>clk_out,
             reset_l=>reset_l,
             button_in=>b5_in,
             buttonOut=>vDivsInc,                              --Used
             buttonState=>changeResampleSettingsState);        --Not used               
             
    button6: buttons    --Unused
    PORT MAP(clk_out=>clk_out,
            reset_l=>reset_l,
            button_in=>b6_in,
            buttonOut=>vDivsDec,                              --Used
            buttonState=>changeResampleSettingsState);        --Not used             
    -------------------------------END BUTTONS--------------------------------           
    
    
    
    
    
    --------------------------DIGITAL CLOCK MANAGER---------------------------
     --DCM
     mydcm:clk_wiz_0
     PORT MAP(clk_out1 => clk_out,
              clk_in1 => clk);
              
    -----------------------END DIGITAL CLOCK MANAGER-------------------------          
              
              
              
              
              
              
    --------------------------------BLOCK RAMS-------------------------------          
    --Assign the address
    addra <= h(8 DOWNTO 0);
     
     --Block ROM
     myrom:ScopeData
     PORT MAP(clka => clk_out,
              addra => addra,
              douta => douta);   
              
    --Block ROM
    cROM: char_ROM
    PORT MAP(clka => clk_out,
             addra => addrChar,
             douta => doutChar);
             
    -----------------------------END BLOCK RAMS------------------------------
                





    --------------------------RIGHT SIDE DISPLAY-----------------------------
    asciiDisplay: rightSideDisplay
    PORT MAP(clk_out=>clk_out,
             reset_l=>reset_l,
             v=>v,
             h=>h,
             addrChar=>addrChar);
    
    ------------------------END RIGHT SIDE DISPLAY---------------------------
    
    
    
    
    
    -----------------------------STATE MACHINE-------------------------------
    stateMachine: fsm
    PORT MAP(clk=>clk,
             reset_l=>reset_l,
             resample=>resample,
             decimationFactor=>UNSIGNED(incomingDecimationFactor),      --takes in the current decimation setting        
             sampleAddr=>sampleAddr,
             storeSample=>storeSample,
             state_out=>stateOut,
             adc_in=>adc_in,
             adcMin=>adcMin,
             adcMax=>adcMax);
    
    ---------------------------END STATE MACHINE-----------------------------
    
    
    
    
    
    -----------------------------TIME DIVISIONS------------------------------
    timeDivisions: timeDivs
    PORT MAP(clk_out=>clk_out,
             reset_l=>reset_l,
             timeDivEnc=>enc1_in,
             tDivSamplingValue=>tDivSamplingValue,
             tDivSamplingUnit=>tDivSamplingUnit,
             tDivSamplingSetting=>tDivSamplingSetting);
             
    ---------------------------END TIME DIVISIONS-----------------------------
    
    
    
    
    
    
    -------------------------SET RESAMPLE SETTINGS----------------------------
    resampleSettings: setResampleSettings
    PORT MAP(clk_out=>clk_out,
             reset_l=>reset_l,
             timeDivsInc=>timeDivsInc,
             timeDivsDec=>timeDivsDec,
             vDivsInc=>vDivsInc,
             vDivsDec=>vDivsDec,
             incomingDecimationRate=>incomingDecimationFactor,          --This is the correct incDecFactor
             resampleVoltageSetting=>resampleVoltageSetting,
             resampleVoltageValue=>resampleVoltageValue,
             resampleTDivValue=>resampleTDivValue,
             resampleTDivUnit=>resampleTDivUnit);
    
    -----------------------END SET RESAMPLE SETTINGS--------------------------
    
    
    
    
    
    -----------------------------SET VAR GAIN DAC-----------------------------    
    setVGA_DAC: vgaDAC
    PORT MAP(clk_out=>clk_out,
             reset_l=>reset_l,
             resampleVoltageSetting=>resampleVoltageSetting,
             dacOut=>dacOut);
                
    ---------------------------END SET VAR GAIN DAC---------------------------
    

    --Store the previous data from the RAM/ROM
    --Allows comparison for vector drawing
    invertData:PROCESS(clk_out) BEGIN
        IF (RISING_EDGE(clk_out)) THEN
            IF (reset_l='0') THEN
                douta_flipped<=(512-douta-16);
                douta_prev<=douta_flipped;
            ELSE
                douta_flipped<=(512-douta-16);
                douta_prev<=douta_flipped;
            END IF;
        END IF;
    END PROCESS;
	
	--Break apart the rgb vector
--	r_int<=rgb(11 DOWNTO 8);
--	g_int<=rgb(7 DOWNTO 4);
--	b_int<=rgb(3 DOWNTO 0);

    --Testing
    PROCESS(clk_out) BEGIN
        IF(RISING_EDGE(clk_out)) THEN
            IF (v<480 AND h<640) THEN
                r_int<=rgb(11 DOWNTO 8);
                g_int<=rgb(7 DOWNTO 4);
                b_int<=rgb(3 DOWNTO 0);
            ELSE
                r_int<="0000";
                g_int<="0000";
                b_int<="0000";
            END IF;
        END IF;
    END PROCESS;
	
	---------------------------------------------------------------------------
	--Two different clocks need to go to the ADC RAM (needs a fix)
	--Use True Dual port RAM with two clocks
	--Use "storeSample" as the enable for writting to the RAM
	----------------------------------------------------------------------------------
	

	
	 
    --Assign RGB values based on the values of h and v
    vga: PROCESS(clk_out) BEGIN 
           IF (RISING_EDGE(clk_out)) THEN
               --If the counters are outside of the 640x480 display region
               --Set the RGB Value to black
               IF(h>=640 OR v>=480) THEN
                    rgb<="000000000000";
			   --Do the ADC plotting
               ELSIF (h<512 AND v<480) THEN
					--ADC plotting w/interpolation
                    IF (((douta_flipped=v) OR (douta_prev>douta_flipped AND (douta_flipped<v AND douta_prev>v)) OR (douta_prev<douta_flipped AND (douta_flipped>v AND douta_prev<v)))) AND (douta_flipped>=1 AND douta_flipped<480) AND NOT(douta_flipped=1 AND douta_prev>=480) THEN
                        rgb<="111100000000";
                    --Draw the x and y axis, and the vertical and horizontal hash marks
                    ELSIF (h=256 OR v=240) OR ((v<243 AND v> 237) AND ((CONV_INTEGER(UNSIGNED(h)) MOD 50)= 6)) OR ((h>253 AND h<259) AND ((480-CONV_INTEGER(UNSIGNED(v)) MOD 50) = 0)) THEN
                        rgb<="111111111111";
					--No value found, so make the background black (currently blue for testinG)
                    ELSE
                        rgb<="000000000000";
                    END IF;
			  --Vertical bar to seperate the plot from right side menu
			  ELSIF (h=512 OR h=513) THEN
						rgb<="000011111111";
			  --Right side display
			  ELSIF (h>=520 AND h<640) AND (v<480) THEN 
			        --Assign RGB values based on the output of the charROM
					rgb<= doutChar AND "000011111111";			  
               ELSE
                    rgb<="000000000000";
               END IF;
           END IF;
     END PROCESS;
     
     
     
     
     
    --Horizontal counter      
    h_counter:PROCESS(clk_out) BEGIN
        IF (RISING_EDGE(clk_out)) THEN
            --If h counter is at 799, reset to 0
            --At the same time, inc v (the row number)
            IF (h="1100011111") THEN
                h<="0000000000";
                v<=v+1;
            --Otherwise, inc h to progress through the horizontal pixels
            ELSE
                h<=h+1;
            END IF;
            
            IF (v="1000001100" AND h="1100011111") THEN
                v<="0000000000";
            END IF;
        END IF;
   END PROCESS;
   
   
   --Vertical Counter
   v_counter: PROCESS(clk_out) BEGIN 
           IF (RISING_EDGE(clk_out)) THEN
               --If the v counter is at 524, reset to 0
               --The row is already reset by the h counter logic above
               IF (v="1000001100") THEN
                   --v<="0000000000";
               END IF;
           END IF;
    END PROCESS;
    
    

      
      
     --Generate the HS and VS
     hv_sync: PROCESS(clk_out) BEGIN 
                  IF (RISING_EDGE(clk_out)) THEN
                      --Generate the HS pulse
                      IF(h>="1010010000" AND h<="1011110000") THEN
                        hs_int0<='0';
                      ELSE
                        hs_int0<='1';
                      END IF;
                      --Generate the VS pulse
                      --IF(v="0111101010" OR v="0111101010") THEN
                      IF ((v="0111101001" OR v="0111101010") AND h="1100011111") THEN
                        vs_int0<='0';
                      ELSIF (v="0111101011" AND h="1100011111") THEN
                        vs_int0<='1';
                      ELSIF (v="0111101010" OR v="0111101011") THEN
                        vs_int0<='0';
                      ELSE
                        vs_int0<='1';
                      END IF;
                  END IF;
     END PROCESS; 
      
      
    --Synchronize all of the outputs to the clock
    vga_sync: PROCESS(clk_out) BEGIN 
             IF (RISING_EDGE(clk_out)) THEN
                 r<=r_int;
                 g<=g_int;
                 b<=b_int;
                 --Use back to back FFs to offset the 2 clock latency from the ROM
                 hs_int1<=hs_int0;
                 hs_int2<=hs_int1;
                 hs<=hs_int2;
                 vs_int1<=vs_int0;
                 vs_int2<=vs_int1;
                 vs<=vs_int2;
             END IF;
    END PROCESS;
	
	--Reset Synchronizer
	reset_sync: PROCESS (clk_out) BEGIN
			IF (RISING_EDGE(clk_out)) THEN
			     --Reset Synchronizer
			     reset_l_temp<=reset_l_in;
			     reset_l<=reset_l_temp;

			END IF;
	END PROCESS;
	
	--ADC Value Synchronizer?
	
	
	
	
	
	
	
	
	
END mine ;






