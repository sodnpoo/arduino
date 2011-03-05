#ifndef HCOMMANDS_H_GUARD
#define HCOMMANDS_H_GUARD

#ifdef DEBUG
  #define HCOMMANDS_DEBUG
#endif
//#undef HCOMMANDS_DEBUG
/******************************************************************** Commands */
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
#define HACTION_SPINLEFT    10


struct Command {
  int cmd;
  int value;
};

char* dumpCommand(struct Command *command, char *out){
#ifdef HCOMMANDS_DEBUG
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
    case HACTION_SPINLEFT:
      strcat(out, "HACTION_SPINLEFT");
    break;
    default:
      itoa(command->cmd, out, 10);
  }
  char cmdVal[16];
  itoa(command->value, cmdVal, 10);
  strcat(out, "=");
  strcat(out, cmdVal);
  
  return out;
#endif
}


#endif

