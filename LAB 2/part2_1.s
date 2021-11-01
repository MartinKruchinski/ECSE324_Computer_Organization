
.global _start


.equ LED_MEMORY, 0xFF200000
.equ HEX_3to0, 0xFF200020

.equ loadTimer, 0xFFFEC600
.equ countTimer, 0xFFFEC604
.equ controlRegister, 0xFFFEC608
.equ interruptStatus, 0xFFFEC60C
initialCount: .word 200000000
_start:
	mov r6, #0b00000000 //initialize count
	bl HEX_write_ASM
	bl write_LEDs_ASM
	b Initialize
	
Initialize:
	b ARM_TIM_config_ASM
	b end
	

// LEDs Driver
// writes the state of LEDs (On/Off state) in R0 to the LEDs memory location
write_LEDs_ASM:
    LDR r1, =LED_MEMORY
    STR r6, [r1]
    bx  lr
	
	
ARM_TIM_config_ASM:
	
	ldr r0, initialCount
	ldr r2, =loadTimer //getting address timer
	str r0, [r2] //loading initial count value into timer
	mov r3, #0b011 // set bits: mode = 1 (auto), enable = 1
	strb r3, [r2, #0x8] // write to timer control register
	mov r3, #0b00
	strb r3, [r2, #0x9] //store vlaue 1 in the prescaler
	b ARM_TIM_read_INT_ASM


	

ARM_TIM_read_INT_ASM:
	ldr r3, [r2, #0xC] //WHERE SHOULD I STORE IT?
	cmp r3, #1
	blt ARM_TIM_read_INT_ASM
	add r6, r6, #1
	bleq HEX_write_ASM
	bleq write_LEDs_ASM
	bl ARM_TIM_clear_INT_ASM
	cmp r6, #0x00000010
	blt ARM_TIM_read_INT_ASM
	beq _start
	

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
	strb r5, [r1]
	pop {r5}
	bx lr

	
end:
	 b end
	