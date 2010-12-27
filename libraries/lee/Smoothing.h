#ifndef SMOOTHING_H_GUARD
#define SMOOTHING_H_GUARD

/******************************************************************** Smoothing */
const int MAXSMOOTHS = 50;
struct Smoothed{
  int readings[MAXSMOOTHS];
  int index;
  int total;
  int max;
};
void newSmoothed(struct Smoothed *smooth, int maxsmooths){
  smooth->max = maxsmooths;
  for(int i=0; i < smooth->max; i++){
    smooth->readings[i] = 0; 
  }
  smooth->index = 0;
}
int smoothReading(struct Smoothed *smooth, int reading){
  smooth->total = smooth->total - smooth->readings[smooth->index];
  smooth->readings[smooth->index] = reading;
  smooth->total = smooth->total + smooth->readings[smooth->index];
  smooth->index++;
  if(smooth->index >= smooth->max){
    smooth->index = 0;
  }
  return smooth->total / smooth->max;
}

#endif
