.global _start

.equ SW_MEMORY, 0xFF200040
.equ LED_MEMORY, 0xFF200000

.equ HEX_3to0, 0xFF200020
.equ HEX_4to5, 0xFF200030

.equ pushButtons, 0xFF200050
.equ MaskBits, 0xFF200058
.equ EdgeBits, 0xFF20005C


_start:
	//CODE FOR SWITCHES AND LEDS
	bl read_slider_switches_ASM
	mov r5, #0x00000200
	cmp r0, r5
	blge HEX_clear_ASM
	bl write_LEDs_ASM
	bl read_PB_edgecp_ASM
	bl HEX_write_ASM
	//bl HEX_clear_ASM
	b _start
	
	
	
	
// Sider Switches Driver
// returns the state of slider switches in R0
read_slider_switches_ASM:
    LDR R1, =SW_MEMORY
    LDR R0, [R1]
    BX  LR
	
// LEDs Driver
// writes the state of LEDs (On/Off state) in R0 to the LEDs memory location
write_LEDs_ASM:
    LDR R1, =LED_MEMORY
    STR R0, [R1]
    BX  LR

//HEX DRIVERS
HEX_clear_ASM:
	push {lr}
	mov r11, #0b01111111
	ldr r2, =HEX_3to0
	ldr r3, =HEX_4to5
	mov r7, #0 //hex1_counter
	mov r8, #0 //hex2_counter
	mov r5, #0x00000000
	bl next
	bx lr
	
HEX_flood_ASM:
	push {lr}
	ldr r2, =HEX_3to0
	ldr r3, =HEX_4to5
	mov r7, #0 //hex1_counter
	mov r8, #0 //hex2_counter
	//b flood_first
	mov r5, #0xFFFFFFFF
	bl next
	bx lr

HEX_write_ASM:
	push {r0, r5, r11, lr}
	ldr r2, =HEX_3to0
	ldr r5, [r2]
	//flood last two
	mov r0, #0
	mov r11, #0b00110000
	cmp r5, #0
	blgt HEX_flood_ASM
	pop {r0,r5, r11}
	//end of flood last two
	//clear push buttons
	bl PB_clear_edgecp_ASM
	//end clear button
	ldr r2, =HEX_3to0
	ldr r3, =HEX_4to5
	mov r7, #0 //first hex counter
	mov r8, #0 //second hex counter
	b get_hexs

get_hexs: //get hexadecimal value
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
	and r6, r11, #1
	cmp r6, #1
	bleq ecrire_un
	add r2, r2, #1
	add r7, r7, #1
	lsr r11, #1
	cmp r7, #4
	blt next
	bleq ecrire_deux
	pop {lr}
	bx lr
	
ecrire_un:
	strb r5, [r2]
	bx lr

ecrire_deux:
	push {lr}
	and r6, r11, #1
	cmp r6, #1
	bleq deux 
	lsr r11, #1
	add r8, r8, #1
	add r3, r3, #1
	cmp r8, #2
	blt ecrire_deux
	pop {lr}
	bx lr
deux: 
	strb r5, [r3]
	bx lr
	
	
//BUTTONS DRIVERS

read_PB_data_ASM:
	ldr r1, =pushButtons //base address
	ldr r0, [r1] //store value in r0 (it is already encoded)
	bx lr //return

read_PB_edgecp_ASM:
	ldr r10, =EdgeBits
	ldr r11, [r10]
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