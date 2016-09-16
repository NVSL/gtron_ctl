#ifndef SCORCHING-SPEOTHOS_H
#define SCORCHING-SPEOTHOS_H

#include "DistanceSensor.h"
#include "LEDArray.h"
#include "LED.h"
#include "Motor.h"
#include "MomentaryButton.h"


LEDArray display;

#define DRIVE_STBY 4        
#define DRIVE_PWMA 3        
#define DRIVE_AIN1 6        
#define DRIVE_AIN2 8        
#define DRIVE_PWMB 5        
#define DRIVE_BIN1 9        
#define DRIVE_BIN2 10        
Motor drive(DRIVE_STBY,DRIVE_PWMA,DRIVE_AIN1,DRIVE_AIN2,DRIVE_PWMB,DRIVE_BIN1,DRIVE_BIN2);

#define DISTANCESENSOR_A A0        
DistanceSensor distanceSensor(DISTANCESENSOR_A);

#define LED_CONTROL 11        
LED led(LED_CONTROL);

#define BUMP_SENSE 12        
MomentaryButton bump(BUMP_SENSE);

#define BUMP_2_SENSE 13        
MomentaryButton bump_2(BUMP_2_SENSE);


#endif