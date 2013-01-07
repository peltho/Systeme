JMBSI $prep        ;LNR on passe à $prep: pour préparer la structure de la mémoire (vecteur d'interruptions, proc/file tables)
#-------- start of $int1 ----------------------------
SETRI R1 0         ;LNR=$int1: adresse où l'ID du processus courant est stocké
LDMEM R1 R0        ;LNR on charge l'ID du dernier processus prévu
SETRI R2 1         ;LNR l'incrémentation pour la table des processus
ADDRG R0 R0 R2     ;LNR le prochain ID de processus à étudier
SETRI R11 20       ;LNR on stocke le nombre de processus à l'@20 (3 processus)
LDMEM R11 R1       ;LNR on charge le nombre de processus dans R1
SETRG R9 R1        ;LNR on sauve R1 dans R9 qui contient alors le nombre de processus
ADDRG R9 R9 R2     ;LNR on incrémente le nombre de processus de 1 car les ID de processus commencent à 1
SETRI R3 1         ;LNR on stocke l'état ReadyToRun dans R3 (différents états: 0(exit), 1(ready), 2(running), 3(semwait), 4(netwait)...)
SETRI R4 3         ;LNR on stocke l'état SemWait dans R4
SETRI R15 100      ;LNR on stocke l'@ de départ du vecteur de sémaphores (où l'on garde l'état des sémaphores)
SETRI R6 0         ;LNR jusqu'à maintenant, on a pas encore de processus terminé
SETRG R7 R0        ;LNR=$top: on copie R0 pour le test du wrap around
SUBRG R7 R7 R9     ;LNR prepare the test for R0 wrap around
JNZRI R7 $nextPid  ;LNR si R7 (donc R0) est différent de R9 (nombre de processus), on peut continuer
SETRI R0 1         ;LNR sinon, on doit mettre R0 à 1 pour le wrap around
SETRG R10 R11      ;LNR=$nextPid: on prépare l'@ de la table des processus
ADDRG R10 R10 R0   ;LNR R10 contient l'@ du processus courant dans la table des processus
SETRI R14 200      ;LNR on stocke l'@ de début du vecteur des listes d'attente des processus dans R14, une liste pour chaque processus, (count,(semId,semOp),(semId,semOp),...)
ADDRG R14 R14 R0   ;LNR on stocke l'@ de début de ce même vecteur pour le processus courant
LDMEM R10 R8       ;LNR on charge l'état du processus courant (de R10) dans R8
JZROI R8 $nextproc ;LNR on termine le processus et on passe à $nextproc:
SETRI R6 1         ;LNR on trouve finalement un processus non terminé
SETRG R12 R8       ;LNR on sauve R8 dans R12, on récupère l'état qu'on avait dans R8 qu'on stocke à présent dans R12
SUBRG R8 R8 R3     ;LNR on prepare le test si le processus est prêt
JZROI R8 $startproc ;LNR on passe à $startproc: pour l'ID R0 et l'@ de la table des processus R10, si c'est prêt
SUBRG R12 R12 R4   ;LNR on prepare le test si le processus est où non dans l'état semwait
JNZRI R12 $nextproc ;LNR on passe à $nextproc: puisque le processus dID R0 n'est pas dans l'état semwait
SETRI R13 0        ;LNR le processus est dans l'état semwait, on le prépare pour semoptest(0)
SETRI R5 1         ;LNR on stocke la taille pour l'appel de la fonction
SETRI R16 $semoptest ;LNR l'@ de début de la fonction $semoptest
CLLSB R5 R16       ;LNR on apelle $semoptest(R13=0, R14=@ de semlist du processus courant, R15=@semvect)
JZROI R16 $nextproc ;LNR on passe au processus suivant car on ne peut tjs pas appliquer les semops attendus par ce processus
SETRI R13 1        ;LNR on peut désormais les appliquer
SETRI R5 1         ;LNR on stocke la taille pour l'appel de la fonction
SETRI R16 $semoptest ;LNR l'@ de début de la fonction $semoptest
CLLSB R5 R16       ;LNR on apelle $semoptest(R13=1, R14=@ de semlist du processus courant, R15=@semvect)
JZROI R16 $crash   ;LNR on ne devrait jamais arriver ici
JMTOI $startproc   ;LNR on passe à $startproc: on a fait toutes les opérations sur semaphores, et on peut élire le processus 0
ADDRG R0 R0 R2     ;LNR=$nextproc: on incrémente le PID pour étudier le prochain processus
SUBRG R1 R1 R2     ;LNR on décrémente le compteur de boucle
JNZRI R1  $top     ;LNR on boucle à $top: boucle pour le nombre maximum de processus
JNZRI R6 $wait     ;LNR aucun processus prêt mais au moins un non terminé, donc on attend avec $wait:
SDOWN              ;LNR tous les processus sont terminés, on éteint tout
INTRP              ;LNR on accepte les interruptions (qui étaient désactivées)
NOPER              ;LNR=$wait: on attend un peu pour les interruptions
JMBSI $wait        ;LNR puis on boucle à $wait: pour attendre un peu plus
SETRI R3 2         ;LNR=$startproc: l'état running, pour le processus qu'on vient de trouver et qui est prêt
STMEM R10 R3       ;LNR on change l'état du processus à running (@ dans R0)
SETRI R1 0         ;LNR @ où l'ID du processus courant est stocké
STMEM R1 R0        ;LNR on stocke le nouvel ID du processus courant
LDPSW R0           ;LNR on exécute le processus d'ID R0
#-------- start of $int2 ----------------------------
SETRI R0 0         ;LNR=$int2: exit current process, the address where its pid is stored
LDMEM R0 R1        ;LNR R1 now has the pid of the process which is now exiting
SETRI R2 20        ;LNR offset to get the process slot address from the process id
ADDRG R0 R1 R2     ;LNR R0 now contains the process slot address
SETRI R3 0         ;LNR the exited process state value
STMEM R0 R3        ;LNR set the state of the process to exit
JMBSI $int1        ;LNR absolute jump to $int1: to keep going    , @@end of interrupt #2@@
#-------- start of $int3 ----------------------------
SETRI R0 0         ;LNR=$int3: scheduler interrupt, the current process, the address where its pid is stored
LDMEM R0 R1        ;LNR R1 now has the pid of the process which was just interrupted
SETRI R2 20        ;LNR offset to get the process slot address from the process id
ADDRG R0 R1 R2     ;LNR R0 now contains the process slot address
SETRI R3 1         ;LNR the interrupted process new state value of readyToRun
STMEM R0 R3        ;LNR set the state of the process to readyToRun
JMBSI $int1        ;LNR absolute jump to $int1: to keep going    , @@end of interrupt #3@@
#-------- start of $int4 ----------------------------
# R2 contains the number of semop entries
# R3 contains the start address in process memory for the semop list ((semId,semOp),(semId,semOp),...)
SETRI R0 0         ;LNR=$int4: semop request for current process, the address where its pid is stored
LDMEM R0 R1        ;LNR R1 now has the pid of the process which is requesting a semop
SETRI R4 20        ;LNR offset to get the process slot address from the process id
ADDRG R0 R1 R4     ;LNR R0 now contains the process slot address
SETRI R6 3         ;LNR the SemWait state value
STMEM R0 R6        ;LNR change the process state to SemWait (address in R0)
SETRI R14 200      ;LNR the start of the proc sem waitlists address vect, one for each proc, (count,(semId,semOp),(semId,semOp),...)
ADDRG R14 R14 R1   ;LNR the start of the current proc sem waitlist address vect
LDMEM R14 R5       ;LNR now R5 contains the first address of the proc sem waitlists vect in kernel memory
STMEM R5 R2        ;LNR first we store the length, then we're going to go one by one to copy the R2 elements, starting with the first
SETRI R7 1         ;LNR constant increment
ADDRG R5 R5 R7     ;LNR=$semwcopy: advance R5 to the address of the first component of the current element of the proc sem waitlists
LDPRM R1 R3 R8     ;LNR read the first component of the first semop from process memory
STMEM R5 R8        ;LNR store the first component of the first semop in kernel memory
ADDRG R3 R3 R7     ;LNR advance R3 to the address of the second component of the current semop of the proc sem waitlists in proc memory
ADDRG R5 R5 R7     ;LNR advance R5 to the address of the second component of the current semop of the proc sem waitlists in kernel memory
LDPRM R1 R3 R8     ;LNR read the second component of the current semop from process memory
STMEM R5 R8        ;LNR store the second component of the current semop in kernel memory
ADDRG R3 R3 R7     ;LNR advance R3 to the address of the first component of the next semop (if any) of the proc sem waitlists in proc memory
SUBRG R2 R2 R7     ;LNR decrement the loop counter
JNZRI R2 $semwcopy ;LNR loop back to continue copying until done // boucle (l85-94) tant que R2 != 0
SETRI R15 100      ;LNR done, so now preparing the start address of the semaphore vector (where we keep the semaphore state values)
SETRI R13 0        ;LNR preparing for semoptest(0): we are first only testing
SETRI R5 1         ;LNR the frame width for the subroutine call
SETRI R16 $semoptest ;LNR the address of the start of the $semoptest sub
CLLSB R5 R16       ;LNR call to $semoptest(R13=0, R14=current proc semlist address, R15=semvect addr)
JZROI R16 $int1    ;LNR because it means we cannot apply the semops, so we need to elect another process , the current one will remain in SemWait for now
SETRI R13 1        ;LNR ok, ready to apply them
SETRI R5 1         ;LNR the frame width for the subroutine call
SETRI R16 $semoptest ;LNR the address of the start of the $semoptest sub
CLLSB R5 R16       ;LNR call to $semoptest(R13=1, R14=current proc semlist address, R15=semvect addr)
JZROI R16 $crash   ;LNR this should never ever happen
SETRI R6 2         ;LNR the Running state, for the ready process which we just found
STMEM R0 R6        ;LNR change the process state back to running (address in R0)
SETRI R6 20        ;LNR offset to get the process id from the process slot address
SUBRG R0 R0 R6     ;LNR get the process id in R0
SETRI R1 0         ;LNR address where the current proc id is stored
STMEM R1 R0        ;LNR store the (newly become) current proc id
LDPSW R0           ;LNR go on to execute proc of id R0  , @@end of interrupt #4@@
#-------- start of $int5 ----------------------------
# R2 contains the number of items to write
# R3 contains the start address in process memory where to read the items one by one
# R4 contains the start address in process memory where to read the item types one by one (0 for int, 1 for char)
/*SETRI R0 0         ;LNR=$int5: consoleOut request for current process, the address where its pid is stored
LDMEM R0 R1        ;LNR R1 now has the pid of the process which is requesting the consoleOut operation
SETRI R6 20        ;LNR offset to get the process slot address from the process id
ADDRG R0 R1 R6     ;LNR R0 now contains the process slot address
SETRI R5 1         ;LNR the readyToRun state
STMEM R0 R5        ;LNR store the readyToRun state for the current process
# Le processus courant est éligible (readyToRun)
SETRI R7 301       ;LNR The address in kernel memory where we need to write the # of items for the consoleOut
STMEM R7 R5        ;LNR just one item for now
LDPRM R1 R3 R6     ;LNR R6 now contains the first item to be obtained (read) and thus sent to consoleOut (recall R3 is given to us by the proc)
SETRI R8 304       ;LNR The address in kernel memory where we decided to write the item (copying it from the process memory)
STMEM R8 R6        ;LNR now writing the item (from R6) which we just read from the process memory a few lines above, at address 304 in kernel mem
SETRI R7 302       ;LNR The address in kernel memory where we need to write the start address (param) where to read the items for the consoleOut
STMEM R7 R8        ;LNR now effectively preparing the start address "parameter" for consoleOut (i.e. write the number '304' at address 302)
LDPRM R1 R4 R7     ;LNR R7 now contains the type of first item to be obtained (read) and thus sent to consoleOut
SETRI R8 404       ;LNR The address in kernel memory where we decided to write the item (copying it from the process memory)
STMEM R8 R7        ;LNR now writing the item type (from R7) which we just read from the process memory a few lines above, at address 404 in kernel mem
SETRI R7 303       ;LNR The address in kernel memory where we need to write the start address (param) where to read the item types for the consoleOut
STMEM R7 R8        ;LNR now effectively preparing the type vect start address "parameter" for consoleOut (i.e. write the number '404' at address 303)
SETRI R7 300       ;LNR The address in kernel memory where, by writing a value of 1, we trigger the consoleOut
STMEM R7 R5        ;LNR there we go -- we just requested a "hardware consoleOut" through "memory-mapping IO"
JMBSI $int1        ;LNR we are done, so we make an absolute jump to $int1: to keep going , @@end of interrupt #5@@
*/
SETRI R0 0         ;LNR=$int5: consoleOut request for current process, the address where its pid is stored
LDMEM R0 R1        ;LNR R1 now has the pid of the process which is requesting the consoleOut operation
SETRI R6 20        ;LNR offset to get the process slot address from the process id
ADDRG R0 R1 R6     ;LNR R0 now contains the process slot address
SETRI R5 1         ;LNR the readyToRun state
STMEM R0 R5        ;LNR store the readyToRun state for the current process
SETRI R7 301       ;LNR=$boucle on stocke la valeur 301 (qui sera une @) dans R7 (début boucle)
STMEM R7 R2        ;LNR on stocke la valeur R2 à R7, donc à l'@301, correspond au nombre d'items
LDPRM R1 R3 R6     ;LNR on charge R3 (@ du premier item) du processus R1 dans R6
SETRI R8 304       ;LNR on stocke la valeur 304 (qui sera une @, qui contiendra la valeur de l'item) dans R8
STMEM R8 R6        ;LNR on stocke la valeur de l'item à R6, donc à l'@304
SETRI R7 302       ;LNR on stocke la valeur 302 (qui sera une @, qui contiendra l'@ de l'item) dans R7
STMEM R7 R8        ;LNR on stocke la valeur 304 à R7, donc à l'@302
LDPRM R1 R4 R7     ;LNR on charge R4 (@ du type de l'item) du processus R1 pour récupérer la valeur du type (0:int/1:char) qu'on stocke dans R7
SETRI R8 404       ;LNR on stocke la valeur 404 (qui sera une @, qui contiendra l'@ du type de l'item) dans R8
STMEM R8 R7        ;LNR on stocke le type de l'item à R8, donc à l'@404
SETRI R7 303       ;LNR on stocke la valeur 303 (qui sera une @, qui contiendra l'@ du type de l'item) dans R7
STMEM R7 R8        ;LNR on stocke l'@ du type de l'item à R7, donc à l'@303
SETRI R7 300       ;LNR on stocke la valeur 300 (qui sera une @) dans R7
STMEM R7 R5        ;LNR on stocke la valeur 1 à R7, donc à l'@300, ce qui déclenche un consoleInOut.output()
ADDRG R3 R3 R5     ;LNR on incrémente R3 pour obtenir l'@ du deuxième item
ADDRG R4 R4 R5     ;LNR on incrémente R4 pour obtenir l'@ du type du deuxième item
SUBRG R9 R2 R5     ;LNR on décrémente le nombre d'items : R9 <- #items - 1
JNZRI R9 $boucle   ;LNR on boucle si R9 (nombre d'items) != 0
JMBSI $int1        ;LNR on retourne à int1
#-------- start of $int6 ----------------------------
SETRI R0 0         ;LNR=$int5: consoleOut request for current process, the address where its pid is stored
LDMEM R0 R1        ;LNR R1 now has the pid of the process which is requesting the consoleOut operation
SETRI R6 20        ;LNR offset to get the process slot address from the process id
ADDRG R0 R1 R6     ;LNR R0 now contains the process slot address
SETRI R5 1         ;LNR the readyToRun state
STMEM R0 R5        ;LNR store the readyToRun state for the current process
SETRI R9 0         ;LNR on stocke la valeur 0 (qui déclenchera input()) dans R
SETRI R7 301       ;LNR=$boucle on stocke la valeur 301 (qui sera une @) dans R7 (début boucle)
STMEM R7 R2        ;LNR on stocke la valeur R2 à R7, donc à l'@301, correspond au nombre d'items
LDPRM R1 R3 R6     ;LNR on charge R3 (@ du premier item) du processus R1 dans R6
SETRI R8 304       ;LNR on stocke la valeur 304 (qui sera une @, qui contiendra la valeur de l'item) dans R8
STMEM R8 R6        ;LNR on stocke la valeur de l'item à R6, donc à l'@304
SETRI R7 302       ;LNR on stocke la valeur 302 (qui sera une @, qui contiendra l'@ de l'item) dans R7
STMEM R7 R8        ;LNR on stocke la valeur 304 à R7, donc à l'@302
LDPRM R1 R4 R7     ;LNR on charge R4 (@ du type de l'item) du processus R1 pour récupérer la valeur du type (0:int/1:char) qu'on stocke dans R7
SETRI R8 404       ;LNR on stocke la valeur 404 (qui sera une @, qui contiendra l'@ du type de l'item) dans R8
STMEM R8 R7        ;LNR on stocke le type de l'item à R8, donc à l'@404
SETRI R7 303       ;LNR on stocke la valeur 303 (qui sera une @, qui contiendra l'@ du type de l'item) dans R7
STMEM R7 R8        ;LNR on stocke l'@ du type de l'item à R7, donc à l'@303
SETRI R7 300       ;LNR on stocke la valeur 300 (qui sera une @) dans R7
STMEM R7 R9        ;LNR on stocke la valeur 0 à R7, donc à l'@300 ce qui déclenche un consoleInOut.input()
ADDRG R3 R3 R5     ;LNR on incrémente R3 pour obtenir l'@ du deuxième item
ADDRG R4 R4 R5     ;LNR on incrémente R4 pour obtenir l'@ du type du deuxième item
SUBRG R9 R2 R5     ;LNR on décrémente le nombre d'items : R9 <- #items - 1
JNZRI R9 $boucle   ;LNR on boucle si R9 (nombre d'items) != 0
JMBSI $int1        ;LNR on retourne à int1
#======== start of initial kernel setup =============
SETRI R0 1         ;LNR=$prep: initial kernel setup, R0 constant increment/decrement value
SETRI R1 1         ;LNR address of first slot in the interrupt vector
SETRI R2 $int1     ;LNR prog address of $int1 start next available process
STMEM R1 R2        ;LNR setting up the interrupt vector for interrupt #1
ADDRG R1 R1 R0     ;LNR increment the address of slots
SETRI R2 $int2     ;LNR prog address of $int2: exit current process
STMEM R1 R2        ;LNR setting up the interrupt vector for interrupt #2
ADDRG R1 R1 R0     ;LNR increment the address of slots
SETRI R2 $int3     ;LNR prog address of $int3: scheduler interrupt
STMEM R1 R2        ;LNR setting up the interrupt vector for interrupt #3
ADDRG R1 R1 R0     ;LNR increment the address of slots
SETRI R2 $int4     ;LNR prog address of $int4: semop Request
STMEM R1 R2        ;LNR setting up the interrupt vector for interrupt #3
ADDRG R1 R1 R0     ;LNR increment the address of slots
SETRI R2 $int5     ;LNR address of $int5: consoleOut Request
STMEM R1 R2        ;LNR setting up the interrupt vector for interrupt #4
ADDRG R1 R1 R0     ;LNR increment the address of slots
SETRI R2 $int6     ;LNR address of $int6: consoleIn Request
STMEM R1 R2        ;LNR setting up the interrupt vector for interrupt #5
SETRI R1 21        ;LNR address where process table starts
SETRI R2 1         ;LNR ReadyToRun initial procstate value
GETI0 R3           ;LNR number of processes
SETRI R8 20        ;LNR address to save the number of processes
STMEM R8 R3        ;LNR saving the number of processes
ADDRG R9 R8 R0     ;LNR offset for the semwaitlists
SETRI R10 201      ;LNR the start of the proc sem waitlists address vect, one for each proc, (count,(semId,semOp),(semId,semOp),...)
ADDRG R7 R10 R8    ;LNR the first such address
STMEM R1 R2        ;LNR=$procSetup: set initial process state value to current slot
ADDRG R1 R1 R0     ;LNR advance address for process table slot
STMEM R10 R7       ;LNR setting the start address for the current proc sem waitlists in the master proc sem waitlists address vect
ADDRG R7 R7 R9     ;LNR increment the start address with the right offset
ADDRG R10 R10 R0   ;LNR advance address in the master proc sem waitlists address vect
SUBRG R3 R3 R0     ;LNR decrement loop counter
JNZRI R3 $procSetup ;LNR jump back to $procSetup: for max number processes
SETRI R0 0         ;LNR address where current scheduled proc id is stored
SETRI R1 0         ;LNR pid 0
STMEM R0 R1        ;LNR just to initialize the state of the system for int1
JMBSI $int1        ;LNR absolute jump to $int1: to start the work    , @@end of initial kernel setup@@
SDOWN              ;LNR=$crash:
#-------- start of $semoptest() ---------------------
#  input parameters (not modified in this procedure):
#    R13 if 0, just test, if 1, then go ahead and do it as well while sweeping through
#    R14 the address where we put the address of start of the semlist (starting with the # of elems, and then pairs (semIndex,semOpVal)
#    R15 the address of the semvect of the kernel (100)
#  output value:
#    R16 1 if it is possible to do all operations, 0 if not
#  uses locally (that is, modifies):
#    R17=counter,R18=semAddr,R19=semVal,R20=ct0,R21=semOpVal, R22<-[R14],modif
#- - - - - - - - - - - - - - - - - - - - - - - - - - -
SETRI R20 0        ;LNR the V() semop value (and V state value)
SETRI R16 1        ;LNR=$semoptest: can we indeed P() each sem we were waiting for ? (the V()'s will go through anyway)
LDMEM R14 R22      ;LNR R22 now contains the address where the current proc semwaitlist really starts
LDMEM R22 R17      ;LNR R17 contains the number of semops requested by the current proc (whatever that proc is)
ADDRG R22 R22 R16  ;LNR=$procsemtop: R22 contains the address of the current semaphore index
LDMEM R22 R18      ;LNR R18 contains the current semaphore index
ADDRG R18 R18 R15  ;LNR R18 now contains the address of the current semaphore
LDMEM R18 R19      ;LNR R19 contains the state value of the current semaphore
SUBRG R19 R19 R16  ;LNR prepare the test whether the current semaphore is in the P state (then R19 is going to be zero)
ADDRG R22 R22 R16  ;LNR R22 now contains the address of the current semop
LDMEM R22 R21      ;LNR R21 now contains the semop code for the current semaphore
SUBRG R21 R21 R16  ;LNR prepare the test whether the current semop code is P() (then R21 is going to be zero)
JNZRI R19 $maybeDoPorVonSemV ;LNR jump to $maybeDoPorVonSemV: if the current semaphore is in the V state
JNZRI R21 $maybeDoVonSemP ;LNR ok, the current semaphore is in P , now, jump to $maybeDoVonSemP: if the current semop code is V()
SETRI R16 0        ;LNR actually the current semop is P(), (and the current semaphore is in P) so we cannot do anything , we return with 0 in R16
SETRI R17 1        ;LNR the stack frame width -- we know its only 1
RETSB R17          ;LNR for any RETSB we need the R17=1 for the stack frame width
JZROI R13 $nextsem ;LNR=$maybeDoPorVonSemV: jump to $nextsem if we only need to examine and not also do it
JNZRI R21 $nextsem ;LNR jump to $nextsem: if the current semop code is V(), because V() on a semaphore in state V is a no-op
STMEM R18 R16      ;LNR ok, do P() on the semaphore (which was in state V) -- R18 had the address of the current semaphore
SUBRG R17 R17 R16  ;LNR=$nextsem: decrement semaphore loop counter
JNZRI R17 $procsemtop ;LNR jump to $procsemtop: if we have more semaphores to examine and perphaps operate upon
RETSB R16          ;LNR we are all done, we return with 1 in R16 (and use the fact that the stack frame width is also 1)
JZROI R13 $nextsem ;LNR=$maybeDoVonSemP: actually jump to $nextsem if we only need to examine and not also do it
STMEM R18 R27      ;LNR ok, do V() on the semaphore (which was in state P) -- R18 had the address of the current semaphore
JMTOI $nextsem     ;LNR jump to $nextsem:
#--------------------------------------
#101: semVectStart: each semaphore is one int ("mem cell"), its ID is its offset from 100,
#                  V() is zero, P() is one     , we store at 100 the max # of
#          semaphores (50)
#--------------------------------------
