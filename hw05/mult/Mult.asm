// This file is part of www.nand2tetris.org
// and the book "The Elements of Computing Systems"
// by Nisan and Schocken, MIT Press.
// File name: projects/04/Mult.asm

// Multiplies R0 and R1 and stores the result in R2.
// (R0, R1, R2 refer to RAM[0], RAM[1], and RAM[2], respectively.)

// Assumptions: R0 >= 0, R1 >= 0, R0 * R1 < 32768

// sum = R0
// while(R1 > 0)
// {
//    sum += R0;
//    R1--;
// }

    @sum
    M=0     //init sum

(LOOP) 
    @R1     //2nd operand will be the loop counter
    D=M
    @END
    D;JLE   //break loop if 2nd operand <= 0
    
    @R0
    D=M     //D=*R0
    @sum
    M=M+D   //*sum = *sum + *R0
    
    @R1
    M=M-1   //(*R1)--; (loop counter decrement)
    
    @LOOP
    0;JMP   //re loop
    
(END)
    @sum
    D=M
    @R2
    M=D
    
(EOF)
    @EOF
    0;JMP