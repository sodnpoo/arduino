#include <Servo.h> 
 

const int XSERVOPIN = 5;
const int YSERVOPIN = 4;
/*
const int MAXX = 100;
const int MINX = 82;
*/
const int MAXX = 95;
const int MINX = 85;
/*
const int MAXY = 103;
const int MINY = 79;
*/
const int MAXY = 95;
const int MINY = 85;



Servo Xservo, Yservo;
 
 
void setup() 
{ 
  Serial.begin(9600);
  Xservo.attach(XSERVOPIN);
  Yservo.attach(YSERVOPIN);
  
  Xservo.write(90);
  //Yservo.write(80);//middle
  Yservo.write(87);
} 
 
 
void loop() { 
  /*
  Xservo.write( ((MAXX-MINX)/2) + MINX );
  Yservo.write(MAXY);
  delay(80);

  Xservo.write(MINX);
  Yservo.write(MINY);
  delay(80);
  
  Xservo.write(MAXX);
  delay(80);
  */
/*
  Xservo.write(MINX);
  delay(300);

  Yservo.write(MINY);
  delay(300);

  Xservo.write(MAXX);
  delay(300);

  Yservo.write(MAXY);
  delay(300);
*/
  /*
  digitalWrite(13, HIGH);
  for(int i=MINY; i < MAXY; i+=2){
    Yservo.write(i);
    delay(10);
    
  } 
  */
  /*
  digitalWrite(13, HIGH);
  for(int i=MINX; i < MAXX; i+=2){
    Xservo.write(i);
    delay(7);
    
  } 
  */
  /*
  digitalWrite(13, LOW);
  for(int i=MAXY; i > MINY; i-=2){
    Yservo.write(i);   
    delay(10);
  } 
  */
  /*
  digitalWrite(13, LOW);
  for(int i=MAXX; i > MINX; i-=2){
    Xservo.write(i);   
    delay(15);
  } 
  */
  
} 
