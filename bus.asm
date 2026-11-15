; KL Bus Ticketing System

.MODEL SMALL
.STACK 100H

.DATA
; Messages
    msgWelcome          DB 0DH, 0AH, '==================================================', 0DH, 0AH, 'Welcome to KL Bus Ticket Booking System', '$'
    msgMainMenu         DB 0DH, 0AH, '--------------------------------------------------', 0DH, 0AH, '1. Book a Ticket', 0DH, 0AH, '2. Exit', 0DH, 0AH, 'Enter your choice: $'
    msgRouteMenu        DB 0DH, 0AH, '--------------------------------------------------', 0DH, 0AH, 'Select Destination:', 0DH, 0AH, '1. Penang (RM50)', 0DH, 0AH, '2. Ipoh (RM30)', 0DH, 0AH, '3. Genting Highland (RM10)', 0DH, 0AH, '4. Johor Bahru (RM70)', 0DH, 0AH, '5. Singapore (RM90)', 0DH, 0AH, 'Enter your choice: $'
    msgSeatMenu         DB 0DH, 0AH, '--------------------------------------------------', 0DH, 0AH, 'Select Seat Type:', 0DH, 0AH, '1. Express (Standard)', 0DH, 0AH, '2. Luxury (Add RM30 to upgrade experience)', 0DH, 0AH, 'Enter your choice: $'
    msgFacilityMenu     DB 0DH, 0AH, '--------------------------------------------------', 0DH, 0AH, 'Select Additional Facilities:', 0DH, 0AH, '1. None', 0DH, 0AH, '2. Bedding Kits (RM 15)', 0DH, 0AH, '3. Travel Insurance (RM 5)', 0DH, 0AH, '4. Lounge Access (RM 20)', 0DH, 0AH, '5. Complimentary Beverages (RM 10)', 0DH, 0AH, 'Enter your choice: $'
    msgFacilityLoop     DB 0DH, 0AH, 'Do you want to select more facilities? (y/n): $'
    msgBookingConfirm   DB 0DH, 0AH, '--------------------------------------------------', 0DH, 0AH, 'Booking Confirmed!', '$'
    msgPrevFare         DB 0DH, 0AH, 'Subtotal Fare: RM $'
    msgTotalFare        DB 0DH, 0AH, 'Total Fare: RM $'
    msgThankYou         DB 0DH, 0AH, '--------------------------------------------------', 0DH, 0AH, 'Thank you for using our service!', 0DH, 0AH, '==================================================', 0DH, 0AH, '$'
    msgInvalidChoice    DB 0DH, 0AH, 'Invalid choice. Please try again.', 0DH, 0AH, '$'
    
    msgPaymentMenu      DB 0DH, 0AH, 0DH, 0AH, 'Select Payment Method:', 0DH, 0AH, '1. Cash Payment (RM 1, 5, 10, 20, 50, 100 notes is accepted)', 0DH, 0AH, '2. Cashless Payment (Debit & Credit Card is available)', 0DH, 0AH, 'Enter your choice: $'
    msgPaymentPrompt    DB 0DH, 0AH, '--------------------------------------------------', 0DH, 0AH, 'Please insert payment amount: RM $'
    msgInsufficientPay  DB 0DH, 0AH, 'Insufficient payment. Please enter an amount equal to or greater than the fare.', '$'
    msgPaymentSuccess   DB 0DH, 0AH, 'Payment successful! Your change: RM $'
    msgPaymentExact     DB 0DH, 0AH, 'Payment successful! No change.', '$'
    msgPaymentMessage   DB 0DH, 0AH, 'Please proceed counter to collect your ticket.', '$'
    msgInvalidInput     DB 0DH, 0AH, 'Invalid input. Please enter a valid number.', '$'
    msgCashless         DB 0DH, 0AH, '--------------------------------------------------', 0DH, 0AH, 'Please insert your card to proceed.', '$'
    msgCardNum          DB 0DH, 0AH, 'Enter Card Number: $'
    msgCardPin          DB 0DH, 0AH, 'Enter OTP: $'
    
    msgMemberPrompt     DB 0DH, 0AH, 'Do you have concession card? (y/n): $'
    msgLoginPrompt      DB 0DH, 0AH, '--------------------Login page--------------------', '$'
    msgPromptUser       DB 0DH, 0AH, 'Enter Username: $'
    msgPromptPass       DB 0DH, 0AH, 'Enter Password: $'
    msgLoginSuccess     DB 0DH, 0AH, 'Login successful! You will receive a 10% discount.', '$'
    msgLoginFailed      DB 0DH, 0AH, 'Invalid credentials! Please try again.', 0DH, 0AH, '$'
    msgOpenFail         DB 0DH, 0AH, 'Error: Could not open file!', '$'
    msgReadFail         DB 0DH, 0AH, 'Error: Could not read file!', '$'

; Service Prices
    routePrices         DW 50, 30, 10, 70, 90       ; Penang, Ipoh, Genting Highland, Johor Bahru, Singapore
    seatPrices          DW 0, 30                    ; Standard, Luxury
    facilityPrices      DW 0, 15, 5, 20, 10         ; None, Bedding Kits, Travel Insurance, Lounge Access, Complimentary Beverages

; File
    userFile            DB 'users.txt', 0
    userBuffer          DB 100 DUP(?)
    userHandle          DW ?
    
; Masking
    maskChar            DB '*'
    newline             DB 0AH, 0DH, '$'
    
; Variables
    userChoice          DB ?            ; Store main menu choice
    routeChoice         DB ?            ; Store route choice
    seatChoice          DB ?            ; Store seat type choice
    facilityChoice      DB ?            ; Store facility choice
    paymentChoice       DB ?            ; Store payment method choice
    
    inputUser           DB 11 DUP(?)    ; Buffer for username input (11 bytes: size, actual size, 10 chars)
    inputPass           DB 11 DUP(?)    ; Buffer for password input (11 bytes: size, actual size, 10 chars)
    inputCardNum        DB 11 DUP(?)    ; Buffer for card number input (max 10 characters + null terminator)
    inputCardPin        DB 6 DUP(?)     ; Buffer for card pin input (max 6 characters + null terminator)
    
    isMember            DB 0            ; 0 = not member, 1 = is member
    memberDiscount      DW 10           ; 10% discount for concession member
    
    totalFare           DW 0            ; Store total fare
    paymentAmount       DW 0            ; Store payment amount
    change              DW 0            ; Store change

.CODE
MAIN PROC
    MOV AX, @DATA
    MOV DS, AX

MainMenu:
    ; Display Welcome Message
    MOV AH, 09H
    LEA DX, msgWelcome
    INT 21H

    ; Display Main Menu
    MOV AH, 09H
    LEA DX, msgMainMenu
    INT 21H

    ; Get User Choice
    MOV AH, 01H
    INT 21H
    SUB AL, '0'
    MOV userChoice, AL

    CMP AL, 1
    JE BookTicket
    CMP AL, 2
    JMP ExitProgram

    ; Invalid Choice
    MOV AH, 09H
    LEA DX, msgInvalidChoice
    INT 21H
    JMP MainMenu

BookTicket:
    CALL CHECKMEMBER
    CALL SELECTROUTE
    CALL SELECTSEAT
    CALL SELECTFACILITY
    CALL FINALIZEFARE
    CALL PAYMENT
    JMP MainMenu

ExitProgram:
    MOV AH, 4CH
    INT 21H
MAIN ENDP
 
CHECKMEMBER PROC
    ; Ask if user is member
    MOV AH, 09H
    LEA DX, msgMemberPrompt
    INT 21H
    
    ; Get user input
    MOV AH, 01H
    INT 21H
    CMP AL, 'y'
    JE MemberLogin
    CMP AL, 'Y'
    JE MemberLogin
    MOV isMember, 0
    RET
    
MemberLogin:
    MOV AH, 09H
    LEA DX, msgLoginPrompt
    INT 21H
    
    CALL OPENANDREADFILE
    JC ExitProgram
    
LoginLoop: 
    CALL GETCREDENTIALS
    CALL VALIDATECREDENTIALS
    JNC LoginSuccess
    
    MOV isMember,0
    MOV AH, 09H
    LEA DX, msgLoginFailed
    INT 21H
    JMP LoginLoop
    
LoginSuccess:
    MOV isMember, 1
    MOV AH, 09H
    LEA DX, msgLoginSuccess
    INT 21H

    ; Close file
    MOV AH, 3EH
    MOV BX, userHandle
    INT 21H
    
CHECKMEMBER ENDP

OPENANDREADFILE PROC
    ; Open file
    MOV AH, 3DH
    MOV AL, 0
    LEA DX, userFile
    INT 21H
    JC OpenFail
    MOV userHandle, AX

    ; Read file
    MOV AH, 3FH
    MOV BX, userHandle
    LEA DX, userBuffer
    MOV CX, 100
    INT 21H
    JC ReadFail

    CLC
    RET

OpenFail:
    MOV AH, 09H
    LEA DX, msgOpenFail
    INT 21H
    STC
    RET

ReadFail:
    MOV AH, 09H
    LEA DX, msgReadFail
    INT 21H
    STC
    RET
OPENANDREADFILE ENDP

GETCREDENTIALS PROC
    ; Prompt for username 
    MOV AH, 09H
    LEA DX, msgPromptUser
    INT 21H
    MOV AH, 0AH
    LEA DX, inputUser
    MOV inputUser[0], 10    ; Max input size = 10
    INT 21H

    ; Prompt for password 
    MOV AH, 09H
    LEA DX, msgPromptPass
    INT 21H
    MOV AH, 0AH
    LEA DX, inputPass
    MOV inputPass[0], 10    ; Max input size = 10
    INT 21H
    RET
GETCREDENTIALS ENDP

VALIDATECREDENTIALS PROC
    MOV SI, OFFSET userBuffer

CheckLoop:
    MOV AL, [SI]
    CMP AL, 0
    JE NoMatch

    ; Compare username
    LEA DI, inputUser + 2
    MOV CX, 10
    CALL COMPARESTRING
    JNZ NextCredential
    
    ; Compare password
    ADD SI, 11
    LEA DI, inputPass + 2
    MOV CX, 11
    CALL COMPARESTRING
    JZ CredentialsMatch
    
NextCredential:
    ADD SI, 23              ; Move to next credential pair (10+1+10+2 for username, space, password, CRLF)
    JMP CheckLoop
    
CredentialsMatch:
    CLC
    RET

NoMatch:
    STC 
    RET
VALIDATECREDENTIALS ENDP

COMPARESTRING PROC
    ; SI = valid string, DI = input string, CX = max length
    PUSH SI
    PUSH DI
    PUSH AX
    PUSH CX

CompareLoop:
    MOV AL, [SI]
    MOV AH, [DI]
    CMP AL, ' '             ; Check if we've reached end of valid string (space-padded)
    JE CheckInputEnd
    CMP AH, 0DH             ; Check if we've reached end of input string (CR)
    JE StringNotEqual
    CMP AL, AH
    JNE StringNotEqual
    INC SI
    INC DI
    LOOP CompareLoop
    JMP StringEqual
    
CheckInputEnd:
    CMP AH, 0DH
    JE StringEqual 

StringNotEqual:
    POP CX
    POP AX
    POP DI
    POP SI
    OR AX, 1
    RET
    
StringEqual:
    POP CX
    POP AX
    POP DI
    POP SI
    XOR AX, AX
    RET
COMPARESTRING ENDP

SELECTROUTE PROC
    ; Route Selection Menu
    MOV AH, 09H
    LEA DX, msgRouteMenu
    INT 21H

    ; Get Route Choice
    MOV AH, 01H
    INT 21H
    SUB AL, '0'
    MOV routeChoice, AL

    CMP AL, 1
    JB InvalidRoute
    CMP AL, 5
    JA InvalidRoute
    
    ; Valid route selection, store and calculate fare
    MOV routeChoice, AL
    DEC AL
    MOV BL, AL
    SHL BL, 1
    MOV AX, [routePrices + BX]
    MOV totalFare, AX
    RET

InvalidRoute:
    MOV AH, 09H
    LEA DX, msgInvalidChoice
    INT 21H
    JMP SELECTROUTE
SELECTROUTE ENDP

SELECTSEAT PROC
    ; Seat Type Selection
    MOV AH, 09H
    LEA DX, msgSeatMenu
    INT 21H
    
    ; Get Seat Choice
    MOV AH, 01H
    INT 21H
    SUB AL, '0'
    MOV seatChoice, AL

    CMP AL, 1
    JB InvalidSeat
    CMP AL, 2
    JA InvalidSeat

    ; Valid seat selection, store and calculate fare
    MOV seatChoice, AL
    DEC AL 
    MOV BL, AL
    SHL BL, 1
    MOV AX, [seatPrices + BX]
    ADD totalFare, AX
    RET
    
InvalidSeat:
    MOV AH, 09H
    LEA DX, msgInvalidChoice
    INT 21H
    JMP SELECTSEAT
SELECTSEAT ENDP

SELECTFACILITY PROC
    ; Facility Selection Menu
    MOV AH, 09H
    LEA DX, msgFacilityMenu
    INT 21H
    
    ; Get Facility Choice
    MOV AH, 01H
    INT 21H
    SUB AL, '0'
    MOV facilityChoice, AL

    CMP AL, 1
    JB InvalidFacility
    CMP AL, 5
    JA InvalidFacility

    ; Valid facility selection, store and calculate fare
    MOV facilityChoice, AL
    DEC AL 
    MOV BL, AL
    SHL BL, 1
    MOV AX, [facilityPrices + BX]
    ADD totalFare, AX
    
    ; More Additional Facility
    MOV AH, 09H
    LEA DX, msgFacilityLoop
    INT 21H
    
    ; Check if user wants select more
    MOV AH, 01H
    INT 21H
    CMP AL, 'n'
    JE FinalizeFacility
    CMP AL, 'N'
    JE FinalizeFacility
    JMP SELECTFACILITY
    
InvalidFacility:
    MOV AH, 09H
    LEA DX, msgInvalidChoice
    INT 21H
    JMP SELECTFACILITY

FinalizeFacility:
    RET
SELECTFACILITY ENDP

FINALIZEFARE Proc
    ; Display Booking Confirmation
    MOV AH, 09H
    LEA DX, msgBookingConfirm
    INT 21H
    
    ; Apply member discount if applicable
    CMP isMember, 1
    JNE SkipDiscount
    
    ; Display Subtotal Fare (before discount)
    MOV AH, 09H
    LEA DX, msgPrevFare
    INT 21H
    
    ; Convert totalFare to ASCII and display
    MOV AX, totalFare
    CALL DISPLAYNUMBER
    
    ; Calculate discount
    MOV AX, totalFare
    MUL memberDiscount
    MOV BX, 100
    DIV BX
    
    ; Subtract discount from total fare
    SUB totalFare, AX
    
SkipDiscount:
    ; Display Total Fare
    MOV AH, 09H
    LEA DX, msgTotalFare
    INT 21H
    
    ; Convert totalFare to ASCII and display
    MOV AX, totalFare
    CALL DISPLAYNUMBER
    RET
FINALIZEFARE ENDP

PAYMENT PROC
    ; Payment Method Selection
    MOV AH, 09H
    LEA DX, msgPaymentMenu
    INT 21H
    
    ; Get Payment Method Choice
    MOV AH, 01H
    INT 21H
    SUB AL, '0'
    MOV paymentChoice, AL

    CMP AL, 1
    JE CashPayment
    CMP AL, 2
    JMP CashlessPayment
    
    CMP AL, 1
    JB InvalidPayment
    CMP AL, 2
    JA InvalidPayment
    
    InvalidPayment:
    MOV AH, 09H
    LEA DX, msgInvalidChoice
    INT 21H
    JMP PAYMENT

CashMethod:
    CALL CASHPAYMENT
    RET
    
CashlessMethod:
    CALL CASHLESSPAYMENT
    RET
PAYMENT ENDP

CASHPAYMENT PROC
    ; Initialize total payment amount to 0
    XOR AX, AX
    MOV paymentAmount, AX
    
GetPayment:
    ; Display message asking for payment
    MOV AH, 09H
    LEA DX, msgPaymentPrompt
    INT 21H
    
    ; Get user input (assuming 3-digit payment)
    CALL GETINPUTNUMBER
    ADD paymentAmount, AX

    ; Compare Payment Amount with Total Fare
    MOV AX, paymentAmount
    CMP AX, totalFare
    JAE ProcessPayment
    
    ; If payment is not enough
    MOV AH, 09H
    LEA DX, msgInsufficientPay
    INT 21H
    JMP GetPayment
    
ProcessPayment:
    ; Calculate change
    SUB AX, totalFare
    MOV change, AX

    ; Display change message
    CMP AX, 0
    JE ExactPayment
    MOV AH, 09H
    LEA DX, msgPaymentSuccess
    INT 21H
    MOV AX, change 
    CALL DISPLAYNUMBER
    JMP FinalizeTransaction
    
ExactPayment:
    MOV AH, 09H
    LEA DX, msgPaymentExact
    INT 21H
    JMP FinalizeTransaction

FinalizeTransaction:
    ; Display Payment Message
    MOV AH, 09H
    LEA DX, msgPaymentMessage
    INT 21H

    ; Thank You Message
    MOV AH, 09H
    LEA DX, msgThankYou
    INT 21H

    ; Clear screen for next session
    MOV AH, 01H
    INT 21H
    SUB AL, '0'
    MOV userChoice, AL
    
    MOV AH, 06H
    MOV BH, 07H
    MOV CX, 0
    MOV DX, 184FH
    INT 10h
    
    MOV AH, 02h
    MOV BH, 0
    MOV DH, 0
    MOV DL, 0
    INT 10h
    
    JMP MainMenu
    
CASHPAYMENT ENDP

CASHLESSPAYMENT PROC
    ; Display cashless payment message
    MOV AH, 09H
    LEA DX, msgCashless
    INT 21H

    ; Display card number prompt
    MOV AH, 09H
    LEA DX, msgCardNum
    INT 21H

    ; Set up input buffer for card number
    MOV BYTE PTR [inputCardNum], 11    ; Max length of input
    MOV BYTE PTR [inputCardNum + 1], 0
    MOV AH, 0AH
    LEA DX, inputCardNum
    INT 21H

    ; Display card pin prompt
    MOV AH, 09H
    LEA DX, msgCardPin
    INT 21H

    ; Read and mask password input
    MOV CX, 6                           ; Max password length
    MOV SI, 0

ReadPinChar:
    MOV AH, 08H
    INT 21H

    CMP AL, 0DH
    JE DonePinInput

    ; Store the character in the password array
    MOV [inputCardPin + SI], AL
    INC SI

    ; Display the mask character '*'
    MOV AH, 02H
    MOV DL, maskChar
    INT 21H

    ; Continue reading characters
    CMP SI, 6
    JB ReadPinChar

DonePinInput:
    ; End the input with null character
    MOV BYTE PTR [inputCardPin + SI], 0
    
    ; Move to the next line after card pin input
    MOV AH, 09H
    LEA DX, newline
    INT 21H

    ; Done cashless payment
    MOV AH, 09H
    LEA DX, msgPaymentExact
    INT 21H
    
    ; Display Payment Message
    MOV AH, 09H
    LEA DX, msgPaymentMessage
    INT 21H

    ; Thank You Message
    MOV AH, 09H
    LEA DX, msgThankYou
    INT 21H
    
    ; Clear screen for next session
    MOV AH, 01H
    INT 21H
    SUB AL, '0'
    MOV userChoice, AL
    
    MOV AH, 06H
    MOV BH, 07H
    MOV CX, 0
    MOV DX, 184FH
    INT 10h
    
    MOV AH, 02h
    MOV BH, 0
    MOV DH, 0
    MOV DL, 0
    INT 10h

    JMP MainMenu
CASHLESSPAYMENT ENDP

; Subroutine to Display Number in Decimal
DISPLAYNUMBER PROC
    ; Assumes number is in AX
    ; Converts AX to string and displays it
    PUSH AX
    PUSH BX
    PUSH CX
    PUSH DX

    XOR CX, CX
    MOV BX, 10

ConvertLoop:
    XOR DX, DX
    DIV BX              ; AX = AX / 10, DX = remainder
    PUSH DX
    INC CX              ; Increment digit count
    CMP AX, 0
    JNE ConvertLoop

DisplayLoop:
    POP DX 
    ADD DL, '0'
    MOV AH, 02H
    INT 21H
    LOOP DisplayLoop

    POP DX
    POP CX
    POP BX
    POP AX
    RET
DISPLAYNUMBER ENDP

; Subroutine to get input number (2-3 digits)
GETINPUTNUMBER PROC
    PUSH BX
    PUSH CX
    XOR BX, BX
    XOR CX, CX 
    
InputLoop:
    MOV AH, 01H 
    INT 21H
    CMP AL, 0DH
    JE EndInput
    SUB AL, '0'
    
    CMP AL, 9           ; Validate if the input is a valid digit (0-9)
    JA InvalidInput
    
    MOV CL, 10
    MOV AH, 0 
    PUSH AX 
    MOV AX, BX
    MUL CL
    MOV BX, AX
    POP AX
    ADD BX, AX
    
    INC CH
    CMP CH, 3           ; Limit to 3 digits count
    JB InputLoop

EndInput:
    MOV AX, BX
    POP CX
    POP BX
    RET

InvalidInput:
    MOV AH, 09H
    LEA DX, msgInvalidInput
    INT 21H
    POP CX
    POP BX
    JMP GETINPUTNUMBER

GETINPUTNUMBER ENDP

END MAIN