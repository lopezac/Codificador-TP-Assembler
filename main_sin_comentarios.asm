global main

section .data
	secuenciaBinariaA	  db 0xC4, 0x94, 0x37, 0x95, 0x63, 0xA2, 0x1D, 0x3C 
						  db 0x86, 0xFC, 0x22, 0xA9, 0x3D, 0x7C, 0xA4, 0x51 
						  db 0x63, 0x7C, 0x29, 0x04, 0x93, 0xBB, 0x65, 0x18 
	largoSecuenciaA		  db 0x18
    TablaConversion		  db "ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789+/", 0
    cantidadDeBytes       db 3
	indiceTablaConversion db 0

section .bss
	secuenciaImprimibleA  resb 32
    cantidadDeIteraciones resb 1
    primerByte            resb 1
    segundoByte           resb 1
    tercerByte            resb 1
    primerCaracter        resb 1
    segundoCaracter       resb 1
    tercerCaracter        resb 1
    cuartoCaracter        resb 1

section .text

main:
    xor rax, rax
    mov al, [largoSecuenciaA]
    div byte[cantidadDeBytes]
    mov [cantidadDeIteraciones], al
    xor rax, rax

    mov rcx, [cantidadDeIteraciones]
    xor r15, r15
    add r15, secuenciaBinariaA

    xor r14, r14
    add r14, secuenciaImprimibleA
    
inicio_de_codificacion:
    sub rsp, 8
    call obtener_3_bytes
    add rsp, 8

    sub rsp, 8
    call obtener_4_digitos
    add rsp, 8

    sub rsp, 8
    call codificar_4_caracteres
    add rsp, 8

    xor byte[primerByte], 0
    xor byte[segundoByte], 0
    xor byte[tercerByte], 0
    xor byte[primerCaracter], 0
    xor byte[segundoCaracter], 0
    xor byte[tercerCaracter], 0
    xor byte[cuartoCaracter], 0

    loop inicio_de_codificacion

    mov byte[r14], 0

    ret

obtener_3_bytes:
    xor r8, r8
    mov r8b, [r15]
    mov [primerByte], r8b
    inc r15

    xor r8, r8
    mov r8b, [r15]
    mov [segundoByte], r8b
    inc r15
    
    xor r8, r8
    mov r8b, [r15]
    mov [tercerByte], r8b
    inc r15

    xor r8, r8

    ret

obtener_4_digitos:
    xor r9, r9
    mov r9b, [primerByte]
    and r9b, 0b11111100
    shr r9b, 2
    mov [primerCaracter], r9b

    xor r9, r9
    xor r10, r10

    mov r9b, [primerByte]
    and r9b, 0b00000011        
    shl r9b, 4                 

    mov r10b, [segundoByte]
    and r10b, 0b11110000        
    shr r10b, 4                 

    or r9b, r10b
    mov [segundoCaracter], r9b

    xor r9, r9
    xor r10, r10

    mov r9b, [segundoByte]
    and r9b, 0b00001111        
    shl r9b, 2                

    mov r10b, [tercerByte]
    and r10b, 0b11000000        
    shr r10b, 6                 

    or r9b, r10b
    mov [tercerCaracter], r9b

    xor r9, r9
    mov r9b, [tercerByte]      
    and r9b, 0b00111111        
    mov [cuartoCaracter], r9b

    xor r9, r9
    xor r10, r10
    
    ret

codificar_un_caracter:
    xor r11, r11
    add r11, TablaConversion

    xor rax, rax

    mov al, [r11 + r13]
    mov [r14], al
    inc r14

    ret

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

    xor r13, r13
    xor rax, rax

    ret
