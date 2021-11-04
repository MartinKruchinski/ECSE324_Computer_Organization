PB_int_flag :
    .word 0x0
	
tim_int_flag :
    .word 0x0
.section .vectors, "ax"
B _start
B SERVICE_UND       // undefined instruction vector
B SERVICE_SVC       // software interrupt vector
B SERVICE_ABT_INST  // aborted prefetch vector
B SERVICE_ABT_DATA  // aborted data vector
.word 0 // unused vector
B SERVICE_IRQ       // IRQ interrupt vector
B SERVICE_FIQ       // FIQ interrupt vector

.text
.global _start
.equ HEX_3to0, 0xFF200020
.equ HEX_4to5, 0xFF200030
.equ loadTimer, 0xFFFEC600
.equ MaskBits, 0xFF200058
.equ EdgeBits, 0xFF20005C
initialCount: .word 1 // 10 milisecond

_start:
    /* Set up stack pointers for IRQ and SVC processor modes */
    MOV        R1, #0b11010010      // interrupts masked, MODE = IRQ
    MSR        CPSR_c, R1           // change to IRQ mode
    LDR        SP, =0xFFFFFFFF - 3  // set IRQ stack to A9 onchip memory
    /* Change to SVC (supervisor) mode with interrupts disabled */
    MOV        R1, #0b11010011      // interrupts masked, MODE = SVC
    MSR        CPSR, R1             // change to supervisor mode
    LDR        SP, =0x3FFFFFFF - 3  // set SVC stack to top of DDR3 memory
    BL     CONFIG_GIC           // configure the ARM GIC
    // To DO: write to the pushbutton KEY interrupt mask register
    // Or, you can call enable_PB_INT_ASM subroutine from previous task
    // to enable interrupt for ARM A9 private timer, use ARM_TIM_config_ASM subroutine
	BL ARM_TIM_config_ASM
	BL enable_PB_INT_ASM
	///////////////////////////////////////////////////////////////////////
    LDR        R0, =0xFF200050      // pushbutton KEY base address
    MOV        R1, #0xF             // set interrupt mask bits
    STR        R1, [R0, #0x8]       // interrupt mask register (base + 8)
    // enable IRQ interrupts in the processor
    MOV        R0, #0b01010011      // IRQ unmasked, MODE = SVC
    MSR        CPSR_c, R0
IDLE:
    B IDLE // This is where you write your objective task
	

/*--- Undefined instructions ---------------------------------------- */
SERVICE_UND:
    B SERVICE_UND
/*--- Software interrupts ------------------------------------------- */
SERVICE_SVC:
    B SERVICE_SVC
/*--- Aborted data reads -------------------------------------------- */
SERVICE_ABT_DATA:
    B SERVICE_ABT_DATA
/*--- Aborted instruction fetch ------------------------------------- */
SERVICE_ABT_INST:
    B SERVICE_ABT_INST
/*--- IRQ ----------------------------------------------------------- */
SERVICE_IRQ:
    PUSH {R0-R7, LR}
/* Read the ICCIAR from the CPU Interface */
    LDR R4, =0xFFFEC100
    LDR R5, [R4, #0x0C] // read from ICCIAR

Timer_check: //CHECK TIMER INTERRUPT
	CMP R5, #29 //Check for arm timer
	BNE Pushbutton_check
	BL ARM_TIM_ISR
	B EXIT_IRQ
	
Pushbutton_check: //CHECK BUTTON INTERRUPT
    CMP R5, #73
	
UNEXPECTED:
    BNE UNEXPECTED      // if not recognized, stop here
    BL KEY_ISR
	
EXIT_IRQ:
/* Write to the End of Interrupt Register (ICCEOIR) */
    STR R5, [R4, #0x10] // write to ICCEOIR
    POP {R0-R7, LR}
SUBS PC, LR, #4
/*--- FIQ ----------------------------------------------------------- */
SERVICE_FIQ:
    B SERVICE_FIQ
	
CONFIG_GIC:
    PUSH {LR}
/* To configure the FPGA KEYS interrupt (ID 73):
* 1. set the target to cpu0 in the ICDIPTRn register
* 2. enable the interrupt in the ICDISERn register */
/* CONFIG_INTERRUPT (int_ID (R0), CPU_target (R1)); */
/* To Do: you can configure different interrupts
   by passing their IDs to R0 and repeating the next 3 lines */
    MOV R0, #29            // TIMER INTERRUPT (Interrupt ID = 29)
    MOV R1, #1   //CHANGE          // this field is a bit-mask; bit 0 targets cpu0
    BL CONFIG_INTERRUPT
	MOV R0, #73            // KEY port (Interrupt ID = 73)
    MOV R1, #1             // this field is a bit-mask; bit 0 targets cpu0
    BL CONFIG_INTERRUPT
	

/* configure the GIC CPU Interface */
    LDR R0, =0xFFFEC100    // base address of CPU Interface
/* Set Interrupt Priority Mask Register (ICCPMR) */
    LDR R1, =0xFFFF        // enable interrupts of all priorities levels
    STR R1, [R0, #0x04]
/* Set the enable bit in the CPU Interface Control Register (ICCICR).
* This allows interrupts to be forwarded to the CPU(s) */
    MOV R1, #1
    STR R1, [R0]
/* Set the enable bit in the Distributor Control Register (ICDDCR).
* This enables forwarding of interrupts to the CPU Interface(s) */
    LDR R0, =0xFFFED000
    STR R1, [R0]
    POP {PC}

/*
* Configure registers in the GIC for an individual Interrupt ID
* We configure only the Interrupt Set Enable Registers (ICDISERn) and
* Interrupt Processor Target Registers (ICDIPTRn). The default (reset)
* values are used for other registers in the GIC
* Arguments: R0 = Interrupt ID, N
* R1 = CPU target
*/
CONFIG_INTERRUPT:
    PUSH {R4-R5, LR}
/* Configure Interrupt Set-Enable Registers (ICDISERn).
* reg_offset = (integer_div(N / 32) * 4
* value = 1 << (N mod 32) */
    LSR R4, R0, #3    // calculate reg_offset
    BIC R4, R4, #3    // R4 = reg_offset
    LDR R2, =0xFFFED100
    ADD R4, R2, R4    // R4 = address of ICDISER
    AND R2, R0, #0x1F // N mod 32
    MOV R5, #1        // enable
    LSL R2, R5, R2    // R2 = value
/* Using the register address in R4 and the value in R2 set the
* correct bit in the GIC register */
    LDR R3, [R4]      // read current register value
    ORR R3, R3, R2    // set the enable bit
    STR R3, [R4]      // store the new register value
/* Configure Interrupt Processor Targets Register (ICDIPTRn)
* reg_offset = integer_div(N / 4) * 4
* index = N mod 4 */
    BIC R4, R0, #3    // R4 = reg_offset
    LDR R2, =0xFFFED800
    ADD R4, R2, R4    // R4 = word address of ICDIPTR
    AND R2, R0, #0x3  // N mod 4
    ADD R4, R2, R4    // R4 = byte address in ICDIPTR
/* Using register address in R4 and the value in R2 write to
* (only) the appropriate byte */
    STRB R1, [R4]
    POP {R4-R5, PC}
	
KEY_ISR:
    LDR R0, =0xFF200050    // base address of pushbutton KEY port
    LDR R1, [R0, #0xC]     // read edge capture register
    MOV R2, #0xF
    STR R2, [R0, #0xC]     // clear the interrupt
    LDR R0, =PB_int_flag    // load PB_int_flag address
	STR R1, [R0] //write the content of pushbuttons edgecapture register in to the PB_int_flag memory
    BX LR
	

ARM_TIM_config_ASM:
	ldr r0, initialCount
	ldr r2, =loadTimer //getting address timer
	str r0, [r2] //loading initial count value into timer
	mov r3, #0b111 // I=1, A=1, E=1
	strb r3, [r2, #0x8] // write to timer control register
	mov r3, #0b0
	strb r3, [r2, #0x9] //store vlaue 1 in the prescaler
	//CLEAR TIME HAS REACHED 0?
	bx lr

enable_PB_INT_ASM:
	push {r4, r6}
	ldr r4, =MaskBits
	mov r6, #0xF //indice for all pushbuttons
	str r6, [r4] //enable interrupts for all pushbuttons
	pop {r4, r6}
	bx lr


ARM_TIM_ISR:
	ldr r0, =0xFFFEC60C
	ldr r1, [r0]
	mov r2, #1
	cmp r1, #1
	streq r2, [r0]
	ldr r0, =tim_int_flag
	cmp r1, #1
	streq r1, [r0]
	bx lr


/*
ARM_TIM_config_ASM:
	
	ldr r0, initialCount
	mov r10, #0
	ldr r2, =loadTimer //getting address timer
	str r0, [r2] //loading initial count value into timer
	mov r3, #0b011 // set bits: mode = 1 (auto), enable = 1
	strb r3, [r2, #0x8] // write to timer control register
	mov r3, #0b00
	strb r3, [r2, #0x9] //store vlaue 1 in the prescaler
	mov r7, #0x0
	mov r8, #0x0
	mov r9, #0x0
	mov r11, #0x0
	mov r12, #0x0
	mov r5,#0b000
	bl PB_clear_edgecp_ASM
	b read_PB_edgecp_ASM

read_PB_edgecp_ASM:
	ldr r0, =EdgeBits
	ldr r5, [r0]
	//check for start button
	cmp r5, #0b001
	beq ARM_TIM_read_INT_ASM
	//cmp r5, #0b011
	//beq ARM_TIM_read_INT_ASM
	//check for stop button
	cmp r5, #0b011
	bleq PB_clear_edgecp_ASM
	//check for reset button
	cmp r5, #0b100
	bleq PB_clear_edgecp_ASM
	beq _start
	
	b read_PB_edgecp_ASM
	
PB_clear_edgecp_ASM:
	push {r2, r3}
	ldr r2, =EdgeBits
	ldr r3, [r2]
	str r3, [r2]
	pop {r2, r3}
	bx lr
	
	
ARM_TIM_read_INT_ASM:
	mov r6, #0
	ldr r1, =HEX_3to0
	b display_0
	//subgt r10, r10, #0x1
	//beq display_1
	//b ARM_TIM_read_INT_ASM

display_0:
	ldr r3, [r2, #0xC] //WHERE SHOULD I STORE IT?
	cmp r3, #1
	blt display_0
	bleq HEX_write_ASM
	add r6, r6, #1
	bl ARM_TIM_clear_INT_ASM
	cmp r6, #10
	blt display_0
	//mov r6, #0
	//bl HEX_write_ASM
	add r10, r10, #0x1
	beq display_1
	
display_1:	
	cmp r3, #1
	blt display_1
	add r7, r7, #1
	mov r6, r7
	//
	cmp r7, #10
	bllt HEX_write_ASM
	bllt ARM_TIM_clear_INT_ASM
	mov r10, #0x0
	mov r6, #0x0
	cmp r7, #10
	bllt read_PB_edgecp_ASM
	mov r7, #0
	mov r6, r7
	bl HEX_write_ASM
	bl ARM_TIM_clear_INT_ASM
	add r10, r10, #0x2
	b display_2
	
display_2:
	cmp r3, #1
	blt display_2
	add r8, r8, #1
	mov r6, r8
	//
	cmp r8, #10
	bllt HEX_write_ASM
	bllt ARM_TIM_clear_INT_ASM
	mov r10, #0x1
	mov r6, #0x0
	cmp r8, #10
	bllt HEX_write_ASM
	mov r10, #0x0
	cmp r8, #10
	bllt HEX_write_ASM
	cmp r8, #10
	blt read_PB_edgecp_ASM //change to link?
	//mov r8, #0
	//mov r6, r8
	//bl HEX_write_ASM
	//bl ARM_TIM_clear_INT_ASM
	add r10, r10, #0x3
	b display_3
display_3:
	cmp r3, #1
	blt display_3
	add r9, r9, #1
	mov r6, r9
	//
	cmp r9, #6
	bllt HEX_write_ASM
	bllt ARM_TIM_clear_INT_ASM
	mov r10, #0x2
	mov r6, #0x0
	cmp r9, #6
	bllt HEX_write_ASM
	mov r10, #0x1
	cmp r9, #6
	bllt HEX_write_ASM
	mov r10, #0x0
	cmp r9, #6
	bllt HEX_write_ASM
	mov r8, #0
	cmp r9, #6
	blt read_PB_edgecp_ASM //change to link?
	//mov r8, #0
	//mov r6, r8
	//bl HEX_write_ASM
	//bl ARM_TIM_clear_INT_ASM
	mov r10, #0x10
	b display_4
	
display_4:
	cmp r3, #1
	blt display_3
	add r11, r11, #1
	mov r6, r11
	//
	cmp r11, #10
	bllt HEX_write_ASM
	bllt ARM_TIM_clear_INT_ASM
	mov r10, #0x3
	mov r6, #0x0
	cmp r11, #10
	bllt HEX_write_ASM
	mov r10, #0x2
	cmp r11, #10
	bllt HEX_write_ASM
	mov r10, #0x1
	cmp r11, #10
	bllt HEX_write_ASM
	mov r10, #0x0
	cmp r11, #10
	bllt HEX_write_ASM
	mov r8, #0
	mov r9, #0
	cmp r11, #10
	blt read_PB_edgecp_ASM //change to link?
	mov r10, #0x11
	b display_5
	
display_5:
	cmp r3, #1
	blt display_3
	add r12, r12, #1
	mov r6, r12
	//
	cmp r12, #6
	bllt HEX_write_ASM
	bllt ARM_TIM_clear_INT_ASM
	mov r10, #0x10
	mov r6, #0x0
	cmp r12, #6
	bllt HEX_write_ASM
	mov r10, #0x3
	cmp r12, #6
	bllt HEX_write_ASM
	mov r10, #0x2
	cmp r12, #6
	bllt HEX_write_ASM
	mov r10, #0x1
	cmp r12, #6
	bllt HEX_write_ASM
	mov r10, #0x0
	cmp r12, #6
	bllt HEX_write_ASM
	mov r8, #0
	mov r9, #0
	mov r11, #0
	cmp r12, #6
	blt read_PB_edgecp_ASM //change to link?
	b end
	
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
	strb r5, [r1, r10]
	pop {r5}
	bx lr

	
end:
	 b end
*/	