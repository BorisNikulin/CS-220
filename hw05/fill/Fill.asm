// This file is part of www.nand2tetris.org
// and the book "The Elements of Computing Systems"
// by Nisan and Schocken, MIT Press.
// File name: projects/04/Fill.asm

// Runs an infinite loop that listens to the keyboard input.
// When a key is pressed (any key), the program blackens the screen,
// i.e. writes "black" in every pixel;
// the screen should remain fully black as long as the key is pressed. 
// When no key is pressed, the program clears the screen, i.e. writes
// "white" in every pixel;
// the screen should remain fully clear as long as no key is pressed.

//screen memory map: [@SCREEN, @24576)

	//since return pointer is always to MAINLOOP
	//I can just set it once here
	@MAINLOOP
	D=A
	@R0
	M=D			//set return pointer to MAINLOOP

(MAINLOOP)
	@KBD
	D=M			//D=keyboard ascii value
	
//	//for fun
//	@FILLASCII
//	0;JMP
	
	@FILLBLACK
	D;JNE		//if key pressed (not 0) fill black (will return to MAINLOOP)
	@FILLWHITE
	0;JMP		//else fill white (will return to MAINLOOP)
	
(FILLBLACK)
	//return pointer already set at the start and will not change
	D=-1 		//all 1's
	@R1
	M=D			//set R1 to all 1's for a black bit pattern
	@FILLSCREEN
	0;JMP		//call FILLSCREEN

(FILLWHITE)
	//return pointer already set at the start and will not change
	D=0			//all 0's
	@R1
	M=D			//set R1 to all 0's for a white bit pattern
	@FILLSCREEN
	0;JMP		//call FILLSCREEN

//for fun
(FILLASCII)
	//return pointer already set at the start and will not change
	@KBD
	D=M			//bit pattern is the ascii bits
	@MAINLOOP
	D;JEQ		//if no key pressed do not redraw screen
	@R1
	M=D			//set R1 to ascii bit pattern
	@FILLSCREEN
	0;JMP		//call FILLSCREEN


//Fills screen with bit pattern
//R0 - return pointer
//R1 - fill pattern
//Pre-requirments: none
(FILLSCREEN)
	//setting return pointer unnecessary
	//since FILLSCREEN will not exectute past FILL call
	@SCREEN
	D=A
	@R2
	M=D			//start arg = SCREEN
	@24576
	D=A
	@R3
	M=D			//end arg = 24576
	@FILL
	0;JMP		//call FILL(MAINLOOP, R1(fillPattern), SCREEN, 24576)
	


//Takes the fill pattern and fills the specified
//RAM addresses from [R1, R2) with the pattern
//R0 - return pointer
//R1 - fill pattern to set each RAM spot with
//R2 - start RAM location (inclusive)
//R3 - end RAM location (exclisive)
//Pre-requirments: none (although for things to happen R3 > R2)
(FILL)
	@R2     	//will be loop counter and pointer to current ram spot
	D=M
	@R3
	D=M-D   	//D=end-start
	@FILLEND
	D;JLE   	//break if (end-start <= 0)
	
	@R1
	D=M			//D=*R1 (fillPattern)
	@R2			//A=R2
	A=M     	//A=*R2
	M=D			//RAM[*R2]=D (fillPattern)
	@R2
	M=M+1   	//ram ptr/loop counter increment
	
	@FILL
	0;JMP		//re loop
	
(FILLEND)
	@R0
	A=M
	0;JMP		//jmp to *returnPtr