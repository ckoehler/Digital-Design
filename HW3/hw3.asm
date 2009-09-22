***************
*	VARs
***************
SPCR        equ     $1028
SPSR        equ     $1029
SPDR        equ     $102A
DDRD        equ     $1009

TEMP		equ		$0000	*Store current temp in $0000 for 0-49

***************
*	Main
***************
            
            org     $2000

			jsr		SPI_INIT
            
Loop:    	jsr     SS_EN
            ldab    #$FF
            jsr     SPI_RW
			TBA
			ldab	#$FF
			jsr		SPI_RW
            jsr     SS_EN
			lsla	
			TAB
			ldaa	#$00
			jsr		HEXtoDEC
            bra		Loop

**************
*	SUBs
**************

SPI_INIT:
            ldab	DDRD
			orab	#$38
			stab	DDRD
			ldab	#$70
			stab	SPCR
			rts


SS_EN:  
            pshb
            ldab	DDRD
			eorb	#$20
			stab	DDRD
            pulb	
            rts

            
SPI_RW:		
			stab	SPDR
SPI_RW1:	ldab	SPSR
			andb	#$80
			beq		SPI_RW1
			ldab	SPDR
			rts
			
HEXtoDEC:	
			pshx
			ldx		#$000A
			idiv	
			lsld
			lsld
			lsld
			lsld
			orab	0,x
			pulx
			rts
			
			
			
			