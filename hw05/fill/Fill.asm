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



/////////////////////////////////
//Note:
//This file contains two versions.
//Both pass the test.
//Version 1 (3de5e1a) and
//Version 2 (158c97a).
//V1 is a sane and working
//first attempt.
//V2 is an extreme overkill
//version that can handle
//changing keyboard
//inputs mid painting and
//done with extreme
//overkill in mind.
//
//
//Side note:
//Running the two versions
//with no animation gave me
//the result that, while
//V2 can respond to changing
//input, the fact that there
//is so much more code running,
//the user experience feels
//much more slugish than V1,
//the non responsive version,
//because V1 is so simple and
//fast, you dont really notice
//V1 being unresponsive. It's
//just so fast, that it 
//feels like it responds mid
//paints even though it doesn't.
//
//
//There is also an intersting bug version
//(not included)
//(952ff9d6) https://github.com/BorisNikulin/CS-220/blob/952ff9d9824145165b0f7a73ee5123c269d7f56a/hw05/fill/Fill.asm
//that paints an interesting
//tiled fractal like design.
//Screenshot: http://i.imgur.com/ajusp3n.png
//
//
//V1 and V2 both pass the test
//and both are commented.
//Any one can be graded, but V2
//is very long and very very
//overkill.
/////////////////////////////////


//-----------------------------------------------
//Version 2 (158c97a)
//https://github.com/BorisNikulin/CS-220/blob/158c97a30f29c7c05269d8e431e54c39a2502521/hw05/fill/Fill.asm


////this is extreme overkill (but it was fun)
//
////screen memory map: [@SCREEN, @24576)
//
//    @1337
//    D=A
//	@sp         //init stack pointer to some space not likely to be used
//	M=D         //will be an increasing empty stack
//
//	//set return pointer to FILLSCREEN so the set colors funcs
//	//also start the loop here (jank linking goooooo)
//	//I couldnt be bothered to be proper here since i retrofited (overkilled)
//	//the other functions to a ridiculous degree
//	//FILLSCREEN will also set the return pointer back to MAINLOOP
//	//so it works out (woooo jank coding :D)
//	@FILLSCREEN
//	D=A
//	@R0
//	M=D
//
//(MAINLOOP)
//	//set return pointer to FILLSCREEN so the set colors funcs
//	//also start the loop here (jank linking goooooo)
//	//I couldnt be bothered to be proper here since i retrofited (overkilled)
//	//the other functions to a ridiculous degree
//	//FILLSCREEN will also set the return pointer back to MAINLOOP
//	//so it works out (woooo jank coding :D)
//	@FILLSCREEN
//	D=A
//	@R0
//	M=D
//
//	@KBD
//	D=M			//D=keyboard ascii value
//	
//	@SETBLACK
//	D;JNE		//if key pressed (not 0) fill black (will return to MAINLOOP)
//	@SETWHITE
//	0;JMP		//else fill white (will return to MAINLOOP)
//
////Fills screen with bit pattern
////R0 - return pointer
////R1 - fill pattern
////Pre-requirments: none
//(FILLSCREEN)
//	//set return pointer to MAINLOOP since I never set it
//	//and have changed the MAINLOOP to use functions
//	//so this will be the place (janky)
//	@MAINLOOP
//	D=A
//	@R0
//	M=D
//	@SCREEN
//	D=A
//	@R2
//	M=D			//start arg = SCREEN
//	@24576
//	D=A
//	@R3
//	M=D			//end arg = 24576 (1 address past the end of screen map)
//	@FILLINTERUPTABLE
//	0;JMP		//call FILL(MAINLOOP, R1(fillPattern), SCREEN, 24576)
//	
////Takes the fill pattern and fills the specified
////RAM addresses from [R1, R2) with the pattern
////R0 - return pointer
////R1 - fill pattern to set each RAM spot with
////R2 - start RAM location (inclusive)
////R3 - end RAM location (exclisive)
////R4 - pointer to interupt function that must return in R1 not 0 to then jump to address in R2 (if R1 after func is 0 no jump happens to R2)
////Pre-requirments: none (although for things to happen R3 > R2)
//(FILLINTERUPTABLE)
//	//save R0, R1, R2 to stack
//	//(maybe a full stack would have been better)
//	//(feels like no need for double @sp then)
//	@R0
//	D=M
//	@sp
//	A=M
//	M=D
//	@sp         //R0 is first in stack 
//	M=M+1       //increment stack pointer
//	@R1
//	D=M
//	@sp
//	A=M
//	M=D
//	@sp         //R1 is second in stack 
//	M=M+1       //increment stack pointer
//	@R2
//	D=M
//	@sp
//	A=M
//	M=D
//	@sp         //R2 is third in stack 
//	M=M+1       //increment stack pointer
//	
//	//stack: R0, R1, R2
//	
//	//set interput func args
//	@FILLINTERUPTFUNCRETURN
//	D=A
//	@R0
//	M=D
//	//call InteruptFunc which will test for an interupt and return a pointer to a func that will run if R1 is not 0 thus setting the bit pattern
//	@INTERUPTFUNC
//	0;JMP
//    //R1=function result
//	//R2=func pointer to run if func result is not 0
//(FILLINTERUPTFUNCRETURN)
//	@R1
//	D=M
//	@R5
//	M=D        //R5=func result
//	@R2
//	D=M
//	@R6
//	M=D        //R6=func pointer to run on non zero return
//	
//	//restore R1 and R2 from stack
//	//R1,R2  will not be used by the modify function
//	//R0 will be used though
//	@sp
//	AM=M-1     //decrement stack pointer
//	D=M        //D=R1       
//	@R2
//	M=D        //R1 poped off stack
//	@sp
//	AM=M-1     //decrement stack pointer
//	D=M        //D=R1       
//	@R1
//	M=D        //R1 poped off stack
//
//    //stack: R0
//
//	//set return pointer
//	//do the check first so the code can be skiped
//    @R5        //func interupt result
//	D=M
//	
//	@FILLINTERUPTMODIFYRETURN
//	D;JEQ       //check for whether further code needs to run (dont interupt (is 0))
//	
//	D=A
//	@R0
//	M=D        //return pointer set to FILLINTERUPTMODIFYRETURN
//
//    @R6        //ptr to R6 which is a ptr to a func
//	A=M        //A=func address
//	0;JMP      //if interupt func return is not 0 jump to the modification function
//	//R1 is now modified to the appropriate color and isBlack is updated
//(FILLINTERUPTMODIFYRETURN)
//
//    //restore R0 from stack
//	@sp
//	AM=M-1     //decrement stack pointer
//	D=M        //D=R0      
//	@R0
//	M=D        //R0 poped off stack
//
//    //stack: empty
//
//	@R2     	//will be loop counter and pointer to current ram spot
//	D=M
//	@R3
//	D=M-D   	//D=end-start
//	@FILLITERUPTABLEEND
//	D;JLE   	//break if (end-start <= 0)
//	
//	@R1
//	D=M			//D=*R1 (fillPattern)
//	@R2			//A=R2
//	A=M     	//A=*R2
//	M=D			//RAM[*R2]=D (fillPattern)
//	@R2
//	M=M+1   	//ram ptr/loop counter increment
//	
//	@FILLINTERUPTABLE
//	0;JMP		//re loop
//	
//(FILLITERUPTABLEEND)
//	@R0
//	A=M
//	0;JMP		//jmp to *returnPtr
//
//
////Checks if there is a need to interupt
////R0 - return pointer
////Returns:
////    R1 - if 0 dont interupt, if not 0 interupt (either 0 or not 0)
////    R2 - pointer to a fucntion to run if the result returned was not 0
//           (after popping stack so the function can modify the callers registers)
//(INTERUPTFUNC)
//    @KBD
//	D=M			//D=kb ascii val
//
//	//if kbd is not pressed set D to 0 else set to 1
//	@INTERUPTFUNCKBDOFF
//    D;JEQ
//(INTERUPTFUNCKBDON)
//	@SETBLACK
//    D=A
//    @R2
//    M=D			//set return func to setBlack in case an interupt is needed
//    
//	D=1			//kbd is down
//	@INTERUPTFUNCKBDEND
//    0;JMP
//(INTERUPTFUNCKBDOFF)
//	@SETWHITE
//    D=A
//    @R2
//    M=D			//set return func to setWhite in case an interupt is needed
//    
//	D=0			//kbd is not down
////	@INTERUPTFUNCKBDEND
////  0;JMP
//(INTERUPTFUNCKBDEND)
//	//D is now 1 for kbd down and 0 for kbd up
//	
//    @isBlack
//    D=M-D		//if D != 0 then interupt is needed as current color does not match the dictated color (by kbd)
//    //isBlack will be changed in set color funcs so no need to change here
//	
//	@R1
//	M=D 		//set return value on whether to interupt
//	
//	@R0
//	A=M
//	0;JMP		//return
//
////Sets R1 to white bit pattern
////R0 - return pointer
////Returns:
////	R1 - white bit pattern (all 0's)
////Affects:
////	@isBlack - becomes 0
//(SETWHITE)
//	@isBlack
//	M=0			//isBlack is 0
//
//	D=0
//	@R1
//	M=D			//R1 becomes white
//	
//	@R0
//	A=M
//	0;JMP		//return
//
////Sets R1 to white bit pattern
////R0 - return pointer
////Returns:
////	R1 - white bit pattern (all 1's)
////Affects:
////	@isBlack - becomes 1
//(SETBLACK)
//	@isBlack
//	M=1			//isBlack is 1
//
//	D=-1
//	@R1
//	M=D			//R1 becomes black
//	
//	@R0
//	A=M
//	0;JMP		//return
//	

//-----------------------------------------------
//Version 1 (3de5e1a)
//https://github.com/BorisNikulin/CS-220/blob/3de5e1a2c2c53611e36c7f336844354d11468a62/hw05/fill/Fill.asm

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