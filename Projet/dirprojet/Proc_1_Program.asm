SETRI R0 0        ; index of first (and unique) semaphore                    // R0 <- 0
SETRI R2 1        ; code of P(), and also count of semop()s                  // R2 <- 1
SETRI R3 210      ; address for the P() semop                                // R3 <- 210
STMEM R3 R0       ; store the index of the semaphore to operate on           // mem[R3] <- R0 <- 0
ADDRG R3 R3 R2    ; advance the address                                      // R3 <- R3 + R2 <- 210 + 1 = 211
STMEM R3 R2       ; store the P() operation code                             // mem[R3] <- R2  <- 1
SETRI R3 220      ; address for the V() semop                                // R3 <- 300
STMEM R3 R0       ; store the index of the semaphore to operate on           // mem[R3] <- R0 <- 0
ADDRG R3 R3 R2    ; advance the address                                      // R3 <- R3 + R2
STMEM R3 R0       ; store the V() operation code                             // mem[R3] <- R0 <- 0
SETRI R5 10       ; shared memory address (agreed upon with the other proc)  // R5 <- 10
SETRI R4 4        ; int number for semop() request, that is int4             // R4 <- 4
SETRI R3 210      ; waitLoop, set address for the P() semop                  // R3 <- 210
CLINT R4          ; P() the semaphore                                        // appel de l'int 4
LDSHM R5 R6       ; read the shared memory value                             // R6 <- sharedMem[R5]
SETRI R3 220      ; set address for the V() semop                            // R3 <- 200
CLINT R4          ; V() the semaphore                                        // appel de l'int 4
JZROI R6 -6       ; jump back to waitLoop(l13) if the value read from shmem is zero  //if(R6 == 0) { PC <- PC-6}
SETRI R3 300      ; some address in process memory                           // R3 <- 300
STMEM R3 R6       ; store the value read from shared memory at that address in proc mem // mem[R3] <- R6
SETRI R4 380      ; some other address in process memory, for the "format"   // R4 <- 380
SETRI R1 1        ; type char                                                // R1 <- 1
STMEM R4 R1       ; store the type value                                     // mem[R4] <- R1 <- 1
SETRI R2 1        ; how many elements -- just one                            // R2 <- 1
SETRI R0 5        ; int number for consoleOut request                        // R0 <- 5
CLINT R0          ; call interruption int5 for kernel consoleOut             // appel de l'int 5
SETRI R9 2        ; int number for exit()                                    // R9 <- 2
CLINT R9          ; kernel int2 exits the process                            // appel de l'int 2
