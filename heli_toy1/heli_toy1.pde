
#include "stdlib.h"
#include "math.h"
#include "wiring.h"
#include "WProgram.h"
#include "Wire.h"
#include <WireHelper.h>

#define DEBUG

#include <Smoothing.h>
#include "Timer.h"
#include <hHardware.h>
#include <ITG3200.h>

Timer gyroTimer, dumpTimer, actionTimer, headingChgLimiter, ledTimer, pingTimer;

/******************************************************************** setup() */
void setup(){
  hHWsetup();
  
  //delay(30000);

  Serial.begin(9600);
  //Serial.println("setup");

  Wire.begin();
  initGyro();
  
  //wait for hardware to settle
  delay(3000);

  newTimer(&gyroTimer, 50);
  
  newTimer(&dumpTimer, 500);
  disableTimer(&dumpTimer);
  
  newTimer(&actionTimer, 50);
  disableTimer(&actionTimer);
  
  newTimer(&headingChgLimiter, 250);

  newTimer(&ledTimer, 250);

  newTimer(&pingTimer, 1000);
  
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
            Serial.println("SHUTDOWN");
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
          case 'q':
            rotorFwd();
          break;
          case 's':
            rotorRev();
          break;
          
          /*
          Every time we see a 'z' - reset the timer
          (if the timer expires then shut down!)
          */
          case 'z':
            enableTimer(&pingTimer);
          break;
          
        }
      }
    }

  }

  if( checkTimer(&pingTimer) ){
    Shutdown();
  }
  
  if( checkTimer(&ledTimer) ){
    flipLed();
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
    
    double heading = 0; //0..359.99
    
    //normalise
    gyroZdeg += 180 - heading;
    if(gyroZdeg > 360){
      gyroZdeg -= 360;
    }
    heading += 180 - heading;
    if(heading > 360){
      heading -= 360;
    }
    
    int resolution = 5; //cant be more than 180
    double maxHeading = heading + resolution;
    double minHeading = heading - resolution;
/*
    Serial.print("maxHeading:");
    Serial.println(maxHeading);
    Serial.print("minHeading:");
    Serial.println(minHeading);
    Serial.print("gyroZdeg:");
    Serial.println(gyroZdeg);
*/
    if( ( gyroZdeg > minHeading ) && ( gyroZdeg < maxHeading ) ){
      Serial.println("**on course**");
    }else{ //we're not on course - spin left or right?
      if( checkTimer(&headingChgLimiter) ){
        if( gyroZdeg > maxHeading ){
          if(M1Speed > MOTORMIN){
            M1Speed--;
            analogWrite(M1, M1Speed);
          }
          if(M2Speed < MOTORMAX){
            M2Speed++;
            analogWrite(M2, M2Speed);
          }
        }
        if( gyroZdeg < minHeading ){
          if(M1Speed < MOTORMAX){
            M1Speed++;
            analogWrite(M1, M1Speed);
          }
          if(M2Speed > MOTORMIN){
            M2Speed--;
            analogWrite(M2, M2Speed);
          }        
        }
      }
    }
    
    /*
    if( ( gyroZdeg > (180-10) ) && ( gyroZdeg < (180+10) ) ){
      Serial.println("**180***");
      Shutdown();
    }
    */
  }
} //loop()

void PrintHelp(){
  Serial.println(" h       : help");
  Serial.println(" <SPACE> : shutdown");
  Serial.println(" p       : toggle dump");
  Serial.println(" g       : go");
  Serial.println(" b       : inc motors");
  Serial.println(" m       : dec motors");
  Serial.println(" q       : tail fwd");
  Serial.println(" s       : tail rev");
}

void Shutdown(){
  //Serial.println("SHUTDOWN");
  StopMotors();
  rotorStop();
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
  Serial.println("!!!!Go!!!!");
  enableTimer(&actionTimer);
}
