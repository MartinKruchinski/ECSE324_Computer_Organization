.global _start

//Adresses
.equ pixelBuffer, 0xc8000000
.equ charBuffer, 0xc9000000
_start:
        bl      draw_test_screen
end:
        b       end

@ TODO: Insert VGA driver functions here.
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
	mov r2, #0
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
		
draw_test_screen:
        push    {r4, r5, r6, r7, r8, r9, r10, lr}
        bl      VGA_clear_pixelbuff_ASM
        bl      VGA_clear_charbuff_ASM
        mov     r6, #0
        ldr     r10, .draw_test_screen_L8
        ldr     r9, .draw_test_screen_L8+4
        ldr     r8, .draw_test_screen_L8+8
        b       .draw_test_screen_L2
.draw_test_screen_L7:
        add     r6, r6, #1
        cmp     r6, #320
        beq     .draw_test_screen_L4
.draw_test_screen_L2:
        smull   r3, r7, r10, r6
        asr     r3, r6, #31
        rsb     r7, r3, r7, asr #2
        lsl     r7, r7, #5
        lsl     r5, r6, #5
        mov     r4, #0
.draw_test_screen_L3:
        smull   r3, r2, r9, r5
        add     r3, r2, r5
        asr     r2, r5, #31
        rsb     r2, r2, r3, asr #9
        orr     r2, r7, r2, lsl #11
        lsl     r3, r4, #5
        smull   r0, r1, r8, r3
        add     r1, r1, r3
        asr     r3, r3, #31
        rsb     r3, r3, r1, asr #7
        orr     r2, r2, r3
        mov     r1, r4
        mov     r0, r6
        bl      VGA_draw_point_ASM
        add     r4, r4, #1
        add     r5, r5, #32
        cmp     r4, #240
        bne     .draw_test_screen_L3
        b       .draw_test_screen_L7
.draw_test_screen_L4:
        mov     r2, #72
        mov     r1, #5
        mov     r0, #20
        bl      VGA_write_char_ASM
        mov     r2, #101
        mov     r1, #5
        mov     r0, #21
        bl      VGA_write_char_ASM
        mov     r2, #108
        mov     r1, #5
        mov     r0, #22
        bl      VGA_write_char_ASM
        mov     r2, #108
        mov     r1, #5
        mov     r0, #23
        bl      VGA_write_char_ASM
        mov     r2, #111
        mov     r1, #5
        mov     r0, #24
        bl      VGA_write_char_ASM
        mov     r2, #32
        mov     r1, #5
        mov     r0, #25
        bl      VGA_write_char_ASM
        mov     r2, #87
        mov     r1, #5
        mov     r0, #26
        bl      VGA_write_char_ASM
        mov     r2, #111
        mov     r1, #5
        mov     r0, #27
        bl      VGA_write_char_ASM
        mov     r2, #114
        mov     r1, #5
        mov     r0, #28
        bl      VGA_write_char_ASM
        mov     r2, #108
        mov     r1, #5
        mov     r0, #29
        bl      VGA_write_char_ASM
        mov     r2, #100
        mov     r1, #5
        mov     r0, #30
        bl      VGA_write_char_ASM
        mov     r2, #33
        mov     r1, #5
        mov     r0, #31
        bl      VGA_write_char_ASM
        pop     {r4, r5, r6, r7, r8, r9, r10, pc}
.draw_test_screen_L8:
        .word   1717986919
        .word   -368140053
        .word   -2004318071