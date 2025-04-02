; Código Assembly gerado para Arduino UNO
; Este código implementa as expressões RPN do arquivo de entrada

.include "m328pdef.inc"

; Inicialização
setup:
    ; Configuração inicial do Arduino
    ; Seria implementado o código para inicializar registradores, etc.

; Memória para comando (MEM)
    .dseg
memory: .byte 2    ; 2 bytes para half-precision float
results: .byte 20   ; Espaço para armazenar 10 resultados (2 bytes cada)
    .cseg

main:
    ; Código principal
    ; Expressão da linha 1: (5 3 +)
expression_1:
    ; Operação de adição
    ld r16, X+    ; Carrega primeiro operando
    ld r17, X+    ; Carrega segundo operando
    add r16, r17  ; Soma
    st X+, r16    ; Armazena resultado
    ; Expressão da linha 2: (10 2 -)
expression_2:
    ; Operação de subtração
    ld r16, X+    ; Carrega primeiro operando
    ld r17, X+    ; Carrega segundo operando
    sub r16, r17  ; Subtrai
    st X+, r16    ; Armazena resultado
    ; Expressão da linha 3: (4 3 *)
expression_3:
    ; Operação de multiplicação
    ld r16, X+    ; Carrega primeiro operando
    ld r17, X+    ; Carrega segundo operando
    mul r16, r17  ; Multiplica
    movw r16, r0  ; Move resultado para r16:r17
    st X+, r16    ; Armazena resultado
    ; Expressão da linha 4: (8 2 |)
expression_4:
    ; Expressão da linha 5: (9 2 /)
expression_5:
    ; Expressão da linha 6: (10 3 %)
expression_6:
    ; Expressão da linha 7: (2 3 ^)
expression_7:
    ; Expressão da linha 8: (5.5 2.5 +)
expression_8:
    ; Operação de adição
    ld r16, X+    ; Carrega primeiro operando
    ld r17, X+    ; Carrega segundo operando
    add r16, r17  ; Soma
    st X+, r16    ; Armazena resultado
    ; Expressão da linha 9: (3 (2 4 +) *)
expression_9:
    ; Operação de adição
    ld r16, X+    ; Carrega primeiro operando
    ld r17, X+    ; Carrega segundo operando
    add r16, r17  ; Soma
    st X+, r16    ; Armazena resultado
    ; Expressão da linha 10: ((5 2 -) (3 1 +) *)
expression_10:
    ; Operação de adição
    ld r16, X+    ; Carrega primeiro operando
    ld r17, X+    ; Carrega segundo operando
    add r16, r17  ; Soma
    st X+, r16    ; Armazena resultado
    ; Expressão da linha 11: (10 MEM)
expression_11:
    ; Expressão da linha 12: (MEM)
expression_12:
    ; Expressão da linha 13: (2 RES)
expression_13:
    ; Expressão da linha 14: ((1 RES) (MEM) +)
expression_14:
    ; Operação de adição
    ld r16, X+    ; Carrega primeiro operando
    ld r17, X+    ; Carrega segundo operando
    add r16, r17  ; Soma
    st X+, r16    ; Armazena resultado
    ; Expressão da linha 15: (7 (3 2 *) (1 5 +) + +)
expression_15:
    ; Operação de adição
    ld r16, X+    ; Carrega primeiro operando
    ld r17, X+    ; Carrega segundo operando
    add r16, r17  ; Soma
    st X+, r16    ; Armazena resultado

end:
    rjmp end    ; Loop infinito
