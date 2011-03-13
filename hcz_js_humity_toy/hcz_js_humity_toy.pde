int analogPin = 0;     // potentiometer wiper (middle terminal) connected to analog pin 3
                       // outside leads to ground and +5V
int raw = 1;           // variable to store the raw input value
float Vin = 4.91;           // variable to store the input voltage
float R1 = 975000;// 3000;         // variable to store the R1 value
float R2 = 0;          // variable to store the R2 value

/*
Returns KOhms from a voltage divider
_raw = raw analog value from center of divider
_Vin = V+
_R1 = value of the top half resistor in KOhms
*/
float RawAnalogToR(int _raw, float _Vin, float _R1){ //using a voltage divider returns kilo ohms
  float _Vout = (_Vin / 1023.0) * _raw;    // Calculates the Voltage on th Input PIN

  Serial.print("_raw: ");
  Serial.println(_raw);

  Serial.print("Vout: ");
  Serial.println(_Vout);

  float s2 = ((_Vin / _Vout) - 1);
  Serial.print("s2: ");
  Serial.println(s2);

  float _R2 = _R1 / ((_Vin / _Vout) - 1);
  return _R2;
}

void setup()
{
  Serial.begin(9600);             // Setup serial
  pinMode(analogPin, INPUT);
  digitalWrite(13, HIGH);         // Indicates that the program has intialized
}

void loop()
{
  
  raw = analogRead(analogPin);    // Reads the Input PIN

  R2 = RawAnalogToR(raw, Vin, R1);

  Serial.print("R2: ");
  Serial.println(R2);
  delay(1000);
} 
