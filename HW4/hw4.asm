* =============
* = Variables =
* =============
ADCTL	equ	$1030
ADR1	equ	$1031
OPTION	equ	$1039
* ========
* = Main =
* ========
                  org               $E000             * $E000 w/o Buffalo, $2000 with.

Init:	lds               #$01FF	* initiate stack pointer
	ldaa	OPTION	* enable A/D subsystem
	oraa	#$80
	staa	OPTION
Main:	jmp	Mode1	* go to voltmeter by default

Mode1:


	bra	Mode1
Mode2:

	bra	Mode2
* ========
* = Subs =
* ========

* read from A/D converter and store in {B}
Read_AD:	pusha
	ldaa	#$00	* prime A/D
	staa	ADCTL
Read_AD1:	ldaa	ADCTL	* read status bit
	anda	#$80
	beq	Read_AD1	* keep checking
	ldab	ADR1	* we should have a result now
	pula
	rts
	
* ===========
* = Vectors =
* ===========
	org               $FFFE
	fdb               Init