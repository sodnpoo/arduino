#include <TimerThree.h>

const int LEDPIN = 13;
const int SERVOPIN = 3;
const int SERVOPIN1 = 4;
const int SERVOPIN2 = 5;
const int SERVOPIN3 = 6;
const int SERVOPIN4 = 7;

void setup(){
  Serial.begin(9600);
  
  pinMode(10, OUTPUT);
  Timer3.initialize(75);
  Timer3.attachInterrupt(callback);    
}

volatile unsigned long diff, diff1, diff2, diff3, diff4 = 0;

void loop(){
  Serial.print(millis());
  
  Serial.print(" 0: ");
  Serial.print(diff);
  Serial.print(" 1: ");
  Serial.print(diff1);
  Serial.print(" 2: ");
  Serial.print(diff2);
  Serial.print(" 3: ");
  Serial.print(diff3);
  Serial.print(" 4: ");
  Serial.print(diff4);
  
  Serial.println();
  //delay(200);
}

volatile unsigned long lastMicros, lastMicros1, lastMicros2, lastMicros3, lastMicros4 = 0;
volatile int servoState, servoState1, servoState2, servoState3, servoState4 = LOW;
volatile int lastState, lastState1, lastState2, lastState3, lastState4 = LOW;

void callback(){
  unsigned long now = micros();

  servoState = digitalRead(SERVOPIN);
  servoState1 = digitalRead(SERVOPIN1);
  servoState2 = digitalRead(SERVOPIN2);
  servoState3 = digitalRead(SERVOPIN3);
  servoState4 = digitalRead(SERVOPIN4);
  
  if( (lastState==LOW) && (servoState==HIGH) ){
    //rising edge
    lastMicros = now;
  }else
  if( (lastState==HIGH) && (servoState==LOW) ){
    //falling edge
    diff = now - lastMicros;
  }

  if( (lastState1==LOW) && (servoState1==HIGH) ){
    //rising edge
    lastMicros1 = now;
  }else
  if( (lastState1==HIGH) && (servoState1==LOW) ){
    //falling edge
    diff1 = now - lastMicros1;
  }

  if( (lastState2==LOW) && (servoState2==HIGH) ){
    //rising edge
    lastMicros2 = now;
  }else
  if( (lastState2==HIGH) && (servoState2==LOW) ){
    //falling edge
    diff2 = now - lastMicros2;
  }

  if( (lastState3==LOW) && (servoState3==HIGH) ){
    //rising edge
    lastMicros3 = now;
  }else
  if( (lastState3==HIGH) && (servoState3==LOW) ){
    //falling edge
    diff3 = now - lastMicros3;
  }

  if( (lastState4==LOW) && (servoState4==HIGH) ){
    //rising edge
    lastMicros4 = now;
  }else
  if( (lastState4==HIGH) && (servoState4==LOW) ){
    //falling edge
    diff4 = now - lastMicros4;
  }


  lastState = servoState;
  lastState1 = servoState1;
  lastState2 = servoState2;
  lastState3 = servoState3;
  lastState4 = servoState4;
  
}

void flipLed(int ledPin){
  if( digitalRead(ledPin) == LOW ){
    digitalWrite(ledPin, HIGH); 
  }else{
    digitalWrite(ledPin, LOW);     
  }
}
