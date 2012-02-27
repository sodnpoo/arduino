#include "stdlib.h"
#include "math.h"
#include "wiring.h"
#include "WProgram.h"
#include "Wire.h"

#include <TimerMicros.h>
#include <Timer.h>

const int IRPIN = 7;

/* servo control without using a timer */

const int SERVOPIN1 = 7;
const int SERVOPIN2 = 8;

/*
The start timer kicks off the pulse once every 20ms 
 */
TimerUs startTimer;
const int SERVOSTARTRATE = 20000; //20ms

/*
The stop timer stops the variable length pulse
 */
TimerUs stopTimer1;
TimerUs stopTimer2;
//const int SERVOSTOPRATE1 = 1500; //90 degrees ?
/*
lower = right
 higher = left
 min = 500
 max = 2200
 center = 1400
 */
const int SERVO1MIN = 1100;
const int SERVO1MAX = 1600;
int servo1pulse = 1400;

//const int SERVOSTOPRATE2 = 1500; //
/*
lower = back
 higher = forward
 min = 800
 max = 1900
 center = 1400
 */
const int SERVO2MIN = 1400;
const int SERVO2MAX = 1900;
int servo2pulse = 1500;

Timer scanTimer;
const int SCANRATE = 150;
const int SCANSTEP = 20;

const byte SD_FWD = 0;
const byte SD_REV = 1;
byte hScanDir = SD_FWD;
byte vScanDir = SD_FWD;

const int MAXHSTEPS = 28;
int hSteps[MAXHSTEPS] = {
  1600,
  1580,
  1560,
  1540,
  1520,
  1500,
  1480,
  1460,
  1440,
  1420,
  1400,
  1380,
  1360,
  1340,
  1320,
  1300,
  1280,
  1260,
  1240,
  1220,
  1200,
  1180,
  1160,
  1140,
  1120,
  1100,
  1080,
  1060
};
/*
const byte MAXVSTEPS = 27;
int vSteps[MAXVSTEPS] = {
  1380,
  1400,
  1420,
  1440,
  1460,
  1480,
  1500,
  1520,
  1540,
  1560,
  1580,
  1600,
  1620,
  1640,
  1660,
  1680,
  1700,
  1720,
  1740,
  1760,
  1780,
  1800,
  1820,
  1840,
  1860,
  1880,
  1900  
};
*/
const int MAXVSTEPS = 3;
int vSteps[MAXVSTEPS] = {
  1605,
  1630,
  1655,/*
  1680,
  1705,
  1730,
  1755,
  1780,
  1805,
  1830,
  1855,
  1880 */
};

//byte image[MAXHSTEPS];
byte image[MAXHSTEPS][MAXVSTEPS];

void setup() {
  Serial.begin(9600);
  Serial.println("setup");
  
  pinMode(SERVOPIN1, OUTPUT);
  digitalWrite(SERVOPIN1, LOW);
  pinMode(SERVOPIN2, OUTPUT);
  digitalWrite(SERVOPIN2, LOW);

  for(int i=0;i<MAXHSTEPS;i++){
    for(int j=0;j<MAXVSTEPS;j++){
      image[i][j] = 0;
    }
  }

  newTimerUs(&startTimer, SERVOSTARTRATE);
  newTimerUs(&stopTimer1, servo1pulse);
  newTimerUs(&stopTimer2, servo2pulse);

  newTimer(&scanTimer, SCANRATE);
  
}

int hStep = 0;
int vStep = 0;

void loop() {
  if(checkTimerUs(&stopTimer1)){
    //set the pin low and start the stop timer    
    digitalWrite(SERVOPIN1, LOW);
    disableTimerUs(&stopTimer1);
  }
  if(checkTimerUs(&stopTimer2)){
    //set the pin low and start the stop timer    
    digitalWrite(SERVOPIN2, LOW);
    disableTimerUs(&stopTimer2);
  }

  if( checkTimerUs(&startTimer) ){
    //set the pin high and start the stop timer
    digitalWrite(SERVOPIN1, HIGH);
    digitalWrite(SERVOPIN2, HIGH);

    newTimerUs(&stopTimer1, servo1pulse);
    newTimerUs(&stopTimer2, servo2pulse);
  /*
  }
  
  if(checkTimer(&scanTimer)){
  */
    byte IRval = analogRead(IRPIN) >> 2;

    boolean nextVertLine = false;
    switch(hScanDir){
      
      case SD_FWD:        
        if(hStep > MAXHSTEPS-1){
          hScanDir = SD_REV;
          nextVertLine = true;
          hStep = MAXHSTEPS-1;
        }else{
          servo1pulse = hSteps[hStep];
          image[hStep][vStep+1] = IRval;
          hStep++;
        }        
      break;
      
      case SD_REV:
        if(hStep < 0){
          hScanDir = SD_FWD;
          nextVertLine = true;
          hStep = 0;
        }else{
          servo1pulse = hSteps[hStep];
          image[hStep][vStep+1] = IRval;
          hStep--;
        }        
      break;      
    }

    if(nextVertLine){
      boolean endOfFrame = false;

Serial.println(vStep);
Serial.println(vScanDir, DEC);

      switch(vScanDir){

        case SD_FWD:
          if(vStep > MAXVSTEPS-1){
            vScanDir = SD_REV;
            endOfFrame = true;
            vStep = MAXVSTEPS-1;
          }else{
            servo2pulse = vSteps[vStep];
            vStep++;
          }        
        break;
        case SD_REV:
          
          if(vStep < 0){
            vScanDir = SD_FWD;
            endOfFrame = true;
            vStep = 0;
          }else{
            servo2pulse = vSteps[vStep];
            vStep--;
          }        
        break;      
/*
        case SD_REV:
          servo2pulse -= SCANSTEP;
          if(servo2pulse < SERVO2MIN - SCANSTEP){
            vScanDir = SD_FWD;
            endOfFrame = true;
          }
        break;        
*/
      }

    
      if(endOfFrame){
        Serial.println("===========================");
        for(int j=0;j<MAXVSTEPS;j++){
    
          String tmpLine = String("");
          for(int i=0;i<MAXHSTEPS;i++){
            tmpLine += String(image[i][j], DEC);
            tmpLine += " ";
          }
          Serial.println(tmpLine);
    
        }
      }
    }

    
  }  
}


