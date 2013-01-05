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
SETRI R3 210      ; waitLoop, set address for the P() semop      (loop start)// R3 <- 210
CLINT R4          ; P() the semaphore                            (bloque)    // appel de l'int 4
LDSHM R5 R6       ; read the shared memory value                             // R6 <- sharedMem[R5]
SETRI R3 220      ; set address for the V() semop                            // R3 <- 200
CLINT R4          ; V() the semaphore                            (debloque)  // appel de l'int 4
JZROI R6 -6       ; jump back to waitLoop(l13) if the value read from shmem is zero  //if(R6 == 0)
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


# Commentaires français

                # SETRI R0 0        ; on récupère la semaphore
                # SETRI R2 1        ; on stocke la valeur 1 dans R2, correspond à la fois le code de P() et le nombre de semops
                # SETRI R3 210      ; on stocke la valeur 210 (qui sera une @) dans R3
                # STMEM R3 R0       ; on stocke la valeur 0 à R3, donc à l'@210
                # ADDRG R3 R3 R2    ; on stocke la valeur 210+1=211 (qui sera une @) dans R3
                # STMEM R3 R2       ; on stocke la valeur 1 à R3, donc à l'@211
                # SETRI R3 220      ; on stocke la valeur 220 (qui sera une @) dans R3
                # STMEM R3 R0       ; on stocke la valeur 0 à R3 donc à l'@220
                # ADDRG R3 R3 R2    ; on stocke la valeur 220+1=221 (qui sera une @) dans R3
                # STMEM R3 R0       ; on stocke la valeur 0 à R3, donc à l'@221
                # SETRI R5 10       ; on stocke la valeur 10 (@ de la mémoire partagée) dans R5
                # SETRI R4 4        ; on stocke la valeur 4 dans R4, correspond à int4
                # SETRI R3 210      ; on stocke la valeur 210 (qui sera une @, pour la semop P()) dans R3
#              /# CLINT R4          ; on appelle int4, donc P()
#     Zone    / # LDSHM R5 R6       ; on charge la valeur de la mémoire partagée dans R6, donc R6 = 65 (valeur de l'@10 de la mémoire partagée) ## <- intervention mémoire partagée (chargement) ##
#   Critique  \ # SETRI R3 220      ; on stocke la valeur 220 (qui sera une @, pour la semop V()) dans R3
#              \# CLINT R4          ; on appelle int4 à nouveau, donc V()
                # JZROI R6 -6       ; si R6=0, alors on boucle à la ligne 45 (pour pouvoir rentrer à nouveau en zone critique) le -6, signifie retour de 6 lignes en arrière, cette ligne incluse.
                # SETRI R3 300      ; on stocke la valeur 300 (qui sera une @, CONSOLEI/OTRIGGER) dans R3
                # STMEM R3 R6       ; on stocke la valeur de la mémoire partagée (65) à R3, donc à l'@300                                       ## <- intervention mémoire partagée ##
                # SETRI R4 380      ; on stocke la valeur 380 (qui sera une @) dans R4
                # SETRI R1 1        ; on stocke la valeur 1 dans R1, correspond au type de l'item (char en l'occurrence)
                # STMEM R4 R1       ; on stocke la valeur 1 à R4, donc le type à l'@380
                # SETRI R2 1        ; on stocke la valeur 1 dans R2, correspond au nombre d'items (1 seul)
                # SETRI R0 5        ; on stocke la valeur 5 dans R0, correspond à la valeur de l'interruption : int5
                # CLINT R0          ; on appelle int5
                # SETRI R9 2        ; on stocke la valeur 2 dans R9, correspond à la valeur de l'interruption : int2
                # CLINT R9          ; on appelle int2

SETRI R0 0        ; on récupère le semaphore
SETRI R2 1        ; on stocke la valeur 1 dans R2, correspond à la fois le code de P() et le nombre de semops
SETRI R3 210      ; on stocke la valeur 210 (qui sera une @) dans R3
STMEM R3 R0       ; on stocke la valeur 0 à R3, donc à l'@210
ADDRG R3 R3 R2    ; on stocke la valeur 210+1=211 (qui sera une @) dans R3
STMEM R3 R2       ; on stocke la valeur 1 à R3, donc à l'@211
SETRI R3 220      ; on stocke la valeur 220 (qui sera une @) dans R3
STMEM R3 R0       ; on stocke la valeur 0 à R3 donc à l'@220
ADDRG R3 R3 R2    ; on stocke la valeur 220+1=221 (qui sera une @) dans R3
STMEM R3 R0       ; on stocke la valeur 0 à R3, donc à l'@221
SETRI R5 10       ; on stocke la valeur 10 (@ de la mémoire partagée) dans R5
SETRI R4 4        ; on stocke la valeur 4 dans R4, correspond à int4
SETRI R3 210      ; on stocke la valeur 210 (qui sera une @, pour la semop P()) dans R3
CLINT R4          ; on appelle int4, donc P()
LDSHM R5 R6       ; on charge la valeur de la mémoire partagée dans R6, donc R6 = 65 (au début, valeur de l'@10 de la mémoire partagée)
SETRI R3 220      ; on stocke la valeur 220 (qui sera une @, pour la semop V()) dans R3
CLINT R4          ; on appelle int4 à nouveau, donc V()
ADDRG R5 R5 R2    ; on incrémente la valeur de R5 (qui contient les @ de la mémoire partagée)
JZROI R6 -7       ; si R6=0, alors on boucle (pour pouvoir rentrer à nouveau en zone critique) le -7, signifie retour de 7 lignes en arrière, cette ligne incluse.
SETRI R3 300      ; on stocke la valeur 300 (qui sera une @, CONSOLEI/OTRIGGER) dans R3
STMEM R3 R6       ; on stocke la valeur de la mémoire partagée (65) à R3, donc à l'@300
SETRI R4 380      ; on stocke la valeur 380 (qui sera une @) dans R4
SETRI R1 1        ; on stocke la valeur 1 dans R1, correspond au type de l'item (char en l'occurrence)
STMEM R4 R1       ; on stocke la valeur 1 à R4, donc le type à l'@380
SETRI R2 1        ; on stocke la valeur 1 dans R2, correspond au nombre d'items (1 seul)
SETRI R0 5        ; on stocke la valeur 5 dans R0, correspond à la valeur de l'interruption : int5
CLINT R0          ; on appelle int5
SETRI R9 2        ; on stocke la valeur 2 dans R9, correspond à la valeur de l'interruption : int2
CLINT R9          ; on appelle int2
