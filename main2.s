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
  
  
  ;---------------macros-----------
  
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
    
u_segundos: DS 1
d_segundos: DS 1
u_minutos: DS 1
d_minutos: DS 1
u_horas: DS 1
d_horas: DS 1
horas_24: DS 1
display1:  DS 1
display2:  DS 1
display3:  DS 1
display4:  DS 1
display5:  DS 1
display6:  DS 1
ESTADO: DS 1
EDITAR: DS 1

bandera: DS 1 
bandera_v1: DS 1
bandera_v2: DS 1
bandera_v3: DS 1
u_dias: DS 1
d_dias:	DS 1
u_mes:	DS 1
d_mes:	DS 1
mes:	DS 1
dias_limite: DS 1
    
    
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
 		
   BTFSC   RBIF	
   CALL    INT_PORTB
   
   BTFSC   T0IF
   CALL	   INT_TMR0
   
   BTFSC   TMR1IF
   CALL    INT_TMR1
    
   BTFSC   TMR2IF
   CALL    INT_TMR2

POP:
    SWAPF   STATUS_TEMP, W  
    MOVWF   STATUS		
    SWAPF   W_TEMP, F	    
    SWAPF   W_TEMP, W		
    RETFIE
    
    
;-----------subrutinas de interrupcion-----------
    
    
INT_PORTB:
 BTFSC	PORTB, 0
 CALL	CAMBIO_ESTADO
 BTFSC	PORTB, 1
 CALL	CAMBIO_ESTADO_EDIT
 BTFSC	PORTB, 2
 CALL	INCREMENTAR
 BTFSC	PORTB, 3
 CALL	DECREMENTAR
 BCF	RBIF	
 RETURN
 
 
 
 
CAMBIO_ESTADO:
    INCF    ESTADO, F
    MOVF    ESTADO, W
    SUBLW   3
    BTFSS   STATUS, 2
    RETURN
    CLRF    ESTADO
    RETURN
    
CAMBIO_ESTADO_EDIT:
    INCF    EDITAR, F  
    MOVF    EDITAR, W
    SUBLW   3
    BTFSS   STATUS, 2
    RETURN
    CLRF    EDITAR
    RETURN

INCREMENTAR:
    MOVF    ESTADO, W
    SUBLW   0
    BTFSC   STATUS, 2
    CALL    INCREMENTAR_RELOJ
    MOVF    ESTADO, W
    SUBLW   1
    BTFSC   STATUS, 2
    CALL    INCREMENTAR_FECHA
    MOVF    ESTADO, W
    SUBLW   2
    BTFSC   STATUS, 2
    CALL    INCREMENTAR_TIMER
    RETURN
 
DECREMENTAR:
    MOVF    ESTADO, W
    SUBLW   0
    BTFSC   STATUS, 2
    CALL    DECREMENTAR_RELOJ
    MOVF    ESTADO, W
    SUBLW   1
    BTFSC   STATUS, 2
    CALL    DECREMENTAR_FECHA
    MOVF    ESTADO, W
    SUBLW   2
    BTFSC   STATUS, 2
    CALL    DECREMENTAR_TIMER
    RETURN   
    
  INCREMENTAR_RELOJ:
    MOVF    EDITAR, W
    SUBLW   1
    BTFSC   STATUS, 2
    CALL    INCREMENTAR_HORAS
    MOVF    EDITAR, W
    SUBLW   2
    BTFSC   STATUS, 2
    CALL    INCREMENTAR_MINUTOS
    RETURN
    
  INCREMENTAR_FECHA:
    
    RETURN
    
  INCREMENTAR_TIMER:
    
    RETURN
    
  DECREMENTAR_RELOJ:
    MOVF    EDITAR, W
    SUBLW   1
    BTFSC   STATUS, 2
    CALL    DECREMENTAR_HORAS
    MOVF    EDITAR, W
    SUBLW   2
    BTFSC   STATUS, 2
    CALL    DECREMENTAR_MINUTOS
    RETURN
    
    RETURN
    
  DECREMENTAR_FECHA:
    
    RETURN
    
  DECREMENTAR_TIMER:
    
    RETURN
    
    
  ;------INCREMENTOS--------------
  
  INCREMENTAR_HORAS:
    
    INCF    u_horas
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
    CLRF    horas_24
    RETURN
    
 INCREMENTAR_MINUTOS:
    
    INCF    u_minutos
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
    CLRF    d_minutos
    RETURN 
    
    
    
    DECREMENTAR_HORAS:
    DECF    u_horas
    MOVF    u_horas ,W
    SUBLW   255
    BTFSS   STATUS, 0
    RETURN
    MOVLW   9
    MOVWF   u_horas
    DECF    d_horas
    MOVF    d_horas ,W
    SUBLW   255
    BTFSS   STATUS, 0
    RETURN
    MOVLW   9
    MOVWF   d_horas
    
 
    
    
    
    DECREMENTAR_MINUTOS:
    RETURN
    
    INT_TMR0:
    RESET_TMR0 240		 ;regreso  el valor para no iniciar de 0 a 240    
    CALL	MOSTRAR_VALOR1
    CALL	MOSTRAR_VALOR2
    CALL	MOSTRAR_VALOR3
    RETURN
    
    
    INT_TMR1:
    
  RESET_TMR1 0xC2, 0xF7   ; Reiniciamos TMR1 para 1 s 49911
    
  INCF	    u_segundos, F
  RETURN  
  
  INT_TMR2:
    
    
     BCF	    TMR2IF
     		                 ;
     BTFSC	    bandera, 0	    ; verificamos la vandera 
     goto	    apagar
     goto	    encender
    
    encender:
    BSF		    PORTD, 5
    BSF		    bandera,0
    RETURN
    
    apagar: 
    BCF		    PORTD, 5
    BCF		    bandera,0
    RETURN

    
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
 
 
 FECHA:
   
    MOVF    mes, W
    SUBLW   0
    BTFSC   STATUS, 2
    GOTO    ENERO	        
    MOVF    mes, W
    SUBLW   1
    BTFSC   STATUS, 2
    GOTO    FEBRERO
    MOVF    mes, W
    SUBLW   2
    BTFSC   STATUS, 2
    GOTO   MARZO
    MOVF    mes, W
    SUBLW   3
    BTFSC   STATUS, 2
    GOTO   ABRIL
    MOVF    mes, W
    SUBLW   4
    BTFSC   STATUS, 2
    GOTO   MAYO
    MOVF    mes, W
    SUBLW   5
    BTFSC   STATUS, 2
    GOTO   JUNIO
    MOVF    mes, W
    SUBLW   6
    BTFSC   STATUS, 2
    GOTO   JULIO
    MOVF    mes, W
    SUBLW   7
    BTFSC   STATUS, 2
    GOTO   AGOSTO
    MOVF    mes, W
    SUBLW   8
    BTFSC   STATUS, 2
    GOTO   SEPTIEMBRE
    MOVF    mes, W
    SUBLW   9
    BTFSC   STATUS, 2
    GOTO   OCTUBRE
    MOVF    mes, W
    SUBLW   10
    BTFSC   STATUS, 2
    GOTO   NOVIEMBRE
    MOVF    mes, W
    SUBLW   11
    BTFSC   STATUS, 2
    GOTO   DICIEMBRE
    RETURN    
    
    
    ENERO:
 MOVF	    u_dias, W	    ;movemos el incremento a w
 SUBLW	    10			    ; le restamos 10
 BTFSS	    STATUS, 2		    ;verificamos si la resta es 0
 RETURN
 CLRF	    u_dias
 INCF	    d_dias		    ;cuando sea 0 limpio mi variable    
 MOVF	    dias_limite, W
 SUBLW	   31
 BTFSS	    STATUS, 2
 RETURN
 CLRF	    d_dias
 CLRF	    u_dias
 CLRF	    dias_limite
 INCF	    u_mes
 INCF	    mes
  
    RETURN
    
    FEBRERO:
 MOVF	    u_dias, W	    ;movemos el incremento a w
 SUBLW	    10			    ; le restamos 10
 BTFSS	    STATUS, 2		    ;verificamos si la resta es 0
 RETURN
 CLRF	    u_dias
 INCF	    d_dias		    ;cuando sea 0 limpio mi variable    
 MOVF	    dias_limite, W
 SUBLW	   28
 BTFSS	    STATUS, 2
 RETURN
 CLRF	    d_dias
 CLRF	    u_dias
 CLRF	    dias_limite
 INCF	    u_mes
 INCF	    mes
    RETURN
    
    MARZO:
    
MOVF	    u_dias, W	    ;movemos el incremento a w
 SUBLW	    10			    ; le restamos 10
 BTFSS	    STATUS, 2		    ;verificamos si la resta es 0
 RETURN
 CLRF	    u_dias
 INCF	    d_dias		    ;cuando sea 0 limpio mi variable    
 MOVF	    dias_limite, W
 SUBLW	   31
 BTFSS	    STATUS, 2
 RETURN
 CLRF	    d_dias
 CLRF	    u_dias
 CLRF	    dias_limite
 INCF	    u_mes
 INCF	    mes    
    
    
    RETURN
    
    ABRIL:
    
 MOVF	    u_dias, W	    ;movemos el incremento a w
 SUBLW	    10			    ; le restamos 10
 BTFSS	    STATUS, 2		    ;verificamos si la resta es 0
 RETURN
 CLRF	    u_dias
 INCF	    d_dias		    ;cuando sea 0 limpio mi variable    
 MOVF	    dias_limite, W
 SUBLW	   30
 BTFSS	    STATUS, 2
 RETURN
 CLRF	    d_dias
 CLRF	    u_dias
 CLRF	    dias_limite
 INCF	    u_mes
 INCF	    mes   
    
    
    RETURN
    
    MAYO:
    
 MOVF	    u_dias, W	    ;movemos el incremento a w
 SUBLW	    10			    ; le restamos 10
 BTFSS	    STATUS, 2		    ;verificamos si la resta es 0
 RETURN
 CLRF	    u_dias
 INCF	    d_dias		    ;cuando sea 0 limpio mi variable    
 MOVF	    dias_limite, W
 SUBLW	   31
 BTFSS	    STATUS, 2
 RETURN
 CLRF	    d_dias
 CLRF	    u_dias
 CLRF	    dias_limite
 INCF	    u_mes
 INCF	    mes   
    
    RETURN
    
    JUNIO:
    
 MOVF	    u_dias, W	    ;movemos el incremento a w
 SUBLW	    10			    ; le restamos 10
 BTFSS	    STATUS, 2		    ;verificamos si la resta es 0
 RETURN
 CLRF	    u_dias
 INCF	    d_dias		    ;cuando sea 0 limpio mi variable    
 MOVF	    dias_limite, W
 SUBLW	   30
 BTFSS	    STATUS, 2
 RETURN
 CLRF	    d_dias
 CLRF	    u_dias
 CLRF	    dias_limite
 INCF	    u_mes
 INCF	    mes   
    
    RETURN
    
    JULIO:
    
 MOVF	    u_dias, W	    ;movemos el incremento a w
 SUBLW	    10			    ; le restamos 10
 BTFSS	    STATUS, 2		    ;verificamos si la resta es 0
 RETURN
 CLRF	    u_dias
 INCF	    d_dias		    ;cuando sea 0 limpio mi variable    
 MOVF	    dias_limite, W
 SUBLW	   31
 BTFSS	    STATUS, 2
 RETURN
 CLRF	    d_dias
 CLRF	    u_dias
 CLRF	    dias_limite
 INCF	    u_mes
 INCF	    mes   
    
    
    RETURN
    
    AGOSTO:
    
 MOVF	    u_dias, W	    ;movemos el incremento a w
 SUBLW	    10			    ; le restamos 10
 BTFSS	    STATUS, 2		    ;verificamos si la resta es 0
 RETURN
 CLRF	    u_dias
 INCF	    d_dias		    ;cuando sea 0 limpio mi variable    
 MOVF	    dias_limite, W
 SUBLW	   31
 BTFSS	    STATUS, 2
 RETURN
 CLRF	    d_dias
 CLRF	    u_dias
 CLRF	    dias_limite
 INCF	    u_mes
 INCF	    mes   
    
    RETURN
    
    SEPTIEMBRE:
    
 MOVF	    u_dias, W	    ;movemos el incremento a w
 SUBLW	    10			    ; le restamos 10
 BTFSS	    STATUS, 2		    ;verificamos si la resta es 0
 RETURN
 CLRF	    u_dias
 INCF	    d_dias		    ;cuando sea 0 limpio mi variable    
 MOVF	    dias_limite, W
 SUBLW	   29
 BTFSS	    STATUS, 2
 RETURN
 CLRF	    d_dias
 CLRF	    u_dias
 CLRF	    dias_limite
 INCF	    u_mes
 INCF	    mes
 
 MOVF	    u_mes, W
 SUBLW	    9
 BTFSS	    STATUS, 2
 CLRF	    u_mes
 INCF	    d_mes
 RETURN
    
    RETURN
    
    OCTUBRE:
    
 MOVF	    u_dias, W	    ;movemos el incremento a w
 SUBLW	    10			    ; le restamos 10
 BTFSS	    STATUS, 2		    ;verificamos si la resta es 0
 RETURN
 CLRF	    u_dias
 INCF	    d_dias		    ;cuando sea 0 limpio mi variable    
 MOVF	    dias_limite, W
 SUBLW	   31
 BTFSS	    STATUS, 2
 RETURN
 CLRF	    d_dias
 CLRF	    u_dias
 CLRF	    dias_limite
 INCF	    u_mes
 INCF	    d_mes
 INCF	    mes
     
    RETURN
    
    NOVIEMBRE:
 MOVF	    u_dias, W	    ;movemos el incremento a w
 SUBLW	    10			    ; le restamos 10
 BTFSS	    STATUS, 2		    ;verificamos si la resta es 0
 RETURN
 CLRF	    u_dias
 INCF	    d_dias		    ;cuando sea 0 limpio mi variable    
 MOVF	    dias_limite, W
 SUBLW	   30
 BTFSS	    STATUS, 2
 RETURN
 CLRF	    d_dias
 CLRF	    u_dias
 CLRF	    dias_limite
 INCF	    u_mes
 INCF	    d_mes
 INCF	    mes
    
    RETURN
    
    DICIEMBRE:
   
 MOVF	    u_dias, W	    ;movemos el incremento a w
 SUBLW	    10			    ; le restamos 10
 BTFSS	    STATUS, 2		    ;verificamos si la resta es 0
 RETURN
 CLRF	    u_dias
 INCF	    d_dias		    ;cuando sea 0 limpio mi variable    
 MOVF	    dias_limite, W
 SUBLW	   31
 BTFSS	    STATUS, 2
 RETURN
 CLRF	    d_dias
 CLRF	    u_dias
 CLRF	    dias_limite
 INCF	    u_mes
 INCF	    d_mes
 INCF	    mes   
 
 MOVF	    mes, W
 SUBLW	    12
 BTFSS	    STATUS, 2
 RETURN
 CLRF	    mes
 CLRF	    u_mes
 CLRF	    d_mes  
 RETURN
 
    
 RESET_24H:
    
    MOVF    horas_24, W
    SUBLW   24
    BTFSS   STATUS, 2
    RETURN
    CLRF    horas_24
    CLRF    d_horas
    CLRF    u_horas
    INCF    u_dias
    INCF    dias_limite
    RETURN
    
    
 SET_DISPLAYS:
    MOVF    ESTADO, W
    SUBLW   0
    BTFSC   STATUS, 2
    CALL    MOSTRAR_RELOJ	        
    MOVF    ESTADO, W
    SUBLW   1
    BTFSC   STATUS, 2
    CALL    MOSTRAR_FECHA
    MOVF    ESTADO, W
    SUBLW   2
    BTFSC   STATUS, 2
    CALL   MOSTRAR_TIMER
    RETURN   
    
    MOSTRAR_FECHA:
    
   /* MOVF    u_segundos, W		; Movemos unidad  a W
    CALL    TABLA_7SEGNEG		; Buscamos valor a cargar en PORTC
    MOVWF   display1		; Guardamos en display
    
    MOVF    d_segundos, W		; Movemos decenaa W
    CALL    TABLA_7SEGNEG		; Buscamos valor a cargar en PORTC
    MOVWF   display2		; Guardamos en display+1
    
    MOVF    u_minutos, W		; Movemos unidad  a W
    CALL    TABLA_7SEGNEG		; Buscamos valor a cargar en PORTC
    MOVWF   display3		; Guardamos en display
    
    MOVF    d_minutos, W		; Movemos decenaa W
    CALL    TABLA_7SEGNEG		; Buscamos valor a cargar en PORTC
    MOVWF   display4		; Guardamos en display+1
    
    MOVF    u_horas, W		; Movemos unidad  a W
    CALL    TABLA_7SEGNEG		; Buscamos valor a cargar en PORTC
    MOVWF   display5		; Guardamos en display
    
    MOVF    d_horas, W		; Movemos decenaa W
    CALL    TABLA_7SEGNEG		; Buscamos valor a cargar en PORTC
    MOVWF   display6		; Guardamos en display+1*/
    
    RETURN    
    
    MOSTRAR_RELOJ:
    
     MOVF    u_mes, W		; Movemos unidad  a W
    CALL    TABLA_7SEG2		; Buscamos valor a cargar en PORTC
    MOVWF   display1		; Guardamos en display
    
    MOVF    d_mes, W		; Movemos decenaa W
    CALL    TABLA_7SEGNEG		; Buscamos valor a cargar en PORTC
    MOVWF   display2		; Guardamos en display+1
    
    MOVLW   00111111B		; Buscamos valor a cargar en PORTC
    MOVWF   display3		; Guardamos en display
    
    MOVLW   00111111B		; Buscamos valor a cargar en PORTC
    MOVWF   display4		; Guardamos en display+1
    
    MOVF    u_dias, W		; Movemos unidad  a W
    CALL    TABLA_7SEG2		; Buscamos valor a cargar en PORTC
    MOVWF   display5		; Guardamos en display
    
    MOVF    d_dias, W		; Movemos decenaa W
    CALL    TABLA_7SEGNEG		; Buscamos valor a cargar en PORTC
    MOVWF   display6		; Guardamos en display+1
    
    
    
    RETURN
    
    MOSTRAR_TIMER:
    RETURN
    
    MOSTRAR_VALOR1:
    
    BSF	    PORTA, 2
    BSF	    PORTA, 5
    BTFSC   bandera_v1,0
    GOTO    DISPLAY_4
    
    DISPLAY_1:
    MOVF    display1, W
    MOVWF   PORTC
    BCF	    PORTA, 0
    BSF	    bandera_v1,0
    RETURN
    
    DISPLAY_4:
    MOVF    display4, W
    MOVWF   PORTC
    BCF	    PORTA, 3
    BCF	    bandera_v1,0
    RETURN
    
    
    MOSTRAR_VALOR2:
    
    BSF	    PORTA, 0
    BSF	    PORTA, 3
    BTFSC   bandera_v2,0
    GOTO    DISPLAY_5
    
    DISPLAY_2:
    MOVF    display2, W
    MOVWF   PORTC
    BCF	    PORTA, 1
    BSF	    bandera_v2,0
    RETURN
    
    DISPLAY_5:
    MOVF    display5, W
    MOVWF   PORTC
    BCF	    PORTA, 4
    BCF	    bandera_v2,0
    RETURN

    MOSTRAR_VALOR3:

    BSF	    PORTA, 1
    BSF	    PORTA, 4
    BTFSC   bandera_v3,0
    GOTO    DISPLAY_6
    
    DISPLAY_3:
    MOVF    display3, W
    MOVWF   PORTC
    BCF	    PORTA, 2
    BSF	    bandera_v3,0
    RETURN
    
    DISPLAY_6:
    MOVF    display6, W
    MOVWF   PORTC
    BCF	    PORTA, 5
    BCF	    bandera_v3,0
    RETURN
    
 MOSTRAR_ESTADO:
    
    MOVF    ESTADO, W
    SUBLW   0
    BTFSC   STATUS, 2
    GOTO    ENCENDER_LED1	        
    MOVF    ESTADO, W
    SUBLW   1
    BTFSC   STATUS, 2
    GOTO    ENCENDER_LED2
    MOVF    ESTADO, W
    SUBLW   2
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
    SUBLW   0
    BTFSC   STATUS, 2
    GOTO    APAGAR_LEDS	        
    MOVF    EDITAR, W
    SUBLW   1
    BTFSC   STATUS, 2
    GOTO    ENCENDER_LED5
    MOVF    EDITAR, W
    SUBLW   2
    BTFSC   STATUS, 2
    GOTO   ENCENDER_LED6
    RETURN  
    
     APAGAR_LEDS: 
    BCF	    PORTD, 3
    BCF	    PORTD, 4
    RETURN
    
    ENCENDER_LED5: 
    BSF	    PORTD, 3
    BCF	    PORTD, 4
   
    RETURN
    
    ENCENDER_LED6:
    BCF	    PORTD, 3
    BSF	    PORTD, 4
    
    RETURN
    
    
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
    
CLRF	ESTADO
CLRF	EDITAR
CLRF	display1
CLRF	bandera
CLRF	bandera_v1
CLRF	bandera_v2
CLRF	bandera_v3
CLRF	u_dias 
CLRF    d_dias
CLRF	d_dias
CLRF	u_mes
CLRF	d_mes
CLRF	mes
CLRF	dias_limite
    
LOOP:
   CALL	    MOSTRAR_ESTADO
   CALL	    MOSTRAR_EDITAR
   CALL	    RELOJ  
   CALL	    RESET_24H
   CALL	    FECHA
   CALL	    SET_DISPLAYS
    
    GOTO    LOOP
 
    
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
    ;BCF	    TRISD, 6
    
    BSF	    TRISB, 0	
    BSF	    TRISB, 1
    BSF	    TRISB, 2
    BSF	    TRISB, 3
    CLRF    TRISC
    CLRF    TRISA
    
    
    
  

    BANKSEL PORTD
    BCF     PORTD, 0
    BCF	    PORTD, 1
    BCF	    PORTD, 2
    BCF     PORTD, 3
    BCF	    PORTD, 4
    BCF	    PORTD, 5
   ; BCF	    PORTD, 6
   
    BSF	    PORTA, 0
    BSF	    PORTA, 1
    BSF	    PORTA, 2
    BSF	    PORTA, 3
    BSF	    PORTA, 4
    BSF	    PORTA, 5
    
    CLRF    PORTC
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
    BSF	    GIE		    ;interrupciones globales
    BSF	    T0IE
    BCF	    T0IF
   ;BSF	    RBIE	    ;activo bandera del portb
    
    
    BCF	    TMR1IF	    ;limpio bandera
    BCF	    TMR2IF	    ;limpio bandera 
    
    BANKSEL PORTA
    BCF	    RBIF	    ;limio bandera del portb
    RETURN   
    
    
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
    
    
    
    TABLA_7SEG2:
    CLRF    PCLATH		; Limpiamos registro PCLATH
    BSF	    PCLATH, 1		; Posicionamos el PC en dirección 02xxh
    ANDLW   0x0F		; no saltar más del tamaño de la tabla
    ADDWF   PCL
    ;RETLW   11000000B	;0
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