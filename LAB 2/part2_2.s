ctrHex_2: .word 0x0
ctrHex_3: .word 0x0
ctrHex_4: .word 0x0
ctrHex_5: .word 0x0
.global _start


.equ hex0, 0xFF200020
.equ hex1, 0xFF200021
.equ hex2, 0xFF200022
.equ hex3, 0xFF200023
.equ hex4, 0xFF200030
.equ hex5, 0xFF200031


.equ HEX_4to5, 0xFF200030
.equ loadTimer, 0xFFFEC600
.equ EdgeBits, 0xFF20005C


initialCount: .word 2000000 // 10 milisecond
floodzeros: .word 0x3F3F3F3F//zeros

// ******************************* HELPER METHODS **************************************
HEX_clear_ASM:
	push {r5}
	ldr r1, =0xFF200020
	mov r5, #0x00000000
	str r5, [r1]
	ldr r1, =0xFF200030
	str r5, [r1]
	pop {r5}
	bx lr
	
HEX_flood_ASM:
	push {r5}
	ldr r1, =0xFF200020
	ldr r5, floodzeros
	str r5, [r1]
	ldr r1, =0xFF200030
	str r5, [r1]
	pop {r5}
	bx lr

read_PB_edgecp_ASM:
	ldr r1, =EdgeBits
	ldr r0, [r1]
	bx lr
	
PB_clear_edgecp_ASM:
	ldr r1, =EdgeBits
	push {r8}
	ldr r8, [r1]
	str r8, [r1]
	pop {r8}
	bx lr

ARM_TIM_read_INT_ASM:
	ldr r1, =loadTimer
	ldr r0, [r1, #0xC] 
	bx lr 

ARM_TIM_clear_INT_ASM:
	push {r1, r4}
	ldr r1, =loadTimer
	mov r4, #0x00000001
	strb r4, [r1, #0xC]
	pop {r1, r4}
	bx lr

HEX_write_ASM:
	push {r5}
	
	cmp r2, #0
	moveq r5, #0b0111111 //encoding number 0 binary
	beq next

	cmp r2, #1
	moveq r5, #0b0000110 //encoding number 1 binary
	beq next
	
	cmp r2, #2
	moveq r5, #0b1011011 //encoding number 2 binary
	beq next
	
	cmp r2, #3
	moveq r5, #0b1001111 //encoding number 3 binary
	beq next
	
	cmp r2, #4
	moveq r5, #0b1100110 //encoding number 4 binary
	beq next
	
	cmp r2, #5
	moveq r5, #0b1101101 //encoding number 5 binary
	beq next
	
	cmp r2, #6
	moveq r5, #0b1111101 //encoding number 6 binary
	beq next
	
	cmp r2, #7
	moveq r5, #0b0000111 //encoding number 7 binary
	beq next
	
	cmp r2, #8
	moveq r5, #0b1111111 //encoding number 8 binary
	beq next
	
	cmp r2, #9
	moveq r5, #0b1100111 //encoding number 9 binary
	beq next
	
	cmp r2, #10
	moveq r5, #0b1110111 //encoding number A binary
	beq next
	
	cmp r2, #11
	moveq r5, #0b1111100 //encoding number B binary
	beq next
	
	cmp r2, #12
	moveq r5, #0b0111001 //encoding number C binary
	beq next
	
	cmp r2, #13
	moveq r5, #0b1011110 //encoding number D binary
	beq next
	
	cmp r2, #14
	moveq r5, #0b1111001 //encoding number E binary
	beq next
	
	cmp r2, #15
	moveq r5, #0b1110001 //encoding number F binary
	beq next
	
next:
	strb r5, [r1] //write number
	pop {r5}
	bx lr

// ************************START OF THE PROGRAM***********************
_start:
	bl HEX_flood_ASM
	
ARM_TIM_config_ASM:
	ldr r0, initialCount
	ldr r2, =loadTimer //getting address timer
	str r0, [r2] //loading initial count value into timer
	mov r3, #0b011 // set bits: mode = 1 (auto), enable = 1
	strb r3, [r2, #0x8] // write to timer control register
	mov r3, #0b00
	strb r3, [r2, #0x9] //store vlaue 1 in the prescaler
	bl PB_clear_edgecp_ASM
	
	//Clear all counters
	
	mov r2, #0 //COUNTER FOR HEX 0
	mov r3, #0 //counter for hex 1
	mov r4, #0 
	ldr r1, =ctrHex_2
	str r2, [r1]
	ldr r1, =ctrHex_3
	str r2, [r1]
	ldr r1, =ctrHex_4
	str r2, [r1]
	ldr r1, =ctrHex_5
	str r2, [r1]
	
	
poll:
	bl ARM_TIM_read_INT_ASM //Read F bit
	cmp r0, #1 //compare F bit
	blt poll //Re read again if not 1
	bl read_PB_edgecp_ASM //Read edgcp
	cmp r0, #0b001 //Start
	bleq main_loop
	cmp r0, #0b011 //Stop
	bleq PB_clear_edgecp_ASM
	cmp r0, #0b100 //Reset
	bleq PB_clear_edgecp_ASM
	beq _start
	cmp r0, #0b101 //Reset
	bleq PB_clear_edgecp_ASM
	beq _start
	b poll
	
main_loop:
push {lr}
//display_0
	ldr r1, =hex0 //address first display
	//add r1, r1, #1
	bl HEX_write_ASM
	bl ARM_TIM_clear_INT_ASM
	add r2, r2, #1 //add 1 to counter display 0
	cmp r2, #11
	poplt {lr}
	bxlt lr
	
	//0 to hex_0
	push {r10}
	mov r10, #0x3f
	strb r10, [r1]
	pop {r10}
	
//display_1
	ldr r1, =hex1
	add r3, r3, #1
	mov r2, r3
	bl HEX_write_ASM
	bl ARM_TIM_clear_INT_ASM
	mov r2, #1 //reset counter hex0 to 0
	cmp r3, #10
	poplt {lr}
	bxlt lr
	
	//0 to hex_1
	push {r10}
	mov r10, #0x3f
	strb r10, [r1]
	pop {r10}
	mov r3, #0 //reset counter hex_1
	
//display_2
	ldr r1, =hex2
	push {r4, r10}
	ldr r10, =ctrHex_2 //get counter hex_2
	ldr r4, [r10] //get value counter hex_2
	add r4, r4, #1 //add 1 to counter hex_2
	str r4, [r10] //store new value to counter hex_2
	mov r2, r4
	bl HEX_write_ASM
	bl ARM_TIM_clear_INT_ASM
	mov r2, #0 //reset counter hex0 to 0
	cmp r4, #10
	pop {r4, r10}
	poplt {lr}
	bxlt lr
	
	//0 to hex_1
	push {r4, r10}
	mov r10, #0x3f
	strb r10, [r1]
	ldr r10, =ctrHex_2 //get counter hex_2
	mov r4, #0
	str r4, [r10] //get value counter hex_2
	pop {r4, r10}

//display_3
	ldr r1, =hex3
	push {r4, r10}
	ldr r10, =ctrHex_3 //get counter hex_2
	ldr r4, [r10] //get value counter hex_2
	add r4, r4, #1 //add 1 to counter hex_2
	str r4, [r10] //store new value to counter hex_2
	mov r2, r4
	bl HEX_write_ASM
	bl ARM_TIM_clear_INT_ASM
	mov r2, #0 //reset counter hex0 to 0
	cmp r4, #6
	pop {r4, r10}
	poplt {lr}
	bxlt lr
	
	//0 to hex_1
	push {r4, r10}
	mov r10, #0x3f
	strb r10, [r1]
	ldr r10, =ctrHex_3 //get counter hex_2
	mov r4, #0
	str r4, [r10] //get value counter hex_2
	pop {r4, r10}

//display_4
	ldr r1, =hex4
	push {r6, r10}
	ldr r10, =ctrHex_4 //get counter hex_2
	ldr r6, [r10] //get value counter hex_2
	add r6, r6, #1 //add 1 to counter hex_2
	str r6, [r10] //store new value to counter hex_2
	mov r2, r6
	bl HEX_write_ASM
	bl ARM_TIM_clear_INT_ASM
	mov r2, #0 //reset counter hex0 to 0
	cmp r6, #10
	pop {r6, r10}
	poplt {lr}
	bxlt lr
	
	//0 to hex_1
	push {r6, r10}
	mov r10, #0x3f
	strb r10, [r1]
	ldr r10, =ctrHex_4 //get counter hex_2
	mov r6, #0
	str r6, [r10] //get value counter hex_2
	pop {r6, r10}

//display_5
	ldr r1, =hex5
	push {r6, r10}
	ldr r10, =ctrHex_5 //get counter hex_2
	ldr r6, [r10] //get value counter hex_2
	add r6, r6, #1 //add 1 to counter hex_2
	str r6, [r10] //store new value to counter hex_2
	mov r2, r6
	bl HEX_write_ASM
	bl ARM_TIM_clear_INT_ASM
	mov r2, #0 //reset counter hex0 to 0
	cmp r6, #6
	pop {r6, r10}
	poplt {lr}
	bxlt lr
	
end: b _start