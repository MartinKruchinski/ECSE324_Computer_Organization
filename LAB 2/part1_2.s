.global _start

.equ SW_MEMORY, 0xFF200040
.equ LED_MEMORY, 0xFF200000

.equ HEX_3to0, 0xFF200020
.equ HEX_4to5, 0xFF200030

.equ pushButtons, 0xFF200050
.equ MaskBits, 0xFF200058
.equ EdgeBits, 0xFF20005C

// ************************HELPER FUNCTIONS*****************************
read_slider_switches_ASM:
    LDR R1, =SW_MEMORY
    LDR R0, [R1]
    BX  LR

write_LEDs_ASM:
    LDR R1, =LED_MEMORY
    STR R0, [R1]
    BX  LR
	
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
	ldr r1, =0xFF200030
	mov r5, #0xFFFFFFFF
	str r5, [r1]
	pop {r5}
	bx lr

read_PB_edgecp_ASM:
	ldr r1, =EdgeBits
	ldr r2, [r1]
	bx lr

PB_clear_edgecp_ASM:
	ldr r1, =EdgeBits
	push {r8}
	ldr r8, [r1]
	str r8, [r1]
	pop {r8}
	bx lr
	
// ************************START OF THE PROGRAM***********************
_start:
	bl read_slider_switches_ASM
	bl write_LEDs_ASM
	mov r10, #0x00000200
	cmp r0, r10
	blge HEX_clear_ASM //clear if sw9 is pressed
	bge _start
	bl HEX_flood_ASM //flood last two if sw9 while not pressed
	bl read_PB_edgecp_ASM //read pushbuttons and store in r2
	cmp r2, #0
	blgt HEX_write_ASM
	b _start


// **********************Write HEX functions*****************************
HEX_write_ASM:
	ldr r1, =HEX_3to0
	mov r3, #0 //counter
	push {r4, r5, lr}
	//GET THE HEX VALUE
	cmp r0, #0
	mov r5, #0b0111111 //encoding number 0 binary
	beq next
	
	cmp r0, #1
	mov r5, #0b0000110 //encoding number 1 binary
	beq next
	
	cmp r0, #2
	mov r5, #0b1011011 //encoding number 2 binary
	beq next
	
	cmp r0, #3
	mov r5, #0b1001111 //encoding number 3 binary
	beq next
	
	cmp r0, #4
	mov r5, #0b1100110 //encoding number 4 binary
	beq next
	
	cmp r0, #5
	mov r5, #0b1101101 //encoding number 5 binary
	beq next
	
	cmp r0, #6
	mov r5, #0b1111101 //encoding number 6 binary
	beq next
	
	cmp r0, #7
	mov r5, #0b0000111 //encoding number 7 binary
	beq next
	
	cmp r0, #8
	mov r5, #0b1111111 //encoding number 8 binary
	beq next
	
	cmp r0, #9
	mov r5, #0b1100111 //encoding number 9 binary
	beq next
	
	cmp r0, #10
	mov r5, #0b1110111 //encoding number A binary
	beq next
	
	cmp r0, #11
	mov r5, #0b1111100 //encoding number B binary
	beq next
	
	cmp r0, #12
	mov r5, #0b0111001 //encoding number C binary
	beq next
	
	cmp r0, #13
	mov r5, #0b1011110 //encoding number D binary
	beq next
	
	cmp r0, #14
	mov r5, #0b1111001 //encoding number E binary
	beq next
	
	cmp r0, #15
	mov r5, #0b1110001 //encoding number F binary
	beq next
	
next:
	and r4, r2, #1
	cmp r4, #1
	bleq ecrire_un
	add r1, r1, #1
	add r3, r3, #1
	lsr r2, #1
	cmp r3, #4
	blt next
	bl PB_clear_edgecp_ASM // clear pushbuttons
	pop {r4, r5, lr}
	bx lr
	
ecrire_un:
	strb r5, [r1]
	bx lr