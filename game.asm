.MODEL SMALL
.stack 100h
.data
	POSICION macro x,y
		MOV AH,02H
		MOV BH,00H
		MOV DH,x
		MOV DL,y
		INT 10H
	endm

	IMPRIMIR macro texto
		MOV AX,@data
		MOV DS,AX
		MOV AH,09
		MOV DX,offset texto
		INT 21h
	endm
	
	PINTA_PIXEL macro x,y,color; Macro para pintar un pixel con un color
	  	MOV AH, 0CH; Interrupcion 10,C
		MOV AL, color; Color 
		MOV BH, 00; Numero de pagina
		MOV CX, x; Columna
		MOV DX, y; Fila
		INT 10H
    endm
	
	PINTA_COLORES macro x,y ; Macro para pintar un pixel del color que corresponde al cuadro
		MOV AH, 0CH; Interrupcion 10,C
		MOV AL, [colores+SI]; Color
		MOV BH, 00; Numero de pagina
		MOV CX, x; Columna
		MOV DX, y; Fila
		INT 10H
	endm
	; Variables de texto para mostrar en pantalla
	LimpiarOpcion DB 'Limpiar',10,13 , "$"
	GuardarBosquejoOpcion DB 'GuardarBosquejo',10,13 , "$"	
	CargarBosquejoOpcion DB 'CargarBosquejo',10,13 , "$"
	InsertarImagenOpcion DB 'InsertarImagen',10,13 , "$"
	
	; Variables para recuadro de dibujo
	ColRecuadro DW  50; Inicia en la columna 50
	FilRecuadro DW  50; Inicia en la fila 50
	ColCursorPintar DW 250; Posicion de la columna donde iniciar a pintar iniciando en el centro
	FilCursorPintar DW 200; Posicion de la fila donde iniciar a pintar iniciando en el centro
	
	; Variables para posicion del cursor
	ColCursor DW 0; Posicion de la columna donde se hizo click
	FilCursor DW 0; Posicion de la fila donde se hizo click
	
	; Variables para posicion de los colores 
	TamColor DW 20; Ancho y alto de cada cuadro de los colores
	ColColor DW 550; Posicion de la columna donde iniciar a pintar los cuadros de los colores
	FilColor DW 50; Posicion de la fila donde iniciar a pintar los cuadros de los colores
	
	;Variables para posicion de cursor al insertar imagen
	ImagenInsertada DW 0;
	
	; Variables para posicion de las opciones en pantalla
	ColLimpiar DW 320; Posicion de la columna donde inciar a pintar el cuadro de limpiar
	FilLimpiar DW 10; Posicion de la fila donde iniciar a pintar el cuadro de Limpiar
	ColNombre DW 50; Posicion de la columna donde inciar a pintar el cuadro de nombre
	FilNombre DW 10; Posicion de la fila donde iniciar a pintar el cuadro de nombre
	ColGuardarBosquejo DW 50; Posicion de la columna donde inciar a pintar el cuadro de GuardarBosquejo
	FilGuardarBosquejo DW 375; Posicion de la fila donde iniciar a pintar el cuadro de GuardarBosquejo
	ColCargarBosquejo DW 50; Posicion de la columna donde inciar a pintar el cuadro de CargarBosquejo
	FilCargarBosquejo DW 425; Posicion de la fila donde iniciar a pintar el cuadro de CargarBosquejo
	ColInsertarImagen DW 320; Posicion de la columna donde inciar a pintar el cuadro de InsertarImagen
	FilInsertarImagen DW 425; Posicion de la fila donde iniciar a pintar el cuadro de InsertarImagen
	
	; Variables para posicion del fondo negro de los colores
	TamBordeH DW 60; Tamano horizontal del fondo negro de los colores ancho
	TamBordeV DW 420; Tamano vertical del fondo negro de los colores alto
	ColBorde DW 530; Posición de la columna donde iniciar a pintar el fondo negro de los colores 
	FilBorde DW 30; Posición de la fila donde iniciar a pintar el fondo negro de los colores
	
	; Variables de los colores
	ColorSeleccionado DB 04H;color seleccionado para pintar
	colores DB 02H, 04H , 05H , 06H , 09H, 0AH, 0BH, 0CH, 0EH, 0FH  ; Vector de colores posibles para seleccionar
	
	;Variables para guardar y cargar archivos
	ruta db 'C',':','\','D','i','b','u','j','o','s','\','$','$','$','$','$','$','$','$','$','$','$','$','$','$',00h ; Carpeta donde se encuentran los archivos de los dibujos
	handle dw 0 ; Contenido del archivo (Dibujo a guardar)
	char_buffer db 1 dup('0')
	TempCol DW 0; Variable temporal para la columna del ciclo de guardar 
	TempFil DW 0; Variable temporal para la fila del ciclo de guardar 
	tempColor DB 04H; Variable para guardar el color del pixel de pantalla

.code
	MOV AX,@DATA
	MOV DS,AX

	MOV AH,00H; Interrupcion 10,0
	MOV AL,12H; 640x480 16 bits modo video
	INT 10H

	CALL CLEAN; Pinta la pantalla de blanco

	MOV CX, 400; Contador dibuja un pixel de la linea horizontal 400 veces
	LINEAHORIZONTAL:
		PUSH CX; Pone cx en la pila
		PINTA_PIXEL ColRecuadro, 50,0H; Macro para pintar un pixel con color negro
		PINTA_PIXEL ColRecuadro, 350,0H; Macro para pintar un pixel con color negro
		INC ColRecuadro; Incrementa col
		POP CX; Devuelve el valor que tenia cx al inicio
	LOOP LINEAHORIZONTAL
	MOV ColRecuadro,50

	MOV CX, 300; Contador dibuja un pixel de la linea vertical 300 veces
	LINEAVERTICAL:
		PUSH CX; Pone cx en la pila
		PINTA_PIXEL 50, FilRecuadro,0H; Macro para pintar un pixel con color negro
		PINTA_PIXEL 450, FilRecuadro,0H; Macro para pintar un pixel con color negro
		INC FilRecuadro; Incrementa fil	
		POP CX; Devuelve el valor que tenia cx al inicio
	LOOP LINEAVERTICAL
	MOV FilRecuadro,50
	
	MOV CX, 130; Contador dibuja un pixel de la linea horizontal 400 veces
		LINEAH_OPCIONES:
			PUSH CX; Pone cx en la pila
			PINTA_PIXEL ColLimpiar, 10,0H; Macro para pintar un pixel con color negro
			PINTA_PIXEL ColLimpiar, 40,0H; Macro para pintar un pixel con color negro
			PINTA_PIXEL ColNombre,10,0H; Macro para pintar un pixel con color negro
			PINTA_PIXEL ColNombre,40,0H; Macro para pintar un pixel con color negro
			PINTA_PIXEL ColGuardarBosquejo,375,0H; Macro para pintar un pixel con color negro
			PINTA_PIXEL ColGuardarBosquejo,405,0H; Macro para pintar un pixel con color negro
			PINTA_PIXEL ColCargarBosquejo,425,0H; Macro para pintar un pixel con color negro
			PINTA_PIXEL ColCargarBosquejo,455,0H; Macro para pintar un pixel con color negro
			jmp SIGUE_LINEAH
;======================================================Salto Intermedio============================================================================
	LINEAH_SALTO:
	jmp LINEAH_OPCIONES

;======================================================Salto Intermedio============================================================================
			SIGUE_LINEAH:
				PINTA_PIXEL ColInsertarImagen,425,0H; Macro para pintar un pixel con color negro
				PINTA_PIXEL ColInsertarImagen,455,0H; Macro para pintar un pixel con color negro
				INC ColLimpiar; Incrementa col
				INC ColNombre; Incrementa col
				INC ColGuardarBosquejo; Incrementa col
				INC ColCargarBosquejo; Incrementa col
				INC ColInsertarImagen; Incrementa col
				POP CX; Devuelve el valor que tenia cx al inicio
				DEC CX; Decrementa CX
		JNZ LINEAH_SALTO  ; Si CX no es cero, salta a LINEAH_SALTO
		
	MOV CX, 30; Contador dibuja un pixel de la linea vertical 300 veces
	LINEAV_OPCIONES:
		PUSH CX; Pone cx en la pila
		PINTA_PIXEL 320, FilLimpiar,0H; Macro para pintar un pixel con color negro
		PINTA_PIXEL 450, FilLimpiar,0H; Macro para pintar un pixel con color negro
		PINTA_PIXEL 50, FilNombre,0H; Macro para pintar un pixel con color negro
		PINTA_PIXEL 180, FilNombre,0H; Macro para pintar un pixel con color negro
		PINTA_PIXEL 50,FilGuardarBosquejo,0H; Macro para pintar un pixel con color negro
		PINTA_PIXEL 180,FilGuardarBosquejo,0H; Macro para pintar un pixel con color negro
		PINTA_PIXEL 50,FilCargarBosquejo,0H; Macro para pintar un pixel con color negro
		PINTA_PIXEL 180,FilCargarBosquejo,0H; Macro para pintar un pixel con color negro
		jmp SIGUE_LINEAV
;======================================================Salto Intermedio============================================================================
	LINEAV_SALTO:
	jmp LINEAV_OPCIONES

;======================================================Salto Intermedio============================================================================
		SIGUE_LINEAV:
		PINTA_PIXEL 320,FilInsertarImagen,0H; Macro para pintar un pixel con color negro
		PINTA_PIXEL 450,FilInsertarImagen,0H; Macro para pintar un pixel con color negro
		INC FilLimpiar; Incrementa fil
		INC FilNombre; Incrementa fil
		INC FilGuardarBosquejo; Incrementa fil
		INC FilCargarBosquejo; Incrementa fil
		INC FilInsertarImagen; Incrementa fil
		POP CX; Devuelve el valor que tenia cx al inicio
		DEC CX; Decrementa CX
		JNZ LINEAV_SALTO  ; Si CX no es cero, salta a LINEAH_SALTO
	
	POSICION 1,45; Posicion para poner el texto de la opcion Limpiar
	IMPRIMIR LimpiarOpcion
	POSICION 24,7; Posicion para poner el texto de la opcion GuardarBosquejo
	IMPRIMIR GuardarBosquejoOpcion
	POSICION 27,7; Posicion para poner el texto de la opcion CargarBosquejo
	IMPRIMIR CargarBosquejoOpcion
	POSICION 27,41; Posicion para poner el texto de la opcion InsertarImagen
	IMPRIMIR InsertarImagenOpcion

	CALL PINTAR_COLORESFONDO; Procedimiento para pintar el fondo negro de los colores
	CALL PINTAR_CUADRADOS; Procedimiento para pintar los 10 cuadrados de los colores
	
	CICLOJUEGO:; Mantener el ciclo del juego activo constantemente detectando las acciones
		CALL DETECTAR_CLICK; Detectar donde se hizo click
		CALL MOVERLAPIZ; Mover el lapiz con las flechas
		jmp CICLOJUEGO
	
		
	mov AH,4CH; Interrupcion 10,4C para finalizar programa
	int 21H

	CLEAN proc
		MOV AX,0700H; Interrupcion 10,7 para limpiar pantalla
		MOV BH,0FH ; Primer digito color de letra/ segundo digito color de fondo
		MOV CX, 0H; Coordenada superior izquierda
		MOV DX,1F4FH; Coordenada inferior derecha es decir toda la pantalla
		INT 10H
		ret
	CLEAN endp
	
	LIMPIAR_DIBUJO proc; Procedimiento para limpiar el area de pintar
		MOV ColRecuadro,51; Inicia ColRecuadro en 51 para no pintar las lineas de borde
		MOV FilRecuadro,51; Inicia FilRecuadro en 51 para no pintar las lineas de borde
		MOV CX,ColRecuadro; Coloca en CX la columna de inicio a pintar
		MOV DX,FilRecuadro; Coloca en DX la fila de inicio a pintar

		COLUMNA_RECUADRO:
			PINTA_PIXEL CX,DX,0FH; Llama al  macro de pintar un pixel de color blanco
			
			INC CX; Incrementa la Columna
			cmp CX,449; Compara si se excedio la coodenada de la columna que se queria
			jng COLUMNA_RECUADRO; Salta si AX es menor a 398 es decir si no se excedio el Tamano
			
			MOV CX,ColRecuadro; Reinicia el valor de la columna
			INC DX; Incrementa la Fila
			cmp DX,349;Compara si se excedio la coodenada de la fila que se queria
			jng COLUMNA_RECUADRO; Salta si AX es menor a 298 es decir si no se excedio el tamano
		ret
	LIMPIAR_DIBUJO endp
	
	PINTAR_COLORESFONDO proc; Procedimiento para pintar el fondo negro de los colores
		MOV CX,ColBorde; Guarda en CX la columna donde iniciar
		MOV DX,FilBorde; Guarda en DX la fila donde iniciar
		
		COLUMN:
			PINTA_PIXEL CX,DX,0H; Llama al macro de pintar un pixel con el color negro
			
			INC CX; Incrementa la Columna
			MOV AX,CX; Pone en AX el valor de la Columna aumentada
			SUB AX,ColBorde; Resta el valor donde inicio a pintar de la columna con el de la columna aumentada
			cmp AX,TamBordeH; Compara si el ancho se excedio del tamano que se queria 
			jng COLUMN; Salta si Ax es menor a TamBordeH es decir si no se ha excedido el Tamano
			
			MOV CX,ColBorde; Reinicia la posicion de la columna
			INC DX; Aumenta la Fila
			MOV AX,DX; Pone en AX el valor de la fila aumentada
			SUB AX,FilBorde; Resta el valor donde inicio a pintar de la fila con el de la fila aumentada
			cmp AX,TamBordeV; Compara si el alto si excedio del tamano que se queria 
			jng COLUMN; Salta si AX es menor a TamBordeV es decir si no se ha excedido el tamano
		ret
	PINTAR_COLORESFONDO endp
	
	PINTAR_COLOR proc; Procedimiento para pintar un cuadrado de los colores 
		MOV CX,ColColor; Coloca en CX la columna de inicio a pintar
		MOV DX,FilColor; Coloca en DX la fila de inicio a pintar
		
		COLUMNAS:
			PINTA_COLORES CX,DX; Llama al  macro de pintar un pixel de cierto color
			
			INC CX; Incrementa la Columna
			MOV AX,CX; Pone el valor de la columna aumentada en AX
			SUB AX,ColColor; Resta el valor de la columna con el valor de la columna aumentada
			cmp AX,TamColor; Compara si se excedio el tamano de la columna que se queria
			jng COLUMNAS; Salta si AX es menor a TamColor es decir si no se excedio el Tamano
			
			MOV CX,ColColor; Reinicia el valor de la columna
			INC DX; Incrementa la Fila
			MOV AX,DX; Pone el valor de la fila aumentada en AX
			SUB AX,FilColor; Resta el valor de la fila con el de la fila aumentada
			cmp AX,TamColor;Compara si se excedio el tamano de la fila que se queria
			jng COLUMNAS; Salta si AX es menor a TamColor es decir si no se excedio el tamano
		ret
	PINTAR_COLOR endp
	
	PINTAR_CUADRADOS proc; Procedimiento para pintar los 10 cuadrados de los colores 
		MOV SI,0; Pone SI en 0 este sera usado para recorrer el vector de colores 
		MOV CX,ColColor; Reinicia el valor de la Columna
		DIBUJA:			
			CALL PINTAR_COLOR; Macro para pintar un pixel del color que toque segun SI			
			MOV AX,FilColor; Pone en AX el valor de la Fila
			ADD AX,40; Le suma 40 a AX 
			MOV FilColor,AX; Pone el valor de la fila+40 en FilColor
			
			INC SI; Incrementa SI
			cmp SI,10; Compara si SI con 10
			jl DIBUJA; Salta si SI es menor a 10
			
		ret
	PINTAR_CUADRADOS endp

	DETECTAR_CLICK proc; Detectar donde se hizo click
		MOV AX,0001H; Muestra el cursor del mouse
		INT 33H
		
		MOV AX,0003H; Interrupcion para guardar la posicion del cursor fila y columna
		INT 33H
		
		TEST BX, 0001H; Verifica si el click izquierdo fué presionado
		JZ NoClick; si no fue presionado salta a NoClick
		
		MOV ColCursor,CX; Guarda la columna donde se hizo click
		MOV FilCursor,DX; Guarda la fila donde se hizo click
		
		CALL DETECTAR_CLICK_COLOR; Detectar que color se selecciono
		CALL DETECTAR_CLICK_LIMPIAR; Detectar si se hizo click en limpiar
		CALL DETECTAR_CLICK_NOMBRE; Detectar si se agrego nombre para el archivo y guardarlo
		CALL DETECTAR_CLICK_GUARDAR; Detectar si se hizo click en GuardarBosquejo
		CALL DETECTAR_CLICK_CARGAR; Detectar si se hizo click en CargarBosquejo
		CALL DETECTAR_CLICK_INSERTAR; Dectar si se hizo click en InsertarImagen
		CALL INICIO_PINTAR
		
		NoClick:
		ret
	DETECTAR_CLICK endp
	
	DETECTAR_CLICK_COLOR proc; Detectar si se hizo click en un color 
		cmp ColCursor,550
		jle SaltoIrANoColor
		cmp ColCursor,610
		jge SaltoIrANoColor
		
		;color verde
		cmp FilCursor,50
		jle ColorRojo
		cmp FilCursor,70
		jge ColorRojo
		MOV ColorSeleccionado,02H; Se selecciono el color verde
		jmp NoColor
		
		ColorRojo:
			cmp FilCursor,90
			jle ColorPurpura
			cmp FilCursor,110
			jge ColorPurpura
			MOV ColorSeleccionado,04H; Se selecciono el color rojo
			jmp NoColor
		
		ColorPurpura:
			cmp FilCursor,130
			jle ColorAmarillo
			cmp FilCursor,150
			jge ColorAmarillo
			MOV ColorSeleccionado,05H; Se selecciono el color purpura
			jmp NoColor
			
		ColorAmarillo:
			cmp FilCursor,170
			jle ColorAzulClaro
			cmp FilCursor,190
			jge ColorAzulClaro
			MOV ColorSeleccionado,06H; Se selecciono el color amarillo
			jmp NoColor
			
;======================================================Salto Intermedio============================================================================
	SaltoIrANoColor:
	jmp NoColor

;======================================================Salto Intermedio============================================================================
			
		ColorAzulClaro:
			cmp FilCursor,210
			jle ColorVerdeClaro
			cmp FilCursor,230
			jge ColorVerdeClaro
			MOV ColorSeleccionado,09H; Se selecciono el color azul claro
			jmp NoColor
			
		ColorVerdeClaro:
			cmp FilCursor,250
			jle ColorAquaClaro
			cmp FilCursor,270
			jge ColorAquaClaro
			MOV ColorSeleccionado,0AH; Se selecciono el color verde claro
			jmp NoColor
			
		ColorAquaClaro:
			cmp FilCursor,290
			jle ColorRojoClaro
			cmp FilCursor,310
			jge ColorRojoClaro
			MOV ColorSeleccionado,0BH; Se selecciono el color aqua claro
			jmp NoColor
			
		ColorRojoClaro:
			cmp FilCursor,330
			jle ColorAmarilloClaro
			cmp FilCursor,350
			jge ColorAmarilloClaro
			MOV ColorSeleccionado,0CH; Se selecciono el color rojo claro
			jmp NoColor
			
		ColorAmarilloClaro:
			cmp FilCursor,370
			jle ColorBlanco
			cmp FilCursor,390
			jge ColorBlanco
			MOV ColorSeleccionado,0EH; Se selecciono el color amarillo claro
			jmp NoColor
			
		ColorBlanco:
			cmp FilCursor,410
			jle NoColor
			cmp FilCursor,430
			jge ColorAquaClaro
			MOV ColorSeleccionado,0FH; Se selecciono el color blanco
		
		NoColor:
		ret
	DETECTAR_CLICK_COLOR endp
	
	DETECTAR_CLICK_LIMPIAR proc; Detecta si se hizo click en la opcion de limpiar area de trabajo
		cmp ColCursor,320
		jle NoLimpiar; si ColCursor es menor o igual salta 
		cmp ColCursor,450
		jge NoLimpiar; si ColCursor es mayor o igual salta
		cmp FilCursor,10
		jle NoLimpiar
		cmp FilCursor,40
		jge NoLimpiar
		CALL LIMPIAR_DIBUJO
		NoLimpiar:
		ret
	DETECTAR_CLICK_LIMPIAR endp
	
	DETECTAR_CLICK_NOMBRE proc; Detecta si se hizo click en el espacio de nombre del archivo
		cmp ColCursor,50
		jle NoEscribir; si ColCursor es menor o igual salta 
		cmp ColCursor,180
		jge NoEscribir; si ColCursor es mayor o igual salta
		cmp FilCursor,10
		jle NoEscribir
		cmp FilCursor,40
		jge NoEscribir		
		;CALL GUARDAR_NOMBRE
			CALL LIMPIAR_NOMBRE
			CALL MOVER_POSICION_CURSOR
			mov si,11; Iniciamos el contador donde queremos escribir la ruta
			LeerpantallaNombre:
				mov ah,1h
				int 21h
				cmp al,13d; Revisar si se precionó enter
				je TerminarNombre
				cmp si,24; Revisar si se llegó al maximo
				je TerminarNombre
				mov ruta[si],al
				inc si
				jmp LeerpantallaNombre
				TerminarNombre:
				mov ruta[si],'$'
		jmp FinClickNombre
		NoEscribir:
		FinClickNombre:
		ret
	DETECTAR_CLICK_NOMBRE endp
	
	DETECTAR_CLICK_GUARDAR proc; Detecta si se hizo click en el espacio de GuardarBosquejo
		cmp ColCursor,50
		jle NoGuardar; si ColCursor es menor o igual salta 
		cmp ColCursor,180
		jge NoGuardar; si ColCursor es mayor o igual salta
		cmp FilCursor,375
		jle NoGuardar
		cmp FilCursor,405
		jge NoGuardar
		CALL GUARDAR_ARCHIVO
		CALL ESCRIBIR_ARCHIVO
	
		NoGuardar:	
		ret
	DETECTAR_CLICK_GUARDAR endp
	
	INICIO_PINTAR proc; Posicion con el cursor para iniciar a pintar con las flecha
		; Verifica si CX (ColCursor) está en el rango (50, 450)
		CMP ColCursor, 50; Compara CX con 50
		JLE FIN_INICIO_PINTAR; Si CX <= 50, salta a FIN_INICIO_PINTAR
		CMP ColCursor, 450; Compara CX con 450
		JGE FIN_INICIO_PINTAR; Si CX >= 450, salta a FIN_INICIO_PINTAR

		; Verifica si DX (FilCursor) está en el rango (50, 350)
		CMP FilCursor, 50; Compara DX con 50
		JLE FIN_INICIO_PINTAR; Si DX <= 50, salta a FIN_INICIO_PINTAR
		CMP FilCursor, 350; Compara DX con 350
		JGE FIN_INICIO_PINTAR; Si DX >= 350, salta a FIN_INICIO_PINTAR
		
		cmp ImagenInsertada, 1; Compara si se inserto imagen para que el siguiente click sea pintarla
		je callInsertar; Salta al procedimiento de pintar imagen insertada
		MOV ColCursorPintar,CX; Cambia el valor de la columna para iniciar a pintar
		MOV FilCursorPintar,DX; Cambia el valor de la fila para iniciar a pintar
		jmp FIN_INICIO_PINTAR
		callInsertar:
		CALL INSERTAR_IMAGEN
		FIN_INICIO_PINTAR:
		ret
	INICIO_PINTAR endp
	
	MOVERLAPIZ proc; Mover el lapiz con las flechas
		MOV AH ,01H; Revisa si se toco una tecla
		INT 16H
		jz TerminarRevision ; Si no se toco una tecla salta hasta el final de MOVERLAPIZ
			
		MOV AH, 00H; Esperar por una tecla
		INT 16H

		cmp AH, 48h
		je Flecha_Arriba; Si es flecha arriba, salta a Flecha_Arriba
		cmp AH, 50h
		je Flecha_Abajo; Si es flecha es abajo salta a Flecha_Abajo
		cmp AH, 4Bh
		je Flecha_Izquierda; Si es flecha es izquierda salta a Flecha_Izquierda
		cmp AH, 4Dh
		je Flecha_Derecha; Si es flecha es abajo derecha a Flecha_Derecha
		jmp TerminarRevision
		
		; Mover el lapiz para pintar
		Flecha_Arriba:
			DEC FilCursorPintar
			cmp FilCursorPintar,50
			je REVERTIR_ARRIBA
			CALL PINTAR_ARRIBA
			jmp TerminarRevision
			REVERTIR_ARRIBA:
				INC FilCursorPintar
				jmp TerminarRevision
		Flecha_Abajo:
			INC FilCursorPintar
			cmp FilCursorPintar,350
			je REVERTIR_ABAJO
			CALL PINTAR_ABAJO
			jmp TerminarRevision
			REVERTIR_ABAJO:
				DEC FilCursorPintar
				jmp TerminarRevision
		Flecha_Izquierda:
			DEC ColCursorPintar
			cmp ColCursorPintar,50
			je REVERTIR_IZQUIERDA
			CALL PINTAR_IZQUIERDA
			jmp TerminarRevision
			REVERTIR_IZQUIERDA:
				INC ColCursorPintar
				jmp TerminarRevision
		Flecha_Derecha:
			INC ColCursorPintar
			cmp ColCursorPintar,450
			je REVERTIR_DERECHA
			CALL PINTAR_DERECHA
			jmp TerminarRevision
			REVERTIR_DERECHA:
				DEC ColCursorPintar
		; Sale de la revision
		TerminarRevision:
		ret
	MOVERLAPIZ endp
	
	PINTAR_ARRIBA proc; Pintar hacia arriba con las flechas
		MOV AH, 0CH; Interrupcion 10,C
		MOV AL, ColorSeleccionado; Color
		MOV BH, 00; Numero de pagina
		MOV CX, ColCursorPintar; Columna
		MOV DX, FilCursorPintar; Fila
		INT 10H
		ret
	PINTAR_ARRIBA endp
	
	PINTAR_ABAJO proc; Pintar hacia abajo con las flechas
		MOV AH, 0CH; Interrupcion 10,C
		MOV AL, ColorSeleccionado; Color
		MOV BH, 00; Numero de pagina
		MOV CX, ColCursorPintar; Columna
		MOV DX, FilCursorPintar; Fila
		INT 10H
		ret
	PINTAR_ABAJO endp
	
	PINTAR_IZQUIERDA proc; Pintar hacia la izquierda con las flechas
		MOV AH, 0CH; Interrupcion 10,C
		MOV AL, ColorSeleccionado; Color
		MOV BH, 00; Numero de pagina
		MOV CX, ColCursorPintar; Columna
		MOV DX, FilCursorPintar; Fila
		INT 10H
		ret
	PINTAR_IZQUIERDA endp
	
	PINTAR_DERECHA proc; Pintar hacia la derecha con las flechas
		MOV AH, 0CH; Interrupcion 10,C
		MOV AL, ColorSeleccionado; Color
		MOV BH, 00; Numero de pagina
		MOV CX, ColCursorPintar; Columna
		MOV DX, FilCursorPintar; Fila
		INT 10H
		ret
	PINTAR_DERECHA endp
	
	GUARDAR_NOMBRE proc; Guarda el nombre del archivo
		
			ret
	GUARDAR_NOMBRE endp
	
	MOVER_POSICION_CURSOR proc; Mueve la posicion del cursor para escribir nombre del archivo
		; Mover el cursor a la posición deseada
		mov ah, 02h; Función para mover el cursor
		mov bh, 0; Página de video (0)
		mov dh, 1; Fila (y) en la que quieres posicionar el cursor
		mov dl, 8; Columna (x) en la que quieres posicionar el cursor
		int 10h ; Llamada a la interrupción 10h para mover el cursor
		ret
	MOVER_POSICION_CURSOR endp
	
	DETECTAR_CLICK_INSERTAR proc
		cmp ColCursor,320
		jle NoInsertar; si ColCursor es menor o igual salta 
		cmp ColCursor,450
		jge NoInsertar; si ColCursor es mayor o igual salta
		cmp FilCursor,425
		jle NoInsertar
		cmp FilCursor,455
		jge NoInsertar
		MOV ImagenInsertada,1; Es uno para indicar que se insertó una imagen
	
		NoInsertar:	
		ret
	DETECTAR_CLICK_INSERTAR endp
	
	LIMPIAR_NOMBRE proc; Limpia el nombre escrito del archivo para colocar otro
		MOV ColNombre,51; Inicia ColRecuadro en 51 para no pintar las lineas de borde
		MOV FilNombre,11; Inicia FilRecuadro en 11 para no pintar las lineas de borde
		MOV CX,ColNombre; Coloca en CX la columna de inicio a pintar
		MOV DX,FilNombre; Coloca en DX la fila de inicio a pintar

		COLUMNA_NOMBRE:
			PINTA_PIXEL CX,DX,0FH; Llama al  macro de pintar un pixel de color blanco
			
			INC CX; Incrementa la Columna
			cmp CX,179; Compara si se excedio el tamano de la columna que se queria
			jng COLUMNA_NOMBRE; Salta si AX es menor a 398 es decir si no se excedio el Tamano
			
			MOV CX,ColNombre; Reinicia el valor de la columna
			INC DX; Incrementa la Fila
			cmp DX,39;Compara si se excedio el tamano de la fila que se queria
			jng COLUMNA_NOMBRE; Salta si AX es menor a 298 es decir si no se excedio el tamano
		ret
	LIMPIAR_NOMBRE endp
	
	GUARDAR_ARCHIVO proc; Guarda el archivo con el nombre que se escribio anteriormente
		mov ah,3ch
		mov cx,0
		mov dx,offset ruta
		int 21h
		mov handle,ax
		mov bx,ax
		mov ah,3eh; Cerrar el Archivo
		int 21h
		ret
	GUARDAR_ARCHIVO endp
	
	ESCRIBIR_PRUEBA proc
			MOV AL,'8'
			mov char_buffer[0], AL ; Almacenar el carácter '8' en el buffer
	
			mov ah,3dh							;Empezamos a abrir el archivo en modo escritura
			mov al,2h
			mov dx,offset ruta					;Ponemos la ruta del archivo a abrir
			int 21h
POSICION 3,30; Posicion para poner el texto de la opcion Limpiar
		IMPRIMIR ruta		
			;jc TERMINARPRUEBA       ; Si hubo error, saltar a TERMINARPRUEBA

			mov bx, ax             ; Guardar el manejador del archivo (en BX)
	POSICION 1,20; Posicion para poner el texto de la opcion Limpiar
		IMPRIMIR LimpiarOpcion
			
			;; Escribir en el archivo
			mov cx, 1              ; Cantidad de bytes a escribir (1 byte)
			mov dx, offset char_buffer ; Dirección del buffer
			mov ah, 40h            ; Función de escritura en archivo
			int 21h                ; Llamada a DOS para escribir
			;jc TERMINARPRUEBA      ; Verificar si ocurrió un error

			cmp ax, cx             ; Comparar bytes escritos con los solicitados
			;jne TERMINARPRUEBA     ; Si no se escribieron todos, ir a TERMINARPRUEBA

			;TERMINARPRUEBA:
			ret
	ESCRIBIR_PRUEBA endp
	
	ESCRIBIR_ARCHIVO proc
		mov ah,3ch;Empezamos a abrir el archivo en modo escritura
		mov al,1h
		mov dx,offset ruta;Ponemos la ruta del archivo a abrir
		int 21h
		jc SaltoIrATerminarContenido; Si hubo error, terminar

		mov bx, ax; Guardar manejador del archivo
		
		; Variables
		MOV ColRecuadro,51; Inicia ColRecuadro en 51 para no pintar las lineas de borde
		MOV FilRecuadro,51; Inicia FilRecuadro en 51 para no pintar las lineas de borde
		MOV CX,ColRecuadro; Coloca en CX la columna de inicio a pintar
		MOV TempCol,CX
		MOV DX,FilRecuadro; Coloca en DX la fila de inicio a pintar
		MOV TempFil,DX
		COLUMNA_COLOR:
			xor al, al
			MOV CX,TempCol
			MOV DX,TempFil
			MOV AH,0DH
			MOV BH,00H
			INT 10H; Revisa el color de un pixel y lo guarda en AL
			MOV tempColor,AL
			jmp CompararColor
			continuar:
			INC TempCol; Incrementa la Columna
            MOV AX,TempCol; Pone el valor de la columna aumentada en AX
            cmp AX,449; Compara si se excedio la coodenada de la columna que se queria
            jng COLUMNA_COLOR; Salta si AX es menor o igual a 449
            MOV CX,ColRecuadro; Reinicia el valor de la columna
            MOV TempCol,CX
            INC TempFil; Incrementa la Fila
			
			mov AL, '@'
			mov char_buffer, AL
			mov cx,1; Cantidad a guardar
			mov dx,offset char_buffer; Cargamos Datos
			mov ah,40h
			int 21h
			cmp cx,ax
			jne SaltoIrATerminarContenido
			
            MOV AX,TempFil; Pone el valor de la fila aumentada en AX
            cmp AX,349;Compara si se excedio la coodenada de la fila que se queria		
            jng COLUMNA_COLOR; Salta si AX es menor o igual a 349
			jmp Fin_archivo
;======================================================Salto Intermedio============================================================================
	SaltoIrATerminarContenido:
	jmp TerminarContenido

;======================================================Salto Intermedio============================================================================
			CompararColor:
			; Comparar el color y escribir el caracter correspondiente
			MOV AL,tempColor
			cmp AL, 00H
			je escribir_0
			cmp AL, 01H
			je escribir_1
			cmp AL, 02H
			je escribir_2
			cmp AL, 03H
			je escribir_3
			cmp AL, 04H
			je escribir_4
			cmp AL, 05H
			je escribir_5
			cmp AL, 06H
			je escribir_6
			cmp AL, 07H
			je escribir_7
			cmp AL, 08H
			je escribir_8
			cmp AL, 09h
			je escribir_9
			cmp AL, 0AH
			je escribir_A
			cmp AL, 0BH
			je escribir_B
			cmp AL, 0CH
			je escribir_C
			cmp AL, 0DH
			je escribir_D
			cmp AL, 0EH
			je escribir_E
			cmp AL, 0FH
			je escribir_F
			;jmp escribir_8
			jmp continuar; Si no coincide, continuar
		escribir_0:
			mov AL, '0'
			jmp escribir_character
		escribir_1:
			mov AL, '1'
			jmp escribir_character
		escribir_2:
			mov AL, '2'
			jmp escribir_character
		escribir_3:
			mov AL, '3'
			jmp escribir_character
		escribir_4:
			mov AL, '4'
			jmp escribir_character
		escribir_5:
			mov AL, '5'
			jmp escribir_character
		escribir_E:
			mov AL, 'E'
			jmp escribir_character
		escribir_6:
			mov AL, '6'
			jmp escribir_character
		escribir_7:
			mov AL, '7'
			jmp escribir_character
		escribir_8:
			mov AL, '8'
			jmp escribir_character
		escribir_9:
			mov AL, '9'
			jmp escribir_character
		escribir_A:
			mov AL, 'A'
			jmp escribir_character
		escribir_B:
			mov AL, 'B'
			jmp escribir_character
		escribir_C:
			mov AL, 'C'
			jmp escribir_character
		escribir_D:
			mov AL, 'D'
			jmp escribir_character
		escribir_F:
			mov AL, 'F'
			jmp escribir_character	
		escribir_character:
			mov char_buffer, AL
			;;Escribir en el archivo
			mov cx,1; Cantidad a guardar
			mov dx,offset char_buffer; Cargamos Datos
			mov ah,40h
			int 21h
			cmp cx,ax
			jne TerminarContenido; En caso de fallar sale
			jmp continuar
		
		Fin_archivo:
			; Al final de todos los caracteres, escribir '%'
			mov AL, '%'
			mov char_buffer, AL
			mov cx,1; Cantidad a guardar
			mov dx,offset char_buffer; Cargamos Datos
			mov ah,40h
			int 21h
			cmp cx,ax
			jne TerminarContenido; En caso de fallar sale

		; Cerrar el archivo
		mov ah, 3eh; Cerrar archivo
		mov bx, handle
		int 21h

		TerminarContenido:
		ret       
	ESCRIBIR_ARCHIVO endp

	DETECTAR_CLICK_CARGAR proc
		cmp ColCursor,50
		jle NoCargar; si ColCursor es menor o igual salta 
		cmp ColCursor,180
		jge NoCargar; si ColCursor es mayor o igual salta
		cmp FilCursor,425
		jle NoCargar
		cmp FilCursor,455
		jge NoCargar
		CALL CARGAR_ARCHIVO	
		NoCargar:	
		ret
	DETECTAR_CLICK_CARGAR endp
	
	CARGAR_ARCHIVO proc
		; Abrir archivo
			mov ah,3dh
			mov al,0h
			mov dx,offset ruta ;ruta
			int 21h
			mov handle,ax
		
		; Variables
		MOV ColRecuadro,51; Inicia ColRecuadro en 51 para no pintar las lineas de borde
		MOV FilRecuadro,51; Inicia FilRecuadro en 51 para no pintar las lineas de borde
		MOV CX,ColRecuadro; Coloca en CX la columna de inicio a pintar
		MOV TempCol,CX
		MOV DX,FilRecuadro; Coloca en DX la fila de inicio a pintar
		MOV TempFil,DX
		
		COLUMNA_CARGAR:
		; Leer el archivo 		
			mov ah,3fh
			mov bx,handle
			mov dx,offset char_buffer
			mov cx,1
			int 21h	
			jmp CompararArchivo
			
			SeguirCargando:
			cmp char_buffer,'@'
			je Aumentar_Fila
			cmp char_buffer, '%'
			je Fin_cargarSalto						
			INC TempCol; Incrementa la Columna
            jmp COLUMNA_CARGAR; Salta si AX es menor o igual a 449
			Aumentar_Fila:
            MOV CX,ColRecuadro; Reinicia el valor de la columna
            MOV TempCol,CX
            INC TempFil; Incrementa la Fila	
            jmp COLUMNA_CARGAR; Salta si AX es menor o igual a 349
		
		CompararArchivo:
			xor AL,AL
			cmp char_buffer, '0'
			je pintar_00H
			cmp char_buffer, '1'
			je pintar_01H
			cmp char_buffer, '2'
			je pintar_02H
			cmp char_buffer, '3'
			je pintar_03H
			cmp char_buffer, '4'
			je pintar_04H
			cmp char_buffer, '5'
			je pintar_05H
			cmp char_buffer, '6'
			je pintar_06H
			jmp continuarCargando
;======================================================Salto Intermedio============================================================================
	Fin_cargarSalto:
	jmp Fin_cargar
;======================================================Salto Intermedio============================================================================	
			continuarCargando:
			cmp char_buffer, '7'
			je pintar_07H
			cmp char_buffer, '8'
			je pintar_08H
			cmp char_buffer, '9'
			je pintar_09H
			cmp char_buffer, 'A'
			je pintar_0AH
			cmp char_buffer, 'B'
			je pintar_0BH
			cmp char_buffer, 'C'
			je pintar_0CH
			cmp char_buffer, 'D'
			je pintar_0DH
			cmp char_buffer, 'E'
			je pintar_0EH
			cmp char_buffer, 'F'
			je pintar_0FH
			jmp SeguirCargando
			pintar_00H:
				mov AL, 00H
				jmp pintarPixelCargado
			pintar_01H:
				mov AL, 01H
				jmp pintarPixelCargado
			pintar_02H:
				mov AL, 02H
				jmp pintarPixelCargado
			pintar_03H:
				mov AL, 03H
				jmp pintarPixelCargado
			pintar_04H:
				mov AL, 04H
				jmp pintarPixelCargado
			pintar_05H:
				mov AL, 05H
				jmp pintarPixelCargado
			pintar_0EH:
				mov AL, 0EH
				jmp pintarPixelCargado
			pintar_06H:
				mov AL, 06H
				jmp pintarPixelCargado
			pintar_07H:
				mov AL, 07H
				jmp pintarPixelCargado
			pintar_08H:
				mov AL, 08H
				jmp pintarPixelCargado
			pintar_09H:
				mov AL, 09H
				jmp pintarPixelCargado
			pintar_0AH:
				mov AL, 0AH
				jmp pintarPixelCargado
			pintar_0BH:
				mov AL, 0BH
				jmp pintarPixelCargado
			pintar_0CH:
				mov AL, 0CH
				jmp pintarPixelCargado
			pintar_0DH:
				mov AL, 0DH
				jmp pintarPixelCargado
			pintar_0FH:
				mov AL, 0FH
				jmp pintarPixelCargado
			
		pintarPixelCargado:
			MOV AH, 0CH; Interrupcion 10,C 
			MOV BH, 00; Numero de pagina
			MOV CX, TempCol; Columna
			MOV DX, TempFil; Fila
			INT 10H
			jmp SeguirCargando
		
		Fin_cargar:
		; Cerrar el archivo
			mov ah,3eh
			int 21h
		ret
	CARGAR_ARCHIVO endp

	INSERTAR_IMAGEN proc
		; Abrir archivo
			mov ah,3dh
			mov al,0h
			mov dx,offset ruta ;ruta
			int 21h
			mov handle,ax
		
		; Variables
		MOV CX,ColCursor; Coloca en CX la columna de inicio a pintar
		MOV TempCol,CX
		MOV DX,FilCursor; Coloca en DX la fila de inicio a pintar
		MOV TempFil,DX
		
		COLUMNA_INSERTAR:
		; Leer el archivo 		
			mov ah,3fh
			mov bx,handle
			mov dx,offset char_buffer
			mov cx,1
			int 21h	
			jmp CmpArchivo
			
			SeguirInsertando:
			cmp char_buffer,'@'
			je FILA_INSERTAR
			cmp char_buffer, '%'
			je Fin_insertarSalto						
			INC TempCol; Incrementa la Columna		
			cmp TempCol, 449
			jle COLUMNA_INSERTAR
			jmp SaltarHastaArroba ; Buscar '@' si TempCol > 450
			FILA_INSERTAR:          
				INC TempFil; Incrementa la Fila	
				cmp TempFil, 349
				jle ResetColumna
				jmp Fin_insertarSalto
				ResetColumna:
					MOV CX,ColCursor; Reinicia el valor de la columna
					MOV TempCol,CX
					jmp COLUMNA_INSERTAR; Salta si AX es menor o igual a 349		
		CmpArchivo:
			xor AL,AL
			cmp char_buffer, '0'
			je pint_00H_Salto
			cmp char_buffer, '1'
			je pint_01H_Salto
			cmp char_buffer, '2'
			je pint_02H_Salto
			cmp char_buffer, '3'
			je pint_03H_Salto
			cmp char_buffer, '4'
			je pint_04H_Salto
			cmp char_buffer, '5'
			je pint_05H_Salto
			jmp continuarCmp
;======================================================Salto Intermedio============================================================================
	Fin_insertarSalto:
	jmp Fin_insertar
	pint_00H_Salto:
	jmp pint_00H
	pint_01H_Salto:
	jmp pint_01H
	pint_02H_Salto:
	jmp pint_02H
	pint_03H_Salto:
	jmp pint_03H
	pint_04H_Salto:
	jmp pint_04H
	pint_05H_Salto:
	jmp pint_05H
;======================================================Salto Intermedio============================================================================	
			continuarCmp:
			cmp char_buffer, '6'
			je pint_06H
			cmp char_buffer, '7'
			je pint_07H
			cmp char_buffer, '8'
			je pint_08H
			cmp char_buffer, '9'
			je pint_09H
			cmp char_buffer, 'A'
			je pint_0AH
			cmp char_buffer, 'B'
			je pint_0BH
			cmp char_buffer, 'C'
			je pint_0CH
			cmp char_buffer, 'D'
			je pint_0DH
			cmp char_buffer, 'E'
			je pint_0EH
			cmp char_buffer, 'F'
			je pint_0FH
			jmp SeguirInsertando
			SaltarHastaArroba:
                ; Bucle para avanzar hasta encontrar '@' en el archivo
                mov AH, 3Fh; Función de DOS para leer archivo
                mov BX, handle
                mov DX, offset char_buffer
                mov CX, 1
                int 21h
                cmp char_buffer, '@'
                jne SaltarHastaArroba; Seguir leyendo si no se encuentra '@'
                jmp SeguirInsertando
			pint_00H:
				mov AL, 00H; Negro
				jmp pintPixelInsertado
			pint_01H:
				mov AL, 01H; Azul
				jmp pintPixelInsertado
			pint_02H:
				mov AL, 02H; Verde
				jmp pintPixelInsertado
			pint_03H:
				mov AL, 03H; Cian
				jmp pintPixelInsertado
			pint_04H:
				mov AL, 04H; Rojo
				jmp pintPixelInsertado
			pint_05H:
				mov AL, 05H; Magenta
				jmp pintPixelInsertado
			pint_0EH:
				mov AL, 0EH; Amarillo
				jmp pintPixelInsertado
			pint_06H:
				mov AL, 06H; Marron
				jmp pintPixelInsertado
			pint_07H:
				mov AL, 07H; Gris claro
				jmp pintPixelInsertado
			pint_08H:
				mov AL, 08H; Gris oscuro
				jmp pintPixelInsertado
			pint_09H:
				mov AL, 09H; Azul claro
				jmp pintPixelInsertado
			pint_0AH:
				mov AL, 0AH; Verde claro
				jmp pintPixelInsertado
			pint_0BH:
				mov AL, 0BH; Cian claro
				jmp pintPixelInsertado
			pint_0CH:
				mov AL, 0CH; Rojo claro
				jmp pintPixelInsertado
			pint_0DH:
				mov AL, 0DH; Magenta claro
				jmp pintPixelInsertado
			pint_0FH:
				mov AL, 0FH; Blanco
				jmp pintPixelInsertado
			
		pintPixelInsertado:
			MOV AH, 0CH; Interrupcion 10,C 
			MOV BH, 00; Numero de pagina
			MOV CX, TempCol; Columna
			MOV DX, TempFil; Fila
			INT 10H
			jmp SeguirInsertando
		
		Fin_insertar:
		; Cerrar el archivo
			mov AH,3eh
			int 21h
		MOV ImagenInsertada,0; Es cero para indicar que ya se inserto la imagen
		ret
	INSERTAR_IMAGEN endp
end