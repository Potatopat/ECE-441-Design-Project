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

LOOP:
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

* PSUEDOCODE:	
* check if text in ?buffer? is equal to possible commands one by one
* see http://freesource-codes.blogspot.com/2011/11/string-comparision-in-assembly-language.html
* will be super long, but entirely copy-paste
	
	
	
	
RETURN:
    ;MOVE.B  #14,D0      ; go back to monitor
    ;TRAP    #15
    BRA     LOOP

HELP:
	LEA		HELPTEXT,A1	; load helptext into a1
	MOVE.B	#14,D0		; display text
	TRAP	#15
	BRA		RETURN
	
GO:
	* TODOL load branching address into A7 during string parsing *
	BRA A7				; branch to location to run that program

EXIT:
	BRA		DONE

DONE:
    MOVE.B  #9,D0
    TRAP    #15         ; halt simulator
    
    

    SIMHALT             ; halt simulator

* Put variables and constants here

MONITOR 	DC.B    'MONITOR441> ',0        				; command prompt input message
BUFFER  	DS.B    80                      				; input string storage          ; 103F      ; TODO: find out if 80 is length of buffer, or what else it could be
CR			EQU		$0D										; ascii code for carriage return
LF			EQU		$0A										; ascii code for line feed
HELPTEXT	DC.B	'MDSP	Memory Display',CR,LF			; ascii string with new line
			DC.B	'SORTW	Sort',CR,LF
			DC.B	'MM		Memory Modify',CR,LF
			DC.B	'MS		Memory Set',CR,LF
			DC.B	'BF		Block Fill',CR,LF
			DC.B	'BMOV	Block Move',CR,LF
			DC.B	'BSCH	Block Test',CR,LF
			DC.B	'GO		Execute Program',CR,LF
			DC.B	'DF		Display Formatted Registers',CR,LF
			DC.B	'EXIT	Exit Monitor Program',CR,LF
			DC.B	'',0
HELP_COMP	DC.B	'HELP',0
EXIT_COMP	DC.B	'EXIT',0
Q_MARK      DC.B    '? ',0


    END    START        ; last line of source




*~Font name~Courier New~
*~Font size~10~
*~Tab type~1~
*~Tab size~4~
