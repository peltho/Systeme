#include "Board.h"

#define MEMORYSIZEPERPROCESS     1000
#define KERNELSAVECURRENTPROCID     0
#define KERNELPID                   0 
#define PROCPSWFRAMESTART           0 
#define SAMEPROCMAXINSTRTICKCHUNK   15 // 15 instructions consécutives max par processus
#define SCHEDULENEXTPROCINTERRUPT   3  // int3
#define MAXSPROCCOUNT               9  // 9 processus max
#define MAXSEMAPHORECOUNT           9  // 9 sémaphores max
#define SEMAPHOREVECTORSTART      100
#define PROCSEMWAITLISTSTART      200  // ProcSemWaitList semops (à partir de 200, cb de semops (couple id sema (décalage par rapport à 100), op)
#define PROCSEMWAITLISTSTARTELEMCNT 2
#define CONSOLEINPUTOUTPUTTRIGGER 300

class CPU : public BaseCPU {
public:
    CPU(const string &id, ostream &log, istream &consoleIn, ostream &consoleOut, const int nGenReg, const int nProc);
    ~CPU();
    void execute  (const Instruction &instr) throw(nsSysteme::CExc);
    void interrupt(const int interruptNumber, bool qCLINTInstr) throw(nsSysteme::CExc);
    void pendingIntIfAny() throw(nsSysteme::CExc);
};
