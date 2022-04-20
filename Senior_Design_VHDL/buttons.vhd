LIBRARY IEEE ;
USE IEEE.STD_LOGIC_1164.ALL ;
USE IEEE.STD_LOGIC_ARITH.ALL;
USE IEEE.STD_LOGIC_UNSIGNED.ALL;

--ALL BUTTONS RETURN LOGIC LOW WHEN ACTIVATED
ENTITY buttons IS
	PORT(clk_out : IN STD_LOGIC;
		 reset_l : IN STD_LOGIC;
		 button_in : IN STD_LOGIC; 
		 buttonOut : OUT STD_LOGIC;
		 buttonState: INOUT STD_LOGIC
		 );
END buttons;


ARCHITECTURE behavioral OF buttons IS
    SIGNAL button_sync : STD_LOGIC := '1';
    SIGNAL button_temp : STD_LOGIC := '1';
    SIGNAL button : STD_LOGIC := '1';
    SIGNAL button_out :STD_LOGIC :='1';
    
    --With a 25MHz clock, this allows us to count up to 1.25E6 (~50ms debounce timer)
    SIGNAL debounceCounter : STD_LOGIC_VECTOR(20 DOWNTO 0) := CONV_STD_LOGIC_VECTOR(0, 21);                    
	
BEGIN
    buttons: PROCESS(clk_out) BEGIN
        IF(RISING_EDGE(clk_out)) THEN
            --If reset is asserted, 
            IF (reset_l = '0') THEN
                button_out<='1';
                button_sync<='1';
                button_out<='1';
                button_temp<='1';
                debounceCounter<=CONV_STD_LOGIC_VECTOR(0, 21); 
                buttonState<='0';
            ELSE
                --Implements a button synchronizer
                button_sync<=button_in;
                button_temp<=button_sync;
                button<=button_temp;
                
                --OUTPUTS A HIGH SIGNAL WHEN THE BUTTON IS NOT PRESSED
                button_out<='1';
                
                --If the button was just high and is going low
                IF (button_temp='0' AND button='1' AND debounceCounter=0) THEN
                    --OUTPUTS A LOW SIGNAL WHEN THE BUTTON IS TRIGGERED
                    button_out<='0';
                    buttonState<=NOT(buttonState);
                    debounceCounter<=debounceCounter+1;
                --If the debounceCounter is 0 and the button was not pressed, stay at zero
                ELSIF(debounceCounter=0) THEN
                    debounceCounter<=debounceCounter;    
                --Otherwise, increment the debounceCounter
                ELSE
                    debounceCounter<=debounceCounter+1;    
                END IF;
                
                
            END IF;
        END IF;
    END PROCESS;
    
    
    
    
    

END behavioral;
