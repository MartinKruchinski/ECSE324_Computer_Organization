PB_int_flag :
    .word 0x0
	
tim_int_flag :
    .word 0x0
	
ctrHex_2: .word 0x0
ctrHex_3: .word 0x0
ctrHex_4: .word 0x0
ctrHex_5: .word 0x0


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


.equ hex0, 0xFF200020
.equ hex1, 0xFF200021
.equ hex2, 0xFF200022
.equ hex3, 0xFF200023
.equ hex4, 0xFF200030
.equ hex5, 0xFF200031

initialCount: .word 2000000 // 10 milisecond
floodzeros: .word 0x3F3F3F3F//zeros


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
	
	//reset int flag to 0 when restarting program
	LDR R0, =PB_int_flag
	mov r1, #0x0
	str r1, [r0]
	
	//fill everything with 0s
	bl HEX_flood_ASM
	//Clear counters
	mov r2, #0 //COUNTER FOR HEX 0
	mov r3, #0 //counter for hex 1
	ldr r1, =ctrHex_2
	str r2, [r1]
	ldr r1, =ctrHex_3
	str r2, [r1]
	ldr r1, =ctrHex_4
	str r2, [r1]
	ldr r1, =ctrHex_5
	str r2, [r1]
	

IDLE:
	ldr r1, =tim_int_flag
	ldr r0, [r1]
	push {r9}
	mov r9, #0
	cmp r0, #1
	streq r9, [r1]
	pop {r9}
	blt IDLE
	
	ldr r0, =PB_int_flag
	ldr r1, [r0]
	
	cmp r1, #0b001
	bleq main_loop
	
	cmp r1, #0b011
	bleq PB_clear_edgecp_ASM
	
	cmp r1, #0b100
	bleq PB_clear_edgecp_ASM
	beq _start
	
    B IDLE 
	
	

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
    //mov r3, #0
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
	//mov r3, #0b0
	//strb r3, [r2, #0x9] //store vlaue 1 in the prescaler
	bx lr

enable_PB_INT_ASM:
	push {r4, r6}
	ldr r4, =MaskBits
	mov r6, #0xF //indice for all pushbuttons
	str r6, [r4] //enable interrupts for all pushbuttons
	pop {r4, r6}
	bx lr


ARM_TIM_ISR:
	//add r3, r3, #1
	ldr r0, =0xFFFEC60C
	ldr r1, [r0]
	str r1, [r0]
	ldr r0, =tim_int_flag
	//mov r2, #0
	//str r2, [r0]
	str r1, [r0]
	bx lr


//Part from 2.2



	
PB_clear_edgecp_ASM:
	push {r2, r3}
	ldr r2, =EdgeBits
	ldr r3, [r2]
	str r3, [r2]
	pop {r2, r3}
	bx lr
	

main_loop:
push {lr}
//display_0
	ldr r1, =hex0 //address first display
	//add r1, r1, #1
	bl HEX_write_ASM
	add r2, r2, #1 //add 1 to counter display 0
	cmp r2, #11
	poplt {lr}
	bxlt lr
	
	//0 to hex_0
	push {r10}
	mov r10, #0x3f
	strb r10, [r1]
	pop {r10}
	
//display_1
	ldr r1, =hex1
	add r3, r3, #1
	mov r2, r3
	bl HEX_write_ASM
	mov r2, #1 //reset counter 
	cmp r3, #10
	poplt {lr}
	bxlt lr
	
	//0 to hex_1
	push {r10}
	mov r10, #0x3f
	strb r10, [r1]
	pop {r10}
	mov r3, #0 //reset counter hex_1
	
//display_2
	ldr r1, =hex2
	push {r4, r10}
	ldr r10, =ctrHex_2 //get counter hex_2
	ldr r4, [r10] //get value counter hex_2
	add r4, r4, #1 //add 1 to counter hex_2
	str r4, [r10] //store new value to counter hex_2
	mov r2, r4
	bl HEX_write_ASM
	mov r2, #0 //reset counter hex0 to 0
	cmp r4, #10
	pop {r4, r10}
	poplt {lr}
	bxlt lr
	
	//0 to hex_1
	push {r4, r10}
	mov r10, #0x3f
	strb r10, [r1]
	ldr r10, =ctrHex_2 //get counter hex_2
	mov r4, #0
	str r4, [r10] //get value counter hex_2
	pop {r4, r10}

//display_3
	ldr r1, =hex3
	push {r4, r10}
	ldr r10, =ctrHex_3 //get counter hex_2
	ldr r4, [r10] //get value counter hex_2
	add r4, r4, #1 //add 1 to counter hex_2
	str r4, [r10] //store new value to counter hex_2
	mov r2, r4
	bl HEX_write_ASM
	mov r2, #0 //reset counter hex0 to 0
	cmp r4, #6
	pop {r4, r10}
	poplt {lr}
	bxlt lr
	
	//0 to hex_1
	push {r4, r10}
	mov r10, #0x3f
	strb r10, [r1]
	ldr r10, =ctrHex_3 //get counter hex_2
	mov r4, #0
	str r4, [r10] //get value counter hex_2
	pop {r4, r10}

//display_4
	ldr r1, =hex4
	push {r6, r10}
	ldr r10, =ctrHex_4 //get counter hex_2
	ldr r6, [r10] //get value counter hex_2
	add r6, r6, #1 //add 1 to counter hex_2
	str r6, [r10] //store new value to counter hex_2
	mov r2, r6
	bl HEX_write_ASM
	mov r2, #0 //reset counter hex0 to 0
	cmp r6, #10
	pop {r6, r10}
	poplt {lr}
	bxlt lr
	
	//0 to hex_1
	push {r6, r10}
	mov r10, #0x3f
	strb r10, [r1]
	ldr r10, =ctrHex_4 //get counter hex_2
	mov r6, #0
	str r6, [r10] //get value counter hex_2
	pop {r6, r10}

//display_5
	ldr r1, =hex5
	push {r6, r10}
	ldr r10, =ctrHex_5 //get counter hex_2
	ldr r6, [r10] //get value counter hex_2
	add r6, r6, #1 //add 1 to counter hex_2
	str r6, [r10] //store new value to counter hex_2
	mov r2, r6
	bl HEX_write_ASM
	mov r2, #0 //reset counter hex0 to 0
	cmp r6, #6
	pop {r6, r10}
	poplt {lr}
	bxlt lr
	b _start

HEX_write_ASM:
	push {r5}
	
	cmp r2, #0
	moveq r5, #0b0111111 //encoding number 0 binary
	beq next

	cmp r2, #1
	moveq r5, #0b0000110 //encoding number 1 binary
	beq next
	
	cmp r2, #2
	moveq r5, #0b1011011 //encoding number 2 binary
	beq next
	
	cmp r2, #3
	moveq r5, #0b1001111 //encoding number 3 binary
	beq next
	
	cmp r2, #4
	moveq r5, #0b1100110 //encoding number 4 binary
	beq next
	
	cmp r2, #5
	moveq r5, #0b1101101 //encoding number 5 binary
	beq next
	
	cmp r2, #6
	moveq r5, #0b1111101 //encoding number 6 binary
	beq next
	
	cmp r2, #7
	moveq r5, #0b0000111 //encoding number 7 binary
	beq next
	
	cmp r2, #8
	moveq r5, #0b1111111 //encoding number 8 binary
	beq next
	
	cmp r2, #9
	moveq r5, #0b1100111 //encoding number 9 binary
	beq next
	
	cmp r2, #10
	moveq r5, #0b1110111 //encoding number A binary
	beq next
	
	cmp r2, #11
	moveq r5, #0b1111100 //encoding number B binary
	beq next
	
	cmp r2, #12
	moveq r5, #0b0111001 //encoding number C binary
	beq next
	
	cmp r2, #13
	moveq r5, #0b1011110 //encoding number D binary
	beq next
	
	cmp r2, #14
	moveq r5, #0b1111001 //encoding number E binary
	beq next
	
	cmp r2, #15
	moveq r5, #0b1110001 //encoding number F binary
	beq next
	
next:
	strb r5, [r1] //write number
	pop {r5}
	bx lr
	
	
HEX_flood_ASM:
	push {r5}
	ldr r1, =0xFF200020
	ldr r5, floodzeros
	str r5, [r1]
	ldr r1, =0xFF200030
	str r5, [r1]
	pop {r5}
	bx lr