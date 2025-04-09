#!/usr/bin/env python3
"""
Simulador de código Assembly para Arduino
Este script interpreta o código Assembly gerado e simula sua execução
"""

import sys
import re

class AVRSimulator:
    def __init__(self):
        # Registradores do AVR
        self.registers = {f'r{i}': 0 for i in range(32)}
        # Memória RAM (simulada)
        self.memory = bytearray(2048)  # 2KB de RAM
        # Memória para variáveis (simulando .dseg)
        self.variables = {'memory': 0.0, 'results': [0.0] * 10}
        # Contador de programa
        self.pc = 0
        # Flag para indicar se o programa terminou
        self.running = True
        
    def load_program(self, filename):
        """Carrega o programa assembly do arquivo"""
        self.program = []
        self.labels = {}
        
        try:
            with open(filename, 'r') as f:
                line_num = 0
                for line in f:
                    # Remove comentários e espaços extras
                    line = re.sub(r';.*$', '', line).strip()
                    if not line:
                        continue
                    
                    # Processa labels
                    if ':' in line and not line.startswith('.'):
                        label, rest = line.split(':', 1)
                        self.labels[label.strip()] = line_num
                        line = rest.strip()
                        if not line:
                            continue
                    
                    # Adiciona instrução ao programa
                    self.program.append(line)
                    line_num += 1
            
            print(f"Programa carregado: {len(self.program)} instruções")
            for label, addr in self.labels.items():
                print(f"Label '{label}' em {addr}")
            return True
        
        except Exception as e:
            print(f"Erro ao carregar o programa: {e}")
            return False
    
    def execute(self):
        """Executa o programa carregado"""
        self.pc = 0
        self.running = True
        
        print("\n--- Iniciando simulação ---\n")
        
        # Localiza o rótulo principal
        if 'main' in self.labels:
            self.pc = self.labels['main']
        
        # Loop principal de execução
        step_count = 0
        while self.running and self.pc < len(self.program) and step_count < 1000:
            instruction = self.program[self.pc]
            print(f"PC={self.pc}: Executando '{instruction}'")
            
            # Simula a execução da instrução
            self.execute_instruction(instruction)
            
            # Avança o PC (a menos que a instrução já tenha modificado)
            self.pc += 1
            step_count += 1
            
            # Mostra estado dos registradores a cada 5 passos
            if step_count % 5 == 0:
                self.print_state()
        
        print("\n--- Simulação concluída ---")
        print(f"Passos executados: {step_count}")
        self.print_state()
        
        # Se terminou porque atingiu o limite, avisa
        if step_count >= 1000:
            print("Atenção: Limite de passos atingido. A simulação foi interrompida.")
    
    def execute_instruction(self, instruction):
        """Simula a execução de uma instrução"""
        # Divide a instrução em operação e operandos
        parts = instruction.split()
        if not parts:
            return
        
        operation = parts[0].lower()
        operands = []
        if len(parts) > 1:
            # Processa operandos, separando por vírgulas se houver
            operands_str = ' '.join(parts[1:])
            operands = [op.strip() for op in operands_str.split(',')]
        
        # Simula operações específicas
        if operation == 'ld':
            # ld r16, X+
            if len(operands) >= 2 and operands[1] == 'X+':
                reg = operands[0]
                # Simula carregar da memória
                self.registers[reg] = 5  # Valor fictício para simulação
                print(f"  Carregado valor 5 para {reg}")
            
        elif operation == 'st':
            # st X+, r16
            if len(operands) >= 2 and operands[0] == 'X+':
                reg = operands[1]
                # Simula armazenar na memória
                print(f"  Armazenado valor {self.registers.get(reg, 0)} na memória")
        
        elif operation == 'add':
            # add r16, r17
            if len(operands) >= 2:
                dst = operands[0]
                src = operands[1]
                # Simula adição
                result = self.registers.get(dst, 0) + self.registers.get(src, 0)
                self.registers[dst] = result
                print(f"  {dst} = {dst} + {src} = {result}")
        
        elif operation == 'sub':
            # sub r16, r17
            if len(operands) >= 2:
                dst = operands[0]
                src = operands[1]
                # Simula subtração
                result = self.registers.get(dst, 0) - self.registers.get(src, 0)
                self.registers[dst] = result
                print(f"  {dst} = {dst} - {src} = {result}")
        
        elif operation == 'mul':
            # mul r16, r17
            if len(operands) >= 2:
                dst = operands[0]
                src = operands[1]
                # Simula multiplicação
                result = self.registers.get(dst, 0) * self.registers.get(src, 0)
                self.registers['r0'] = result & 0xFF  # Parte baixa
                self.registers['r1'] = (result >> 8) & 0xFF  # Parte alta
                print(f"  r0:r1 = {dst} * {src} = {result}")
        
        elif operation == 'rjmp':
            # rjmp label
            if len(operands) >= 1:
                label = operands[0]
                if label in self.labels:
                    # Simula salto
                    old_pc = self.pc
                    self.pc = self.labels[label]
                    print(f"  Salto de {old_pc} para {self.pc} (label {label})")
                else:
                    print(f"  Erro: Label '{label}' não encontrada")
        
        elif operation == 'movw':
            # movw r16:r17, r0:r1
            if len(operands) >= 2:
                dst_pair = operands[0].split(':')
                src_pair = operands[1].split(':')
                if len(dst_pair) >= 1 and len(src_pair) >= 1:
                    dst_reg = dst_pair[0]
                    src_reg = src_pair[0]
                    # Simula mover word
                    self.registers[dst_reg] = self.registers.get(src_reg, 0)
                    if len(dst_pair) > 1 and len(src_pair) > 1:
                        self.registers[dst_pair[1]] = self.registers.get(src_pair[1], 0)
                    print(f"  Movido {src_reg} para {dst_reg}")
        
        else:
            print(f"  Operação '{operation}' não implementada na simulação (ignorando)")
    
    def print_state(self):
        """Mostra o estado atual dos registradores e memória"""
        print("\n--- Estado atual ---")
        print("Registradores:")
        for i in range(0, 32, 4):
            regs = [f"r{j}={self.registers.get(f'r{j}', 0)}" for j in range(i, min(i+4, 32))]
            print("  " + ", ".join(regs))
        
        print("Variáveis:")
        print(f"  memory = {self.variables['memory']}")
        print(f"  results = {self.variables['results'][:3]}...")
        print("---------------------")


if __name__ == "__main__":
    if len(sys.argv) < 2:
        print("Uso: python3 simulate_asm.py <arquivo_asm>")
        sys.exit(1)
    
    simulator = AVRSimulator()
    if simulator.load_program(sys.argv[1]):
        simulator.execute()
    else:
        print("Falha ao carregar o programa.")
        sys.exit(1)
