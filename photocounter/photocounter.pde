#include "stdlib.h"
#include "math.h"
#include "wiring.h"
#include "WProgram.h"
#include "Wire.h"

#include <Timer.h>

const int PHOTOPIN = 0;

const int LEDPIN = 13;

volatile int state = LOW;
volatile int counter = 0;

Timer dumpTimer;
const int DUMPRATE = 1000;


void setup(){
  Serial.begin(9600);
  Serial.println("setup");

  pinMode(PHOTOPIN, INPUT);

  digitalWrite(LEDPIN, LOW);
  
  attachInterrupt(PHOTOPIN, blink, FALLING);
  
  newTimer(&dumpTimer, DUMPRATE);

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
  }

  digitalWrite(LEDPIN, state);
}
