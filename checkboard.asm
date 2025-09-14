IDEAL
    DOSSEG
    MODEL   small
    STACK   256
    
    DATASEG
exc       DB 0
cell_size DW 20
    CODESEG
Start:
    mov ax, @data
    mov ds, ax

    mov cx, 0
    mov di, 0     

    mov ax, 0013h ; Set video mode 13h
    int 10h
    
board:
    mov ax, cx
    xor dx, dx
    div [cell_size]   ; AX = cx / cell_size
    mov si, ax        ; SI = cell column

    mov ax, di
    xor dx, dx
    div [cell_size]   ; AX = di / cell_size
    add si, ax        ; SI = cell_col + cell_row

    mov al, 15        ; White
    test si, 1       ; Check if sum is odd/even
    jz draw_pixel
    mov al, 0        ; Black

draw_pixel:
    mov ah, 0Ch
    mov dx, di
    int 10h

    inc cx
    cmp cx, 199
    jl board
    mov cx, 0
    inc di
    cmp di, 199
    jl board

ex:
    mov ah, 01h
    int 16h
    jz ex

Exit:
    mov ax, 0003h
    int 10h
    mov ah, 04Ch ; DOS Exit program
    mov al, [exc] ; Return exit code value
    int 21h ; Call DOS.  Terminate program
    END Start