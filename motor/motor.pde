/*
 */

int potPin = 0;
int potVar = 0;
int led1Pin = 13;
int led2Pin = 3;
const int speedPin = 5;
const int speedPin2 = 6;

void setup()
{
  Serial.begin(9600);
  Serial.println("setup()");
  
  pinMode(led1Pin, OUTPUT);
  //digitalWrite(led1Pin, LOW);
  
  pinMode(speedPin, OUTPUT);
}

void loop()
{
  /*
  //255=off
  analogWrite(led1Pin, 255);
  analogWrite(led2Pin, 255);
  delay(1000);
  //0=on
  analogWrite(led1Pin, 0);
  analogWrite(led2Pin, 0);
  delay(1000);
  */
  
  for(int i=70;i<=75;i++){
    if(digitalRead(led1Pin) == LOW){
      digitalWrite(led1Pin, HIGH); 
    }else{
      digitalWrite(led1Pin, LOW);      
    }
    
    Serial.println(i);    
    analogWrite(speedPin, i);
    analogWrite(speedPin2, i);
    delay(600);
  }

  analogWrite(speedPin, 0);
  analogWrite(speedPin2, 0);
  Serial.println("stopped.");    
  delay(5000);

  /*
  for(int i=255; i>=192; i-=5){
    analogWrite(speedPin, 255-i);
    analogWrite(led2Pin, i);
    delay(200); 
  }
 */
  /*
  potVar = analogRead(potPin);
  analogWrite(led1Pin, potVar/4);
  analogWrite(led2Pin, 255-(potVar/4));
  */
  /*
  for(int i=ledMin;i<=ledMax;i+=5){
    analogWrite(led1Pin, i);
    analogWrite(led2Pin, ledMin-i);
    delay(30);
  }
  for(int i=ledMax;i>=ledMin;i-=5){
    analogWrite(led1Pin, i);
    analogWrite(led2Pin, ledMax-i);
    delay(30);
  }
  */
  /*
  potVar = analogRead(potPin);
  Serial.println(potVar);
  
  digitalWrite(led1Pin, LOW);
  digitalWrite(led2Pin, HIGH);
  
  delay(potVar);

  digitalWrite(led1Pin, HIGH);
  digitalWrite(led2Pin, LOW);
  
  delay(potVar);
  */
}
