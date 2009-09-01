; Hello World for the CRT

; equ
tx_byte	equ	$0000
SCCR2		equ	$102D
BAUD		equ	$102B
SCSR		equ	$102E
SCDR		equ	$102F

; main
	.org $D000
init:
	lds #$01FF
	cli
	jsr init_sci
main:
	ldaa #'H'
	staa tx_byte
	jsr check_tx_byte
	ldaa #'e'
	staa tx_byte
	jsr check_tx_byte
	ldaa #'l'
	staa tx_byte
	jsr check_tx_byte
	ldaa #'l'
	staa tx_byte
	jsr check_tx_byte
	ldaa #'o'
	staa tx_byte
	jsr check_tx_byte
	ldaa #'!'
	staa tx_byte
	jsr check_tx_byte
endloop: 	bra endloop

;isr's
isr_sci:
	ldaa SCSR
	ldaa tx_byte
	staa SCDR
	clr tx_byte
	rti

;subs
check_tx_byte:
	ldaa	tx_byte
	bne	check_tx_byte
	rts

init_sci:
	ldaa    #$88
	staa    SCCR2	; turn on tx and tx interrupts
	clr 	BAUD	; choose 125k baud
	rts

	.org	$FFD6
	dc.w	isr_sci

	.org $FFFE
	dc.w	init

