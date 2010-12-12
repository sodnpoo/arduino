#include "stdlib.h"
#include "math.h"
#include "wiring.h"
#include "WProgram.h"
#include "Wire.h"

#include <Timer.h>

//status LED
const int LEDPIN = 13;

//rotorary encoder photocell - wind speed
const int PHOTOPIN = 0;
volatile int state = LOW;
volatile int counter = 0;

//LM335Z - temperature
const int LM335PIN = 0;
int LM335toDegreesC(int raw, int fudge){
  return (((raw * 500L) / 1023L) - 273L) + fudge; // Algorithm to convert the LM335 output signal from the ADC to degrees C.
} 

//dump data timer
Timer dumpTimer;
const int DUMPRATE = 1000;

void setup(){
  Serial.begin(9600);
  Serial.println("setup");

  digitalWrite(LEDPIN, LOW);

  pinMode(PHOTOPIN, INPUT);
  attachInterrupt(PHOTOPIN, blink, FALLING);
  
  newTimer(&dumpTimer, DUMPRATE);
  
  delay(1000);
}

void blink()
{
  state = !state;
  counter++;
}

void loop(){
  if( checkTimer(&dumpTimer) ){
    Serial.print("counter:");
    Serial.println(counter);
    
    int speed = counter;
    counter = 0;
    
    int degreesC = LM335toDegreesC(analogRead(LM335PIN), -4);

    Serial.print("degreesC:");
    Serial.println(degreesC);
    
  }

  digitalWrite(LEDPIN, state);
}
