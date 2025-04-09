; Código Assembly para Arduino com saída serial
; Este código executa operações RPN e envia resultados via serial

; Definições
.equ RAMEND, 0x08FF
.equ BAUD_RATE, 9600
.equ F_CPU, 16000000  ; Frequência do Arduino UNO

; Constantes para configuração serial
.equ UBRR_VALUE, F_CPU/16/BAUD_RATE-1

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

    ; Configurar UART (comunicação serial)
    ldi r16, lo8(UBRR_VALUE)  ; Baixo byte da taxa de transmissão
    sts UBRR0L, r16
    ldi r16, hi8(UBRR_VALUE)  ; Alto byte da taxa de transmissão
    sts UBRR0H, r16
    
    ; Habilitar transmissor
    ldi r16, (1<<TXEN0)
    sts UCSR0B, r16
    
    ; Configurar formato: 8 bits de dados, 1 bit de parada, sem paridade
    ldi r16, (1<<UCSZ01)|(1<<UCSZ00)
    sts UCSR0C, r16

; Memória para comando (MEM)
.section .data
memory: .space 2    ; 2 bytes para half-precision float
results: .space 20   ; Espaço para armazenar 10 resultados (2 bytes cada)

.section .text
main:
    ; Código principal com envio dos resultados via serial
    rcall print_header

    ; Expressão 1: (5 3 +)
    ldi r16, 5     ; Carrega primeiro operando
    ldi r17, 3     ; Carrega segundo operando
    add r16, r17   ; Soma
    sts memory, r16 ; Armazena resultado
    
    ; Envia resultado pela serial
    ldi r19, '1'   ; Identificador da expressão
    rcall print_result
    
    ; Expressão 2: (10 2 -)
    ldi r16, 10    ; Carrega primeiro operando
    ldi r17, 2     ; Carrega segundo operando
    sub r16, r17   ; Subtrai
    sts memory+1, r16 ; Armazena resultado
    
    ; Envia resultado pela serial
    ldi r19, '2'   ; Identificador da expressão
    rcall print_result
    
    ; Expressão 3: (4 3 *)
    ldi r16, 4     ; Carrega primeiro operando
    ldi r17, 3     ; Carrega segundo operando
    mul r16, r17   ; Multiplica
    mov r16, r0    ; Move resultado para r16
    sts memory+2, r16 ; Armazena resultado
    
    ; Envia resultado pela serial
    ldi r19, '3'   ; Identificador da expressão
    rcall print_result
    
    ; Expressão 4: (8 2 /)
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
    mov r16, r18   ; Move resultado para r16
    sts memory+3, r16 ; Armazena resultado
    
    ; Envia resultado pela serial
    ldi r19, '4'   ; Identificador da expressão
    rcall print_result

    rcall print_done

end:
    rjmp end    ; Loop infinito

; Rotina para imprimir cabeçalho
print_header:
    ldi r16, 'R'
    rcall uart_send
    ldi r16, 'P'
    rcall uart_send
    ldi r16, 'N'
    rcall uart_send
    ldi r16, ' '
    rcall uart_send
    ldi r16, 'T'
    rcall uart_send
    ldi r16, 'e'
    rcall uart_send
    ldi r16, 's'
    rcall uart_send
    ldi r16, 't'
    rcall uart_send
    ldi r16, ':'
    rcall uart_send
    ldi r16, 13    ; CR
    rcall uart_send
    ldi r16, 10    ; LF
    rcall uart_send
    ret

; Rotina para imprimir resultado
print_result:
    ; Salva r16 (resultado)
    push r16
    
    ; Imprime "Expr. N: "
    ldi r16, 'E'
    rcall uart_send
    ldi r16, 'x'
    rcall uart_send
    ldi r16, 'p'
    rcall uart_send
    ldi r16, 'r'
    rcall uart_send
    ldi r16, '.'
    rcall uart_send
    ldi r16, ' '
    rcall uart_send
    mov r16, r19   ; Identificador da expressão
    rcall uart_send
    ldi r16, ':'
    rcall uart_send
    ldi r16, ' '
    rcall uart_send
    
    ; Recupera r16 (resultado)
    pop r16
    
    ; Converte valor numérico para ASCII e imprime
    rcall print_number
    
    ; Nova linha
    ldi r16, 13    ; CR
    rcall uart_send
    ldi r16, 10    ; LF
    rcall uart_send
    ret

; Rotina para imprimir conclusão
print_done:
    ldi r16, 'T'
    rcall uart_send
    ldi r16, 'e'
    rcall uart_send
    ldi r16, 's'
    rcall uart_send
    ldi r16, 't'
    rcall uart_send
    ldi r16, ' '
    rcall uart_send
    ldi r16, 'C'
    rcall uart_send
    ldi r16, 'o'
    rcall uart_send
    ldi r16, 'm'
    rcall uart_send
    ldi r16, 'p'
    rcall uart_send
    ldi r16, 'l'
    rcall uart_send
    ldi r16, 'e'
    rcall uart_send
    ldi r16, 't'
    rcall uart_send
    ldi r16, 'e'
    rcall uart_send
    ldi r16, '!'
    rcall uart_send
    ldi r16, 13    ; CR
    rcall uart_send
    ldi r16, 10    ; LF
    rcall uart_send
    ret

; Rotina para imprimir um número
print_number:
    ; Se número for 0, imprimir "0" e retornar
    cpi r16, 0
    brne not_zero
    ldi r16, '0'
    rcall uart_send
    ret
    
not_zero:
    ; Converte número para decimal ASCII
    ; Para simplificar, limitado a números 0-99
    push r17       ; Salva r17
    
    ; Para números > 9, precisamos separar dígitos
    cpi r16, 10
    brlt single_digit
    
    ; Divide por 10 para obter dezenas
    ldi r17, 10
    mov r18, r16
    ldi r16, 0
div10:
    cp r18, r17
    brlt div10_done
    sub r18, r17
    inc r16
    rjmp div10
div10_done:
    ; r16 contém dezenas, r18 contém unidades
    
    ; Imprime dezenas
    subi r16, -'0'  ; Converte para ASCII
    rcall uart_send
    
    ; Imprime unidades
    mov r16, r18
    subi r16, -'0'  ; Converte para ASCII
    rcall uart_send
    
    pop r17         ; Restaura r17
    ret
    
single_digit:
    ; Converte para ASCII e imprime
    subi r16, -'0'  ; Converte para ASCII
    rcall uart_send
    
    pop r17         ; Restaura r17
    ret

; Rotina para enviar byte pela UART
uart_send:
    ; Espera até que o buffer de transmissão esteja vazio
uart_wait:
    lds r17, UCSR0A
    sbrs r17, UDRE0
    rjmp uart_wait
    
    ; Envia o byte
    sts UDR0, r16
    ret
