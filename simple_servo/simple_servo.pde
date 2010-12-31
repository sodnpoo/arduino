const int SERVOPIN = 3;


void setup(){
  Serial.begin(9600);
  
  pinMode(SERVOPIN, OUTPUT);
}

void loop(){
  Serial.print("R micros():");
  Serial.println(micros());
  
  Servo_Move(1200);
  delay(2000);
  Servo_Move(1700);
  delay(2000);
}

void Servo_Move(int val){
  int i;
  for(i=0;i<5;i++){
    digitalWrite(SERVOPIN, HIGH);
    delayMicroseconds(val);
    digitalWrite(SERVOPIN,LOW);
    delay(20);
  }
}


