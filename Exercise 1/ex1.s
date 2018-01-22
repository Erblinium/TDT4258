.syntax unified
	
.include "efm32gg.s"

	/////////////////////////////////////////////////////////////////////////////
	//
  	// Exception vector table
  	// This table contains addresses for all exception handlers
	//
	/////////////////////////////////////////////////////////////////////////////
	
.section .vectors
	
	      .long   stack_top               /* Top of Stack                 */
	      .long   _reset                  /* Reset Handler                */
	      .long   dummy_handler           /* NMI Handler                  */
	      .long   dummy_handler           /* Hard Fault Handler           */
	      .long   dummy_handler           /* MPU Fault Handler            */
	      .long   dummy_handler           /* Bus Fault Handler            */
	      .long   dummy_handler           /* Usage Fault Handler          */
	      .long   dummy_handler           /* Reserved                     */
	      .long   dummy_handler           /* Reserved                     */
	      .long   dummy_handler           /* Reserved                     */
	      .long   dummy_handler           /* Reserved                     */
	      .long   dummy_handler           /* SVCall Handler               */
	      .long   dummy_handler           /* Debug Monitor Handler        */
	      .long   dummy_handler           /* Reserved                     */
	      .long   dummy_handler           /* PendSV Handler               */
	      .long   dummy_handler           /* SysTick Handler              */

	      /* External Interrupts */
	      .long   dummy_handler
	      .long   gpio_handler            /* GPIO even handler */
	      .long   dummy_handler
	      .long   dummy_handler
	      .long   dummy_handler
	      .long   dummy_handler
	      .long   dummy_handler
	      .long   dummy_handler
	      .long   dummy_handler
	      .long   dummy_handler
	      .long   dummy_handler
	      .long   gpio_handler            /* GPIO odd handler */
	      .long   dummy_handler
	      .long   dummy_handler
	      .long   dummy_handler
	      .long   dummy_handler
	      .long   dummy_handler
	      .long   dummy_handler
	      .long   dummy_handler
	      .long   dummy_handler
	      .long   dummy_handler
	      .long   dummy_handler
	      .long   dummy_handler
	      .long   dummy_handler
	      .long   dummy_handler
	      .long   dummy_handler
	      .long   dummy_handler
	      .long   dummy_handler
	      .long   dummy_handler
	      .long   dummy_handler
	      .long   dummy_handler
	      .long   dummy_handler
	      .long   dummy_handler
	      .long   dummy_handler
	      .long   dummy_handler
	      .long   dummy_handler
	      .long   dummy_handler
	      .long   dummy_handler
	      .long   dummy_handler

.section .text

	/////////////////////////////////////////////////////////////////////////////
	//
	// Reset handler
  	// The CPU will start executing here after a reset
	//
	/////////////////////////////////////////////////////////////////////////////

.globl  _reset
.type   _reset, %function
.thumb_func
_reset: 
	//Setup and activate GPIO clock in CMU
	ldr R0, =CMU_BASE
	ldr R1, [R0, #CMU_HFPERCLKEN0]    			// base address of cmu + offset to access register

	mov R2, #1 		          					// r2 = 0b1
	lsl R2, R2, #CMU_HFPERCLKEN0_GPIO 			// r2 << 13, left shift 13 times --> a
	orr R2, R1, R2 			  					// logicaly OR CMU register r1 with bit mask r2
	str R2, [R0, #CMU_HFPERCLKEN0]    			// store value of R2 into an address equal to cmu reg

	
	//Setup GPIO base addresses
	ldr R0, =GPIO_PA_BASE						// Register R0 and R1 are reserved and will be later used to access button states and drive LED's
	ldr R1, =GPIO_PC_BASE

	//Set drive-strength to high for GPIO's
	mov R2, #0x2 //20mA 
	str R2, [R0, #GPIO_CTRL]

	//set pins 8-15 on port A as outputs
	ldr R2, =0x55555555
	str R2, [R0, #GPIO_MODEH]
	
	//Turn off LED's
	mov R2, #0xFF00
	str R2, [R0, #GPIO_DOUT]

	//Set pins 0-7 to input for port C
	ldr R2, =0X33333333
	str R2, [R1, #GPIO_MODEL]

	//Enable internal pull-up for push buttons -->active low
	mov R2, #0xFF
	str R2, [R1, #GPIO_DOUT]

	//Enable external interrupts on PORT C
	ldr R2, =GPIO_BASE
	ldr R3, =0x22222222 					 	// Pins 0-7 enabled interrupt			
	str R3, [R2, #GPIO_EXTIPSELL]
	
	//Set interrupt on 1 to 0 transitions (High-to-Low)
	mov R3, #0xFF
	str R3, [R2, #GPIO_EXTIFALL]				//Interrupts on rising and falling edge on GPIOs
	str R3, [R2, #GPIO_EXTIRISE]		
	str R3, [R2, #GPIO_IEN]					    //Enable interrupt generation
	
	//Enable interrupt handling
	ldr R3, =ISER0
	ldr R4, [R3]
	movw R5, #0x802						        // movw allows us to load a 16 bit number to the lower 16 bits of a 32 bit register.									
	orr R5, R5, R4						
	str R5, [R3]
	
	//Enable deep sleep mode
	mov R3, #6 
	ldr R4, =SCR 
	str R3, [R4]                               	//Store the value 0b110 at the memorylocation of R4 (System control register)
	

	// Stops executing instructions and enters sleep mode. 
	wfi //
	/////////////////////////////////////////////////////////////////////////////
	//
  	// GPIO handler
  	// The CPU will jump here when there is a GPIO interrupt
	//
	/////////////////////////////////////////////////////////////////////////////
	
.thumb_func
gpio_handler:

	ldr R2, =GPIO_BASE  
	ldr R4, [R2, #GPIO_IF]	
	str R4, [R2, #GPIO_IFC]


	ldr R2, [R1, #GPIO_DIN]
	lsl R2, R2, #8            					//Shift R2 because GPIO_DIN is bits 0-7, while PA base pins are 8-15
	str R2, [R0, #GPIO_DOUT]
	bx LR                     					// Return from routine, jump to address LR


	
	/////////////////////////////////////////////////////////////////////////////
	
        .thumb_func
dummy_handler:  
        b .  // do nothing


