global main

;----------------------------------      VARIABLES CON CONTENIDO INICIAL      -----------------------------------
section .data
    ; la secuencia binaria que codificaremos a base64
    secuenciaBinariaA     db 0xC4, 0x94, 0x37, 0x95, 0x63, 0xA2, 0x1D, 0x3C 
                          db 0x86, 0xFC, 0x22, 0xA9, 0x3D, 0x7C, 0xA4, 0x51 
                          db 0x63, 0x7C, 0x29, 0x04, 0x93, 0xBB, 0x65, 0x18 
    largoSecuenciaA       db 0x18 ; aca ponemos la longitud de la secuencia
    ; la tabla de conversion de base64, que usaremos a lo largo del programa
    TablaConversion       db "ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789+/", 0
    cantidadDeBytes       db 3    ; aca decimos que trabajamos con bloques de 3 bytes


;----------------------------------     VARIABLES SIN CONTENIDO INICIAL      ------------------------------------
section .bss
    secuenciaImprimibleA  resb 32 ; aca guardamos la secuencia binaria codificada en Base64
    ; aca guardaremos los bytes de cada bloque de 3 bytes, en cada iteracion
    primerByte            resb 1
    segundoByte           resb 1
    tercerByte            resb 1 
    ; aca guardaremos los digitos de cada bloque de 3 bytes, en cada iteracion
    primerDigito          resb 1  
    segundoDigito         resb 1
    tercerDigito          resb 1 
    cuartoDigito          resb 1


;----------------------------------               INSTRUCCIONES              ------------------------------------
section .text


;----------------------------------           INICIO DEL PROGRAMA            ------------------------------------
main:
    ; calculamos cuantas iteraciones necesitamos
    xor rax, rax                  ; limpiamos rax
    mov al, [largoSecuenciaA]     ; aca movemos la longitud de la secuencia
    div byte[cantidadDeBytes]     ; aca dividimos por 3 para saber cuantos bloques hay
    
    xor rcx, rcx                  ; limpiamos rcx
    mov cl, al                    ; guardamos en rcx para iterar sobre la cantidad de bloques
    xor rax, rax                  ; limpiamos rax

    ; a lo largo del programa, r15 sera el puntero a la secuenciaBinariaA
    xor r15, r15                  ; limpiamos r15
    add r15, secuenciaBinariaA    ; apuntamos al inicio de la secuencia binaria

    ; a lo largo del programa, r14 sera el puntero a la secuenciaImprimibleA
    xor r14, r14                  ; limpiamos r14
    add r14, secuenciaImprimibleA ; apuntamos al inicio del resultado

    ; a lo largo del programa, r11 sera el puntero a la TablaConversion
    xor r11, r11
    add r11, TablaConversion      


;----------------------------------        INICIO DE LA CODIFICACION         ------------------------------------
inicio_de_codificacion:
    ; procesamos cada bloque de 3 bytes
    sub rsp, 8
    call obtener_3_bytes          ; aca leemos cada bloque de 3 bytes, en las variables auxiliares primerByte,
                                  ; segundoByte y tercerByte
    add rsp, 8

    sub rsp, 8
    call obtener_4_digitos        ; aca leemos en las variables auxiliares primerDigito, segundoDigito,
                                  ; tercerDigito y cuartoDigito, el resultado de dividir cada bloque de 3 bytes
                                  ; en 4 digitos binarios de 6 bits
    add rsp, 8

    sub rsp, 8
    call codificar_4_caracteres   ; aca convertimos los digitos en caracteres imprimibles en base64
    add rsp, 8

    ; limpiamos las variables para la proxima iteracion
    mov byte[primerByte], 0
    mov byte[segundoByte], 0
    mov byte[tercerByte], 0
    mov byte[primerDigito], 0
    mov byte[segundoDigito], 0
    mov byte[tercerDigito], 0
    mov byte[cuartoDigito], 0

    loop inicio_de_codificacion   ; repetimos para cada bloque
   
    mov byte[r14], 0              ; agregamos un 0 al final, indicando que termina la secuencia imprimible

    ret


;----------------------------------             RUTINAS INTERNAS             ------------------------------------


;----------------------------------             OBTENER 3 BYTES              ------------------------------------
obtener_3_bytes:
    ; aca leemos 3 bytes seguidos de la secuencia binaria
    xor r8, r8                    ; limpiamos r8
    mov r8b, [r15]                ; movemos en r8, el byte apuntado por secuenciaBinariaA
    mov [primerByte], r8b         ; guardamos en la variable auxiliar primerByte, el primer byte del bloque actual
    inc r15                       ; avanzamos al siguiente byte del bloque actual

    xor r8, r8
    mov r8b, [r15]
    mov [segundoByte], r8b
    inc r15
    
    xor r8, r8
    mov r8b, [r15]
    mov [tercerByte], r8b
    inc r15

    xor r8, r8                    ; limpiamos r8

    ret


;----------------------------------             OBTENER 4 DIGITOS            ------------------------------------
obtener_4_digitos:
    ; primer digito
    ; 6 bits de la izquierda del primer byte
    xor r9, r9                    ; limpiamos r15

    mov r9b, [primerByte]         
    and r9b, 0b11111100           ; aca usamos una mascara para tomar los primeros 6 bits
    shr r9b, 2                    ; movemos los bits 2 lugares a la derecha
    
    mov [primerDigito], r9b

    ; segundo digito
    ; 2 bits de la derecha del primer byte
    ; 4 bits de la izquierda del segundo byte
    xor r9, r9                    ; limpiamos r9
    xor r10, r10                  ; limpiamos r10

    mov r9b, [primerByte]
    and r9b, 0b00000011           ; aca usamos una mascara para tomar los 2 ultimos bits
    shl r9b, 4                    ; movemos los bits 4 lugares a la izquierda

    mov r10b, [segundoByte]
    and r10b, 0b11110000          ; aca usamos una mascara para tomar los primeros 4 bits
    shr r10b, 4                   ; movemos los bits 4 lugares a la derecha

    or r9b, r10b                  ; combinamos los bits
    
    mov [segundoDigito], r9b

    ; tercer digito
    ; 4 bits de la derecha del segundo byte
    ; 2 bits de la izquierda del tercer byte
    xor r9, r9
    xor r10, r10

    mov r9b, [segundoByte]
    and r9b, 0b00001111           ; aca usamos una mascara para tomar los ultimos 4 bits
    shl r9b, 2                    ; movemos los bits 2 lugares a la izquierda

    mov r10b, [tercerByte]
    and r10b, 0b11000000          ; aca usamos una mascara para tomar los primeros 2 bits
    shr r10b, 6                   ; movemos los bits 6 lugares a la derecha

    or r9b, r10b                  ; combinamos los bits
    
    mov [tercerDigito], r9b

    ; cuarto digito
    ; 6 bits de la derecha del tercer byte
    xor r9, r9                    ; limpiamos r9
    mov r9b, [tercerByte]         ; aca tomamos los ultimos 6 bits
    and r9b, 0b00111111
    mov [cuartoDigito], r9b

    xor r9, r9                    ; limpiamos r9
    xor r10, r10                  ; limpiamos r10

    ret


;----------------------------------          CODIFICAR 4 CARACTERES           -----------------------------------
codificar_4_caracteres:
    ; traducimos los 4 digitos a caracteres base64
    ; primer caracter
    xor r13, r13                  ; limpiamos r13
    mov r13b, [primerDigito]    ; movemos a r13 el primerDigito a codificar

    sub rsp, 8
    call codificar_un_caracter    ; agregamos a secuenciaImprimibleA el primerDigito codificado en base64
    add rsp, 8

    ; segundo caracter
    xor r13, r13                  ; limpiamos r13
    mov r13b, [segundoDigito]   ; movemos a r13 el segundoDigito a codificar

    sub rsp, 8
    call codificar_un_caracter    ; agregamos a secuenciaImprimibleA el segundoDigito codificado en base64
    add rsp, 8

    ; tercer caracter
    xor r13, r13                  ; limpiamos r13
    mov r13b, [tercerDigito]    ; movemos a r13 el tercerDigito a codificar

    sub rsp, 8
    call codificar_un_caracter    ; agregamos a secuenciaImprimibleA el tercerDigito codificado en base64
    add rsp, 8

    ; cuarto caracter
    xor r13, r13                  ; limpiamos r13
    mov r13b, [cuartoDigito]    ; movemos a r13 el cuartoDigito a codificar

    sub rsp, 8
    call codificar_un_caracter    ; agregamos a secuenciaImprimibleA el cuartoDigito codificado en base64
    add rsp, 8

    xor r13, r13                  ; limpiamos r13
    xor rax, rax                  ; limpiamos rax

    ret


;----------------------------------          CODIFICAR UN CARACTER           ------------------------------------
codificar_un_caracter:
    ; buscamos el caracter correspondiente en la tabla de conversion
    xor rax, rax                  ; limpiamos rax
    
    mov al, [r11 + r13]           ; guardamos en el registro al, el caracter correspondiente en la TablaConversion al
                                  ; digito almacenado en r13
    mov [r14], al                 ; guardamos el digito codificado en la secuenciaImprimibleA
    inc r14                       ; avanzamos al siguiente caracter de la secuenciaImprimibleA

    ret
