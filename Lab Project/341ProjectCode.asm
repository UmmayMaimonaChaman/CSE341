.MODEL SMALL
.STACK 100H
.DATA
; data arrays for user logins (passwords)
array1 DW 101,102,103,104,105,106,107,108,109,110,111,112,113,114,115,116,117,118,119,120,121,122,123,124,125,126,127,128,129,130  ; audience array (passwords: 101-130)
array2 DW 201,202,203,204,205,206,207,208,209,210,211,212,213,214,215,216,217,218,219,220  ; contestants array (passwords: 201-220)
array3 DW 301,302,303,304,305  ; judges array (passwords: 301-305)
adminPassword DW 10            ; admin password is 10

; counter variables
voteCount1 DB 0       ; votes for contestant 1
voteCount2 DB 0       ; votes for contestant 2
voteCount3 DB 0       ; votes for contestant 3
totalVotes DB 0       ; total votes cast

; weighted vote counters
weightedVote1 DW 0    ; weighted votes for contestant 1
weightedVote2 DW 0    ; weighted votes for contestant 2
weightedVote3 DW 0    ; weighted votes for contestant 3
totalWeightedVotes DW 0 ; total weighted votes

; user counter variables
userCount1 DB 0       ; audience count
userCount2 DB 0       ; contestant count
userCount3 DB 0       ; judge count
largestVote DB 0      ; tracks highest vote count

; vote weights
spectatorWeight DB 1  ; Spectator vote weight: 1 point
contestantWeight DB 2 ; Contestant vote weight: 2 points
judgeWeight DB 3      ; Judge vote weight: 3 points

; messages
welcomeMsg DB 'Electo Finale Round Voting$'
menuMsg DB '1.Spectator 2.OtherContestant 3.Judges 4.Admin 5. Exit$'
loginMsg DB 'Enter Your Login: $'
invalidUserMsg DB 'Invalid user$'
invalidOptionMsg DB 'Invalid option$'
validAudienceMsg DB 'Valid user/Audience$'
validContestantMsg DB 'Valid user/Contestant$'
validJudgeMsg DB 'Valid user/Judge$'
votePromptMsg DB 'Vote for the Contestant$'
voteOptionsMsg DB '1. Con1  2. Con2  3. Con3$'
passwordPrompt DB 'Enter Password: $'
incorrectPasswordMsg DB 'Incorrect Admin Login Password.Try Again$'
summaryMsg DB 'Summary$'
individualVotesMsg DB 'Individual votes$'
contestant1Msg DB 'Con1$'
contestant2Msg DB 'Con2$'
contestant3Msg DB 'Con3$'
votesMsg DB 'Votes: $'
audienceMsg DB 'Audience$'
contestantsMsg DB 'Other Contestants$'
judgesMsg DB 'Judges$'
totalVotesMsg DB 'Total votes received: $'
adminMenuMsg DB '1. Summary 2. Check_Proceed 3.Back$'
winner1Msg DB 'Election Winner :: Contestant 1$'
winner2Msg DB 'Election Winner :: Contestant 2$'
winner3Msg DB 'Election Winner :: Contestant 3$'
newLine DB 0DH, 0AH, '$'  ; carriage return, line feed
pressKeyMsg DB 10,13,'Press any key to return...$' ; New message for returning

; New weighted vote messages
weightedVotesTitle DB 'Weighted Votes$'
weightedVotesMsg DB 'Weighted votes: $'
weightInfoMsg DB 'Vote Weights: Spectator=1, Contestant=2, Judge=3$'
totalWeightedVotesMsg DB 'Total weighted votes: $'

.CODE
MAIN PROC
    ; initialize DS
    MOV AX, @DATA
    MOV DS, AX

    ; start of the program
    ;
    JMP MainMenu

MainMenu:
    ; Display welcome message
    LEA DX, welcomeMsg
    CALL DisplayMsg

    ; Display new lines
    LEA DX, newLine
    CALL DisplayMsg
    LEA DX, newLine
    CALL DisplayMsg

    ; Display menu options
    LEA DX, menuMsg
    CALL DisplayMsg
    LEA DX, newLine
    CALL DisplayMsg

    ; Get user choice
    CALL GetInput

    ; Process user choice
    CMP AL, '1'
    JE SpectatorSection
    CMP AL, '2'
    JE ContestantSection
    CMP AL, '3'
    JE JudgesSection
    CMP AL, '4'
    JE AdminSection
    CMP AL, '5'
    JE ExitProgram

    ; Invalid choice
    LEA DX, invalidOptionMsg
    CALL DisplayMsg
    JMP MainMenu
ExitProgram:
    MOV AH, 4CH
    INT 21H

; Spectator Section
SpectatorSection:

    LEA DX, loginMsg
    CALL DisplayMsg

    CALL GetNumberInput  ; Get multi-digit input

    MOV CX, 30      ; Loop counter for array1
    LEA SI, array1  ; Load array1 address

CheckSpectator:
    MOV BX, [SI]    ; Load value from array
    CMP AX, BX      ; Compare with input
    JE ValidSpectator
    ADD SI, 2       ; Move to next element
    LOOP CheckSpectator

    ; Invalid user
    LEA DX, invalidUserMsg
    CALL DisplayMsg
    JMP MainMenu

ValidSpectator:
    INC userCount1  ; Increment audience count
    LEA DX, validAudienceMsg
    CALL DisplayMsg

    JMP VoteSpectator

; Contestant Section
ContestantSection:

    LEA DX, loginMsg
    CALL DisplayMsg

    CALL GetNumberInput  ; Get multi-digit input

    MOV CX, 20      ; Loop counter for array2
    LEA SI, array2  ; Load array2 address

CheckContestant:
    MOV BX, [SI]    ; Load value from array
    CMP AX, BX      ; Compare with input
    JE ValidContestant
    ADD SI, 2       ; Move to next element
    LOOP CheckContestant

    ; Invalid user
    LEA DX, invalidUserMsg
    CALL DisplayMsg
    JMP MainMenu

ValidContestant:
    INC userCount2  ; Increment contestant count
    LEA DX, validContestantMsg
    CALL DisplayMsg

    JMP VoteContestant

; Judges Section
JudgesSection:

    LEA DX, loginMsg
    CALL DisplayMsg

    CALL GetNumberInput  ; Get multi-digit input

    CMP AX, 0       ; Check if input is 0
    JE ExitJudge

    MOV CX, 5       ; Loop counter for array3
    LEA SI, array3  ; Load array3 address

CheckJudge:
    MOV BX, [SI]    ; Load value from array
    CMP AX, BX      ; Compare with input
    JE ValidJudge
    ADD SI, 2       ; Move to next element
    LOOP CheckJudge

    ; Invalid user
    LEA DX, invalidUserMsg
    CALL DisplayMsg
    JMP JudgesSection

ExitJudge:
    LEA DX, invalidUserMsg
    CALL DisplayMsg
    JMP JudgesSection

ValidJudge:
    INC userCount3  ; Increment judge count
    LEA DX, validJudgeMsg
    CALL DisplayMsg

    JMP VoteJudge
;-------------------------------------feature3---------------------------------
; Voting section for spectators
VoteSpectator:
    MOV BYTE PTR [SI], 0  ; Mark user as voted
    LEA DX, votePromptMsg
    CALL DisplayMsg

    LEA DX, newLine
    CALL DisplayMsg
    LEA DX, newLine
    CALL DisplayMsg

    LEA DX, voteOptionsMsg
    CALL DisplayMsg

    CALL GetInput

    CMP AL, '1'
    JE Vote1Spectator
    CMP AL, '2'
    JE Vote2Spectator
    CMP AL, '3'
    JE Vote3Spectator

    LEA DX, invalidOptionMsg
    CALL DisplayMsg
    JMP VoteSpectator

; Voting section for contestants
VoteContestant:
    MOV WORD PTR [SI], 0  ; Mark user as voted
    LEA DX, votePromptMsg
    CALL DisplayMsg

    LEA DX, newLine
    CALL DisplayMsg
    LEA DX, newLine
    CALL DisplayMsg

    LEA DX, voteOptionsMsg
    CALL DisplayMsg

    CALL GetInput

    CMP AL, '1'
    JE Vote1Contestant
    CMP AL, '2'
    JE Vote2Contestant
    CMP AL, '3'
    JE Vote3Contestant

    LEA DX, invalidOptionMsg
    CALL DisplayMsg
    JMP VoteContestant

; Voting section for judges
VoteJudge:
    MOV BYTE PTR [SI], 0  ; Mark user as voted
    LEA DX, votePromptMsg
    CALL DisplayMsg

    LEA DX, newLine
    CALL DisplayMsg
    LEA DX, newLine
    CALL DisplayMsg

    LEA DX, voteOptionsMsg
    CALL DisplayMsg

    CALL GetInput

    CMP AL, '1'
    JE Vote1Judge
    CMP AL, '2'
    JE Vote2Judge
    CMP AL, '3'
    JE Vote3Judge

    LEA DX, invalidOptionMsg
    CALL DisplayMsg
    JMP VoteJudge

;-------------------------------------feature4---------------------------------
; Register spectator vote for contestant 1 (weight 1)
Vote1Spectator:
    INC voteCount1          ; Increment contestant 1 votes
    INC totalVotes          ; Increment total votes

    ; Add weighted vote (spectator = 1)
    MOV AL, spectatorWeight
    MOV AH, 0               
    ADD weightedVote1, AX   ; Add weighted vote to contestant 1
    ADD totalWeightedVotes, AX ; Add to total weighted votes

    JMP MainMenu

; Register spectator vote for contestant 2 (weight 1)
Vote2Spectator:
    INC voteCount2          ; Increment contestant 2 votes
    INC totalVotes          ; Increment total votes

    ; Add weighted vote (spectator = 1)
    MOV AL, spectatorWeight
    MOV AH, 0               ; Clear high byte for 16-bit addition
    ADD weightedVote2, AX   ; Add weighted vote to contestant 2
    ADD totalWeightedVotes, AX ; Add to total weighted votes

    JMP MainMenu

; Register spectator vote for contestant 3 (weight 1)
Vote3Spectator:
    INC voteCount3          ; Increment contestant 3 votes
    INC totalVotes          ; Increment total votes

    ; Add weighted vote (spectator = 1)
    MOV AL, spectatorWeight
    MOV AH, 0               ; Clear high byte for 16-bit addition
    ADD weightedVote3, AX   ; Add weighted vote to contestant 3
    ADD totalWeightedVotes, AX ; Add to total weighted votes

    JMP MainMenu

; Register contestant vote for contestant 1 (weight 2)
Vote1Contestant:
    INC voteCount1          ; Increment contestant 1 votes
    INC totalVotes          ; Increment total votes

    ; Add weighted vote (contestant = 2)
    MOV AL, contestantWeight
    MOV AH, 0               ; Clear high byte for 16-bit addition
    ADD weightedVote1, AX   ; Add weighted vote to contestant 1
    ADD totalWeightedVotes, AX ; Add to total weighted votes

    JMP MainMenu

; Register contestant vote for contestant 2 (weight 2)
Vote2Contestant:
    INC voteCount2          ; Increment contestant 2 votes
    INC totalVotes          ; Increment total votes

    ; Add weighted vote (contestant = 2)
    MOV AL, contestantWeight
    MOV AH, 0               ; Clear high byte for 16-bit addition
    ADD weightedVote2, AX   ; Add weighted vote to contestant 2
    ADD totalWeightedVotes, AX ; Add to total weighted votes

    JMP MainMenu

; Register contestant vote for contestant 3 (weight 2)
Vote3Contestant:
    INC voteCount3          ; Increment contestant 3 votes
    INC totalVotes          ; Increment total votes

    ; Add weighted vote (contestant = 2)
    MOV AL, contestantWeight
    MOV AH, 0               ; Clear high byte for 16-bit addition
    ADD weightedVote3, AX   ; Add weighted vote to contestant 3
    ADD totalWeightedVotes, AX ; Add to total weighted votes

    JMP MainMenu

; Register judge vote for contestant 1 (weight 3)
Vote1Judge:
    INC voteCount1          ; Increment contestant 1 votes
    INC totalVotes          ; Increment total votes

    ; Add weighted vote (judge = 3)
    MOV AL, judgeWeight
    MOV AH, 0               ; Clear high byte for 16-bit addition
    ADD weightedVote1, AX   ; Add weighted vote to contestant 1
    ADD totalWeightedVotes, AX ; Add to total weighted votes

    JMP MainMenu

; Register judge vote for contestant 2 (weight 3)
Vote2Judge:
    INC voteCount2          ; Increment contestant 2 votes
    INC totalVotes          ; Increment total votes

    ; Add weighted vote (judge = 3)
    MOV AL, judgeWeight
    MOV AH, 0               ; Clear high byte for 16-bit addition
    ADD weightedVote2, AX   ; Add weighted vote to contestant 2
    ADD totalWeightedVotes, AX ; Add to total weighted votes

    JMP MainMenu

; Register judge vote for contestant 3 (weight 3)
Vote3Judge:
    INC voteCount3          ; Increment contestant 3 votes
    INC totalVotes          ; Increment total votes

    ; Add weighted vote (judge = 3)
    MOV AL, judgeWeight
    MOV AH, 0               ; Clear high byte for 16-bit addition
    ADD weightedVote3, AX   ; Add weighted vote to contestant 3
    ADD totalWeightedVotes, AX ; Add to total weighted votes

    JMP MainMenu

; Admin Section
AdminSection:

    LEA DX, passwordPrompt
    CALL DisplayMsg

    CALL GetNumberInput  ; Get multi-digit input

    CMP AX, 10      ; Check password (10)
    JNE IncorrectPassword

    JMP AdminMenu

IncorrectPassword:
    LEA DX, incorrectPasswordMsg
    CALL DisplayMsg
    JMP MainMenu

AdminMenu:

    LEA DX, adminMenuMsg
    CALL DisplayMsg

    CALL GetInput

    CMP AL, '1'
    JE ShowSummary
    CMP AL, '2'
    JE FindWinner
    CMP AL, '3'
    JE MainMenu

    LEA DX, invalidOptionMsg
    CALL DisplayMsg
    JMP AdminMenu

AdminMenuScreen:

    LEA DX, adminMenuMsg
    CALL DisplayMsg
    LEA DX, newLine
    CALL DisplayMsg

    CALL GetInput

    CMP AL, '1'
    JE ShowSummary
    CMP AL, '2'
    JE FindWinner
    CMP AL, '3'
    JE MainMenu      ; Back to Main Menu

    LEA DX, invalidOptionMsg
    CALL DisplayMsg
    CALL Delay
    JMP AdminMenuScreen

; Show voting summary
ShowSummary:

    LEA DX, summaryMsg
    CALL DisplayMsg

    LEA DX, newLine
    CALL DisplayMsg

    ; Display vote weight information
    LEA DX, weightInfoMsg
    CALL DisplayMsg

    LEA DX, newLine
    CALL DisplayMsg
    LEA DX, newLine
    CALL DisplayMsg

    ; Regular Votes Section
    LEA DX, individualVotesMsg
    CALL DisplayMsg

    LEA DX, newLine
    CALL DisplayMsg

    ; Display contestant 1 votes
    LEA DX, contestant1Msg
    CALL DisplayMsg
    LEA DX, votesMsg
    CALL DisplayMsg

    MOV DL, voteCount1
    ADD DL, 48      ; Convert to ASCII
    MOV AH, 02H     ; Display character
    INT 21H

    LEA DX, newLine
    CALL DisplayMsg

    ; Display contestant 2 votes
    LEA DX, contestant2Msg
    CALL DisplayMsg
    LEA DX, votesMsg
    CALL DisplayMsg

    MOV DL, voteCount2
    ADD DL, 48      ; Convert to ASCII
    MOV AH, 02H     ; Display character
    INT 21H

    LEA DX, newLine
    CALL DisplayMsg

    ; Display contestant 3 votes
    LEA DX, contestant3Msg
    CALL DisplayMsg
    LEA DX, votesMsg
    CALL DisplayMsg

    MOV DL, voteCount3
    ADD DL, 48      ; Convert to ASCII
    MOV AH, 02H     ; Display character
    INT 21H

    LEA DX, newLine
    CALL DisplayMsg

    ; Display audience count
    LEA DX, audienceMsg
    CALL DisplayMsg
    LEA DX, votesMsg
    CALL DisplayMsg

    MOV DL, userCount1
    ADD DL, 48      ; Convert to ASCII
    MOV AH, 02H     ; Display character
    INT 21H

    LEA DX, newLine
    CALL DisplayMsg

    ; Display contestant count
    LEA DX, contestantsMsg
    CALL DisplayMsg
    LEA DX, votesMsg
    CALL DisplayMsg

    MOV DL, userCount2
    ADD DL, 48      ; Convert to ASCII
    MOV AH, 02H     ; Display character
    INT 21H

    LEA DX, newLine
    CALL DisplayMsg

    ; Display judge count
    LEA DX, judgesMsg
    CALL DisplayMsg
    LEA DX, votesMsg
    CALL DisplayMsg

    MOV DL, userCount3
    ADD DL, 48      ; Convert to ASCII
    MOV AH, 02H     ; Display character
    INT 21H

    LEA DX, newLine
    CALL DisplayMsg

    ; Display total votes
    LEA DX, totalVotesMsg
    CALL DisplayMsg

    MOV DL, totalVotes
    ADD DL, 48      ; Convert to ASCII
    MOV AH, 02H     ; Display character
    INT 21H

    LEA DX, newLine
    CALL DisplayMsg
    LEA DX, newLine
    CALL DisplayMsg

    ; Weighted Votes Section
    LEA DX, weightedVotesTitle
    CALL DisplayMsg

    LEA DX, newLine
    CALL DisplayMsg

    ; Display contestant 1 weighted votes
    LEA DX, contestant1Msg
    CALL DisplayMsg
    LEA DX, weightedVotesMsg
    CALL DisplayMsg

    ; Display weighted vote (2-digit number)
    MOV AX, weightedVote1
    CALL DisplayNumber

    LEA DX, newLine
    CALL DisplayMsg

    ; Display contestant 2 weighted votes
    LEA DX, contestant2Msg
    CALL DisplayMsg
    LEA DX, weightedVotesMsg
    CALL DisplayMsg

    ; Display weighted vote (2-digit number)
    MOV AX, weightedVote2
    CALL DisplayNumber

    LEA DX, newLine
    CALL DisplayMsg

    ; Display contestant 3 weighted votes
    LEA DX, contestant3Msg
    CALL DisplayMsg
    LEA DX, weightedVotesMsg
    CALL DisplayMsg

    ; Display weighted vote (2-digit number)
    MOV AX, weightedVote3
    CALL DisplayNumber

    LEA DX, newLine
    CALL DisplayMsg

    ; Display total weighted votes
    LEA DX, totalWeightedVotesMsg
    CALL DisplayMsg

    ; Display total weighted votes (2-digit number)
    MOV AX, totalWeightedVotes
    CALL DisplayNumber

    LEA DX, newLine
    CALL DisplayMsg

    ; Prompt to return
    LEA DX, pressKeyMsg
    CALL DisplayMsg
    CALL GetInput ; Wait for key press (GetInput now preserves AL)
    JMP AdminMenuScreen

; Find the winner - now using weighted votes
FindWinner:
    ; Compare contestant 1 and contestant 2 weighted votes
    MOV AX, weightedVote1
    MOV BX, weightedVote2

    CMP AX, BX
    JGE CheckContestant3WithContestant1

    ; Contestant 2 has more weighted votes than contestant 1
    MOV AX, weightedVote2
    JMP CheckContestant3WithCurrent

CheckContestant3WithContestant1:
    ; AX already has weightedVote1
    JMP CheckContestant3WithCurrent

CheckContestant3WithCurrent:
    ; AX has the highest weighted vote count so far
    MOV BX, weightedVote3
    CMP AX, BX
    JGE DetermineWinner

    ; Contestant 3 has the most weighted votes
    MOV AX, weightedVote3

DetermineWinner:
    ; AX contains the highest weighted vote count
    ; Now determine which contestant has this count

    CMP AX, weightedVote1
    JE ShowWinner1

    CMP AX, weightedVote2
    JE ShowWinner2

    CMP AX, weightedVote3
    JE ShowWinner3

    ; Shouldn't reach here, but just in case
    JMP AdminMenu

; Show contestant 1 as winner
ShowWinner1:

    LEA DX, winner1Msg
    CALL DisplayMsg

    LEA DX, newLine
    CALL DisplayMsg

    LEA DX, weightedVotesMsg
    CALL DisplayMsg

    ; Display weighted vote (2-digit number)
    MOV AX, weightedVote1
    CALL DisplayNumber

    LEA DX, pressKeyMsg
    CALL DisplayMsg
    CALL GetInput ; GetInput now preserves AL
    JMP AdminMenuScreen

; Show contestant 2 as winner
ShowWinner2:

    LEA DX, winner2Msg
    CALL DisplayMsg

    LEA DX, newLine
    CALL DisplayMsg

    LEA DX, weightedVotesMsg
    CALL DisplayMsg

    ; Display weighted vote (2-digit number)
    MOV AX, weightedVote2
    CALL DisplayNumber

    LEA DX, pressKeyMsg
    CALL DisplayMsg
    CALL GetInput ; GetInput now preserves AL
    JMP AdminMenuScreen

; Show contestant 3 as winner
ShowWinner3:

    LEA DX, winner3Msg
    CALL DisplayMsg

    LEA DX, newLine
    CALL DisplayMsg

    LEA DX, weightedVotesMsg
    CALL DisplayMsg

    ; Display weighted vote (2-digit number)
    MOV AX, weightedVote3
    CALL DisplayNumber

    LEA DX, pressKeyMsg
    CALL DisplayMsg
    CALL GetInput ; GetInput now preserves AL
    JMP AdminMenuScreen

; Display a multi-digit number in AX
DisplayNumber PROC
    PUSH AX
    PUSH BX
    PUSH CX
    PUSH DX

    MOV CX, 10      ; Divisor
    MOV BX, 0       ; Digit counter

    ; Handle zero case
    CMP AX, 0
    JNE ConvertToDigits

    MOV DL, '0'     ; Print '0' if the number is 0
    MOV AH, 02H
    INT 21H
    JMP EndDisplayNumber

ConvertToDigits:
    ; Convert number to decimal digits
    MOV DX, 0       ; Clear high word
    DIV CX          ; AX = quotient, DX = remainder

    PUSH DX         ; Save remainder on stack
    INC BX          ; Increment digit counter

    CMP AX, 0       ; Check if quotient is 0
    JNE ConvertToDigits

PrintDigits:
    ; Print digits in reverse order
    POP DX          ; Get digit from stack
    ADD DL, '0'     ; Convert to ASCII
    MOV AH, 02H     ; Display character
    INT 21H

    DEC BX          ; Decrement digit counter
    JNZ PrintDigits

EndDisplayNumber:
    POP DX
    POP CX
    POP BX
    POP AX
    RET
DisplayNumber ENDP

; Utility procedures

; Display a message
DisplayMsg PROC
    MOV AH, 09H
    INT 21H
    RET
DisplayMsg ENDP

; Clear the screen
ClearScreen PROC
    MOV AX, 0600H   ; Scroll window up
    MOV BH, 07H     ; Normal attribute (white on black)
    MOV CX, 0000H   ; Upper left corner (0,0)
    MOV DX, 184FH   ; Lower right corner (24,79)
    INT 10H

    ; Reset cursor position
    MOV AH, 02H     ; Set cursor position
    MOV BH, 00H     ; Page number
    MOV DX, 0000H   ; Row 0, column 0
    INT 10H

    RET
ClearScreen ENDP

; Get single character input
GetInput PROC
    MOV AH, 01H     ; Get character input
    INT 21H
    RET
GetInput ENDP

; Get multi-digit number input
GetNumberInput PROC
    PUSH BX         ; Save registers
    PUSH CX

    MOV BX, 0       ; Clear result
    MOV CX, 0       ; Clear digit counter

ReadNextDigit:
    MOV AH, 01H     ; Read character
    INT 21H

    CMP AL, 0DH     ; Check for Enter key
    JE FinishInput

    CMP AL, '0'     ; Check if below '0'
    JB InvalidDigit
    CMP AL, '9'     ; Check if above '9'
    JA InvalidDigit

    SUB AL, '0'     ; Convert from ASCII to number
    MOV CL, AL      ; Save digit in CL

    MOV AX, 10      ; Multiply current result by 10
    MUL BX
    MOV BX, AX

    ADD BX, CX      ; Add new digit

    JMP ReadNextDigit

InvalidDigit:
    ; Just ignore invalid characters
    JMP ReadNextDigit

FinishInput:
    MOV AX, BX      ; Put result in AX

    POP CX          ; Restore registers
    POP BX
    RET
GetNumberInput ENDP

; Delay procedure
Delay PROC
    MOV CX, 0FFFFH
DelayLoop:
    DEC CX
    JNZ DelayLoop
    RET
Delay ENDP

END MAIN