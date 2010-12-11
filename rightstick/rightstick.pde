const int enablePin = 22;
const int fwdPin = 4;//0;
const int revPin = 3;//1;


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
  Serial.begin(9600);

  newSmoothed(&smooth1);
  newSmoothed(&smooth2);

  pinMode(fwdPin, INPUT);
  pinMode(revPin, INPUT);
  
}
/*
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
*/
void loop(){
  int fwdVal = smoothReading(&smooth1, analogRead(fwdPin));
  int revVal = smoothReading(&smooth2, analogRead(revPin));

  if( (fwdVal > 80) && (!revVal) ){
    //forward pushed
    Serial.println("forward");
  }
  if( (revVal > 80) && (!fwdVal) ){
    //rev pushed
    Serial.println("reverse");
  }
  if( !fwdVal && !revVal ){
    Serial.println("neutral");
  }

}
