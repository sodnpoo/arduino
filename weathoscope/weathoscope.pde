#include "stdlib.h"
#include "math.h"
#include "wiring.h"
#include "WProgram.h"
#include "Wire.h"

#include <Smoothing.h>
#include <Timer.h>

//status LED
const int LEDPIN = 13;

//rotorary encoder photocell - wind speed
/* NOT USED
const int PHOTOPIN = 0;
volatile int state = LOW;
volatile int counter = 0;
*/

//LM335Z - temperature
const int LM335RATE = 1000; // 1 second
const int LM335PIN = 0;
Timer LM335Timer;
Smoothed LM335Smooth;
int LM335toDegreesC(int raw, int fudge){
  return (((raw * 500L) / 1023L) - 273L) + fudge; // Algorithm to convert the LM335 output signal from the ADC to degrees C.
} 

//dump data timer
Timer dumpTimer;
const int DUMPRATE = 60000; //60 seconds

void setup(){
  Serial.begin(9600);
  Serial.println("setup");

  digitalWrite(LEDPIN, LOW);

  /* NOT USED
  pinMode(PHOTOPIN, INPUT);
  attachInterrupt(PHOTOPIN, windSpeedISR, FALLING);
  */
  
  newSmoothed(&LM335Smooth, 10);
  newTimer(&LM335Timer, LM335RATE);

  newTimer(&dumpTimer, DUMPRATE);
  
  delay(1000);
}

void windSpeedISR()
{
  /*
  state = !state;
  counter++;
  */
}

boolean dumpHalfFreq = false;
int smoothedLM335 = 0;

void loop(){
  if( checkTimer(&LM335Timer) ){
    int rawLM335 = analogRead(LM335PIN);
    smoothedLM335 = smoothReading(&LM335Smooth, rawLM335);
  }
  
  if( checkTimer(&dumpTimer) ){
    digitalWrite(LEDPIN, HIGH);
    
    int degreesC = LM335toDegreesC(smoothedLM335, -4);
  
    Serial.print("degreesC:");
    Serial.print(degreesC);

    Serial.print('/'); // divider
      
    Serial.println();
    
    digitalWrite(LEDPIN, LOW);
  }
  
}
