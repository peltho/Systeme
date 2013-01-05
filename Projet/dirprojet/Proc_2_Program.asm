/*
SETRI R0 0        ; index of first (and unique) semaphore                     // R0 <- 0
SETRI R2 1        ; code of P(), and also count of semop()s                   // R2 <- 1
SETRI R3 215      ; address for the P() semop                                 // R3 <- 215
STMEM R3 R0       ; store the index of the semaphore to operate on            // mem[R3] <- R0
ADDRG R3 R3 R2    ; advance the address                                       // R3 <- R3 + R2 = 215 + 1 = 216
STMEM R3 R2       ; store the P() operation code                              // mem[R3] <- R2 = 1
SETRI R3 225      ; address for the V() semop                                 // R3 <- 225
STMEM R3 R0       ; store the index of the semaphore to operate on            // mem[R3] <- R0 = 0
ADDRG R3 R3 R2    ; advance the address                                       // R3 <- R3 + R2 = 225 + 1 = 256
STMEM R3 R0       ; store the V() operation code                              // mem[R3] <- R0 = 0
SETRI R5 10       ; shared memory address (agreed upon with the other proc)   // R5 <- 10
SETRI R4 4        ; int number for semop() request, that is int4              // R4 <- 4
SETRI R6 65       ; value to write in shared memory                           // R6 <- 65
SETRI R3 215      ; set address for the P() semop                             // R3 <- 215
CLINT R4          ; P() the semaphore                                         // appel de l'int 4
STSHM R5 R6       ; store the value in the shared memory                      // sharedMem[R5] <- R6
SETRI R3 225      ; set address for the V() semop                             // R3 <- 255
CLINT R4          ; V() the semaphore                                         // appel de l'int 4 (semaphore)
SETRI R9 2        ; int number for exit()                                     // R9 <- 2
CLINT R9          ; kernel int2 exits the process                             // appel de l'int 2 (exit())
*/

# Commentaires français

# SETRI R0 0        ; on récupère la sémaphore
# SETRI R2 1        ; on stocke la valeur 1 dans R2, correspond à la fois au code de P() et au nombre de semops
# SETRI R3 215      ; on stocke la valeur 215 (qui sera une @) dans R3
# STMEM R3 R0       ; on stocke la valeur 0 (index de la semaphore) à R3, donc à l'@215
# ADDRG R3 R3 R2    ; R3 contient l'@215+1, donc l'@216
# STMEM R3 R2       ; on stocke la valeur 1 (code de P()) à R3, donc à l'@216
# SETRI R3 225      ; on stocke la valeur 225 (qui sera une @) dans R3
# STMEM R3 R0       ; on stocke la valeur 0 (index de la semaphore) à R3, donc à l'@225
# ADDRG R3 R3 R2    ; R3 contient l'@225+1, donc l'@226
# STMEM R3 R0       ; on stocke la valeur 0 (code de V()) à R3, donc à l'@226
# SETRI R5 10       ; on stocke la valeur 10 (qui sera une @) dans R5, correspond à l'@ de la mémoire partagée
# SETRI R4 4        ; on stocke la valeur 4 dans R4, correspond à l'int4
# SETRI R6 65       ; on stocke la valeur 65 dans R6, correspond à la valeur à écrire dans la mémoire partagée
# SETRI R3 215      ; on stocke la valeur 215 (qui sera une @, celle de P()) dans R3
# CLINT R4          ; on appelle int4, donc P()
# STSHM R5 R6       ; on stocke la valeur 65 à R5, donc à l'@10 de la mémoire partagée    ## <- intervention mémoire partagée (stockage) ##
# SETRI R3 225      ; on stocke la valeur 225 (qui sera une @, celle de V()) dans R3
# CLINT R4          ; on appelle int4 à nouveau, donc V()
# SETRI R9 2        ; on stocke la valeur 2 dans R9, correspond à int2
# CLINT R9          ; on appelle int2, ce qui termine le processus

SETRI R0 0        ; on récupère la sémaphore
SETRI R2 1        ; on stocke la valeur 1 dans R2, correspond à la fois au code de P() et au nombre de semops
SETRI R3 215      ; on stocke la valeur 215 (qui sera une @) dans R3
STMEM R3 R0       ; on stocke la valeur 0 (index de la semaphore) à R3, donc à l'@215
ADDRG R3 R3 R2    ; R3 contient l'@215+1, donc l'@216
STMEM R3 R2       ; on stocke la valeur 1 (code de P()) à R3, donc à l'@216
SETRI R3 225      ; on stocke la valeur 225 (qui sera une @) dans R3
STMEM R3 R0       ; on stocke la valeur 0 (index de la semaphore) à R3, donc à l'@225
ADDRG R3 R3 R2    ; R3 contient l'@225+1, donc l'@226
STMEM R3 R0       ; on stocke la valeur 0 (code de V()) à R3, donc à l'@226
SETRI R5 10       ;LNR on stocke la valeur 10 (qui sera une @) dans R5, correspond à l'@ de la mémoire partagée
SETRI R4 4        ;LNR on stocke la valeur 4 dans R4, correspond à l'int4
SETRI R6 65       ;LNR on stocke la valeur 65 dans R6, correspond à la valeur à écrire dans la mémoire partagée
SETRI R3 215      ;LNR on stocke la valeur 215 (qui sera une @, celle de P()) dans R3
CLINT R4          ;LNR on appelle int4, donc P()
STSHM R5 R6       ;LNR on stocke la valeur 65 à R5, donc à l'@10 de la mémoire partagée
SETRI R3 225      ;LNR on stocke la valeur 225 (qui sera une @, celle de V()) dans R3
CLINT R4          ;LNR on appelle int4 à nouveau, donc V()
SETRI R10 10      ;LNR compteur initialisé à 10
SETRI R7 11       ;LNR première @ (de la mem partagée) stockée dans R7
SETRI R8 1        ;LNR première valeur à écrire, stockée dans R8
SETRI R3 215      ;LNR=$boucle on stocke la valeur 215 (qui sera une @, celle de P()) dans R3
CLINT R4          ;LNR on appelle int4, donc P()
STSHM R8 R7       ;LNR on stocke la première valeur (1) dans la première @ (11)
SETRI R3 225      ;LNR on stocke la valeur 225 (qui sera une @, celle de V()) dans R3
CLINT R4          ;LNR on appelle int4 à nouveau, donc V()
ADDRG R7 R7 R2    ;LNR on incrémente les @ (R7 <- 11+1)
ADDRG R8 R8 R2    ;LNR on incrémente les valeurs (R8 <- 1+1)
SUBRG R10 R2      ;LNR on décrémente le compteur
JNZRI R10 $boucle ;LNR si R10 != 0, on boucle
SETRI R9 2        ;LNR on stocke la valeur 2 dans R9, correspond à int2
CLINT R9          ;LNR on appelle int2, ce qui termine le processus
