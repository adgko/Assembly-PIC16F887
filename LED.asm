    LIST P=16f887
	#include <P16F887.INC>
    
;CONFIG1
    __CONFIG _CONFIG1, _FOSC_HS & _WDTE_OFF & _PWRTE_ON & _MCLRE_ON & _CP_OFF & _CPD_OFF & _BOREN_OFF & _IESO_ON & _FCMEN_ON & _LVP_OFF
;CONFIG2
    __CONFIG _CONFIG2, _BOR4V_BOR40V & _WRT_OFF
    
reg1 equ    0x20
reg2 equ    0x21
reg3 equ    0x22
	
    ORG 0
    bsf STATUS, RP0	; Me dirijo al banco 1
    bcf TRISB, 0	; Configuro Pin 0 puerto B como salida
    bcf STATUS, RP0	; Me dirijo al banco 0
    
INICIO     
    bsf	PORTB,0		; Lo enciendo
    GOTO RETARDO	; Espero
    GOTO INICIO
    bcf PORTB,0		; Lo apago
    GOTO RETARDO	; Espero
    GOTO INICIO
RETARDO	
    movlw	D'4'     
    movwf	reg1
TRES
    movlw	D'100'
    movwf	reg2
DOS
    movlw	D'207'
    movwf	reg3
UNO
    decfsz	reg3,1	
    goto	UNO
    decfsz	reg2,1
    goto	DOS
    decfsz	reg1,1
    goto	TRES

    END


//////////////////////////////////////////////

	list p=16f887
	#include <p16f887.inc>

    __CONFIG _CONFIG1, _FOSC_HS & _WDTE_OFF & _PWRTE_ON & _MCLRE_ON & _CP_OFF & _BOREN_OFF & _IESO_ON & _FCMEN_ON & _LVP_OFF
    __CONFIG _CONFIG2, _BOR4V_BOR40V & _WRT_OFF
	
TIEMPO1 EQU 21H
TIEMPO2 EQU 22H 
TIEMPO3 EQU 23H 

		org 0
		bsf	    STATUS, RP0
		;CLRF	    PORTB
		bcf TRISB,0
		bcf	    STATUS, RP0
		
INICIO
		BCF	    PORTB, 0
		CALL	    RETARDO
		BSF	    PORTB, 0
		CALL	    RETARDO
		GOTO	    INICIO
		
RETARDO
		MOVLW	    D'4'
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
