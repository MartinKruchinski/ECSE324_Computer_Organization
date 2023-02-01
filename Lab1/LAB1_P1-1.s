.global _start
n : .word 5
//LIST : .word 0, 1, 6 ,4 , -8

_start:
//initialize registers
mov R5, #0
mov R0, #0
mov R1, #1
ldr R2, n //load n memory address in r2 
mov R6, #2 //Initialize i
cmp R2, #0
beq zero
cmp R2, #2
ble one

LOOP:
cmp R6, R2 //compare the values of n and i
bgt store // if i is greater than n then branch to end
add R5, R1, R0 // f(i) = f(i-1) + f(i-2)
add R6, R6, #1 //increase the value of i
mov R0, R1  //change the value of f(i-2)
mov R1, R5 ////change the value of f(i-1)
mov R7, #1
ble LOOP //if less or equal branch to loop again

store:
mov R0, r5 //store the final value in r0
b end

zero: //case 0
mov R0, #0
b end

one: mov R0, #1 //case n=2 or n=1
b end
end: b end