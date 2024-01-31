PROCESSOR    18F4620

#include <xc.inc>

; CONFIGURATION (DO NOT EDIT)
CONFIG OSC = HSPLL      ; Oscillator Selection bits (HS oscillator, PLL enabled (Clock Frequency = 4 x FOSC1))
CONFIG FCMEN = OFF      ; Fail-Safe Clock Monitor Enable bit (Fail-Safe Clock Monitor disabled)
CONFIG IESO = OFF       ; Internal/External Oscillator Switchover bit (Oscillator Switchover mode disabled)
; CONFIG2L
CONFIG PWRT = ON        ; Power-up Timer Enable bit (PWRT enabled)
CONFIG BOREN = OFF      ; Brown-out Reset Enable bits (Brown-out Reset disabled in hardware and software)
CONFIG BORV = 3         ; Brown Out Reset Voltage bits (Minimum setting)
; CONFIG2H
CONFIG WDT = OFF        ; Watchdog Timer Enable bit (WDT disabled (control is placed on the SWDTEN bit))
; CONFIG3H
CONFIG PBADEN = OFF     ; PORTB A/D Enable bit (PORTB<4:0> pins are configured as digital I/O on Reset)
CONFIG LPT1OSC = OFF    ; Low-Power Timer1 Oscillator Enable bit (Timer1 configured for higher power operation)
CONFIG MCLRE = ON       ; MCLR Pin Enable bit (MCLR pin enabled; RE3 input pin disabled)
; CONFIG4L
CONFIG LVP = OFF        ; Single-Supply ICSP Enable bit (Single-Supply ICSP disabled)
CONFIG XINST = OFF      ; Extended Instruction Set Enable bit (Instruction set extension and Indexed Addressing mode disabled (Legacy mode))

; GLOBAL SYMBOLS
; You need to add your variables here if you want to debug them.
GLOBAL var1
GLOBAL var2
GLOBAL var3
GLOBAL var4
GLOBAL var5
GLOBAL flag
    
; Define space for the variables in RAM
PSECT udata_acs
var1:
    DS 1 
var2:
    DS 1
var3:
    DS 1
var4:
    DS 1
var5:
    DS 1
flag:
    DS 1

PSECT resetVec,class=CODE,reloc=2
resetVec:
    goto       main

PSECT CODE
main:
  clrf TRISA
  setf TRISB
  clrf flag
  movlw 00000111B
  movwf LATA
  call busy_wait
  bcf LATA, 2
  clrf var3
  movlw 8
  movwf var4
  
main_loop:
  call check_buttons
  call metronome_update
  goto main_loop
  
busy_wait:
    movlw 26
    clrf var3
    clrf var2
    clrf var1
    outer_loop_start:
        loop_start:
            lo_start:
                incfsz var1
		goto lo_start
            incfsz var2
	    goto loop_start
	addwf var3
	bnov outer_loop_start
    return 
    
check_buttons:
    call rb0_task
    call rb1_task
    call rb2_task
    call rb3_task
    call rb4_task
    return
    
rb0_task:
    btfsc PORTB, 0
    goto set_rb0_flag
    is_rb0_pressed:
        btfsc flag, 0
	goto update_rb0_conf
        return
	
set_rb0_flag:
    bsf flag, 0
    return
    
update_rb0_conf:
    movff LATA, var5
    bcf flag, 0
    bcf LATA, 0
    bcf LATA, 1
    bsf LATA, 2
    con:
        btfsc PORTB, 0
        goto set_rb0_flag_2
        is_rb0_pressed_2:
            btfsc flag, 0
    	    goto update_rb0_conf_2
            goto con    
    return
    
set_rb0_flag_2:
    bsf flag, 0
    goto con
    
update_rb0_conf_2:
    bcf flag, 0
    movff var5, LATA
    return
    
    
rb1_task:
    btfsc PORTB, 1
    goto set_rb1_flag
    is_rb1_pressed:
        btfsc flag, 1
	goto update_rb1_conf
	return

set_rb1_flag:
    bsf flag, 1
    return
    
update_rb1_conf:
    bcf flag, 1
    btg flag, 6
    return
    
rb2_task:
    btfsc PORTB, 2
    goto set_rb2_flag
    is_rb2_pressed:
        btfsc flag, 2
	goto update_rb2_conf
	return

set_rb2_flag:
    bsf flag, 2
    return
    
update_rb2_conf:
    movlw 8
    movwf var4
    bcf flag, 2
    return
    
    
rb3_task:
    btfsc PORTB, 3
    goto set_rb3_flag
    is_rb3_pressed:
        btfsc flag, 3
	goto update_rb3_conf
	return

set_rb3_flag:
    bsf flag, 3
    return
    
update_rb3_conf:
    decf var4
    decf var4
    bcf flag, 3
    return
    
rb4_task:
    btfsc PORTB, 4
    goto set_rb4_flag
    is_rb4_pressed:
        btfsc flag, 4
	goto update_rb4_conf
	return

set_rb4_flag:
    bsf flag, 4
    return
    
update_rb4_conf:
    incf var4
    incf var4
    bcf flag, 4
    return
    
metronome_update:
    movlw 2
    btfsc flag, 6
    addlw 2
    addwf var1
    bc var1_overflown
    return
   
var1_overflown:
    movlw 4
    addwf var2
    bc var2_overflown
    return
    
var2_overflown:
    btg LATA, 0
    bcf LATA, 1
    incf var3
    movf var4, 0
    cpfslt var3
    bsf LATA, 1
    btfsc LATA, 1
    clrf var3
    return


end resetVec

  