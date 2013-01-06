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
