#include "stdlib.h"
#include "math.h"
#include "wiring.h"
#include "WProgram.h"
#include "Wire.h"

#include <Timer.h>
#include <Smoothing.h>
#include <Servo.h> 
#include <SoftwareSerial.h>

/* Motors */
const int MOTORA1PIN = 3;
const int MOTORA2PIN = 5;
const int MOTORB1PIN = 6;
const int MOTORB2PIN = 9;
const int MAXSPEED = 255;

/* Scanner */
const int SCANIRPIN = 7;
const int SCANSERVOPIN = 8;
const int SCANMINANGLE = 50;
const int SCANMAXANGLE = 130;
const int SCANSTEPS = 10;
const int SCANSTEP = (SCANMAXANGLE - SCANMINANGLE) / SCANSTEPS;
const int SCANRATE = 50;
const byte SD_FWD = 0;
const byte SD_REV = 1;

struct tScanner {
  Servo servo;
  int pos;
  byte direction;
  Timer timer;
  int distances[SCANSTEPS+1];
  int distance;
  boolean hold;
};

void initScanner(struct tScanner *scanner){
  scanner->pos = SCANMINANGLE;
  scanner->direction = SD_FWD;  
  scanner->hold = false;
  scanner->servo.attach(SCANSERVOPIN);
  for(int i=0;i<SCANSTEPS;i++){
    scanner->distances[i] = 0;
  }
  scanner->distance = 0;
  newTimer(&scanner->timer, SCANRATE);
}

tScanner scanner;

//status LED
const int LEDPIN = 13;

Timer rotationTimer;
Smoothed Zsmooth;


void setup(){
  Serial.begin(9600);
  Serial.println("setup");
  
  pinMode(LEDPIN, OUTPUT);
  digitalWrite(LEDPIN, LOW);

  pinMode(MOTORA1PIN,OUTPUT);
  pinMode(MOTORA2PIN,OUTPUT);
  pinMode(MOTORB1PIN,OUTPUT);
  pinMode(MOTORB2PIN,OUTPUT);

  //initScanner(&scanner);
  
  Wire.begin();
  initGyro();
  
  delay(1000);

  newSmoothed(&Zsmooth, 10);
  
/* 
  Forward();
*/
  newTimer(&rotationTimer, 100);
}

Timer evadeTimer;
int i = 1;
//double X, Y, Z = 0;
int X, Y, Z = 0;
int zOffset = 0;

Timer motorStopTimer;


void loop(){
  if( checkTimer(&motorStopTimer) ){
    Motor_Stop();
    disableTimer(&motorStopTimer);
  }

  if( checkTimer(&rotationTimer) ){
//    double x, y, z;    
    int x, y, z;    
    getGyroscopeData(&x, &y, &z);      
    /*
    X += x;
    Y += y;*/
    if(zOffset==0){
      zOffset = z;
    }
    z -= zOffset;
    
    if((z > 10) || (z < -10)){
      Z += z;//smoothReading(&Zsmooth, z);
    }
    //Z = (Z / i) /10;
  
    double doubleZ = Z / 14.375;
    doubleZ = doubleZ / 10;
  
    Serial.println();
    Serial.print("!!!!!!!!!!");
    Serial.print(" Z: ");
    Serial.print(Z);

    Serial.println();
    Serial.println();
    Serial.print("!!!!!!!!!!");
    Serial.print(" dZ: ");
    Serial.print(doubleZ);

    Serial.println();
    Serial.println();
    
    int destAngle = -90;
    int motorPulse = 20;
    
    if( (doubleZ >= ( destAngle -0.5)) && (doubleZ <= ( destAngle +0.5)) ){
      Motor_Stop();
      Serial.println("!!!STOP!!!");      
      //disableTimer(&rotationTimer);
    }else{
      if( (doubleZ >= ( destAngle -45)) && (doubleZ <= ( destAngle +45)) ){
        motorPulse = 20;
      }
      if( (doubleZ >= ( destAngle -15)) && (doubleZ <= ( destAngle +15)) ){
        motorPulse = 7;
      }
      /*
      if( (doubleZ >= ( destAngle -5)) && (doubleZ <= ( destAngle +5)) ){
        motorPulse = 5;
      }
      */
      if( doubleZ < (destAngle) ) {
        Spin_Left();
        newTimer(&motorStopTimer, motorPulse);
      }
  
      if( doubleZ > (destAngle) ) {
        Spin_Right();
        newTimer(&motorStopTimer, motorPulse);
      }
      
    }
    
    if(i==50){
      Motor_Stop();
      Z=0;
      i=0;
      zOffset = 0;
      disableTimer(&rotationTimer);
      delay(5000);
      Serial.println("==============go================");
      delay(250);
      enableTimer(&rotationTimer);
    }

    i++;
  }
  /*
  double x, y, z;
  
  getGyroscopeData(&x, &y, &z);
  X += x;
  Y += y;
  Z += z;
  Serial.println();
  delay(100);
  if(i==10){

    Serial.print("!!!!!!!!!! X: ");
    Serial.print(X/100);
    Serial.print(" Y: ");
    Serial.print(Y/100);
    Serial.print(" Z: ");
    Serial.print(Z/100);
    Serial.println();
    X = 0;
    Y = 0;
    Z = 0;
    
    i=0;
    delay(5000);
    Serial.println("==============go================");
  }
  i++;  
  */
  /*
  if( checkTimer(&scanner.timer) ){
    if( !scanner.hold ){
      switch(scanner.direction){
        case SD_FWD:
          scanner.pos += SCANSTEP;
          //scanner.distance++;
          if(scanner.pos > SCANMAXANGLE - SCANSTEP){
            scanner.direction = SD_REV;
            flipLed(LEDPIN);
          }
        break;
        case SD_REV:
          scanner.pos -= SCANSTEP;
          //scanner.distance--;
          if(scanner.pos < SCANMINANGLE + SCANSTEP){
            scanner.direction = SD_FWD;
            flipLed(LEDPIN);
          }        
        break;
      }      
      scanner.servo.write(scanner.pos);    
    }
    scanner.distance = analogRead(SCANIRPIN);

    if(scanner.distance > 100){ //too close!
      scanner.hold = true;
      if(scanner.pos > 90){
        Spin_Right();
        newTimer(&evadeTimer, 50);
      }else
      if(scanner.pos < 90){
        Spin_Left();      
        newTimer(&evadeTimer, 50);
      }else{
        Backward();
        newTimer(&evadeTimer, 300);
      }
    }
  }
  
  if( checkTimer(&evadeTimer) ){
    disableTimer(&evadeTimer);
    scanner.hold = false;
    Forward();
  }
  */
}

/* LED */
void flipLed(int ledPin){
  if( digitalRead(ledPin) == LOW ){
    digitalWrite(ledPin, HIGH); 
  }else{
    digitalWrite(ledPin, LOW);     
  }
}

/* Motors */
void Forward(){
  analogWrite(MOTORA1PIN,MAXSPEED);
  analogWrite(MOTORA2PIN,0);
  analogWrite(MOTORB1PIN,MAXSPEED);
  analogWrite(MOTORB2PIN,0);
}
void Backward(){
  analogWrite(MOTORA1PIN,0);
  analogWrite(MOTORA2PIN,MAXSPEED);
  analogWrite(MOTORB1PIN,0);
  analogWrite(MOTORB2PIN,MAXSPEED);
}
void Spin_Right(){
  analogWrite(MOTORA1PIN,0);
  analogWrite(MOTORA2PIN,MAXSPEED);
  analogWrite(MOTORB1PIN,MAXSPEED);
  analogWrite(MOTORB2PIN,0);
}
void Spin_Left(){
  analogWrite(MOTORA1PIN,MAXSPEED);
  analogWrite(MOTORA2PIN,0);
  analogWrite(MOTORB1PIN,0);
  analogWrite(MOTORB2PIN,MAXSPEED);
}
void Motor_Stop(){
  analogWrite(MOTORA1PIN,0);
  analogWrite(MOTORA2PIN,0);
  analogWrite(MOTORB1PIN,0);
  analogWrite(MOTORB2PIN,0);
}


