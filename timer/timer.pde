struct Timer {
  long lastTime;
  int delayTime;
};

void dumpTimer(struct Timer *timer){
  Serial.println("=== dumpTimer() ===");
  Serial.print("lastTime: ");
  Serial.println(timer->lastTime);
  Serial.print("delayTime: ");
  Serial.println(timer->delayTime);
}

void newTimer(struct Timer *timer, int delayTime){
  timer->lastTime = 0;
  timer->delayTime = delayTime;
}

boolean checkTimer(struct Timer *timer){
  long now = millis();
  if((now - timer->lastTime) > timer->delayTime){
    timer->lastTime = now;
    return true;
  }
  return false;
}

Timer testTimer;

void setup(){
  Serial.begin(9600);
  
  dumpTimer(&testTimer);
  newTimer(&testTimer, 3000);
  dumpTimer(&testTimer);
}

void loop(){
  
  boolean hasTriggered = checkTimer(&testTimer);
  if(hasTriggered){
    Serial.println("!!! woop !!!");
    dumpTimer(&testTimer);
  }
  //dumpTimer(&testTimer);
  
  //delay(1000);
}

