#include "Board.h"

#define MEMORYSIZEPERPROCESS     1000 
#define KERNELSAVECURRENTPROCID     0
#define KERNELPID                   0 
#define PROCPSWFRAMESTART           0 
#define SAMEPROCMAXINSTRTICKCHUNK   15 // 15 instructions max par processus
#define SCHEDULENEXTPROCINTERRUPT   3
#define MAXSPROCCOUNT               9  // 9 processus max
#define MAXSEMAPHORECOUNT           9  // 9 sémaphores max
#define SEMAPHOREVECTORSTART      100
#define PROCSEMWAITLISTSTART      200
#define PROCSEMWAITLISTSTARTELEMCNT 2  // 2 opérations sur les sémaphores (P() et V())
#define CONSOLEINPUTOUTPUTTRIGGER 300 

class CPU : public BaseCPU {
public:
    CPU(const string &id, ostream &log, istream &consoleIn, ostream &consoleOut, const int nGenReg, const int nProc);
    ~CPU();
    void execute  (const Instruction &instr) throw(nsSysteme::CExc); 
    void interrupt(const int interruptNumber, bool qCLINTInstr) throw(nsSysteme::CExc);
    void pendingIntIfAny() throw(nsSysteme::CExc);
};
