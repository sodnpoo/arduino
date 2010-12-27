#include <Wire.h>

#define address 0x40

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
  delay(100);
}

int x;

int readAccel(byte msb, byte lsb)
{
  int temp, result;

  temp = 0;

  while(temp != 1)
  {
    Wire.beginTransmission(address);
//    Wire.send(0x03);
    Wire.send(msb);
    Wire.requestFrom(address, 1);
    while(Wire.available())
    {
      temp = Wire.receive() & 0x01;
    }
  }

  Wire.beginTransmission(address);
//  Wire.send(0x02);
  Wire.send(lsb);
  Wire.requestFrom(address, 1);
  while(Wire.available())
  {
    temp |= Wire.receive();
    temp = temp >> 2;
  }
  result = Wire.endTransmission();
  return temp;
}

void initBMA180()
{
  int temp, result, error;

  Wire.beginTransmission(address);
  Wire.send(0x00);
  Wire.requestFrom(address, 1);
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
    Wire.beginTransmission(address);
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
    Wire.beginTransmission(address);
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
    Wire.beginTransmission(address);
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

  Wire.beginTransmission(address);
  Wire.send(0x00);
  Wire.requestFrom(address, 1);
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

