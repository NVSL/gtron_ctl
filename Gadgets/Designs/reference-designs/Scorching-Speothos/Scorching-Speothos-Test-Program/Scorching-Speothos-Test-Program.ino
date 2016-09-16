#include "GadgetManager.h"
#include "Adafruit_LEDBackpack.h"
#include "Adafruit_GFX.h"
#include "Wire.h"
#include "Scorching-Speothos.h"

void setup()
{
  Serial.begin(9600);
  display.setup();
  drive.setup();
  distanceSensor.setup();
  led.setup();
  bump.setup();
  bump_2.setup();
  
}

void loop()
{
  Serial.println("Testing display...");
  
  	display.clear();
  	display.drawCircle(3,3, 3);
        Serial.println("Testing drive...");
  
  drive.spinLeft();
  delay(1000);
  drive.spinRight();
  delay(1000);
        Serial.println("Testing distanceSensor...");
  
  
  	 for (int c = 0; c < 5000; c++) {
  	 char str[50];
  	 sprintf(str, "distanceSensor: distance= %d", distanceSensor.get_distance());
  	 Serial.println(str);
  	 delay(1);
  	}
        Serial.println("Testing led...");
  
  led.turnOn();
  delay(1000);
  led.turnOff();
  delay(1000);
          Serial.println("Testing bump...");
  
  
  	for (int c = 0; c < 5000; c++) {
  	     char str[50];
  	     sprintf(str, "bump: pressed = %s", bump.isPressed() ? "yes" : "no");
  	     Serial.println(str);
  	     delay(1);
  	}
        Serial.println("Testing bump_2...");
  
  
  	for (int c = 0; c < 5000; c++) {
  	     char str[50];
  	     sprintf(str, "bump_2: pressed = %s", bump_2.isPressed() ? "yes" : "no");
  	     Serial.println(str);
  	     delay(1);
  	}
        
}