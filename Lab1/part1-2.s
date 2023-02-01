.global _start

n: .word 10 // n in fib(n)

_start:
	ldr R0, n //load n
	bl fib	//branch to fib and copy address of next instruction into lr
	B end //branch to end when ending
	

fib: 
	push {lr} //push address of next instruction
	cmp R0, #2 //if it is less than, then the result is 2 or 1
	BLE twoorless //branch if n is two or less (cause is either 0 or 1)
	sub R2, R0, #1 //fib (n-1)
	sub R3, R0, #2 //fib (n-2)
	mov R0, R2 //moving the value of fib(n-1) into R0 so we can do recursion
	push {R3} //push the value of f(n-2) so we don't lose it when we do a subroutine
	bl fib //recursive call
	pop {R3}	//pop fib(n-2)
	push {R0}	//save the value that was returned
	mov R0, R3	//moving the value of fib(n-2) into R0 so we can do recursion
	BL fib	//recursive call
	mov R3,R0	//move the returned value into R3, because R0 is going to store the sum of R2+R1
	pop {R2}	//Pop the value that was previously returned from the first recursion into R2
	add R0, R2, R3 // f(n) = f(n-1) + f(n-2)
	pop {lr}
	bx lr
	
twoorless: 
	cmp R0, #0 //check if n=0
	BEQ iszero //branch if n=0
	mov R0, #1 //if n is not 0 then fib(n)=1
	pop {lr} //pop value of lr to go backwards after we finished recursion
	bx lr //branch to lr's address
	
iszero: 
	mov R0, #0 //fib(0)=0
	pop {lr} //pop value of lr to go backwards after we finished recursion
	bx lr //branch to lr's address

end: B end




	