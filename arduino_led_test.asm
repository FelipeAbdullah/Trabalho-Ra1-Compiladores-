; Código Assembly para Arduino com feedback visual via LED
; Este código executa operações RPN e usa o LED para indicar execução

; Definições
.equ RAMEND, 0x08FF
.equ PORTB, 0x25  ; Endereço do PORT B no ATmega328p
.equ DDRB, 0x24   ; Endereço do Data Direction Register B
.equ LED_PIN, 5   ; Pino 13 é PB5 no Arduino Uno

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

    ; Configurar LED como saída
    ldi r16, (1<<LED_PIN)
    out DDRB, r16
    
    ; Blink inicial (sinal de início)
    rcall blink_led
    rcall delay
    rcall blink_led
    rcall delay

; Memória para comando (MEM)
.section .data
memory: .space 2    ; 2 bytes para half-precision float
results: .space 20   ; Espaço para armazenar 10 resultados (2 bytes cada)

.section .text
main:
    ; Expressão 1: (5 3 +) = 8
    ldi r16, 5     ; Carrega primeiro operando
    ldi r17, 3     ; Carrega segundo operando
    add r16, r17   ; Soma
    sts memory, r16 ; Armazena resultado
    
    ; Verifica se resultado é correto (8)
    cpi r16, 8
    brne error
    rcall blink_led ; Pisca LED se correto
    rcall delay
    
    ; Expressão 2: (10 2 -) = 8
    ldi r16, 10    ; Carrega primeiro operando
    ldi r17, 2     ; Carrega segundo operando
    sub r16, r17   ; Subtrai
    sts memory+1, r16 ; Armazena resultado
    
    ; Verifica se resultado é correto (8)
    cpi r16, 8
    brne error
    rcall blink_led ; Pisca LED se correto
    rcall delay
    
    ; Expressão 3: (4 3 *) = 12
    ldi r16, 4     ; Carrega primeiro operando
    ldi r17, 3     ; Carrega segundo operando
    mul r16, r17   ; Multiplica
    mov r16, r0    ; Move resultado para r16
    sts memory+2, r16 ; Armazena resultado
    
    ; Verifica se resultado é correto (12)
    cpi r16, 12
    brne error
    rcall blink_led ; Pisca LED se correto
    rcall delay
    
    ; Expressão 4: (8 2 /) = 4
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
    
    ; Verifica se resultado é correto (4)
    cpi r16, 4
    brne error
    rcall blink_led ; Pisca LED se correto
    rcall delay
    
    ; Todos os testes passaram, pisca LED rapidamente 5 vezes
    rcall success
    rjmp end

error:
    ; LED fica aceso continuamente para indicar erro
    ldi r16, (1<<LED_PIN)
    out PORTB, r16
    rjmp end

success:
    ; Pisca rápido 5 vezes para indicar sucesso
    ldi r20, 5     ; Contador de piscadas
success_loop:
    rcall blink_led_fast
    rcall delay_short
    dec r20
    brne success_loop
    ret

end:
    rjmp end    ; Loop infinito

; Rotina para piscar o LED
blink_led:
    ldi r16, (1<<LED_PIN)
    out PORTB, r16     ; Acende LED
    rcall delay_short
    ldi r16, 0
    out PORTB, r16     ; Apaga LED
    ret

; Rotina para piscar o LED rapidamente
blink_led_fast:
    ldi r16, (1<<LED_PIN)
    out PORTB, r16     ; Acende LED
    rcall delay_very_short
    ldi r16, 0
    out PORTB, r16     ; Apaga LED
    ret

; Rotina de atraso longo
delay:
    ldi r22, 20
outer_loop:
    ldi r21, 255
middle_loop:
    ldi r20, 255
inner_loop:
    dec r20
    brne inner_loop
    dec r21
    brne middle_loop
    dec r22
    brne outer_loop
    ret

; Rotina de atraso curto
delay_short:
    ldi r21, 255
delay_short_loop1:
    ldi r20, 255
delay_short_loop2:
    dec r20
    brne delay_short_loop2
    dec r21
    brne delay_short_loop1
    ret

; Rotina de atraso muito curto
delay_very_short:
    ldi r20, 255
delay_very_short_loop:
    dec r20
    brne delay_very_short_loop
    ret
