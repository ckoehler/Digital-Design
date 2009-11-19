;;;;;;;;;;;;;
; Vars
;;;;;;;;;;;;;

PWCLK	equ	$0840	;Clk
PWEN	equ	$0842	;Enable
PWSCAL0	equ	$0844	;Scale Clock
PWCNT0	equ	$0848	;Channel Counters
PWPER0	equ	$084C	;Period
PWDTY0	equ	$0850	;Duty Cycle
PWCTL	equ	$0854	;control

TIOS	equ	$0880	;In/Out
TCNT	equ	$0884	;CNT High
TSCR	equ	$0886	;Control
TMSK1	equ	$088C	;Enable flag
TFLG1	equ	$088E	;Flags
TC1	equ	$0892	;CNT Set

PORTH	equ	$0829
DDRH	equ	$082B

DelayC	equ	1420    ;1527
DelayD	equ	1253    ;1360
DelayE	equ	1212
DelayF	equ	1146
DelayG	equ	1020
DelayA	equ	909
DelayB	equ	810

	org	$2000
Note	rmb	2
Sample	rmb	2
Buffer	rmb	2

;;;;;;;;;;;
; Main
;;;;;;;;;;;

	org	$1000
Start:
	cli
	ldaa	#SinWave
	staa	Buffer
	jsr	InitTimer
	jsr	InitPWM
	jsr	SelectRow
Loop:	jsr	CheckCol
	bra	Loop

;;;;;;;;;;;
; Subs
;;;;;;;;;;;


InitTimer:	ldaa	#$02	;TC1 Timer
	staa	TIOS
	ldaa	#$80	;Enable Timer
	staa	TSCR
	rts
	
InitPWM:	movb	#$00,PWCLK
	ldaa	PWCTL
	oraa	#$08
	staa	PWCTL
	rts
	
PlayC:	ldd	#DelayC	;load delay time
	std	Note
	jsr	StartNote
	rts
PlayD:	ldd	#DelayD	;load delay time
	std	Note
	jsr	StartNote
	rts
PlayE:	ldd	#DelayE	;load delay time
	std	Note
	jsr	StartNote
	rts	

StartNote:	ldx	Buffer	;Set to begging of buffer
	ldaa	1,x+	;load sample
	staa	PWDTY0	;store sample to PWM Duty
	stx	Sample	;Store inc to sample	
	ldd	TCNT
	addd	Note
	std	TC1	;Set 1/20 C Period
	ldaa	#$A0
	staa	PWPER0	;Set period
		
	ldaa	#$02	;Enable Interuppt
	staa	TMSK1
	ldaa	#$01    	;Enable PWM
	staa	PWEN
	rts
	
StopNote:	pshd
	ldaa	#$00
	staa	TMSK1
	ldaa	#$00
	staa	PWEN
	puld
	rts
;Checks Rows	
SelectRow:	psha
	ldaa	#$10
	staa	DDRH
	staa	PORTH
SelectRowRTS:	pula
	rts
;Checks Cols
CheckCol:	psha
	pshx
	pshb
	ldx	#0	;Init to 0
	ldaa	PORTH	;load port
	anda	#$0F	;mask MSBs
	beq	CheckColRTS	;Exit if none set
	bita	#$01
	beq	Act1
	bita	#$02
	beq	Act2
	bita	#$04
	beq	Act3
	bita	#$08
	beq	Act4
	bra	CheckColRTS
	
Act1:	jsr	PlayC
A1_LOOP:	ldab	PORTH
	andb	#$01
	bne	A1_LOOP
	jsr	StopNote
	bra	CheckColRTS
Act2:	jsr	PlayD
A2_LOOP:	ldab	PORTH
	andb	#$02
	bne	A2_LOOP
	jsr	StopNote
	bra	CheckColRTS
Act3:	jsr	PlayE
A3_LOOP:	ldab	PORTH
	andb	#$04
	bne	A3_LOOP
	jsr	StopNote
	bra	CheckColRTS
	
Act4:	ldd	Buffer
	andd	#SinWave
	bne	Sine
	ldd	#TriWave
	bra	CheckCol1
Sine:	ldd	#SinWave

CheckCol1:	std	Buffer
CheckColRTS:	pulb
	pulx
	pula
	rts

;;;;;;;;;;;;
; ISRs
;;;;;;;;;;;;

ISR_Timer: 	pshd
	pshx
	ldd	TCNT	;Get Current value
	addd	Note	;Add delay
	std	TC1	;Store delay
	ldaa	#$02	;Reset Flag
	staa	TFLG1
	ldx	Sample	;Load Current Sample addr
	ldaa	1,x+	;Load sample value inc
	bne	ISR_Timer1	;if sample is zero restart buffer
	ldx	Buffer
	ldaa	1,x+
ISR_Timer1:	stx	Sample	;Store current sample addr
	staa	PWDTY0	;Set Duty Cycle
	movb	#$00,PWCNT0	;Reset PWM
	cli
	pulx
	puld
	rti
	
	org	$62c
	fdb	ISR_Timer
	
	org	$2010
	
SinWave:	fcb	128
	fcb	165
	fcb	200
	fcb	227
	fcb	246
	fcb	255
	fcb	252
	fcb	238
	fcb	214
	fcb	183
	fcb	147
	fcb	109
	fcb	73
	fcb	42
	fcb	18
	fcb	4
	fcb	1
	fcb	10
	fcb	29
	fcb	56
	fcb	91
	fcb 	0

TriWave:	fcb	128
	fcb	0