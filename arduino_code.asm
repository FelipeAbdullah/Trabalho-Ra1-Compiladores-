; Código Assembly gerado para Arduino UNO
; Este código implementa as expressões RPN do arquivo de entrada

; Definições
.equ RAMEND, 0x08FF

; Inicialização
.global main
.section .text

; Inicialização
reset:
    ; Configurar pilha
    ldi r16, lo8(RAMEND)
    out SPL, r16
    ldi r16, hi8(RAMEND)
    out SPH, r16

; Memória para comando (MEM)
.section .data
memory: .space 2    ; 2 bytes para half-precision float
results: .space 20   ; Espaço para armazenar 10 resultados (2 bytes cada)

.section .text
main:
    ; Código principal
    ; Expressão da linha 1: (5 3 +)
expression_1:
    ; Operação de adição
    ldi r16, 5     ; Carrega primeiro operando
    ldi r17, 3     ; Carrega segundo operando
    add r16, r17   ; Soma
    sts memory, r16 ; Armazena resultado
    
    ; Expressão da linha 2: (10 2 -)
expression_2:
    ; Operação de subtração
    ldi r16, 10    ; Carrega primeiro operando
    ldi r17, 2     ; Carrega segundo operando
    sub r16, r17   ; Subtrai
    sts memory+1, r16 ; Armazena resultado
    
    ; Expressão da linha 3: (4 3 *)
expression_3:
    ; Operação de multiplicação
    ldi r16, 4     ; Carrega primeiro operando
    ldi r17, 3     ; Carrega segundo operando
    mul r16, r17   ; Multiplica
    sts memory+2, r0 ; Armazena resultado (parte baixa)
    
    ; Expressão da linha 4: (8 2 /)
expression_4:
    ; Operação de divisão (simplificada)
    ldi r16, 8     ; Carrega primeiro operando
    ldi r17, 2     ; Carrega segundo operando
    ldi r18, 0     ; Inicializa resultado
div_loop:
    cp r16, r17    ; Compara r16 com r17
    brlt div_end   ; Se r16 < r17, termina
    sub r16, r17   ; r16 = r16 - r17
    inc r18        ; Incrementa o resultado
    rjmp div_loop  ; Continua divisão
div_end:
    sts memory+3, r18 ; Armazena resultado

end:
    rjmp end    ; Loop infinito
