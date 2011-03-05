#define DEBUG

#include "stdlib.h"
#include "math.h"
#include "wiring.h"
#include "WProgram.h"
#include "Wire.h"

#include <sd_raw.h>
#include <sd_raw_config.h>
#include <sd_reader_config.h>

#include <sdbinlog.h>

#include "Smoothing.h"
#include "Timer.h"


#include <hCommands.h>
#include <hHardware.h>
#include <hLog.h>


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
/*  
  Serial.print("free:");
  Serial.println(findFree());
*/  
//  uint32_t sdtail = findFree();

  byte buf[256];

  Serial.println("==========");
  Serial.println("===read===");
  Serial.println("==========");
  
  Serial.println("ts,bottomRange,desiredBottomRange,bottomRangeLocked,cmd,value,i");
  
  byte type;
  sdtail = 0;
  do{

    sdtail = readLog(sdtail, &buf);

    if(sdtail){
      logdata_t *logdata;
      logdata = (logdata_t*)&buf;
      
//      char buf2[255]; Serial.println( dumpCommand( &(logdata->hAction), buf2) );

      Serial.print( logdata->ts );
      Serial.print( ',' );
      Serial.print( logdata->bottomRange );
      Serial.print( ',' );
      Serial.print( logdata->desiredBottomRange );
      Serial.print( ',' );

      if(logdata->bottomRangeLocked)
        Serial.print("true");
      else
        Serial.print("false");

      Serial.print( ',' );
      Serial.print( logdata->hAction.cmd );
      Serial.print( ',' );
      Serial.print( logdata->hAction.value );
      Serial.print( ',' );
      Serial.print( logdata->iAction ); 
      Serial.println();
      
/*      
      Serial.print( "ts:" );
      Serial.println( logdata->ts );
      Serial.print( "bottomRange:" );
      Serial.println( logdata->bottomRange );
      Serial.print( "desiredBottomRange:" );
      Serial.println( logdata->desiredBottomRange );
      Serial.print( "bottomRangeLocked:" );
      Serial.println( logdata->bottomRangeLocked );

      Serial.print( logdata->hAction.cmd );
      Serial.print('=');
      Serial.println( logdata->hAction.value );

      Serial.print( "iAction:" ); 
      Serial.println( logdata->iAction ); 
*/
  
    }
  }while(sdtail);  

}


void loop(){
  digitalWrite(2, HIGH);   // set the LED on
  delay(1000);              // wait for a second
  digitalWrite(2, LOW);    // set the LED off
  delay(1000);              // wait for a second
  
}

