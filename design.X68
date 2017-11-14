*-----------------------------------------------------------
* Title      :  Patrick Bartman's Design Project
* Written by :  Patrick Bartman
* Date       :  11/30/2017
* Description:  
*-----------------------------------------------------------
    ORG    $1000
START:                  ; first instruction of program

* Put program code here

    CLR.L   D0
    CLR.L   D1
    
* see http://www.easy68k.com/QuickStart/Hello%20World%20Program%203.txt

LOOP
	LEA     MONITOR,A1  ; gives command prompt
	MOVE.B  #14,D0      ; stores result in D0
	TRAP    #15
    
INPUT:
	LEA     BUFFER,A1   ; TODO: need to increment buffer if trying to store, or clear if not
    MOVE.B  #2,D0       ; trap task 2 does the following:
    TRAP    #15         ; read a string from the keyboard into A1 of length stored at D1.W
    MOVEA.L D2,A1
    CMP.W   #0,D1       ; compares D1 to the number 0 to see if not empty
    BEQ     DONE        ; branch DONE if they are equal
    
* do code to determine what to do next here

RETURN:
    ;MOVE.B  #14,D0      ; go back to monitor
    ;TRAP    #15
    BRA     LOOP
    
    
DONE:
    MOVE.B  #9,D0
    TRAP    #15         ; halt simulator
    
    

    SIMHALT             ; halt simulator

* Put variables and constants here

MONITOR DC.B    'MONITOR441> ',0        ; command prompt input message
BUFFER  DS.B    80                      ; input string storage          ; 103F      ; TODO: find out if 80 is length of buffer, or what else it could be

    END    START        ; last line of source

*~Font name~Courier New~
*~Font size~10~
*~Tab type~1~
*~Tab size~4~
