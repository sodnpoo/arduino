#include <Wire.h>

const int BMA180ADDR = 0x40;

struct BMA180_Range_t {
  byte bitmask;
  double scalefactor;
};

/*
range<2:0>  range[+/-g]    mg/LSB(ADC)
000         1              0.13
001         1.5            0.19
010         2              0.25
011         3              0.38
100         4              0.50
101         8              0.99
110         16             1.98
111         NA             NA
*/

const BMA180_Range_t BMA180_RANGE1   = { B000, 0.13 };
const BMA180_Range_t BMA180_RANGE1_5 = { B001, 0.19 };
const BMA180_Range_t BMA180_RANGE2   = { B010, 0.25 };
const BMA180_Range_t BMA180_RANGE3   = { B011, 0.38 };
const BMA180_Range_t BMA180_RANGE4   = { B100, 0.50 };
const BMA180_Range_t BMA180_RANGE8   = { B101, 0.99 };
const BMA180_Range_t BMA180_RANGE16  = { B110, 1.98 };

double BMA180_gScaleFactor = 0;

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

bool getAccel(int *x, int *y, int *z){
  //use global BMA180_gScaleFactor
  *x = readAccel(0x03, 0x02) * BMA180_gScaleFactor;
  *y = readAccel(0x05, 0x04) * BMA180_gScaleFactor;
  *z = readAccel(0x07, 0x06) * BMA180_gScaleFactor;
  return true;
}

void initBMA180(){
  _initBMA180(&BMA180_RANGE2);
}

void _initBMA180(const struct BMA180_Range_t *range){
  writeTo(BMA180ADDR, 0x0d, B00010000);     //ctrl_reg1 register and set the ee_w bit to enable writing.
  //writeTo(BMA180ADDR, 0x20, B00001000); //bw_tcs register and set the filtering level to 10hz.
  
  byte reg0x35 = 0;
  BMA180_gScaleFactor = range->scalefactor;
  reg0x35 |= range->bitmask << 1; // apply the bitmask..
  writeTo(BMA180ADDR, 0x35, reg0x35);     //offset_lsb1 register and set the range to +- 2.
  
}

