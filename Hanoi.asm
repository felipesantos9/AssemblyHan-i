section .text
    global _start

_start:

    ; Impressão do prompt
    mov eax, 4              ; syscall write (sys_write)
    mov ebx, 1              ; descriptor de arquivo stdout
    mov ecx, prompt         ; ponteiro para o prompt
    mov edx, len_prompt     ; tamanho do prompt
    int 0x80                ; chamada de sistema para escrever
    
    ; Leitura da entrada
    mov eax, 3              ; syscall read (sys_read)
    mov ebx, 0              ; descriptor de arquivo stdin
    mov ecx, entrada        ; ponteiro para o buffer de entrada
    mov edx, 128            ; tamanho máximo da entrada
    int 0x80                ; chamada de sistema para ler


    ; Impressão da mensagem inicial
    mov eax, 4              ; syscall write (sys_write)
    mov ebx, 1              ; descriptor de arquivo stdout
    mov ecx, inicio         ; ponteiro para a mensagem inicial
    mov edx, 27             ; tamanho da mensagem
    int 0x80                ; chamada de sistema para escrever


    ; Impressão do número de discos
    mov eax, 4              ; syscall write (sys_write)
    mov ebx, 1              ; descriptor de arquivo stdout
    mov ecx, entrada        ; ponteiro para o buffer de entrada (contém o número de discos)
    mov edx, 1              ; tamanho do número (apenas 1 byte)
    int 0x80                ; chamada de sistema para escrever
   

    ; Inicializa a execução do algoritmo Hanoi
    lea esi, [entrada]      ; carrega o endereço do buffer de entrada em esi
    mov ecx, 1              ; inicializa ecx com 1
    call integer_string     ; chama a função para converter a entrada em um número
    push dword 2            ; push do terceiro pino (destino)
    push dword 3            ; push do segundo pino (auxiliar)
    push dword 1            ; push do primeiro pino (origem)
    push eax                ; push do número de discos
    call hanoi              ; chama a função hanoi


    ; Impressão "Concluído!"
    mov eax, 4                  ; syscall write (sys_write)
    mov ebx, 1                  ; descriptor de arquivo stdout
    mov ecx, concluido          ; ponteiro para a mensagem de saída
    mov edx, len_concluido      ; tamanho da mensagem de saída
    int 0x80                    ; chamada de sistema para escrever

    ; Termina o programa
    mov eax, 1               ; Chama a syscall para sair do programa
    mov ebx, 0               ; Indica que o programa foi executado com sucesso
    int 0x80                 ; Chamada de sistema para sair


hanoi:
    push ebp                 ; Salva o valor de ebp na pilha
    mov ebp, esp             ; Configura ebp para apontar para o início da pilha

    mov eax, [ebp+8]         ; Move o valor do primeiro parâmetro (número de discos) para eax
    cmp eax, 0               ; Compara com zero (caso base)
    je desempilhar           ; Se o número de discos for zero, retorna

    ; Chamada recursiva para mover n-1 discos da torre origem para a torre auxiliar
    push dword [ebp+16]      ; Push da terceira torre (destino)
    push dword [ebp+20]      ; Push  da segunda torre (origem)
    push dword [ebp+12]      ; Push da primeira torre (auxiliar)
    dec eax                  ; Decrementa o número de discos
    push dword eax           ; Push do número de discos decrementado
    call hanoi               ; Chama recursivamente a função hanoi
    add esp, 16              ; Limpa os parâmetros da pilha

    ; Movimento de disco da torre origem para a torre destino
    push dword [ebp+16]      ; Push da terceira torre (destino)
    push dword [ebp+12]      ; Push da primeira torre (origem)
    push dword [ebp+8]       ; Push do número de discos
    call imprime             ; Chama a função imprime para imprimir a ação
    add esp, 12              ; Limpa os parâmetros da pilha

    ; Chamada recursiva para mover n-1 discos da torre auxiliar para a torre destino
    push dword [ebp+12]      ; Push da primeira torre (destino)
    push dword [ebp+16]      ; Push da terceira torre (origem)
    push dword [ebp+20]      ; Push  da segunda torre (auxiliar)
    mov eax, [ebp+8]         ; Move novamente o número de discos para eax
    dec eax                  ; Decrementa o número de discos
    push dword eax           ; Push do número de discos decrementado
    call hanoi               ; Chama recursivamente a função hanoi

desempilhar:
    mov esp, ebp   ; Restaura o ponteiro de pilha (esp) para o valor que estava salvo em ebp
    pop ebp        ; Desempilha o valor de ebp, restaurando o valor do ponteiro de base da pilha
    ret            ; Retorna à função chamadora


imprime:
    push ebp         ; Salva o ponteiro de base da pilha atual
    mov ebp, esp     ; Configura ebp para apontar para o início da pilha atual

    mov eax, [ebp + 8]    ; Move o primeiro parâmetro (número do disco) para eax
    add al, 48            ; Converte o número do disco em seu caractere ASCII equivalente
    mov [disco], al       ; Armazena o caractere em disco

    mov eax, [ebp + 12]   ; Move o segundo parâmetro (torre destino) para eax
    add al, 64            ; Converte o número da torre em seu caractere ASCII equivalente
    mov [torre_saida], al ; Armazena o caractere em torre_saida

    mov eax, [ebp + 16]   ; Move o terceiro parâmetro (torre origem) para eax
    add al, 64            ; Converte o número da torre em seu caractere ASCII equivalente
    mov [torre_ida], al   ; Armazena o caractere em torre_ida

    mov edx, length       ; Move o tamanho da string para edx
    mov ecx, msg          ; Move o endereço da string para ecx
    mov ebx, 1            ; Especifica a saída padrão (stdout)
    mov eax, 4            ; Chama a interrupção do sistema para escrever
    int 0x80               ; Chama a interrupção do sistema

    mov esp, ebp   ; Restaura o ponteiro de pilha (esp) para o valor que estava salvo em ebp
    pop ebp        ; Desempilha o valor de ebp, restaurando o valor do ponteiro de base da pilha
    ret            ; Retorna à função chamadora


integer_string:
  xor ebx, ebx          ; Limpa o registrador ebx para garantir que esteja vazio antes de iniciar o processamento.
.proximo_digito:       ; Rótulo para o início do loop que percorre os caracteres da string.
  movzx eax, byte [esi]   ; Move o próximo byte da string para o registrador eax, sem sinal.
  inc esi                ; Incrementa o ponteiro de origem da string para acessar o próximo caractere.
  sub al, '0'            ; Subtrai o valor ASCII '0' do caractere atual para converter de ASCII para valor numérico.
  imul ebx, 10           ; Multiplica o valor acumulado (na base 10) por 10.
  add ebx, eax           ; Adiciona o valor numérico do caractere atual ao acumulador.
  loop .proximo_digito  ; Continua o loop até que todos os caracteres da string sejam processados.
  mov eax, ebx           ; Move o resultado da conversão (valor numérico) para o registrador eax.
  ret                    ; Retorna com o valor convertido.


section .data
    entrada db 128
    msg: db " Mova disco ", 0
    disco: db '  da Torre '
    torre_saida: db '  para a Torre ' 
    torre_ida: db ' ', 0xa
    length equ $ - msg

    concluido: db "Concluído!", 0xa
    len_concluido equ $ - concluido
    
    inicio: db " Discos na torre de hanoi: ", 0xa
    len_inicio equ $ - inicio
    
    prompt: db "Número de discos: ", 0xa
    len_prompt equ $ - prompt
