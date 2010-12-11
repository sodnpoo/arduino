/*
 */

int potPin = 0;
int potVar = 0;
int led1Pin = 12;
int led2Pin = 11;

int heliLedPin = 0;

void setup()
{
  Serial.begin(9600);           // set up Serial library at 9600 bps
  Serial.println("setup()");  // prints hello with ending line break 
  
  pinMode(led1Pin, OUTPUT);
  pinMode(led2Pin, OUTPUT);  
  
  for(int i=0;i<5;i++){
    digitalWrite(led1Pin, HIGH);
    digitalWrite(led2Pin, LOW);
    delay(200);
    digitalWrite(led1Pin, LOW);
    digitalWrite(led2Pin, HIGH);
    delay(200);

    digitalWrite(led1Pin, LOW);
    digitalWrite(led2Pin, LOW);
  }
  
}

//should be an array[]
int heliLedVal0 = 0;
int heliLedVal1 = 0;
int heliLedVal2 = 0;

void loop()                       // run over and over again
{
  //shuffle down
  heliLedVal2 = heliLedVal1;
  heliLedVal1 = heliLedVal0;

  heliLedVal0 = analogRead(heliLedPin);
  Serial.print("heliLedVal0: ");
  Serial.print(heliLedVal0);
  Serial.print(" heliLedVal1: ");
  Serial.print(heliLedVal1);
  Serial.print(" heliLedVal2: ");
  Serial.println(heliLedVal2);
  
  if((heliLedVal0 <= 10)&&(heliLedVal1 <= 10)&&(heliLedVal2 <= 10)){
    digitalWrite(led1Pin, LOW);
  }else{
    digitalWrite(led1Pin, HIGH);  
  }
  
  delay(250);
}
