.global _start
 //initialize fx
fx_input: .word 183, 207, 128, 30, 109, 0, 14, 52, 15, 210
		  .word 228, 76, 48, 82, 179, 194, 22, 168, 58, 116
		  .word 228, 217, 180, 181, 243, 65, 24, 127, 216, 118
		  .word 64, 210, 138, 104, 80, 137, 212, 196, 150, 139
		  .word 155, 154, 36, 254, 218, 65, 3, 11, 91, 95
		  .word 219, 10, 45, 193, 204, 196, 25, 177, 188, 170
		  .word 189, 241, 102, 237, 251, 223, 10, 24, 171, 71
		  .word 0, 4, 81, 158, 59, 232, 155, 217, 181, 19
		  .word 25, 12, 80, 244, 227, 101, 250, 103, 68, 46
		  .word 136, 152, 144, 2, 97, 250, 47, 58, 214, 51

//initialize kernel
kernel_input: .word 1,1,0,-1,-1
			  .word 0,1,0,-1,0
			  .word 0,0,1,0,0
			  .word 0,-1,0,1,0
			  .word -1,-1,0,1,1

//initialize gx
output_gx: .fill 40
		   .fill 40
		   .fill 40
		   .fill 40
		   .fill 40
		   .fill 40
		   .fill 40
		   .fill 40
		   .fill 40
		   .fill 40	   

//initialize variables
int_iw: .word 10
int_ih: .word 10
int_kw: .word 5
int_kh: .word 5
int_ksw: .word 2
int_khw: .word 2

y: .word 0
x: .word 0
i: .word 0
sum: .word 0
j: .word 0


_start:
//load variables to register
ldr R0, y //y=0
ldr R2, x //x=0
ldr R3, i  //i=0
ldr R4, j //j=0
ldr R10, sum //sum=0


for_loop1:
	ldr R1, int_ih //ih =10
	cmp R0, R1 // y < ih
	bge end //branch to end, end of the program
	mov R2, #0 // x = 0
for_loop2: 
	ldr R1, int_iw //iw = 10
	cmp R2, R1 // x < iw
	bge increase_y //y++
	mov R3, #0 // i = 0
	mov R10, #0 //sum = 0

for_loop3:
	ldr R1, int_kw //kw = 5
	cmp R3, R1 //i < kw
	bge increase_x //increase x and go to previous loop
	mov R4, #0 // j = 0
	
for_loop4:
	ldr R1, int_kh //kh = 5
	cmp R4, R1 // j < kh
	bge increase_i // i++
	ldr R1, int_ksw //ksw = 2
	add R5, R2, R4 // temp1 = x+ j
	sub R5, R5, R1 // temp1 = x+j -ksw
	ldr R1, int_khw //khw = 2
	add R6, R0, R3 // temp2 = y+i
	sub R6, R6, R1 // temp2 = y+i -khw
	
	//if statement
	cmp R5, #0 // check temp1>=0
	blt increase_j
	cmp R5, #9 //check temp1<=9
	bgt increase_j
	cmp r6, #0 // check temp2>=0
	blt increase_j
	cmp R6, #9 //check temp2<=9
	bgt increase_j 
	
	//inside if statement
	ldr R9, =kernel_input //load first address of kernel
	mov R1, #5
	mla R11, R4, R1 , R3 //multiply j by number of rows and add i
	mov R1, #4
	mul R11, R11, R1 //total offset
	add R9, R9, R11 //address of element we want to get
	ldr r8, [R9] //value of element we want to get (override R2 cause we don't have any more registers)
	ldr R12, =fx_input
	mov R1, #10
	mla R11, R5, R1 , R6 //multiply temp1 by number of rows and add temp2
	mov R1, #4
	mul R11, R11, R1 //total offest
	add R12, R12, R11 //address of element we want to get
	ldr R7, [R12] //value of fx[temp1][temp2]
	mul R8, R8, R7 // kx[j][i] * fx[temp1][temp2]
	add R10, R10, R8 // sum = sum + kx[j][i] * fx [temp1][temp2]

increase_j:
	add R4, R4, #1 // j++
	b for_loop4
	


increase_y:
	add R0,R0, #1 //y=y+1
	b for_loop1

increase_x:
	mov R1, #10
	mov R11, #0
	mov R12, #0
	mla R11, R2, R1, R0 //x*10 + y
	ldr R12, =output_gx //load gx (first address)
	mov R1, #4
	mul R11, R11, R1 //(x*10 + y)*4
	add R12, R12, R11 //
	str R10, [R12] //gx[x][y]
	add R2, R2, #1 // x = x + 1
	b for_loop2
	
	
increase_i: 
	add R3, R3, #1 //i++
	b for_loop3


end: B end //infinite loop

	