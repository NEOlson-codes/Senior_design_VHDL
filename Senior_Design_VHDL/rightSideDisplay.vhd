LIBRARY IEEE ;
USE IEEE.STD_LOGIC_1164.ALL;
USE IEEE.STD_LOGIC_ARITH.ALL;
USE IEEE.STD_LOGIC_UNSIGNED.ALL;


ENTITY rightSideDisplay IS
	PORT(clk_out : IN STD_LOGIC;
		 reset_l : IN STD_LOGIC;
		 v, h : IN STD_LOGIC_VECTOR(9 DOWNTO 0);
		 addrChar : OUT STD_LOGIC_VECTOR(13 DOWNTO 0)		 
		 );
END rightSideDisplay;


ARCHITECTURE behavioral OF rightSideDisplay IS
    SIGNAL vIntg, hIntg, asciiVal : INTEGER := 0;
    SIGNAL asciiAddr : STD_LOGIC_VECTOR(6 DOWNTO 0) := CONV_STD_LOGIC_VECTOR(0, 7);
    
      

BEGIN

    --Convert the vertical and horizontal coords to integers
    vIntg<=CONV_INTEGER(v);
    hIntg<=CONV_INTEGER(h);
    
    --Creates an address into the charROM based on the ascii value and the current pixel
    asciiAddr <= CONV_STD_LOGIC_VECTOR(asciiVal, 7);
    addrChar <= asciiAddr & v(3 DOWNTO 0) & h(2 DOWNTO 0)-1;


    --Define the ascii values for the right side display
     asciiText: PROCESS(clk_out) BEGIN
        IF (RISING_EDGE(clk_out)) THEN
            --If reset is asserted, blacks out the right side display
            --IF (reset_l ='0') THEN
                --asciiVal <= 0;
            --ELSIF((v<480) AND (h<640 AND h>=520)) THEN
            IF((v<480) AND (h<640 AND h>=520)) THEN
                --Possibly shift values left by 2 to compensate for clock delay
                CASE vIntg IS
                   --1st row of text
                   WHEN 0 to 15 => 
                   CASE hIntg IS
                       WHEN 520 to 527 => asciiVal <= 0;
                       WHEN 528 to 535 => asciiVal <= 0;
                       WHEN 536 to 543 => asciiVal <= 65;
                       WHEN 544 to 551 => asciiVal <= 108;
                       WHEN 552 to 559 => asciiVal <= 97;
                       WHEN 560 to 567 => asciiVal <= 110;
                       WHEN 568 to 575 => asciiVal <= 0;
                       WHEN 576 to 583 => asciiVal <= 67;
                       WHEN 584 to 591 => asciiVal <= 111;
                       WHEN 592 to 599 => asciiVal <= 101;
                       WHEN 600 to 607 => asciiVal <= 0;
                       WHEN 608 to 615 => asciiVal <= 38;
                       WHEN 616 to 623 => asciiVal <= 0;
                       WHEN 624 to 631 => asciiVal <= 0;
                       WHEN 632 to 639 => asciiVal <= 0;
                       WHEN OTHERS => asciiVal <=0;                           
                   END CASE;
                   --2nd row of text
                   WHEN 16 to 31 => 
                   CASE hIntg IS
                       WHEN 520 to 527 => asciiVal <= 0;
                       WHEN 528 to 535 => asciiVal <= 0;
                       WHEN 536 to 543 => asciiVal <= 78;
                       WHEN 544 to 551 => asciiVal <= 101;
                       WHEN 552 to 559 => asciiVal <= 105;
                       WHEN 560 to 567 => asciiVal <= 108;
                       WHEN 568 to 575 => asciiVal <= 0;
                       WHEN 576 to 583 => asciiVal <= 79;
                       WHEN 584 to 591 => asciiVal <= 108;
                       WHEN 592 to 599 => asciiVal <= 115;
                       WHEN 600 to 607 => asciiVal <= 111;
                       WHEN 608 to 615 => asciiVal <= 110;
                       WHEN 616 to 623 => asciiVal <= 0;
                       WHEN 624 to 631 => asciiVal <= 0;
                       WHEN 632 to 639 => asciiVal <= 0;
                       WHEN OTHERS => asciiVal <=0;                           
                   END CASE;
                   --3rd Row of text
                   WHEN 32 to 47 => 
                   CASE hIntg IS
                       WHEN 520 to 527 => asciiVal <= 0;
                       WHEN 528 to 535 => asciiVal <= 0;
                       WHEN 536 to 543 => asciiVal <= 0;
                       WHEN 544 to 551 => asciiVal <= 0;
                       WHEN 552 to 559 => asciiVal <= 0;
                       WHEN 560 to 567 => asciiVal <= 0;
                       WHEN 568 to 575 => asciiVal <= 0;
                       WHEN 576 to 583 => asciiVal <= 0;
                       WHEN 584 to 591 => asciiVal <= 0;
                       WHEN 592 to 599 => asciiVal <= 0;
                       WHEN 600 to 607 => asciiVal <= 0;
                       WHEN 608 to 615 => asciiVal <= 0;
                       WHEN 616 to 623 => asciiVal <= 0;
                       WHEN 624 to 631 => asciiVal <= 0;
                       WHEN 632 to 639 => asciiVal <= 0;
                       WHEN OTHERS => asciiVal <=0;                           
                   END CASE;
                   --4th Row of text
                   WHEN 48 to 63 => 
                   CASE hIntg IS
                      WHEN 520 to 527 => asciiVal <= 0;
                      WHEN 528 to 535 => asciiVal <= 0;
                      WHEN 536 to 543 => asciiVal <= 86;
                      WHEN 544 to 551 => asciiVal <= 114;
                      WHEN 552 to 559 => asciiVal <= 109;
                      WHEN 560 to 567 => asciiVal <= 115;
                      WHEN 568 to 575 => asciiVal <= 0;
                      WHEN 576 to 583 => asciiVal <= 40;
                      WHEN 584 to 591 => asciiVal <= 109;
                      WHEN 592 to 599 => asciiVal <= 86;
                      WHEN 600 to 607 => asciiVal <= 41;
                      WHEN 608 to 615 => asciiVal <= 0;
                      WHEN 616 to 623 => asciiVal <= 0;
                      WHEN 624 to 631 => asciiVal <= 0;
                      WHEN 632 to 639 => asciiVal <= 0;
                      WHEN OTHERS => asciiVal <=0;                           
                  END CASE;
                  --5th Row of Text
                  WHEN 64 to 79 =>
                  CASE hIntg IS
                       WHEN 520 to 527 => asciiVal <= 0;
                       WHEN 528 to 535 => asciiVal <= 0;
                       WHEN 536 to 543 => asciiVal <= 0;
                       WHEN 544 to 551 => asciiVal <= 0;
                       WHEN 552 to 559 => asciiVal <= 0;
                       WHEN 560 to 567 => asciiVal <= 0;
                       WHEN 568 to 575 => asciiVal <= 0;
                       WHEN 576 to 583 => asciiVal <= 0;
                       WHEN 584 to 591 => asciiVal <= 0;
                       WHEN 592 to 599 => asciiVal <= 0;
                       WHEN 600 to 607 => asciiVal <= 0;
                       WHEN 608 to 615 => asciiVal <= 0;
                       WHEN 616 to 623 => asciiVal <= 0;
                       WHEN 624 to 631 => asciiVal <= 0;
                       WHEN 632 to 639 => asciiVal <= 0;
                       WHEN OTHERS => asciiVal <=0;                           
                   END CASE;
                   --6th Row of Text
                  WHEN 80 to 95 =>
                   CASE hIntg IS
                        WHEN 520 to 527 => asciiVal <= 0;
                        WHEN 528 to 535 => asciiVal <= 0;
                        WHEN 536 to 543 => asciiVal <= 0;
                        WHEN 544 to 551 => asciiVal <= 0;
                        WHEN 552 to 559 => asciiVal <= 0;
                        WHEN 560 to 567 => asciiVal <= 0;
                        WHEN 568 to 575 => asciiVal <= 0;
                        WHEN 576 to 583 => asciiVal <= 0;
                        WHEN 584 to 591 => asciiVal <= 0;
                        WHEN 592 to 599 => asciiVal <= 0;
                        WHEN 600 to 607 => asciiVal <= 0;
                        WHEN 608 to 615 => asciiVal <= 0;
                        WHEN 616 to 623 => asciiVal <= 0;
                        WHEN 624 to 631 => asciiVal <= 0;
                        WHEN 632 to 639 => asciiVal <= 0;
                        WHEN OTHERS => asciiVal <=0;                           
                    END CASE;
                    --7th Row
                    WHEN 96 to 111 =>
                      CASE hIntg IS
                           WHEN 520 to 527 => asciiVal <= 0;
                           WHEN 528 to 535 => asciiVal <= 0;
                           WHEN 536 to 543 => asciiVal <= 0;
                           WHEN 544 to 551 => asciiVal <= 0;
                           WHEN 552 to 559 => asciiVal <= 0;
                           WHEN 560 to 567 => asciiVal <= 0;
                           WHEN 568 to 575 => asciiVal <= 0;
                           WHEN 576 to 583 => asciiVal <= 0;
                           WHEN 584 to 591 => asciiVal <= 0;
                           WHEN 592 to 599 => asciiVal <= 0;
                           WHEN 600 to 607 => asciiVal <= 0;
                           WHEN 608 to 615 => asciiVal <= 0;
                           WHEN 616 to 623 => asciiVal <= 0;
                           WHEN 624 to 631 => asciiVal <= 0;
                           WHEN 632 to 639 => asciiVal <= 0;
                           WHEN OTHERS => asciiVal <=0;                           
                       END CASE;   
                        --8th Row
                       WHEN 96 to 127 =>
                         CASE hIntg IS
                              WHEN 520 to 527 => asciiVal <= 0;
                              WHEN 528 to 535 => asciiVal <= 0;
                              WHEN 536 to 543 => asciiVal <= 0;
                              WHEN 544 to 551 => asciiVal <= 0;
                              WHEN 552 to 559 => asciiVal <= 0;
                              WHEN 560 to 567 => asciiVal <= 0;
                              WHEN 568 to 575 => asciiVal <= 0;
                              WHEN 576 to 583 => asciiVal <= 0;
                              WHEN 584 to 591 => asciiVal <= 0;
                              WHEN 592 to 599 => asciiVal <= 0;
                              WHEN 600 to 607 => asciiVal <= 0;
                              WHEN 608 to 615 => asciiVal <= 0;
                              WHEN 616 to 623 => asciiVal <= 0;
                              WHEN 624 to 631 => asciiVal <= 0;
                              WHEN 632 to 639 => asciiVal <= 0;
                              WHEN OTHERS => asciiVal <=0;                           
                          END CASE;
                          --9th Row
                        WHEN 128 to 143 =>
                            CASE hIntg IS
                                 WHEN 520 to 527 => asciiVal <= 0;
                                 WHEN 528 to 535 => asciiVal <= 0;
                                 WHEN 536 to 543 => asciiVal <= 0;
                                 WHEN 544 to 551 => asciiVal <= 0;
                                 WHEN 552 to 559 => asciiVal <= 0;
                                 WHEN 560 to 567 => asciiVal <= 0;
                                 WHEN 568 to 575 => asciiVal <= 0;
                                 WHEN 576 to 583 => asciiVal <= 0;
                                 WHEN 584 to 591 => asciiVal <= 0;
                                 WHEN 592 to 599 => asciiVal <= 0;
                                 WHEN 600 to 607 => asciiVal <= 0;
                                 WHEN 608 to 615 => asciiVal <= 0;
                                 WHEN 616 to 623 => asciiVal <= 0;
                                 WHEN 624 to 631 => asciiVal <= 0;
                                 WHEN 632 to 639 => asciiVal <= 0;
                                 WHEN OTHERS => asciiVal <=0;                           
                             END CASE;
                                                                 
--                   --30th Row of text
--                   WHEN 64 to 79 =>
--                   IF (state=displayState) THEN 
--                   CASE hIntg IS
--                       WHEN 520 to 527 => asciiVal <= 0;
--                       WHEN 528 to 535 => asciiVal <= 0;
--                       WHEN 536 to 543 => asciiVal <= 0;
--                       WHEN 544 to 551 => asciiVal <= 68;
--                       WHEN 552 to 559 => asciiVal <= 105;
--                       WHEN 560 to 567 => asciiVal <= 115;
--                       WHEN 568 to 575 => asciiVal <= 112;
--                       WHEN 576 to 583 => asciiVal <= 108;
--                       WHEN 584 to 591 => asciiVal <= 97;
--                       WHEN 592 to 599 => asciiVal <= 121;
--                       WHEN 600 to 607 => asciiVal <= 0;
--                       WHEN 608 to 615 => asciiVal <= 0;
--                       WHEN 616 to 623 => asciiVal <= 0;
--                       WHEN 624 to 631 => asciiVal <= 0;
--                       WHEN 632 to 639 => asciiVal <= 0;
--                       WHEN OTHERS => asciiVal <=0;                           
--                   END CASE;
--                   ELSIF(state=sampleState) THEN
--                   CASE hIntg IS
--                       WHEN 520 to 527 => asciiVal <= 0;
--                       WHEN 528 to 535 => asciiVal <= 0;
--                       WHEN 536 to 543 => asciiVal <= 0;
--                       WHEN 544 to 551 => asciiVal <= 83;
--                       WHEN 552 to 559 => asciiVal <= 97;
--                       WHEN 560 to 567 => asciiVal <= 109;
--                       WHEN 568 to 575 => asciiVal <= 112;
--                       WHEN 576 to 583 => asciiVal <= 108;
--                       WHEN 584 to 591 => asciiVal <= 101;
--                       WHEN 592 to 599 => asciiVal <= 0;
--                       WHEN 600 to 607 => asciiVal <= 0;
--                       WHEN 608 to 615 => asciiVal <= 0;
--                       WHEN 616 to 623 => asciiVal <= 0;
--                       WHEN 624 to 631 => asciiVal <= 0;
--                       WHEN 632 to 639 => asciiVal <= 0;
--                       WHEN OTHERS => asciiVal <=0;                           
--                   END CASE;
--                   --Unknown state
--                   ELSE
--                   CASE hIntg IS
--                       WHEN 520 to 527 => asciiVal <= 0;
--                       WHEN 528 to 535 => asciiVal <= 0;
--                       WHEN 536 to 543 => asciiVal <= 0;
--                       WHEN 544 to 551 => asciiVal <= 85;
--                       WHEN 552 to 559 => asciiVal <= 110;
--                       WHEN 560 to 567 => asciiVal <= 107;
--                       WHEN 568 to 575 => asciiVal <= 110;
--                       WHEN 576 to 583 => asciiVal <= 111;
--                       WHEN 584 to 591 => asciiVal <= 119;
--                       WHEN 592 to 599 => asciiVal <= 110;
--                       WHEN 600 to 607 => asciiVal <= 0;
--                       WHEN 608 to 615 => asciiVal <= 0;
--                       WHEN 616 to 623 => asciiVal <= 0;
--                       WHEN 624 to 631 => asciiVal <= 0;
--                       WHEN 632 to 639 => asciiVal <= 0;
--                       WHEN OTHERS => asciiVal <=0;                           
--                   END CASE;                      
--                   END IF;
                   
                   
                   WHEN OTHERS => asciiVal <= 0;
               END CASE;
            END IF;
        END IF;
     END PROCESS;
     
END behavioral;