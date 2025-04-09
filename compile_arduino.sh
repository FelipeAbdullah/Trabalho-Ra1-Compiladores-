#!/bin/bash

# Script para compilar código Assembly para Arduino Uno
# Uso: ./compile_arduino.sh [nome_do_arquivo_asm] [porta_serial]

# Verifica argumentos
if [ -z "$1" ]; then
    ASM_FILE="arduino_code.asm"
else
    ASM_FILE="$1"
fi

if [ -z "$2" ]; then
    # Tenta detectar automaticamente a porta Arduino
    if [ -e /dev/ttyACM0 ]; then
        SERIAL_PORT="/dev/ttyACM0"
    elif [ -e /dev/ttyUSB0 ]; then
        SERIAL_PORT="/dev/ttyUSB0"
    else
        echo "Não foi possível detectar a porta Arduino automaticamente."
        echo "Por favor, especifique a porta como segundo argumento."
        exit 1
    fi
else
    SERIAL_PORT="$2"
fi

# Verifica se o arquivo existe
if [ ! -f "$ASM_FILE" ]; then
    echo "Erro: Arquivo $ASM_FILE não encontrado!"
    exit 1
fi

# Extrai o nome base do arquivo (sem extensão)
BASE_NAME=$(basename "$ASM_FILE" .asm)

# Cores para mensagens
GREEN='\033[0;32m'
RED='\033[0;31m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

echo -e "${YELLOW}Compilando $ASM_FILE para Arduino Uno...${NC}"

# Verifique se as ferramentas necessárias estão instaladas
if ! command -v avr-as &> /dev/null; then
    echo -e "${RED}Erro: avr-as não encontrado. Por favor, instale o compilador AVR.${NC}"
    echo "Em sistemas baseados em Debian/Ubuntu: sudo apt-get install gcc-avr binutils-avr avr-libc avrdude"
    exit 1
fi

if ! command -v avr-objcopy &> /dev/null; then
    echo -e "${RED}Erro: avr-objcopy não encontrado. Por favor, instale o compilador AVR.${NC}"
    exit 1
fi

if ! command -v avrdude &> /dev/null; then
    echo -e "${RED}Erro: avrdude não encontrado. Por favor, instale o AVRDUDE.${NC}"
    exit 1
fi

# Passo 1: Montar o arquivo Assembly para um arquivo objeto
echo "Montando o arquivo ASM para arquivo objeto..."
avr-as -mmcu=atmega328p -o "$BASE_NAME.o" "$ASM_FILE"

if [ $? -ne 0 ]; then
    echo -e "${RED}Erro ao montar o arquivo Assembly!${NC}"
    exit 1
fi
echo -e "${GREEN}Montagem do arquivo ASM concluída com sucesso!${NC}"

# Passo 2: Converter o arquivo objeto para um arquivo hexadecimal
echo "Convertendo para formato HEX..."
avr-objcopy -O ihex "$BASE_NAME.o" "$BASE_NAME.hex"

if [ $? -ne 0 ]; then
    echo -e "${RED}Erro ao converter para o formato HEX!${NC}"
    exit 1
fi
echo -e "${GREEN}Conversão para formato HEX concluída com sucesso!${NC}"

# Passo 3: Perguntar ao usuário se deseja carregar no Arduino
echo -e "${YELLOW}Deseja carregar o código no Arduino conectado em $SERIAL_PORT? (s/n)${NC}"
read -r RESPOSTA

if [[ "$RESPOSTA" =~ ^[Ss]$ ]]; then
    echo "Carregando código no Arduino..."
    avrdude -F -V -c arduino -p ATMEGA328P -P "$SERIAL_PORT" -b 115200 -U flash:w:"$BASE_NAME.hex"
    
    if [ $? -ne 0 ]; then
        echo -e "${RED}Erro ao carregar o código no Arduino!${NC}"
        echo "Verifique se o Arduino está conectado corretamente."
        exit 1
    fi
    echo -e "${GREEN}Código carregado com sucesso no Arduino!${NC}"
else
    echo -e "${YELLOW}Carregamento cancelado. Você pode carregar manualmente usando:${NC}"
    echo "avrdude -F -V -c arduino -p ATMEGA328P -P $SERIAL_PORT -b 115200 -U flash:w:$BASE_NAME.hex"
fi

echo -e "${GREEN}Compilação concluída! Arquivos gerados:${NC}"
echo " - $BASE_NAME.o (arquivo objeto)"
echo " - $BASE_NAME.hex (arquivo hexadecimal para o Arduino)"
