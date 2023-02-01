.global _start

//pointer: .word array
size: .word 5

//Variables for the algorithm
int_step: .word 0
int_i: .word 0
array: .word -1, 23, 0, 12, -7

_start:
//initialize Variables
ldr R0, =array //point to first element of the array
ldr R1, size // size = 5 (for this example)
ldr R2, int_step // step = 0 (initialize)
sub R4, R1, #1 // size -1 (never changes)


loop1: //first for loop
ldr R0, =array //allows us to point to first element when starting every new iteration
ldr R3, int_i // i = 0
cmp R2, R4 //  step < size-1
bge end // loop ends if step >= size - 1

loop2: //second for loop
sub R5, R4, R2 //size - 1 - step 
cmp R3, R5 // i < size - 1 - step 
beq increase_step //increase step if equal

sorting: // comparing and swapping elements
ldr R6, [R0] // points to element in the array
ldr R7, [R0, #4] //points to next element
cmp R6, R7 //compare *(ptr + i) > *(ptr + i + 1) --> swap R6 with R7 to compute descending
ble increase_i //increase i if *(ptr + i) is less or equal
str R7, [R0] //swap R7 and R6
str R6, [R0, #4] //swap R7 and R6
b increase_i //increase i when loop ends


increase_step:
add R2, R2, #1 // step = step + 1
b loop1 //branch to first for loop

increase_i:
add R3, R3, #1 // i = i + 1
add R0, R0, #4 //add 4 to the pointer to the element, so the loop starts pointing to the next element
b loop2 //branch to second for loop

end:
b end //infinite loop