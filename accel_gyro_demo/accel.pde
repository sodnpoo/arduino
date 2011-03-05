#include <Wire.h>

//#define address 0x40
const int BMA180ADDR = 0x40;
/*
void setup()
{
  Wire.begin();
  Serial.begin(9600);
  initBMA180();
  delay(2000);
}

void loop()
{

  Serial.print(" X: ");
  int X = readAccel(0x03, 0x02);
  Serial.print(X);

  Serial.print(" Y: ");
  int Y = readAccel(0x05, 0x04);
  Serial.print(Y);

  Serial.print(" Z: ");
  int Z = readAccel(0x07, 0x06);
  Serial.print(Z);

  Serial.println();
  delay(250);
}
*/
int x;

int readAccel(byte msb, byte lsb){
  byte _msb, _lsb;  
  readFrom(BMA180ADDR, lsb, 1, &_lsb);  
  int r = 0;
  if(_lsb & 1){
    readFrom(BMA180ADDR, msb, 1, &_msb);
    r = r | _msb;
    r = r << 8;
    r = r | _lsb;
    r = r >> 2;    
  }
  return r;
}

void initBMA180()
{
  int temp, result, error;

  Wire.beginTransmission(BMA180ADDR);
  Wire.send(0x00);
  Wire.requestFrom(BMA180ADDR, 1);
  while(Wire.available())
  {
    temp = Wire.receive();
  }
  Serial.print("Id = ");
  Serial.println(temp);
  result = Wire.endTransmission();
  checkResult(result);
  if(result > 0)
  {
    error = 1;
  }
  delay(10);
  if(temp == 3)
  {
    // Connect to the ctrl_reg1 register and set the ee_w bit to enable writing.
    Wire.beginTransmission(BMA180ADDR);
    Wire.send(0x0D);
    Wire.send(B0001);
    result = Wire.endTransmission();
    checkResult(result);
    if(result > 0)
    {
      error = 1;
    }
    delay(10);
    // Connect to the bw_tcs register and set the filtering level to 10hz.
    Wire.beginTransmission(BMA180ADDR);
    Wire.send(0x20);
    Wire.send(B00001000);
    result = Wire.endTransmission();
    checkResult(result);
    if(result > 0)
    {
      error = 1;
    }
    delay(10);
    // Connect to the offset_lsb1 register and set the range to +- 2.
    Wire.beginTransmission(BMA180ADDR);
    Wire.send(0x35);
    Wire.send(B0100);
    result = Wire.endTransmission();
    checkResult(result);
    if(result > 0)
    {
      error = 1;
    }
    delay(10);
  }

  if(error == 0)
  {
    Serial.print("BMA180 Init Successful");
  }
}

void checkResult(int result)
{
  if(result >= 1)
  {
    Serial.print("PROBLEM..... Result code is ");
    Serial.println(result);
  }
  else
  {
    Serial.println("Read/Write success");
  }
}

void readId()
{
  int temp, result;

  Wire.beginTransmission(BMA180ADDR);
  Wire.send(0x00);
  Wire.requestFrom(BMA180ADDR, 1);
  while(Wire.available())
  {
    temp = Wire.receive();
  }
  Serial.print("Id = ");
  Serial.println(temp);
  result = Wire.endTransmission();
  checkResult(result);
  delay(10);
} 

