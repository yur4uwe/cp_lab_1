IDEAL
        DOSSEG
        MODEL   small
        STACK   256
        DATASEG

a           DW      0
b           DW      1
exc         DB      0
max_count   DB      24

num_msg     DB      '-th fib num: $'

buffer      DB      5 dup(0)     ; enough for 5 digits

        CODESEG
Start:
    mov	  ax, @data
	mov	  ds,ax

    mov     cl, [max_count]
    xor     ch, ch          ; Clear high byte of CX
    mov     ax, 0
    mov     bx, 1


fib_loop:
    mov     dx, ax      ; dx = a
    mov     ax, bx      ; ax = b
    add     bx, dx      ; b = a + b

    loop fib_loop

print_fib:
    push ax ; Save Fibonacci number in Stack

    mov ax, 0             ; clear ax for printing
    mov al, [max_count]   ; AX = max_count
    sub al, cl            ; AX = current index (0-based)
    call print_num        ; Print the index
    
    lea dx, [num_msg]
    mov ah, 09h
    int 21h

    pop ax  ; Restore Fibonacci number from Stackr
    call print_num        ; Print the Fibonacci number

    jmp Exit

print_num: 
    push ax
    push bx
    push cx
    push dx

    mov cx, 0          ; digit count
    mov bx, 10         ; divisor
    lea si, [buffer]   ; buffer for digits

write_to_buffer_loop:
    xor dx, dx         ; clear DX before DIV
    div bx             ; AX / 10, quotient in AL, remainder in AH
    add dl, '0'        ; convert remainder to ASCII
    mov [si], dl       ; store digit
    inc si
    inc cx
    cmp ax, 0
    jne write_to_buffer_loop
    
print_num_print:
    dec si
    mov dl, [si]
    mov ah, 02h
    int 21h
    loop print_num_print

    pop dx
    pop cx
    pop bx
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