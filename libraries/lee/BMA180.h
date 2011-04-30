#ifndef BMA180_H_GUARD
#define BMA180_H_GUARD

#include <Wire.h>

const int BMA180ADDR = 0x40;

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

int readXAccel(){
  return readAccel(0x03, 0x02);
}
int readYAccel(){
  return readAccel(0x05, 0x04);
}
int readZAccel(){
  return readAccel(0x07, 0x06);
}

void initBMA180(){
  writeTo(BMA180ADDR, 0x0D, B0001);      // Connect to the ctrl_reg1 register and set the ee_w bit to enable writing.
  writeTo(BMA180ADDR, 0x20, B00001000);  // Connect to the bw_tcs register and set the filtering level to 10hz.
  writeTo(BMA180ADDR, 0x35, B0100);      // Connect to the offset_lsb1 register and set the range to +- 2.
}

#endif
