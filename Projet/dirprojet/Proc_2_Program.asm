SETRI R0 0    ; index of first (and unique) semaphore                         // R0 <- 0
SETRI R2 1    ; code of P(), and also count of semop()s                       // R2 <- 1
SETRI R3 215      ; address for the P() semop                                 // R3 <- 215
STMEM R3 R0   ; store the index of the semaphore to operate on                // mem[R3] <- R0
ADDRG R3 R3 R2    ; advance the address                                       // R3 <- R3 + R2 = 215 + 1 = 216
STMEM R3 R2   ; store the P() operation code                                  // mem[R3] <- R2 = 1
SETRI R3 225      ; address for the V() semop                                 // R3 <- 225
STMEM R3 R0   ; store the index of the semaphore to operate on                // mem[R3] <- R0 = 0
ADDRG R3 R3 R2    ; advance the address                                       // R3 <- R3 + R2 = 225 + 1 = 256
STMEM R3 R0       ; store the V() operation code                              // mem[R3] <- R0 = 0
SETRI R5 10   ; shared memory address (agreed upon with the other proc)       // R5 <- 10
SETRI R4 4    ; int number for semop() request, that is int4                  // R4 <- 4
SETRI R6 65   ; value to write in shared memory                               // R6 <- 65
SETRI R3 215      ; set address for the P() semop                             // R3 <- 215
CLINT R4      ; P() the semaphore                                             // appel de l'int 4
STSHM R5 R6   ; store the value in the shared memory                          // sharedMem[R5] <- R6
SETRI R3 225      ; set address for the V() semop                             // R3 <- 255
CLINT R4      ; V() the semaphore                                             // appel de l'int 4 (semaphore)
SETRI R9 2        ; int number for exit()                                     // R9 <- 2
CLINT R9          ; kernel int2 exits the process                             // appel de l'int 2 (exit())
