#include "stdlib.h"
#include "math.h"
#include "wiring.h"
#include "WProgram.h"
#include "Wire.h"

#include <Timer.h>

Timer IRblinkTimer;
const int IRBLINKRATE = 5000;
const int IRPIN = 3;

Timer photoReadTimer;
const int PHOTOREADRATE = 200;
//const int PHOTOPIN = 1;
const int PHOTOPIN = 22;

const int LEDPIN = 13;

void setup(){
  Serial.begin(9600);
  Serial.println("setup");

  newTimer(&IRblinkTimer, IRBLINKRATE);
  pinMode(IRPIN, OUTPUT);
//  digitalWrite(IRPIN, LOW);
  digitalWrite(IRPIN, HIGH);

  newTimer(&photoReadTimer, PHOTOREADRATE);
  pinMode(PHOTOPIN, INPUT);

  digitalWrite(LEDPIN, LOW);
}

void loop(){
  /*
  if( checkTimer(&IRblinkTimer) ){
    //flip
    if( digitalRead(IRPIN) ){
      Serial.println("IR LOW");
      digitalWrite(IRPIN, LOW);
    }else{
      Serial.println("IR HIGH");
      digitalWrite(IRPIN, HIGH);
    }
  }
  */

  if( checkTimer(&photoReadTimer) ){
    //int photoVal = analogRead(PHOTOPIN);
    int photoVal = digitalRead(PHOTOPIN);
    Serial.print("photo:");
    Serial.println(photoVal);
    if( photoVal ){
      digitalWrite(LEDPIN, HIGH);
    }else{
      digitalWrite(LEDPIN, LOW);
    }
  }
}
