; hex to decimal converter

decimal	        equ	$0000
hex		equ	$0001


	org $D000
;main
Init:
	clr decimal
	clr hex
	lds $01FF
Main:
	jsr Hex2Dec
	bra Main

; subroutines
Hex2Dec:
	ldx 	#$000A
	clra
	ldab 	hex
	idiv			; divide hex by 10 (0A)
	stab	decimal
	xgdx			; swap x and d because we can't move x directly to decimal
	lslb
	lslb
	lslb
	lslb			; move most significant byte over
	addb	decimal	        ; combine the bytes
	stab decimal
	rts

; interrupt vectors
	org $FFFE
	dc.w	Init