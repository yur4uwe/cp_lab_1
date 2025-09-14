MODEL	SMALL
STACK 256	
DATASEG

CODESEG
start:
	mov ax,0013h
	int 10h
	mov cx,319
	mov dx,100

maljuvannja:
	mov al,5
        add dx,1
	mov ah,0Ch
	int 10h
loop maljuvannja
ex:
	mov ah,1
	int 16h

jz ex
	mov ax,0003h
	int 10h
	mov ah,04Ch
	int 021h

end start