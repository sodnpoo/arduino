#include <TimerThree.h>

const int LEDPIN = 13;
const int SERVOPIN = 3;

void setup(){
  Serial.begin(9600);
  
  pinMode(10, OUTPUT);

  pinMode(SERVOPIN, OUTPUT);
  digitalWrite(SERVOPIN, LOW);

  Timer3.initialize(1);         // initialize timer1, and set a 1/2 second period
//  Timer3.initialize(500000);         // initialize timer1, and set a 1/2 second period
//  Timer3.initialize(500000);         // initialize timer1, and set a 1/2 second period
  //Timer3.pwm(9, 512);
  Timer3.attachInterrupt(callback);    
  

}

void loop(){
    
}

volatile long t, c = 0;
volatile boolean pulse = 0;
volatile long d = 1200;

volatile unsigned long lastMicros = 0;

const byte GOHI = 0x01;
const byte GOLO = 0x02;
const byte WAIT1200 = 0x03;
const byte WAIT1700 = 0x04;
const byte WAIT20000 = 0x05;
const byte GOHI1200 = 0x06;
const byte GOHI1700 = 0x07;
const byte WAIT2SEC = 0x08;

volatile byte mode = 0x00;
volatile byte lastMode, i = 0x00;

void callback(){
  unsigned long now = micros();
  unsigned long diff = now - lastMicros;
  
  switch(mode){
    case GOHI:
      digitalWrite(SERVOPIN, HIGH);
      flipLed(LEDPIN);
      lastMicros = now;
      mode = WAIT1700;
    break;
    case GOLO:
      digitalWrite(SERVOPIN, LOW);
      flipLed(LEDPIN);
      lastMicros = now;
      mode = WAIT20000;
    break;
    case WAIT1200:
      if(diff>1200){
        lastMode = GOHI1200;
        mode = GOLO;
      }
    break;
    case WAIT1700:
      if(diff>1700){
        lastMode = GOHI1700;
        mode = GOLO;
      }
    break;
    case WAIT20000:
      if(diff>20000){
        if(i>5){
          mode = WAIT2SEC;
          i=0;
        }else{
          mode = lastMode;
        }
        i++;
      }
    break;
    case WAIT2SEC:
      if(diff>2000000){
        if(lastMode == GOHI1200){
          mode = GOHI1700;
        }else{
          mode = GOHI1200;
        }
      }
    break;
    case GOHI1200:
      digitalWrite(SERVOPIN, HIGH);
      //flipLed(LEDPIN);
      lastMicros = now;
      mode = WAIT1200;
    break;
    case GOHI1700:
      digitalWrite(SERVOPIN, HIGH);
      //flipLed(LEDPIN);
      lastMicros = now;
      mode = WAIT1700;
    break;
    case 0x00:
      //start
      mode = GOHI;//1200;
    break;
  }
  
  //Serial.println(diff);
  /*
  if(diff>100000){
    Serial.println(diff);
    flipLed(LEDPIN);
    lastMicros = now;
  }
  */
  
}

void flipLed(int ledPin){
  if( digitalRead(ledPin) == LOW ){
    digitalWrite(ledPin, HIGH); 
  }else{
    digitalWrite(ledPin, LOW);     
  }
}
