#ifndef HLOG_H_GUARD
#define HLOG_H_GUARD

/*
structs for heli logging - put here so they can be used by a reader program
*/

struct logdata_t {
  long ts;
  int bottomRange;
  int desiredBottomRange;
  boolean bottomRangeLocked;
  Command hAction;
  int iAction; 
};
struct logdatacontainer_t { //all variables we want to log need to be in this struct
  byte loglen;     //we need a byte at the start and end

  logdata_t logdata;
  
  byte lognull;     //we need a byte at the start and end
};

#endif

