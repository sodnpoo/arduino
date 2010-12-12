#ifndef SMOOTHING_H_GUARD
#define SMOOTHING_H_GUARD

/******************************************************************** Smoothing */
const int MAXSMOOTHS = 50;
struct Smoothed{
  int readings[MAXSMOOTHS];
  int index;
  int total;
};
void newSmoothed(struct Smoothed *smooth){
  for(int i=0;i<MAXSMOOTHS;i++){
    smooth->readings[i] = 0; 
  }
  smooth->index = 0;
}
int smoothReading(struct Smoothed *smooth, int reading){
  smooth->total = smooth->total - smooth->readings[smooth->index];
  smooth->readings[smooth->index] = reading;
  smooth->total = smooth->total + smooth->readings[smooth->index];
  smooth->index++;
  if(smooth->index >= MAXSMOOTHS){
    smooth->index = 0;
  }
  return smooth->total / MAXSMOOTHS;
}

#endif
