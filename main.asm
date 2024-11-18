; Nombre y padron de los integrantes del grupo
; Axel Carlos Lopez 111713
; Bautista Capello

; Casos de prueba:
; SecuenciaBinariaDePrueba db	0x73, 0x38, 0xE7, 0xF7, 0x34, 0x2C, 0x4F, 0x92
;						   db	0x49, 0x55, 0xE5, 0x9F, 0x8E, 0xF2, 0x75, 0x5A
;						   db	0xD3, 0xC5, 0x53, 0x65, 0x68, 0x52, 0x78, 0x3F
; SecuenciaImprimibleCodificada	db	"czjn9zQsT5JJVeWfjvJ1WtPFU2VoUng/"

global main

; esto es un macro para llamar la funcion puts de C, imprime la cadena pasada como parametro
; la idea es poder imprimir secuenciaImprimibleA y ver rapidamente que tiene adentro
extern puts
%macro m_puts 1
    mov rdi, %1

    sub rsp, 8
    call puts
    add rsp, 8
%endmacro

section .data
	secuenciaBinariaA	db	0xC4, 0x94, 0x37, 0x95, 0x63, 0xA2, 0x1D, 0x3C
						db	0x86, 0xFC, 0x22, 0xA9, 0x3D, 0x7C, 0xA4, 0x51
						db	0x63, 0x7C, 0x29, 0x04, 0x93, 0xBB, 0x65, 0x18
    TablaConversion		db	"ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789+/"
	largoSecuenciaA		db	0x18 ; 24 en decimal

    ; estas son cosas de prueba
	letraZ               db "Z", 0
	letraA               db "A", 0
    valor252 db 252
    valor6  db 6
	indiceTablaConversion db 0

section .bss
	secuenciaImprimibleA	resb	32

section .text

main:
    ; Seteamos en 0 los registros rax, y rbx
    xor rax, rax
    xor rbx, rbx

    mov al, [valor252]
    and al, 0b00111111

    mov bl, [valor252]
    and bl, 0b11000000

    mov cl, [valor6]         ; Cargar 6 en CL (usaremos esto para dividir)
    div cl            ; Dividimos BL por 64 para colocar los bits en las posiciones correctas

    or al, bl

    ; se aproxima por aca -> https://chatgpt.com/share/673a84ca-c200-8004-a88e-717933dc6669
    ; https://chatgpt.com/share/673a84ca-c200-8004-a88e-717933dc6669


    ; 1er digito
    ; 11110101 convertir a 00111101
    ; primero conseguimos los primeros 6 caracteres
    ; 11110101 and 11111100
    ; 11110100


    ; 11110000
    ; 00000100


    ; 11010100 and 10000000
    ; 11111111 - 10000000
    ; 01111111
    ; 10000000 -> 00000001

    ; 11010100 and 10000000
    ; 11111111 + 10000000
    ; 01111111
    ; 10000000



    ; 11010100 and 10000000
    ; 11111111 - 01000000
    ; 11111111
    ; 00000001

    ; r9x
    ; 00000000 + 00000001 = 00000001
    ; 00000001 + 00000010 = 00000011
    ; 00000011 + 00000000 = 00000011
    ; 00000011 + 00001000 = 00001011
    
    ; 00111101 
    ; el resultado lo desplazamos dos bits a la derecha











    ; 2do digito
    ; 11110101 -> 00000001
    
    ; 3er digito

    ; 4to digito
    ; 11110101 convertir a 00111101





;     mov r9, 0 ; vaciamos r9
;     add r9, secuenciaImprimibleA ; le sumamos al registro r9 la direccion de memoria de secuenciaImprimibleA

;     xor rcx, rcx
;     mov rcx, 0 ; vaciamos rcx
;     mov cl, [largoSecuenciaA] ; no movemos a rcx, porque rcx es de 8 bytes, y largoSecuenciaA es de 

; iteracion_secuencia:
;     mov r8w, [letraA]
;     mov [r9], r8w
;     add r9, 1

;     loop iteracion_secuencia


    m_puts secuenciaImprimibleA ; imprime "ZAZ"

    ret