#include "GadgetManager.h"
#include "Servo.h"
#include "Amusing-Ammotragus.h"

void setup()
{
  Serial.begin(9600);
  drive.setup();
  pincer.setup();
  Servo.setup();
  pwm.setup();
  Servo_2.setup();
  pincer_2.setup();
  
}

void loop()
{
  Serial.println("Testing drive...");
  
  drive.spinLeft();
  delay(1000);
  drive.spinRight();
  delay(1000);
        Serial.println("Testing pincer...");
  
  
  	for(int i = 0; i < 5; i++) {
  	pincer.open();
  	delay(500);
  	pincer.close();
  	delay(500);
  	}
        Serial.println("Testing pwm...");
  
  	    
  
              for (int c = 0; c < 8; c += 256/8) {
  	    char str[50];
  	    sprintf(str, "pwm: writing %d", c);
  	    Serial.println(str);
  	    pwm.write(c);
  	    delay(1000);
  	    }
  	  Serial.println("Testing pincer_2...");
  
  
  	for(int i = 0; i < 5; i++) {
  	pincer_2.open();
  	delay(500);
  	pincer_2.close();
  	delay(500);
  	}
        
}