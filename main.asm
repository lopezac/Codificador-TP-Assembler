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

    secuenciaBinariaA db	0x73, 0x38, 0xE7, 0xF7, 0x34, 0x2C, 0x4F, 0x92
						   db	0x49, 0x55, 0xE5, 0x9F, 0x8E, 0xF2, 0x75, 0x5A
						   db	0xD3, 0xC5, 0x53, 0x65, 0x68, 0x52, 0x78, 0x3F
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
    
    valorAnteriorDeRcx        resq    1
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

    ; r14 sera el 'puntero' que usaremos para iterar sobre secuenciaImprimibleA
    xor r14, r14
    add r14, secuenciaImprimibleA
    
inicio_de_codificacion:
    sub rsp, 8
    call obtener_3_bytes
    add rsp, 8

    sub rsp, 8
    call obtener_4_digitos
    add rsp, 8

    testrcx:
    mov [valorAnteriorDeRcx], rcx

    sub rsp, 8
    call codificar_4_caracteres
    add rsp, 8

    mov rcx, [valorAnteriorDeRcx]

    xor byte[primerByte], 0
    xor byte[segundoByte], 0
    xor byte[tercerByte], 0
    xor byte[primerCaracter], 0
    xor byte[segundoCaracter], 0
    xor byte[tercerCaracter], 0
    xor byte[cuartoCaracter], 0

    loop inicio_de_codificacion

; --------------------------- FINALIZACION -------------------------------------

    m_puts secuenciaImprimibleA

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
    xor r8, r8

    ret

obtener_4_digitos:
    ; 1er digito
    ; 6 bits de la izquierda del primer byte
    xor r9, r9               ; vaciamos r9b
    mov r9b, [primerByte]      ; movemos a r9b una copia de primerByte
    and r9b, 0b11111100        ; eliminamos los 2 bits de la derecha
    shr r9b, 2                 ; corremos los 6 bits de la izquierda 2 posiciones a la derecha
    mov [primerCaracter], r9b  ; guardamos en primerCaracter

    ; 2do digito
    ; 2 bits de la derecha del primer byte
    ; 4 bits de la izquierda del segundo byte
    xor r9, r9
    xor r10, r10

    mov r9b, [primerByte]      ; movemos a r9b una copia de primerByte
    and r9b, 0b00000011        
    shl r9b, 4                 

    mov r10b, [segundoByte]    ; movemos a r9b una copia de segundoByte
    and r10b, 0b11110000        
    shr r10b, 4                 

    or r9b, r10b
    mov [segundoCaracter], r9b

    ; 3er digito
    ; 4 bits de la derecha del segundo byte
    ; 2 bits de la izquierda del tercer byte
    xor r9, r9
    xor r10, r10

    mov r9b, [segundoByte]      ; movemos a r9b una copia de segundoByte
    and r9b, 0b00001111        
    shl r9b, 2                

    mov r10b, [tercerByte]    ; movemos a r9b una copia de tercerByte
    and r10b, 0b11000000        
    shr r10b, 6                 

    or r9b, r10b
    mov [tercerCaracter], r9b

    ; 4to digito
    ; 6 bits de la derecha del tercer byte
    xor r9, r9                 ; vaciamos r9b
    mov r9b, [tercerByte]      
    and r9b, 0b00111111        
    mov [cuartoCaracter], r9b  ; guardamos en cuartoC

    xor r9, r9
    xor r10, r10
    
    ret

codificar_un_caracter:
    ; r11 sera el 'puntero' que usaremos para iterar sobre TablaConversion
    xor r11, r11 ; vaciamos r11
    add r11, TablaConversion ; le sumamos al registro r11 la direccion de memoria de TablaConversion

    iterar_hasta_caracter:
        inc r11
        loop iterar_hasta_caracter
    testLuego:
    xor rax, rax

    ; r14 es el 'puntero' que usaremos para iterar sobre secuenciaImprimibleA
    mov al, [r11]                 ; Movemos el valor actual del puntero r11, a al
    add [r14], al
    add r14, 1

    ret

codificar_4_caracteres:
    ; ----------------------------- primer caracter ----------------------------
    xor rcx, rcx
    mov cl, [primerCaracter]

    sub rsp, 8
    call codificar_un_caracter
    add rsp, 8

    ; ---------------------------- segundo caracter ----------------------------
    xor rcx, rcx
    mov cl, [segundoCaracter]

    sub rsp, 8
    call codificar_un_caracter
    add rsp, 8

    ; ----------------------------- tercer caracter ----------------------------
    xor rcx, rcx
    mov cl, [tercerCaracter]

    sub rsp, 8
    call codificar_un_caracter
    add rsp, 8

    ; ----------------------------- cuarto caracter ----------------------------
    xor rcx, rcx
    mov cl, [cuartoCaracter]

    sub rsp, 8
    call codificar_un_caracter
    add rsp, 8
 

    xor rcx, rcx
    xor rax, rax

    ret