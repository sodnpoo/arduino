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
  
  int X,Y,Z=0;

  Serial.println(" X: ");
  //X = readAccel(0x03, 0x02);
  //Serial.println(X);
  X = readAccel3(0x03, 0x02);
  double dX;
  dX = X * 0.00025;
  Serial.println(dX);

  Serial.println(" Y: ");
  //Y = readAccel(0x05, 0x04);  
  //Serial.println(Y);
  Y = readAccel3(0x05, 0x04);  
  double dY;
  dY = Y * 0.00025;
  Serial.println(dY);

  Serial.println(" Z: ");
  //Z = readAccel(0x07, 0x06);
  //Serial.println(Z);
  Z = readAccel3(0x07, 0x06);
  double dZ;
  dZ = Z * 0.00025;
  Serial.println(dZ);

  Serial.println();
  delay(1000);
}

int readAccel3(byte msbAddr, byte lsbAddr)
{
  short temp, result, temp2;
  byte lsb, msb = 0;

  temp2 = 0;
  temp = 0;

  while(temp != 1)
  {
    Wire.beginTransmission(address);
//    Wire.send(0x03);
    Wire.send(msbAddr);
    Wire.requestFrom(address, 1);
    while(Wire.available())
    {
      msb = Wire.receive();
      temp = msb & 0x01;
    }
  }

  Wire.beginTransmission(address);
//  Wire.send(0x02);
  Wire.send(lsbAddr);
  Wire.requestFrom(address, 1);
  while(Wire.available())
  {
    lsb = Wire.receive();
    temp |= lsb;
    temp = temp >> 2;
  }
  result = Wire.endTransmission();
  /*
  Serial.print("lsb: ");
  Serial.println(lsb, BIN);
  Serial.print("msb: ");
  Serial.println(msb, BIN);
  Serial.print("temp: ");
  Serial.println(temp, BIN);
  */
  msb = msb >> 2;
  
  if(lsb & B10000000){
    //Serial.println("negative");
    
    lsb &= B01111111;
    temp2 = lsb << 6;
    temp2 |= msb;       
   
    temp2 = 0 - temp2;
  }else{
    temp2 = lsb << 6;
    temp2 |= msb;    
  }
/*
  Serial.print("temp2: ");
  Serial.println(temp2, BIN);
  Serial.println(temp2, DEC);
*/
  
//  Serial.println(temp2, DEC);
  
  return temp2;
}

int readAccel2(byte lsbAddr, byte msbAddr){
  byte lsb, msb = 0;
  short result;
  
  //read LSB first...
  while(!(lsb & 1)){
    Wire.beginTransmission(address);
    Wire.send(lsbAddr);
    Wire.requestFrom(address, 1);
    while(Wire.available()){
      lsb = Wire.receive();
    }
    Wire.endTransmission();
  }
  
  Serial.print("lsb: ");
  Serial.println(lsb, BIN);
  
  if(lsb & 1){
    Serial.println("new_data");
  }
  
  //remove bit 0 and bit 1
  lsb = lsb >> 2;
  Serial.print("lsb: ");
  Serial.println(lsb, BIN);
  

  //now MSB
  Wire.beginTransmission(address);
  Wire.send(msbAddr);
  Wire.requestFrom(address, 1);
  while(Wire.available()){
    msb = Wire.receive();
  }
  Wire.endTransmission();
  
  Serial.print("msb: ");
  Serial.println(msb, BIN);
  
  result = msb << 6;
  Serial.print("res: ");
  Serial.println(result, BIN);
  
  result |= lsb;
  Serial.print("res: ");
  Serial.println(result, BIN);

  Serial.print("res: ");
  Serial.println(result, DEC);
  
  return 0;
}

//int x;

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

