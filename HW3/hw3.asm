***************
* VARs
***************
SPCR	equ	$1028	*SPI Control
SPSR	equ	$1029	*SPI Status
SPDR	equ	$102A	*SPI Data
DDRD	equ	$1009	*Register D

***************
* Main
***************

	org     	$2000

	jsr	SPI_INIT	*Init SPI System
Loop:	jsr	SS_EN	*Enables Slave Select
	ldab	#$FF	*Generic Request over SPI
	jsr	SPI_RW	*Writes then reads bite from SPI
	tba		*Transfers most sig to top register
	ldab	#$FF
	jsr	SPI_RW
	jsr	SS_EN	*Disables Slave Select

	lsld		*Formats A to contain entire int temp
	tab		*Transfers A -> B for least sig figures
	ldaa	#$00	*Loads 0 for most sig figures
	jsr	HEXtoDEC	*Creates decimal values from hex stored in D

	jsr	SPI_RW

	bra	Loop

**************
* SUBs
**************

*Init SPI
SPI_INIT:
	ldab	DDRD	*Load Current state of DDRD
	orab	#$38	*Turn on Slave select
	stab	DDRD	*store
	ldab	#$70	*Enable SPI
	stab	SPCR	
	rts

*Toggles *SS
SS_EN:  
	pshb
	ldab	DDRD	*Load Current State of DDRD
	eorb	#$20	*Toggle Slave Select
	stab	DDRD	*Store back
	pulb
	rts

*Returns {B} temp from sensor	     
SPI_RW:		
	psha
	stab	SPDR	*Store $FF into SPI Data
	ldaa	DDRD
	anda	#$20
SPI_RW1:	ldab	SPSR	*Reads SPI Status Register 
	andb	#$80	*Checks for status high on bit 7
	beq	SPI_RW1	*Checks again if not high
	ldab	SPDR	*Pulls data from SPI
SPI_RW_E:	pula
	rts

*Returns {B} temp in 4 bit most sig decimal in binary -> 0000 and 4 bit lest sig decimal in binary -> 0000	
HEXtoDEC:	
	pshx
	ldx	#$000A	*Load x with 10
	idiv		*Divide D/X
	xgdx		*Exchange remainder(D) with int(X)
	lsld		*Left shift D 4 times putting it to most sig
	lsld
	lsld
	lsld
	orab	0,x	*Add x to b which is the remainder as least sig
	pulx
	rts