#include <TimerThree.h>

const int LEDPIN = 13;
const int SERVOPIN = 3;
const int SERVOPIN1 = 4;
const int SERVOPIN2 = 5;
const int SERVOPIN3 = 6;
const int SERVOPIN4 = 7;

const int MAXRCPWMS = 5;
const int RCPINS[MAXRCPWMS] = {
  SERVOPIN, 
  SERVOPIN1, 
  SERVOPIN2, 
  SERVOPIN3, 
  SERVOPIN4,
};

struct tRcPwm {
  unsigned long pulseWidth, lastMicros, lastState;
  int pin;
};

volatile tRcPwm rcPwm[MAXRCPWMS];

void setup(){
  Serial.begin(9600);

  for(int i=0;i<MAXRCPWMS;i++){
    rcPwm[i].pulseWidth = 0;
    rcPwm[i].lastMicros = 0;
    rcPwm[i].lastState = 0;
    rcPwm[i].pin = RCPINS[i];
  }
  
  pinMode(10, OUTPUT);
  Timer3.initialize(50);
  Timer3.attachInterrupt(callback);    
}

void loop(){
  Serial.print(millis());

  for(int i=0;i<MAXRCPWMS;i++){
    Serial.print(" ");
    Serial.print(i);
    Serial.print(": ");
    Serial.print(rcPwm[i].pulseWidth);
  }
  
  Serial.println();
  //delay(200);
}

int rawDigitalRead(int pinnum){
  switch(pinnum){
    case 3:
      return !((PINE & (1<<5))==0); // 3
    case 4:
      return !((PING & (1<<5))==0); // 4
    case 5:
      return !((PINE & (1<<3))==0); // 5
    case 6:
      return !((PINH & (1<<3))==0); // 6
    case 7:
      return !((PINH & (1<<4))==0); // 7
  }
}

void callback(){
  

  for(int i=0;i<MAXRCPWMS;i++){
    //int state = digitalRead(rcPwm[i].pin);
    int state = rawDigitalRead(rcPwm[i].pin);
    
    if( rcPwm[i].lastState != state ){
      unsigned long now = micros();
      if( state==HIGH ){ //rising
        rcPwm[i].lastMicros = now;
      }else{ //falling
        rcPwm[i].pulseWidth = now - rcPwm[i].lastMicros;
      }
      rcPwm[i].lastState = state;
    }
    /*
    if( (rcPwm[i].lastState==LOW) && (state==HIGH) ){
      //rising edge
      rcPwm[i].lastMicros = now;
    }else
    if( (rcPwm[i].lastState==HIGH) && (state==LOW) ){
      //falling edge
      rcPwm[i].pulseWidth = now - rcPwm[i].lastMicros;
    }
    */
    
  }
}

void flipLed(int ledPin){
  if( digitalRead(ledPin) == LOW ){
    digitalWrite(ledPin, HIGH); 
  }else{
    digitalWrite(ledPin, LOW);     
  }
}
