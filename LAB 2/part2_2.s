
.global _start


.equ HEX_3to0, 0xFF200020
.equ HEX_4to5, 0xFF200030
.equ loadTimer, 0xFFFEC600
.equ EdgeBits, 0xFF20005C


initialCount: .word 200000 // 10 milisecond
					
_start:
	ldr r1, =HEX_3to0
	mov r6, #0 //initialize count
	mov r10, #0
	bl HEX_write_ASM
	mov r10, #0x1
	bl HEX_write_ASM
	mov r10, #0x2
	bl HEX_write_ASM
	mov r10, #0x3
	bl HEX_write_ASM
	mov r10, #0x10
	bl HEX_write_ASM
	mov r10, #0x11
	bl HEX_write_ASM
	b Initialize
	
Initialize:
	b ARM_TIM_config_ASM
	b end
	
	
	
ARM_TIM_config_ASM:
	
	ldr r0, initialCount
	mov r10, #0
	ldr r2, =loadTimer //getting address timer
	str r0, [r2] //loading initial count value into timer
	mov r3, #0b011 // set bits: mode = 1 (auto), enable = 1
	strb r3, [r2, #0x8] // write to timer control register
	mov r3, #0b00
	strb r3, [r2, #0x9] //store vlaue 1 in the prescaler
	mov r7, #0x0
	mov r8, #0x0
	mov r9, #0x0
	mov r11, #0x0
	mov r12, #0x0
	mov r5,#0b000
	bl PB_clear_edgecp_ASM
	b read_PB_edgecp_ASM

read_PB_edgecp_ASM:
	ldr r0, =EdgeBits
	ldr r5, [r0]
	//check for start button
	cmp r5, #0b001
	beq ARM_TIM_read_INT_ASM
	//cmp r5, #0b011
	//beq ARM_TIM_read_INT_ASM
	//check for stop button
	cmp r5, #0b011
	bleq PB_clear_edgecp_ASM
	//check for reset button
	cmp r5, #0b100
	bleq PB_clear_edgecp_ASM
	beq _start
	
	b read_PB_edgecp_ASM
	
PB_clear_edgecp_ASM:
	push {r2, r3}
	ldr r2, =EdgeBits
	ldr r3, [r2]
	str r3, [r2]
	pop {r2, r3}
	bx lr
	
	
ARM_TIM_read_INT_ASM:
	mov r6, #0
	ldr r1, =HEX_3to0
	b display_0
	//subgt r10, r10, #0x1
	//beq display_1
	//b ARM_TIM_read_INT_ASM

display_0:
	ldr r3, [r2, #0xC] //WHERE SHOULD I STORE IT?
	cmp r3, #1
	blt display_0
	bleq HEX_write_ASM
	add r6, r6, #1
	bl ARM_TIM_clear_INT_ASM
	cmp r6, #10
	blt display_0
	//mov r6, #0
	//bl HEX_write_ASM
	add r10, r10, #0x1
	beq display_1
	
display_1:	
	cmp r3, #1
	blt display_1
	add r7, r7, #1
	mov r6, r7
	//
	cmp r7, #10
	bllt HEX_write_ASM
	bllt ARM_TIM_clear_INT_ASM
	mov r10, #0x0
	mov r6, #0x0
	cmp r7, #10
	bllt read_PB_edgecp_ASM
	mov r7, #0
	mov r6, r7
	bl HEX_write_ASM
	bl ARM_TIM_clear_INT_ASM
	add r10, r10, #0x2
	b display_2
	
display_2:
	cmp r3, #1
	blt display_2
	add r8, r8, #1
	mov r6, r8
	//
	cmp r8, #10
	bllt HEX_write_ASM
	bllt ARM_TIM_clear_INT_ASM
	mov r10, #0x1
	mov r6, #0x0
	cmp r8, #10
	bllt HEX_write_ASM
	mov r10, #0x0
	cmp r8, #10
	bllt HEX_write_ASM
	cmp r8, #10
	blt read_PB_edgecp_ASM //change to link?
	//mov r8, #0
	//mov r6, r8
	//bl HEX_write_ASM
	//bl ARM_TIM_clear_INT_ASM
	add r10, r10, #0x3
	b display_3
display_3:
	cmp r3, #1
	blt display_3
	add r9, r9, #1
	mov r6, r9
	//
	cmp r9, #6
	bllt HEX_write_ASM
	bllt ARM_TIM_clear_INT_ASM
	mov r10, #0x2
	mov r6, #0x0
	cmp r9, #6
	bllt HEX_write_ASM
	mov r10, #0x1
	cmp r9, #6
	bllt HEX_write_ASM
	mov r10, #0x0
	cmp r9, #6
	bllt HEX_write_ASM
	mov r8, #0
	cmp r9, #6
	blt read_PB_edgecp_ASM //change to link?
	//mov r8, #0
	//mov r6, r8
	//bl HEX_write_ASM
	//bl ARM_TIM_clear_INT_ASM
	mov r10, #0x10
	b display_4
	
display_4:
	cmp r3, #1
	blt display_3
	add r11, r11, #1
	mov r6, r11
	//
	cmp r11, #10
	bllt HEX_write_ASM
	bllt ARM_TIM_clear_INT_ASM
	mov r10, #0x3
	mov r6, #0x0
	cmp r11, #10
	bllt HEX_write_ASM
	mov r10, #0x2
	cmp r11, #10
	bllt HEX_write_ASM
	mov r10, #0x1
	cmp r11, #10
	bllt HEX_write_ASM
	mov r10, #0x0
	cmp r11, #10
	bllt HEX_write_ASM
	mov r8, #0
	mov r9, #0
	cmp r11, #10
	blt read_PB_edgecp_ASM //change to link?
	mov r10, #0x11
	b display_5
	
display_5:
	cmp r3, #1
	blt display_3
	add r12, r12, #1
	mov r6, r12
	//
	cmp r12, #6
	bllt HEX_write_ASM
	bllt ARM_TIM_clear_INT_ASM
	mov r10, #0x10
	mov r6, #0x0
	cmp r12, #6
	bllt HEX_write_ASM
	mov r10, #0x3
	cmp r12, #6
	bllt HEX_write_ASM
	mov r10, #0x2
	cmp r12, #6
	bllt HEX_write_ASM
	mov r10, #0x1
	cmp r12, #6
	bllt HEX_write_ASM
	mov r10, #0x0
	cmp r12, #6
	bllt HEX_write_ASM
	mov r8, #0
	mov r9, #0
	mov r11, #0
	cmp r12, #6
	blt read_PB_edgecp_ASM //change to link?
	b end
	
ARM_TIM_clear_INT_ASM:
	mov r4, #0x00000001
	strb r4, [r2, #0xC]
	bx lr

HEX_write_ASM:
	ldr r1, =HEX_3to0
	b get_hexs

get_hexs: //get hexadecimal value
	push {r5}
	cmp r6, #0
	moveq r5, #0b0111111 //encoding number 0 binary
	beq next

	cmp r6, #1
	moveq r5, #0b0000110 //encoding number 1 binary
	beq next
	
	cmp r6, #2
	moveq r5, #0b1011011 //encoding number 2 binary
	beq next
	
	cmp r6, #3
	moveq r5, #0b1001111 //encoding number 3 binary
	beq next
	
	cmp r6, #4
	moveq r5, #0b1100110 //encoding number 4 binary
	beq next
	
	cmp r6, #5
	moveq r5, #0b1101101 //encoding number 5 binary
	beq next
	
	cmp r6, #6
	moveq r5, #0b1111101 //encoding number 6 binary
	beq next
	
	cmp r6, #7
	moveq r5, #0b0000111 //encoding number 7 binary
	beq next
	
	cmp r6, #8
	moveq r5, #0b1111111 //encoding number 8 binary
	beq next
	
	cmp r6, #9
	moveq r5, #0b1100111 //encoding number 9 binary
	beq next
	
	cmp r6, #10
	moveq r5, #0b1110111 //encoding number A binary
	beq next
	
	cmp r6, #11
	moveq r5, #0b1111100 //encoding number B binary
	beq next
	
	cmp r6, #12
	moveq r5, #0b0111001 //encoding number C binary
	beq next
	
	cmp r6, #13
	moveq r5, #0b1011110 //encoding number D binary
	beq next
	
	cmp r6, #14
	moveq r5, #0b1111001 //encoding number E binary
	beq next
	
	cmp r6, #15
	moveq r5, #0b1110001 //encoding number F binary
	beq next
	
next:
	strb r5, [r1, r10]
	pop {r5}
	bx lr

	
end:
	 b end
	