;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; Reset memory locations ;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;
START_ADDRESS 	equ	$0000
END_ADDRESS 	equ 	$0100

	.org 	$D000
Main:
	LDS	#$01FF
	JSR Init_Memory
End:	BRA End



Init_Memory:
	LDX 	#START_ADDRESS
	LDAA	#00
Loop:	
	STAA	0,X
	INX
	CPX	#END_ADDRESS
	BNE Loop
Init_Memory_End:
	RTS

	org $FFFE
	dc.w	Main

