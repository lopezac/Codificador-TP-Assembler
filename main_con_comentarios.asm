; Entrada del programa principal
global main

; Sección de datos inicializados
section .data
    ; Secuencia binaria que se codificará en Base64
	secuenciaBinariaA	  db 0xC4, 0x94, 0x37, 0x95, 0x63, 0xA2, 0x1D, 0x3C 
						  db 0x86, 0xFC, 0x22, 0xA9, 0x3D, 0x7C, 0xA4, 0x51 
						  db 0x63, 0x7C, 0x29, 0x04, 0x93, 0xBB, 0x65, 0x18 
	largoSecuenciaA		  db 0x18 ; Longitud de la secuencia binaria
    TablaConversion		  db "ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789+/", 0 ; Tabla Base64
    cantidadDeBytes       db 3 ; Cada iteración procesa 3 bytes
	indiceTablaConversion db 0 ; Índice usado para la tabla de conversión

; Sección para reservar espacio sin inicializar
section .bss
	secuenciaImprimibleA  resb 32 ; Espacio para almacenar la secuencia codificada
    cantidadDeIteraciones resb 1 ; Cantidad de veces que se iterará para procesar la secuencia
    primerByte            resb 1 ; Almacena el primer byte del trío
    segundoByte           resb 1 ; Almacena el segundo byte del trío
    tercerByte            resb 1 ; Almacena el tercer byte del trío
    primerCaracter        resb 1 ; Primer carácter Base64
    segundoCaracter       resb 1 ; Segundo carácter Base64
    tercerCaracter        resb 1 ; Tercer carácter Base64
    cuartoCaracter        resb 1 ; Cuarto carácter Base64

; Sección de código ejecutable
section .text

main:
    ; Calcular cuántas iteraciones necesitamos para procesar la secuencia
    xor rax, rax
    mov al, [largoSecuenciaA]
    div byte[cantidadDeBytes] ; Largo / 3
    mov [cantidadDeIteraciones], al
    xor rax, rax

    ; Configuración inicial
    mov rcx, [cantidadDeIteraciones] ; Número de iteraciones
    xor r15, r15
    add r15, secuenciaBinariaA ; Apuntar al inicio de la secuencia
    xor r14, r14
    add r14, secuenciaImprimibleA ; Apuntar al inicio de la secuencia de salida

inicio_de_codificacion:
    ; Obtener 3 bytes de la secuencia
    sub rsp, 8
    call obtener_3_bytes
    add rsp, 8

    ; Convertirlos en 4 caracteres Base64
    sub rsp, 8
    call obtener_4_digitos
    add rsp, 8

    ; Codificar esos caracteres con la tabla Base64
    sub rsp, 8
    call codificar_4_caracteres
    add rsp, 8

    ; Resetear los valores de los bytes/caracteres procesados
    xor byte[primerByte], 0
    xor byte[segundoByte], 0
    xor byte[tercerByte], 0
    xor byte[primerCaracter], 0
    xor byte[segundoCaracter], 0
    xor byte[tercerCaracter], 0
    xor byte[cuartoCaracter], 0

    ; Decrementar el contador de iteraciones y repetir
    loop inicio_de_codificacion

    ; Finalizar la cadena de salida con un 0 (null terminator)
    mov byte[r14], 0

    ret

; Obtiene los 3 bytes necesarios para una iteración
obtener_3_bytes:
    xor r8, r8
    mov r8b, [r15] ; Primer byte
    mov [primerByte], r8b
    inc r15

    xor r8, r8
    mov r8b, [r15] ; Segundo byte
    mov [segundoByte], r8b
    inc r15
    
    xor r8, r8
    mov r8b, [r15] ; Tercer byte
    mov [tercerByte], r8b
    inc r15

    ret

; Convierte los 3 bytes en 4 dígitos Base64
obtener_4_digitos:
    ; Calcular el primer carácter
    xor r9, r9
    mov r9b, [primerByte]
    and r9b, 0b11111100 ; Máscara para los primeros 6 bits
    shr r9b, 2 ; Desplazar esos bits a la derecha
    mov [primerCaracter], r9b

    ; Calcular el segundo carácter
    xor r9, r9
    xor r10, r10
    mov r9b, [primerByte]
    and r9b, 0b00000011 ; Tomar los últimos 2 bits
    shl r9b, 4 ; Desplazarlos a la izquierda
    mov r10b, [segundoByte]
    and r10b, 0b11110000 ; Tomar los primeros 4 bits del segundo byte
    shr r10b, 4 ; Desplazar esos bits
    or r9b, r10b ; Combinar ambos
    mov [segundoCaracter], r9b

    ; Calcular el tercer carácter
    xor r9, r9
    xor r10, r10
    mov r9b, [segundoByte]
    and r9b, 0b00001111 ; Tomar los últimos 4 bits
    shl r9b, 2 ; Desplazarlos
    mov r10b, [tercerByte]
    and r10b, 0b11000000 ; Tomar los primeros 2 bits del tercer byte
    shr r10b, 6 ; Desplazarlos
    or r9b, r10b ; Combinar
    mov [tercerCaracter], r9b

    ; Calcular el cuarto carácter
    xor r9, r9
    mov r9b, [tercerByte]
    and r9b, 0b00111111 ; Máscara para los últimos 6 bits
    mov [cuartoCaracter], r9b

    ret

; Codifica un solo carácter usando la tabla Base64
codificar_un_caracter:
    xor r11, r11
    add r11, TablaConversion ; Apuntar a la tabla

    xor rax, rax
    mov al, [r11 + r13] ; Obtener el carácter
    mov [r14], al ; Guardarlo en la secuencia de salida
    inc r14 ; Avanzar el puntero

    ret

; Codifica los 4 caracteres generados
codificar_4_caracteres:
    xor r13, r13
    mov r13b, [primerCaracter]

    sub rsp, 8
    call codificar_un_caracter
    add rsp, 8

    xor r13, r13
    mov r13b, [segundoCaracter]

    sub rsp, 8
    call codificar_un_caracter
    add rsp, 8

    xor r13, r13
    mov r13b, [tercerCaracter]

    sub rsp, 8
    call codificar_un_caracter
    add rsp, 8

    xor r13, r13
    mov r13b, [cuartoCaracter]

    sub rsp, 8
    call codificar_un_caracter
    add rsp, 8

    ret
