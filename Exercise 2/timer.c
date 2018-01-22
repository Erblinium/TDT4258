#include <stdint.h>
#include <stdbool.h>

#include "efm32gg.h"

#define 	TIMER_PERIOD 1750

/*
 * function to setup the timer 
 */
void setupTimer()
{
	/*
	 * TODO enable and set up the timer
	 * 
	 * 1. Enable clock to timer by setting bit 6 in CMU_HFPERCLKEN0 2.
	 * Write the period to register TIMER1_TOP 3. Enable timer interrupt
	 * generation by writing 1 to TIMER1_IEN 4. Start the timer by writing 
	 * 1 to TIMER1_CMD
	 * 
	 * This will cause a timer interrupt to be generated every (period)
	 * cycles. Remember to configure the NVIC as well, otherwise the
	 * interrupt handler will not be invoked. 
	 */

	*CMU_HFPERCLKEN0 |= CMU2_HFPERCLKEN0_TIMER1;		 /*Enable clock to the timer module 1 */
	*TIMER1_TOP 	  = TIMER_PERIOD;		   	 /*Set no. of ticks between interrupts*/ 
	*TIMER1_IEN	  = 1;					 /*Enable interrupt generation from timer*/ 
	*TIMER1_CMD	  = 1;					 /*Start timer*/ 

}

void setupDMA()
{

	*CMU_HFPERCLKEN0  |= CMU2_HFPERCLKEN0_TIMER1;
	*CMU_HFPERCLKEN0  |= CMU2_HFPERCLKEN0_PRS;
	*CMU_HFCORECLKEN0 |= CMU_HFCORECLKEN0_DMA;
	*PRS_CH0_CTRL	   = 0x1D0001;   			 /* Set input src to TIMER1 and set timer overflow signal on PRS */
	*TIMER1_TOP 	   = TIMER_PERIOD;		   	 /* Set no. of ticks between interrupts */
	 

}
/*
* Function to start timer
*/
void startTimer()
{
	*TIMER1_CMD	  = 1;
	*TIMER1_TOP 	  = TIMER_PERIOD;
}
/*
* Function to stop timer
*/
void stopTimer()
{
	*TIMER1_CMD	  = 0;
}
/*
* Function to disable timer, and interrupt
*/
void disableTimerIRQ()
{
	*CMU_HFPERCLKEN0 &= ~CMU2_HFPERCLKEN0_TIMER1;
	*TIMER1_IEN	  = 0;
}
