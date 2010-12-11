const int M1 = 5;
const int M2 = 6;

void setup(){
  Serial.begin(9600);
  pinMode(M1, OUTPUT);
  pinMode(M2, OUTPUT);
}

void loop(){
  for(int i=90;i<=95;i++){
    Serial.println(i);
    analogWrite(M1, i);
    analogWrite(M2, i);
    delay(250); 
  }
  analogWrite(M1, 0);
  analogWrite(M2, 0);
  Serial.println("wait");
  delay(3000);
  /*
  digitalWrite(onboardLed, HIGH);
   delay(500);
   digitalWrite(onboardLed, LOW);
   delay(500);
   */
}

