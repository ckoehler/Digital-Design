;;;;;;;;;;;
; interrupt test
;;;;;;;

; variables and equates
PORTC equ $1003
DDRC	equ $1007
TMSK2	equ $1024
TCNT	equ $100E
TFLG2 equ $1025

	.org $D000
; main
Init: 
	LDS #$01FF
	JSR init_ports
	JSR init_interrupts
Main:
	BRA Main


;subroutines
init_ports:
	; set 3rd bit in data direction register for port c to output
	LDAA #$08
	STAA DDRC
	; reset bit 3 to 0 => LED off
	LDAA #$00
	STAA PORTC
	RTS

init_interrupts:
	LDAA #$80 ; enable timer overflow interrupt
	STAA TMSK2
	CLI	; clear the global interrupt mask
	RTS

; Interrupt Service Routines
ISR_TimerOverflow:
	LDAA PORTC
	EORA #$08
	STAA PORTC
	LDAA #$80
	STAA TFLG2
	RTI

	
; interrupt vectors
	.org $FFDE
	dc.w ISR_TimerOverflow


	.org $FFFE
	dc.w Init

