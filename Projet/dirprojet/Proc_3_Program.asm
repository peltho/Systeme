SETRI R3 350    ; on stocke la valeur 350 (qui sera une @) dans R3
SETRI R1 20     ; on stocke la valeur 20 dans R1
STMEM R3 R1     ; on stocke la valeur 20 à R3, donc à l'@350
SETRI R4 380    ; on stocke la valeur 380 (qui sera une @) dans R4
SETRI R1 0      ; on stocke la valeur 0 dans R1
STMEM R4 R1     ; on stocke la valeur 0 à R4, donc à l'@380
SETRI R2 1      ; on stocke la valeur 1 dans R2
SETRI R0 5      ; on stocke la valeur 5 dans R0, correspond à int5
CLINT R0        ; kernel int5 consoleOut
SETRI R6 2      ; on stocke la valeur 2 dans R6, correspond à int2
CLINT R6        ; kernel int2 exits the process
