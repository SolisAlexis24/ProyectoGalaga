title "Proyecto: Galaga" ;codigo opcional. Descripcion breve del programa, el texto entrecomillado se imprime como cabecera en cada página de código
	.model small	;directiva de modelo de memoria, small => 64KB para memoria de programa y 64KB para memoria de datos
	.386			;directiva para indicar version del procesador
	.stack 128 		;Define el tamano del segmento de stack, se mide en bytes
	.data			;Definicion del segmento de datos
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;Definición de constantes
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;Valor ASCII de caracteres para el marco del programa
marcoEsqInfIzq 		equ 	200d 	;'╚'
marcoEsqInfDer 		equ 	188d	;'╝'
marcoEsqSupDer 		equ 	187d	;'╗'
marcoEsqSupIzq 		equ 	201d 	;'╔'
marcoCruceVerSup	equ		203d	;'╦'
marcoCruceHorDer	equ 	185d 	;'╣'
marcoCruceVerInf	equ		202d	;'╩'
marcoCruceHorIzq	equ 	204d 	;'╠'
marcoCruce 			equ		206d	;'╬'
marcoHor 			equ 	205d 	;'═'
marcoVer 			equ 	186d 	;'║'
;Valores ASCII para las teclas del juego
teclaA equ 61h
teclaD equ 64h
teclaEsp equ 20h
;Atributos de color de BIOS
;Valores de color para carácter
cNegro 			equ		00h
cAzul 			equ		01h
cVerde 			equ 	02h
cCyan 			equ 	03h
cRojo 			equ 	04h
cMagenta 		equ		05h
cCafe 			equ 	06h
cGrisClaro		equ		07h
cGrisOscuro		equ		08h
cAzulClaro		equ		09h
cVerdeClaro		equ		0Ah
cCyanClaro		equ		0Bh
cRojoClaro		equ		0Ch
cMagentaClaro	equ		0Dh
cAmarillo 		equ		0Eh
cBlanco 		equ		0Fh
;Valores de color para fondo de carácter
bgNegro 		equ		00h
bgAzul 			equ		10h
bgVerde 		equ 	20h
bgCyan 			equ 	30h
bgRojo 			equ 	40h
bgMagenta 		equ		50h
bgCafe 			equ 	60h
bgGrisClaro		equ		70h
bgGrisOscuro	equ		80h
bgAzulClaro		equ		90h
bgVerdeClaro	equ		0A0h
bgCyanClaro		equ		0B0h
bgRojoClaro		equ		0C0h
bgMagentaClaro	equ		0D0h
bgAmarillo 		equ		0E0h
bgBlanco 		equ		0F0h
;Valores para delimitar el área de juego
lim_superior 	equ		1
lim_inferior 	equ		23
lim_izquierdo 	equ		1
lim_derecho 	equ		39
lim_col_izq		equ		lim_izquierdo+2
lim_col_der		equ		lim_derecho-2
;Valores de referencia para la posición inicial del jugador
ini_columna 	equ 	lim_derecho/2
ini_renglon 	equ 	22
ren_bala_in		equ     19 ;Renglon de las balas del jugador cuando son disparadas

;Valores para la posición de los controles e indicadores dentro del juego
;Lives
lives_col 		equ  	lim_derecho+7
lives_ren 		equ  	4

;Scores
hiscore_ren	 	equ 	11
hiscore_col 	equ 	lim_derecho+7
score_ren	 	equ 	13
score_col 		equ 	lim_derecho+7

;Botón STOP
stop_col 		equ 	lim_derecho+10
stop_ren 		equ 	19
stop_izq 		equ 	stop_col-1
stop_der 		equ 	stop_col+1
stop_sup 		equ 	stop_ren-1
stop_inf 		equ 	stop_ren+1

;Botón PAUSE
pause_col 		equ 	stop_col+10
pause_ren 		equ 	19
pause_izq 		equ 	pause_col-1
pause_der 		equ 	pause_col+1
pause_sup 		equ 	pause_ren-1
pause_inf 		equ 	pause_ren+1

;Botón PLAY
play_col 		equ 	pause_col+10
play_ren 		equ 	19
play_izq 		equ 	play_col-1
play_der 		equ 	play_col+1
play_sup 		equ 	play_ren-1
play_inf 		equ 	play_ren+1

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

;////////////////////////////////////////////////////
;Definición de variables
;////////////////////////////////////////////////////
titulo 			db 		"GALAGA"
scoreStr 		db 		"SCORE"
hiscoreStr		db 		"HI-SCORE"
livesStr		db 		"LIVES"
gameOver		db 		"GAME OVER"		;Muestra al usuario que ha perdido
blank			db 		"     "
player_lives 	db 		3
player_score 	dw 		0
player_hiscore 	dw 		0
filename		db		"C:\galaga\hiscore.txt", 0
manejador_arc	dw		?

player_col		db 		ini_columna 	;posicion en columna del jugador
player_ren		db 		ini_renglon 	;posicion en renglon del jugador

enemy_col		db 		ini_columna 	;posicion en columna del enemigo
enemy_ren		db 		3 				;posicion en renglon del enemigo
direccion		db		0
num_mov_e		db		0
mov_abajo		db		0				;Variable booleana que indica si el ultimo movimiento vertical ue hacia arriba

col_aux 		db 		0  		;variable auxiliar para operaciones con posicion - columna
ren_aux 		db 		0 		;variable auxiliar para operaciones con posicion - renglon

conta 			db 		0 		;contador
conta_movs		db      0		;Contador que contabiliza los movimientos del jugador
cont_balp		dw		0
cont_bale		dw		0
cont_mov_e		dw		0

;; Variables de ayuda para lectura de tiempo del sistema
tick_ms			dw 		55 		;55 ms por cada tick del sistema, esta variable se usa para operación de MUL convertir ticks a segundos
mil				dw		1000 	;1000 auxiliar para operación DIV entre 1000
diez 			dw 		10 		;10 auxiliar para operaciones
sesenta			db 		60 		;60 auxiliar para operaciones
status 			db 		0 		;0 stop, 1 play, 2 pause
ticks 			dw		0 		;Variable para almacenar el número de ticks del sistema y usarlo como referencia

;Variables que sirven de parámetros de entrada para el procedimiento IMPRIME_BOTON
boton_caracter 	db 		0
boton_renglon 	db 		0
boton_columna 	db 		0
boton_color		db 		0
boton_bg_color	db 		0
balap_en_pant	db		0 ;Esta variable verifica si ya existe una bala del jugador dibujada en pantalla
bala_enemiga	db		0
balap_x			db		ini_columna
balap_y			db		ren_bala_in
balae_x			db		ini_columna
balae_y			db		6

;Auxiliar para calculo de coordenadas del mouse en modo Texto
ocho			db 		8
;Cuando el driver del mouse no está disponible
no_mouse		db 	'No se encuentra driver de mouse. Presione [enter] para salir$'
;////////////////////////////////////////////////////
;Cuando no se puede encontrar el archivo
error_abrir		db 	'No se encuentra el archivo. Presione [enter] para salir$'
error_leer		db 	'No se puede leer el archivo. Presione [enter] para salir$'
error_escribir		db 	'No se puede escribir el archivo. Presione [enter] para salir$'


;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;Macros;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;
;clear - Limpia pantalla
clear macro
	mov ax,0003h 	;ah = 00h, selecciona modo video
					;al = 03h. Modo texto, 16 colores
	int 10h		;llama interrupcion 10h con opcion 00h. 
				;Establece modo de video limpiando pantalla
endm

;posiciona_cursor - Cambia la posición del cursor a la especificada con 'renglon' y 'columna' 
posiciona_cursor macro renglon,columna
	mov dh,renglon	;dh = renglon
	mov dl,columna	;dl = columna
	mov bx,0
	mov ax,0200h 	;preparar ax para interrupcion, opcion 02h
	int 10h 		;interrupcion 10h y opcion 02h. Cambia posicion del cursor
endm 

;inicializa_ds_es - Inicializa el valor del registro DS y ES
inicializa_ds_es 	macro
	mov ax,@data
	mov ds,ax
	mov es,ax 		;Este registro se va a usar, junto con BP, para imprimir cadenas utilizando interrupción 10h
endm

;muestra_cursor_mouse - Establece la visibilidad del cursor del mouser
muestra_cursor_mouse	macro
	mov ax,1		;opcion 0001h
	int 33h			;int 33h para manejo del mouse. Opcion AX=0001h
					;Habilita la visibilidad del cursor del mouse en el programa
endm

;posiciona_cursor_mouse - Establece la posición inicial del cursor del mouse
posiciona_cursor_mouse	macro columna,renglon
	mov dx,renglon
	mov cx,columna
	mov ax,4		;opcion 0004h
	int 33h		;int 33h para manejo del mouse. Opcion AX=0001h
					;Habilita la visibilidad del cursor del mouse en el programa
endm

;oculta_cursor_teclado - Oculta la visibilidad del cursor del teclado
oculta_cursor_teclado	macro
	mov ah,01h 		;Opcion 01h
	mov cx,2607h 	;Parametro necesario para ocultar cursor
	int 10h 		;int 10, opcion 01h. Cambia la visibilidad del cursor del teclado
endm

;apaga_cursor_parpadeo - Deshabilita el parpadeo del cursor cuando se imprimen caracteres con fondo de color
;Habilita 16 colores de fondo
apaga_cursor_parpadeo	macro
	mov ax,1003h 		;Opcion 1003h
	xor bl,bl 			;BL = 0, parámetro para int 10h opción 1003h
  	int 10h 			;int 10, opcion 01h. Cambia la visibilidad del cursor del teclado
endm

;imprime_caracter_color - Imprime un caracter de cierto color en pantalla, especificado por 'caracter', 'color' y 'bg_color'. 
;Los colores disponibles están en la lista a continuacion;
; Colores:
; 0h: Negro
; 1h: Azul
; 2h: Verde
; 3h: Cyan
; 4h: Rojo
; 5h: Magenta
; 6h: Cafe
; 7h: Gris Claro
; 8h: Gris Oscuro
; 9h: Azul Claro
; Ah: Verde Claro
; Bh: Cyan Claro
; Ch: Rojo Claro
; Dh: Magenta Claro
; Eh: Amarillo
; Fh: Blanco
; utiliza int 10h opcion 09h
; 'caracter' - caracter que se va a imprimir
; 'color' - color que tomará el caracter
; 'bg_color' - color de fondo para el carácter en la celda
; Cuando se define el color del carácter, éste se hace en el registro BL:
; La parte baja de BL (los 4 bits menos significativos) define el color del carácter
; La parte alta de BL (los 4 bits más significativos) define el color de fondo "background" del carácter
imprime_caracter_color macro caracter,color,bg_color
	mov ah,09h				;preparar AH para interrupcion, opcion 09h
	mov al,caracter 		;AL = caracter a imprimir
	mov bh,0				;BH = numero de pagina
	mov bl,color 			
	or bl,bg_color 			;BL = color del caracter
							;'color' define los 4 bits menos significativos 
							;'bg_color' define los 4 bits más significativos 
	mov cx,1				;CX = numero de veces que se imprime el caracter
							;CX es un argumento necesario para opcion 09h de int 10h
	int 10h 				;int 10h, AH=09h, imprime el caracter en AL con el color BL
endm

;imprime_caracter_color - Imprime un caracter de cierto color en pantalla, especificado por 'caracter', 'color' y 'bg_color'. 
; utiliza int 10h opcion 09h
; 'cadena' - nombre de la cadena en memoria que se va a imprimir
; 'long_cadena' - longitud (en caracteres) de la cadena a imprimir
; 'color' - color que tomarán los caracteres de la cadena
; 'bg_color' - color de fondo para los caracteres en la cadena
imprime_cadena_color macro cadena,long_cadena,color,bg_color
	mov ah,13h				;preparar AH para interrupcion, opcion 13h
	lea bp,cadena 			;BP como apuntador a la cadena a imprimir
	mov bh,0				;BH = numero de pagina
	mov bl,color 			
	or bl,bg_color 			;BL = color del caracter
							;'color' define los 4 bits menos significativos 
							;'bg_color' define los 4 bits más significativos 
	mov cx,long_cadena		;CX = longitud de la cadena, se tomarán este número de localidades a partir del apuntador a la cadena
	int 10h 				;int 10h, AH=09h, imprime el caracter en AL con el color BL
endm

;lee_mouse - Revisa el estado del mouse
;Devuelve:
;;BX - estado de los botones
;;;Si BX = 0000h, ningun boton presionado
;;;Si BX = 0001h, boton izquierdo presionado
;;;Si BX = 0002h, boton derecho presionado
;;;Si BX = 0003h, boton izquierdo y derecho presionados
; (400,120) => 80x25 =>Columna: 400 x 80 / 640 = 50; Renglon: (120 x 25 / 200) = 15 => 50,15
;;CX - columna en la que se encuentra el mouse en resolucion 640x200 (columnas x renglones)
;;DX - renglon en el que se encuentra el mouse en resolucion 640x200 (columnas x renglones)
lee_mouse	macro
	mov ax,0003h
	int 33h
endm

;comprueba_mouse - Revisa si el driver del mouse existe
comprueba_mouse 	macro
	mov ax,0		;opcion 0
	int 33h			;llama interrupcion 33h para manejo del mouse, devuelve un valor en AX
					;Si AX = 0000h, no existe el driver. Si AX = FFFFh, existe driver
endm
;revisa_teclado - Revisa que tecla se ha presionado y si esta coincide con a (izquierda), d (derecha)
; o " " (disparar). Si alguna de las reclas coincide, se llama al procedimeitno que realiza la accion
revisa_teclado		macro
	mov ah, 01h
	int 16h ;Verifica si hay alguna tecla pendiente de ser leída utilizando la interrupción int 16h con la opción AH=01h.
	jz term1
	mov ah, 00h; Si hay una tecla pendiente de ser leída, se utiliza la interrupción int 16h con la opción AH=00h para leer la tecla del teclado y guardar el valor ASCII en el registro AL.
	int 16h
	cmp al, teclaA ; Si AL = teclaA, se presionó a
	je izquierdaPlayer ;Salta a la etiqueta para llamar al procedimiento de mover a la izquierda
	cmp al, teclaD ; Si AL = teclaD, se presionó d
	je derechaPlayer ; Salta a la etiqueta para llamar al procedimiento de mover a la derecha
	cmp al, 0Dh ; Boton [enter] para salir
	je salir
	jmp term1 ;Sino es ninguna de las anteriores se salta al final del macro para no hacer nada
	izquierdaPlayer:
		call MOVER_IZQUIERDA_PLAYER ;Se llama al procedimiento de mover a la izquierda al jugardor
		jmp term1
	derechaPlayer:
		call MOVER_DERECHA_PLAYER ;Se llama al procedimiento de mover a la derecha al jugardor
		jmp term1
	term1:
endm

;Devuelve los limites izquierdo y derecho del enemigo en al y ah respectivamente
calcular_limites_enemigo	macro
	mov bl, enemy_col
	mov bh, enemy_ren
	sub bl, 2
	mov al, bl ;limite izquierdo del enemigo en al
	add bl, 4
	mov ah, bl ;limite derecho del enemigo en ah
	endm

;Devuelve los limites izquierdo y derecho del jugador en al y ah respectivamente
calcular_limites_jugador	macro
	mov bl, player_col
	mov bh, player_ren
	sub bl, 2
	mov al, bl ;limite izquierdo del jugador en al
	add bl, 4
	mov ah, bl ;limite derecho del jugador en ah
	endm

;Macro para detectra la colision de una bala con el enemigo
detectar_colision_en		macro
	calcular_limites_enemigo
	cmp [balap_x], al
	jb no_colision ;si balap_x < limite izq. del enemigo, no hay colision
	cmp [balap_x], ah
	jg no_colision ;si balap_x > limite der. del enemigo, no hay colision
	mov bh, [enemy_ren] 
	add bh, 3
	cmp [balap_y], bh ;si balap_y >= bh, no hay colision
	ja no_colision
	colision:
		call BLINK_ENEMY
		call BORRA_ENEMIGO
		mov [enemy_col], ini_columna ;Coloca al enemigo en su columna original
		mov [enemy_ren], 3 ;Coloca al enemigo en su renglon inicial
		mov [mov_abajo], 0 ;Los movimientos del enemigo hacia abajo se resetean
		inc player_score
		call IMPRIME_SCORE
		mov bx, player_score
		cmp bx, player_hiscore
		jbe no_colision
		mov player_hiscore, bx
		call IMPRIME_HISCORE
		guardar_hiscore
	no_colision:
	endm

;Macro para detectar la colision de una bala con el jugador
detectar_colision		macro
	calcular_limites_jugador
	cmp [balae_x], al
	jb no_colision_jug ;si balap_x < limite izq. del jugador, no hay colision
	cmp [balae_x], ah
	jg no_colision_jug ;si balap_x > limite der. del jugador, no hay colision
	cmp [balae_y], 20 ;si balap_y <= 18, no hay colision
	jbe no_colision_jug
	colision_jug:
		call BLINK_PLAYER
		cmp player_lives, 1
		je fin_juego
		call BORRAR_LIVES
		dec player_lives
		call IMPRIME_LIVES
		call IMPRIME_JUGADOR
	no_colision_jug:
	endm

;Macro que lee el contador de tics y lo guarda en cualquiera que sea contador
	read_time	macro contador
	mov ah, 0
	int 1Ah
	mov contador, dx
	endm

;Macro que lee el contador de tics y lo resta con culquier contador anterior y lo compara con un espaciado
	calcular_tiempo		macro contador, espaciado
	mov ah, 0
	int 1Ah
	sub dx, contador
	cmp dx, espaciado
	endm

;Macro para leer el hiscore del archivo
	leer_hiscore	macro
	;Abrir
	mov ah, 3Dh
	mov al, 2 ;Abrir el archivo en modo lectura
	lea dx, filename
	int 21h
	jc error_al_abrir
	mov manejador_arc, ax
	;Leer
	mov ah, 3Fh
	mov bx, manejador_arc
	lea dx, player_hiscore
	mov cx, 2
	int 21h
	jc error_al_leer
	;Cerrar
	mov ah, 3Eh
	mov bx, manejador_arc
	int 21h
	endm

;Macro para guardar el highscore en el archivo
	guardar_hiscore	macro
	;Abrir archivo
	mov ah, 3Dh
	mov al, 2 ;Abrir el archivo en modo lectura
	lea dx, filename
	int 21h
	jc error_al_abrir
	mov manejador_arc, ax
	;Escribir
	mov ah, 40h
	mov bx, manejador_arc
	mov cx, 2
	lea dx, player_hiscore
	int 21h
	jc error_al_escribir
	;Cerrar
	mov ah, 3Eh
	mov bx, manejador_arc
	int 21h
	endm

;Macro para verificar si el mouse se ha presionado, y si es asi, si ha sido en algun boton de la pantalla
	verificar_botones	macro
	lee_mouse
	test bx,0001h 		
	jz principal ;Se revisa si se hizo clic en el mouse
	conversion_mouse_p:
	;Leer la posicion del mouse y hacer la conversion a resolucion
	;80x25 (columnas x renglones) en modo texto
	mov ax,dx 			;Copia DX en AX. DX es un valor entre 0 y 199 (renglon)
	div [ocho] 			;Division de 8 bits
						;divide el valor del renglon en resolucion 640x200 en donde se encuentra el mouse
						;para obtener el valor correspondiente en resolucion 80x25
	xor ah,ah 			;Descartar el residuo de la division anterior
	mov dx,ax 			;Copia AX en DX. AX es un valor entre 0 y 24 (renglon)

	mov ax,cx 			;Copia CX en AX. CX es un valor entre 0 y 639 (columna)
	div [ocho] 			;Division de 8 bits
						;divide el valor de la columna en resolucion 640x200 en donde se encuentra el mouse
						;para obtener el valor correspondiente en resolucion 80x25
	xor ah,ah 			;Descartar el residuo de la division anterior
	mov cx,ax 			;Copia AX en CX. AX es un valor entre 0 y 79 (columna)
	;Aquí se revisa si se hizo clic en el botón izquierdo
	test bx,0001h 		;Para revisar si el boton izquierdo del mouse fue presionado
	jz mouse 			;Si el boton izquierdo no fue presionado, vuelve a leer el estado del mouse
	cmp dx,0 ;Se revisa si es en el renglon del boton de salir
	je boton_x_p
	jmp renglon_botones_p ;Sino lo fue, se revisa si fue en el renglon de los botones
	boton_x_p:
	jmp boton_x1_p
	;Lógica para revisar si el mouse fue presionado en [X]
	;[X] se encuentra en renglon 0 y entre columnas 76 y 78
	boton_x1_p:
		cmp cx,76
		jge boton_x2_p
		jmp principal
	boton_x2_p:
		cmp cx,78
		jbe boton_x3_p
		jmp principal
	boton_x3_p:
		;Se cumplieron todas las condiciones
	jmp salir
	renglon_botones_p:
		cmp dx, 21 
		jbe	columnas_botones_p ;Se verifica si fue en el renglon de los botones
		jmp no_botones ;sino, se salta todo el proceso
	columnas_botones_p:
		cmp cx, 49         
		je boton_stop_p		
		cmp cx,48
		je boton_stop_p		
		cmp cx,50
		je boton_stop_p		;Verifica si es dentro del area del boton stop	

		cmp cx, 59  		
		je boton_pause
		cmp cx,	58
		je boton_pause
		cmp cx, 60
		je boton_pause		;Verifica si es dentro del area del boton pause

		cmp cx, 69 		
		je boton_play_p
		cmp cx, 68
		je boton_play_p
		cmp cx, 70
		je boton_play_p ;Verifica si es dentro del area del boton play
	boton_stop_p:
				mov [player_lives],3
				mov [player_score],0
				mov [enemy_ren], 3
				mov [enemy_col], ini_columna
				mov [player_ren], ini_renglon
				mov [player_col], ini_columna
				mov [balae_x], ini_columna
				mov [balae_y], 6
				mov [mov_abajo], 0
				mov [balap_x], ini_columna
				mov [balap_y], ren_bala_in
				jmp imprime_ui ;Resetea tod el juego y sus variables
	boton_pause:
		mov [status], 2
		jmp mouse_no_clic ;Se pausa el juego
	boton_play_p:
		jmp principal ;Se reanuda el juego
	no_botones:
	endm

;Macro para detectar la colisión entre el enemigo y el jugador
detectar_colision_enemigo_jugador macro
	cmp [enemy_ren], 18
	jb no_colision_enem_jug ;Se verifica si el renglon del enemigo es mayor a 18, esto quiere decir que puede chocar de lado con la nave del jugador
	verificar_columnas:
    calcular_limites_jugador
	cmp [enemy_col], al
	je colision_enem_jug 
	cmp [enemy_col], ah
	je colision_enem_jug ;Si los limites del jugador coinciden con la columna del enemigo, hay colision
	jmp no_colision_enem_jug
    colision_enem_jug:
        ; Código a ejecutar cuando hay colisión entre el enemigo y el jugador
        ; Por ejemplo, restar una vida al jugador, reiniciar posición del enemigo, etc.
        call BLINK_PLAYER
        cmp player_lives, 1
        je fin_juego
        call BORRAR_LIVES
        dec player_lives
        call IMPRIME_LIVES
        call IMPRIME_JUGADOR
		;;Se podiciona al enemigo en la posicion original
		mov [enemy_ren], 3
		mov [enemy_col], ini_columna
		mov [balae_x], ini_columna
		mov [balae_y], 6
		mov [mov_abajo], 0
    no_colision_enem_jug:
endm

;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;Fin Macros;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;

	.code
inicio:					;etiqueta inicio
	inicializa_ds_es
	comprueba_mouse		;macro para revisar driver de mouse
	xor ax,0FFFFh		;compara el valor de AX con FFFFh, si el resultado es zero, entonces existe el driver de mouse
	jz imprime_ui		;Si existe el driver del mouse, entonces salta a 'imprime_ui'
	;Si no existe el driver del mouse entonces se muestra un mensaje
	lea dx,[no_mouse]
	mov ax,0900h	;opcion 9 para interrupcion 21h
	int 21h			;interrupcion 21h. Imprime cadena.
	jmp teclado		;salta a 'teclado'
imprime_ui:
	leer_hiscore
	clear 					;limpia pantalla
	oculta_cursor_teclado	;oculta cursor del mouse
	apaga_cursor_parpadeo 	;Deshabilita parpadeo del cursor
	call DIBUJA_UI 			;procedimiento que dibuja marco de la interfaz
	muestra_cursor_mouse 	;hace visible el cursor del mouse

;En "mouse_no_clic" se revisa que el boton izquierdo del mouse no esté presionado
;Si el botón está presionado, continúa a la sección "mouse"
;si no, se mantiene indefinidamente en "mouse_no_clic" hasta que se suelte
mouse_no_clic:
	lee_mouse
	test bx,0001h
	jnz mouse_no_clic
;Lee el mouse y avanza hasta que se haga clic en el boton izquierdo
mouse:
	lee_mouse
conversion_mouse:
	;Leer la posicion del mouse y hacer la conversion a resolucion
	;80x25 (columnas x renglones) en modo texto
	mov ax,dx 			;Copia DX en AX. DX es un valor entre 0 y 199 (renglon)
	div [ocho] 			;Division de 8 bits
						;divide el valor del renglon en resolucion 640x200 en donde se encuentra el mouse
						;para obtener el valor correspondiente en resolucion 80x25
	xor ah,ah 			;Descartar el residuo de la division anterior
	mov dx,ax 			;Copia AX en DX. AX es un valor entre 0 y 24 (renglon)

	mov ax,cx 			;Copia CX en AX. CX es un valor entre 0 y 639 (columna)
	div [ocho] 			;Division de 8 bits
						;divide el valor de la columna en resolucion 640x200 en donde se encuentra el mouse
						;para obtener el valor correspondiente en resolucion 80x25
	xor ah,ah 			;Descartar el residuo de la division anterior
	mov cx,ax 			;Copia AX en CX. AX es un valor entre 0 y 79 (columna)
	;Aquí se revisa si se hizo clic en el botón izquierdo
	test bx,0001h 		;Para revisar si el boton izquierdo del mouse fue presionado
	jz mouse 			;Si el boton izquierdo no fue presionado, vuelve a leer el estado del mouse

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;Aqui va la lógica de la posicion del mouse;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
	;PLAY
	cmp dx, play_ren
	jge boton_play_renglon
	;Si el mouse fue presionado en el renglon 0
	;se va a revisar si fue dentro del boton [X]
	cmp dx,0
	je boton_x

	jmp mouse_no_clic
boton_x:
	jmp boton_x1

;Lógica para revisar si el mouse fue presionado en [X]
;[X] se encuentra en renglon 0 y entre columnas 76 y 78
boton_x1:
	cmp cx,76
	jge boton_x2
	jmp mouse_no_clic
boton_x2:
	cmp cx,78
	jbe boton_x3
	jmp mouse_no_clic
boton_x3:
	;Se cumplieron todas las condiciones
	jmp salir

;;Loop principal del juego
principal:
	call MOVIMIENTO_ENEMIGO
	call DISPARAR_ENEMIGO
	revisa_teclado
	call DISPARAR_PLAYER
	verificar_botones
	jmp principal

boton_play_Renglon:
	cmp dx, 21 				;verifica en que renglon se esta oprimiendo
	jbe boton_play_Columna
	jmp mouse_no_clic
	boton_play_Columna:
		cmp cx, 49           
		je boton_stop		
		cmp cx,48
		je boton_stop		
		cmp cx,50
		je boton_stop		;Verifica si es dentro del area del boton stop

		cmp cx, 68  		
		je boton_Play
		cmp cx, 69
		je boton_Play
		cmp cx, 70
		je boton_Play		;;Verifica si es dentro del area del boton play
		jmp mouse_no_clic   ;En caso de que no se oprima ningun boton
			boton_Play:
				cmp cx, 68
				jmp principal
			boton_stop:
				mov [player_lives],3
				mov [player_score],0
				mov [enemy_ren], 3
				mov [enemy_col], ini_columna
				mov [player_ren], ini_renglon
				mov [player_col], ini_columna
				mov [balae_x], ini_columna
				mov [balae_y], 6
				mov [mov_abajo], 0
				mov [balap_x], ini_columna
				mov [balap_y], ren_bala_in
				jmp imprime_ui
error_al_abrir:
	lea dx,[error_abrir]
	mov ax,0900h	;opcion 9 para interrupcion 21h
	int 21h			;interrupcion 21h. Imprime cadena.
	jmp teclado		;salta a 'teclado'

error_al_leer:
	lea dx,[error_leer]
	mov ax,0900h	;opcion 9 para interrupcion 21h
	int 21h			;interrupcion 21h. Imprime cadena.
	jmp teclado		;salta a 'teclado'

error_al_escribir:
	lea dx,[error_escribir]
	mov ax,0900h	;opcion 9 para interrupcion 21h
	int 21h			;interrupcion 21h. Imprime cadena.
	jmp teclado		;salta a 'teclado'

fin_juego:
	call BORRAR_LIVES
	call BORRA_JUGADOR
	posiciona_cursor lives_ren, lives_col
	imprime_cadena_color [gameOver], 9, cAmarillo, bgNegro
	jmp mouse_no_clic
;Si no se encontró el driver del mouse, muestra un mensaje y el usuario debe salir tecleando [enter]
teclado:
	mov ah,08h
	int 21h
	cmp al,0Dh		;compara la entrada de teclado si fue [enter]
	jnz teclado 	;Sale del ciclo hasta que presiona la tecla [enter]

salir:				;inicia etiqueta salir
	clear 			;limpia pantalla
	mov ax,4C00h	;AH = 4Ch, opción para terminar programa, AL = 0 Exit Code, código devuelto al finalizar el programa
	int 21h			;señal 21h de interrupción, pasa el control al sistema operativo

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;PROCEDIMIENTOS;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
	DIBUJA_UI proc
		;imprimir esquina superior izquierda del marco
		posiciona_cursor 0,0
		imprime_caracter_color marcoEsqSupIzq,cAmarillo,bgNegro
		
		;imprimir esquina superior derecha del marco
		posiciona_cursor 0,79
		imprime_caracter_color marcoEsqSupDer,cAmarillo,bgNegro
		
		;imprimir esquina inferior izquierda del marco
		posiciona_cursor 24,0
		imprime_caracter_color marcoEsqInfIzq,cAmarillo,bgNegro
		
		;imprimir esquina inferior derecha del marco
		posiciona_cursor 24,79
		imprime_caracter_color marcoEsqInfDer,cAmarillo,bgNegro
		
		;imprimir marcos horizontales, superior e inferior
		mov cx,78 		;CX = 004Eh => CH = 00h, CL = 4Eh 
	marcos_horizontales:
		mov [col_aux],cl
		;Superior
		posiciona_cursor 0,[col_aux]
		imprime_caracter_color marcoHor,cAmarillo,bgNegro
		;Inferior
		posiciona_cursor 24,[col_aux]
		imprime_caracter_color marcoHor,cAmarillo,bgNegro
		
		mov cl,[col_aux]
		loop marcos_horizontales

		;imprimir marcos verticales, derecho e izquierdo
		mov cx,23 		;CX = 0017h => CH = 00h, CL = 17h 
	marcos_verticales:
		mov [ren_aux],cl
		;Izquierdo
		posiciona_cursor [ren_aux],0
		imprime_caracter_color marcoVer,cAmarillo,bgNegro
		;Inferior
		posiciona_cursor [ren_aux],79
		imprime_caracter_color marcoVer,cAmarillo,bgNegro
		;Limite mouse
		posiciona_cursor [ren_aux],lim_derecho+1
		imprime_caracter_color marcoVer,cAmarillo,bgNegro

		mov cl,[ren_aux]
		loop marcos_verticales

		;imprimir marcos horizontales internos
		mov cx,79-lim_derecho-1 		
	marcos_horizontales_internos:
		push cx
		mov [col_aux],cl
		add [col_aux],lim_derecho
		;Interno superior 
		posiciona_cursor 8,[col_aux]
		imprime_caracter_color marcoHor,cAmarillo,bgNegro

		;Interno inferior
		posiciona_cursor 16,[col_aux]
		imprime_caracter_color marcoHor,cAmarillo,bgNegro

		mov cl,[col_aux]
		pop cx
		loop marcos_horizontales_internos

		;imprime intersecciones internas	
		posiciona_cursor 0,lim_derecho+1
		imprime_caracter_color marcoCruceVerSup,cAmarillo,bgNegro
		posiciona_cursor 24,lim_derecho+1
		imprime_caracter_color marcoCruceVerInf,cAmarillo,bgNegro

		posiciona_cursor 8,lim_derecho+1
		imprime_caracter_color marcoCruceHorIzq,cAmarillo,bgNegro
		posiciona_cursor 8,79
		imprime_caracter_color marcoCruceHorDer,cAmarillo,bgNegro

		posiciona_cursor 16,lim_derecho+1
		imprime_caracter_color marcoCruceHorIzq,cAmarillo,bgNegro
		posiciona_cursor 16,79
		imprime_caracter_color marcoCruceHorDer,cAmarillo,bgNegro

		;imprimir [X] para cerrar programa
		posiciona_cursor 0,76
		imprime_caracter_color '[',cAmarillo,bgNegro
		posiciona_cursor 0,77
		imprime_caracter_color 'X',cRojoClaro,bgNegro
		posiciona_cursor 0,78
		imprime_caracter_color ']',cAmarillo,bgNegro

		;imprimir título
		posiciona_cursor 0,37
		imprime_cadena_color [titulo],6,cAmarillo,bgNegro

		call IMPRIME_TEXTOS

		call IMPRIME_BOTONES

		call IMPRIME_DATOS_INICIALES

		call IMPRIME_SCORES

		call IMPRIME_LIVES

		ret
	endp

	IMPRIME_TEXTOS proc
		;Imprime cadena "LIVES"
		posiciona_cursor lives_ren,lives_col
		imprime_cadena_color livesStr,5,cGrisClaro,bgNegro

		;Imprime cadena "SCORE"
		posiciona_cursor score_ren,score_col
		imprime_cadena_color scoreStr,5,cGrisClaro,bgNegro

		;Imprime cadena "HI-SCORE"
		posiciona_cursor hiscore_ren,hiscore_col
		imprime_cadena_color hiscoreStr,8,cGrisClaro,bgNegro
		ret
	endp

	IMPRIME_BOTONES proc
		;Botón STOP
		mov [boton_caracter],254d		;Carácter '■'
		mov [boton_color],bgAmarillo 	;Background amarillo
		mov [boton_renglon],stop_ren 	;Renglón en "stop_ren"
		mov [boton_columna],stop_col 	;Columna en "stop_col"
		call IMPRIME_BOTON 				;Procedimiento para imprimir el botón
		;Botón PAUSE
		mov [boton_caracter],19d 		;Carácter '‼'
		mov [boton_color],bgAmarillo 	;Background amarillo
		mov [boton_renglon],pause_ren 	;Renglón en "pause_ren"
		mov [boton_columna],pause_col 	;Columna en "pause_col"
		call IMPRIME_BOTON 				;Procedimiento para imprimir el botón
		;Botón PLAY
		mov [boton_caracter],16d  		;Carácter '►'
		mov [boton_color],bgAmarillo 	;Background amarillo
		mov [boton_renglon],play_ren 	;Renglón en "play_ren"
		mov [boton_columna],play_col 	;Columna en "play_col"
		call IMPRIME_BOTON 				;Procedimiento para imprimir el botón
		ret
	endp

	IMPRIME_SCORES proc
		;Imprime el valor de la variable player_score en una posición definida
		call IMPRIME_SCORE
		;Imprime el valor de la variable player_hiscore en una posición definida
		call IMPRIME_HISCORE
		ret
	endp

	IMPRIME_SCORE proc
		;Imprime "player_score" en la posición relativa a 'score_ren' y 'score_col'
		mov [ren_aux],score_ren
		mov [col_aux],score_col+20
		mov bx,[player_score]
		call IMPRIME_BX
		ret
	endp

	IMPRIME_HISCORE proc
	;Imprime "player_score" en la posición relativa a 'hiscore_ren' y 'hiscore_col'
		mov [ren_aux],hiscore_ren
		mov [col_aux],hiscore_col+20
		mov bx,[player_hiscore]
		call IMPRIME_BX
		ret
	endp

	;BORRA_SCORES borra los marcadores numéricos de pantalla sustituyendo la cadena de números por espacios
	BORRA_SCORES proc
		call BORRA_SCORE
		call BORRA_HISCORE
		ret
	endp

	BORRA_SCORE proc
		posiciona_cursor score_ren,score_col+20 		;posiciona el cursor relativo a score_ren y score_col
		imprime_cadena_color blank,5,cBlanco,bgNegro 	;imprime cadena blank (espacios) para "borrar" lo que está en pantalla
		ret
	endp

	BORRA_HISCORE proc
		posiciona_cursor hiscore_ren,hiscore_col+20 	;posiciona el cursor relativo a hiscore_ren y hiscore_col
		imprime_cadena_color blank,5,cBlanco,bgNegro 	;imprime cadena blank (espacios) para "borrar" lo que está en pantalla
		ret
	endp

	;Imprime el valor del registro BX como entero sin signo (positivo)
	;Se imprime con 5 dígitos (incluyendo ceros a la izquierda)
	;Se usan divisiones entre 10 para obtener dígito por dígito en un LOOP 5 veces (una por cada dígito)
	IMPRIME_BX proc
		mov ax,bx
		mov cx,5
	div10:
		xor dx,dx
		div [diez]
		push dx
		loop div10
		mov cx,5
	imprime_digito:
		mov [conta],cl
		posiciona_cursor [ren_aux],[col_aux]
		pop dx
		or dl,30h
		imprime_caracter_color dl,cBlanco,bgNegro
		xor ch,ch
		mov cl,[conta]
		inc [col_aux]
		loop imprime_digito
		ret
	endp

	IMPRIME_DATOS_INICIALES proc
		call DATOS_INICIALES 		;inicializa variables de juego
		;imprime la 'nave' del jugador
		;borra la posición actual, luego se reinicia la posición y entonces se vuelve a imprimir
		call BORRA_JUGADOR
		mov [player_col], ini_columna
		mov [player_ren], ini_renglon
		;Imprime jugador
		call IMPRIME_JUGADOR

		;Borrar posicion actual del enemigo y reiniciar su posicion

		;Imprime enemigo
		call IMPRIME_ENEMIGO

		ret
	endp

	;Inicializa variables del juego
	DATOS_INICIALES proc
		mov [player_score],0
		mov [player_lives], 3
		ret
	endp

	;Imprime los caracteres ☻ que representan vidas. Inicialmente se imprime el número de 'player_lives'
	IMPRIME_LIVES proc
		xor cx,cx
		mov di,lives_col+20
		mov cl,[player_lives]
	imprime_live:
		push cx
		mov ax,di
		posiciona_cursor lives_ren,al
		imprime_caracter_color 2d,cCyanClaro,bgNegro
		add di,2
		pop cx
		loop imprime_live
		ret
	endp


	;Borra la ultima vida
	BORRAR_LIVES proc
		xor cx,cx
		mov di,lives_col+20
		mov cl,[player_lives]
	borra_live:
		push cx
		mov ax,di
		posiciona_cursor lives_ren,al
		imprime_caracter_color 178,cNegro,bgNegro
		add di,2
		pop cx
		loop borra_live
		ret
	endp

	;Imprime la nave del jugador, que recibe como parámetros las variables ren_aux y col_aux, que indican la posición central inferior
	PRINT_PLAYER proc
		posiciona_cursor [ren_aux],[col_aux]
		imprime_caracter_color 219,cBlanco,bgNegro
		dec [ren_aux]
		posiciona_cursor [ren_aux],[col_aux]
		imprime_caracter_color 219,cBlanco,bgNegro
		dec [ren_aux]
		posiciona_cursor [ren_aux],[col_aux]
		imprime_caracter_color 219,cBlanco,bgNegro
		add [ren_aux],2
		
		dec [col_aux]
		posiciona_cursor [ren_aux],[col_aux]
		imprime_caracter_color 219,cBlanco,bgNegro
		dec [ren_aux]
		posiciona_cursor [ren_aux],[col_aux]
		imprime_caracter_color 219,cBlanco,bgNegro
		inc [ren_aux]
		
		dec [col_aux]
		posiciona_cursor [ren_aux],[col_aux]
		imprime_caracter_color 219,cBlanco,bgNegro
		
		add [col_aux],3
		posiciona_cursor [ren_aux],[col_aux]
		imprime_caracter_color 219,cBlanco,bgNegro
		dec [ren_aux]
		posiciona_cursor [ren_aux],[col_aux]
		imprime_caracter_color 219,cBlanco,bgNegro
		inc [ren_aux]
		
		inc [col_aux]
		posiciona_cursor [ren_aux],[col_aux]
		imprime_caracter_color 219,cBlanco,bgNegro
		ret
	endp

	;Imprime la nave del jugador, que recibe como parámetros las variables ren_aux y col_aux, que indican la posición central inferior
	PRINT_PLAYER_AZUL proc
		posiciona_cursor [ren_aux],[col_aux]
		imprime_caracter_color 219,cAzul,bgNegro
		dec [ren_aux]
		posiciona_cursor [ren_aux],[col_aux]
		imprime_caracter_color 219,cAzul,bgNegro
		dec [ren_aux]
		posiciona_cursor [ren_aux],[col_aux]
		imprime_caracter_color 219,cAzul,bgNegro
		add [ren_aux],2
		
		dec [col_aux]
		posiciona_cursor [ren_aux],[col_aux]
		imprime_caracter_color 219,cAzul,bgNegro
		dec [ren_aux]
		posiciona_cursor [ren_aux],[col_aux]
		imprime_caracter_color 219,cAzul,bgNegro
		inc [ren_aux]
		
		dec [col_aux]
		posiciona_cursor [ren_aux],[col_aux]
		imprime_caracter_color 219,cAzul,bgNegro
		
		add [col_aux],3
		posiciona_cursor [ren_aux],[col_aux]
		imprime_caracter_color 219,cAzul,bgNegro
		dec [ren_aux]
		posiciona_cursor [ren_aux],[col_aux]
		imprime_caracter_color 219,cAzul,bgNegro
		inc [ren_aux]
		
		inc [col_aux]
		posiciona_cursor [ren_aux],[col_aux]
		imprime_caracter_color 219,cAzul,bgNegro
		ret
	endp

	;Borra la nave del jugador, que recibe como parámetros las variables ren_aux y col_aux, que indican la posición central de la barra
	DELETE_PLAYER proc
		;Implementar
		posiciona_cursor [ren_aux],[col_aux]
		imprime_caracter_color 219,cNegro,bgNegro
		dec [ren_aux]
		posiciona_cursor [ren_aux],[col_aux]
		imprime_caracter_color 219,cNegro,bgNegro
		dec [ren_aux]
		posiciona_cursor [ren_aux],[col_aux]
		imprime_caracter_color 219,cNegro,bgNegro
		add [ren_aux],2
		
		dec [col_aux]
		posiciona_cursor [ren_aux],[col_aux]
		imprime_caracter_color 219,cNegro,bgNegro
		dec [ren_aux]
		posiciona_cursor [ren_aux],[col_aux]
		imprime_caracter_color 219,cNegro,bgNegro
		inc [ren_aux]
		
		dec [col_aux]
		posiciona_cursor [ren_aux],[col_aux]
		imprime_caracter_color 219,cNegro,bgNegro
		
		add [col_aux],3
		posiciona_cursor [ren_aux],[col_aux]
		imprime_caracter_color 219,cNegro,bgNegro
		dec [ren_aux]
		posiciona_cursor [ren_aux],[col_aux]
		imprime_caracter_color 219,cNegro,bgNegro
		inc [ren_aux]
		
		inc [col_aux]
		posiciona_cursor [ren_aux],[col_aux]
		imprime_caracter_color 219,cNegro,bgNegro
		ret
	endp

	;Imprime la nave del enemigo
	PRINT_ENEMY proc
		posiciona_cursor [ren_aux],[col_aux]
		imprime_caracter_color 178,cRojo,bgNegro
		inc [ren_aux]
		posiciona_cursor [ren_aux],[col_aux]
		imprime_caracter_color 178,cRojo,bgNegro
		inc [ren_aux]
		posiciona_cursor [ren_aux],[col_aux]
		imprime_caracter_color 178,cRojo,bgNegro
		sub [ren_aux],2
		
		dec [col_aux]
		posiciona_cursor [ren_aux],[col_aux]
		imprime_caracter_color 178,cRojo,bgNegro
		inc [ren_aux]
		posiciona_cursor [ren_aux],[col_aux]
		imprime_caracter_color 178,cRojo,bgNegro
		dec [ren_aux]
		
		dec [col_aux]
		posiciona_cursor [ren_aux],[col_aux]
		imprime_caracter_color 178,cRojo,bgNegro
		
		add [col_aux],3
		posiciona_cursor [ren_aux],[col_aux]
		imprime_caracter_color 178,cRojo,bgNegro
		inc [ren_aux]
		posiciona_cursor [ren_aux],[col_aux]
		imprime_caracter_color 178,cRojo,bgNegro
		dec [ren_aux]
		
		inc [col_aux]
		posiciona_cursor [ren_aux],[col_aux]
		imprime_caracter_color 178,cRojo,bgNegro
		ret
	endp

	DELETE_ENEMY proc
		posiciona_cursor [ren_aux],[col_aux]
		imprime_caracter_color 178,cNegro,bgNegro
		inc [ren_aux]
		posiciona_cursor [ren_aux],[col_aux]
		imprime_caracter_color 178,cNegro,bgNegro
		inc [ren_aux]
		posiciona_cursor [ren_aux],[col_aux]
		imprime_caracter_color 178,cNegro,bgNegro
		sub [ren_aux],2
		
		dec [col_aux]
		posiciona_cursor [ren_aux],[col_aux]
		imprime_caracter_color 178,cNegro,bgNegro
		inc [ren_aux]
		posiciona_cursor [ren_aux],[col_aux]
		imprime_caracter_color 178,cNegro,bgNegro
		dec [ren_aux]
		
		dec [col_aux]
		posiciona_cursor [ren_aux],[col_aux]
		imprime_caracter_color 178,cNegro,bgNegro
		
		add [col_aux],3
		posiciona_cursor [ren_aux],[col_aux]
		imprime_caracter_color 178,cNegro,bgNegro
		inc [ren_aux]
		posiciona_cursor [ren_aux],[col_aux]
		imprime_caracter_color 178,cNegro,bgNegro
		dec [ren_aux]
		
		inc [col_aux]
		posiciona_cursor [ren_aux],[col_aux]
		imprime_caracter_color 178,cNegro,bgNegro
		ret
	endp

	PRINT_ENEMY_BLUE proc
		posiciona_cursor [ren_aux],[col_aux]
		imprime_caracter_color 178,cAzulClaro,bgNegro
		inc [ren_aux]
		posiciona_cursor [ren_aux],[col_aux]
		imprime_caracter_color 178,cAzulClaro,bgNegro
		inc [ren_aux]
		posiciona_cursor [ren_aux],[col_aux]
		imprime_caracter_color 178,cAzulClaro,bgNegro
		sub [ren_aux],2
		
		dec [col_aux]
		posiciona_cursor [ren_aux],[col_aux]
		imprime_caracter_color 178,cAzulClaro,bgNegro
		inc [ren_aux]
		posiciona_cursor [ren_aux],[col_aux]
		imprime_caracter_color 178,cAzulClaro,bgNegro
		dec [ren_aux]
		
		dec [col_aux]
		posiciona_cursor [ren_aux],[col_aux]
		imprime_caracter_color 178,cAzulClaro,bgNegro
		
		add [col_aux],3
		posiciona_cursor [ren_aux],[col_aux]
		imprime_caracter_color 178,cAzulClaro,bgNegro
		inc [ren_aux]
		posiciona_cursor [ren_aux],[col_aux]
		imprime_caracter_color 178,cAzulClaro,bgNegro
		dec [ren_aux]
		
		inc [col_aux]
		posiciona_cursor [ren_aux],[col_aux]
		imprime_caracter_color 178,cAzulClaro,bgNegro
		ret
	endp
	;procedimiento IMPRIME_BOTON
	;Dibuja un boton que abarca 3 renglones y 5 columnas
	;con un caracter centrado dentro del boton
	;en la posición que se especifique (esquina superior izquierda)
	;y de un color especificado
	;Utiliza paso de parametros por variables globales
	;Las variables utilizadas son:
	;boton_caracter: debe contener el caracter que va a mostrar el boton
	;boton_renglon: contiene la posicion del renglon en donde inicia el boton
	;boton_columna: contiene la posicion de la columna en donde inicia el boton
	;boton_color: contiene el color del boton
	IMPRIME_BOTON proc
	 	;background de botón
		mov ax,0600h 		;AH=06h (scroll up window) AL=00h (borrar)
		mov bh,cRojo	 	;Caracteres en color amarillo
		xor bh,[boton_color]
		mov ch,[boton_renglon]
		mov cl,[boton_columna]
		mov dh,ch
		add dh,2
		mov dl,cl
		add dl,2
		int 10h
		mov [col_aux],dl
		mov [ren_aux],dh
		dec [col_aux]
		dec [ren_aux]
		posiciona_cursor [ren_aux],[col_aux]
		imprime_caracter_color [boton_caracter],cRojo,[boton_color]
	 	ret 			;Regreso de llamada a procedimiento
	endp	 			;Indica fin de procedimiento UI para el ensamblador
	
	BORRA_JUGADOR proc
		mov al,[player_col]
		mov ah,[player_ren]
		mov [col_aux],al
		mov [ren_aux],ah
		call DELETE_PLAYER
		ret
	endp

	IMPRIME_JUGADOR proc
		mov al,[player_col]
		mov ah,[player_ren]
		mov [col_aux],al
		mov [ren_aux],ah
		call PRINT_PLAYER
		ret
	endp

	IMPRIME_JUGADOR_AZUL proc
		mov al,[player_col]
		mov ah,[player_ren]
		mov [col_aux],al
		mov [ren_aux],ah
		call PRINT_PLAYER_AZUL
		ret
	endp

	IMPRIME_ENEMIGO proc
		mov al,[enemy_col]
		mov ah,[enemy_ren]
		mov [col_aux],al
		mov [ren_aux],ah
		call PRINT_ENEMY
		ret
	endp

	IMPRIME_ENEMIGO_AZUL proc
		mov al,[enemy_col]
		mov ah,[enemy_ren]
		mov [col_aux],al
		mov [ren_aux],ah
		call PRINT_ENEMY_BLUE
		ret
	endp

	;Procedimiento para mover a la izquierda
	MOVER_IZQUIERDA_PLAYER proc
		cmp conta_movs, 0 ;Se verifica si es el primer movimiento realizado por el jugador
		ja no_primero_izq ;Si no lo es, salta a la etiqueta para moverlo desde una posicion diferente al centro
		primero_izq: ;Primer movimiento desde por el jugador a la izquierda
		call BORRA_JUGADOR ; Se borra al jugador
		dec [player_col] ;Como se mueve a la izquierda, se decrementa el valor de la columna del jugador
		call IMPRIME_JUGADOR ;Se reimprime el jugador con el nuevo valor de columna
		inc [conta_movs] ; Marcador para indicar que ya se ha realizado al menos un movimiento
		no_primero_izq:
		mov al, [player_col]
		mov ah, [player_ren] ;Se mueve a AL y AH la posicion del jugador 
		mov bl, al ;Se obtiene el valor de AL a BL, esto para poder conseguir el valor de la columna del jugador
		sub bl, 2 ; Se le resta 2 a la columna del jugador, esto es porque la nave tiene un ancho de 2 a la izquierda
		cmp bl, lim_izquierdo 
		je no_moveizq ; Si el limite izquierdo que tendria la nave es el mismo que tiene el limite izquierdo de la pantalla, no se realiza el movimiento
		mov [ren_aux], ah ;Si no se cumple lo anterior, entonces la nave se mueve siguiendo la misma lógica que en el primer movimiento
		mov [col_aux], al ;Se mueve lo quetienen AL y AH a ren_aux y col_aux. esto porque son las variables que utiliza DELETE_PLAYER
		call DELETE_PLAYER
		dec [player_col]
		call IMPRIME_JUGADOR
		no_moveizq:
		ret
	endp

	;Procedimiento para mover a la derecha
	MOVER_DERECHA_PLAYER proc
		cmp conta_movs, 0 ;Se verifica si es el primer movimiento realizado por el jugador
		ja no_primero_der ;Si no lo es, salta a la etiqueta para moverlo desde una posicion diferente al centro
		primero_der: ;Primer movimiento desde por el jugador a la derecha
		call BORRA_JUGADOR
		inc [player_col] ;Como se mueve a la derecha, se incrementa el valor de la columna del jugador
		call IMPRIME_JUGADOR ;Se reimprime el jugador con el nuevo valor de columna
		inc [conta_movs] ;Marcador para indicar que ya se ha realizado al menos un movimiento
		no_primero_der:
		mov al, [player_col] ;Se mueve a AL y AH la posicion del jugador
		mov ah, [player_ren] 
		mov bl, al ;Se obtiene el valor de AL a BL, esto para poder conseguir el valor de la columna del jugador
		add bl, 2 ; Se le suma 2 a la columna del jugador, esto es porque la nave tiene un ancho de 2 a ;a derecha
		cmp bl, lim_derecho 
		je no_moveder ; Si el limite derecho que tendria la nave es el mismo que tiene el limite derechp de la pantalla, no se realiza el movimiento
		mov [ren_aux], ah ;Si no se cumple lo anterior, entonces la nave se mueve siguiendo la misma lógica que en el primer movimiento
		mov [col_aux], al ;Se mueve lo quetienen AL y AH a ren_aux y col_aux. esto porque son las variables que utiliza DELETE_PLAYER
		call DELETE_PLAYER
		inc [player_col]
		call IMPRIME_JUGADOR
		no_moveder:
		ret
	endp

	BORRA_ENEMIGO proc
		mov al,[enemy_col]
		mov ah,[enemy_ren]
		mov [col_aux],al
		mov [ren_aux],ah
		call DELETE_ENEMY
		ret
	endp

	DELAY proc
		pusha           ; Guardar los registros en el stack
						; Utilizar un bucle para ocupar el tiempo de ejecución
		mov cx, 0FFFFh ; El valor en CX será el número de iteraciones del bucle
		bucle_retardo:
		dec ax				;AGREGAR INSTRUCCIONES DEMOVIMIENTO DE REGISTROS ENTRE MAS DELAY SE REQUIERA
		loop bucle_retardo ; Reducir el valor de CX en 1 y saltar a bucle_retardo si CX no es 0
		popa            ; Restaurar los registros desde el stack
		ret
	endp
;Este procedimiento modifica la posicion de las balas si ya hay una en pantalla o imprime balas en la pantalla cuando el jugador presiona espacio en el teclado 
	DISPARAR_PLAYER proc
		cmp balap_en_pant, 1 ;Se verifica si hay alguna bala en la pantalla
		je repos_bala ; Si hay una bala en pantalla, la reposiciona
		cmp al, teclaEsp ; Si AL = teclaEsp, se presionó " "
		jne fin_disp ; Si no  se ha presionado el espacio y no hay balas en pantalla, se omite el proceso
		dibujar_bala:
		mov [balap_y], ren_bala_in
		mov dl, [player_col]
		mov [balap_x], dl
		posiciona_cursor balap_y, balap_x ;Se posiciona el cursor a la posicion inicial de la bala (cualquiera que sea la columna y el renglon de partida)
		imprime_caracter_color 173,cAzul,bgNegro ;proyectil pintado 
		mov [balap_en_pant], 1 ;Marca que hay una bala en pantalla
		read_time [cont_balp]
		jmp fin_disp
		repos_bala:
		calcular_tiempo [cont_balp], 1 ;Compara si el tiempo transucurrido es suficiente
		jb fin_disp ;Sino, se salta al final y omite todo
		cmp balap_y, 2 ;Se fija si no es el final de la pantalla
		je borrar_disparo ;Si lo es, se borra el disparo
		detectar_colision_en ;Detectar colision de la bala con la nave enemiga
		posiciona_cursor balap_y, balap_x ;Sino, se posiciona el cursor en la posicion indicada
		imprime_caracter_color 178,cNegro,bgNegro ;Se borra el proyectil
		dec balap_y ;Se decrementa el renglon (esto hace que la bala "suba")
		posiciona_cursor balap_y, balap_x
		imprime_caracter_color 173,cAzul,bgNegro ;Se reimprime el proyectil mas arriba
		read_time [cont_balp]
		jmp fin_disp
		borrar_disparo:
		mov balap_en_pant, 0 ;Se indica que no hay disparos en pantalla
		posiciona_cursor balap_y, balap_x
		imprime_caracter_color 178,cNegro,bgNegro ;Se borra el proyectil
		read_time [cont_balp]
		fin_disp:
		ret
		endp
	;Procedimiento para que el enemigo parpadee
	BLINK_ENEMY		proc
	mov cx, 0FFFFh
	blink_loop:
		call IMPRIME_ENEMIGO_AZUL
		call DELAY
		call IMPRIME_ENEMIGO
	loop blink_loop
	ret
	endp

	BLINK_PLAYER		proc
	mov cx, 0FFFFh
	blink_loop_p:
		call IMPRIME_JUGADOR_AZUL
		call DELAY
		call IMPRIME_JUGADOR
	loop blink_loop_p
	ret
	endp


MOVIMIENTO_ENEMIGO	 proc
    ; Mover la nave enemiga según la dirección actual
	calcular_tiempo cont_mov_e, 1 ; Calcula el tiempo desde el ultimo moviemiento
	jb no_move_e ;Si el movimiento no es suficiente, no se mueve
	cmp num_mov_e, 5
	je mover_vertical
    cmp direccion, 1 ;Revisa si ;a direccion del movimiento es a la derecha
    je mover_enemigo_derecha ;Si lo es, mueve a la izquierda
	mover_enemigo_izquierda: ;Sino, se mueve a la izquierda
	call BORRA_ENEMIGO
	calcular_limites_enemigo ;Se calculan los limites del enemigo 
	cmp al, lim_izquierdo 
	je lim_izquierdo_col ; Si lim_izq del enemigo = lim_izq hay colision con borde izq, por ello, salta a lim_izq_col
	dec enemy_col ;Sino, mueve al enemigo
	inc num_mov_e
	jmp imprimir_nave_E ;Se salta a imprimir la nave
	mover_enemigo_derecha:
	call BORRA_ENEMIGO
	calcular_limites_enemigo ;Se calculan los limites del enemigo
	cmp ah, lim_derecho
	je lim_derecho_col ; Si lim_der del enemigo = lim_der hay colision con borde der, por ello, salta a lim_der_col
	inc enemy_col ;Sino, se mueve al enemigo
	inc num_mov_e
	jmp imprimir_nave_E ;Se salta a imprimri la nave
	lim_izquierdo_col:
    ; Limitar la posición de la nave enemiga dentro de los límites
    mov enemy_col, lim_col_izq
    mov direccion, 1 ; Cambiar la dirección a derecha
    jmp imprimir_nave_E
	lim_derecho_col:
    ; Limitar la posición de la nave enemiga dentro de los límites
    mov enemy_col, lim_col_der
    mov direccion, 0 ; Cambiar la dirección a izquierda
	jmp imprimir_nave_E
	mover_vertical:
		mover_enemigo_abajo:
		call BORRA_ENEMIGO
		cmp mov_abajo, 16
		jae mover_enemigo_arriba
		inc enemy_ren
		inc mov_abajo
		mov num_mov_e, 0
		jmp imprimir_nave_E
		mover_enemigo_arriba:
		call BORRA_ENEMIGO
		dec enemy_ren
		dec mov_abajo
		mov num_mov_e, 0
		jmp imprimir_nave_E
	imprimir_nave_E:
	detectar_colision_enemigo_jugador
    ; Imprimir la nave enemiga
    call IMPRIME_ENEMIGO
	read_time cont_mov_e ;Se lee el tiempo en el que se hizo el movimiento 
	no_move_e:
    ret
endp

DISPARAR_ENEMIGO proc
		cmp bala_enemiga, 1 ; Comprueba si hay una bala enemiga en pantalla
		je repos_bala_en ; Si hay una bala en pantalla, reposiciona la bala
		dibujar_bala_en:
		mov bh, [enemy_ren]
		add bh, 3
		mov [balae_y], bh ; Establece la posición inicial en el eje Y de la bala enemiga
		mov bl, [enemy_col] ; Mueve el valor de la columna del enemigo a BL
		mov [balae_x], bl ; Establece la posición inicial en el eje X de la bala enemiga
		posiciona_cursor balae_y, balae_x ; Posiciona el cursor en la posición de la bala enemiga
		imprime_caracter_color 33, cRojo, bgNegro ; Imprime el carácter correspondiente a la bala enemiga en rojo
		mov [bala_enemiga], 1 ; Marca que hay una bala enemiga en pantalla
		read_time [cont_bale] ; Lee el tiempo actual
		jmp fin_disp_en ; Salta al final del procedimiento de disparo enemigo
		repos_bala_en:
		calcular_tiempo [cont_bale], 1 ; Compara si el tiempo transcurrido es suficiente
		jb fin_disp_en ; Si no ha transcurrido suficiente tiempo, salta al final del procedimiento
		cmp [balae_y], ini_renglon ; Comprueba si la bala enemiga alcanzó el borde superior de la pantalla
		je borrar_bala_en ; Si lo hizo, borra la bala enemiga	
		detectar_colision
		posiciona_cursor balae_y, balae_x ; Posiciona el cursor en la posición actual de la bala enemiga
		imprime_caracter_color 178,cNegro,bgNegro ; Borra el carácter correspondiente a la bala enemiga
		inc balae_y ; Incrementa la posición Y de la bala enemiga (hace que la bala "baje")
		posiciona_cursor balae_y, balae_x ; Posiciona el cursor en la nueva posición de la bala enemiga
		imprime_caracter_color 33, cRojo, bgNegro ; Vuelve a imprimir la bala enemiga un renglón más abajo
		read_time [cont_bale] ; Lee el tiempo actual
		jmp fin_disp_en ; Salta al final del procedimiento de disparo enemigo
		borrar_bala_en:
		mov bala_enemiga, 0 ; Indica que no hay balas enemigas en pantalla
		posiciona_cursor balae_y, balae_x ; Posiciona el cursor en la posición actual de la bala enemiga
		imprime_caracter_color 178,cNegro,bgNegro ; Borra el carácter correspondiente a la bala enemiga
		read_time [cont_bale] ; Lee el tiempo actual
		fin_disp_en:
		ret ; Retorna al código principal
endp

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;FIN PROCEDIMIENTOS;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
end inicio			;fin de etiqueta inicio, fin de programa
