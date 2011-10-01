#ifndef HHARDWARE_H_GUARD
#define HHARDWARE_H_GUARD

const int ledPin = 2;
const int heliLedPin = 5;

const int M1 = 5;
const int M2 = 6;

const int in1Pin = 7;//24;
const int in2Pin = 8;//25;
const int tailSpeedPin = 3;

// SRF stuff
#define srfAddress 0x70                           // Address of the SRF08
#define cmdByte 0x00                              // Command byte
#define lightByte 0x01                            // Byte to read light sensor
#define rangeByte 0x02                            // Byte for start of ranging data

inline void hHWsetup(){
  Wire.begin();
  
  pinMode(heliLedPin, INPUT);

  pinMode(M1, OUTPUT);
  pinMode(M2, OUTPUT);  
  analogWrite(M1, 0);
  analogWrite(M2, 0);
  
  pinMode(ledPin, OUTPUT);
  
  //tail rotor
  pinMode(in1Pin, OUTPUT);
  pinMode(in2Pin, OUTPUT);
  pinMode(tailSpeedPin, OUTPUT);

}

void flipLed(){
  if( digitalRead(ledPin) == LOW ){
    digitalWrite(ledPin, HIGH); 
  }else{
    digitalWrite(ledPin, LOW);     
  }
}
/*
Smoothed txActiveSmooth;
Timer txActiveTimer;
inline boolean isTxActive(struct Smoothed *smooth, int ledPin){
  int pinVal = analogRead(ledPin);
  Serial.print("pinVal: ");
  Serial.println(pinVal);

  int LedVal = smoothReading(smooth, pinVal);
  Serial.print("txLedVal: ");
  Serial.println(LedVal);

  if(LedVal){
    return false;
  }
  return true;
}
*/
/***************************************** tail rotor */
void rotorFwd(){
  Serial.println("rotorFwd()");
  digitalWrite(in1Pin, HIGH);
  digitalWrite(in2Pin, LOW);  
  analogWrite(tailSpeedPin, 255);
}

void rotorRev(){
  Serial.println("rotorRev()");
  digitalWrite(in1Pin, LOW);
  digitalWrite(in2Pin, HIGH);  
  analogWrite(tailSpeedPin, 255);
}

void rotorStop(){
  //Serial.println("rotorStop()");
  digitalWrite(in2Pin, LOW);
  digitalWrite(in1Pin, LOW);  
  analogWrite(tailSpeedPin, 0);
}

/******************************************************************** Motors */
#define MOTORMAX 255
#define MOTORMIN 170
int M1Speed = MOTORMIN;
int M2Speed = MOTORMIN;
// 208 is take off speed with full battery
// 180 just off floor(holding own weight) with trainer / free rotation on skids

void SpinLeft(){
  
  if((M1Speed+20) < MOTORMAX){
    M1Speed += 20;
  }else{
    M1Speed = MOTORMAX;
  }
/*
  if(M2Speed > MOTORMIN){
    M2Speed -= 40;
  }
*/  
  analogWrite(M1, M1Speed);
  analogWrite(M2, M2Speed);
}

void IncMotors(){
  //Serial.println("IncMotors");
  if( (M1Speed < MOTORMAX) && (M2Speed < MOTORMAX) ){
    M1Speed++;
    M2Speed++;
    flipLed();
  }
  analogWrite(M1, M1Speed);
  analogWrite(M2, M2Speed);
}

void DecMotors(){
  //Serial.println("DecMotors");
  if( (M1Speed > MOTORMIN) && (M2Speed > MOTORMIN) ){
    M1Speed--;
    M2Speed--;
    flipLed();
  }
  analogWrite(M1, M1Speed);
  analogWrite(M2, M2Speed);
}

void StopMotors(){  
  analogWrite(M1, 0);
  analogWrite(M2, 0);
  M1Speed = MOTORMIN;
  M2Speed = MOTORMIN;
}

/********************* SRF08 */

//need to wait at least 65ms before reading the range
void requestRange(int srf){
  //Serial.println("requestRange()");
  Wire.beginTransmission(srf);
  Wire.send(0x00);  //00 = start ranging
  Wire.send(0x51);  //51 = in cm (50=inches,51=cm,52=ms)
  Wire.endTransmission();
}

int readRange(int srf){
  //Serial.println("readRange()");
  Wire.beginTransmission(srf);
  Wire.send(0x02); //(02=rangebyte?)
  Wire.endTransmission();
  //fetch 2 bytes and return as int
  Wire.requestFrom(srf, 2);
  while(Wire.available() < 2);
  byte highByte = Wire.receive();
  byte lowByte = Wire.receive();
  return (highByte << 8) + lowByte;
}
/* example how to get range */
int getRange2(){
  requestRange(srfAddress);
  delay(70);
  return readRange(srfAddress);
}


#endif

