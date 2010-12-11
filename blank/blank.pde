/*
 */

int potPin = 0;
int potVar = 0;
int led1Pin = 2;
int led2Pin = 3;

void setup()
{
  Serial.begin(9600);           // set up Serial library at 9600 bps
  Serial.println("setup()");  // prints hello with ending line break 
  
  pinMode(led1Pin, OUTPUT);
  pinMode(led2Pin, OUTPUT);  
  
}

void loop()                       // run over and over again
{

}
