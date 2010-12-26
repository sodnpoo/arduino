#include <Wire.h> // I2C library, gyroscope

#define GYRO_ADDR 0x69 // gyro address, binary = 11101001 when AD0 is connected to Vcc (see schematics of your breakout board)
#define SMPLRT_DIV 0x15
#define DLPF_FS 0x16
#define INT_CFG 0x17
#define PWR_MGM 0x3E

#define TO_READ 6 // 2 bytes for each axis x, y, z


//initializes the gyroscope
void initGyro()
{
  /*****************************************
  * ITG 3200
  * power management set to:
  * clock select = internal oscillator
  *     no reset, no sleep mode
  *   no standby mode
  * sample rate to = 3Hz
  * parameter to +/- 2000 degrees/sec
  * low pass filter = 5Hz
  * no interrupt
  ******************************************/

  writeTo(GYRO_ADDR, PWR_MGM, 0x00);
  writeTo(GYRO_ADDR, SMPLRT_DIV, 0xFF); // EB, 50, 80, 7F, DE, 23, 20, FF
  writeTo(GYRO_ADDR, DLPF_FS, 0x1E); // +/- 2000 dgrs/sec, 1KHz, 1E, 19
  writeTo(GYRO_ADDR, INT_CFG, 0x00);

}


void getGyroscopeData()
{
  /**************************************
  Gyro ITG-3200 I2C
  registers:
  x axis MSB = 1D, x axis LSB = 1E
  y axis MSB = 1F, y axis LSB = 20
  z axis MSB = 21, z axis LSB = 22
  *************************************/

  int regAddress = 0x1D;
  double x, y, z;
  byte buff[TO_READ];
  char str[50]; // 50 should be enough to store all the data from the

  readFrom(GYRO_ADDR, regAddress, TO_READ, buff); //read the gyro data from the ITG3200

  x = ((buff[0] << 8) | buff[1]) / 14.375;
  y = ((buff[2] << 8) | buff[3]) / 14.375;
  z = ((buff[4] << 8) | buff[5]) / 14.375;

  Serial.print(" X: ");
  Serial.print(x);
  Serial.print(" Y: ");
  Serial.print(y);
  Serial.print(" Z: ");
  Serial.print(z);
  
  Serial.println();
}


void setup()
{
  Serial.begin(9600);
  Wire.begin();
  initGyro();
}


void loop()
{
  getGyroscopeData();
  delay(1000);
}


//---------------- Functions
//Writes val to address register on device
void writeTo(int device, byte address, byte val) {
   Wire.beginTransmission(device); //start transmission to device
   Wire.send(address);	  // send register address
   Wire.send(val);	  // send value to write
   Wire.endTransmission(); //end transmission
}

//reads num bytes starting from address register on device in to buff array
void readFrom(int device, byte address, int num, byte buff[]) {
  Wire.beginTransmission(device); //start transmission to device
  Wire.send(address);	  //sends address to read from
  Wire.endTransmission(); //end transmission

  Wire.beginTransmission(device); //start transmission to device
  Wire.requestFrom(device, num);    // request 6 bytes from device

  int i = 0;
  while(Wire.available())    //device may send less than requested (abnormal)
  {
    buff[i] = Wire.receive(); // receive a byte
    i++;
  }
  Wire.endTransmission(); //end transmission
}

 
