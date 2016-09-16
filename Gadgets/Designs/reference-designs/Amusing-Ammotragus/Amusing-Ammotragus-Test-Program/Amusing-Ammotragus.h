#ifndef AMUSING-AMMOTRAGUS_H
#define AMUSING-AMMOTRAGUS_H

#include "Motor.h"
#include "breakoutpins.h"
#include "ServoMotor.h"
#include "Pincer.h"


#define DRIVE_STBY 8        
#define DRIVE_PWMA 9        
#define DRIVE_AIN1 11        
#define DRIVE_AIN2 12        
#define DRIVE_PWMB 10        
#define DRIVE_BIN1 13        
#define DRIVE_BIN2 A0        
Motor drive(DRIVE_STBY,DRIVE_PWMA,DRIVE_AIN1,DRIVE_AIN2,DRIVE_PWMB,DRIVE_BIN1,DRIVE_BIN2);

#define PINCER_DATA 3        
Pincer pincer(PINCER_DATA);

#define SERVO_DATA 4        
ServoMotor Servo(SERVO_DATA);

#define PWM_PIN1 10        
OnePWMPin pwm(PWM_PIN1);

#define SERVO_2_DATA 5        
ServoMotor Servo_2(SERVO_2_DATA);

#define PINCER_2_DATA 6        
Pincer pincer_2(PINCER_2_DATA);


#endif