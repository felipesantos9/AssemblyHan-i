section .text
    global _start

_start:
    ; Imprime "Algoritmo da Torre de Hanoi com x discos"
    mov eax, 4
    mov ebx, 1
    mov ecx, inicio
    mov edx, len_inicio
    int 128

    ; Inicializa a execução do algoritmo Hanoi com 3 discos
    mov eax, 3
    push dword 2
    push dword 3
    push dword 1
    push eax
    call hanoi

    ; Impressão "Concluído!"
    mov eax, 4
    mov ebx, 1
    mov ecx, concluido
    mov edx, len_concluido
    int 128

    ; Termina o programa
    mov eax, 1
    mov ebx, 0
    int 128

hanoi:
    push ebp
    mov ebp, esp

    mov eax, [ebp+8]
    cmp eax, 0
    je desempilhar

    push dword [ebp+16]
    push dword [ebp+20]
    push dword [ebp+12]
    dec eax
    push dword eax
    call hanoi
    add esp, 16

    push dword [ebp+16]
    push dword [ebp+12]
    push dword [ebp+8]
    call imprime
    add esp, 12

    push dword [ebp+12]
    push dword [ebp+16]
    push dword [ebp+20]
    mov eax, [ebp+8]
    dec eax
    push dword eax
    call hanoi

desempilhar:
    mov esp, ebp
    pop ebp
    ret

imprime:
    push ebp
    mov ebp, esp
    
    mov eax, [ebp + 8]
    add al, 48
    mov [disco], al

    mov eax, [ebp + 12]
    add al, 64
    mov [torre_saida], al

    mov eax, [ebp + 16]
    add al, 64
    mov [torre_ida], al

    mov edx, length
    mov ecx, msg
    mov ebx, 1
    mov eax, 4
    int 128

    mov esp, ebp
    pop ebp
    ret

section .data
    msg: db "Mova disco ", 0
    disco: db '  da Torre '
    torre_saida: db '  para a Torre ' 
    torre_ida: db ' ', 0xa
    length equ $ - msg

    concluido: db "Concluído!", 0xa
    len_concluido equ $ - concluido
    
    inicio: db "Algoritmo da Torre de Hanoi com 3 discos", 0xa
    len_inicio equ $ - inicio
