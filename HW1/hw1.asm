****************
* Vars
****************

SCICR2		=	$102D
SCSR			=	$102E
SCDR			=	$102F
BAUD			=	$102B

BUFFER_BEG		=	$0190		//Starting Point of Buffer
BUFFER_END		=	$01CC		//End of buffer Store 3C for 60


**************
* Main
**************
			org	$B600

Init:			lds	#$01FF
			jsr 	SCI_INIT	
			ldx 	#Name
			jsr	SCI_OUT_MSG
Loop:			ldx	#Prompt
			jsr	SCI_OUT_MSG
			ldx	#BUFFER_BEG
			jsr	SCI_IN_MSG
			bra	Loop

Name:			fcc	"David Ibach & Christoph Koehler"
			fcb	13,10,0

Prompt:		fcc	"Enter a message: "
			fcb	0



***************
* Subs
***************
;Init SCI
SCI_INIT:		
			psha
			ldaa	#$0C
			staa	SCICR2
			ldaa	#$30
			staa	BAUD
			pula
			rts


SCI_OUT_MSG:
			psha
SCI_OUT_MSG_1:	lda	0,x
			inx
			cmpa	#$00
			beq	SCI_OUT_MSG_END
			jsr	SCI_Char_OUT
			bra	SCI_OUT_MSG_1
SCI_OUT_MSG_END:	pula
			rts

SCI_Char_OUT:	
			pshb
SCI_Char_OUT_1:	ldab	SCSR
			andb	#$80
			cmpb	#$80
			bne	SCI_Char_OUT_1
			staa	SCDR
			pulb
			rts

SCI_IN_MSG:		
			psha
SCI_IN_MSG_1:	ldaa	SCSR
			anda	#$20
			beq	SCI_IN_MSG_1
			ldaa	SCDR
			cmpa	#$0D
			beq	SCI_IN_MSG_END
			cpx	#BUFFER_END
			beq	SCI_IN_MSG_1
			staa	0,x
			inx
			jsr	SCI_Char_OUT
			bra	SCI_IN_MSG_1
SCI_IN_MSG_END:	ldaa #$0D
			jsr SCI_Char_OUT
			pula
			rts

			org	$FFFE
			dc.w	Init



