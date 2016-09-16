#ifndef CREAKY-CAPREOLUS_H
#define CREAKY-CAPREOLUS_H

#include "Adafruit_LEDBackpack.h"
#include "MomentaryButton.h"
#include "Adafruit_GFX.h"
#include "breakoutpins.h"
#include "Buzzer.h"
#include "RotaryEncoder.h"
#include "RGBLED.h"


Adafruit_7segment display;

#define KNOB_A 8        
#define KNOB_B 10        
#define KNOB_SENSE 4        
RotaryEncoder knob(KNOB_SENSE,KNOB_B,KNOB_A);

#define BUZZER_1 3        
Buzzer buzzer(BUZZER_1);

#define LED_2_CONTROL_RED 5        
#define LED_2_CONTROL_GREEN 6        
#define LED_2_CONTROL_BLUE 9        
RGBLED led_2(LED_2_CONTROL_RED,LED_2_CONTROL_GREEN,LED_2_CONTROL_BLUE);

#define BUTTON_SENSE 11        
MomentaryButton button(BUTTON_SENSE);

#define BUTTON_2_SENSE 12        
MomentaryButton button_2(BUTTON_2_SENSE);

#define ANALOG_PIN1 A0        
OneADCPin analog(ANALOG_PIN1);

#define DIGITAL_PIN1 13        
OneDigitalPin digital(DIGITAL_PIN1);


#endif
