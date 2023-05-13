; 8086 assembly program to print a random number between 1-9 if user input is 'b' or 'B'
; the program never repeats the same number twice
; this problem is solved by storing the previous number in a text file
; the program then overwrites this number with the newly generated random number



; MAIN PROGRAM

org 100h


tryagain:

; TRY TO OPEN FILE "textfile.txt"
MOV AH,3DH
LEA DX,fname
MOV AL,2
INT 21H
JC create  ; if file does not exist, create it and try to open it again.
MOV fhandle,AX


MOV DX, OFFSET MSG1 ; 
MOV AH, 9           ; print MSG1
INT 21H             ;

MOV AH,1 ; get user input
INT 21H  ;


CMP AL,66 ; B
JE RAND

CMP AL,98 ; b
JE RAND


continue:


;CLOSE FILE
MOV AH,3EH
MOV BX,fhandle
INT 21H


;EXIT                           
MOV AH,4CH
INT 21H


ret  ; END OF PROGRAM



; LABELS 


RAND:

MOV DX, OFFSET MSG2 ; 
MOV AH, 9           ; print MSG2
INT 21H             ;


; READ FROM FILE
MOV AH,3FH
LEA DX,buffer
MOV CX,size
MOV BX,fhandle
INT 21H

MOV CL, buffer[0] ; Get previous number and save it to CL

;CLOSE FILE
MOV AH,3EH     ;
MOV BX,fhandle ; not closing the file and reopening it caused bugs in the program
INT 21H        ; not sure why.

; REOPEN IT
MOV AH,3DH
LEA DX,fname
MOV AL,2
INT 21H
JC create
MOV fhandle,AX


MOV BL,CL      ; Now move the previous number to BL
               ; since CL is going to be used to generate a random number
               

again: ; generate random number

MOV AH, 00h  ; interrupts to get system time        
INT 1AH      ; CX:DX now hold number of clock ticks since midnight      

mov  ax, dx
xor  dx, dx
mov  cx, 9    
div  cx      ; here dx contains the remainder of the division - from 0 to 8

add  dl, '0'  ; to ascii from '0' to '8'
INC DL        ; Increment DL to change the range to 1-9

CMP DL, BL   ; looping mechanism
JE again     ; if generated random number is equal to the previous number, generate again.

mov ah, 2h   ; call interrupt to display a value in DL
int 21h


MOV [197],BL ; Store previous random number in [197]      


; OVERWRITE DATA TO FILE
MOV CX,0
MOV buffer[0],DL
INC CX 
                       
MOV AH,40H
MOV BX,fhandle
LEA DX,buffer
INT 21H


MOV DX, OFFSET MSG3  ;
MOV AH,9             ; print MSG3
INT 21H              ;

CMP [197],24H ;
JE none       ; if there is no previous number print "None"

; else print the previous number

MOV AH,2
MOV DL,[197]
INT 21H


JMP continue ; continue on to close the file and exit the program    


create:

    ; CREATE FILE
    MOV AH,3CH
    LEA DX,fname
    MOV CL,0
    INT 21H
    MOV fhandle,ax
    
JMP tryagain


none:

    MOV DX, OFFSET MSG4 ;
    MOV AH,9            ; print "None"
    INT 21H             ;
    
JMP continue
 


; FINAL VARIABLES

fname DB "textfile.txt",0
fhandle DW ?
size dw 1 ; we only need 1 char of data
buffer db size dup("$")

MSG1 DB "User input: $"
MSG2 DB 10,13,"Random number between (1-9): $"  ; use "10,13" for a new line
MSG3 DB 10,13,"Previous random number: $"
MSG4 DB "None$"

