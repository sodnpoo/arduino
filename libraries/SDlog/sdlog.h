#ifndef SDLOG_H_GUARD
#define SDLOG_H_GUARD

/******************************************************************** sdlog */

const int SDDATAOFFSET = 16;
const int SDMAXLENGTH = 255;

boolean SDwriteOffset(uint32_t offset){
  if( !sd_raw_write(0, (byte*)&offset, sizeof(offset)) ){
    return false;
  }  
  return true;  
}

uint32_t SDreadOffset(){
  uint32_t offset = 0;
  if(! sd_raw_read(0 ,(byte*)&offset, sizeof(offset)) ){
    return 0;
  }
  return offset;  
}

boolean SDwriteAt(char *s, uint32_t offset)
{
  int slen = strlen(s)+1;
  if(slen>SDMAXLENGTH){
    return false; 
  }
  if( !sd_raw_write(offset+SDDATAOFFSET, (byte*)s, slen) ){
    return false;
  }
  //sd_raw_sync();
  return true;
}

boolean SDwrite(char *s, boolean sync){
  uint32_t offset = SDreadOffset();
  if(! SDwriteAt(s, offset) ){
    return false; 
  }
  if(! SDwriteOffset(offset + strlen(s) +1 ) ){
    return false;
  }
  if(sync){
    sd_raw_sync();
  }
  return true;
}

#endif

