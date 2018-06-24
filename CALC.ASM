jmp start
;You have to clear it after every process

;These are user-defined variables to compensate for the lack of registers
firstD db 0 ;For the first number inputted
seconD db 1 ;For the second number inputted
ans dw 		;Stores the answer
op db 0 	;The operation to be done
fstD db ' ' ;Stores the first digit of the answer
sndD db ' ' ;Stores the second digit of the answer
thrD db ' ' ;Stores the third digit of the answer
fthD db ' ' ;Stores the fourth digit of the answer



start:
mov ax,0006h 						;set DOS Box to Graphics Mode. 200 x 640 resolution
int 10h		 

mov dx,0000h 						;For the lines
mov cx,320   						;Specific to the line in the middle of the screen
mov ax,0cffh 						;ah = 0c the function for inputting the pixel, al = ffh for the color

borderr:							;make border in the middle of sckren
	mov ax,0cffh					;ah = 0c the function for inputtiing the pixel, al = ffh for color
	int 10h
	inc dx							;For printing pixel by pixel. DX is the y axis
	cmp dx,200						;200 is the limit of the screen
jb borderr

mov dx,40							;y-location of the screen for horizontal lines 
horr:								;makes the horizontal lines in the calculator 
	mov cx,0						;x-location of the screen for the horizontal line
	hor:
		mov ax,0cffh
		int 10h
		inc cx
		cmp cx,320
	jb hor
	add dx,40
	cmp dx,200
jb horr 

mov cx,80		;x-location of the screen for vertical lines.
ver: 			;makes the vertical lines in the calculator
	mov dx,40   ;y-location of the screen for the vertical lines.
	vert:
		mov ax,0cffh
		int 10h
		inc dx
		cmp dx,200
	jb vert 
	add cx,80 
	cmp cx,320
jb ver

mov bl,1 
mov dh,8
txt:		;Just puts in the numbers and operations you see on the screen
	mov dl,5
	shi:
		mov ah, 02h	;set cursor position
		int 10h
		
		mov ah,00h
		mov al,bl 
		mov bh,4
		div bh
		cmp ah,0  ;cursor is in an operand position('+', '-', 'x', '/')
		je operat 
		cmp bl,14 ;cursor is in bottom 2 squares('=', 'C')
		jge equalD
		jmp num ;cursor is in a number position ('1', '2', ....)
		
		back:
		mov bh,00h	
		mov ah,0eh
		;mov al,'0'
		int 10h		;print chracter at cursor position
		inc bl 
		add dl,10 
	cmp dl,40
	jb shi
	add dh,5
cmp dh,25
jb txt
jmp strt

equalD:
	
	cmp bl,14
	je ikwal
	cmp bl,15
	je klir
ikwal:
	mov al, '='
jmp back
klir:
	mov al, 'C'
jmp back

operat:
	
	cmp bl,4 
	je plusD
	cmp bl,8 
	je minusD
	cmp bl,12 
	je timesD
	cmp bl,16
	je dibaydibaiD
plusD:
	mov al, '+'
jmp back;
minusD:
	mov al, '-'
jmp back
timesD:
	mov al, 'x'
jmp back
dibaydibaiD:
	mov al, '/'
jmp back

num:
	cmp bl,13
	je zeroD
	mov ah,bl
	sub bl,al 
	mov al,bl
	add al,'0'
	mov bl, ah 
jmp back

zeroD:
	mov al, '0'
jmp back
;-------------------------actual calculator logic-------------
strt:
mov di,0                               ;Ctr for how many digits you input
mov si,0
mov ax, 0001h						   ;Setting mouse for input
int 33h 
check:								   ;It's keep looping for input
	and di,1
	mov bh,00h
	mov dh,3
	mov dl,0						   ;line 145 to 151 just sets the cursor for displaying the result
	add dx,di
	mov ah,02h
	int 10h

	mov ax,0003h
	int 33h

	cmp bx,1							;Checks the position of the mouse
	je pos
	
	cmp bx,2							;Right-click to exit
	je exit
	
jmp check

exit:
mov ax, 0002h ;hides the mouse
int 33h 

int 20h

twoDigit:								;Checks for a second digit and stores it in the user-defined variable firstD
	sub al,'0'							;To convert to integer, deduct input with '0'
	mov cl,al							;Acts as temp storage
	mov al,firstD						;Transfers the first inputted digit to al
	mov dl,10							;Multiply first digit by 10
	mul dl								;
	add al,cl							;plus the second digit that was inputted
	mov firstD, al						;Assign back to firstD
	
	mov ah,0eh							;clears the number on display
	mov al,' '
	int 10h
	
	
jmp return

operations:							;Checks for the operation inputted
	mov di,0 
	
	mov ax,dx						;specifically lines 188 - 190
	mov dh,40
	div dh
	
	mov op,al						;Stores the inputted operation in 'op'
	
	mov bh,00h						;sets the cursor to the left on the display (line 194 - 197)
	mov dh,3						
	mov dl,0
	mov ah,02h
	int 10h

	mov ah,08h 						;read characters inputted
	int 10h
	
	sub al,'0'						;convert character to integer
	mov firstD, al					;stores it to firstD
	
	mov ah,0eh						;lines 206 - 208 clears the display
	mov al,' '
	int 10h
	
	mov ah,08h 						;read characters (second digit)
	int 10h
	
	cmp al,'0'						;if(al > '0' && al < '9') then jmp to twoDigit
	jb return
	cmp al,'9'
	ja return    
	jmp twoDigit 
	return:							;For delay purposes
	
	mov cx,500
	delay1:
		mov bx,1000
		delay2:
		dec bx
		nop
		cmp bx,0
		jne delay2
		dec cx
		cmp cx,0
	jne delay1
	
jmp check    						;jumps back and checks for input

pos:								;The first function called when you left click on the mouse
	cmp cx,240						;Recall that the screen is divided into two.
	jb cmpDx						;Marks the numbers section of the calculator
	cmp cx,320						;jump to operations if its in the operation section
	jb operations
jmp check


cmpDx:
	cmp dx,160						;Marks '0' '=' and 'c'
	ja equal
	cmp dx,40						;Marks '1' '2' ... '9'
	ja numb
jmp check

equal:
	cmp cx,160
	ja clear
	cmp cx, 80
	ja equall
	mov al, 0
jmp disp

clear:     							;Function definition for 'C'
	mov bh,00h						;lines 258 - 262 setting the cursor to the left of the display
	mov dh,3
	mov dl,0
	mov ah,02h
	int 10h
	
	mov ah,0eh						;Clears the contents of display (lines 264 - 269)
	mov al,' '
	int 10h
	int 10h
	int 10h
	int 10h
	
	mov firstD,0					;Emptys firstD
	mov seconD,0					;Emptys secondD
	mov op,0						;Emptys the operations
	mov di,0						;Basically everything
jmp check							;Check again for inputs

numb:
	cmp dx,80						
	jb numL1						;below 80 are '1' '2' and '3' above it is '4' '5' and '6'
	cmp dx,120
	ja numL3						;above 120 are '7' '8' and '9'
jmp numL2

numL1:								;function for displaying inputted numbers between '1' '2' and '3'
	mov ax,cx						;lines 286 - 289 is for mapping what and where the value is
	mov dh,80
	div dh
	mov ah,00h
	
	add al,1
cmp di,2
jb disp
jmp check

numL2:								;same story as numL1
	mov ax,cx
	mov dh,80
	div dh
	mov ah,00h
	
	add al,4
cmp di,2
jb disp
jmp check

numL3:								;same story numL1
	mov ax,cx
	mov dh,80
	div dh
	mov ah,00h
	
	add al,7
cmp di,2
jb disp
jmp check

equall:
jmp equals

disp:    							;displays the inputted number
	add al,'0'						;To convert the digit into string
	mov ah,0eh						;displays the digit stored in the register
	int 10h
	add di,1
	
	mov cx,500						;
	delay:
		mov bx,1000
		delayy:
		dec bx
		nop
		cmp bx,0
		jne delayy
		dec cx
		cmp cx,0
	jne delay
	
	mov al,0
jmp check							;To check for other inputs


twoDigitS:							;similar to twoDigit function but for the second number input this time
	sub al,'0'        				;Converts character to number
	mov cl,al						;Acts as a temp storage
	mov al,seconD					;Transfers the first inputted digit to al
	mov dl,10						;Multiply first digit by 10
	mul dl				
	add al,cl						;add the second digit that was inputted
	mov seconD, al					;Assign back to seconD
	
	mov ah,0eh
	mov al,' '						;Clears the number on display
	int 10h	
jmp return1

equals:
	; mov di,0 
	
	
	mov ah,02h						;lines 361 - 364 sets the cursor to the left of the display for reading
	mov dh,3
	mov dl,0
	int 10h
	
	
	mov ah,08h						;Reads the first digit of the second number
	int 10h
	
	sub al,'0'						;Converts to integer
	mov seconD,al					;Stores input into seconD
	
	mov ah,0eh
	mov al,' '						;clears the first digit of the second number
	int 10h
	
	mov ah,08h						;Reads the second digit of the second number
	int 10h
	
	
	cmp al,'0'						;if(al > '0' && al < '9') then jmp to twoDigit
	jb return1						
	cmp al,'9'
	ja return1    
	jmp twoDigits					;if a second digit exists, in order to save the second digit
	
	return1:
	
	mov cx,500
	delay3:
		mov bx,1000
		delay4:
		dec bx
		nop
		cmp bx,0
		jne delay4
		dec cx
		cmp cx,0
	jne delay3
	
		cmp op,4
	je divv
	cmp op,3
	je mull
	cmp op,2
	je subb
	cmp op,1
	je addd
	
jmp check							;Check for another input
		

mull:								;Multiplication function
	; mov al,op
	; mov ans,al
	
	mov al,firstD					;Lines 417 - 419, al register is involved when multiplying
	mov bl,seconD
	mul bl							;Technically, al is being multiplied to bl
	
	mov ans,ax						;Since the product is stored in ax, we transfer the result into 'ans'
	
jmp dispAns

divv:								;Division function
	; mov al,op
	; mov ans,al
	mov dx,0000h					;Since we might be dealing with big numbers, set dx to 0 in order to divide by a 16 bit specification
	mov ah,00h						;ah register 0
	mov al,firstD					;store the first number to al
	mov bh,00h
	mov bl, seconD					;store the second number to bl
	div bx							;What's happening here is that al is being divided by bl. firstD is being divided by seconD
	mov ans,ax						;Again the result is stored in ax
jmp dispAns 

subb:								;Subtraction function
	; mov al,op
	; mov ans,al
	
	mov ah,00h						;Since ax was used, in order to refresh the register we assign zero to use ah
	mov al, firstD
	mov bh,00h						;Since bx was used, in order to refresh the register we assign zero to use bh
	mov bl,seconD
	sub ax,bx						;subtract firstD with seconD
	cmp ax,0						
	ja NotNeg						;if the result is positive
	mov ax,0000h					;if the result is negative then the format is not supported
	NotNeg:
	
	mov ans,ax						;Store the result if it is positive
jmp dispAns
	
addd:								;Addition function
	; mov al,op
	; mov ans,al
	
	mov bh,00h						;Since bx was used, in order to refresh the register we assign zero to use bh
	mov bl,firstD
	mov ah,00h						;Since ax was used, in order to refresh the register we assign zero to use ah
	mov al, seconD
	add bx,ax						;add firstD with seconD
	
	mov ans, bx						;The result is stored in bx. Unlike multiplying and dividing, subtracting and adding have no specific register as to where the result is stored. The first parameter is usuall where the result is stored
jmp dispAns


dispAns:							;display function for the result
	; mov al,ans
	
	; jmp disp

	mov bh,00h						;lines 473 - 477 setting the cursor to the left of the display
	mov dh,3
	mov dl,0
	mov ah,02h
	int 10h
	
	mov cx, ans						
	
	;This maps the location of each digit in the result
	cmp cx, 10
	jb ones	
	cmp cx, 100
	jb twos
	cmp cx,1000
	jb threes
	jmp fours
	
	ones:
		add cx,'0'				;Convert integer to string
		mov fstD,cl				;store the left most digit of the result into fstD
	jmp last
	
	twos:
		mov ax,cx				
		mov ch,10 
		div ch					;Acts as a modulo in order to take the digit right after the left most
		add ah,'0'				;Convert integer to string 
		mov sndD,ah				;save that digit to sndD
		add al,'0'				;convert integer to string
		mov fstD,al				;The quotient is the first digit
	jmp last
	
	threes:
		mov ax,cx
		mov dx,0000h
		mov cx,10				
		div cx					;Modulo again for the third digit starting from the digit at the left most
		add dl,'0'				;Convert to string
		mov thrD,dl				;Store the third digit of the result
		
		mov dx,0000h
		div cx					;For taking the second digit this time
		add dl,'0'
		mov sndD,dl				;Store the second digit of the result
		
		add al,'0'				
		mov fstD,al				;And of course, the first digit
		
	jmp last 
	
	;This is the same pattern as the previous ones.
	fours:
		mov ax,cx
		mov dx,0000h
		mov cx,10
		div cx
		add dl,'0'
		mov fthD,dl
		
		mov dx,0000h
		div cx
		add dl,'0'
		mov thrD,dl
		
		mov dx,0000h
		div cx
		add dl,'0'
		mov sndD,dl
		
		add al,'0'
		mov fstD,al
	
	;This prints out the result from left to right.(example: result = 1000, so it is displayed as '1' then '0', '0' and so on)
	last:
		mov al,fstD
		mov ah,0eh
		int 10h
		
		mov al,sndD
		mov ah,0eh
		int 10h
		
		mov al,thrD
		mov ah,0eh
		int 10h
		
		mov al,fthD
		mov ah,0eh
		int 10h
		
	mov cx,500
	delay5:
		mov bx,1000
		delay6:
		dec bx
		nop
		cmp bx,0
		jne delay6
		dec cx
		cmp cx,0
	jne delay5
	
	;For clearing stuff
	mov op,0
	mov ans,0
	mov fstD,' '
	mov sndD,' '
	mov thrD,' '
	mov fthD,' '
	mov firstD,' '
	mov seconD,0
	mov ax,0000h
	mov al,0
	mov di,0
jmp check							;Check for another input
