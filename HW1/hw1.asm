****************
* Vars
****************

SCICR2		=	$102D
SCSR			=	$102E
SCDR			=	$102F
BAUD			=	$102B

BUFFER_BEG		=	$0190		//Starting Point of Buffer
BUFFER_END		=	$01CC		//End of buffer Store 3C for 60
STORE			=	$01CE


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
			ldx	#Answer
			jsr	SCI_OUT_MSG
			ldx	#BUFFER_BEG
			jsr	SCI_OUT_MSG
			ldx	#CR
			jsr	SCI_OUT_MSG
			bra	Loop

Name:			fcc	"David Ibach & Christoph Koehler"
			fcb	13,10,0

Prompt:		fcc	"Enter a message: "
			fcb	0

Answer:		fcc	"	After ROT13: "
			fcb	0

CR:			fcb	13,10,0



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
			jsr	SCI_Char_OUT
			jsr	ROT13_CYPHER
			staa	0,x
			inx	
			ldaa	#$00
			staa	0,x
			bra	SCI_IN_MSG_1
SCI_IN_MSG_END:	ldaa	#$0D
			jsr	SCI_Char_OUT
			pula
			rts

ROT13_CYPHER:	pshb
			TAB
			andb	#$40
			cmpb	#$40
			bne	ROT13_CYPHER_END
			TAB
			andb	#$5C
			cmpb	#$5C
			beq	ROT13_CYPHER_END
			TAB	
			andb	#$4F
			cmpb	#$40
			beq	ROT13_CYPHER_END
			TAB
			andb	#$5B
			cmpb	#$5B
			beq	ROT13_CYPHER_END
			TAB
			andb	#$20
			beq	ROT13_CYPHER_UP
			bra	ROT13_CYPHER_LOW
ROT13_CYPHER_UP:	TAB	
			adda	#13
			addb	#13
			subb	#$5B
			stab	STORE
			comb	
			andb	#$80
			cmpb	#$80
			bne	ROT13_CYPHER_END
			ldaa	#'A'
			adda	STORE	
			bra	ROT13_CYPHER_END
ROT13_CYPHER_LOW:	TAB	
			adda	#13
			addb	#13
			subb	#$7B
			stab	STORE
			comb	
			andb	#$80
			cmpb	#$80
			bne	ROT13_CYPHER_END
			ldaa	#'a'
			adda	STORE	
			bra	ROT13_CYPHER_END
ROT13_CYPHER_END:	pulb
			rts

			

			org	$FFFE
			dc.w	Init



