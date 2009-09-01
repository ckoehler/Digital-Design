; switch close to open detector

; vars and equ
DDRC 		equ $1007
PORTC		equ $1003
LastTime	equ $0000
switched	equ $0001	; set to 1 if switch triggered, 0 otherwise

	.org $D000

Init:
	lds #$01FF
	clr LastTime
	jsr init_ports
Loop:
	jsr switch_check
	bra Loop

; subs
init_ports:
	ldaa #$00
	staa DDRC
	
	rts

switch_check:
	ldaa PORTC
	anda #$08
	psha
	beq  switch_check_end
	ldaa LastTime
	anda #$08
	bne switch_check_end
	ldaa #$01
	staa switched
switch_check_end:
	pula
	staa LastTime
	rts
	
	.org $FFFE
	dc.w Init

