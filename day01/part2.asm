; fuck ts life

section .data
    filename db "input.txt",0
    nl       db 10
    lock_num   dq 50        ; initial lock value (pos = 50)
    zero_count dq 0         ; part2 = 0
section .bss
    file_buf resb 512*1024
    line_buf resb 128
    int_buf  resb 20
section .text
global _start
; ----------------------------------------------------
_start:
    ; open file - with open("input.txt", "r") as f:
    mov rax, 2
    lea rdi, [filename]
    xor rsi, rsi
    syscall
    mov r12, rax
    ; read file - lines = list(map(str.strip, f.readlines()))
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
    ; for line in lines:
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
    ; distance = int(line[1:])
    lea rsi, [line_buf + 1]
    xor rax, rax
    call convert_loop
    mov r15, rax                    ; r15 = distance
    ; direction = line[0]
    movzx rcx, byte [line_buf]      ; rcx = direction
    ; pos = lock_num
    mov rbx, qword [lock_num]       ; rbx = pos
    ; if direction == "L":
    cmp rcx, 'L'
    je do_sub
do_add:
    ; for _ in range(distance):
    test r15, r15
    jz print_pos
.loop:
    ; pos = (pos + 1) % 100
    inc rbx
    cmp rbx, 100
    jl .check_zero
    xor rbx, rbx                    ; wrap to 0
.check_zero:
    ; if pos == 0:
    test rbx, rbx
    jnz .next
    ; part2 += 1
    inc qword [zero_count]
.next:
    dec r15
    jnz .loop
    jmp print_pos
do_sub:
    ; for _ in range(distance):
    test r15, r15
    jz print_pos
.loop:
    ; pos = (pos - 1) % 100
    dec rbx
    test rbx, rbx
    jns .check_zero
    mov rbx, 99                     ; wrap to 99
.check_zero:
    ; if pos == 0:
    test rbx, rbx
    jnz .next
    ; part2 += 1
    inc qword [zero_count]
.next:
    dec r15
    jnz .loop
; ----------------------------------------------------
print_pos:
    ; store pos back
    mov qword [lock_num], rbx
    ; print(pos)
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
    ; print(f"{part2}")
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
; ASCII -> integer - int(line[1:])
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
; Print RAX decimal - print(pos) / print(f"{part2}")
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
