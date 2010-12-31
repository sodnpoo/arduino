const int SERVOPIN = 3;

void setup(){
  Serial.begin(9600);
  
}

void loop(){
  int val = pulseIn(SERVOPIN, HIGH);
  Serial.println(val);
  delay(100);
}
