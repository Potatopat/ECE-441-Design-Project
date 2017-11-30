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
    MOVE.L #STACK, $0
    MOVE.L #BUS_ERR, $8
    MOVE.L #ADDR_ERR_STR, $C
    MOVE.L #ILL_INST, $10
    MOVE.L #DIV_ZERO, $14
    ;MOVE.L #CHK_INST, $18
    MOVE.L #PRIV_VIOL, $20
    MOVE.L #LINE_A, $28
    MOVE.L #LINE_F, $2C


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
    
CLR_SPACE:                ; don't think i need??
    CMP.B (A1),D2
    ADD #$01,A1
    BEQ CLR_SPACE
    
    MOVEQ   #0,D1
    SUB #$01,A1
    
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
    LEA     CMD_BUFFER,A1
    LEA     CMD_TBL,A2
    LEA     CMD_ADDR,A3

GET_CMD_LOOP:
    CMPM.B  (A1)+,(A2)+
    BNE     NEXT
    CMPI.B  #SPACE,(A1)
    BNE     GET_CMD_LOOP
    CMPI.B  #SPACE,(A2)
    BNE     CMD_ERROR
    MOVE.L  (A3),A5         ; command found     ; TODO: find out what's in (A5)
    JMP     (A5)            ; run command
    
NEXT:
    LEA     CMD_BUFFER,A1

NEXT_LOOP:
    CMPI.B  #NULL,(A2)+
    BNE     NEXT_LOOP
    ADD     #EOT,A3        ; TODO: don't think I need, but find out
    CMPA    #EXIT_COMP,A2
    BGT     CMD_ERROR
    JMP     GET_CMD_LOOP
    
GET_ARG:
    CMPI.B  #HEX,(A5)       ; checks to make sure that has a hex number as address
    ;BNE     HEX_ERROR
    MOVE    $0000,D7
    MOVE    $0000,D6
    
GET_ARG_LOOP:
    ADD     #$01,A5
    ROL.L   #4,D7
    ADD.L   D6,D7
    MOVE.B  (A5)+,D6
    CMPI.B  #$39,D6         ; if number less than 9
    BLE     DIGIT           ; easy, continue to next step
    SUBQ.B  #$07,D6         ; subtract $7 to make A=$3A, .., F=$3F
    
DIGIT:
    SUB.B   #ZERO,D6
    CMPI.B  #NULL,-(A5)
    BEQ     RETURN_ARG
    CMPI.B  #SPACE,(A5)
    BEQ     RETURN_ARG
    CMPI.B  #SEMICOLON,(A5) ; has aditional arg, return to sender and then call arg loop again
    BEQ     RETURN_ARG
    BRA     GET_ARG_LOOP
    
RETURN_ARG:
    RTS
    
GET_VALUE:
    MOVEQ   #NULL, D7
    MOVEQ   #NULL, D6
ADD_VALUE:
    MOVE.B  (A5)+, D6
    CMPI.B  #$39, D6
    BLE     NUM_VALUE
    SUBQ.B  #$07, D6
NUM_VALUE:
    SUB.B   #ZERO, D6
    ROL.L   #4, D7
    ADD.L   D6, D7
    SUB.B   #$01, D1
    CMPI.B  #NULL, D1
    BLE     RETURN_VALUE
    BRA     ADD_VALUE
RETURN_VALUE:
    RTS

    

* PSUEDOCODE:	
* check if text in ?buffer? is equal to possible commands one by one
* see http://freesource-codes.blogspot.com/2011/11/string-comparision-in-assembly-language.html
* will be super long, but entirely copy-paste


HELP:
	LEA		HELPTEXT,A1	; load helptext into a1
	MOVE.B	#14,D0		; display text
	TRAP	#15
	BRA		RETURN
	
MDSP:                   ; TODO: Fix
    LEA     OUTPUT, A2
    LEA     BUFFER, A5
    ADD     #$05, A5
    JSR     GET_ARG
    MOVE.L  D7, A2
    ADD     #$01, A5
    JSR     GET_ARG
    MOVE.L  D7, A3
    MOVEQ   #NULL, D1
    LEA     BUFFER, A1
    
NEW
    MOVE.B  #$00, (A1)
    MOVE.B  #13, D0
    TRAP    #15
    JSR     DISP_ADDR
    MOVE.W  #08, D6
    
DISP_MEM
    MOVE.B  #16, D2
    CMPA    A2, A3
    BEQ     END_DISP
    MOVE.B  (A2)+, D1
    MOVE.B  #15, D0
    TRAP    #15
    MOVE.B  #SPACE, D1
    MOVE.B  #6, D0
    TRAP    #15
    SUB     #01, D6
    BEQ     NEW
    BRA     DISP_MEM

END_DISP
    MOVE.B  #NULL, D1
    MOVE.B  #0, D0
    TRAP    #15
    JMP     PROMPT

DISP_ADDR       ;PRINT OUT THE VALUE OF A2 (USEFUL FOR MDSP AND MCHG)
    MOVE.B  #$24, D1
    MOVE    #6, D0
    TRAP    #15
    MOVE.L  A2, D0
    LEA     OUTPUT, A1
    MOVE.W  #8, D2
DISP_ADDR_2
    ROL.L   #4, D0
    MOVE.L  D0, D3
    AND.L   #$0F, D3
    CMPI.B  #$09, D3
    BLE     DISP_ADDR_3
    ADD     #$07, D3
DISP_ADDR_3
    ADD     #$30, D3
    MOVE.B  D3, (A1)+
    SUBQ.W  #1, D2
    BNE     DISP_ADDR_2
    MOVE.B  #NULL, (A1)+
    LEA     OUTPUT, A1
    MOVE.B  #14, D0
    TRAP #15
    MOVE.B	#$3A, D1
    MOVE.B	#6, D0
    TRAP	#15
    RTS


SORTW:

MM:
    LEA     INPUT,A5
    ADD     #$03,A5
    JSR     GET_ARG
    MOVE.L  D7,A2
MOD_LOOP:
	LEA     OUTPUT, A1
    JSR     DISP_ADDR
    MOVE.B  #2,D0
    TRAP    #15
    LEA		OUTPUT,A1
    CMPI.B	#$2E,(A1)
    BEQ		DONE_MOD
    CMPI.B	#2,D1
	;BNE		ARG_ERR
	LEA		OUTPUT, A5
    JSR		GET_VALUE
	MOVE.B	D7,(A2)+
	BRA		MOD_LOOP

DONE_MOD:
    BRA     RETURN

MS:

BF:
    LEA     BUFFER, A5
    ADD     #$03, A5
    JSR     GET_ARG
    MOVE.L  D7, A2
    ADD     #$01, A5
    JSR     GET_ARG
    MOVE.L  D7, A3
    MOVEQ	#00, D1
    MOVE.L	A5, A6
    ADD		#01, A6
    
GET_LENGTH:
	ADD		#01, D1
	CMPI.B	#NULL, (A6)+
	BNE		GET_LENGTH
	CMPI.B	#05, D1
	;BNE		ARG_ERR        
    JSR     GET_VALUE    ;D7 NOW STORES THE WORD WE WANT TO FILL
    
FILL_MEM:
    CMPA    A3, A2
    BGE     DONE_FILL
    MOVE.W  D7, (A2)+
    BRA     FILL_MEM

DONE_FILL:
    MOVE.B  #NULL, D1
    MOVE.B  #0, D0
    TRAP    #15
    JMP     PROMPT

BMOV:
    LEA     BUFFER,A5
    ADD     #05,A5
    JSR     GET_ARG
    MOVE.L  D7,A2
    ADD     #01,A5
    JSR     GET_ARG
    MOVE.L  D7,A3
    ADD     #01,A5
    JSR     GET_ARG
    MOVE.L  D7,A4
MOVE_MEM:
    CMPA    A3,A2
    BGE     DONE_MOVE
    MOVE.W  (A2)+,(A4)+
    BRA     MOVE_MEM
    
DONE_MOVE
    MOVE.B  #NULL,D1
    MOVE.B  #0,D0
    TRAP    #15
    JMP     RETURN


BTST:
    LEA     OUTPUT, A2
    LEA     BUFFER, A5
    ADD     #$05, A5
    JSR     GET_ARG
    MOVE.L  D7, A2
    ADD     #$01, A5
    JSR     GET_ARG
    MOVE.L  D7, A3
    MOVE.L  A2, A5      ;STORE COPY OF START LOCATION
WRITE_TEST
    CMPA    A2, A3
    BLT     DONE_WRITE
    MOVE.W  #$AAAA, (A2)+
    BRA     WRITE_TEST
DONE_WRITE
    MOVE.L  A5, A2
READ_TEST
    CMP.W   #$AAAA, (A2)
    BNE     MEM_ERR
    MOVE.W  #$AAAA, (A2)+
    CMPA    A2, A3
    BGT     READ_TEST
    
    MOVE.L  A5, A2
TEST
    CMP.W   #$AAAA, (A2)
    BNE     MEM_ERR
    MOVE.W  #$0000, (A2)+
    CMPA    A2, A3
    BGT     TEST
    LEA     GOOD, A1
    MOVE.B  #14, D0
    TRAP    #15

    
    JMP     RETURN

MEM_ERR
    LEA     MEM_ERR_STR, A1
    MOVE.B  #13, D0
    TRAP    #15
    JMP     RETURN

BSCH:

GO:	
    LEA     BUFFER,A5
    ADD     #$03,A5
    JSR     GET_ARG
    LEA     OUTPUT,A1
    MOVE.L  D7,A1       ; moves GO's arg into A7
	JMP     (A1)		; branch to location to run that program
	BRA     RETURN
    
DF:
    JSR     REG
    
    BRA     RETURN
    
    
RESET:
    MOVE.L  #NULL,A2
    MOVE.L  #$00000FFF,A3
    MOVE.L  #$FFFFFFFF,D7
    
    JMP     FILL_MEM
    
    MOVE.L  #$FFFFFFFF,D7
    MOVE.L  #$2000,A2
    MOVE.L  #$3000,A3
    
    JMP     FILL_MEM
    
    CLR.L   D0
    CLR.L   D1
    CLR.L   D2
    CLR.L   D3
    CLR.L   D4
    CLR.L   D5
    CLR.L   D6
    CLR.L   D7
    
    BRA     RETURN

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
	BRA		RETURN
	
CMD_ERROR:
    JSR     ILL_INST
    ;LEA     CMD_ERR_STR,A1  ; loads CMD_ERR_STR into A1
    ;MOVE.B	#14,D0		    ; display text
	;TRAP	#15
	BRA		RETURN
	
HEX_ERROR:
    LEA     HEX_ERR_STR,A1  ; loads HEX_ERR_STR into A1
    MOVE.B	#14,D0		    ; display text
	TRAP	#15
	BRA		RETURN
    
ARG_ERROR:
    LEA     ARG_ERR_STR,A1  ; loads ARG_ERR_STR into A1
    MOVE.B	#14,D0		    ; display text
	TRAP	#15
	BRA		RETURN

DONE:
    MOVE.B  #9,D0
    TRAP    #15         ; halt simulator
    
    
    
BUS_ERR:
    LEA     BUS_ERR_STR, A1
    MOVE.B  #13, D0
    TRAP    #15
    JMP     REG

ADDR_ERR:
    LEA     ADDR_ERR_STR, A1
    MOVE.B  #13, D0
    TRAP    #15
    JMP     REG

ILL_INST:
    LEA     ILL_INST_STR, A1
    MOVE.B  #13, D0
    TRAP    #15
    JMP     REG

DIV_ZERO:
    LEA     DIV0_ERR_STR, A1
    MOVE.B  #13, D0
    TRAP    #15
    JMP     REG

PRIV_VIOL:
    LEA     PRIV_VIOL_STR, A1
    MOVE.B  #13, D0
    TRAP    #15
    JMP     REG

TRACE:
    LEA     TRACE_STR,A1
    MOVE.B  #13,D0
    TRAP    #15
    JMP     REG

LINE_A:
    LEA     LINE_A_STR,A1
    MOVE.B  #13,D0
    TRAP    #15
    JMP     REG

LINE_F:
    LEA     LINE_F_STR,A1
    MOVE.B  #13,D0
    TRAP    #15
    JMP     REG
    
REG:
    LEA     STACK,A7
    MOVEM.L D0-D7/A0-A7,-(A7)
    MOVEQ   #00,D5
    
NXT_REG:
    LEA     RGSTR_STR,A1
    ADD     D5,A1
    ADD     #$03,D5
    MOVE.W  #03,D1
    MOVE.B  #01,D0
    TRAP    #15
    LEA     OUTPUT,A1
    MOVE.W  #8, D2
    MOVE.L  (A7)+,D0
    
NXT_DIG:
    ROL.L   #4,D0
    MOVE.L  D0,D3
    AND.L   #$0F,D3
    CMPI.B  #$09,D3
    BLE     LESS
    ADD     #$07,D3
LESS:
    ADD     #$30,D3
    MOVE.B  D3,(A1)+
    SUBQ.W  #1,D2
    BNE     NXT_DIG
    
    MOVE.B  #$00,(A1)+
    LEA     OUTPUT,A1
    MOVE.B  #13,D0
    TRAP    #15
    CMPA    #STACK,A7
    BLT     NXT_REG   
    
SR:
	LEA		STACK,A7
	MOVE	SR,-(A7)
	LEA		SR_STR,A1
	MOVE.B	#14,D0
	TRAP	#15
	LEA		OUTPUT,A1
	MOVE.W	#4,D2
	MOVE.L	(A7)+,D0
NXT_SR:
    ROL.L   #4,D0
    MOVE.L  D0,D3
    AND.L   #$0F,D3
    CMPI.B  #$09,D3
    BLE     LESS_SR
    ADD     #$07,D3
LESS_SR:
    ADD     #$30,D3
    MOVE.B  D3,(A1)+
    SUBQ.W  #1,D2
    BNE     NXT_SR
    MOVE.B  #$00,(A1)+
    LEA     OUTPUT,A1
    MOVE.B  #13,D0
    TRAP    #15
    JMP     PROMPT


SWAP:
    LEA     INPUT,A5
    ADD     #05,A5
    JSR     GET_ARG
    MOVE.L  D7,A2
    ADD     #01,A5
    JSR     GET_ARG
    MOVE.L  D7,A3
    ADD     #01,A5
    CMPI.B  #$42,(A5)       ; if has 'B' for byte
    BEQ     SWAP_BYTE
    CMPI.B  #$57,(A5)       ; if has 'W' for word
    BEQ     SWAP_WORd
    CMPI.B  #$4C,(A5)       ; if has 'L' for long
    BEQ     SWAP_LONG
    JMP     ARG_ERR_STR
    
SWAP_BYTE:
    MOVE.B  (A2),D1
    MOVE.B  (A3),(A2)
    MOVE.B  D1,(A3)
    BRA     RETURN
SWAP_WORD:
    MOVE.W  (A2),D1
    MOVE.W  (A3),(A2)
    MOVE.W  D1,(A3)
    BRA     RETURN
SWAP_LONG:
    MOVE.L  (A2),D1
    MOVE.L  (A3),(A2)
    MOVE.L  D1,(A3)
    BRA     RETURN


DIVZ:
    CLR.L   D0
    CLR.L   D1
    DIVU    D0,D1
    BRA RETURN

    
    

    SIMHALT             ; halt simulator

* Put variables and constants here

MONITOR 	DC.B    'MONITOR441> ',0        				; command prompt input message
BUFFER      EQU     $2100                                   ; input string storage
CMD_BUFFER  EQU     $2200
OUTPUT      EQU     $2300
CR			EQU		$0D										; ascii code for carriage return
LF			EQU		$0A										; ascii code for line feed
CMD_TBL     DC.B    'HELP ',0
            DC.B    'MDSP ',0
            DC.B    'SORTW ',0
            DC.B    'SWAP ',0
            DC.B    'MM ',0
            DC.B    'MS ',0
            DC.B    'BF ',0
            DC.B    'BMOV ',0
            DC.B    'BTST ',0
            DC.B    'BSCH ',0
            DC.B    'GO ',0
            DC.B    'DF ',0
            DC.B    'RESET ',0
            DC.B    'DIVZ ',0
CMD_ADDR    DC.L    HELP
            DC.L    MDSP
            DC.L    SORTW
            DC.L    SWAP
            DC.L    MM
            DC.L    MS
            DC.L    BF
            DC.L    BMOV
            DC.L    BTST
            DC.L    BSCH
            DC.L    GO
            DC.L    DF
            DC.L    RESET
            DC.L    EXIT
            DC.L    DIVZ
HELPTEXT	DC.B	'MDSP	   Memory Display (MDSP $ONE $TWO) or (MDSP $ONE)',CR,LF		; ascii string with new line
			DC.B	'SORTW       Sort (SORT $START $END)',CR,LF
			DC.B	'MM		Memory Modify (MM $ADDRESS) then ($DATA) until (.)',CR,LF
			DC.B	'MS		Memory Set (MS $ADDRESS DATA)',CR,LF
			DC.B	'BF		Block Fill (BF $START $END ####)',CR,LF
			DC.B	'BMOV	   Block Move (BMOV $ONE $TWO)',CR,LF
			DC.B	'BTST	   Block Test (BTST $ONE TWO)',CR,LF
			DC.B    'BSCH      Block Search (BSCH $ONE TWO)',CR,LF
			DC.B	'GO		Execute Program (GO $ADDRESS)',CR,LF
			DC.B	'DF		Display Formatted Registers (DF)',CR,LF
			DC.B	'SWAP	   Swap the data of two registers with length (SWAP $ONE $TWO;B/W/L)',CR,LF
			DC.B    'RESET      Clears nonoperative registers to origional state (RESET )',CR,LF
            DC.B	'EXIT	   Exit Monitor Program (EXIT)',CR,LF
			DC.B	'',0
HELP_COMP	DC.B	'HELP',0
EXIT_COMP	DC.B	'EXIT',0
Q_MARK      DC.B    '? ',0
EMPTY_STR   DC.B    'YOU HAD AN EMPTY STRING',0
CMD_ERR_STR DC.B    'NOT VALID',CR,LF
			DC.B	'',0
HEX_ERR_STR DC.B    'NEEDS TO BE A HEXADECIMAL NUMBER. BEGIN ARG WITH "$"',0
ARG_ERR_STR DC.B    'ARGUMENT ERROR. LIKELY A NON HEX NUMBER',0
SPACE       EQU     $20
NULL        EQU     $00
EOT         EQU     $04
HEX         EQU     $24
ZERO        EQU     $30
SEMICOLON   EQU     $3B
STACK       EQU     $3000
RGSTR_STR   DC.B    'D0=D1=D2=D3=D4=D5=D6=D7=A0=A1=A2=A3=A4=A5=A6=A7='
BUS_ERR_STR DC.B    'BUS ERROR',$0A,$0D,0
ADDR_ERR_STR
            DC.B    'ADDRESS ERROR',LF,CR,0    
ILL_INST_STR
            DC.B    'NOT VALID INSTRUCTION',LF,CR,0
DIV0_ERR_STR
            DC.B    'DIVIDE BY ZERO ERROR',LF,CR,0
PRIV_VIOL_STR
            DC.B    'PRIVILEGE VIOLATION',0
TRACE_STR   DC.B    'TRACE EXCEPTION',0
LINE_A_STR  DC.B    'LINE A EXCEPTION',0
LINE_F_STR  DC.B    'LINE F EXCEPTION',0
MEM_ERR_STR DC.B    'ERROR IN MEMORY AT: ',0
SR_STR      DC.B	'SR=',0
GOOD        DC.B    'NO ERROR DETECTED',LF,CR,0

    END    START        ; last line of source
*~Font name~Courier New~
*~Font size~10~
*~Tab type~1~
*~Tab size~4~
