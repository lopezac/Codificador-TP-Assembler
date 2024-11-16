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
	indiceTablaConversion db 0

section .bss
	secuenciaImprimibleA	resb	32

section .text

main:
    ; esto es de prueba tambien, para ir viendo viste de a poquito
    ; (chatgpt tiro), que podemos usar al registro r9 como un puntero a la cadena secuenciaImprimibleA
    ; la ventaja de esto que le podemos incrementar 1 a este puntero (el registro r9) y avanzar a la posicion
    ; siguiente, en cambio directamente con secuenciaImprimibleA no es posible hacer eso
    mov r9, 0 ; primero le ponemos de valor 0, si no tira error
    add r9, secuenciaImprimibleA ; le pasamos (en realidad le sumamos) al registro r9 la direccion de
                                 ; memoria de secuenciaImprimibleA

    mov r8w, [letraZ] ; muevo la letraZ de un byte a r8w, que es de un byte tambien
    mov [r9], r8w     ; muevo al puntero r9, el valor de r8w que es la letraZ

    add r9, 1         ; le sumamos 1 al puntero r9, osea avanzamos a la posicion siguiente
    mov r8w, [letraA]
    mov [r9], r8w

    add r9, 1
    mov r8w, [letraZ]
    mov [r9], r8w

    m_puts secuenciaImprimibleA ; imprime "ZAZ"

    ret