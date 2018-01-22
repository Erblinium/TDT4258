#include <stdint.h>

#include "efm32gg.h"
#include "functions.h"
#include "sounds.h"
#include <stdbool.h>


uint16_t idx= 0;
bool playing = false;
int current_button = -1;
/*
 * TIMER1 interrupt handler 
 */
void __attribute__ ((interrupt)) TIMER1_IRQHandler()
{
	/*
	 * TODO feed new samples to the DAC remember to clear the pending
	 * interrupt by writing 1 to TIMER1_IFC 
	 */
	*TIMER1_IFC = 1;
	playing = true;
	if(idx <= currentSound->length)
	{
		*DAC0_CH0DATA = currentSound->samples[idx]<<4;	/* Shift 4 bits left to the msb of the 12 bit data registers */
		*DAC0_CH1DATA = currentSound->samples[idx]<<4;
		idx++;											/* Increment sample */
	}
	else/*Sound is finished, go to sleep */
	{
		stopTimer();
		disableTimerIRQ();
		disableDAC();
		idx = 0;
		playing = false;
		*GPIO_PA_DOUT     = ~0;							/* Set button to light LED */
		*SCR = 0b110;
	}
}

/*
 * GPIO even pin interrupt handler 
 */
void __attribute__ ((interrupt)) GPIO_EVEN_IRQHandler()
{
	/*
	 * TODO handle button pressed event, remember to clear pending
	 * interrupt 
	 */
	Button_handler();
}

/*
 * GPIO odd pin interrupt handler 
 */
void __attribute__ ((interrupt)) GPIO_ODD_IRQHandler()
{
	/*
	 * TODO handle button pressed event, remember to clear pending
	 * interrupt 
	 */
	Button_handler();
}


void Button_handler()
{	
	*GPIO_IFC 	  = 0xFF;			/* Clear all interrupts */
	*GPIO_PA_DOUT     = (*GPIO_PC_DIN << 8);	/* Set button to light LED */
	if(!playing)
	{
	    	int input = ~(*GPIO_PC_DIN);
	    	for (int i=0; i < 8; i++) {  /*Itterating trough the buttons, easily scalable should there be additional buttons*/
			if ((1 << i) == (input & (1 << i))) 
			{
		    	current_button = i;
		   	break;
			}
	    	}	
		switch(current_button) //Swich case for button pressed
		{
			case 0:
			case 4:
				pickSound(&laser);
			break;
			case 1:
			case 5:
				pickSound(&coin);
			break;
			case 2:
			case 6:
				pickSound(&skrra);
			break;
			case 3:
			case 7:
				pickSound(&win);
			break;
			default:
				current_button=-1;
			break;
		
		}
	}
	

}

