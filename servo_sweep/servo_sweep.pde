#include <Servo.h> 

Servo myservo;

void setup() 
{ 
  myservo.attach(9);
} 

void loop() {
  for(int i=1200;i<1700;i++){
    myservo.writeMicroseconds(i);  // set servo to mid-point
    delayMicroseconds(i*2);
  }
  for(int i=1700;i>1200;i--){
    myservo.writeMicroseconds(i);  // set servo to mid-point
    delayMicroseconds(i*2);
  }

} 
