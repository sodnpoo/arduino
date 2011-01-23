
#include "stdlib.h"
#include "math.h"
#include "wiring.h"
#include "WProgram.h"
#include "Wire.h"

#include <sd_raw.h>
#include <sd_raw_config.h>
#include <sd_reader_config.h>

#include <sdbinlog.h>

#define DEBUG

#include "Smoothing.h"
#include "Timer.h"

#define HACTION_OFF    0
#define HACTION_UP     1 //value is height
#define HACTION_DOWN   2
#define HACTION_HOVER  3
#define HACTION_NEXT   4 //next command
#define HACTION_FWD    5
#define HACTION_REV    6
#define HACTION_BTMRANGE    7 //set min range bottom
#define HACTION_LAND    8
#define HACTION_TAKEOFF    9

struct Command {
  int cmd;
  int value;
};

char* dumpCommand(struct Command *command, char *out){
  out[0] = 0;
  switch(command->cmd){
    case HACTION_OFF: //on the ground - rotors idle
      strcat(out, "HACTION_OFF");
    break;
    case HACTION_UP: //moving upwards
      strcat(out, "HACTION_UP");
    break;
    case HACTION_DOWN: //moving downwards
      strcat(out, "HACTION_DOWN");
    break;
    case HACTION_HOVER: //hovering
      strcat(out, "HACTION_HOVER");
    break;
    case HACTION_NEXT: //next command
      strcat(out, "HACTION_NEXT");
    break;
    case HACTION_FWD:
      strcat(out, "HACTION_FWD");
    break;
    case HACTION_REV:
      strcat(out, "HACTION_REV");
    break;
    case HACTION_BTMRANGE:
      strcat(out, "HACTION_BTMRANGE");
    break;
    case HACTION_LAND:
      strcat(out, "HACTION_LAND");
    break;
    case HACTION_TAKEOFF:
      strcat(out, "HACTION_TAKEOFF");
    break;
    default:
      itoa(command->cmd, out, 10);
  }
  char cmdVal[16];
  itoa(command->value, cmdVal, 10);
  strcat(out, "=");
  strcat(out, cmdVal);
  
  return out;
}

const byte STULTRAB = 99;
struct t_sensor {
  byte type;
  int value;
};

/* log */
const byte LTCOMMAND = 0;
const byte LTSENSOR = 1;

struct t_log_sensor {
  byte loglen;
  byte logtype;
  t_sensor sensor;
  byte null;  
};
struct t_log_haction {
  byte loglen;
  byte logtype;
  Command haction;
  byte null;
};

void setup(){
  pinMode(2, OUTPUT);     

  Serial.begin(9600);
  
  Serial.println("setup()");

  int sdinit = sd_raw_init();
  if(sdinit != 1){
     Serial.print("MMC/SD initialization failed: ");
     Serial.println(sdinit);
  }

  delay(1000);

  uint32_t sdtail = 0;
  
  Serial.print("free:");
  Serial.println(findFree());
  
//  uint32_t sdtail = findFree();

  t_log_haction c;
  t_log_sensor s;
  char buf[256];

  Serial.println("==========");
  Serial.println("===read===");
  Serial.println("==========");
  
  sdtail = 0;
  do{
    sdtail = readLog(sdtail, &buf);
  }while(sdtail);  


  Serial.println("===========");
  Serial.println("===write===");
  Serial.println("===========");

  sdtail = 0;

  c.haction.cmd = HACTION_HOVER;
  c.haction.value = 99;
  Serial.println(dumpCommand(&c.haction, buf));
  sdtail = writeLog(&c, sdtail, sizeof(c));


  s.sensor.type = STULTRAB;
  s.sensor.value = 1234;
  sdtail = writeLog(&s, sdtail, sizeof(s));

  c.haction.cmd = HACTION_UP;
  c.haction.value = 100;
  Serial.println(dumpCommand(&c.haction, buf));
  sdtail = writeLog(&c, sdtail, sizeof(c));

  c.haction.cmd = HACTION_LAND;
  c.haction.value = 50;
  Serial.println(dumpCommand(&c.haction, buf));
  sdtail = writeLog(&c, sdtail, sizeof(c));

  sd_raw_sync();

  Serial.println("==========");
  Serial.println("===read===");
  Serial.println("==========");
  
  byte type;
  sdtail = 0;
  byte bbuf[255];
  do{

    sdtail = readLog(sdtail, &bbuf);

    if(sdtail){
      
      type = bbuf[0];
    
    switch(type){

      case LTCOMMAND:
        Serial.println("LTCOMMAND");
        
        Command *c;
        c = (Command*)&bbuf[sizeof(type)];

        Serial.println(dumpCommand(c, buf));
        
        break;

      case LTSENSOR:
        Serial.println("LTSENSOR");
        /*
        t_sensor *s;
        s = (t_sensor*)bbuf[1];

        Serial.print(s->type);
        Serial.print("=");
        Serial.println(s->value);
        */
        break;

    }

    }

  }while(sdtail);  

}


void loop(){
  digitalWrite(2, HIGH);   // set the LED on
  delay(1000);              // wait for a second
  digitalWrite(2, LOW);    // set the LED off
  delay(1000);              // wait for a second
  
}

