#include "stdlib.h"
#include "math.h"
#include "wiring.h"
#include "WProgram.h"
#include "Wire.h"

#include <Smoothing.h>
#include <Timer.h>

//status LED
const int LEDPIN = 13;

//photocell pin
const int LIGHTPIN = 1;//analog

//rotorary encoder photocell - wind speed
const int PHOTOPIN = 0; //interrupt
volatile int state = LOW;
volatile int counter = 0;
Timer rotationTimer;
const int ROTATERATE = 60000; // sample rate 1 minute
//diameter of blades = 165mm 
//circumference of blades = 1036mm = 3.14 * (165mm*2)
const int bladeCircumference = 1036; //in mm

//LM335Z - temperature
const int LM335RATE = 1000; // 1 second
const int LM335PIN = 0; //analog
Timer LM335Timer;
Smoothed LM335Smooth;
int LM335toDegreesC(int raw, int fudge){
  return (((raw * 500L) / 1023L) - 273L) + fudge; // Algorithm to convert the LM335 output signal from the ADC to degrees C.
} 

//humidity
//const int HCZJSPIN = 1;
/*
Returns KOhms from a voltage divider
_raw = raw analog value from center of divider
_Vin = V+
_R1 = value of the top half resistor in KOhms
*/
/*
float RawAnalogToR(int _raw, float _Vin, float _R1){ //using a voltage divider returns kilo ohms
  float _Vout = (_Vin / 1023.0) * _raw;    // Calculates the Voltage on th Input PIN
  float _R2 = _R1 / ((_Vin / _Vout) - 1);
  return _R2;
}
*/


//dump data timer
Timer dumpTimer;
const int DUMPRATE = 60000; //60 seconds

void setup(){
  Serial.begin(9600);
  Serial.println("setup");

  digitalWrite(LEDPIN, LOW);

  pinMode(PHOTOPIN, INPUT);
  attachInterrupt(PHOTOPIN, windSpeedISR, FALLING);
  
  newSmoothed(&LM335Smooth, 10);
  newTimer(&LM335Timer, LM335RATE);

  newTimer(&rotationTimer, ROTATERATE);

  newTimer(&dumpTimer, DUMPRATE);
  
  delay(1000);
}

void windSpeedISR()
{
  state = !state;
  counter++;
}

boolean dumpHalfFreq = false;
int smoothedLM335 = 0;
int rotationsPerMin = 0;

void loop(){
  digitalWrite(LEDPIN, state);
  
  if( checkTimer(&rotationTimer) ){
    rotationsPerMin = counter;
    counter = 0;
  }
  
  if( checkTimer(&LM335Timer) ){
    int rawLM335 = analogRead(LM335PIN);
    smoothedLM335 = smoothReading(&LM335Smooth, rawLM335);
  }
  
  if( checkTimer(&dumpTimer) ){
//    digitalWrite(LEDPIN, HIGH);
    
    int degreesC = LM335toDegreesC(smoothedLM335, -4);
 
    Serial.print("degreesC:");
    Serial.print(degreesC);
    
    Serial.print('/'); // divider


    Serial.print("rotationsPerMin:");
    Serial.print(rotationsPerMin);
    
    Serial.print('/'); // divider

    Serial.print("windMph:");
    int metresPerMin = rotationsPerMin * (bladeCircumference/1000);
    int metresPerHour = metresPerMin * 60;
    int windMph = metresPerHour * 0.000621371192; //convert to mph
    Serial.print( windMph );
    
    Serial.print('/'); // divider

    Serial.print("light:");
    int light = analogRead(LIGHTPIN);
    Serial.print(light);
    
    Serial.print('/'); // divider

    /*
    int humidityR = analogRead(HCZJSPIN);    // Reads the Input PIN

    float Vin = 4.86;           // variable to store the input voltage
    float R1 = 1020 + 970 + 970;// 3000;         // variable to store the R1 value
    float R2 = RawAnalogToR(humidityR, Vin, R1);

    Serial.print("humidityR:");
    Serial.print(R2);
    
    Serial.print('/'); // divider
    */
      
    Serial.println();
    
//    digitalWrite(LEDPIN, LOW);
  }
  
}
