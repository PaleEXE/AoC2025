section .data
    filename db "input.txt",0
    nl       db 10

    lock_num   dq 50        ; initial lock value
    zero_count dq 0

section .bss
    file_buf resb 512*1024
    line_buf resb 128
    int_buf  resb 20

section .text
global _start

; ----------------------------------------------------
_start:
    ; open file
    mov rax, 2
    lea rdi, [filename]
    xor rsi, rsi
    syscall
    mov r12, rax

    ; read file
    mov rax, 0
    mov rdi, r12
    lea rsi, [file_buf]
    mov rdx, 512*1024
    syscall
    mov r13, rax
    xor r14, r14

    ; close file
    mov rax, 3
    mov rdi, r12
    syscall

; ----------------------------------------------------
process_lines:
    xor rcx, rcx

next_char:
    cmp r14, r13
    jge done

    mov al, [file_buf + r14]

    cmp al, 10
    je process_line

    mov [line_buf + rcx], al
    inc rcx
    inc r14
    jmp next_char

; ----------------------------------------------------
process_line:
    cmp rcx, 0
    je skip_newline

    ; null terminate
    mov byte [line_buf + rcx], 0

    ; convert digits starting from char 2
    lea rsi, [line_buf + 1]
    xor rax, rax
    call convert_loop

    ; get direction char
    movzx rcx, byte [line_buf]

    ; load lock
    mov rbx, qword [lock_num]

    ; decide add / sub
    cmp rcx, 'L'
    je do_sub

do_add:
    add rbx, rax
    jmp normalize_result

do_sub:
    sub rbx, rax

; ----------------------------------------------------
normalize_result:
    ; force range 0..99

.normalize_high:
    cmp rbx, 100
    jl .normalize_low
    sub rbx, 100
    jmp .normalize_high

.normalize_low:
    cmp rbx, 0
    jge store_lock
    add rbx, 100
    jmp .normalize_low

; ----------------------------------------------------
store_lock:
    mov qword [lock_num], rbx

    cmp rbx, 0
    jne no_zero

    mov rax, qword [zero_count]
    inc rax
    mov qword [zero_count], rax

no_zero:

    ; print lock
    mov rax, rbx
    lea rsi, [int_buf]
    call print_int

    ; newline
    mov rax, 1
    mov rdi, 1
    lea rsi, [nl]
    mov rdx, 1
    syscall

skip_newline:
    inc r14
    jmp process_lines

; ----------------------------------------------------
done:
    ; print zero count
    mov rax, qword [zero_count]
    lea rsi, [int_buf]
    call print_int

    ; newline
    mov rax, 1
    mov rdi, 1
    lea rsi, [nl]
    mov rdx, 1
    syscall

    ; exit
    mov rax, 60
    xor rdi, rdi
    syscall

; ----------------------------------------------------
; ASCII -> integer
convert_loop:
    mov bl, [rsi]
    cmp bl, 0
    je .done

    sub bl, '0'
    mov rcx, 10
    mul rcx
    add rax, rbx

    inc rsi
    jmp convert_loop

.done:
    ret

; ----------------------------------------------------
; Print RAX decimal
print_int:
    mov rbx, rax

    lea rdi, [rsi + 19]
    mov byte [rdi], 0

    mov rcx, 10

.next_digit:
    xor rdx, rdx
    div rcx
    add dl, '0'

    dec rdi
    mov [rdi], dl

    test rax, rax
    jnz .next_digit

    ; write output
    lea rsi, [rdi]
    lea rdx, [int_buf + 20]
    sub rdx, rsi

    mov rax, 1
    mov rdi, 1
    syscall
    ret
