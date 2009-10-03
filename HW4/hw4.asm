* =============
* = Variables =
* =============
ADCTL             equ               $1030
ADR2              equ               $1032
OPTION            equ               $1039
SCCR2             equ               $102D
SCSR              equ               $102E
SCDR              equ               $102F
BAUD              equ               $102B
R_H               equ               $5

Dig5              equ               $0000
Dot               equ               $0001
Dig4              equ               $0002
Dig3              equ               $0003
Dig2              equ               $0004
Dig1              equ               $0005
Space             equ               $0006
Unit              equ               $0007
CR                equ               $0008
LF                equ               $0009
Finish            equ               $000A

ADResult          equ               $000B
* reference Resistor / 4 = 250 ohms
Rref              equ               $FA
* ========
* = Main =
* ========
                  org               $B600             * $E000 w/o Buffalo, $2000 with.

Init:             lds               #$01FF            * initiate stack pointer
                  jsr               SCI_INIT
                  ldaa              OPTION            * enable A/D subsystem
                  oraa              #$80
                  staa              OPTION
                  ldaa              #$2E
                  staa              Dot
                  ldaa              #$00
                  staa              Finish
                  ldaa              #$0A
                  staa              LF
                  ldaa              #$0D
                  staa              CR
                  ldaa              #$20
                  staa              Space
                  
Main:             jmp               Mode1             * go to voltmeter by default

Mode1:
                  ldx               #Voltage
                  jsr               Output
                  ldaa              #$56              * get V for unit
                  staa              Unit
Mode11:
                  jsr               Read_AD
                  jsr               Fill_Digits
                  ldx               #Dig5
                  jsr               Output
                  jsr               Check_Input
                  cmpa              #$6F              * check for lowercase o
                  beq               Mode2             * if we have an o, move to mode 2

                  bra               Mode11
Mode2:            
                  ldx               #Resistance
                  jsr               Output
                  ldaa              #$4F              * get V for unit
                  staa              Unit
Mode22:
                  jsr               Read_AD
*                  jsr               Calc_Res
                  jsr               Check_Input
                  cmpa              #$76              * check for v and switch mode if found
                  beq               Mode1
                  bra               Mode22

* ========
* = Subs =
* ========

*Init SCI
SCI_INIT:
                  psha
                  ldaa              #$0C              * enable Tx and Rx
                  staa              SCCR2
                  ldaa              #$30              * set BAUD to 9600
                  staa              BAUD
                  pula
                  rts
                  
* returns either 0 or character in {A}
Check_Input:
                  ldaa              SCSR              * check to see if there is data incoming from the SCI
                  anda              #$20
                  beq               Check_Input_End   * if not, end here
                  ldaa              SCDR              * otherwise read the data into A
Check_Input_End:  rts                  
                  
* work on the byte in X that we get
Output:
                  psha
Output1:          ldaa              0,x               * get first character of what X points to
                  inx                                 * increment x to get the next address to read from
                  cmpa              #$00              * did we encounter a 0 char?
                  beq               OutputEnd         * if so, end
                  jsr               Output_Char       * otherwise, print the character, from regA
                  bra               Output1           * and start all over
OutputEnd:        pula
                  rts

* expects data to send out in A
Output_Char:     
                  pshb
Output_Char1:     ldab              SCSR              * check to see if the transmit register is empty
                  andb              #$80
                  cmpb              #$80
                  bne               Output_Char1      * if not, keep looping until it is
                  staa              SCDR              * finally, write the character to the SCI
                  pulb
                  rts

* read from A/D converter and store in ADResult
Read_AD:          psha
                  ldaa              #$01              * prime A/D
                  staa              ADCTL
Read_AD1:         ldaa              ADCTL             * read status bit
                  anda              #$80
                  beq               Read_AD1          * keep checking
                  ldaa              ADR2              * we should have a result now
                  staa              ADResult
                  pula
                  rts

Voltage:	fcb	$D
	fcc	"Voltage:    "
	fcb	0
	
Resistance:	fcb	$D
	fcc	"Resistance: "
	fcb	0

Fill_Digits:
	psha
	pshb
	ldab	ADResult
	ldaa	#R_H
	mul
	adda	#$30
                  staa              Dig5
                  ldaa              #10
                  mul
                  adda              #$30
                  staa              Dig4
                  ldaa              #10
                  mul
                  adda              #$30
                  staa              Dig3
                  ldaa              #10
                  mul
                  adda              #$30
                  staa              Dig2
                  ldaa              #10
                  mul
                  adda              #$30
                  staa              Dig1
                  pula
                  pulb
                  rts

Calc_Res:         psha
                  pshb
                  clrb
                  ldab              ADResult
                  negb
* we now have 256-ADResult in D. Switch to X to prepare for division
                  xgdx
                  ldaa              ADResult
                  ldab              #Rref
                  mul
                  idiv
                  xgdx
                  lsld
                  lsld
* now D contains the measured resistor value in HEX
                  ldx               #$64
                  idiv
                  xgdx
                  ldx               #$A
                  idiv
                  xgdx
                  pula
                  pulb
                  rts

                  
* ===========
* = Vectors =
* ===========
                  org               $FFFE
                  fdb               Init
