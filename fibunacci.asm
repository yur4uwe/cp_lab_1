IDEAL
        DOSSEG
        MODEL   small
        STACK   256
        DATASEG
exc         DB      0
max_count   DB      25

num_msg     DB      '-th fib num: $'

buffer      DB      5 dup(0)     ; enough for 5 digits

        CODESEG
Start:
    mov	ax, @data
	mov	ds, ax

    mov cx, [max_count]
    mov ax, 0
    mov bx, 1

fib_loop:
    call print_fib
    call new_line

    mov dx, ax      ; dx = a
    mov ax, bx      ; ax = b
    add bx, dx      ; b = a + b

    loop fib_loop

    jmp Exit

print_fib:
    push ax ; Save Fibonacci number in Stack

    mov ax, 0             ; clear ax for printing
    mov al, [max_count]   ; AX = max_count
    sub al, cl            ; AX = current index (0-based)
    add al, 1             ; AX = current index (1-based)
    call print_num        ; Print the index
    
    lea dx, [num_msg]
    mov ah, 09h
    int 21h

    pop ax  ; Restore Fibonacci number from Stackr

print_num: 
    push ax ; Again save ax
    push bx ; Save bx as well
    push cx ; Save cx 'cus its counter

    mov cx, 0          ; digit count
    mov bx, 10         ; divisor
    lea si, [buffer]   ; buffer for digits

write_to_buffer_loop:
    xor dx, dx         ; clear DX before DIV
    div bx             ; AX / 10, quotient in AX, remainder in DX
    add dl, '0'        ; convert remainder to ASCII
    mov [si], dl       ; store digit
    inc si        ; Increment buffer pointer
    inc cx        ; Increment digit count
    cmp ax, 0     ; Check if quotient is zero
    jne write_to_buffer_loop
    
    mov ah, 02h
flush_buffer_loop:
    dec si
    mov dl, [si]
    int 21h
    loop flush_buffer_loop

    pop cx
    pop bx
    pop ax
    ret

new_line:
    push ax
    push dx

    mov dl, 0Ah
    mov ah, 02h
    int 21h
    mov dl, 0Dh
    mov ah, 02h
    int 21h

    pop dx
    pop ax
    ret

Exit:
    mov     ah, 04Ch        ; DOS function: Exit program
    mov     al, [exc]       ; Return exit code value
    int     21h             ; Call DOS.  Terminate program

    END     Start           ; End of program / entry point

; Fibonacci sequence calculation
; a = 0
; b = 1
; for i = 0 to max_count - 1
;     temp = a
;     a = b
;     b = temp + b
;     printf("%d-th fib num: %d", i, b)
; end for