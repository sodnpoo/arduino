/*
 */

int potPin = 0;
int potVar = 0;
int led1Pin = 7;
int led2Pin = 6;
int MFled1Pin = 12;
int MFled2Pin = 11;

void setup()
{
  Serial.begin(9600);           // set up Serial library at 9600 bps
  Serial.println("setup()");  // prints hello with ending line break 
  
  pinMode(led1Pin, OUTPUT);
  pinMode(led2Pin, OUTPUT);  
  pinMode(MFled1Pin, OUTPUT);  
  pinMode(MFled2Pin, OUTPUT);   

  analogWrite(led1Pin, 255);
  analogWrite(led2Pin, 255);
  analogWrite(MFled1Pin, 0);
  analogWrite(MFled2Pin, 0);
  
}

void loop()                       // run over and over again
{

  for(int i=0;i<=255;i++){
    analogWrite(MFled1Pin, i);
    analogWrite(led1Pin, i);
    //analogWrite(MFled2Pin, 255-i);
    delay(1);
  }
  for(int i=255;i>=0;i--){
    analogWrite(MFled1Pin, i);
    analogWrite(led2Pin, i);
    //analogWrite(MFled2Pin, 255-i);
    delay(1);
  }

}
