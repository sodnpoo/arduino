#include "stdlib.h"
#include "math.h"
#include "wiring.h"
#include "WProgram.h"
#include "Wire.h"

#include <Timer.h>
#include <Servo.h> 
#include <SoftwareSerial.h>

/* LCD */
const int LCDPIN = 16;
SoftwareSerial LCD = SoftwareSerial(LCDPIN,LCDPIN);
const byte LCDLINE1 = 0x80;
const byte LCDLINE2 = 0xC0;
/* Scanner */

const int SCANSERVOPIN = 7;
const int SCANMINANGLE = 60;
const int SCANMAXANGLE = 120;
const int SCANSTEP = (SCANMAXANGLE - SCANMINANGLE) / 8;
const int SCANRATE = 1000;
const byte SD_FWD = 0;
const byte SD_REV = 1;

struct tScanner {
  Servo scanServo;
  int scanPos;
  byte scanDir;
  Timer scanTimer;
};

void initScanner(struct tScanner *scanner){
  scanner->scanPos = SCANMINANGLE;
  scanner->scanDir = SD_FWD;  
  scanner->scanServo.attach(SCANSERVOPIN);
  newTimer(&scanner->scanTimer, SCANRATE);
}

tScanner scanner;

//status LED
const int LEDPIN = 13;

//dump data timer

void setup(){
  Serial.begin(9600);
  Serial.println("setup");
  
  pinMode(LCDPIN, OUTPUT);
  LCD.begin(9600);

  pinMode(LEDPIN, OUTPUT);
  digitalWrite(LEDPIN, LOW);

  initScanner(&scanner);
}

void loop(){
  if( checkTimer(&scanner.scanTimer) ){
    switch(scanner.scanDir){
      case SD_FWD:
        scanner.scanPos += SCANSTEP;
        if(scanner.scanPos > SCANMAXANGLE - SCANSTEP){
          scanner.scanDir = SD_REV;
          flipLed(LEDPIN);
        }
      break;
      case SD_REV:
        scanner.scanPos -= SCANSTEP;
        if(scanner.scanPos < SCANMINANGLE + SCANSTEP){
          scanner.scanDir = SD_FWD;
          flipLed(LEDPIN);
        }        
      break;
    }
    Serial.print("scanPos:");
    Serial.println(scanner.scanPos);
    LCD_Show_Text(&LCD, LCDLINE1, "scanPos:");
    LCD_Show_Int(&LCD, LCDLINE2, scanner.scanPos);
    scanner.scanServo.write(scanner.scanPos);
  }

}

/** SLCD Function **/
void LCD_Show_Int(SoftwareSerial *serial, byte Position,int x){
  LCD_Clear(serial);
  serial->print(Position,BYTE);
  serial->print(x,DEC);
}
void LCD_Show_Text(SoftwareSerial *serial, byte Position,char* x){
  LCD_Clear(serial);
  serial->print(Position,BYTE);
  serial->print(x);
}
void LCD_Clear(SoftwareSerial *serial){
  serial->print(0xFE,BYTE);
}

/* LED */
void flipLed(int ledPin){
  if( digitalRead(ledPin) == LOW ){
    digitalWrite(ledPin, HIGH); 
  }else{
    digitalWrite(ledPin, LOW);     
  }
}

