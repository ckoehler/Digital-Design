; Christoph Koehler
; Project 3
; 
; Counter with LCD display and LED indicators for high/low status

; vars and equ
DDRC 		equ $1007	; data direction register for PORT C
PORTA		equ $1000	; counter/switch input on bit 0, mode toggle switch on bit 1
PORTB		equ $1004	; output for LCD. bits 0-7
PORTC		equ $1003	; output for LEDs, bit 0 green and bit 1 red
TCTL2		equ $1021	; timer control register 2, for input capture interrupt
TMASK1	equ $1022	; to enable IC3interrupt
TFLG1		equ $1023	; timer flag register
lastTime	equ $0000
switched	equ $0001	; set to 1 if switch triggered, 0 otherwise
hex		equ $0002
decimal	equ $0003
counter	equ $0004
mode		equ $0005
switched_from_isr equ $0006

	.org $D000
Init:
	lds #$01FF		; set stack pointer
	jsr init_ports	; init ports and variables
Loop:
	jsr sanity_check		; makes sure the counter is between 0 and 50
	jsr check_mode		; see if we're counting up or down. 0 = up, 1 = down
	jsr trickle_switched	; set "switched" based on the "switched_from_isr" variable. See subroutine for more info.
	jsr check_leds		; check leds and set if count is 0 or 50
	jsr print_counter		; display the counter on the LCDs
	jsr change_counter	; decrement or increment the counter
	bra Loop			; repeat

; subs
init_ports:
	; clear a bunch of vars
	clr lastTime
	clr switched	
	clr hex
	clr decimal
	clr counter
	clr mode
	clr switched_from_isr

	; set PORT C for output
	ldaa #$3
	staa DDRC

	; configur input capture 1 for trigger on falling edge
	ldaa #$2
	staa TCTL2

	; enable interrupt for IC1
	ldaa #$1
	staa TMASK1

	; enable interrupts
	cli	

	rts

; instead of setting "switched" directly from the ISR, we set a dummy var
; and trickle the change down to "switched" here.
; The reason for that is the counter not working correctly at times when
; the interrupt happened somewhere in between and didn't register.
; This way we set it before we go through all the checks, not anywhere
; in between.
trickle_switched:
	ldaa switched_from_isr
	
	; only set switched if switched_from_isr is 1
	beq trickle_switched_end
	staa switched
	clr switched_from_isr
trickle_switched_end:
	rts

; make sure the counter is between 0 and 50 at all times
sanity_check:
	ldaa counter
	
	; check if counter is greater than 50
	cmpa #50
	bgt reset_counter
	cmpa #0
	blt reset_counter
	rts

;resets counter to 0
reset_counter:
	ldaa #0
	staa counter
	rts

; checks which mode we are in, inc or dec counter
check_mode:
	ldaa PORTA
	anda #$02	; get bit 1 only
	staa mode	
	clr switched	; reset switched. prevents counter from changing if 
				; we just toggle the mode switch 
	rts

; increments or decrements the counter depending on our mode
change_counter:
	ldaa mode
	; increment if mode == 0, decrement if mode == 1 - corresponds to mode switch
	beq inc_counter
	jsr dec_counter
	rts

inc_counter:
	; get switched...
	ldaa switched

	; ...if we aren't, end
	beq inc_counter_end

	; ...else, proceed
	ldab counter
	subb #50		; subtract decimal 50, which will result in 0 if counter is 50

	; if we get 0 in B, we are at the max of 50 and end here
	beq inc_counter_end

	; ... else we increment the counter
	ldaa counter
	inca
	staa counter
	clr switched
inc_counter_end:
	rts

; same as increment counter, except we decrement
dec_counter:
	ldaa switched
	beq inc_counter_end
	ldaa counter
	beq dec_counter_end
	deca
	staa counter
	clr switched
dec_counter_end:
	rts

; determine if we need to light up any of the LEDs	
check_leds:

	; get counter, subtract 50 to see if we're at 50. If we are, Z flag will be set
	; and we activate the green led 
	ldaa counter
	suba #50
	beq activate_green_led

	; load counter again and check for Z flag. If it's set, counter == 0 and we 
	; need to activate the red led
	ldaa counter
	beq activate_red_led

	; otherwise reset both LEDs
	ldaa #$00
	staa PORTC
	rts

activate_green_led:
	ldaa #$01
	staa PORTC
	rts

activate_red_led:
	ldaa #$02
	staa PORTC
	rts

; print the counter to the LCDs
print_counter:
	; get counter and store it in hex, since it's a hex number
	ldaa counter
	staa hex
	
	; then convert it. we will get the result in decimal
	jsr hex2dec

	; take decimal and output to the LCDs on PORT B
	ldaa decimal
	staa PORTB
	rts


; convert number in hex to decimal
hex2dec:
	; load 10 into X; that's what we divide by
	ldx 	#$000A
	
	; load hex into least significant position of D, i.e. B. Most significant,
	; i.e. A, is set to 0.
	clra
	ldab 	hex
	idiv			; divide hex by 10 (0A)
	stab	decimal
	xgdx			; swap x and d because we can't move x directly to decimal
	lslb
	lslb
	lslb
	lslb			; move most significant byte over
	addb	decimal	; combine the bytes
	stab 	decimal	
	rts

; ISRs
; someone flipped the switch, so set it to switched
flip_switch:
	; indicate that we are switched
	ldaa #$01
	staa switched_from_isr

	; clear TFLG1, yes, by writing a 1 to it.
	ldaa #$01
	staa TFLG1

	rti

	.org 	$FFEA
	dc.w	flip_switch

	.org $FFFE
	dc.w Init


