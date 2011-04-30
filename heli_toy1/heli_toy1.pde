#include "stdlib.h"
#include "math.h"
#include "wiring.h"
#include "WProgram.h"
#include "Wire.h"
#include <WireHelper.h>

#define DEBUG

#include "Smoothing.h"
#include "Timer.h"
#include <hHardware.h>
#include <ITG3200.h>

const int LEDPIN = 2;

Timer gyroTimer, dumpTimer, actionTimer;


/******************************************************************** setup() */
void setup(){
  hHWsetup();
  
  //delay(30000);

  Serial.begin(9600);
  //Serial.println("setup");

  pinMode(LEDPIN, OUTPUT);
  digitalWrite(LEDPIN, LOW);

  Wire.begin();
  initGyro();
  
  delay(1000);

  newTimer(&gyroTimer, 50);
  
  newTimer(&dumpTimer, 500);
  disableTimer(&dumpTimer);
  
  newTimer(&actionTimer, 5000);
  disableTimer(&actionTimer);
}

//gyro
int xOffset, yOffset, zOffset = 0;
long gyroX = 0, gyroY = 0, gyroZ = 0;


int i=0;
boolean readlnmode = false;
//String s = "";

/******************************************************************** loop() */
void loop(){
  if (Serial.available() > 0) {
    char c = Serial.read();
    
    if((c+1 > 'A') && (c-1 < 'Z')){      
      readlnmode = true;
    }
    if(readlnmode){
      //s = s + c;
      if(c == 0x0A){
        readlnmode = false;
      }
    }else{
      if(( (c+1 > 'a') && (c-1 < 'z') ) || (c==' ')){
        Serial.print("cmd: ");
        Serial.print(c);
        Serial.print(" ");
        Serial.println(c, HEX);
        //Serial.print("BTM182:");
        //Serial.println(s);


        switch(c){
          case ' ':
            Shutdown();
          break;
          case 'p':
            ToggleDump();
          break;
          case 'h':
            PrintHelp();
          break;
          case 'g':
            Go();
          break;
          case 'b':
            for(int i=0; i<10;i++){
              IncMotors();
            }
          break;
          case 'm':
            for(int i=0; i<10;i++){
              DecMotors();
            }
          break;
          
        }
      }
    }
    /*
    switch(c){
      case ' ':
        Shutdown();
      break;
      case 'p':
        ToggleDump();
      break;
      case 'h':
        PrintHelp();
      break;
      case 'g':
        Go();
      break;
      case 'b':
        IncMotors();
      break;
      case 'm':
        DecMotors();
      break;
      
    }
    */
  }
  
  //check gyroZ every 5 seconds
  //if != 180 then spin left
  
  if( checkTimer(&gyroTimer) ){
    int x = 0, y = 0, z = 0;
    if( getGyroscopeData(&x, &y, &z) ){
      accumulateRotations(x, &gyroX, &xOffset);
      accumulateRotations(y, &gyroY, &yOffset);
      accumulateRotations(z, &gyroZ, &zOffset);
    }
  }  
  
  if( checkTimer(&dumpTimer) ){
    
    Serial.print("gX:");
    Serial.print(gyroRotationsToDeg(&gyroX));
    Serial.print(" ");
    Serial.print("gY:");
    Serial.print(gyroRotationsToDeg(&gyroY));
    Serial.print(" ");
    Serial.print("gZ:");
    Serial.print(gyroRotationsToDeg(&gyroZ));
    Serial.print(" ");

    Serial.print("M1:");
    Serial.print(M1Speed);
    Serial.print(" ");
    Serial.print("M2:");
    Serial.print(M2Speed);
    Serial.print(" ");

    Serial.println();
  }  
  
  if( checkTimer(&actionTimer) ){
    double gyroZdeg = gyroRotationsToDeg(&gyroZ);
    if(!(( gyroZdeg > (180-10) ) && ( gyroZdeg < (180+10) ))){
      Serial.println("SpinLeft!!!!");
    }
  }
} //loop()

void PrintHelp(){
  Serial.println(" h       : help");
  Serial.println(" <SPACE> : shutdown");
  Serial.println(" p       : toggle dump");
  Serial.println(" g       : go");
  Serial.println(" b       : inc motors");
  Serial.println(" m       : dec motors");
}

void Shutdown(){
  Serial.println("SHUTDOWN");
  StopMotors();
  disableTimer(&actionTimer);
}

void ToggleDump(){
  if(isTimerDisabled(&dumpTimer)){
    enableTimer(&dumpTimer);
  }else{
    disableTimer(&dumpTimer);
  }
}

void Go(){
  enableTimer(&actionTimer);
}
