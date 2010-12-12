#ifndef TIMER_H_GUARD
#define TIMER_H_GUARD

/******************************************************************** Timer */
struct Timer {
  long lastTime;
  int delayTime;
};

void newTimer(struct Timer *timer, int delayTime){
  timer->lastTime = millis();
  timer->delayTime = delayTime;
}

boolean checkTimer(struct Timer *timer){
  if(timer->lastTime == 0){
    return false; 
  }
  long now = millis();
  if((now - timer->lastTime) > timer->delayTime){
    timer->lastTime = now;
    return true;
  }
  return false;
}

boolean isTimerDisabled(struct Timer *timer){
  if(timer->lastTime == 0){
    return true;
  }
  return false;
}

void disableTimer(struct Timer *timer){
  timer->lastTime = 0;
}

void enableTimer(struct Timer *timer){
  timer->lastTime = millis();
}

#endif

