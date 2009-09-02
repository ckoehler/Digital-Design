****************
* Vars
****************

SCICR2		=	$102D
SCSR			=	$102E
SCDR			=	$102F
BAUD			=	$102B

BUFFER_BEG		=	$0101		//Starting Point of Buffer
BUFFER_END		=	$0110		//End of buffer (n-1)
BUFFER_CP		=	$0100		//Current position of buffer (n)


**************
* Main
**************
			org	$0000

Init:			lds	#$01FF
			jsr 	SCI_INIT
			ldx 	#Name
			stx	BUFFER_CP
ENDLoop:		bra	ENDLoop

Name:			fcc	"David Ibach & Christoph Koehler"
			fcb	13,10,0

***************
* Subs
***************
;Init SCI
SCI_INIT:		
			psha
			ldaa	#$8C
			staa	SCICR2
			ldaa	#$03
			staa	BAUD
			pula
			rts

TX_NXT:
			pshx
			ldx	BUFFER_CP
			ldaa	1,x			;Do nothing to A after
			cpx	#BUFFER_END
			bne	TX_NXT_1
			ldx	#BUFFER_BEG
			stx	BUFFER_CP
TX_NXT_1:		cmpa 	#$00
			bne	TX_NXT_END
			jsr 	EN_TX
			bra	TX_NXT_END
TX_NXT_END:		staa	SCDR
			pulx
			rts

RX_NXT:
			pshx
			ldx	BUFFER_CP
			ldaa	SCDR
			staa	SCDR
			staa	1,x
			cpx	#BUFFER_END
			bne	RX_NXT_END
			ldx	#BUFFER_BEG
			stx	BUFFER_CP
			bra	RX_NXT_END
RX_NXT_END:		pulx
			rts
			
EN_TX:
			psha
			ldaa	SCICR2
			eora	#$80
			pula
			rts			

**************
* ISRs
**************

ISR_SCI:
			psha
			LDAA	SCSR
			ANDA	#$80
			cmpa	#$80
			bne	ISR_SCI_READ
			jsr	TX_NXT
			bra	ISR_SCI_END
ISR_SCI_READ:	ldaa	SCSR
			anda	#$20
			bne	ISR_SCI_END
			jsr	RX_NXT
			bra	ISR_SCI_END
ISR_SCI_END:	pula
			rti


			org	$FFFE
			dc.w	Init

			org	$FFE6
			dc.w	ISR_SCI



