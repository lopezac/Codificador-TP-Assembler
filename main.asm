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

    mov rsi, secuenciaBinariaA  ; Cargar la dirección de la secuencia en RSI
    mov al, [rsi]               ; Cargar el primer byte de la secuencia en AL

section .data
	secuenciaBinariaA	 db	0xC4, 0x94, 0x37, 0x95, 0x63, 0xA2, 0x1D, 0x3C
						 db	0x86, 0xFC, 0x22, 0xA9, 0x3D, 0x7C, 0xA4, 0x51
						 db	0x63, 0x7C, 0x29, 0x04, 0x93, 0xBB, 0x65, 0x18
    TablaConversion		 db	"ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789+/"
	largoSecuenciaA		 db	0x18, 0 ; 24 en decimal

    ; estas son cosas de prueba
    cantidadDeBytes       db  3
	letraZ                db "Z"
	letraA                db "A"
    valor252              db 252
	indiceTablaConversion db 0

section .bss
	secuenciaImprimibleA	  resb	  24
    
    cantidadDeIteraciones     resb    1
    primerByte                resb    1
    segundoByte               resb    1
    tercerByte                resb    1
    primerCaracter            resb    1
    segundoCaracter           resb    1
    tercerCaracter            resb    1
    cuartoCaracter            resb    1


section .text

; --------------------------------- MAIN  --------------------------------------
main:
    ; Conseguimos el numero de iteraciones 24 / 3 = 8
    xor rax, rax ; Vaciamos rax
    mov ax, [largoSecuenciaA] ; Movemos a ax (1 byte) el largo de secuencia de A
    div byte[cantidadDeBytes] ; Dividimos ax por la cantidad de bytes = 3
    mov [cantidadDeIteraciones], ax ; Movemos a cantidadDeIteraciones el valor de ax
    xor rax, rax ; Vaciamos rax



    ; r15 sera el 'puntero' que usaremos para iterar sobre secuenciaBinariaA
    mov rcx, [cantidadDeIteraciones] ; Movemos la cantidad de iteraciones para iterar
    xor r15, r15 ; vaciamos r15
    add r15, secuenciaBinariaA ; le sumamos al registro r15 la direccion de memoria de secuenciaBinariaA

inicio_de_codificacion:
    sub rsp, 8
    call obtener_3_bytes
    add rsp, 8

    sub rsp, 8
    call obtener_4_digitos
    add rsp, 8

    ; sub rsp, 8
    ; call codificar_4_caracteres
    ; add rsp, 8

    ; sub rsp, 8
    ; call codificar_4_caracteres
    ; add rsp, 8

    loop inicio_de_codificacion

    ret

; --------------------------- RUTINAS INTERNAS ---------------------------------
obtener_3_bytes:
    xor r8, r8 ; vaciamos el registro r8
    mov r8b, [r15] ; movemos el valor hexadecimal apuntado por el puntero r15
                   ; que apunta a una posicion de secuenciaBinariaA
    mov [primerByte], r8b

    xor r8, r8
    mov r8b, [r15 + 1]
    mov [segundoByte], r8b
    
    xor r8, r8
    mov r8b, [r15 + 2]
    mov [tercerByte], r8b

    add r15, 3

    ret

obtener_4_digitos:
    
    ret

    ; 1er digito
    ; 6 bits de la izquierda del primer byte
    ; mov r9b, [valor252]
    ; and r9b, 0b11111100
    ; shr r9b, 2 ; 11111100 -> 00111111

    ; 2do digito
    ; 2 bits de la derecha del primer byte
    ; 4 bits de la izquierda del segundo byte

    ; 3er digito
    ; 4 bits de la derecha del segundo byte
    ; 2 bits de la izquierda del tercer byte

    ; 4to digito
    ; 6 bits de la derecha del tercer byte












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


;     m_puts secuenciaImprimibleA ; imprime "ZAZ"