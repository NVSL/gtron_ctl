
#include "MomentaryButton.h"
#include "Wire.h"
#include "Creaky-Capreolus.h"

void setup()
{
  Serial.begin(9600);
  display.setup();
  knob.setup();
  buzzer.setup();
  led_2.setup();
  button.setup();
  button_2.setup();
  analog.setup();
  digital.setup();

}

void loop()
{
  Serial.println("Testing display...");
  
  	display.print(0xBEEF, HEX);
  	display.writeDisplay();
        Serial.println("Testing knob...");
    
  
  	 for (int c = 0; c < 10000; c++) {
  	     knob.update();
  	     char str[50];
  	     sprintf(str, "knob: value = %d; pressed = %s", knob.getCurrentPos(), knob.isPressed() ? "yes" : "no");
  	     Serial.println(str);
         Serial.println(digitalRead(KNOB_A));
         Serial.println(digitalRead(KNOB_B));
         Serial.println(digitalRead(KNOB_SENSE));
  	     delay(1);
  	}
        Serial.println("Testing buzzer...");
  
  	buzzer.playNote(NOTE_A4,300);
  	delay(300);
  	buzzer.playNote(NOTE_B4,300);
  	delay(300);
  	buzzer.playNote(NOTE_C4,300);
  	delay(300);
        Serial.println("Testing led_2...");
  for (int i = 0; i < 1; i++) {
  led_2.set(0, 0, 0);
  delay(1000);
  led_2.set(255, 0, 0);
  delay(1000);
  led_2.set(255, 255, 0);
  delay(1000);
  led_2.set(255, 255, 255);
  delay(1000);
  led_2.set(0, 0, 0);
  delay(1000);
  }
          Serial.println("Testing button...");
  
  
  	for (int c = 0; c < 500; c++) {
  	     char str[50];
  	     sprintf(str, "button: pressed = %s", button.isPressed() ? "yes" : "no");
  	     Serial.println(str);
  	     delay(1);
  	}
        Serial.println("Testing button_2...");
  
  
  	for (int c = 0; c < 500; c++) {
  	     char str[50];
  	     sprintf(str, "button_2: pressed = %s", button_2.isPressed() ? "yes" : "no");
  	     Serial.println(str);
  	     delay(1);
  	}
        Serial.println("Testing analog...");
  
  
  	 for (int c = 0; c < 1000; c++) {
  	 char str[50];
  	 sprintf(str, "analog: %d", analog.read());
  	 Serial.println(str);
  	    delay(1);
  	    }
  	  Serial.println("Testing digital...");
  
  	    
  
  	    for (int c = 0; c < 2; c++) {
  	    Serial.println("digital: turn on");
  	    digital.write(1);
  	    delay(1000);
  	    Serial.println("digital: turn off");
  	    digital.write(0);
  	    delay(1000);
  	    }
  	  
}
