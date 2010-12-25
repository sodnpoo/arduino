#include "stdlib.h"
#include "math.h"
#include "wiring.h"
#include "WProgram.h"
#include "Wire.h"

#include <Timer.h>
#include <Servo.h> 
#include <SoftwareSerial.h>

/* Motors */
const int MOTORA1PIN = 3;
const int MOTORA2PIN = 5;
const int MOTORB1PIN = 6;
const int MOTORB2PIN = 9;

/* Scanner */
const int SCANIRPIN = 7;
const int SCANSERVOPIN = 7;
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

void setup(){
  Serial.begin(9600);
  Serial.println("setup");
  
  pinMode(LEDPIN, OUTPUT);
  digitalWrite(LEDPIN, LOW);

  pinMode(MOTORA1PIN,OUTPUT);
  pinMode(MOTORA2PIN,OUTPUT);
  pinMode(MOTORB1PIN,OUTPUT);
  pinMode(MOTORB2PIN,OUTPUT);

  initScanner(&scanner);
 
  Forward();
}

Timer evadeTimer;

void loop(){
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
  digitalWrite(MOTORA1PIN,HIGH);
  digitalWrite(MOTORA2PIN,LOW);
  digitalWrite(MOTORB1PIN,HIGH);
  digitalWrite(MOTORB2PIN,LOW);
}
void Backward(){
  digitalWrite(MOTORA1PIN,LOW);
  digitalWrite(MOTORA2PIN,HIGH);
  digitalWrite(MOTORB1PIN,LOW);
  digitalWrite(MOTORB2PIN,HIGH);
}
void Spin_Left(){
  digitalWrite(MOTORA1PIN,LOW);
  digitalWrite(MOTORA2PIN,HIGH);
  digitalWrite(MOTORB1PIN,HIGH);
  digitalWrite(MOTORB2PIN,LOW);
}
void Spin_Right(){
  digitalWrite(MOTORA1PIN,HIGH);
  digitalWrite(MOTORA2PIN,LOW);
  digitalWrite(MOTORB1PIN,LOW);
  digitalWrite(MOTORB2PIN,HIGH);
}
void Motor_Stop(){
  digitalWrite(MOTORA1PIN,LOW);
  digitalWrite(MOTORA2PIN,LOW);
  digitalWrite(MOTORB1PIN,LOW);
  digitalWrite(MOTORB2PIN,LOW);
}

