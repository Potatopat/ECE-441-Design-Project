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
    CLR.L   D2
    CLR.L   D3
    CLR.L   D4
    CLR.L   D5
    CLR.L   D6
    CLR.L   D7
    
* see http://www.easy68k.com/QuickStart/Hello%20World%20Program%203.txt

INIT:
    * Do eception vector table here *
    * MOVE.L #STACK, $0 ; etc.

PROMPT:
	LEA     MONITOR,A1  ; gives command prompt
	MOVE.B  #14,D0      ; stores result in D0
	TRAP    #15
    
INPUT:
	LEA     BUFFER,A1
    MOVE.B  #2,D0       ; trap task 2 does the following:
    TRAP    #15         ; read a string from the keyboard into A1 of length stored at D1.W
    CMP.W   #0,D1       ; compares D1 to the number 0 to see if not empty
    BEQ     EMPTY       ; branch EMPTY if they are equal
    
PARSE:
    LEA     BUFFER,A1
    MOVE.B  #SPACE,D2
    
CLR_SPC:                ; don't think i need??
    ;CMP.B (A1), D2
    ;ADD #$01, A1
    ;BEQ CLR_SPC
    
    MOVEQ   #0, D1
    ;SUB #$01, A1
    
    LEA     CMD_BUFFER,A2

COPY_CMD:
    MOVE    (A1)+,(A2)+
    ADDI    #1,D1
    CMPI    #8,D1
    BGE     CMD_ERROR
    CMPI.B  #SPACE,(A1)
    BEQ     GET_CMD
    CMPI.B  #NULL,(A1)
    BEQ     GET_CMD
    BRA     COPY_CMD
    
GET_CMD:
    MOVE.B  #SPACE,(A2)
    LEA     CMD_TBL,A1
    LEA     CMD_BUFFER,A2
    LEA     CMD_ADDR,A3

GET_CMD_LOOP:
    CMPM.B  (A2)+,(A1)+
    BNE     NEXT
    CMPI.B  #SPACE,(A2)
    BNE     GET_CMD_LOOP
    CMPI.B  #SPACE,(A1)
    BNE     CMD_ERROR
    MOVE.L  (A3),A4         ; command found     ; TODO: find out what's in (A4)
    JMP     (A4)            ; run command
    
NEXT:
    LEA     CMD_BUFFER,A2

NEXT_LOOP:
    CMPI.B  #NULL,(A1)+
    BNE     NEXT_LOOP
    ;ADD     #EOT,A3        ; TODO: don't think I need, but find out
    CMPA    #EXIT,A1
    BGT     CMD_ERROR
    JMP     GET_CMD_LOOP
    
GET_ARG:
    CMPI.B  #HEX,(A5)

* PSUEDOCODE:	
* check if text in ?buffer? is equal to possible commands one by one
* see http://freesource-codes.blogspot.com/2011/11/string-comparision-in-assembly-language.html
* will be super long, but entirely copy-paste


HELP:
	LEA		HELPTEXT,A1	; load helptext into a1
	MOVE.B	#14,D0		; display text
	TRAP	#15
	BRA		RETURN
	
MDSP:

SORTW:

MM:

MS:

BF:

BMOV:

BTST:

BSCH:

GO:
	* TODO: load branching address into A7 during string parsing
	* TODO: make sure it is valid memory address via BGE, BLE, etc.
	
    LEA     BUFFER,A6
    ;ADD     #$03,A6       ; why #$03 (End-Of-Text)
    JSR     GET_ARG
    LEA     OUTPUT,A7
    MOVE.L  D7,A7       ; moves GO's arg into A7
	JMP     (A7)		; branch to location to run that program
    
DF:

EXIT:
	BRA		DONE
	
RETURN:
    ;MOVE.B  #14,D0      ; go back to monitor
    ;TRAP    #15
    BRA     PROMPT

EMPTY:
    LEA		EMPTY_STR,A1    ; loads EMPTY_STR into A1
	MOVE.B	#14,D0		    ; display text
	TRAP	#15
	BRA		DONE            ; TODO: Maybe not branch to done?
	
CMD_ERROR:
    LEA     CMD_ERR_STR,A1  ; loads CMD_ERR_STR into A1
    MOVE.B	#14,D0		    ; display text
	TRAP	#15
	BRA		DONE
    
DONE:
    MOVE.B  #9,D0
    TRAP    #15         ; halt simulator
    
    

    SIMHALT             ; halt simulator

* Put variables and constants here

MONITOR 	DC.B    'MONITOR441> ',0        				; command prompt input message
BUFFER      EQU     $2100                                   ; input string storage
CMD_BUFFER  EQU     $2200
OUTPUT      EQU     $2300
CR			EQU		$0D										; ascii code for carriage return
LF			EQU		$0A										; ascii code for line feed
HELPTEXT	DC.B	'MDSP	   Memory Display',CR,LF		; ascii string with new line
			DC.B	'SORTW       Sort',CR,LF
			DC.B	'MM		Memory Modify',CR,LF
			DC.B	'MS		Memory Set',CR,LF
			DC.B	'BF		Block Fill',CR,LF
			DC.B	'BMOV	   Block Move',CR,LF
			DC.B	'BSCH	   Block Test',CR,LF
			DC.B	'GO		Execute Program',CR,LF
			DC.B	'DF		Display Formatted Registers',CR,LF
			DC.B	'EXIT	   Exit Monitor Program',CR,LF
			DC.B	'',0
CMD_TBL     DC.B    'HELP ',0
            DC.B    'MDSP ',0
            DC.B    'SORTW ',0
            DC.B    'MM ',0
            DC.B    'MS ',0
            DC.B    'BF ',0
            DC.B    'BMOV ',0
            DC.B    'BTST ',0
            DC.B    'BSCH ',0
            DC.B    'GO ',0
            DC.B    'DF ',0
CMD_ADDR    DC.L    HELP
            DC.L    MDSP
            DC.L    SORTW
            DC.L    MM
            DC.L    MS
            DC.L    BF
            DC.L    BMOV
            DC.L    BTST
            DC.L    BSCH
            DC.L    GO
            DC.L    DF
            DC.L    EXIT
HELP_COMP	DC.B	'HELP',0
EXIT_COMP	DC.B	'EXIT',0
Q_MARK      DC.B    '? ',0
EMPTY_STR   DC.B    'YOU HAD AN EMPTY STRING',0
CMD_ERR_STR DC.B    'NOT VALID',0
SPACE       EQU     $20
NULL        EQU     $00
EOT         EQU     $04
HEX         EQU     $24


    END    START        ; last line of source







*~Font name~Courier New~
*~Font size~10~
*~Tab type~1~
*~Tab size~4~
