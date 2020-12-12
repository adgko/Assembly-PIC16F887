    LIST P=16F887
    #include <P16F887.INC>
    
;CONFIG1
    __CONFIG _CONFIG1, _FOSC_HS & _WDTE_OFF & _PWRTE_ON & _MCLRE_ON & _CP_OFF & _CPD_OFF & _BOREN_OFF & _IESO_ON & _FCMEN_ON & _LVP_OFF
;CONFIG2
    __CONFIG _CONFIG2, _BOR4V_BOR40V & _WRT_OFF
    
CONTA   EQU  0x21
CONTA2  EQU  0x25
TIEMPO1 EQU  22H
TIEMPO2 EQU  23H 
TIEMPO3 EQU  24H 
 
    ORG	    0
    bsf	    STATUS,RP0	    ;voy al banco 1
    ;clrf    TRISB
    bsf	    TRISB,6
    bsf	    TRISB,7
    clrf    TRISC
    clrf    PORTD
    bcf	    STATUS,RP0	    ;voy al banco 0
    ;bcf	    TRISC
    ;bcf	    TRISB,6
    clrf    PORTD

INICIO	   
	    movlw	0x09
	    movwf	CONTA2
	    movlw	0x40
	    movwf	PORTC
	    movlw	0x00
	    movwf	CONTA
	    ;CLRF	PORTC
BETA	    BTFSC	PORTB,6
	    goto	BETA
ALFA	    bsf		PORTB,6
	    INCF	CONTA
	    movfw	CONTA
	    CALL	TABLA
	    movwf	PORTC
	    CALL	RETARDO
	    BTFSS	PORTB,7
	    goto	INICIO
	    DECFSZ	CONTA2
	    goto	ALFA
	    goto	INICIO

TABLA
	    addwf   PCL	    ; suma a PC el valor del dígito
	    retlw   0x40    ; obtiene el valor 7 segmentos del 0
	    retlw   0x75    ; obtiene el valor 7 segmentos del 1 
	    retlw   0x24    ; obtiene el valor 7 segmentos del 2 
	    retlw   0x30    ; obtiene el valor 7 segmentos del 3 
	    retlw   0x19    ; obtiene el valor 7 segmentos del 4    
	    retlw   0x12    ; obtiene el valor 7 segmentos del 5
	    retlw   0x02    ; obtiene el valor 7 segmentos del 6
	    retlw   0x78    ; obtiene el valor 7 segmentos del 7
	    retlw   0x00    ; obtiene el valor 7 segmentos del 8
	    retlw   0x18    ; obtiene el valor 7 segmentos del 9		

RETARDO
		MOVLW	    D'2'
		MOVWF	    TIEMPO3
DEC3		MOVLW	    D'100'
		MOVWF	    TIEMPO2
DEC2		MOVLW	    D'207'
		MOVWF	    TIEMPO1
DEC1		DECFSZ	    TIEMPO1	;
		GOTO	    DEC1
		DECFSZ	    TIEMPO2	;
		GOTO	    DEC2
		DECFSZ	    TIEMPO3	;
		GOTO	    DEC3
		
		END