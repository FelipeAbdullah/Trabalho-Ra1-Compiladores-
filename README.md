# Calculadora RPN (Notação Polonesa Reversa)

Este projeto implementa uma calculadora que avalia expressões aritméticas escritas em notação polonesa reversa (RPN), também conhecida como notação pós-fixa. O programa é capaz de ler expressões de um arquivo de texto, avaliá-las e também gerar código Assembly para execução em um Arduino Uno.

## Sumário
- [Descrição do Projeto](#descrição-do-projeto)
- [Funcionalidades](#funcionalidades)
- [Estrutura do Código](#estrutura-do-código)
- [Como Executar](#como-executar)
- [Notação RPN Explicada](#notação-rpn-explicada)
- [Comandos Especiais](#comandos-especiais)
- [Exemplos Práticos](#exemplos-práticos)
- [Geração de Código Assembly](#geração-de-código-assembly)
- [Configuração do Arduino para Testes](#configuração-do-arduino-para-testes)

## Descrição do Projeto

A calculadora RPN implementada neste projeto suporta operações aritméticas básicas e expressões aninhadas. Diferente da notação convencional (infixa), a notação RPN coloca os operadores após seus operandos, o que elimina a necessidade de parênteses para definir a ordem das operações.

## Funcionalidades

A calculadora suporta as seguintes operações:

- **Adição**: `+` no formato `(A B +)`
- **Subtração**: `-` no formato `(A B -)`
- **Multiplicação**: `*` no formato `(A B *)`
- **Divisão Real**: `|` no formato `(A B |)`
- **Divisão de Inteiros**: `/` no formato `(A B /)`
- **Resto da Divisão**: `%` no formato `(A B %)`
- **Potenciação**: `^` no formato `(A B ^)`

Além disso, a calculadora implementa comandos especiais:
- `(N RES)`: Recupera o resultado de N linhas anteriores
- `(V MEM)`: Armazena um valor V na memória
- `(MEM)`: Recupera o valor armazenado na memória

## Estrutura do Código

O código está organizado em uma classe principal `RPNCalculator` que contém os seguintes métodos principais:

### `to_half_precision(value)`
Converte um número para o formato de meia precisão (16 bits) conforme o padrão IEEE754.

```python
# Exemplo de uso
calculator = RPNCalculator()
half_precision_number = calculator.to_half_precision(3.14159)
```

### `evaluate_expression(expression)`
Avalia uma expressão RPN e retorna o resultado.

```python
# Exemplo de uso
result = calculator.evaluate_expression("(5 3 +)")  # Retorna 8
```

### `evaluate_tokens(tokens)`
Avalia uma lista de tokens em notação RPN.

### `tokenize_expression(expression)`
Converte uma string de expressão RPN em uma lista de tokens.

### `operate(a, b, operator)`
Realiza uma operação específica entre dois operandos.

### `process_file(filename)`
Processa um arquivo contendo expressões RPN (uma por linha).

### `generate_arduino_assembly(filename, output_filename)`
Gera código Assembly para Arduino baseado nas expressões do arquivo.

## Como Executar

Para executar a calculadora, você precisa fornecer um arquivo de texto contendo as expressões RPN, uma por linha:

```bash
python3 main.py arquivo_de_expressoes.txt
```

Onde `arquivo_de_expressoes.txt` é seu arquivo com expressões RPN. O programa irá:
1. Ler cada linha do arquivo
2. Avaliar cada expressão
3. Mostrar o resultado de cada expressão
4. Gerar código Assembly no arquivo `arduino_code.asm`

## Notação RPN Explicada

Na notação RPN, os operadores são colocados depois dos operandos. Por exemplo:

- **Notação Infixa**: `3 + 4`
- **Notação RPN**: `3 4 +`

Para expressões mais complexas:
- **Notação Infixa**: `(3 + 4) * 2`
- **Notação RPN**: `3 4 + 2 *`

Neste projeto, as expressões são colocadas entre parênteses:
- `(3 4 +)` é equivalente a `3 + 4`
- `(3 4 + 2 *)` é equivalente a `(3 + 4) * 2`

### Vantagens da Notação RPN

1. **Sem ambiguidade**: Não exige regras de precedência de operadores.
2. **Sem parênteses**: Não precisa de parênteses para definir a ordem das operações.
3. **Avaliação eficiente**: Pode ser avaliada facilmente usando uma pilha.

## Comandos Especiais

### 1. Comando `(N RES)`

Este comando recupera o resultado de N linhas anteriores.

```
(5 3 +)        # Resultado: 8
(10 2 -)       # Resultado: 8
(1 RES)        # Retorna o resultado da linha anterior (8)
```

### 2. Comando `(V MEM)`

Este comando armazena um valor na memória.

```
(42 MEM)       # Armazena o valor 42 na memória
```

### 3. Comando `(MEM)`

Este comando recupera o valor armazenado na memória.

```
(42 MEM)       # Armazena o valor 42 na memória
(MEM)          # Retorna 42
(MEM 10 +)     # Retorna 52
```

## Exemplos Práticos

Abaixo estão alguns exemplos de expressões RPN e seus resultados:

### Operações Básicas

```
(5 3 +)        # 5 + 3 = 8
(10 2 -)       # 10 - 2 = 8
(4 3 *)        # 4 * 3 = 12
(8 2 |)        # 8 / 2 = 4.0 (divisão real)
(9 2 /)        # 9 / 2 = 4 (divisão de inteiros)
(10 3 %)       # 10 % 3 = 1 (resto da divisão)
(2 3 ^)        # 2 ^ 3 = 8 (potenciação)
```

### Expressões Aninhadas

```
(3 (2 4 +) *)  # 3 * (2 + 4) = 18
((5 2 -) (3 1 +) *)  # (5 - 2) * (3 + 1) = 12
```

### Uso dos Comandos Especiais

```
(10 MEM)                  # Armazena 10 na memória
(MEM)                     # Retorna 10
(2 RES)                   # Retorna o resultado de 2 linhas atrás
((1 RES) (MEM) +)         # Soma o resultado anterior com o valor na memória
```

### Expressão Complexa

```
(7 (3 2 *) (1 5 +) + +)   # 7 + (3 * 2) + (1 + 5) = 19
```

## Geração de Código Assembly

O programa gera código Assembly compatível com o Arduino Uno. O código gerado inclui:

1. Definições de memória para armazenar resultados e o valor MEM
2. Código para executar cada expressão
3. Implementações das operações básicas (adição, subtração, etc.)

O arquivo Assembly gerado pode ser compilado e carregado em um Arduino Uno usando ferramentas apropriadas de desenvolvimento para Arduino.

### Exemplo de Código Assembly Gerado

```assembly
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
    
end:
    rjmp end    ; Loop infinito
```

## Configuração do Arduino para Testes

Para testar o código Assembly gerado pela calculadora RPN no Arduino, você precisará seguir estas etapas:

### Requisitos de Hardware

- Arduino Uno ou compatível
- Cabo USB para conectar o Arduino ao computador
- (Opcional) LED externo, resistor de 220Ω e jumpers

### Preparação do Arduino

1. **Conexão básica**:
   - Conecte o Arduino ao computador via cabo USB
   - Verifique se o LED embutido (pino 13) está funcionando

2. **Configuração para testes avançados (opcional)**:
   ```
   +5V --- LED --- Resistor 220Ω --- Pino Digital (ex: 8)
   ```

### Compilação e Carregamento do Código

1. **Instale as ferramentas AVR**:
   ```bash
   # Para Ubuntu/Debian
   sudo apt-get install gcc-avr binutils-avr avr-libc avrdude
   ```

2. **Utilize o script de compilação**:
   ```bash
   ./compile_arduino.sh
   ```
   
   Ou para especificar um arquivo específico:
   ```bash
   ./compile_arduino.sh arquivo.asm
   ```

### Verificação da Execução

O código `arduino_led_test.asm` inclui rotinas de teste que usam o LED embutido para indicar se as operações foram executadas corretamente:

1. **Inicialização**: O LED piscará 2 vezes lentamente
2. **Testes por Operação**: Para cada operação bem-sucedida, o LED piscará 1 vez
3. **Resultado Final**:
   - **Sucesso**: 5 piscadas rápidas
   - **Falha**: LED constantemente aceso

### Depuração

Se você precisar depurar o código:

1. Modifique `arduino_test.asm` para incluir mais pontos de verificação
2. Use o monitor serial com baud rate 9600 para visualizar mensagens
3. Para operações mais complexas, considere usar um display LCD ou múltiplos LEDs

---

*Este projeto foi desenvolvido como parte da atividade avaliativa da disciplina de Compiladores.*
