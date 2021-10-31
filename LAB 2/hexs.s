.global _start

//Hex display indices
.equ HEX0, 0x00000001
.equ HEX1, 0x00000002
.equ HEX2, 0x00000004
.equ HEX3, 0x00000008
.equ HEX4, 0x00000010
.equ HEX5, 0x00000020


.equ HEX_3to0, 0xFF200020
.equ HEX_4to5, 0xFF200030

_start:
	mov r0, #0x00000002
	mov r1, #15
	b HEX_flood_ASM
	
	
	
HEX_clear_ASM:
	ldr r2, =HEX_3to0
	ldr r3, =HEX_4to5
	mov r7, #0 //hex1_counter
	mov r8, #0 //hex2_counter
	mov r5, #0x00000000
	//b clear_first
	b next
	
HEX_flood_ASM:
	ldr r2, =HEX_3to0
	ldr r3, =HEX_4to5
	mov r7, #0 //hex1_counter
	mov r8, #0 //hex2_counter
	//b flood_first
	mov r5, #0xFFFFFFFF
	b next
	

HEX_write_ASM:
	ldr r2, =HEX_3to0
	ldr r3, =HEX_4to5
	mov r7, #0 //first hex counter
	mov r8, #0 //second hex counter
	b get_hexs

get_hexs: //get hexadecimal value
	cmp r1, #0
	mov r5, #0b0111111 //encoding number 0 binary
	beq next
	
	cmp r1, #1
	mov r5, #0b0000110 //encoding number 1 binary
	beq next
	
	cmp r1, #2
	mov r5, #0b1011011 //encoding number 2 binary
	beq next
	
	cmp r1, #3
	mov r5, #0b1001111 //encoding number 3 binary
	beq next
	
	cmp r1, #4
	mov r5, #0b1100110 //encoding number 4 binary
	beq next
	
	cmp r1, #5
	mov r5, #0b1101101 //encoding number 5 binary
	beq next
	
	cmp r1, #6
	mov r5, #0b1111101 //encoding number 6 binary
	beq next
	
	cmp r1, #7
	mov r5, #0b0000111 //encoding number 7 binary
	beq next
	
	cmp r1, #8
	mov r5, #0b1111111 //encoding number 8 binary
	beq next
	
	cmp r1, #9
	mov r5, #0b1100111 //encoding number 9 binary
	beq next
	
	cmp r1, #10
	mov r5, #0b1110111 //encoding number A binary
	beq next
	
	cmp r1, #11
	mov r5, #0b1111100 //encoding number B binary
	beq next
	
	cmp r1, #12
	mov r5, #0b0111001 //encoding number C binary
	beq next
	
	cmp r1, #13
	mov r5, #0b1011110 //encoding number D binary
	beq next
	
	cmp r1, #14
	mov r5, #0b1111001 //encoding number E binary
	beq next
	
	cmp r1, #15
	mov r5, #0b1110001 //encoding number F binary
	beq next
	
next:
	and r6, r0, #1
	cmp r6, #1
	bleq ecrire_un
	add r2, r2, #1
	add r7, r7, #1
	lsr r0, #1
	cmp r7, #4
	blt next
	bleq ecrire_deux
	b end
	
ecrire_un:
	strb r5, [r2]
	bx lr

ecrire_deux:
	and r6, r0, #1
	cmp r6, #1
	bleq deux 
	lsr r0, #1
	add r8, r8, #1
	add r3, r3, #1
	cmp r8, #2
	blt ecrire_deux
	bx lr
deux: 
	strb r5, [r3]
	bx lr
end:
	b end












