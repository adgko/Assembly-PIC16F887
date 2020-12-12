    List p=16f887
    radix	dec				;utilizar notación decimal
    #include <p16f887.inc>
    
; CONFIG1
; __config 0xEFF4
 __CONFIG _CONFIG1, _FOSC_INTRC_NOCLKOUT & _WDTE_OFF & _PWRTE_OFF & _MCLRE_ON & _CP_OFF & _CPD_OFF & _BOREN_ON & _IESO_ON & _FCMEN_ON & _LVP_OFF
; CONFIG2
; __config 0xFFFF
 __CONFIG _CONFIG2, _BOR4V_BOR40V & _WRT_OFF

;------------------------------------------------------------------------------------------------------------------

	#define		bank0	bcf	STATUS,RP0		
	#define		bank1	bsf	STATUS,RP0	
	#define		digit1	PORTB,3				;digito de control de centena de display
	#define		digit2  PORTB,2				;digito de control de decena de display
	#define		digit3	PORTB,1				;digito de control de unidad de display
	
	cblock		H'20'						
	
	TIME1									;Registrador auxiliar para temporizar
	TIME2									;Registrador auxiliar para temporizar
	TIME3									;Registrador auxiliar para temporizar
	
	REG1H									;byte alto registrador 1 de 16 bits utilizado en rutina de división
	REG1L									;byte bajo registrador 1 de 16 bits utilizado en rutina de división
	REG2H									;byte alto registrador 2 de 16 bits utilizado en rutina de división
	REG2L									;byte bajo registrador 2 de 16 bits utilizado en rutina de división
	REG3H									;byte alto registrador 3 de 16 bits utilizado en rutina de división
	REG3L									;byte bajo registrador 3 de 16 bits utilizado en rutina de división
	REG4H									;byte alto registrador 4 de 16 bits utilizado en rutina de división
	REG4L									;byte bajo registrador 4 de 16 bits utilizado en rutina de división
	AUX_H									;byte bajo de registrador de 16 bits para retornar valor de div
	AUX_L									;byte bajo de registrador de 16 bits para retornar valor de div
	AUX_TEMP								;contador temporario usado en la rutina de división
	REG_MULT1								;registrador 1 para multiplicación
	REG_MULT2								;registrador 2 para multiplicación
	REG_AUX									;registrador auxiliar
	UNI									;almacena unidad
	DEZ_A									;armacena unidad de decena
	DEZ_B									;almacena decena
	
	W_TEMP									;Registrador temporario para w
	STATUS_TEMP								;Registrador temporario para STATUS
	
	counter									;Registrador auxiliar de contagem
	CEN_DISP								;Centena de número en display
	DEZ_DISP								;Decena de número en display
	UNI_DISP								;Unidad de número en display
 
	endc			
	
;----------------------------------------------------------------------------------------------------------------------------------------------------
	
		ORG		0
		GOTO		inicio
		
		ORG		0x04						;vector interrupción
		
		movwf 		W_TEMP						;Copia w en w_temp
		swapf 		STATUS,W  					;trae STATUS a w
		bank0								;Seleciona el banco 0 de memoria 
		movwf 		STATUS_TEMP					;guarda w en status_temp
		
		btfss		INTCON,T0IF					;Hay interrupción de tmr0?
		goto		exit_ISR					;No, vamos a salida de interrupcion
		bcf		INTCON,T0IF					;Si, limpia el flag
		
		btfss		digit1						;Digito de centena activado?
		goto		copy_dez					;Si, desvía y actualiza decena
		btfss		digit2						;No. Digito de decena activado?
		goto		copy_uni					;Si, desvía y actualiza unidad
		btfss		digit3						;No. Digito de unidad activado?
 										;Si, actualiza centena.
		movlw		D'50'
		movwf		TMR0
											
copy_cen:

		bsf		digit2						;desactiva digito de decena
		bsf		digit3						;desactiva digito de unidad
		clrf		PORTC						;limpia PORTC
		bcf		digit1						;enciende digito de centena
		movf		CEN_DISP,W					;mueve lo que hay en centena a w
		call		send_disp					;llama a subrutina de mostrar en display
		movwf		PORTC						;y envía a PORTC el dato convertido
		goto		exit_ISR					;desvía a salida de interrupción
	
	
copy_dez:

		bsf		digit3						;desactiva digito de unidad
		bsf		digit1						;desactiva digito de centena
		clrf		PORTC						;limpia PORTC
		bcf		digit2						;enciende el dígito más significativo
		movf		DEZ_DISP,W					;mueve lo que hay en decena a w
		call		send_disp					;llama a subrutina de mostrar en display
		movwf		PORTC						;y envía a PORTC el dato convertido
		goto		exit_ISR					;desvía a salida de interrupción
	
copy_uni:

		bsf		digit1						;desactiva digito de centena
		bsf		digit2						;desactiva digito de decena
		clrf		PORTC						;Limpia PORTC
		bcf		digit3						;enciende digito de unidades
	        movf		UNI_DISP,W					;mueve lo que hay en decena a w
		call		send_disp					;llama a subrutina de mostrar en display
		movwf		PORTC						;y envía a PORTC el dato convertido
 
exit_ISR:

		swapf 		STATUS_TEMP,W					;copia en w el contenido de status_temp con los nibles invertidos
		movwf 		STATUS 						;recupera el contenido de STATUS
		swapf 		W_TEMP,F 					
		swapf 		W_TEMP,W  					;recupera w
	
		retfie	
		
;=====================================================================================================================================================
		
		;Main
inicio:

		movlw		H'A0'						
		movwf		INTCON						;habilita interrupcion global y tmr0
	
		bank1								
		movlw		H'D3'						
		movwf		OPTION_REG					;Timer0 incrementa con ciclo máquina, ps 1:32
		movlw		H'0E'						
		movwf		ADCON1						;AN0 analógico, justificación izquierda
		movlw		H'01'						
		movwf		TRISA						;configura todo PORTA como entrada
		movlw		b'00000000'						
		movwf		TRISB						;configura RB0,RB1 y RB2 como salida
		movlw		b'00000000'						
		movwf		TRISC						;configura todo PORTC como salida, exceto RB7
		
		bank0									
		movlw		H'41'						
		movwf		ADCON0						;fosc/8, enciende conversor AD
	
		movlw		D'50'
		movwf		TMR0
		bsf		digit1						;desactiva digito de centena
		clrf		UNI_DISP					;limpia unidad de display
		clrf		DEZ_DISP					;limpia decena de display
		clrf		CEN_DISP					;limpia centena de display
	
 
loop:

		bsf		ADCON0,GO_DONE					;inicia conversión AD
	
wait_ADC:

		btfsc		ADCON0,GO_DONE					;terminó?
		goto		wait_ADC					;No. Espero
	
		movf		ADRESH,W					;Si. Muevo el valor obtenido a W
	
	
		movwf		REG_MULT1					;guardo el valor para multiplicarlo
		movlw		D'250'						
		movwf		REG_MULT2					;guardo 250 para multiplicar, porque es la escala en voltaje
		call		multip						;llama a la subrutina para multiplicar
		movf		AUX_H,W						;traigo el contenido de AUX_H a w
		movwf		REG2H						;guardo el resultado 
		movf		AUX_L,W						;traigo el contenido de AUX_L a w
		movwf		REG2L						;guardo el resultado
		clrf		REG1H						;limpia REG1H
		movlw		D'255'						;muevo 255 para dividir, porque son las 255 convinaciones posibles de bit
		movwf		REG1L						;y las guardo en REG1L
		call		divid						;llama a la subrutina para dividir
		movf		REG2L,W						;traigo lo que hay en REG2L a w
	
	
		call		conv_binToDec					;lama a la rutina para convertir de binario a decimal
	
		movf		UNI,W						;traigo o que hay en UNI a w
		movwf		UNI_DISP					;y lo mando al display
		movf		DEZ_A,W						;traigo o que hay en DEZ a w
		movwf		DEZ_DISP					;y lo mando al display
		movf		DEZ_B,W						;traigo o que hay en CEN a w
		movwf		CEN_DISP					;y lo mando al display
	
	
		goto		loop						;vuelve a iniciar el ciclo
		
;----------------------------------BINARIO A DECIMAL----------------------------------------------------------------------------------------
conv_binToDec:

		movwf		REG_AUX						;guarda el valor a convertir
		clrf		UNI						;limpia unidad
		clrf		DEZ_A						;limpia decena A
		clrf		DEZ_B						;limpia decena B

		movf		REG_AUX,F					;REG_AUX = REG_AUX
		btfsc		STATUS,Z					;el valor es 0?
		return								;Si. Vuelve

start_adj:
						
		incf		UNI,F						;No. Incrementa Unidad
		movf		UNI,W						;traigo lo que hay en unidad a w
		xorlw		H'0A'						;W = UNI XOR 10d
		btfss		STATUS,Z					;es 10d?
		goto		end_adj						;No. Desvío y salgo
						 
		clrf		UNI						;Si. limpia registro UNI
		movf		DEZ_A,W						;traigo lo que hay en DEZ_A a w
		xorlw		H'09'						;W = DEZ_A XOR 9d
		btfss		STATUS,Z					;es 9d?
		goto		incDezA						;No, valor menor a 9. incremento DEZ_A
		clrf		DEZ_A						;Si.Limpio DEZ_A
		incf		DEZ_B,F						;Incrementa registrador DEZ_B
		goto		end_adj						;Desvia para end_adj
	
incDezA:
		incf		DEZ_A,F						;Incrementa DEZ_A
	
end_adj:
		decfsz		REG_AUX,F					;Decrementa REG_AUX. Finalizó la conversión ?
		goto		start_adj					;No. Continua
		return								;Si. Return
		
;=========================SUBRUTINA DE MULTIPLICACIÓN================================================================================
mult    MACRO   bit							;Inicio de macro de multiplicación

		btfsc		REG_MULT1,bit				;el bit actual de REG_MULT1 es 0?
		addwf		AUX_H,F					;No. Lo suma a AUX_H
		rrf		AUX_H,F					;rotaciona AUX_H para derecha y almacena el resultado en el mismo
		rrf		AUX_L,F					;rotaciona AUX_L para derecha y almacena el resultado en el mismo

		endm							;fin de macro


multip:

		clrf		AUX_H						;limpia AUX_H
		clrf		AUX_L						;limpia AUX_L
		movf		REG_MULT2,W					;traigo el contenido de Reg_MULT2 a w
		bcf		STATUS,C					;limpia el bit de carry

		mult    	0							;llama macro para cada dos 7 bits
		mult    	1							;de REG_MULT1
		mult    	2							;
		mult    	3							;
		mult    	4							;
		mult    	5							;
		mult    	6							;
		mult    	7							;

		return									;retorna

;==================================SUBRUTINA DE DIVISIÓN================================================================
divid:

		movlw		H'10'						
		movwf		AUX_TEMP					;cargael contador para la división

		movf		REG2H,W						;trae el contenido de REG2H a w
		movwf		REG4H						;y lo guarda en REG4H
		movf		REG2L,W						;traigo el contenido de REG2L a w
		movwf		REG4L						;y lo guarda en REG4L
		clrf		REG2H						;limpia REG2H
		clrf		REG2L						;limpia REG2L
		clrf		REG3H						;limpia REG3H
		clrf		REG3L						;limpia REG3L

DIV
		bcf		STATUS,C					;limpia bit de carry
		rlf		REG4L,F						;rotaciona REG4L para izquierda y lo almacena el resultado en el mismo
		rlf		REG4H,F						;rotaciona REG4H para izquierda y lo almacena el resultado en el mismo
		rlf		REG3L,F						;rotaciona REG3L para izquierda y lo almacena el resultado en el mismo
		rlf		REG3H,F						;rotaciona REG3H para izquierda y lo almacena el resultado en el mismo
		movf		REG1H,W						;traigo lo que esté en REG1H a w
		subwf		REG3H,W						;Work = REG3H - REG1H
		btfss		STATUS,Z					;Resultado igual a cero?
		goto		NOCHK						;No. Desvia para NOCHK
		movf		REG1L,W						;Si. Traigo lo que está en REG1L a w
		subwf		REG3L,W						;Work = REG3L - REG1L
	 
NOCHK
		btfss		STATUS,C					;Carry es 1?
		goto		NOGO						;No. Desvia para NOGO
		movf		REG1L,W						;Si. traigo lo que este en REG1L a w
		subwf		REG3L,F						;Work = REG3L - REG1L
		btfss		STATUS,C					;Carry es 1?
		decf		REG3H,F						;decrementa REG3H 
		movf		REG1H,W						;traigo lo que este en REG1H a w
		subwf		REG3H,F						;Work = REG3H - REG1H
		bsf		STATUS,C					; carry=1
	 
NOGO
		rlf		REG2L,F						;rotaciona REG2L para izquierda y lo almacena el resultado en el mismo
		rlf		REG2H,F						;rotaciona REG2H para izquierda y lo almacena el resultado en el mismo
		decfsz		AUX_TEMP,F					;decrementa AUX_TEMP. es cero?
		goto		DIV						;No. Continua dividiendo
		return								;Si. Retorna
	
;=================================================================================================================================================================
	
send_disp:									

		addwf		PCL,F				;PCL = PCL + W
				;' gfedcba'			
		retlw		b'11000000'			;Retorna símbolo '0'
		retlw		b'11111001'			;Retorna símbolo '1' 
		retlw		b'10100100'			;Retorna símbolo '2'
	 	retlw		b'10110000'			;Retorna símbolo '3'
	 	retlw		b'10011001'			;Retorna símbolo '4'
		retlw		b'10010010'			;Retorna símbolo '5' 
		retlw		b'10000010'			;Retorna símbolo '6' 
		retlw		b'11111000'			;Retorna símbolo '7' 
	 	retlw		b'10000000'			;Retorna símbolo '8'
		retlw		b'10010000'			;Retorna símbolo '9' 
		
;============================================================================================================================================
		
		END