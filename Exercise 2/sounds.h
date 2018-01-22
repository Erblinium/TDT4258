#ifndef _SOUNDS_H
#define _SOUNDS_H

#include <stdint.h>
#include <stdbool.h>
//Sound struct containing a data array and the lenght of mentioned array. 
typedef struct Sound {
	uint16_t length;
	uint8_t samples[];
} Sound;

extern Sound laser;
extern Sound coin;
extern Sound skrra;
extern Sound uni;
extern Sound win;

extern Sound* currentSound;
extern void pickSound(Sound*);

#endif
