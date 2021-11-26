.global _start

//Adresses
.equ pixelBuffer, 0xc8000000
.equ charBuffer, 0xc9000000
.equ ps2Data, 0xFF200100
_start:
        bl      input_loop
end:
        b       end

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

write_hex_digit:
        push    {r4, lr}
        cmp     r2, #9
        addhi   r2, r2, #55
        addls   r2, r2, #48
        and     r2, r2, #255
        bl      VGA_write_char_ASM
        pop     {r4, pc}
write_byte:
        push    {r4, r5, r6, lr}
        mov     r5, r0
        mov     r6, r1
        mov     r4, r2
        lsr     r2, r2, #4
        bl      write_hex_digit
        and     r2, r4, #15
        mov     r1, r6
        add     r0, r5, #1
        bl      write_hex_digit
        pop     {r4, r5, r6, pc}
input_loop:
        push    {r4, r5, lr}
        sub     sp, sp, #12
        bl      VGA_clear_pixelbuff_ASM
        bl      VGA_clear_charbuff_ASM
        mov     r4, #0
        mov     r5, r4
        b       .input_loop_L9
.input_loop_L13:
        ldrb    r2, [sp, #7]
        mov     r1, r4
        mov     r0, r5
        bl      write_byte
        add     r5, r5, #3
        cmp     r5, #79
        addgt   r4, r4, #1
        movgt   r5, #0
.input_loop_L8:
        cmp     r4, #59
        bgt     .input_loop_L12
.input_loop_L9:
        add     r0, sp, #7
        bl      read_PS2_data_ASM
        cmp     r0, #0
        beq     .input_loop_L8
        b       .input_loop_L13
.input_loop_L12:
        add     sp, sp, #12
        pop     {r4, r5, pc}