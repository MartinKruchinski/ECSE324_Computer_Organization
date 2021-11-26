y_value: .word 0x0
players_turn: .word 0x0
player_wins: .word 0x0
.equ pixelBuffer, 0xc8000000
.equ charBuffer, 0xc9000000
.equ ps2Data, 0xFF200100
.global _start

//Adresses
white_screen: .word 0xffff
red_color: .word 0xf200

_start:
        bl VGA_clear_pixelbuff_ASM //set background to white
		bl VGA_clear_charbuff_ASM
		bl draw_board //draw board
		b  input_loop

input_loop:
    bl   read_PS2_data_ASM
	cmp     r0, #0
	beq input_loop
	ldr r1, =0xFF200100
	ldrb r2, [r1]
	//check for key 0 pressed
	cmp r2, #69
	bne	input_loop
	bl Player_turn_ASM //write player's turn
	b game_starts

game_starts:
    bl   read_PS2_data_ASM
	cmp     r0, #0
	beq game_starts
	ldr r1, =0xFF200100
	ldrb r2, [r1]
	
	//check first box
	cmp r2, #22
	mov r2, #0xf
	mov r0, #70
	mov r1, #30
	bleq draw_square
	ldr r1, =0xFF200100
	ldr r2, [r1] //get value of ps2_data
	ldr r2, [r1] //get value of ps2_data
	beq Change_to_player_2
	
	//check second box
	bl   read_PS2_data_ASM
	cmp r2, #30
	mov r0, #139
	mov r1, #30
	mov r2, #0xf
	bleq draw_square
	ldr r1, =0xFF200100
	ldr r2, [r1] //get value of ps2_data
	ldr r2, [r1] //get value of ps2_data
	beq Change_to_player_2
	
	//check third box
	bl   read_PS2_data_ASM
	cmp r2, #38
	mov r0, #208
	mov r1, #30
	mov r2, #0xf
	bleq draw_square
	ldr r1, =0xFF200100
	ldr r2, [r1] //get value of ps2_data
	ldr r2, [r1] //get value of ps2_data
	beq Change_to_player_2
	
	//check 4 box
	bl   read_PS2_data_ASM
	cmp r2, #37
	mov r0, #70
	mov r1, #99
	mov r2, #0xf
	bleq draw_square
	ldr r1, =0xFF200100
	ldr r2, [r1] //get value of ps2_data
	ldr r2, [r1] //get value of ps2_data
	beq Change_to_player_2
	
	//check 5 box
	bl   read_PS2_data_ASM
	cmp r2, #46
	mov r0, #139
	mov r1, #99
	mov r2, #0xf
	bleq draw_square
	ldr r1, =0xFF200100
	ldr r2, [r1] //get value of ps2_data
	ldr r2, [r1] //get value of ps2_data
	beq Change_to_player_2
	
	
	//check 6 box
	bl   read_PS2_data_ASM
	cmp r2, #54
	mov r0, #208
	mov r1, #99
	mov r2, #0xf
	bleq draw_square
	ldr r1, =0xFF200100
	ldr r2, [r1] //get value of ps2_data
	ldr r2, [r1] //get value of ps2_data
	beq Change_to_player_2
	
	//check 7 box
	bl   read_PS2_data_ASM
	cmp r2, #61
	mov r0, #70
	mov r1, #168
	mov r2, #0xf
	bleq draw_square
	ldr r1, =0xFF200100
	ldr r2, [r1] //get value of ps2_data
	ldr r2, [r1] //get value of ps2_data
	beq Change_to_player_2
	
	//check 8 box
	bl   read_PS2_data_ASM
	cmp r2, #62
	mov r0, #139
	mov r1, #168
	mov r2, #0xf
	bleq draw_square
	ldr r1, =0xFF200100
	ldr r2, [r1] //get value of ps2_data
	ldr r2, [r1] //get value of ps2_data
	beq Change_to_player_2
	
	//check 9 box
	bl   read_PS2_data_ASM
	cmp r2, #70
	mov r0, #208
	mov r1, #168
	mov r2, #0xf
	bleq draw_square
	ldr r1, =0xFF200100
	ldr r2, [r1] //get value of ps2_data
	ldr r2, [r1] //get value of ps2_data
	beq Change_to_player_2
	
	b game_starts
	
	
game_starts_2:
    bl   read_PS2_data_ASM
	cmp     r0, #0
	beq game_starts_2
	ldr r1, =ps2Data
	ldrb r2, [r1]
	
	//check first box
	cmp r2, #22
	mov r2, #0xff0
	mov r0, #89
	mov r1, #30
	bleq draw_cross
	ldr r1, =0xFF200100
	ldr r2, [r1] //get value of ps2_data
	ldr r2, [r1] //get value of ps2_data
	beq Change_to_player_1
	
	//check second box
	bl   read_PS2_data_ASM
	cmp r2, #30
	mov r0, #158
	mov r1, #30
	mov r2, #0xff0
	bleq draw_cross
	ldr r1, =0xFF200100
	ldr r2, [r1] //get value of ps2_data
	ldr r2, [r1] //get value of ps2_data
	beq Change_to_player_1
	
	//check third box
	bl   read_PS2_data_ASM
	cmp r2, #38
	mov r0, #227
	mov r1, #30
	mov r2, #0xff0
	bleq draw_cross
	ldr r1, =0xFF200100
	ldr r2, [r1] //get value of ps2_data
	ldr r2, [r1] //get value of ps2_data
	beq Change_to_player_1
	
	//check 4 box
	bl   read_PS2_data_ASM
	cmp r2, #37
	mov r0, #89
	mov r1, #99
	mov r2, #0xff0
	bleq draw_cross
	ldr r1, =0xFF200100
	ldr r2, [r1] //get value of ps2_data
	ldr r2, [r1] //get value of ps2_data
	beq Change_to_player_1
	
	//check 5 box
	bl   read_PS2_data_ASM
	cmp r2, #46
	mov r0, #158
	mov r1, #99
	mov r2, #0xff0
	bleq draw_cross
	ldr r1, =0xFF200100
	ldr r2, [r1] //get value of ps2_data
	ldr r2, [r1] //get value of ps2_data
	beq Change_to_player_1
	
	
	//check 6 box
	bl   read_PS2_data_ASM
	cmp r2, #54
	mov r0, #227
	mov r1, #99
	mov r2, #0xff0
	bleq draw_cross
	ldr r1, =0xFF200100
	ldr r2, [r1] //get value of ps2_data
	ldr r2, [r1] //get value of ps2_data
	beq Change_to_player_1
	
	//check 7 box
	bl   read_PS2_data_ASM
	cmp r2, #61
	mov r0, #89
	mov r1, #168
	mov r2, #0xff0
	bleq draw_cross
	ldr r1, =0xFF200100
	ldr r2, [r1] //get value of ps2_data
	ldr r2, [r1] //get value of ps2_data
	beq Change_to_player_1
	
	//check 8 box
	bl   read_PS2_data_ASM
	cmp r2, #62
	mov r0, #158
	mov r1, #168
	mov r2, #0xff0
	bleq draw_cross
	ldr r1, =0xFF200100
	ldr r2, [r1] //get value of ps2_data
	ldr r2, [r1] //get value of ps2_data
	beq Change_to_player_1
	
	//check 9 box
	bl   read_PS2_data_ASM
	cmp r2, #70
	mov r0, #227
	mov r1, #168
	mov r2, #0xff0
	bleq draw_cross
	ldr r1, =0xFF200100
	ldr r2, [r1] //get value of ps2_data
	ldr r2, [r1] //get value of ps2_data
	beq Change_to_player_1
	
	b game_starts_2
	
Change_to_player_1:
	mov r0, #0
	mov r2, #0
	bl	Player_turn_ASM
	b	game_starts
Change_to_player_2:
	mov r0, #0
	mov r2, #0
	bl	Player_turn_ASM
	b	game_starts_2
	
/*

		//draw square
		mov r0, #70
		mov r1, #30
		push {r9}
		ldr r9, =red_color
		ldr r2, [r9]
		pop {r9}
		bl draw_square
		
		//draw cross
		mov r0, #158
		mov r1, #30
		mov r2, #0xff0
		push {r9}
		ldr r9, =y_value
		str r1, [r9]
		pop {r9}
		bl draw_cross
		bl VGA_clear_charbuff_ASM
		push {r3,r4}
		ldr r4, =players_turn
		ldr r3, [r4]
		bl Player_turn_ASM
		pop {r3, r4}
		bl result_ASM
*/		
end:
        b       end
		

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

result_ASM:
		push {lr}
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
        moveq 	r2, #49
		movgt	r2, #50
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
		pop {lr}
		bx lr
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
	
@ TODO: insert PS/2 driver here.
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
	