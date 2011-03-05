#include "stdlib.h"
#include "math.h"
#include "wiring.h"
#include "WProgram.h"
#include "Wire.h"

#include <Timer.h>
#include <Smoothing.h>

//status LED
const int LEDPIN = 13;

Timer gyroTimer;
Timer dumpTimer;
Timer accelTimer;

void setup(){
  Serial.begin(9600);
  Serial.println("setup");

  pinMode(LEDPIN, OUTPUT);
  digitalWrite(LEDPIN, LOW);

  Wire.begin();
  initGyro();
  
  delay(1000);


  //BMA180  
  initBMA180();
  delay(2000);
  newTimer(&accelTimer, 1000);
  
  newTimer(&dumpTimer, 500);
}

long X = 0, Y = 0, Z = 0;
int xOffset, yOffset, zOffset = 0;

int accelX, accelY, accelZ = 0;

void loop(){
  int x = 0, y = 0, z = 0;
  getGyroscopeData(&x, &y, &z);
/*
  if(x!=0){
    Serial.print("X: ");
    Serial.println( gyroDataToDegrees(x, &X, &xOffset) );
  }
  if(y!=0){
    Serial.print("Y: ");
    Serial.println( gyroDataToDegrees(y, &Y, &yOffset) );
  }
  if(z!=0){
    Serial.print("Z: ");
    Serial.println( gyroDataToDegrees(z, &Z, &zOffset) );
  }
*/
  
  
  if( checkTimer(&accelTimer) ){
    accelX = readAccel(0x03, 0x02);
    accelY = readAccel(0x05, 0x04);
    accelZ = readAccel(0x07, 0x06);
  }

  if( checkTimer(&dumpTimer) ){
    
    Serial.print("accelX: ");
    Serial.print(accelX*0.25);
    Serial.print(" ");
    Serial.print("accelY: ");
    Serial.print(accelY*0.25);
    Serial.print(" ");
    Serial.print("accelZ: ");
    Serial.print(accelZ*0.25);
    Serial.print(" ");

    Serial.println();
  }
}

/* LED */
void flipLed(int ledPin){
  if( digitalRead(ledPin) == LOW ){
    digitalWrite(ledPin, HIGH); 
  }else{
    digitalWrite(ledPin, LOW);     
  }
}


