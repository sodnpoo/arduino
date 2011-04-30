#include "stdlib.h"
#include "math.h"
#include "wiring.h"
#include "WProgram.h"
#include "Wire.h"

#include <Timer.h>
#include <Smoothing.h>

#include <WireHelper.h>

#include <BMA180.h>
#include <ITG3200.h>

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

  newTimer(&gyroTimer, 50);
  
  newTimer(&dumpTimer, 500);
}

//raw gyro data
long rawGyroX = 0, rawGyroY = 0, rawGyroZ = 0;
//auto calculated offsets
int xOffset, yOffset, zOffset = 0;

long gyroX = 0, gyroY = 0, gyroZ = 0;


int rawAccelX, rawAccelY, rawAccelZ = 0;

void loop(){

  if( checkTimer(&gyroTimer) ){
    int x = 0, y = 0, z = 0;
    getGyroscopeData(&x, &y, &z);
  
    gyroX = accumulateRotations(x, &rawGyroX, &xOffset);
    gyroY = accumulateRotations(y, &rawGyroY, &yOffset);
    gyroZ = accumulateRotations(z, &rawGyroZ, &zOffset);
  }  
  
  if( checkTimer(&accelTimer) ){
    rawAccelX = readXAccel();
    rawAccelY = readYAccel();
    rawAccelZ = readZAccel();
  }

  if( checkTimer(&dumpTimer) ){
    
    Serial.print("gyroX: ");
    Serial.print(gyroRotationsToDeg(&gyroX));
    Serial.print(" ");
    Serial.print("gyroY: ");
    Serial.print(gyroRotationsToDeg(&gyroY));
    Serial.print(" ");
    Serial.print("gyroZ: ");
    Serial.print(gyroRotationsToDeg(&gyroZ));
    Serial.print(" ");

    Serial.println();
  
    
    Serial.print("accelX: ");
    Serial.print(rawAccelX*0.25);
    Serial.print(" ");
    Serial.print("accelY: ");
    Serial.print(rawAccelY*0.25);
    Serial.print(" ");
    Serial.print("accelZ: ");
    Serial.print(rawAccelZ*0.25);
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


