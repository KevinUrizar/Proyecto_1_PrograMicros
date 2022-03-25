; Archivo:	main.s
; Dispositivo:	PIC16F887
; Autor:	Kevin Urizar
; Compilador:	pic-as (v2.35), MPLABX V6.00
;                
; Programa	reloj digital con diferentes modos 
; Hardware:	dispays, botones y leds. 		
;
; Creado:	07 marz 2022
; Última modificación: 07 marz 2022
    
PROCESSOR 16F887
    
; PIC16F887 Configuration Bit Settings

; Assembly source line config statements

; CONFIG1
  CONFIG  FOSC = INTRC_NOCLKOUT ; Oscillator Selection bits (INTOSCIO oscillator: I/O function on RA6/OSC2/CLKOUT pin, I/O function on RA7/OSC1/CLKIN)
  CONFIG  WDTE = OFF            ; Watchdog Timer Enable bit (WDT disabled and can be enabled by SWDTEN bit of the WDTCON register)
  CONFIG  PWRTE = OFF            ; Power-up Timer Enable bit (PWRT enabled)
  CONFIG  MCLRE = OFF           ; RE3/MCLR pin function select bit (RE3/MCLR pin function is digital input, MCLR internally tied to VDD)
  CONFIG  CP = OFF              ; Code Protection bit (Program memory code protection is disabled)
  CONFIG  CPD = OFF             ; Data Code Protection bit (Data memory code protection is disabled)
  CONFIG  BOREN = OFF           ; Brown Out Reset Selection bits (BOR disabled)
  CONFIG  IESO = OFF            ; Internal External Switchover bit (Internal/External Switchover mode is disabled)
  CONFIG  FCMEN = OFF           ; Fail-Safe Clock Monitor Enabled bit (Fail-Safe Clock Monitor is disabled)
  CONFIG  LVP = OFF              ; Low Voltage Programming Enable bit (RB3/PGM pin has PGM function, low voltage programming enabled)

; CONFIG2
  CONFIG  BOR4V = BOR40V        ; Brown-out Reset Selection bit (Brown-out Reset set to 4.0V)
  CONFIG  WRT = OFF             ; Flash Program Memory Self Write Enable bits (Write protection off)

// config statements should precede project file includes.
#include <xc.inc>
;#include "conteo.inc"  
  
  
; -------------- MACROS --------------- 
  ; Macro para reiniciar el valor del TMR0
  ; **Recibe el valor a configurar en TMR_VAR**
  RESET_TMR0 MACRO TMR_VAR
    BANKSEL TMR0	    ; cambiamos de banco
    MOVLW   TMR_VAR
    MOVWF   TMR0	    ; configuramos tiempo de retardo
    BCF	    T0IF	    ; limpiamos bandera de interrupción
    ENDM  
    
    
  RESET_TMR1 MACRO TMR1_H, TMR1_L
    MOVLW   TMR1_H	    ; Literal a guardar en TMR1H
    MOVWF   TMR1H	    ; Guardamos literal en TMR1H
    MOVLW   TMR1_L	    ; Literal a guardar en TMR1L
    MOVWF   TMR1L	    ; Guardamos literal en TMR1L
    BCF	    TMR1IF	    ; Limpiamos bandera de int. TMR1
    ENDM  

  
 
 PSECT udata_shr		    
    W_TEMP:	DS 1
    STATUS_TEMP:  DS 1
    
PSECT udata_bank0
bandera_ene:	DS 1
bandera_feb:	DS 1   
bandera_marz:	DS 1   
bandera_abr:	DS 1   
bandera_may:	DS 1   
bandera_jun:	DS 1   
bandera_jul:	DS 1   
bandera_ago:	DS 1   
bandera_sep:	DS 1   
bandera_oct:	DS 1   
bandera_nov:	DS 1   
bandera_dic:	DS 1   

u_segundos: DS 2  
d_segundos: DS 2  
u_minutos: DS 2
d_minutos: DS 2
u_horas: DS 2
d_horas: DS 2
horas_24: DS 2
bandera1: DS 1
bandera2: DS 1
bandera3: DS 1
bandera4: DS 1
bandera5: DS 1
bandera6: DS 1
display:  DS 6 
bandera_edit1: DS 1
bandera_reloj: DS 1

u_dias:	  DS 1
d_dias:	  DS 1
u_mes:	  DS 1
d_mes:    DS 1
mes:	  DS 1  
dias_limite: DS 1
EDITAR: DS 1
ESTADO:	DS 1
LED:    DS 1    
KO:	DS 1
PPP:	DS 1    
    
PSECT resVect, class=CODE, abs, delta=2
ORG 00h			    
;------------ vector de reseteo --------------
resetVec:
    PAGESEL MAIN		
    GOTO    MAIN
    
PSECT intVect, class=CODE, abs, delta=2
ORG 04h				
;------- vector de interrupciones ----------
PUSH:
    MOVWF   W_TEMP		
    SWAPF   STATUS, W
    MOVWF   STATUS_TEMP	 
    
ISR:
    ;CALL	VERIFICAR_EDITAR

    
    
    
    BTFSC   T0IF	    ; Interrupcion de TMR0
    CALL    INT_TMR0   
   		
   BTFSC   RBIF	
   CALL    INT_PORTB
    
    BTFSC   TMR1IF
    CALL    INT_TMR1
    
    BTFSC   TMR2IF
    CALL    INT_TMR2
    
    /*BTFSC   estado,0
    CALL    EDITAR
    CALL    MODO_NORMAL
    
   /* MODO_NORMAL:
    BTFSC   RBIF	    ;verifio mi bandera 
    GOTO    $+2		    ; si se presiona voy a verficar el boton
    GOTO    $+3
    CALL    SETEAR_ESTADO1
    CALL    INT_PORTB_00
    BCF	    RBIF
    GOTO    POP
    
    EDITAR:
    BTFSC   RBIF	    ;verifico mi bandera 
    ;GOTO    $+2
    ;GOTO    $+6
    ;BTFSC   PORTD, 0
    CALL    EDITAR_RELOJ
    ;BTFSC   PORTD, 1
    ;CALL    EDITAR_FECHA
    ;BTFSC   PORTD, 2
    ;CALL    EDITAR_TIMER
    CALL    SETEAR_ESTADO2
    BCF	    RBIF
    GOTO    POP*/
    
POP:
    SWAPF   STATUS_TEMP, W  
    MOVWF   STATUS		
    SWAPF   W_TEMP, F	    
    SWAPF   W_TEMP, W		
    RETFIE
    
   /* SETEAR_ESTADO1:	;en mi loop principal verifico el boton 
 BTFSS	PORTB, 1	; si se presiona voy a ncender estado
 RETURN
 BSF	estado, 0
 RETURN
 SETEAR_ESTADO2:
 BTFSS	PORTB, 1
 RETURN
 BCF	estado, 0
 RETURN*/
    
 INT_PORTB:
 BTFSC	PORTB, 0
 CALL	CAMBIO_ESTADO
 BTFSC	PORTB, 1
 CALL	CAMBIO_ESTADO_EDIT
 BTFSC	PORTB, 2
 CALL	INCREMENTAR
 BTFSC	PORTB, 3
 CALL	DECREMENTAR
 BSF	RBIF	
 RETURN
 
 
 
 
CAMBIO_ESTADO:
    INCF    ESTADO, F
    MOVF    ESTADO, W
    SUBLW   4
    BTFSS   STATUS, 2
    RETURN
    BSF	    ESTADO, 0
    RETURN
    
CAMBIO_ESTADO_EDIT:
    INCF    EDITAR, F  
    MOVF    EDITAR, W
    SUBLW   4
    BTFSS   STATUS, 2
    RETURN
    BSF	    ESTADO, 0
    RETURN

INCREMENTAR:
    MOVF    ESTADO, W
    SUBLW   1
    BTFSC   STATUS, 2
    CALL    INCREMENTAR_RELOJ
    MOVF    ESTADO, W
    SUBLW   2
    BTFSC   STATUS, 2
    CALL    INCREMENTAR_FECHA
    MOVF    ESTADO, W
    SUBLW   3
    BTFSC   STATUS, 2
    CALL    INCREMENTAR_TIMER
    RETURN
 
DECREMENTAR:
    MOVF    ESTADO, W
    SUBLW   1
    BTFSC   STATUS, 2
    CALL    DECREMENTAR_RELOJ
    MOVF    ESTADO, W
    SUBLW   2
    BTFSC   STATUS, 2
    CALL    DECREMENTAR_FECHA
    MOVF    ESTADO, W
    SUBLW   3
    BTFSC   STATUS, 2
    CALL    DECREMENTAR_TIMER
    RETURN   
    
  INCREMENTAR_RELOJ:
    MOVF    EDITAR, W
    SUBLW   2
    BTFSC   STATUS, 2
    CALL    INCREMENTAR_HORAS
    MOVF    ESTADO, W
    SUBLW   3
    BTFSC   STATUS, 2
    CALL    INCREMENTAR_MINUTOS
    RETURN
    
  INCREMENTAR_FECHA:
    
    RETURN
    
  INCREMENTAR_TIMER:
    
    RETURN
    
  DECREMENTAR_RELOJ:
    
    RETURN
    
  DECREMENTAR_FECHA:
    
    RETURN
    
  DECREMENTAR_TIMER:
    
    RETURN
    
    
  ;------INCREMENTOS--------------
  
  INCREMENTAR_HORAS:
    
    /*INCF    u_horas
    INCF    horas_24
    MOVF    u_horas, W
    SUBLW   10
    BTFSS   STATUS, 2
    RETURN
    CLRF    u_horas
    INCF    d_horas
    MOVF    horas_24, W
    SUBLW   24
    BTFSS   STATUS, 2	
    RETURN 
    CLRF    d_horas
    CLRF    u_horas
    CLRF    horas_24*/
    RETURN
    
 INCREMENTAR_MINUTOS:
    
    /*INCF    u_minutos
    MOVF    u_minutos, W
    SUBLW   10
    BTFSS   STATUS, 2
    RETURN
    CLRF    u_minutos
    INCF    d_minutos
    MOVF    d_minutos, W
    SUBLW   6
    BTFSS   STATUS, 2
    RETURN 
    CLRF    d_minutos*/
    RETURN  
    
    
/*
    BTFSS   PORTD, 0		; Verificamos en que estado estamos 
    GOTO    $+2
    GOTO    ESTADO_0
    BTFSS   PORTD, 1		; Verificamos en que estado estamos 
    GOTO    $+2
    GOTO    ESTADO_1 
    BTFSS   PORTD, 2		; Verificamos en que estado estamos 
    GOTO    $+2
    GOTO    ESTADO_2
    BTFSS   PORTD, 3		; Verificamos en que estado estamos 
    GOTO    $+2
    ;GOTO    ESTADO_3
    ;BTFSS   PORTD, 4		; Verificamos en que estado estamos 
    ;GOTO    $+2
    ;GOTO    ESTADO_4
    
    ESTADO_0:
	BTFSC   PORTB, 0	; Si se presionó botón de cambio de modo
	GOTO	$+2
	;BTFSC	PORTB, 1
	;GOTO	EDITAR
	GOTO	$+4
	BCF	PORTD, 2
	BCF	PORTD, 0
	BSF	PORTD, 1
	BCF	RBIF
    RETURN
    
    ESTADO_1:
	BTFSC   PORTB, 0	; Si se presionó botón de cambio de modo
	GOTO	$+2
	GOTO	$+3
	BCF	PORTD, 1
	BSF	PORTD, 2
	BCF	RBIF
    RETURN
 
   ESTADO_2:
	BTFSC   PORTB, 0	; Si se presionó botón de cambio de modo
	GOTO	$+2
	GOTO	$+3
	BCF	PORTD, 2
	BSF	PORTD, 0
	BCF	RBIF
    RETURN
 
    
   /* ESTADO_3:
	BTFSC   PORTB, 0	; Si se presionó botón de cambio de modo
	GOTO	$+2
	GOTO	$+3
	BCF	PORTD, 3
	BSF	PORTD, 4
	BCF	RBIF
    RETURN
 
    ESTADO_4:
	BTFSC   PORTB, 0	; Si se presionó botón de cambio de modo
	GOTO	$+2
	GOTO	$+3
	BCF	PORTD, 4
	BSF	PORTD, 0
	BCF	RBIF
    RETURN*/

   /*EDITAR_RELOJ:
    BTFSC   PORTB, 2
    CALL    incremento_horas
    BTFSC   PORTB, 3
    CALL    incremento_minutos
    RETURN
    
    
    incremento_horas:
     
    INCF    u_horas
    INCF    horas_24
    MOVF    u_horas, W
    SUBLW   10
    BTFSS   STATUS, 2
    RETURN
    /*CLRF    u_horas
    INCF    d_horas
    MOVF    horas_24, W
   SUBLW   24
    BTFSS   STATUS, 2	
    RETURN 
    CLRF    d_horas
    CLRF    u_horas
    CLRF    horas_24
    RETURN
    
    
    incremento_minutos:
    
    INCF    u_minutos
    MOVF    u_minutos, W
    SUBLW   10
    BTFSS   STATUS, 2
    RETURN
    /*CLRF    u_minutos
    INCF    d_minutos
    MOVF    d_minutos, W
    SUBLW   6
    BTFSS   STATUS, 2
    RETURN 
    CLRF    d_minutos
    RETURN  
    
  /*  
   BTFSC    bandera_reloj, 0
   GOTO	    editar_u_reloj
   GOTO	    editar_u_min
   editar_u_reloj:
    BTFSC   PORTB, 2	    ;verifico para cambio de bandera
    BCF	    bandera, 0
   BTFSC    PORTB, 3
   CALL	    incremento_horas
   RETURN
   
   editar_u_min:
   BTFSC    PORTB, 2	    ;verifico para cambio de bandera
   BSF	    bandera, 0
   BTFSC    PORTB, 3
   CALL	    incremento_minutos
   RETURN 
    
   EDITAR_FECHA:
    RETURN
    
    EDITAR_TIMER:
    RETURN*/
    
    
  
INT_TMR0:		 ;interrumpcion de timer 0
RESET_TMR0 240		 ;regreso  el valor para no iniciar de 0 a 240
INCF	LED, F    
;CALL	MOSTRAR_VALOR   
RETURN
    
    
INT_TMR1:
    
  RESET_TMR1 0xC2, 0xF7   ; Reiniciamos TMR1 para 1 s 49911
    
  INCF	    u_segundos, F
  RETURN  
  
  INT_TMR2:
    
    
    /* BCF	    TMR2IF
     		                 ;
     BTFSC	    bandera, 0	    ; verificamos la vandera 
     goto	    apagar
     goto	    encender
    
    encender:
    BSF		    PORTD, 5
    BSF		    bandera,0
    return
    
    apagar: 
    BCF		    PORTD, 5
    BCF		    bandera,0*/
    RETURN
    
 ;--------subrutinas-------------------------------	
 
 LEDS:
    MOVF     LED, W
    SUBLW   250
    BTFSS   STATUS, 2
    RETURN
    CLRF    LED
    INCF    PORTE
  RETURN
 ;conteo_reloj:
    
  RELOJ:		    ;macro para mis minutos y horas 
  MOVF	    u_segundos, W	    ;movemos el incremento a w
 SUBLW	    10			    ; le restamos 10
 BTFSS	    STATUS, 2		    ;verificamos si la resta es 0
RETURN
 CLRF	    u_segundos		    ;cuando sea 0 limpio mi variable 
 
 ;------------continuamos con las decenas---------
 INCF	    d_segundos		    ;luego incrementos mis decenas y repito
 MOVF	    d_segundos, W
 SUBLW	    6			    ; en este caso resto 6
 BTFSS	    STATUS, 2
RETURN
 CLRF	    d_segundos
 
 ;----------continuo con las unidades de minutos--
 INCF	    u_minutos
 MOVF	    u_minutos, W
 SUBLW	    10
 BTFSS	    STATUS, 2
  RETURN	    				    ; si no retornamos 
 CLRF	    u_minutos
 
 ;--------continuo con la decena de minutos------
 INCF	    d_minutos
 MOVF	    d_minutos, W
 SUBLW	    6
 BTFSS	    STATUS, 2
 RETURN
 CLRF	    d_minutos
 
 ;-------continuo oon la unidad de horas--------
 INCF	    u_horas
 INCF	    horas_24		   ;incremento esta variable que servira despues
 MOVF	    u_horas, W
 SUBLW	    10
 BTFSS	    STATUS, 2
RETURN
 CLRF	    u_horas
 
 ;-------continuo con la decena de horas-------
 INCF	    d_horas		   ;unicamente la incremente, despues reseteo

    
 RETURN
 
 RESET_24H:
    
    MOVF    horas_24, W
    SUBLW   24
    BTFSS   STATUS, 2
    RETURN
    CLRF    horas_24
    CLRF    d_horas
    CLRF    u_horas
    ;INCF    u_dias
    ;INCF    dias_limite
    RETURN
    
MOSTRAR_ESTADO:
    
    MOVF    ESTADO, W
    SUBLW   1
    BTFSC   STATUS, 2
    GOTO    ENCENDER_LED1	        
    MOVF    ESTADO, W
    SUBLW   2
    BTFSC   STATUS, 2
    GOTO    ENCENDER_LED2
    MOVF    ESTADO, W
    SUBLW   3
    BTFSC   STATUS, 2
    GOTO   ENCENDER_LED3
    RETURN   
    
    ENCENDER_LED1:
    BSF	    PORTD, 0
    BCF	    PORTD, 1
    BCF	    PORTD, 2
    
    RETURN
    
    ENCENDER_LED2: 
    
    BCF	    PORTD, 0
    BSF	    PORTD, 1
    BCF	    PORTD, 2
    
    RETURN
    
    ENCENDER_LED3:
    BCF	    PORTD, 1
    BSF	    PORTD, 2
    BCF	    PORTD, 0
    RETURN
 
MOSTRAR_EDITAR:
    
    	        
    MOVF    EDITAR, W
    SUBLW   2
    BTFSC   STATUS, 2
    GOTO    ENCENDER_LED5
    MOVF    EDITAR, W
    SUBLW   3
    BTFSC   STATUS, 2
    GOTO   ENCENDER_LED6
    RETURN   
    
    ENCENDER_LED5: 
    BSF	    PORTD, 3
    BCF	    PORTD, 4
   
    RETURN
    
    ENCENDER_LED6:
    BCF	    PORTD, 3
    BSF	    PORTD, 4
    
    RETURN
    
    
    
 /*FECHA:				    ;macro para mi fecha
    ;--------enero-----------------
     
 
*/
 

  /*
VERIFICAR_EDITAR:	    ;subrutina se activs cuando estado vale 1
    
    BTFSS  PORTD, 3	    ; verifico en sub estado me encuentro 
    GOTO    $+2
    GOTO    estado_normal
    BTFSS   PORTD, 4
    GOTO    $+2
    GOTO    editar_horas
    BTFSS   PORTD, 5
    GOTO    $+2
    GOTO    editar_minutos
    
    estado_normal:	    ;no realiza nada, solo se enciende un puerto
    BTFSC   PORTB, 1	    ; verifico si el boton de editar se presiona 
    GOTO    $+2		    ; si se presiona cambio de estado y salto a borrar estado
    GOTO    $+3		    ; si no se presiona borro estado y regreso 
    BSF	    PORTD, 4	    ;enciendo puerto siguiente 
    BCF	    PORTD, 3	    ; apago puerto actual
    
    CLRF    estado
    RETURN
    editar_horas:
    
    /*BTFSC   PORTB, 1
    GOTO    $+2
    GOTO    $+3
    BSF	    PORTD, 5
    BCF	    PORTD, 4
    BTFSC   PORTB, 2*/	    ;verifico si se presiona el boton de incremento 
   /* CALL    incremento_horas ; si se presiona llamo a mi subrrutina 
    CLRF    estado		; si no limpio estado y regreso 
    RETURN*/
    
   /* editar_minutos:
    /*BTFSC   PORTB, 1
    GOTO    $+2
    GOTO    $+3
    BSF	    PORTD, 3
    BCF	    PORTD, 5
    BTFSC   PORTB, 		    ;verifico boton de incremento 	    
    CALL    incremento_minutos	    ; llamo a mi subrrutina 
    CLRF    estado		    ;limpio estado
    RETURN*/
    
    
    
      
      
    /*BTFSS   estado, 0
    RETURN
    BTFSS   PORTD, 0		; verifico el estado en el que estoy
    GOTO    $+2
    GOTO    EDITAR_RELOJ	; si es el estado 0 voy a editar el reloj
    BTFSS   PORTD, 1
    GOTO    $+2
    GOTO    EDITAR_FECH
    BTFSS   PORTD, 2
    GOTO    $+2
    GOTO    EDITAR_TIMER
	   
	EDITAR_RELOJ:		;verifico en que estado de edicion estoy
	
	BTFSS	PORTD, 6	;estoy en modo editar horas
	GOTO	$+2
	GOTO	EDIT_HOR
	BTFSS	PORTD, 7	;estoy en modo editar minutos 
	GOTO	$+2
	GOTO	EDIT_MIN

	
	  
	    EDIT_HOR:			;edicion de hora
	
	    BTFSC   PORTB, 1		;verifico si se preciona boton ditar
	    GOTO    cambio_estado			; si se presiona cambio de estado
	    BTFSC   PORTB, 2
	    GOTO    incrementar_horas		
	    RETURN			; si se presiona ejecuto el incremento
	    
	    incrementar_horas:		; si no retorno 
	    INCF    u_horas+1
	    INCF    horas_24+1
	    MOVF    u_horas+1, W
	    SUBLW   10
	    BTFSS   STATUS, 2
	    GOTO    $+2
	    GOTO    $+2
	    MOVF    u_horas, W		; Movemos unidad  a W
	    CALL    TABLA_7SEGNEG		; Buscamos valor a cargar en PORTC
	    MOVWF   display+4		; Guardamos en display 
	    RETURN
	    CLRF    u_horas+1
	    INCF    d_horas+1
	    MOVF    horas_24+1, W
	    SUBLW   24
	    BTFSS   STATUS, 2
	    GOTO    $+2
	    GOTO    $+2
	    MOVF    d_horas, W		; Movemos unidad  a W
	    CALL    TABLA_7SEGNEG		; Buscamos valor a cargar en PORTC
	    MOVWF   display+5		; Guardamos en display
	    RETURN 
	    CLRF    d_horas+1
	    CLRF    u_horas+1
	    CLRF    horas_24+1
	    RETURN
	    
	    cambio_estado:
	    BCF PORTD, 6		;apago estado
	    BSF	PORTB, 7		;enciendo proximo estado
	    RETURN
	    
	    EDIT_MIN:
	    
	    BTFSC   PORTB, 1		;verifico si se preciona boton ditar
	    GOTO    cambio_estado2			; si se presiona cambio de estado
	    BTFSC   PORTB, 2
	    GOTO    incrementar_min		
	    RETURN			; si se presiona ejecuto el incremento
	    
	    incrementar_min:		; si no retorno 
	    INCF    u_minutos+1
	    MOVF    u_minutos+1, W
	    SUBLW   10
	    BTFSS   STATUS, 2
	    GOTO    $+2
	    GOTO    $+2
	    MOVF    u_minutos, W		; Movemos unidad  a W
	    CALL    TABLA_7SEGNEG		; Buscamos valor a cargar en PORTC
	    MOVWF   display+2		; Guardamos en display 
	    RETURN
	    CLRF    u_minutos+1
	    INCF    d_minutos+1
	    MOVF    d_minutos+1, W
	    SUBLW   6
	    BTFSS   STATUS, 2
	    GOTO    $+2
	    GOTO    $+2
	    MOVF    d_minutos, W		; Movemos unidad  a W
	    CALL    TABLA_7SEGNEG		; Buscamos valor a cargar en PORTC
	    MOVWF   display+3		; Guardamos en display
	    RETURN 
	    CLRF    d_minutos+1
	   
	    RETURN
	    
	    cambio_estado2:
	    BCF PORTD, 7		;apago estado
	    BSF	PORTB, 6		;enciendo proximo estado
	    BCF	estado, 0
	    RETURN
	    
	EDITAR_FECH:
	RETURN
	
	EDITAR_TIMER:
	RETURN
	    
	
	
    
    
    
    
/*CHECKBOTON:
    BTFSC PORTB, 0
    GOTO CHECKBOTON 
    
ANTIREBOTES:
    BTFSS PORTB, 0
    GOTO ANTIREBOTES
    RETURN*/
  
SET_DISPLAYS:
    
    MOVF    ESTADO, W
    SUBLW   1
    BTFSC   STATUS, 2
    CALL    mostrar_hora	        
    MOVF    ESTADO, W
    SUBLW   2
    BTFSC   STATUS, 2
    CALL    mostrar_fecha
    MOVF    ESTADO, W
    SUBLW   3
    BTFSC   STATUS, 2
    CALL    mostrar_temporizador   
    RETURN
    mostrar_hora:
    
    MOVF    u_segundos, W		; Movemos unidad  a W
    CALL    TABLA_7SEGNEG		; Buscamos valor a cargar en PORTC
    MOVWF   display		; Guardamos en display
    
    MOVF    d_segundos, W		; Movemos decenaa W
    CALL    TABLA_7SEGNEG		; Buscamos valor a cargar en PORTC
    MOVWF   display+1		; Guardamos en display+1
    
    MOVF    u_minutos, W		; Movemos unidad  a W
    CALL    TABLA_7SEGNEG		; Buscamos valor a cargar en PORTC
    MOVWF   display+2		; Guardamos en display
    
    MOVF    d_minutos, W		; Movemos decenaa W
    CALL    TABLA_7SEGNEG		; Buscamos valor a cargar en PORTC
    MOVWF   display+3		; Guardamos en display+1
    
    MOVF    u_horas, W		; Movemos unidad  a W
    CALL    TABLA_7SEGNEG		; Buscamos valor a cargar en PORTC
    MOVWF   display+4		; Guardamos en display
    
    MOVF    d_horas, W		; Movemos decenaa W
    CALL    TABLA_7SEGNEG		; Buscamos valor a cargar en PORTC
    MOVWF   display+5		; Guardamos en display+1
    
    RETURN    

    

    
    mostrar_fecha:
    
   RETURN
    
    mostrar_temporizador:
    
    RETURN
    
/*MOSTRAR_VALOR:
    
    BSF	    PORTA, 0		; Apagamos display de unudad
    BSF	    PORTA, 1		; Apagamos display de decena
    BSF	    PORTA, 2
    BSF	    PORTA, 3
    BSF	    PORTA, 4
    BSF	    PORTA, 5 
    ;BTFSC   bandera1, 0		; Verificamos bandera4
    ;GOTO    $+2
    ;GOTO    DISPLAY_0
    ;BTFSC   bandera2, 0		; Verificamos bandera4
    ;GOTO    $+2
    ;GOTO    DISPLAY_1
    BTFSC   bandera3, 0		; Verificamos bandera4
    ;GOTO    $+2
    GOTO    DISPLAY_2
    BTFSC   bandera4, 0		; Verificamos bandera4
    ;GOTO    $+2
    GOTO    DISPLAY_3
    BTFSC   bandera5, 0		; Verificamos bandera4
    ;GOTO    $+2
    GOTO    DISPLAY_4
    BTFSC   bandera6, 0		; Verificamos bandera4
    ;GOTO    $+2
    GOTO    DISPLAY_5
  
    /*DISPLAY_0:			
	MOVF    display, W	; Movemos display a W
	MOVWF	    PORTC		; Movemos Valor de tabla a PORTC
	BCF	    PORTA, 0		; encendemos el display a mostrar	
	BSF	bandera2, 0	; Cambiamos bandera para cambiar el otro display en la siguiente interrupción
	BCF	bandera1, 0	; apagamos bandera actual
    RETURN

    DISPLAY_1:
	MOVF    display+1, W	; Movemos display a W
	MOVWF	    PORTC		; Movemos Valor de tabla a PORTC
	                         ; encendemos el display a mostrar
	BCF	    PORTA, 1			
	BSF	bandera3, 0	; Cambiamos bandera para cambiar el otro display en la siguiente interrupción
	BCF	bandera2, 0	; apagamos bandera actual
    RETURN
    DISPLAY_2:			
	MOVF    display+2, W	; Movemos display a W
	MOVWF	    PORTC		; Movemos Valor de tabla a PORT		
	BCF	    PORTA, 2
	BSF	bandera4, 0	; Cambiamos bandera para cambiar el otro display en la siguiente interrupción
	BCF	bandera3, 0	; apagamos bandera actual
        RETURN

    DISPLAY_3:
	MOVF    display+3, W	; Movemos display a W
	MOVWF	    PORTC		; Movemos Valor de tabla a PORTC
	BCF	    PORTA, 3
	BSF	bandera5, 0	; Cambiamos bandera para cambiar el otro display en la siguiente interrupción
	BCF	bandera4, 0	; apagamos bandera actual
        RETURN	
	
    DISPLAY_4:			
	MOVF    display+4, W	; Movemos display a W
	MOVWF	    PORTC		; Movemos Valor de tabla a PORTC	
	BCF	    PORTA, 4
	BSF	bandera6, 0	; Cambiamos bandera para cambiar el otro display en la siguiente interrupción
	BCF	bandera5, 0	; apagamos bandera actual
        RETURN

    DISPLAY_5:
	MOVF    display+5, W	; Movemos display a W
	MOVWF	    PORTC		; Movemos Valor de tabla a PORTC
	BCF	    PORTA, 5 	; Encendemos display 
	BSF	bandera3, 0	; Cambiamos bandera para cambiar el otro display en la siguiente interrupción
	BCF	bandera6, 0	; apagamos bandera actual
        RETURN
    */
	
	
    
 
    
    
PSECT code, delta=2, abs
ORG 100h			
;-------------------------
MAIN:
    CALL    CONFIG_IO		
    CALL    CONFIG_RELOJ
    CALL    CONFIG_TMR0
    CALL    CONFIG_TMR1	    ; Configuración de TMR1
    CALL    CONFIG_TMR2
    CALL    CONFIG_INT	
    ;BANKSEL PORTD	    ; Cambio a banco 00

CLRF	u_segundos 
CLRF	d_segundos
CLRF	u_minutos
CLRF	d_minutos
CLRF	u_horas
CLRF	d_horas
CLRF	horas_24
    
CLRF	bandera_ene
CLRF	bandera_feb  
CLRF	bandera_marz	   
CLRF	bandera_abr  
CLRF	bandera_may  
CLRF	bandera_jun   
CLRF	bandera_jul  
CLRF	bandera_ago   
CLRF	bandera_sep   
CLRF	bandera_oct   
CLRF	bandera_nov   
CLRF	bandera_dic    
BSF	ESTADO,0
BSF	EDITAR,0
CLRF	bandera_reloj
   
BSF u_mes,0
BSF u_dias ,0   
 BANKSEL PORTD   
loop:
    ;BANKSEL PORTD
    ;CALL	CHECKBOTON
   CALL     LEDS 
 ;  
   ;CALL	    SETEAR_ESTADO1
   ;CALL	    SETEAR_ESTADO2
   ;CALL	    SETEAR_ESTADO3
  ; CALL	VERIFICAR_EDITAR
   CALL	    MOSTRAR_ESTADO
   CALL	    MOSTRAR_EDITAR
   CALL	    RELOJ  
   CALL	    SET_DISPLAYS
   CALL	    RESET_24H
;   CALL	FECHA
   ;CALL	LIMITE_MES
   
    
    
    GOTO    loop	    
        
;------------- subrutinas de configuracion ---------------

    
CONFIG_IO:
;    CLRF    estado
    BANKSEL ANSEL
    CLRF    ANSEL
    CLRF    ANSELH		
    BANKSEL TRISD		
  
    BCF	    TRISD, 0
    BCF	    TRISD, 1
    BCF	    TRISD, 2
    BCF     TRISD, 3
    BCF	    TRISD, 4
    BCF	    TRISD, 5
    BCF	    TRISD, 6
    BCF	    TRISD, 7
    CLRF    TRISE
    BCF	    TRISA, 0
    BCF	    TRISA, 1
    BCF	    TRISA, 2
    BCF     TRISA, 3
    BCF	    TRISA, 4
    BCF	    TRISA, 5
    BCF	    TRISA, 6
    
    BSF	    TRISB, 0	
    BSF	    TRISB, 1
    BSF	    TRISB, 2
    CLRF    TRISC
    CLRF    PORTE

    BANKSEL PORTD
    BCF     PORTD, 0
    BCF	    PORTD, 1
    BCF	    PORTD, 2
    BCF     PORTD, 3
    BCF	    PORTD, 4
    BCF	    PORTD, 5
    BCF     PORTD, 6
    BCF	    PORTD, 7
    
    BANKSEL PORTA
    
     BSF    PORTA, 0
    BSF	    PORTA, 1
    BSF	    PORTA, 2
    BSF     PORTA, 3
    BSF     PORTA, 4
    BSF     PORTA, 5
    BCF	    PORTA, 6
    
   
  
    RETURN
    
CONFIG_TMR0:
 BANKSEL OPTION_REG		; cambiamos de banco
    BCF	    T0CS		; TMR0 como temporizador
    BCF	    PSA			; prescaler a TMR0
    BCF	    PS2
    BSF	    PS1
    BSF	    PS0			; PS<2:0> -> 110 prescaler 1 : 16
    RESET_TMR0 240		; Reiniciamos TMR0 para 2 ms
    RETURN  

CONFIG_TMR1:
    BANKSEL T1CON	    ; Cambiamos a banco 00
    BCF	    TMR1GE	    ; TMR1 siempre cuenta
    BSF	    T1CKPS1	    ; prescaler 1:8
    BSF	    T1CKPS0
    BCF	    T1OSCEN	    ; LP deshabilitado
    BCF	    TMR1CS	    ; Reloj interno
    BSF	    TMR1ON	    ; Prendemos TMR1
    
    RESET_TMR1 0xC2, 0xF7   ; Reiniciamos TMR1 para 1 s
    RETURN    
    
CONFIG_TMR2:
    BANKSEL PR2		    ; Cambiamos a banco 01
    MOVLW   245		    ; Valor para interrupciones cada 50ms
    MOVWF   PR2		    ; Cargamos litaral a PR2
    
    
    BANKSEL T2CON	    ; Cambiamos a banco 00
    BSF	    T2CKPS1	    ; prescaler 1:16
    BSF	    T2CKPS0
    
    BSF	    TOUTPS3	    ; postscaler 1:16
    BSF	    TOUTPS2
    BSF	    TOUTPS1
    BSF	    TOUTPS0
    
    BSF	    TMR2ON	    ; prendemos TMR2
    RETURN
    
CONFIG_RELOJ:
    BANKSEL OSCCON	    ; cambiamos a banco 01
    BSF	    OSCCON, 0	    ; SCS -> 1, Usamos reloj interno
    BCF	    OSCCON, 6
    BSF	    OSCCON, 5
    BSF	    OSCCON, 4	    ; IRCF<2:0> -> 011 500khz
    RETURN 
    
CONFIG_INT:
    BANKSEL IOCB		
    BSF	    IOCB0		
    BSF	    IOCB1
    BSF	    IOCB2
    BSF	    IOCB3
    
    
    BANKSEL PIE1
    BSF	    TMR1IE	    ;habilitar int del timer 1
    BSF	    TMR2IE	    ;habilitar int del timer 2
    
    BANKSEL INTCON
    BSF	    PEIE	    ;interrupciones de perifericos
    BSF	    T0IE		; Habilitamos interrupcion TMR0
    BCF	    T0IF	    ;limpio bamdera del tmr0
    BSF	    GIE		    ;interrupciones globales					
    BSF	    RBIE	    ;activo bandera del portb
    
    
    BCF	    TMR1IF	    ;limpio bandera
    BCF	    TMR2IF	    ;limpio bandera 
    
    BANKSEL PORTA
    BCF	    RBIF	    ;limio bandera del portb
    RETURN     
    
 ;-----------rutinas de interrupcion-----------------
 

 
   ORG 200h

   
    
    TABLA_7SEGNEG:
    CLRF    PCLATH		; Limpiamos registro PCLATH
    BSF	    PCLATH, 1		; Posicionamos el PC en dirección 02xxh
    ANDLW   0x0F		; no saltar más del tamaño de la tabla
    ADDWF   PCL
    RETLW   11000000B	;0
    RETLW   11111001B	;1
    RETLW   10100100B	;2
    RETLW   10110000B	;3
    RETLW   10011001B	;4
    RETLW   10010010B	;5
    RETLW   10000010B	;6
    RETLW   11111000B	;7
    RETLW   10000000B	;8
    RETLW   10010000B	;9  
    RETLW   01110111B	;A	; las letar no estan negadas
    RETLW   01111100B	;b
    RETLW   00111001B	;C
    RETLW   01011110B	;d
    RETLW   01111001B	;E
    RETLW   01110001B	;F        
    
    
    
    
 

    END