#include "stdlib.h"
#include "math.h"
#include "wiring.h"
#include "WProgram.h"

#include "sd_reader_config.h"
#include "sd_raw.h"
#include "sd_raw_config.h"

#include "sdlog.h"

void setup()
{
  Serial.begin(9600);
  Serial.println("setup()");
  delay(1000);

//  printWelcome();
  int sdinit = sd_raw_init();
  if(sdinit != 1)
  {
     Serial.print("MMC/SD initialization failed: ");
     Serial.println(sdinit);
  }
//  print_disk_info();
}

void loop()
{
  if(Serial.available()>0){
    char inChar = Serial.read();
    switch(inChar){
      case 'd': {
        SDdump();
        break;
      }
      case 'z': {
        Serial.println("zeroing offset");
        SDwriteOffset(0);
        break;
      }
      case 'r': {
        uint32_t offset = SDreadOffset();
        Serial.print("offset: ");
        Serial.println(offset);
        break;
      }
      case 'w': {
        SDwrite("Arduino is an open-source electronics prototyping platform based on flexible, easy-to-use hardware and software.",true);
        //SDwrite("It's intended for artists, designers, hobbyists, and anyone interested in creating interactive objects or environments.");
        /*
        SDwrite("Arduino can sense the environment by receiving input from a variety of sensors and can affect its surroundings by controlling lights, motors, and other actuators.");
        SDwrite("The microcontroller on the board is programmed using the Arduino programming language (based on Wiring) and the Arduino development environment (based on Processing). ");
        SDwrite("Arduino projects can be stand-alone or they can communicate with software on running on a computer (e.g. Flash, Processing, MaxMSP).");
        SDwrite("The boards can be built by hand or purchased preassembled; the software can be downloaded for free. The hardware reference designs (CAD files) are available under an open-source license, you are free to adapt them to your needs.");
        SDwrite("Arduino received an Honorary Mention in the Digital Communities section of the 2006 Ars Electronica Prix. The Arduino team is: Massimo Banzi, David Cuartielles, Tom Igoe, Gianluca Martino, and David Mellis. Credits");
        SDwrite("Development: For information on the development of Arduino, see the Arduino project on Google Code. Changes to the software are discussed on the developers mailing list.");
        SDwrite("Elsewhere: You can find lots of pictures of Arduino projects and workshops in the Arduino tag on Flickr. Related links can be found on the Arduino tag on del.icio.us.");
        SDwrite("To get started, follow the instructions for your operating system: Windows, Mac OS X or Linux; or for your board: Arduino Nano, Arduino Mini, Arduino BT, LilyPad Arduino, XBee shield. If you're having trouble, check out the troubleshooting suggestions.");
        SDwrite("Examples of how to work with the Arduino language and common electronic components; further readings on the foundations; information on hacking and extending the Arduino hardware and software; external resources.");
        */
        break;
      }
      default:
        break;
     }
  }    
}

/* dump to Serial */
void SDdump(){
  const uint32_t lastOffset = SDreadOffset();
  char t[SDMAXLENGTH];

  /*
  1. fetch 255(MAXLENGTH) chars starting at 16(DATAOFFSET)
  2. cast to string
  3. fetch 255(MAXLENGTH) chars starting at 16(DATAOFFSET)+string.length() */
  
  uint32_t offset = 0 + SDDATAOFFSET;
  while(offset < lastOffset){
    sd_raw_read(offset, (byte*)t, SDMAXLENGTH);

    int slen = strlen(t);
    Serial.print('[');
    Serial.print(offset);
    Serial.print("][");
    Serial.print(slen);
    Serial.print("][");
    Serial.print(t);
    Serial.println(']');
    
    offset = offset + slen + 1;
  }
}

/*
void printWelcome()
{
    Serial.println("------------------------");
    Serial.println("Data sampling system");
    Serial.println("send z to zero offset");
    Serial.println("send r to read offset");
    Serial.println("send w to write @ next offset");
    Serial.println("send s to start sampling");
    Serial.println("send q to stop sampling");
    Serial.println("Ready.....");
    Serial.println("-------------------------");
}


int print_disk_info()
{
 

    struct sd_raw_info disk_info;
    if(!sd_raw_get_info(&disk_info))
    {
        return 0;
    }

    
    Serial.println();
    Serial.print("rev:    "); 
    Serial.print(disk_info.revision,HEX); 
    Serial.println();
    Serial.print("serial: 0x"); 
    Serial.print(disk_info.serial,HEX); 
    Serial.println();
    Serial.print("date:   "); 
    Serial.print(disk_info.manufacturing_month,DEC); 
    Serial.println();
    Serial.print(disk_info.manufacturing_year,DEC); 
    Serial.println();
    Serial.print("size:   "); 
    Serial.print(disk_info.capacity,DEC); 
    Serial.println();
    Serial.print("copy:   "); 
    Serial.print(disk_info.flag_copy,DEC); 
    Serial.println();
    Serial.print("wr.pr.: ");
    Serial.print(disk_info.flag_write_protect_temp,DEC); 
    Serial.print('/');
    Serial.print(disk_info.flag_write_protect,DEC); 
    Serial.println();
    Serial.print("format: "); 
    Serial.print(disk_info.format,DEC); 
    Serial.println();
    Serial.print("free:   "); 
   
    return 1;
}

*/
