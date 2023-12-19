;Made by Yonatan Deri
PrintText Macro row , column , text ;Macro for printing text with white color
   push ax
   push bx
   push cx
   push dx   
   
   mov ah,2 ;command for setting the cursor position.
   mov bh,0 ;page number 0(for graphic mode)
   mov dl,column
   mov dh,row
   int 10h ;execute
   mov ah, 9h ;command for printing a string
   mov bl, 1h
   mov dx, offset text ;string terminated (to end taking the string) by the '$' sign.
   int 21h ;execute
   
   pop dx
   pop cx
   pop bx
   pop ax
endm PrintText


ConvertDecimal Macro  decimal, printableDecimal ;Macro to convert decimal from the program to printable decimal (ascii) thats why there is add 3000h instead of sub 3000h
	mov al,decimal ; al now contains the decimal number to convert to printble decimal (0-9)
	xor ah, ah ; setting ah to be 00
	mov cl, 10 ; cl now contains the number 10
	div cl ; al = ax:cl => al= ax: 10. For example: ax contains 0003 => al = 0003 : 10 = 0.3 so al =  0300 so it changed the place the 3 was.
	add ax, 3000h ;adding 3000 to ax register so as the example: 0300 + 3000= 3300. That's ascii code (33h) equals to the decimal number 3.
	mov printableDecimal,ax
endm ConvertDecimal 

ClearScreen MACRO ;Macro to clear the screen with setting the configuration of the screen to video mode again, it's printing the screen again. Another way to do this, is to print all the screen black color as the backgroung.
	mov ah, 00h ;set video mode
	mov al, 13h ; set window mode: size (320*200) and 256 color
	int 10h ;set configurations of the window mode and size.
endm ClearScreen

IDEAL
MODEL small
STACK 100h
DATASEG

;SpaceShip (player) Sprite
player db 0,0,0,0,1,1,0,0,0,0,0,0,0,0,1,1,0,0,0,0,0,0,0,1,1,1,1,0,0,0,0,0,0,1,1,1,1,0,0,0,0,1,1,1,1,1,1,1,1,0,0,1,1,1,1,1,1,1,1,0,1,1,1,1,1,1,1,1,1,1,0,0,1,1,1,1,1,1,0,0,0,0,0,1,1,1,1,0,0,0,0,0,0,0,1,1,0,0,0,0
;SpaceShip Pos
playerXPos dw 100 ;Column variable for the player
playerYPos dw 100 ;Row variable for the player
playerIndex dw 0 ;to navigate in the player array with si.
playerXCounter dw 0 ;counter for the X - the column of the paint player, every pixel it goes 1 pixel to the right.
playerYCounter dw 0 ;counter for the Y - the row of the paint player, every 10 pixels it's going one row down. 
playerXLength dw 10 ;the length of the X (horizontal) of the player painting
playerYLength dw 10 ;the length of the Y (vertival) of the player painting
playerPixel db ? ;this variable will store the value of the pixel in the player array, will check with this if the value in the array is 0 or 1 and with this if I need to paint a pixel in the X and Y position or should I skip this pixel.
playerColor db 9 ; decimal value for the player color (light blue).
hitedPlayer db 0 ;boolean variable to check if the player has been hited by the aliens. 

;Shot configuration
shot db 1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1 ;shot sprite
shotYPos dw 20 ;Row variable for the shot
shotXPos dw ? ;Column variable for the shot
shotVelY db 02h ;Velocity for the shot (the speed for the shot)
shotStatus db 0 ;Status of the shot, if the is a current shot the value is 1 other wise the value is 0 (it's a boolian variable)
shotColor db 0Ch ;light red color value for the shot
shotYCounter dw 0 ;counter for the Y - the row of the shot, every 4 pixels it's going one row down.
shotXCounter dw 0 ;counter for the X - the column of the shot every pixel it goes 1 pixel to the right.
shotXLength dw 4 ;the length of the X (horizontal) of the shot painting
shotYLength dw 4 ;the length of the Y (vertival) of the shot painting
shotIndex dw 0 ;to navigate in the shot array with si.
shotPixel db ? ;this variable will store the value in the shot array (0 or 1), in that case only 1 because it's a shot, if the value in the array is equal to 1 it will paint a pixel at the X and Y positions, otherwise it will skip a pixel.
shotHit db 0 ;boolean variable to check if the shot hited the alien.

PlayerName	       db     15, ?,  15 dup('$') ;an empty array to store the player name that the player inputs.
AskPlayerName	       db      'Enter your pilot name: ','$' ;string to ask the player to enter the name of pilot
whileGamePlayerName db 'Pilot name:', '$' ;string to point that it's the pilot name after the ':'.
pilotNameTextXPos db 53 ;X postion (column) to where to print the whileGamePlayerName with the entered name.
pilotNameIndex dw 0 ;variable to navigate in the string and go letter by letter. This is for coloring the text.
;Score
scoresFile db 'scores.txt',0 ; variable for the file name, will be using this to open the file, read from it and write to it.
scoresFileHandle dw ? ;the file handle for the scores.txt file. Will be using this variable a lot in the file parts. After all it's the handle for the file.
readScoreBuffer dw ? ;the array to store the read data from the score.txt file.
unitHits db 0 ;variable for the units of the score number.
tensHits db 0 ;variable for the tens of the score number.
score dw 0 ;variable to store the general score.
displayHits db 'Score: 00','$' ;string to display the score. I put 00 because you need to put a value in the string so the program will know to save there a spot for data to replace the 00. 
readPixel db 0 ;variable to save the read pixel from the screen.


CUText db 'C-U-Next Time','$' ;exit message string.
cUTextXPos db 16 ;X position (column) for the exit message string.
cUIndex dw 0 ;variable to navigate in the exit message string so I can print it letter by letter using si and making the text be colored.

gameOverTextXPos db 16
gameOverIndex dw 0

exitTextXPos db 1
exitIndex dw 0
exitColor db 0

retryTextXPos db 34
retryIndex dw 0
retryColor db 0

GameOverText db 'GAMEOVER','$'
FinalScoreText db 'Your Final Score Is: 00', '$'
NewHighScoreText db 'We Have A New High Score: 00', '$' ;26 letters
newHighScoreTextXPos db 6
newHighScoreTextIndex dw 0
ExitText db 'Exit', '$'
RetryText db 'Retry', '$'

Clock equ es:6Ch ;Variable for the time, will be using it for the movement of the aliens, it's the counter at address 0040:006Ch. The equ gives a symbolic name to a numeric constant (in this scanerio, give the variable "Clock" the numeric value of the system time).  
spaceJump db 0
cantGoFurther db 0

;AlienSpritetasm base		 
;alien db 0,1,1,1,0,1,1,1,1,1,1,0,1,0,1,0,1,0,1,0,0,0,1,0,0

alien db 0,0,1,1,1,1,1,1,0,0,\
		 0,0,1,1,1,1,1,1,0,0,\
		 1,1,1,1,1,1,1,1,1,1,\
		 1,1,1,1,1,1,1,1,1,1,\
		 1,1,0,0,1,1,0,0,1,1,\
		 1,1,0,0,1,1,0,0,1,1,\
		 0,0,1,1,0,0,1,1,0,0,\
		 0,0,1,1,0,0,1,1,0,0,\
		 0,0,0,0,1,1,0,0,0,0,\
		 0,0,0,0,1,1,0,0,0,0
		
;Aliens
alienXPos dw 20 ;Column variable for the alien
alienYPos dw 20 ;Row variable for the alien
alienIndex dw 0
alienXCounter dw 0
alienYCounter dw 0
alienXLength dw 10
alienYLength dw 10
alienPixel db ?
alienColor db 10 ;light green decimal value for the alien
alienStatus db 0
checkAlienCollision_Y dw ?
checkAlienCollision_X dw ?
;Openning Screen
openningAlienXLength dw 20
openningAlienYLength dw 20
openningAlien db 0,0,0,0,1,1,1,1,1,1,1,1,1,1,1,1,0,0,0,0,\
				 0,0,0,0,1,1,1,1,1,1,1,1,1,1,1,1,0,0,0,0,\
				 0,0,0,0,1,1,1,1,1,1,1,1,1,1,1,1,0,0,0,0,\
				 0,0,0,0,1,1,1,1,1,1,1,1,1,1,1,1,0,0,0,0,\
				 1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,\
				 1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,\
				 1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,\
				 1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,\
				 1,1,1,1,0,0,0,0,1,1,1,1,0,0,0,0,1,1,1,1,\
				 1,1,1,1,0,0,0,0,1,1,1,1,0,0,0,0,1,1,1,1,\
				 1,1,1,1,0,0,0,0,1,1,1,1,0,0,0,0,1,1,1,1,\
				 1,1,1,1,0,0,0,0,1,1,1,1,0,0,0,0,1,1,1,1,\
				 0,0,0,0,1,1,1,1,0,0,0,0,1,1,1,1,0,0,0,0,\
				 0,0,0,0,1,1,1,1,0,0,0,0,1,1,1,1,0,0,0,0,\
				 0,0,0,0,1,1,1,1,0,0,0,0,1,1,1,1,0,0,0,0,\
				 0,0,0,0,1,1,1,1,0,0,0,0,1,1,1,1,0,0,0,0,\
				 0,0,0,0,0,0,0,0,1,1,1,1,0,0,0,0,0,0,0,0,\
				 0,0,0,0,0,0,0,0,1,1,1,1,0,0,0,0,0,0,0,0,\
				 0,0,0,0,0,0,0,0,1,1,1,1,0,0,0,0,0,0,0,0,\
				 0,0,0,0,0,0,0,0,1,1,1,1,0,0,0,0,0,0,0,0
titleIndex dw 0
titleTextXPos db 16
TitleText db 'Attack On Aliens', '$'

startTextIndex dw 0
startTextXPos db 16
StartText db 'Start', '$'
startColor db 0
exitOpenningTextIndex dw 0
exitOpenningTextXPos db 16

;hearts
heartOutline db 0,0,1,1,0,0,0,1,1,0,0,0,1,0,0,1,0,1,0,0,1,0,1,0,0,0,0,1,0,0,0,0,1,1,0,0,0,0,0,0,0,0,0,1,0,1,0,0,0,0,0,0,0,1,0,0,0,1,0,0,0,0,0,1,0,0,0,0,0,1,0,0,0,1,0,0,0,0,0,0,0,1,0,1,0,0,0,0,0,0,0,0,0,1,0,0,0,0,0
heartFilling db 0,0,0,0,0,0,0,0,0,0,0,0,0,1,1,0,0,0,1,1,0,0,0,1,1,1,1,0,1,1,1,1,0,0,1,1,1,1,1,1,1,1,1,0,0,0,1,1,1,1,1,1,1,0,0,0,0,0,1,1,1,1,1,0,0,0,0,0,0,0,1,1,1,0,0,0,0,0,0,0,0,0,1,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
heartXPos dw 270 ;Column variable for the heart
heartYPos dw 8 ;Row variable for the heart
heartIndex dw 0
heartXCounter dw 0
heartYCounter dw 0
heartXLength dw 11
heartYLength dw 9
heartPixel db ?
heartOutlineColor db 15 ;white decimal value for the outline of the heart.
heartFillingColor db 4
paintHeartsCounter db 3
;lifes
lifesCounter dw 3
alienHit dw 0


;Colors
paintColor db ?
paint_Y dw ? ;Y position coordinate to paint a pixel it's for a "universal" proc
paint_X dw ? ;X postion coordinate to paint a pixel it's for a "universal" proc
colorBg db 0
msg2 dw ?
ErrorMsg db "Error", '$'
;Checking
count db 0
timeAux db 0
timeAuxAlien db 0

NewScore db "00", '$'
betterScore dw 0

saveKey db ? ;Variable to store the pressed key and check which key was pressed.

flag db 0
shotReachedEnd db 0
 
CODESEG
;;;;;;;;;;;;;
;Printing the openning screen, the title of the game, Start option and Exit Option + navigation in that screen using 'w' and 's' keys and chosing using the space bar.
;;;;;;;;;;;;;
proc OpenningScreen
	mov bl, [alienColor] ;color of the alien.
	mov [paintColor], bl ;color to paint, the value in bl goes into the paintColor variable.
	mov [alienIndex], 0 ;variable responsible for the navigation in the alien sprite array.
	mov [alienYCounter], 0 ;resetting counter for the Y position of the painting process of the alien.
	mov [paint_Y], 20 ;Y coordinate to print the alien on responsible for the rows of the painting.
Loop_PaintOpenningAlien_Y: ;label resonsible for the loop of painting the Y, moving 1 row down every time with the increase paint_Y. 
	mov [alienXCounter], 0
	mov [paint_X], 150
Loop_PaintOpenningAlien_X:
	mov dx, [alienIndex]
	mov si, dx
	mov bl, [openningAlien + si]
	inc [alienIndex]
	mov [alienPixel], bl
	cmp [alienPixel], 0
	je SkipPaintOpenningAlienPixel
	call Draw_Pixel
SkipPaintOpenningAlienPixel:
	inc [alienXCounter]
	inc [paint_X]
	mov bx, [alienXCounter]
	cmp [openningAlienXLength], bx
	jne Loop_PaintOpenningAlien_X
	inc [alienYCounter]
	inc [paint_Y]
	mov bx, [alienYCounter]
	cmp [openningAlienYLength], bx
	jne Loop_PaintOpenningAlien_Y
	mov [playerXPos], 155
	mov [playerYPos], 55
	call PaintPlayer
	mov [shotXPos], 158
	mov [shotYPos], 46
	call DrawShot
	;Drawing the Title
	mov [titleTextXPos], 12
	mov [titleIndex], 0
	mov [startTextXPos], 17
	mov [startTextIndex], 0
	mov [exitOpenningTextXPos], 17
	mov [exitOpenningTextIndex], 0
	paintTitle:
	mov ah,2
	mov bh,0
	mov dl,[titleTextXPos] ;X position for the title text.
	mov dh,11 ; The Y position for the title text.
	int 10h
	mov ah, 09h
	mov si, [titleIndex]
	mov al, [TitleText + si]
	mov bh, 00h
	mov bl, 2
	mov cx, 1
	int 10h
	inc [titleTextXPos]
	inc [titleIndex]
	cmp [titleIndex], 16
	jne paintTitle
	;Paint Start Text
	paintStartWithColor:
	mov ah,2
	mov bh,0
	mov dl,[startTextXPos]
	mov dh, 15
	int 10h
	mov ah, 09h
	mov si, [startTextIndex]
	mov al, [StartText + si]
	mov bh, 00h
	mov bl, 11
	mov cx, 1
	int 10h
	inc [startTextXPos]
	inc [startTextIndex]
	cmp [startTextIndex], 5
	jne paintStartWithColor
	;Paint Exit Text
	paintOpenningExitText:
	mov ah,2
	mov bh,0
	mov dl,[exitOpenningTextXPos]
	mov dh,19
	int 10h
	mov ah, 09h
	mov si, [exitOpenningTextIndex]
	mov al, [ExitText + si]
	mov bh, 00h
	mov bl, 15
	mov cx, 1
	int 10h
	inc [exitOpenningTextXPos]
	inc [exitOpenningTextIndex]
	cmp [exitOpenningTextIndex], 4
	jne paintOpenningExitText
	
	checkStartOrExit:
	mov [spaceJump], 0
	mov ah,0Ch ;flush buffer and read standard input
	mov al,07h
	int 21h
	cmp al, 'w'
	je markStartText
	cmp al, 's'
	je markOpeningExitText
	cmp al, 20h
	je middlcheckSpaceOptionsForOpenning
	jmp markStartText
middlcheckSpaceOptionsForOpenning:
	mov [spaceJump], 1
	jmp middleLabel2JumpOpenning
	markStartText:
	mov [exitColor], 15
	mov [startColor], 11
	mov [exitOpenningTextIndex], 0
	mov [startTextIndex], 0
	mov [startTextXPos], 17
	mov [exitOpenningTextXPos], 17
	jmp checkpaintStartWithColor
	markOpeningExitText:
	mov [exitColor], 11
	mov [startColor], 15
	mov [exitOpenningTextIndex], 0
	mov [startTextIndex], 0
	mov [startTextXPos], 17
	mov [exitOpenningTextXPos], 17
	checkpaintStartWithColor:
	mov ah,2h
	mov bh,0
	mov dl,[startTextXPos]
	mov dh,15
	int 10h
middleLabel2JumpOpenning:
	cmp [spaceJump], 1
	je checkSpaceOptionsOpenning
	mov ah, 09h
	mov si, [startTextIndex]
	mov al, [StartText + si]
	mov bh, 00h
	mov bl, [startColor]
	mov cx, 1
	int 10h
	inc [startTextXPos]
	inc [startTextIndex]
	cmp [startTextIndex], 5
	jne checkpaintStartWithColor
	checkpaintOpenningExitTextWithColor:
	mov ah,2
	mov bh,0
	mov dl,[exitOpenningTextXPos]
	mov dh,19
	int 10h
	mov ah, 09h
	mov si, [exitOpenningTextIndex]
	mov al, [ExitText + si]
	mov bh, 00h
	mov bl, [exitColor]
	mov cx, 1
	int 10h
	inc [exitOpenningTextXPOs]
	inc [exitOpenningTextIndex]
	cmp [exitOpenningTextIndex], 4
	jne checkpaintOpenningExitTextWithColor

	cmp [spaceJump], 1 ;if it's equal to 1 that means the player pressed on the retry button or the exit button. If not it's needs to continue checking for presses.
	jne continueCheckingOpenning
	checkSpaceOptionsOpenning:
	cmp [exitColor], 11
	je exitTheGame
	ClearScreen
	ret
	;call EnterName
	jmp checkStartOrExit
	exitTheGame:
	call Exit
continueCheckingOpenning:
	jmp checkStartOrExit
	ret
endp OpenningScreen

;;;;;;;;;;;;
;Main game proc, setting variables as the start of a new game, setting the screen graphics like the hearts and the text on the screen like the pilot name and the score. In addition, calling the RnadomPosGenerator to create pseudo random numbers for the X coordinates for the aline so after that when I call the MoveAlien proc the alien will appear in a "randomized" X coordinate.
;;;;;;;;;;;;
proc GameLoop
	call DrawPilotName ;proc for the print of the string "Pilot name: " with the name you entered from the EnterName proc.
	call UpdateAlien ;proc to update the alien and printing on the alien a black spot same as the background, making it seem like a blank spot and the aline is moving becasue I'm painting after the update an aslien in a new Y coordinate.
	call UpdateShot ;proc to ipdate the shot and printing on the shot a black spot same as the backgroung, making it seem like a blank spot and the shot is moving because I'm painting after the update a shot in a new Y coordinate.
	mov [playerXPos],  100 ;reset the player X coordinate.
	mov [playerYPos], 120 ;reset the player Y coordinate.
	call PaintPlayer ;proc to paint the player in a given X Y coordinates (in this case the coordinates I set were playerXPos to 100 and playerYPos to 120).
	mov [playerIndex],  0 ;index to navigate in the player sprite array and checking if the value is 0 or 1 (0 skip that pixel on those X & Y, 1 paint that pixel on those X & Y coordinates).
	mov [alienYPos], 20 ;resetting the Y coordinate of the alien so when I choose Retry it wont continue moving from a further (larger) Y coordinate and ruin the game becasue it will make the player to lose a heart when it arrives to it's end of movement (down part of the screen).
	mov [unitHits], 0 ;ressetting the unit digit of the score printed while game is running.
	mov [tensHits], 0 ;ressetting the tens digit of the score printed while game is running.
	mov [lifesCounter], 3 ;resetting the lifes counter to 3 because you start again with 3 hearts like in the beginning of the program when you run the program.
	call PaintHearts ;setting the screen graphics with the 3 hearts on the top right corner.
	call PrintStrings ;setting the screen strings to default (Score: 00) 
	loopA:
	call RandomPosGenerator
	call MoveAlien
	call PaintPlayer
	jmp loopA
endp GameLoop

;;;;;;;;;;;
;Proc to print the Pilot name string plus the player name that the player enterd from the EnterNameProc with the array PlayerName.
;;;;;;;;;;;
proc DrawPilotName
	;PrintText 1, 53, whileGamePlayerName
	mov [pilotNameTextXPos], 53
	mov [pilotNameIndex], 0
	paintPilotNameWithColor:
	mov ah,2
	mov bh,0
	mov dl,[pilotNameTextXPos] ;X position for the game over text.
	mov dh,1 ; The Y position for the gameover text.
	int 10h
	mov ah, 09h
	mov si, [pilotNameIndex]
	mov al, [whileGamePlayerName + si]
	mov bh, 00h
	mov bl, 11
	mov cx, 1
	int 10h
	inc [pilotNameTextXPos]
	inc [pilotNameIndex]
	cmp [pilotNameIndex], 11
	jne paintPilotNameWithColor
	mov bl,' ' ; the character count in the buffer is from the 2nd byte in the input buffer, so the 2  bytes (1 and 0) before it are byte 1 = length of the input.
	mov [PlayerName + 0], bl
	mov [PlayerName + 1], bl
	PrintText 1, 64, PlayerName
	ret
endp DrawPilotName

;;;;;;;;;;;
;Proc to ask the player to enter his name and put the input in the ready and empty array called PlayerName.
;;;;;;;;;;;
proc EnterName
	LoopOnName:
	PrintText 8,7,AskPlayerName

	;Receive player name from the user
	mov ah, 0Ah
	mov dx, offset PlayerName
	int 21h

	mov bl, [PlayerName + 1]
	cmp bl, 0	;Check that input is not empty
	jz LoopOnName
	
	ClearScreen
	call GameLoop
endp EnterName


 	
;;;;;;;;;;;
;Proc to print the score string to the screen in accordance with the actual running game score.
;;;;;;;;;;;
proc PrintStrings
	 push ax
	 
	 cmp [unitHits], 9 ;checks if the score unit counter is greater then 9 if it is it's time to print the score's tens number and reset the score's unit counter.
	 jng printUnitsScore ;print score unit counter in it's postion.
	 mov [unitHits], 0
	 inc [tensHits]
	 inc [score]
	 ConvertDecimal [tensHits], ax
	 mov dx, 7
	 mov si, dx
	 mov [displayHits + si], ah
	 printUnitsScore:       ;this label always works because it's the score's units label so every time the player hits the aliens the scores increases by 1.
	 ConvertDecimal [unitHits], ax
	 inc [score]
	 mov dx, 8
	 mov si, dx
	 mov [displayHits + si], ah
	
	PrintText 1 , 41 , displayHits


	pop ax
	ret   
endp PrintStrings

;;;;;;;;;;;
;Proc that responsible to all the player movemnet, player inputs, movement of the aliens, checking for shots in the screen, checking for alien reaching end of movement so as the shot, updating score live accordingly to the actual running game, all of these actions running simultaneously with the system time (clock, checking it's 1/100 seccond that is stored in dl).
;;;;;;;;;;;
proc MoveAlien
	mov [hitedPlayer], 0 ;resetting the color of the player to it's default.
		CheckTimeAlien:
		mov ah, 2Ch ;command to get the system time (retrieves DOS maintained clock time).
		int 21h ;execute
		
		
		cmp dl, [timeAuxAlien]
		je CheckTimeAlien
		;if I put here the UpdateShot1Proc it will go crazy because dl stores the value of the milliseconds so the Y position of the shot won't be correct
		mov [timeAuxAlien], dl
		call PaintPlayer ; creating the red blink effect when alien hits the player.
		cmp [shotStatus], 1
		je proceedMoveShot
		jmp continueMovingProcess
		proceedMoveShot:
		call UpdateShot
		sub [shotYPos], 3
		call DrawShot
		call CheckForShotHit
		call IsKeyPressed
		cmp [shotHit], 1
		je middleLabel2Hit
		cmp [shotYPos], 20
		jg continueMovingProcess
		;resets the shot if it reached it's end
		mov [shotReachedEnd], 1
		call UpdateShot
		mov [shotStatus], 0
		continueMovingProcess:
		call UpdateAlien
		add [alienYPos], 2
		call PaintAlien
		call CheckForShotHit
		call CheckForAlienCollisions
		call IsKeyPressed
		cmp [shotHit], 1
		je HIT
		cmp [alienHit], 1
		je hitPlayer
		cmp [alienYPos], 195
		jng continueMovingAlien
		dec [lifesCounter]
		call UpdateAlien
		call UpdateHeartFilling
		sub [heartXPos], 13
		mov [alienYPos], 20 ;so the alien won't continue with it's Y position and won't continue after he reached his end of Y axis movement (y = 195).
		call CheckForGameOver
		ret
	middleLabel2Hit:
		jmp HIT
		continueMovingAlien:
		jmp CheckTimeAlien
		hitPlayer:
		dec [lifesCounter]
		call UpdateAlien
		call UpdatePlayer
		call UpdateHeartFilling
		call CheckForGameOver
		sub [heartXPos], 13
		mov [hitedPlayer], 1
		call PaintPlayer ; the variabel hitedPlayer will say the proc PaintPlayer to paint the player with red color.
		mov [alienYPos], 20
		mov [alienHit], 0
		ret
		HIT:
		inc [unitHits]
		call UpdateAlien
		call UpdateShot
		mov [alienYPos], 20 ;this is for the random position generator so that the alien wouldn't continue his movement from the last y postion (and just random it's x position) if the shot hits him. 
		mov [shotStatus], 0
		call PrintStrings
		ret
endp MoveAlien

;;;;;;;;;;;
;Proc to print NewHighScore text that works accordingly to the CheckForGameOver proc
;;;;;;;;;;;
proc PaintNewHighScore
	mov [newHighScoreTextXPos], 6 ;resetting the X coordinate of the newHighScoreText.
	mov [newHighScoreTextIndex], 0 ;resetting the index for navigation in the newHighScoreText string.
	paintNewHighScoreLoop:
	ConvertDecimal [tensHits], ax
	 mov dx, 26
	 mov si, dx
	 mov [NewHighScoreText + si], ah
	 ConvertDecimal [unitHits], ax
	 mov dx, 27
	 mov si, dx
	 mov [NewHighScoreText + si], ah
	 mov ah,2
	mov bh,0
	mov dl,[newHighScoreTextXPos] ;X position for the game over text.
	mov dh,13 ; The Y position for the gameover text.
	int 10h
	mov ah, 09h
	mov si, [newHighScoreTextIndex]
	mov al, [NewHighScoreText + si]
	mov bh, 00h
	mov bl, 14
	mov cx, 1
	int 10h
	inc [newHighScoreTextXPos]
	inc [newHighScoreTextIndex]
	cmp [newHighScoreTextIndex], 28
	jne paintNewHighScoreLoop
	ret
endp PaintNewHighScore

;;;;;;;;;;;
;Proc check if it's game over and the player got 0 lives, if it's not just return and if it is, print the right screen for the game over (game over screen, if it's a new high score put the new high score in the scores.txt file instead of the last score there and print "We Have A new High Score:" string with the score a side with this string). In addition, printing the Retry and Exit options and allowing to naigate between those options using the 'a' and 'd' keys, 'a' to choose the left option (Exit) and 'd' to choose the right option (Retry).
;;;;;;;;;;;
proc CheckForGameOver
	cmp [lifesCounter], 0
	je gameOverScreen
	ret
gameOverScreen:
	ClearScreen

	mov [gameOverTextXPos], 16
	mov [gameOverIndex], 0
	mov [retryTextXPos], 34
	mov [retryIndex], 0
	mov [exitTextXPos], 1
	mov [exitIndex], 0
	paintGameOverWithColor:
	mov ah,2
	mov bh,0
	mov dl,[gameOverTextXPos] ;X position for the game over text.
	mov dh,11 ; The Y position for the gameover text.
	int 10h
	mov ah, 09h
	mov si, [gameOverIndex]
	mov al, [GameOverText + si]
	mov bh, 00h
	mov bl, 4
	mov cx, 1
	int 10h
	inc [gameOverTextXPos]
	inc [gameOverIndex]
	cmp [gameOverIndex], 8
	jne paintGameOverWithColor
	 
	 call OpenFile
	 call ReadFile
	 cmp [betterScore], 0
	 jne printRegularFinalScore
	 call OpenFile
	 call DeleteFileData
	 call CloseFile
	 ConvertDecimal [tensHits], bx
	 mov si, 0
	 mov [NewScore + si], bh
	 ConvertDecimal [unitHits], bx
	 mov si, 1
	 mov [NewScore + si], bh
	 mov al, 1        ; relative to current file position
     mov ah, 42h      ; service for seeking file pointer
     mov bx, [scoresFileHandle] ;file handle
     mov cx, -1      ; upper half of lseek 32-bit offset (cx:dx) high order word of number of bytes to move
     mov dx, -2       ; moves file pointer one byte backwards (This is important) low order word of number of bytes to move
     int 21h ;execute (seeks to specified location in file).
	 call OpenFile
	 call WriteToFile
	 call CloseFile
	 call PaintNewHighScore
	 jmp continuePrinting
	 printRegularFinalScore:
	 call CloseFile
	 ConvertDecimal [tensHits], ax
	 mov dx, 21
	 mov si, dx
	 mov [FinalScoreText + si], ah
	 ConvertDecimal [unitHits], ax
	 mov dx, 22
	 mov si, dx
	 mov [FinalScoreText + si], ah
	 PrintText 13, 9, FinalScoreText, 1
	continuePrinting:
	paintRetryWithColor:
	mov ah,2
	mov bh,0
	mov dl,[retryTextXPos]
	mov dh,20
	int 10h
	mov ah, 09h
	mov si, [retryIndex]
	mov al, [RetryText + si]
	mov bh, 00h
	mov bl, 11
	mov cx, 1
	int 10h
	inc [retryTextXPos]
	inc [retryIndex]
	cmp [retryIndex], 5
	jne paintRetryWithColor
	
	paintExitTextWithColor:
	mov ah,2
	mov bh,0
	mov dl,[exitTextXPos]
	mov dh,20
	int 10h
	mov ah, 09h
	mov si, [exitIndex]
	mov al, [ExitText + si]
	mov bh, 00h
	mov bl, 15
	mov cx, 1
	int 10h
	inc [exitTextXPos]
	inc [exitIndex]
	cmp [exitIndex], 4
	jne paintExitTextWithColor
	
	checkRetryOrExit:
	mov [spaceJump], 0
	mov ah,0Ch
	mov al,07h
	int 21h
	cmp al, 'a'
	je markExitText
	cmp al, 'd'
	je markRetryText
	cmp al, 20h
	je middleheckSpaceOptions
	jmp markRetryText
middleheckSpaceOptions:
	mov [spaceJump], 1
	jmp middleLabel2Jump
	markRetryText:
	mov [exitColor], 15
	mov [retryColor], 11
	mov [exitIndex], 0
	mov [retryIndex], 0
	mov [retryTextXPos], 34
	mov [exitTextXPos], 1
	jmp checkpaintRetryWithColor
	markExitText:
	mov [exitColor], 11
	mov [retryColor], 15
	mov [exitIndex], 0
	mov [retryIndex], 0
	mov [retryTextXPos], 34
	mov [exitTextXPos], 1
	checkpaintRetryWithColor:
	mov ah,2h
	mov bh,0
	mov dl,[retryTextXPos]
	mov dh,20
	int 10h
middleLabel2Jump:
	cmp [spaceJump], 1
	je checkSpaceOptions
	mov ah, 09h
	mov si, [retryIndex]
	mov al, [RetryText + si]
	mov bh, 00h
	mov bl, [retryColor]
	mov cx, 1
	int 10h
	inc [retryTextXPos]
	inc [retryIndex]
	cmp [retryIndex], 5
	jne checkpaintRetryWithColor
	checkpaintExitTextWithColor:
	mov ah,2
	mov bh,0
	mov dl,[exitTextXPos]
	mov dh,20
	int 10h
	mov ah, 09h
	mov si, [exitIndex]
	mov al, [ExitText + si]
	mov bh, 00h
	mov bl, [exitColor]
	mov cx, 1
	int 10h
	inc [exitTextXPos]
	inc [exitIndex]
	cmp [exitIndex], 4
	jne checkpaintExitTextWithColor

	cmp [spaceJump], 1 ;if it's equal to 1 that means the player pressed on the retry button or the exit button. If not it's needs to continue checking for presses.
	jne continueChecking
	checkSpaceOptions:
	cmp [exitColor], 11
	je exitGame
	ClearScreen
	call GameLoop
	jmp checkRetryOrExit
	exitGame:
	call Exit
continueChecking:
	jmp checkRetryOrExit
	ret
endp CheckForGameOver

;;;;;;;;;;;
;Proc to open a given file, returns the file handle to ax and from there to the scoreFileHandle variable, if the file didn't succedded in it's openning, print error message. 
;;;;;;;;;;;
proc OpenFile
	; Open file
	;push ax
	mov ah, 3Dh
	mov al, 2
	lea dx, [scoresFile]
	int 21h
	jc openerror
	mov [scoresFileHandle], ax
	ret
	openerror:
	mov dx, offset ErrorMsg
	mov ah, 9h
	int 21h
	;pop ax
	ret
endp OpenFile

;;;;;;;;;;;
;Proc to read data from the file byte after byte and checking if the tens digit of the number in the file (2 digits number) is greater than the actual running game score tens digit, if it is put the value 1 in the boolean variable betterScore, that means that the score in the txt file is better than the actual running game score. If the tens digit of the number in the file is equal to the actual running game score check the unit digits; if the acutal running game score is greater after all the checking put the value 0 in the boolean variable betterScore, that means the actual running game score is greater than the score in the txt file.
;;;;;;;;;;;
proc ReadFile ;reads the file data and checks it againts the actual score. I'm not using here the stack becasue I need the variables to be global like the betterScore var or the tensHits var, I need to get them after they changed.
	;Read file
	loopCheckFile:
	xor dx, dx ;reseting dx register.
	mov ah,3Fh ;command to read from file.
	mov bx, [scoresFileHandle] ;bx contains the file hndle for the scores.txt file.
	mov cx,1 ;reading 1 byte (cx stores how many bytes we want to read from the file).
	mov dx, offset readScoreBuffer ;dx is a pointer to the "readScoreBuffer" 
	int 21h ;execute
	mov cx, [readScoreBuffer]
	sub cx, 0030h ;converting the ascii number stored in cx from readScoreBuffer to decimal number for instance: 0035h = 5 in decimal so 0035h - 0030h = 0005h = 5 in decimal.
	cmp cl, [tensHits]
	jg returnTrue
	cmp cl, [tensHits]
	je checkUnit
	cmp cl, [tensHits]
	jl returnFalse
	checkUnit:
	xor dx, dx
	mov ah,3Fh
	mov bx, [scoresFileHandle]
	mov cx,1 ;reading 1 byte (cx stores how many bytes we want to read from the file).
	mov dx, offset readScoreBuffer;[offset scoresBuffer+si]
	int 21h ;execute
	mov cx, [readScoreBuffer]
	sub cx, 0030h
	cmp cl, [unitHits]
	jg returnTrue
	returnFalse:
	mov [betterScore], 0 ;if the actual running game score is greater than the score stored in the scores.txt file.
	ret
	returnTrue:
	mov [betterScore], 1 ;if the score stored in the scores.txt file is greater than the actual running game score.
	ret
endp ReadFile

;;;;;;;;;;;
;Proc to write data to scores.txt file using the NewScore array we have got from the CheckForGameOver proc if the check from the ReadFile proc putted 0 in the boolean varibale betterScore (the actual running game score is greater than the score stored in the scores.txt file).
;;;;;;;;;;;
proc WriteToFile
	mov ah,40h
	mov bx, [scoresFileHandle]
	mov cx,2 ;writing 2 bytes, 2 numbers tens digit and unit digits
	mov dx,offset NewScore ;array from which the data will be copied to the file.
	int 21h ;execute
	mov ah,40h
	mov bx, [scoresFileHandle]
	mov cx,6 ;writing 2 bytes, 2 numbers tens digit and unit digits
	mov dx,offset PlayerName ;array from which the data will be copied to the file.
	int 21h ;execute
	ret
endp WriteToFile

;;;;;;;;;;;
;Proc to delete file data.
;;;;;;;;;;;
proc DeleteFileData
	mov ah,40h ;command to 
	mov bx, [scoresFileHandle]
	mov cx,0 ;deletes data in file
	mov dx,0
	int 21h ;execute
endp DeleteFileData
;;;;;;;;;;;
;Proc to the File, helps us save the changes we made to the file right after we made them. So if the player picks the Retry button in the gameover screen and he scored a new high score in the last game, the new high score will be saved in the scores.txt file.
;;;;;;;;;;;
proc CloseFile
	mov ah,3Eh ;command to close the file
	mov bx, [scoresFileHandle] ; file handle to close
	int 21h ;execute
	ret
endp CloseFile

;proc DelayAliens
;	mov bx, 40h
;	mov es, bx
;	mov bx, [Clock] ;setting the time that will be checked as the previous time in dx, now dx contains the first time before the first tick
;	FirstTick:
;	cmp bx, [Clock] ;comparing if the previous time is equal to the current time
;	je FirstTick ; if it is check again
;	mov cx, 2 ; 27x0.055sec = ~1.5sec
;	
;	DelayLoop:
;	
;	mov bx, [Clock]
;	Tick:
;	;call IsKeyPressed ;checking if any key is pressed while the aliens are moving, I'm doing this here instead of everything in the main label because I to make the aliens move faster if the player is moving. If the player moved this means that he pressed a movement key, in this case the call to IsKeyPressed proc returns a lot faster than if the player didn't press a movement key this is working because the delay loop is created the way that there isn't a long proccess to do in the delay loop and if the player doesn't press a movement key the delay will be normal because it's faster to not move the player with calling another proc and another and wait for them to return. If the player pressed a movement key, it's taking some time to return from all the calls for the proc, like drawing, updating (it's drawing and then updating and then returning to this line, this takes a couple of milliseconds) if the player didn't press any of the movement key it's returning right back to this line and continues the delay.
;	cmp bx, [Clock]
;	je Tick
;	loop DelayLoop
;	ret
;endp DelayAliens	
	
;;;;;;;;;;;
;Proc to paint the alien in a given X & Y coordinates.
;;;;;;;;;;;
proc PaintAlien
	mov bl, [alienColor]
	mov [paintColor], bl
	mov [alienIndex], 0
	mov [alienYCounter], 0
	mov ax, [alienYPos]
	mov [paint_Y], ax
Loop_PaintAlien_Y:
	mov [alienXCounter], 0
	mov ax, [alienXPos]
	mov [paint_X], ax
Loop_PaintAlien_X:
	mov dx, [alienIndex]
	mov si, dx
	mov bl, [alien + si]
	inc [alienIndex]
	mov [alienPixel], bl
	cmp [alienPixel], 0
	je SkipPaintAlienPixel
	call Draw_Pixel
SkipPaintAlienPixel:
	inc [alienXCounter]
	inc [paint_X]
	mov bx, [alienXCounter]
	cmp [alienXLength], bx
	jne Loop_PaintAlien_X
	inc [alienYCounter]
	inc [paint_Y]
	mov bx, [alienYCounter]
	cmp [alienYLength], bx
	jne Loop_PaintAlien_Y
	ret
endp PaintAlien

;;;;;;;;;;;
;Proc to paint a pixel on the screen using the paint_X variable and paint_Y variable to set the coordinates to where on the screen should the pixel be painted.
;;;;;;;;;;;
proc Draw_Pixel
	mov BH,0h 					 ;set the page number
	mov cx, [paint_X]
	mov dx, [paint_Y]
	mov AL,[paintColor]				 ;color of what I defined when I called the proc, it;s like a parameter.
	mov AH,0Ch                   ;set the configuration to writing a pixel
	int 10h
	ret
endp Draw_Pixel

;;;;;;;;;;;
;Proc to update alien and painting on it's last Y and X coordinates (before they changed) a black spot to create a blank space in the last location it was it (black as the backgroung color).
;;;;;;;;;;;
proc UpdateAlien
	mov bl, [colorBg]
	mov [paintColor], bl
	mov [alienIndex], 0
	mov [alienYCounter], 0
	mov ax, [alienYPos]
	mov [paint_Y], ax
Loop_UpdateAlien_Y:
	mov [alienXCounter], 0
	mov ax, [alienXPos]
	mov [paint_X], ax
Loop_UpdateAlien_X:
	call Draw_Pixel
	inc [alienXCounter]
	inc [paint_X]
	mov bx, [alienXCounter]
	cmp [alienXLength], bx
	jne Loop_UpdateAlien_X
	inc [alienYCounter]
	inc [paint_Y]
	mov bx, [alienYCounter]
	cmp [alienYLength], bx
	jne Loop_UpdateAlien_Y 
	ret
endp UpdateAlien

;;;;;;;;;;;
;Proc to paint the hearts sprites, outline and filling of them.
;;;;;;;;;;;
proc PaintHearts
mov [paintHeartsCounter], 3
paintHeartsLoop:
	call PaintHeartOutline
	call PaintHeartFilling
	add [heartXPos], 13
	dec [paintHeartsCounter]
	cmp [paintHeartsCounter], 0
	jne paintHeartsLoop
	sub [heartXPos], 13
	ret
endp PaintHearts

;;;;;;;;;;;
;Proc to paint the outline of the hearts.
;;;;;;;;;;;
proc PaintHeartOutline
	mov bl, [heartOutlineColor]
	mov [paintColor], bl
	mov [heartIndex], 0
	mov [heartYCounter], 0
	mov ax, [heartYPos]
	mov [paint_Y], ax
Loop_PaintHeartOutline_Y:
	mov [heartXCounter], 0
	mov ax, [heartXPos]
	mov [paint_X], ax
Loop_PaintHeartOutline_X:
	mov dx, [heartIndex]
	mov si, dx
	mov bl, [heartOutline + si]
	inc [heartIndex]
	mov [heartPixel], bl
	cmp [heartPixel], 0
	je SkipPaintHeartOutlinePixel
	call Draw_Pixel
SkipPaintHeartOutlinePixel:
	inc [heartXCounter]
	inc [paint_X]
	mov bx, [heartXCounter]
	cmp [heartXLength], bx
	jne Loop_PaintHeartOutline_X
	inc [heartYCounter]
	inc [paint_Y]
	mov bx, [heartYCounter]
	cmp [heartYLength], bx
	jne Loop_PaintHeartOutline_Y
	ret
endp PaintHeartOutline

;;;;;;;;;;;
;Proc to paint the hearts filling.
;;;;;;;;;;;
proc PaintHeartFilling
	mov bl, [heartFillingColor]
	mov [paintColor], bl
	mov [heartIndex], 0
	mov [heartYCounter], 0
	mov ax, [heartYPos]
	mov [paint_Y], ax
Loop_PaintHeartFilling_Y:
	mov [heartXCounter], 0
	mov ax, [heartXPos]
	mov [paint_X], ax
Loop_PaintHeartFilling_X:
	mov dx, [heartIndex]
	mov si, dx
	mov bl, [heartFilling + si]
	inc [heartIndex]
	mov [heartPixel], bl
	cmp [heartPixel], 0
	je SkipPaintHeartFillingPixel
	call Draw_Pixel
SkipPaintHeartFillingPixel:
	inc [heartXCounter]
	inc [paint_X]
	mov bx, [heartXCounter]
	cmp [heartXLength], bx
	jne Loop_PaintHeartFilling_X
	inc [heartYCounter]
	inc [paint_Y]
	mov bx, [heartYCounter]
	cmp [heartYLength], bx
	jne Loop_PaintHeartFilling_Y
	ret
endp PaintHeartFilling

;;;;;;;;;;;
;Proc to update heart filling when the player got hited by the alien or the alien reached it's end of movement on the screen according to the MoveMlien proc, if it hited the player or reached it's end of movement on the screen reduce the lifesCounter of the player and update heart filling.
;;;;;;;;;;;
proc UpdateHeartFilling
	mov bl, [colorBg]
	mov [paintColor], bl
	mov [heartIndex], 0
	mov [heartYCounter], 0
	mov ax, [heartYPos]
	mov [paint_Y], ax
Loop_UpdateHeartFilling_Y:
	mov [heartXCounter], 0
	mov ax, [heartXPos]
	mov [paint_X], ax
Loop_UpdateHeartFilling_X:
	mov dx, [heartIndex]
	mov si, dx
	mov bl, [heartFilling + si]
	inc [heartIndex]
	mov [heartPixel], bl
	cmp [heartPixel], 0
	je SkipUpdateHeartFillingPixel
	call Draw_Pixel
SkipUpdateHeartFillingPixel:
	inc [heartXCounter]
	inc [paint_X]
	mov bx, [heartXCounter]
	cmp [heartXLength], bx
	jne Loop_UpdateHeartFilling_X
	inc [heartYCounter]
	inc [paint_Y]
	mov bx, [heartYCounter]
	cmp [heartYLength], bx
	jne Loop_UpdateHeartFilling_Y
	ret
endp UpdateHeartFilling

;;;;;;;;;;;
;Proc to paint player in a given X & Y coordinates
;;;;;;;;;;;
proc PaintPlayer
	cmp [hitedPlayer], 1
	jne regularColor
	mov bl, 4
	jmp startPainting
	regularColor:
	mov bl, [playerColor]
	startPainting:
	mov [paintColor], bl
	mov [playerIndex], 0
	mov [playerYCounter], 0
	mov ax, [playerYPos]
	mov [paint_Y], ax
Loop_PaintPlayer_Y:
	mov [playerXCounter], 0
	mov ax, [playerXPos]
	mov [paint_X], ax
Loop_PaintPlayer_X:
	mov dx, [playerIndex]
	mov si, dx
	mov bl, [player + si]
	inc [playerIndex]
	mov [playerPixel], bl
	cmp [playerPixel], 0
	je SkipPaintPlayerPixel
	call Draw_Pixel
SkipPaintPlayerPixel:
	inc [playerXCounter]
	inc [paint_X]
	mov bx, [playerXCounter]
	cmp [playerXLength], bx
	jne Loop_PaintPlayer_X
	inc [playerYCounter]
	inc [paint_Y]
	mov bx, [playerYCounter]
	cmp [playerYLength], bx
	jne Loop_PaintPlayer_Y
	ret
endp PaintPlayer

;;;;;;;;;;;
;Proc to update player in it's last location he was in (X & Y coordinates), updating with painting a black spot on the last location the player was in (black same s the backgroung color).
;;;;;;;;;;;
proc UpdatePlayer ;drawing a blank spot where is the characer before we change the yPos or the xPos
	mov bl, [colorBg]
	mov [paintColor], bl
	mov [playerIndex], 0
	mov [playerYCounter], 0
	mov ax, [playerYPos]
	mov [paint_Y], ax
Loop_UpdatePlayer_Y:
	mov [playerXCounter], 0
	mov ax, [playerXPos]
	mov [paint_X], ax
Loop_UpdatePlayer_X:
	call Draw_Pixel
	inc [playerXCounter]
	inc [paint_X]
	mov bx, [playerXCounter]
	cmp [playerXLength], bx
	jne Loop_UpdatePlayer_X
	inc [playerYCounter]
	inc [paint_Y]
	mov bx, [playerYCounter]
	cmp [playerYLength], bx
	jne Loop_UpdatePlayer_Y
	ret
endp UpdatePlayer

;;;;;;;;;;;
;Proc to check if a key was pressed and if it was, act accordingly.
;;;;;;;;;;;
proc IsKeyPressed
	mov [cantGoFurther], 0
	ifKeyPressed:
	
	
	
	mov ah, 1h ;check keystroke status from the keyboard buffer (if the carry flag/zero flag isn't set to 1, the user had pressed a key).
	int 16h ;interrupt for functions that are related to the keyboard buffer.
	jz outy ;jump if no key is pressed. checks the ZF = Zero Flag at the start of the project I tried to check the cf = carry flag but it's sets it every time and then when I setes it it doesn't change. If not store the keystroke in al and remove it from the buffer with ah = 00h / int 16h.
	
	mov ah,00h ;swallow the al value (checks which key is being pressed), get keystroke from keyboard with no echo.
	int 16h
	
	
	mov [saveKey], al ;The ascii character of swallowing the value of the pressed key is stored in al.
	
	cmp [playerYPos], 190
	je endOfPlayerMovement
	
	cmp [playerYPos], 20
	jne allGood
	mov [cantGoFurther], 1
	
	allGood:
	
	cmp [saveKey],73h
	je isMoveDown
	
	endOfPlayerMovement:
	cmp [shotStatus], 1
	je dontShoot
	cmp [saveKey],20h
	je middleLabelShoot
	
	cmp [cantGoFurther], 1
	je dontGoUp
	dontShoot:
	cmp [saveKey],77h
	je isMoveUp
	
	dontGoUp:
	cmp [saveKey],61h
	je isMoveLeft
	
	cmp [saveKey],64h
	je isMoveRight
	
	
	
outy: ;return to the MoveShot proc if no key has been pressed. This helps for the movement of the shot and aliens. The shot doesn't need to wait till the end of the proc to continue moving if no key is pressed and not different from that, the delay of the movement for the aliens can continue noramaly (no need to wait for the end of the proc, this effects the delay time because the time till the proc is returning to the aliens movement proc is longer) if no key has been pressed 
ret
middle: ;middle range label to be able to jump to the check time label without out of range error.
mov [flag], 1
ret
	;jmp gameLoop

middleLabelShoot:
jmp isShoot
	ret;if none of the above keystroke has been pressed (w,a,s,d,spaceKey) jump to the game loop and don't move the character
	isMoveUp:
	call UpdatePlayer
	sub [playerYPos], 5
	;dec [playerYPos]
	call PaintPlayer
	ret

	isMoveDown:
	call UpdatePlayer
	add [playerYPos], 5
	;inc [playerYPos]
	call PaintPlayer
	ret
	
	isMoveLeft:
	call UpdatePlayer
	sub [playerXPos], 5
	;dec [playerXPos]
	call PaintPlayer
	ret
	
	isMoveRight:
	call UpdatePlayer
	add [playerXPos], 5
	;inc [playerXPos]
	call PaintPlayer
	ret
	
	isShoot:
	mov [shotStatus], 1
	mov bx, [playerXPos]
	mov [shotXPos], bx
	mov ax, [playerYPos]
	mov [shotYPos], ax
	add [shotXPos], 3
	sub [shotYPos], 4
	;dec [shotYPos]
	call DrawShot
	ret
endp IsKeyPressed

;;;;;;;;;;;
;Proc to update shot in the last location it was in (X & Y coordinates). It's updating the shot with painting a black spot on where the last location of the shot (black color same as the backgroung color).
;;;;;;;;;;;
proc UpdateShot
	mov bl, [colorBg]
	mov [paintColor], bl
	mov [shotYCounter], 0
	mov ax, [shotYPos]
	mov [paint_Y], ax
Loop_UpdateShot_Y:
	mov [shotXCounter], 0
	mov ax, [shotXPos]
	mov [paint_X], ax
Loop_UpdateShot_X:
	call Draw_Pixel
	inc [shotXCounter]
	inc [paint_X]
	mov bx, [shotXCounter]
	cmp [shotXLength], bx
	jne Loop_UpdateShot_X
	inc [shotYCounter]
	inc [paint_Y]
	mov bx, [shotYCounter]
	cmp [shotYLength], bx
	jne Loop_UpdateShot_Y
	ret
endp UpdateShot

;;;;;;;;;;;
;Proc to draw the shot in a given X & Y coordinates.
;;;;;;;;;;;
proc DrawShot                 	
	mov bl, [shotColor]
	mov [paintColor], bl
	mov [shotIndex], 0
	mov [shotYCounter], 0
	mov ax, [shotYPos]
	mov [paint_Y], ax
Loop_PaintShot_Y:
	mov [shotXCounter], 0
	mov ax, [shotXPos]
	mov [paint_X], ax
Loop_PaintShot_X:
	mov dx, [shotIndex]
	mov si, dx
	mov bl, [shot + si]
	inc [shotIndex]
	mov [shotPixel], bl
	cmp [shotPixel], 0
	je SkipPaintShotPixel
	call Draw_Pixel
SkipPaintShotPixel:
	inc [shotXCounter]
	inc [paint_X]
	mov bx, [shotXCounter]
	cmp [shotXLength], bx
	jne Loop_PaintShot_X
	inc [shotYCounter]
	inc [paint_Y]
	mov bx, [shotYCounter]
	cmp [shotYLength], bx
	jne Loop_PaintShot_Y
		
	ret
endp DrawShot

;;;;;;;;;;;
;Proc to check for shot collisions and act accordingly.
;;;;;;;;;;;
proc CheckForShotHit
	mov bh,0h
	mov cx,[shotXPos] ;checks for collision of the left corner of the shot with the alien through color (if the shot is under the color of the alien it's a collision! because I read the color value of the pixel on the shot left corner positions).
	mov dx,[shotYPos]
	dec dx ; to prevent the effect on the shotYPos variable
	mov ah,0Dh ;this command (from the BIOS interrupt) reads the color value of the pixel at CX:DX positions on the screen
	int 10h ; return al the pixel value read
	cmp al, [alienColor]
	je hitAlien
	mov bh,0h
	mov cx,[shotXPos]
	add cx, 4 ;checks for collision of the right corner of the shot with alien through color.
	mov dx,[shotYPos]
	dec dx ; to prevent the effect on te=he shotYPos variable
	mov ah,0Dh ;this command (from the BIOS interrupt) reads the color value of the pixel at CX:DX positions on the screen
	int 10h ; return al the pixel value read
	cmp al, [alienColor]
	je hitAlien
	noHit:
	mov [shotHit], 0
	ret
	hitAlien:
	mov [shotHit], 1
	ret
endp CheckForShotHit

;;;;;;;;;;;
;Proc to checek for alien collisions with the player.
;;;;;;;;;;;
proc CheckForAlienCollisions
middlCheck:
	mov bh, 0h
	mov cx, [alienXPos]
	add cx, 5
	mov dx, [alienYPos]
	add dx, 10
	mov ah, 0Dh
	int 10h
	cmp al, [playerColor]
	je playerCollision
leftCheck:
	mov bh, 0h
	mov cx, [alienXPos]
	dec cx
	mov dx, [alienYPos]
	mov ah, 0Dh
	int 10h
	cmp al, [playerColor]
	je playerCollision
rightCheck:
	mov bh, 0h
	mov cx, [alienXPos]
	add cx, 10
	mov dx, [alienYPos]
	mov ah, 0Dh
	int 10h
	cmp al, [playerColor]
	je playerCollision
	noCollision:
	mov [alienHit], 0
	ret
	playerCollision:
	mov [alienHit], 1
	ret
endp CheckForAlienCollisions

;;;;;;;;;;;
;Proc creates pseudo random numbers for the X coordinate of the alien.
;;;;;;;;;;;
proc RandomPosGenerator
	;generate a raandom number using the system time
	randStart:
	mov ah, 00h ;interrups to get system time
	int 1ah ;cx:dx now hold number of clock ticks since midnight
	
	mov ax, dx
	xor dx, dx
	mov cx, 309 ;cx contains the most significant 16 bit values (as you can see the 44 is actuallt 45 because the counting starts at 0), now cx contains the limit for the randomness for the aliens apearences.
	div cx ;here dx contains the remainder of the division - from 0 - 45
	add dl, '0' ;0 = 30h
	mov [alienXPos], dx

	
	ret
endp RandomPosGenerator



	
	

	
	
	
	
;;;;;;;;;;;
;Proc to print exit message and exit the program.
;;;;;;;;;;;
proc Exit
ClearScreen
paintCUText:
	mov ah,2
	mov bh,0
	mov dl,[cUTextXPos]
	mov dh,11
	int 10h
	mov ah, 09h
	mov si, [cUIndex]
	mov al, [CUText + si]
	mov bh, 00h
	mov bl, 9
	mov cx, 1
	int 10h
	inc [cUTextXPos]
	inc [cUIndex]
	cmp [cUIndex], 13
	jne paintCUText
exitLabel:
	mov ax, 4c00h
	int 21h
endp Exit

;Start of the program
start:
	mov ax, @data
	mov ds, ax
	
	;call RandomPosGenerator
	
	;;;;;;;;;;;;;;;;;;;;;;;;;;;;;; Screen Configuration
	;printing the window
	mov ah, 00h ;set video mode
	mov al, 13h ; set window mode: size (320*200) and 256 color
	int 10h ;set configurations of the window mode and size.
	;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
	
	call OpenningScreen
	call EnterName



END start


