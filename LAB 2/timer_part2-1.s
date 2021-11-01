
.global _start
initialCount: .word 200000000

.equ loadTimer, 0xFFFEC600
.equ countTimer, 0xFFFEC604
.equ controlRegister, 0xFFFEC608
.equ interruptStatus, 0xFFFEC60C


ARM_TIM_config_ASM:
	ldr r0, initialCount
	ldr r2, =loadTimer //getting address timer
	str r0, [r2] //loading initial count value into timer
	mov r3, #0b011 // set bits: mode = 1 (auto), enable = 1
	strb r3, [r2, #0x8] // write to timer control register
	mov r3, #0b01
	strb r3, [r2, #0x9] //store vlaue 1 in the prescaler
	b ARM_TIM_clear_INT_ASM

	

ARM_TIM_read_INT_ASM:
	ldr R3, [R2, #0xC] //WHERE SHOULD I STORE IT?
	bx lr
	

ARM_TIM_clear_INT_ASM:
	mov r4, #0x00000001
	strb r4, [r2, #0xC]
	b end 

end:
	 b end
	