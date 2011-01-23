#ifndef SDBINLOG_H_GUARD
#define SDBINLOG_H_GUARD

/******************************************************************** sdbinlog */

uint32_t writeLog(void *data, uint32_t offset, byte length){
  ((byte*)data)[0] = length; //cast to byte array and set first byte to length
  ((byte*)data)[length] = 0; //cast to byte array and set last byte to 0
                             // this effectively sets the length of the next log entry to 0 by default
  sd_raw_write( offset, (byte*)data, length );
  return offset + length - sizeof(byte);
}

uint32_t readLog(uint32_t offset, void *data){
  byte length = 0; //read the first byte to get the length
  sd_raw_read(offset, (byte*)&length, sizeof(length));
  
  if(length){
    sd_raw_read(offset + sizeof(length), (byte*)data, length - sizeof(byte));
    return offset + length - sizeof(byte);      
  }
  return 0;
}

uint32_t findFree(){
  uint32_t sdtail = 0;
  uint32_t lasttail = 0;
  byte buf[255];
  do{
    lasttail = sdtail;
    sdtail = readLog(sdtail, &buf);
  }while(sdtail);  
  return lasttail;
}

#endif
