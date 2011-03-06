#include <Wire.h>

const int BMA180ADDR = 0x40;

int readAccel(byte msbaddr, byte lsbaddr){
  byte _msb, _lsb;  
  readFrom(BMA180ADDR, lsbaddr, 1, &_lsb);  
  int r = 0;
  if(_lsb & 1){
    readFrom(BMA180ADDR, msbaddr, 1, &_msb);
    r = r | _msb;
    r = r << 8;
    r = r | _lsb;
    r = r >> 2;    
  }
  return r;
}

void initBMA180(){
  writeTo(BMA180ADDR, 0x0d, B0001);     //ctrl_reg1 register and set the ee_w bit to enable writing.
  writeTo(BMA180ADDR, 0x20, B00001000); //bw_tcs register and set the filtering level to 10hz.
  writeTo(BMA180ADDR, 0x35, B0100);     //offset_lsb1 register and set the range to +- 2.
}

