const int enablePin = 22;
const int in1Pin = 7;//24;
const int in2Pin = 8;//25;
const int heli1Pin = 3;//0;
const int heli2Pin = 4;//1;


const int MAXSMOOTHS = 3;
struct Smoothed{
  int readings[MAXSMOOTHS];
  int index;
  int total;
};

void newSmoothed(struct Smoothed *smooth){
  for(int i=0;i<MAXSMOOTHS;i++){
    smooth->readings[i] = 0; 
  }
  smooth->index = 0;
}

int smoothReading(struct Smoothed *smooth, int reading){
  smooth->total = smooth->total - smooth->readings[smooth->index];
  smooth->readings[smooth->index] = reading;
  smooth->total = smooth->total + smooth->readings[smooth->index];
  smooth->index++;
  if(smooth->index >= MAXSMOOTHS){
    smooth->index = 0;
  }
  return smooth->total / MAXSMOOTHS;
}

Smoothed smooth1, smooth2;

void setup(){
  //Serial.begin(9600);

  newSmoothed(&smooth1);
  newSmoothed(&smooth2);

  pinMode(enablePin, OUTPUT);
  pinMode(in1Pin, OUTPUT);
  pinMode(in2Pin, OUTPUT);

  pinMode(heli2Pin, INPUT);
  pinMode(heli2Pin, INPUT);
  
  digitalWrite(enablePin, HIGH);
  digitalWrite(in1Pin, LOW);
  digitalWrite(in2Pin, LOW);
}

void rotorFwd(){
    Serial.println("rotorFwd()");
    digitalWrite(in1Pin, HIGH);
    digitalWrite(in2Pin, LOW);  
}

void rotorRev(){
    Serial.println("rotorRev()");
    digitalWrite(in1Pin, LOW);
    digitalWrite(in2Pin, HIGH);  
}

void rotorStop(){
  digitalWrite(in2Pin, LOW);
  digitalWrite(in1Pin, LOW);  
}

void loop(){
  //Serial.println("loop()");
  
  int in1 = analogRead(heli1Pin);
  int in1s = smoothReading(&smooth1, in1);
  int in2 = analogRead(heli2Pin);
  int in2s = smoothReading(&smooth2, in2);
  /*
  Serial.print("in1: ");
  Serial.println(in1);
  Serial.print("in2: ");
  Serial.println(in2);
  */
  if((in1s>80)&&(!in2s)){
    Serial.print("in1s: ");
    Serial.println(in1s);
    rotorRev();
  }
  if((in2s>80)&&(!in1s)){
    Serial.print("in2s: ");
    Serial.println(in2s);
    rotorFwd();
  }
  if( !in1s && !in2s ){
    rotorStop();
  }

}
