#ifndef _FUNCTIONS_H
#define _FUNCTIONS_H

void setupTimer(void);
void disableTimerIRQ(void);
void startTimer(void);
void stopTimer(void);
void setupNVIC(void);

void setupDAC(void);
void disableDAC(void);
void setupGPIO(void);
void Button_handler(void);


#endif
