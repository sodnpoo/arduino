#include <TimerThree.h>

const byte LEDPIN = 13;
const byte SERVOPIN = 3;
const byte SERVOPIN1 = 4;
const byte SERVOPIN2 = 5;
const byte SERVOPIN3 = 6;
const byte SERVOPIN4 = 7;

const byte MAXRCPWMS = 5;
const byte RCPINS[MAXRCPWMS] = {
  SERVOPIN, 
  SERVOPIN1, 
  SERVOPIN2, 
  SERVOPIN3, 
  SERVOPIN4, /**/
};

  /* < 50 millis for loop()
  1 = 10
  2 = 14
  3 = 26
  4 = 32
  5 = 40
  */
const byte RCSAMPLERATE = 40; //in microseconds

struct tRcPwm {
  unsigned long lastMicros;
  byte pin, lastState;
  int pulseWidth;
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
  Timer3.initialize( RCSAMPLERATE );
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

byte rawDigitalRead(byte pinnum){
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
  for(byte i=0;i<MAXRCPWMS;i++){
    //byte state = digitalRead(rcPwm[i].pin);
    byte state = rawDigitalRead(rcPwm[i].pin);
    
    if( rcPwm[i].lastState != state ){
      unsigned long now = micros();
      if( state==HIGH ){ //rising
        rcPwm[i].lastMicros = now;
      }else{ //falling
        rcPwm[i].pulseWidth = now - rcPwm[i].lastMicros;
      }
      rcPwm[i].lastState = state;
    }
  }
}

void flipLed(int ledPin){
  if( digitalRead(ledPin) == LOW ){
    digitalWrite(ledPin, HIGH); 
  }else{
    digitalWrite(ledPin, LOW);     
  }
}
