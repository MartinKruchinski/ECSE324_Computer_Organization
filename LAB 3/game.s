y_value: .word 0x0
players_turn: .word 0x0
player_wins: .word 0x0
.equ pixelBuffer, 0xc8000000
.equ charBuffer, 0xc9000000
.equ ps2Data, 0xFF200100
checkifnice: .space 4 //stores make code
//Player marks
box1: .space 4
box2: .space 4
box3: .space 4
box4: .space 4
box5: .space 4
box6: .space 4
box7: .space 4
box8: .space 4
box9: .space 4

//position of the players
streak_1: .space 4
streak_2: .space 4

hasStarted: .space 4

.global _start

//Adresses
white_screen: .word 0xffff
red_color: .word 0xf200

_start:
		//clear everything when restarting game
		push {r7, r8}
		mov r8, #0
		ldr r7, =box1
		str r8, [r7]
		ldr r7, =box2
		str r8, [r7]
		ldr r7, =box3
		str r8, [r7]
		ldr r7, =box4
		str r8, [r7]
		ldr r7, =box5
		str r8, [r7]
		ldr r7, =box6
		str r8, [r7]
		ldr r7, =box7
		str r8, [r7]
		ldr r7, =box8
		str r8, [r7]
		ldr r7, =box9
		str r8, [r7]
		ldr r7, =streak_1
		str r8, [r7]
		ldr r7, =streak_2
		str r8, [r7]
		ldr r7, =players_turn
		str r8, [r7]
		pop {r7, r8}
		push {r10}
		ldr r10, =hasStarted
		mov r1, #0
		str r1, [r10]
		push {r10}
		//end clear
		
        bl VGA_clear_pixelbuff_ASM //set background to red
		bl VGA_clear_charbuff_ASM
		bl draw_board //draw board
		b  input_loop

input_loop:
	ldr r0, =checkifnice
    bl   read_PS2_data_ASM
	cmp     r0, #0
	beq input_loop
	push {r5}
	ldr r5, =checkifnice
	ldr r2, [r5]
	pop {r5}
	push {r8, r9}
	ldr r9, =ps2Data
	ldr r8, [r9]
	ldr r8, [r9]
	pop {r8, r9}
	cmp r2, #0x45
	bne	input_loop
	bl Player_turn_ASM //write player's turn
	push {r5}
	ldr r5, =checkifnice
	mov r1, #0
	str r1, [r5]
	pop {r5}
	b game_starts

//player one loop

game_starts:
	ldr r0, =checkifnice
    bl   read_PS2_data_ASM
	cmp     r0, #0
	beq game_starts
	
	//get make value
	push {r5}
	ldr r5, =checkifnice
	ldr r2, [r5]
	pop {r5}
	
	//clear
	push {r8, r9}
	ldr r9, =ps2Data
	ldr r8, [r9]
	ldr r8, [r9]
	pop {r8, r9}
	//end clear
	
	
first_box:
	//check first box
	cmp r2, #0x16
	bne	second_box
	push {r10}
	ldr r10, =box1
	ldr r1, [r10]
	push {r10}
	cmp r1, #0
	bne	second_box
	moveq r2, #0xf
	moveq r0, #70
	moveq r1, #30
	bleq draw_square
	push {r9, r10}
	ldr r10, =box1
	mov r9, #1
	str r9, [r10]
	ldr r10, =streak_1
	ldr r9, [r10]
	add r9, r9, #1
	str r9, [r10]
	pop {r9, r10}
	beq Change_to_player_2

second_box:
	//check second box
	cmp r2, #30
	bne	third_box
	push {r10}
	ldr r10, =box2
	ldr r1, [r10]
	push {r10}
	cmp r1, #0
	bne	third_box
	moveq r0, #139
	moveq r1, #30
	moveq r2, #0xf
	bleq draw_square
	push {r9, r10}
	ldr r10, =box2
	mov r9, #1
	str r9, [r10]
	ldr r10, =streak_1
	ldr r9, [r10]
	add r9, r9, #2
	str r9, [r10]
	pop {r9, r10}
	beq Change_to_player_2

third_box:
	//check third box
	cmp r2, #38
	bne	fourth_box
	push {r10}
	ldr r10, =box3
	ldr r1, [r10]
	push {r10}
	cmp r1, #0
	bne	fourth_box
	moveq r0, #208
	moveq r1, #30
	moveq r2, #0xf
	bleq draw_square
	push {r9, r10}
	ldr r10, =box3
	mov r9, #1
	str r9, [r10]
	ldr r10, =streak_1
	ldr r9, [r10]
	add r9, r9, #4
	str r9, [r10]
	pop {r9, r10}
	beq Change_to_player_2

fourth_box:
	//check 4 box
	cmp r2, #37
	bne	fifth_box
	push {r10}
	ldr r10, =box4
	ldr r1, [r10]
	push {r10}
	cmp r1, #0
	bne	fifth_box
	moveq r0, #70
	moveq r1, #99
	moveq r2, #0xf
	bleq draw_square
	push {r9, r10}
	ldr r10, =box4
	mov r9, #1
	str r9, [r10]
	ldr r10, =streak_1
	ldr r9, [r10]
	add r9, r9, #8
	str r9, [r10]
	pop {r9, r10}
	beq Change_to_player_2

fifth_box:
	//check 5 box
	cmp r2, #46
	bne	six_box
	push {r10}
	ldr r10, =box5
	ldr r1, [r10]
	push {r10}
	cmp r1, #0
	bne	six_box
	moveq r0, #139
	moveq r1, #99
	moveq r2, #0xf
	bleq draw_square
	push {r9, r10}
	ldr r10, =box5
	mov r9, #1
	str r9, [r10]
	ldr r10, =streak_1
	ldr r9, [r10]
	add r9, r9, #16
	str r9, [r10]
	pop {r9, r10}
	beq Change_to_player_2
	
six_box:	
	//check 6 box
	cmp r2, #54
	bne	seven_box
	push {r10}
	ldr r10, =box6
	ldr r1, [r10]
	push {r10}
	cmp r1, #0
	bne	seven_box
	moveq r0, #208
	moveq r1, #99
	moveq r2, #0xf
	bleq draw_square
	push {r9, r10}
	ldr r10, =box6
	mov r9, #1
	str r9, [r10]
	ldr r10, =streak_1
	ldr r9, [r10]
	add r9, r9, #32
	str r9, [r10]
	pop {r9, r10}
	beq Change_to_player_2

seven_box:
	//check 7 box
	cmp r2, #61
	bne	eigth_box
	push {r10}
	ldr r10, =box7
	ldr r1, [r10]
	push {r10}
	cmp r1, #0
	bne	eigth_box
	moveq r0, #70
	moveq r1, #168
	moveq r2, #0xf
	bleq draw_square
	push {r9, r10}
	ldr r10, =box7
	mov r9, #1
	str r9, [r10]
	ldr r10, =streak_1
	ldr r9, [r10]
	add r9, r9, #64
	str r9, [r10]
	pop {r9, r10}
	beq Change_to_player_2

eigth_box:
	//check 8 box
	cmp r2, #62
	bne	nine_box
	push {r10}
	ldr r10, =box8
	ldr r1, [r10]
	push {r10}
	cmp r1, #0
	bne	nine_box
	moveq r0, #139
	moveq r1, #168
	moveq r2, #0xf
	bleq draw_square
	push {r9, r10}
	ldr r10, =box8
	mov r9, #1
	str r9, [r10]
	ldr r10, =streak_1
	ldr r9, [r10]
	add r9, r9, #128
	str r9, [r10]
	pop {r9, r10}
	beq Change_to_player_2

nine_box:
	//check 9 box
	cmp r2, #70
	bne is0
	push {r10}
	ldr r10, =box9
	ldr r1, [r10]
	push {r10}
	cmp r1, #0
	bne	is0
	moveq r0, #208
	moveq r1, #168
	moveq r2, #0xf
	bleq draw_square
	push {r9, r10}
	ldr r10, =box9
	mov r9, #1
	str r9, [r10]
	ldr r10, =streak_1
	ldr r9, [r10]
	add r9, r9, #256
	str r9, [r10]
	pop {r9, r10}
	beq Change_to_player_2
	
is0:
	push {r10}
	ldr r10, =hasStarted
	ldr r1, [r10]
	push {r10}
	cmp r1, #0
	beq game_starts
	cmp r2, #0x45
	beq _start
	bne game_starts
	
	b game_starts
	
//player two loop
game_starts_2:
    ldr r0, =checkifnice
    bl   read_PS2_data_ASM
	cmp     r0, #0
	beq game_starts_2
	
	//get make value
	push {r5}
	ldr r5, =checkifnice
	ldr r2, [r5]
	pop {r5}
	
	//clear
	push {r8, r9}
	ldr r9, =ps2Data
	ldr r8, [r9]
	ldr r8, [r9]
	pop {r8, r9}
	//end clear
	cmp r2, #0x45
	beq _start
	
	//check first box
first_box_1:
	//check first box
	cmp r2, #0x16
	bne	second_box_1
	push {r10}
	ldr r10, =box1
	ldr r1, [r10]
	push {r10}
	cmp r1, #0
	bne	second_box_1
	moveq r2, #0xff0
	moveq r0, #89
	moveq r1, #30
	bleq draw_cross
	push {r9, r10}
	ldr r10, =box1
	mov r9, #1
	str r9, [r10]
	ldr r10, =streak_2
	ldr r9, [r10]
	add r9, r9, #1
	str r9, [r10]
	pop {r9, r10}
	beq Change_to_player_1

second_box_1:
	//check second box
	cmp r2, #30
	bne	third_box_1
	push {r10}
	ldr r10, =box2
	ldr r1, [r10]
	push {r10}
	cmp r1, #0
	bne	third_box_1
	moveq r0, #158
	moveq r1, #30
	moveq r2, #0xff0
	bleq draw_cross
	push {r9, r10}
	ldr r10, =box2
	mov r9, #1
	str r9, [r10]
	ldr r10, =streak_2
	ldr r9, [r10]
	add r9, r9, #2
	str r9, [r10]
	pop {r9, r10}
	beq Change_to_player_1

third_box_1:
	//check third box
	cmp r2, #38
	bne	fourth_box_1
	push {r10}
	ldr r10, =box3
	ldr r1, [r10]
	push {r10}
	cmp r1, #0
	bne	fourth_box_1
	moveq r0, #227
	moveq r1, #30
	moveq r2, #0xff0
	bleq draw_cross
	push {r9, r10}
	ldr r10, =box3
	mov r9, #1
	str r9, [r10]
	ldr r10, =streak_2
	ldr r9, [r10]
	add r9, r9, #4
	str r9, [r10]
	pop {r9, r10}
	beq Change_to_player_1

fourth_box_1:
	//check 4 box
	cmp r2, #37
	bne	fifth_box_1
	push {r10}
	ldr r10, =box4
	ldr r1, [r10]
	push {r10}
	cmp r1, #0
	bne	fifth_box_1
	moveq r0, #89
	moveq r1, #99
	moveq r2, #0xff0
	bleq draw_cross
	push {r9, r10}
	ldr r10, =box4
	mov r9, #1
	str r9, [r10]
	ldr r10, =streak_2
	ldr r9, [r10]
	add r9, r9, #8
	str r9, [r10]
	pop {r9, r10}
	beq Change_to_player_1

fifth_box_1:
	//check 5 box
	cmp r2, #46
	bne	six_box_1
	push {r10}
	ldr r10, =box5
	ldr r1, [r10]
	push {r10}
	cmp r1, #0
	bne	six_box_1
	moveq r0, #158
	moveq r1, #99
	moveq r2, #0xff0
	bleq draw_cross
	push {r9, r10}
	ldr r10, =box5
	mov r9, #1
	str r9, [r10]
	ldr r10, =streak_2
	ldr r9, [r10]
	add r9, r9, #16
	str r9, [r10]
	pop {r9, r10}
	beq Change_to_player_1
	
six_box_1:	
	//check 6 box
	cmp r2, #54
	bne	seven_box_1
	push {r10}
	ldr r10, =box6
	ldr r1, [r10]
	push {r10}
	cmp r1, #0
	bne	seven_box_1
	moveq r0, #227
	moveq r1, #99
	moveq r2, #0xff0
	bleq draw_cross
	push {r9, r10}
	ldr r10, =box6
	mov r9, #1
	str r9, [r10]
	ldr r10, =streak_2
	ldr r9, [r10]
	add r9, r9, #32
	str r9, [r10]
	pop {r9, r10}
	beq Change_to_player_1

seven_box_1:
	//check 7 box
	cmp r2, #61
	bne	eigth_box_1
	push {r10}
	ldr r10, =box7
	ldr r1, [r10]
	push {r10}
	cmp r1, #0
	bne	eigth_box_1
	moveq r0, #89
	moveq r1, #168
	moveq r2, #0xff0
	bleq draw_cross
	push {r9, r10}
	ldr r10, =box7
	mov r9, #1
	str r9, [r10]
	ldr r10, =streak_2
	ldr r9, [r10]
	add r9, r9, #64
	str r9, [r10]
	pop {r9, r10}
	beq Change_to_player_1

eigth_box_1:
	//check 8 box
	cmp r2, #62
	bne	nine_box_1
	push {r10}
	ldr r10, =box8
	ldr r1, [r10]
	push {r10}
	cmp r1, #0
	bne	nine_box_1
	moveq r0, #158
	moveq r1, #168
	moveq r2, #0xff0
	bleq draw_cross
	push {r9, r10}
	ldr r10, =box8
	mov r9, #1
	str r9, [r10]
	ldr r10, =streak_2
	ldr r9, [r10]
	add r9, r9, #128
	str r9, [r10]
	pop {r9, r10}
	beq Change_to_player_1

nine_box_1:
	//check 9 box
	cmp r2, #70
	bne game_starts_2
	push {r10}
	ldr r10, =box9
	ldr r1, [r10]
	push {r10}
	cmp r1, #0
	bne	game_starts_2
	moveq r0, #227
	moveq r1, #168
	moveq r2, #0xff0
	bleq draw_cross
	push {r9, r10}
	ldr r10, =box9
	mov r9, #1
	str r9, [r10]
	ldr r10, =streak_2
	ldr r9, [r10]
	add r9, r9, #256
	str r9, [r10]
	pop {r9, r10}
	beq Change_to_player_1
	
	b game_starts_2
	
Change_to_player_1:
	bl check_player_2_wins
	bl checkIfEnd
	mov r0, #0
	mov r2, #0
	bl	Player_turn_ASM
	b	game_starts
Change_to_player_2:
	push {r10}
	ldr r10, =hasStarted
	mov r1, #1
	str r1, [r10]
	push {r10}
	bl check_player_1_wins
	bl checkIfEnd
	mov r0, #0
	mov r2, #0
	bl	Player_turn_ASM
	b	game_starts_2
	

//check if player 2 has won
check_player_1_wins:
	ldr r0, =streak_1
	ldr r2, [r0]
	
	//first combination
	mov r0, #0
	and r0, r2, #0b111
	cmp r0, #0b111
	beq result_ASM
	
	//second combination
	mov r0, #0
	and r0, r2, #73
	cmp r0, #73
	beq result_ASM
	
	//third combination
	mov r0, #0
	and r0, r2, #0b111000
	cmp r0, #0b111000
	beq result_ASM
	
	//four combination
	mov r0, #0
	and r0, r2, #0b10010010
	cmp r0, #0b10010010
	beq result_ASM
	
	//five combination
	mov r0, #0
	and r0, r2, #0b1010100
	cmp r0, #0b1010100
	beq result_ASM
	
	//six combination
	mov r0, #0
	mov r1, #0b111000000
	//add r1, r1, #256
	and r0, r2, r1
	cmp r0, r1
	beq result_ASM
	
	//seven combination first diagonal
	mov r0, #0
	mov r1, #0b10001
	add r1, r1, #256
	and r0, r2, r1
	cmp r0, r1
	beq result_ASM
	
	//eight combination
	mov r0, #0
	mov r1, #0b100100
	add r1, r1, #256
	and r0, r2, r1
	cmp r0, r1
	beq result_ASM

	bx lr

//check if player 2 has won
check_player_2_wins:
	ldr r0, =streak_2
	ldr r2, [r0]
	
	//first combination
	mov r0, #0
	and r0, r2, #0b111
	cmp r0, #0b111
	beq result_ASM
	
	//second combination
	mov r0, #0
	and r0, r2, #73
	cmp r0, #73
	beq result_ASM
	
	//third combination
	mov r0, #0
	and r0, r2, #0b111000
	cmp r0, #0b111000
	beq result_ASM
	
	//four combination
	mov r0, #0
	and r0, r2, #0b10010010
	cmp r0, #0b10010010
	beq result_ASM
	
	//five combination
	mov r0, #0
	and r0, r2, #0b1010100
	cmp r0, #0b1010100
	beq result_ASM
	
	//six combination
	mov r0, #0
	mov r1, #0b111000000
	//add r1, r1, #256
	and r0, r2, r1
	cmp r0, r1
	beq result_ASM
	
	//seven combination first diagonal
	mov r0, #0
	mov r1, #0b10001
	add r1, r1, #256
	and r0, r2, r1
	cmp r0, r1
	beq result_ASM
	
	//eight combination
	mov r0, #0
	mov r1, #0b100100
	add r1, r1, #256
	and r0, r2, r1
	cmp r0, r1
	beq result_ASM

	bx lr

//check if there is a draw
checkIfEnd:
	ldr r0, =box1
	ldrb r2, [r0]
	cmp r2, #0
	bxeq lr
	
	ldr r0, =box2
	ldrb r2, [r0]
	cmp r2, #0
	bxeq lr
	
	ldr r0, =box3
	ldrb r2, [r0]
	cmp r2, #0
	bxeq lr
	
	ldr r0, =box4
	ldrb r2, [r0]
	cmp r2, #0
	bxeq lr
	
	ldr r0, =box5
	ldrb r2, [r0]
	cmp r2, #0
	bxeq lr
	
	ldr r0, =box6
	ldrb r2, [r0]
	cmp r2, #0
	bxeq lr
	
	ldr r0, =box7
	ldrb r2, [r0]
	cmp r2, #0
	bxeq lr
	
	ldr r0, =box8
	ldrb r2, [r0]
	cmp r2, #0
	bxeq lr
	
	ldr r0, =box9
	ldrb r2, [r0]
	cmp r2, #0
	bxeq lr
	
	b finish_draw
	
//Driver to write the player's turn
Player_turn_ASM:
		push {r3,r4,lr}
		ldr r4, =players_turn
		ldr r3, [r4]
        mov     r2, #80
        mov     r1, #2
        mov     r0, #33
        bl      VGA_write_char_ASM
        mov     r2, #76
        mov     r1, #2
        mov     r0, #34
        bl      VGA_write_char_ASM
        mov     r2, #65
        mov     r1, #2
        mov     r0, #35
        bl      VGA_write_char_ASM
        mov     r2, #89
        mov     r1, #2
        mov     r0, #36
        bl      VGA_write_char_ASM
        mov     r2, #69
        mov     r1, #2
        mov     r0, #37
        bl      VGA_write_char_ASM
        mov     r2, #82
        mov     r1, #2
        mov     r0, #38
        bl      VGA_write_char_ASM
        mov     r2, #32
        mov     r1, #2
        mov     r0, #39
        bl      VGA_write_char_ASM
		push	{r4, r5, r6}
		ldr		r4, =players_turn
		mov		r5, #0
		mov		r6, #1
		cmp 	r3, #0
        moveq 	r2, #49
		movgt	r2, #50
		streq	r6, [r4]
		strgt	r5, [r4]
		pop		{r4, r5, r6}
        mov     r1, #2
        mov     r0, #40
        bl      VGA_write_char_ASM
        mov     r2, #32
        mov     r1, #2
        mov     r0, #41
        bl      VGA_write_char_ASM
        mov     r2, #84
        mov     r1, #2
        mov     r0, #42
        bl      VGA_write_char_ASM
        mov     r2, #85
        mov     r1, #2
        mov     r0, #43
        bl      VGA_write_char_ASM
		mov     r2, #82
        mov     r1, #2
        mov     r0, #44
        bl      VGA_write_char_ASM
		mov     r2, #78
        mov     r1, #2
        mov     r0, #45
        bl      VGA_write_char_ASM
		pop {r3, r4, lr}
		bx lr

//Driver to write result of the game
result_ASM:
        mov     r2, #80
        mov     r1, #2
        mov     r0, #33
        bl      VGA_write_char_ASM
        mov     r2, #76
        mov     r1, #2
        mov     r0, #34
        bl      VGA_write_char_ASM
        mov     r2, #65
        mov     r1, #2
        mov     r0, #35
        bl      VGA_write_char_ASM
        mov     r2, #89
        mov     r1, #2
        mov     r0, #36
        bl      VGA_write_char_ASM
        mov     r2, #69
        mov     r1, #2
        mov     r0, #37
        bl      VGA_write_char_ASM
        mov     r2, #82
        mov     r1, #2
        mov     r0, #38
        bl      VGA_write_char_ASM
        mov     r2, #45
        mov     r1, #2
        mov     r0, #39
        bl      VGA_write_char_ASM
		push	{r4}
		ldr		r4, =players_turn
		ldr		r3, [r4]
		cmp 	r3, #0
        moveq 	r2, #50
		movgt	r2, #49
		pop		{r4}
        mov     r1, #2
        mov     r0, #40
        bl      VGA_write_char_ASM
        mov     r2, #32
        mov     r1, #2
        mov     r0, #41
        bl      VGA_write_char_ASM
        mov     r2, #87
        mov     r1, #2
        mov     r0, #42
        bl      VGA_write_char_ASM
        mov     r2, #73
        mov     r1, #2
        mov     r0, #43
        bl      VGA_write_char_ASM
		mov     r2, #78
        mov     r1, #2
        mov     r0, #44
        bl      VGA_write_char_ASM
		mov     r2, #83
        mov     r1, #2
        mov     r0, #45
        bl      VGA_write_char_ASM
		b idle		

//Driver to write "Draw"	
finish_draw:
		bl VGA_clear_charbuff_ASM //gonna cause problems when restarting
        mov     r2, #68
        mov     r1, #2
        mov     r0, #37
        bl      VGA_write_char_ASM
        mov     r2, #82
        mov     r1, #2
        mov     r0, #38
        bl      VGA_write_char_ASM
        mov     r2, #65
        mov     r1, #2
        mov     r0, #39
        bl      VGA_write_char_ASM
        mov     r2, #87
        mov     r1, #2
        mov     r0, #40
        bl      VGA_write_char_ASM
		b 		idle
		
//When finishing goes here and checks for 0 to restart	
idle:
	ldr r0, =checkifnice
    bl   read_PS2_data_ASM
	cmp     r0, #0
	beq idle
	
	//get make value
	push {r5}
	ldr r5, =checkifnice
	ldr r2, [r5]
	pop {r5}
	
	//clear
	push {r8, r9}
	ldr r9, =ps2Data
	ldr r8, [r9]
	ldr r8, [r9]
	pop {r8, r9}
	
	cmp r2, #0x45
	beq _start
	b idle

// *************************** START OF DRAW BOARD DRIVER ***************************

	
draw_board:
	push {lr}
	//draw first line
	mov r0, #125
	mov r1, #15
	mov r2, #0
	bl draw_first_line
	
	//draw second line
	mov r0, #194
	mov r1, #15
	bl draw_second_line
	
	//draw third line
	mov r0, #55
	mov r1, #84
	push {r3}
	mov r3, #220
	add r3, r3, #42
	bl draw_third_line
	pop {r3}
	
	//draw fourth line
	mov r0, #55
	mov r1, #153
	push {r3}
	mov r3, #220
	add r3, r3, #42
	bl draw_fourth_line
	pop {r3}
	pop {lr}
	bx lr
	
draw_first_line:
	cmp r1, #222
	bxeq lr
	push {lr}
	bl VGA_draw_point_ASM
	pop {lr}
	add r1, r1, #1
	b draw_first_line

draw_second_line:
	cmp r1, #222
	bxeq lr
	push {lr}
	bl VGA_draw_point_ASM
	pop {lr}
	add r1, r1, #1
	b draw_second_line
	
draw_third_line:
	cmp r0, r3
	bxeq lr
	push {lr}
	bl VGA_draw_point_ASM
	pop {lr}
	add r0, r0, #1
	b draw_third_line
	
draw_fourth_line:
	cmp r0, r3
	bxeq lr
	push {lr}
	bl VGA_draw_point_ASM
	pop {lr}
	add r0, r0, #1
	b draw_fourth_line

// *************************** END OF DRAW BOARD DRIVER ***************************

// *************************** START OF MAKE SQUARE DRIVER **************************

draw_square:
	push {lr}
	//draw line 1
	push {r10}
	add r10, r0, #39
	bl draw_square_1
	pop {r10}
	
	//draw line 2
	push {r10}
	add r10, r1, #39
	bl draw_square_2
	pop {r10}
	
	//draw line 3
	push {r10}
	sub r10, r0, #39
	bl draw_square_3
	pop {r10}
	
	//draw line 4
	push {r10}
	sub r10, r1, #39
	bl draw_square_4
	pop {r10}
	pop {lr}
	bx lr
	
draw_square_1:
	cmp r0, r10
	bxeq lr
	push {lr}
	bl VGA_draw_point_ASM
	pop {lr}
	add r0, r0, #1
	b draw_square_1
	
draw_square_2:
	cmp r1, r10
	bxeq lr
	push {lr}
	bl VGA_draw_point_ASM
	pop {lr}
	add r1, r1, #1
	b draw_square_2
	
draw_square_3:
	cmp r0, r10
	bxeq lr
	push {lr}
	bl VGA_draw_point_ASM
	pop {lr}
	sub r0, r0, #1
	b draw_square_3

draw_square_4:
	cmp r1, r10
	bxeq lr
	push {lr}
	bl VGA_draw_point_ASM
	pop {lr}
	sub r1, r1, #1
	b draw_square_4	

// *************************** END OF MAKE SQUARE DRIVER ***************************

// *************************** START OF DRAW CROSS DRIVER ***************************
draw_cross:
	push {r9, lr}
	ldr r9, =y_value
	str r1, [r9]
	pop {r9}
	//draw line 1
	push {r10}
	add r10, r1, #39
	bl draw_square_2
	pop {r10}
	
	//draw line 2
	push {r10, r11}
	ldr r11, =y_value
	ldr r1, [r11]
	add r1, r1, #19
	sub r0, r0, #19
	add r10, r0, #39
	bl draw_square_1
	pop {r10, r11}
	
	pop {lr}
	bx lr
// *************************** START OF DRAW CROSS DRIVER ***************************



@ TODO: copy VGA driver here.
VGA_draw_point_ASM:
	push {r3,r4,r5}
	ldr r3, =pixelBuffer //load base address
	lsl r4, r0, #1 //shift x 
	lsl r5, r1, #10 //shift y
	add r3, r3, r4 // base address + x
	add r3, r3, r5 //base address + x + y
	strh r2, [r3] //store pixel color in correct address
	pop {r3,r4,r5}
	bx lr
	
VGA_clear_pixelbuff_ASM:
	push {r10}
	mov r0, #0
	mov r1, #0
	push {r3}
	ldr r3, =red_color
	ldr r2, [r3]
	//mov r2, #0xf0f
	pop {r3}
	mov r10, #300
	add r10, r10, #20
	b increment_x_clear
	
increment_x_clear:
	cmp r0, r10 //compare r0 to max value of x
	push {lr}
	bllt VGA_draw_point_ASM //draw point if it hasn't reached it
	pop {lr}
	addlt r0, r0, #1 // increment x by 1 if it hasn't reached it
	moveq r0, #0 //reset x if it has reached it
	push {lr}
	bleq increment_y_clear //increment y
	pop {lr}
	cmp r1, #240
	popeq {r10}
	bxeq lr
	b increment_x_clear

increment_y_clear:
	cmp r1, #240
	addlt r1, r1, #1 //increment y
	bxlt lr
	bx lr //finished clearing
	
	
	
VGA_write_char_ASM:
	push {r3, r4}
	ldr r3, =charBuffer
	cmp r0, #0 //check x less than 0
	bxlt lr
	cmp r0, #79 //check x more than 79
	bxgt lr
	cmp r1, #0 //check y less than 0
	bxlt lr
	cmp r1, #59 //check y more than 59
	lsl r4, r1, #7 //shift y 
	add r3, r3, r0 //base address + x
	add r3, r3, r4 //base address + x + y
	strb r2, [r3]
	pop {r3,r4}
	bx lr
	
VGA_clear_charbuff_ASM:
	mov r0, #0
	mov r1, #0
	mov r2, #0	
	b increment_x_char
	
increment_x_char:
	cmp r0, #80
	push {lr}
	bllt VGA_write_char_ASM
	pop {lr}
	addlt r0, r0, #1 // increment x by 1 if it hasn't reached it
	moveq r0, #0 //reset x if it has reached it
	push {lr}
	bleq increment_y_char //increment y
	pop {lr}
	cmp r1, #60
	bxeq lr
	b increment_x_char
	
increment_y_char:
	cmp r1, #60
	addlt r1, r1, #1 //increment y
	bxlt lr
	bx lr //finished clearing
	
//PS/2 driver.
read_PS2_data_ASM:
	
	push {r3}
	ldr r1, =ps2Data //load address of ps2_data
	
	ldr r2, [r1] //get value of ps2_data
	and r3, r2, #0b1000000000000000 //check bit 16 that is RVALID
	
	cmp r3, #0
	moveq r0, #0
	popeq {r3}
	bxeq lr
	strb r2, [r0]
	mov r0, #1
	pop {r3}
	bx lr