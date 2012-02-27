#ifndef TIMERMICROS_H_GUARD
#define TIMERMICROS_H_GUARD

/******************************************************************** Timer */
struct TimerUs {
  unsigned long lastTime;
  unsigned int delayTime;
};

void newTimerUs(struct TimerUs *timer, unsigned int delayTime){
  timer->lastTime = micros();
  timer->delayTime = delayTime;
}

boolean checkTimerUs(struct TimerUs *timer){
  if(timer->lastTime == 0){
    return false; 
  }
  unsigned long now = micros();
  if((now - timer->lastTime) >= timer->delayTime){
    timer->lastTime = now;
    return true;
  }
  return false;
}

boolean isTimerDisabledUs(struct TimerUs *timer){
  if(timer->lastTime == 0){
    return true;
  }
  return false;
}

void disableTimerUs(struct TimerUs *timer){
  timer->lastTime = 0;
}

void enableTimerUs(struct TimerUs *timer){
  timer->lastTime = micros();
}

#endif

