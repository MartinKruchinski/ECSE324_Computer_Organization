.global _start

.equ pushButtons, 0xFF200050
.equ MaskBits, 0xFF200058
.equ EdgeBits, 0xFF20005C


_start:
	//bl read_PB_data_ASM
	//bl read_PB_edgecp_ASM
	//bl PB_clear_edgecp_ASM
	mov r6, #0x00000001 //indice input
	bl disable_PB_INT_ASM
	b end
read_PB_data_ASM:
	ldr r1, =pushButtons //base address
	ldr r0, [r1] //store value in r0 (it is already encoded)
	bx lr //return

read_PB_edgecp_ASM:
	ldr r2, =EdgeBits
	ldr r0, [r2]
	bx lr
	
PB_clear_edgecp_ASM:
	ldr r2, =EdgeBits
	ldr r3, [r2]
	str r3, [r2]
	bx lr

enable_PB_INT_ASM:
	push {r4}
	ldr r4, =MaskBits
	str r6, [r4]
	pop {r4}
	bx lr

disable_PB_INT_ASM:
	ldr r4, =MaskBits
	mov r7, #0b00001111 //set all bits to 1
	eor r6, r6, r7 //xor to set only input to 0
	str r6, [r4] //store final 4 bits in maskbits address
	

end:
	b end