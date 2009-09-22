* ===========
* = Equates =
* ===========
* here are our external devices
LIGHTS1           equ               $B580
LIGHTS2           equ               $B590
SWITCHES          equ               $B5A0             * Switch 0010 and 0100 both request State 1
*                                                       Switch 0001 requests State 2, and 1000 State 3

COPOPT            equ               $1039
COPRST            equ               $103A


* State 1 is free E-W traffic
STATE11           equ               $0C              * 00 001 100
STATE12           equ               $0C              * 00 001 100

* State 2 is free traffic from the South
STATE21           equ               $24              * 00 100 100
STATE22           equ               $21              * 00 100 001

* State 3 is turning lane green
STATE31           equ               $09              * 00 001 001
STATE32           equ               $24              * 00 100 100

* transition state from State 1 to State 2
TRANSTATE121      equ               $14              * 00 010 100
TRANSTATE122      equ               $14              * 00 010 100

* transition state from State 2 to State 1
TRANSTATE211      equ               $24              * 00 100 100
TRANSTATE212      equ               $22              * 00 100 010

* transition state from State 1 to State 3
TRANSTATE131      equ               $0C              * 00 001 100
TRANSTATE132      equ               $14              * 00 010 100

* transition state from State 3 to State 1
TRANSTATE311      equ               $0A              * 00 001 010
TRANSTATE312      equ               $24              * 00 100 100

* transition state from State 2 to State 3
TRANSTATE231      equ               $24              * 00 100 100
TRANSTATE232      equ               $22              * 00 100 010

* transition state from State 3 to State 2
TRANSTATE321      equ               $12              * 00 010 010
TRANSTATE322      equ               $24              * 00 100 100

**************
* Main
**************
                  org               $E000             * $E000 w/o Buffalo, $2000 with.
Init:             lds               #$01FF            * init stack pointer
                  ldaa              COPOPT            * Set COP to ~ 1s timeout
                  oraa              #$03
                  staa              COPOPT
                  ldaa              $#55
                  staa              COPRST
                  ldaa              #$AA
                  staa              COPRST
                  
Main:             bra               gotoState1        * start with state 1


gotoState1:
                  ldaa              #STATE11          * get state info from definitions
                  staa              LIGHTS1           * and store into the light ext device
                  ldaa              #STATE12
                  staa              LIGHTS2                  
                  jsr               delay10           * then delay for 10 seconds before changing
State1Loop:
                  jsr               resetCOP          * reset the COP
                  ldaa              SWITCHES          * read Switches in
                  ldab              SWITCHES
                  andb              #$01              * Switch A -> State 2
                  bne               trans12
                  tab
                  andb              #$08              * Switch D -> State 3
                  bne               trans13
                  bra               State1Loop        * else no switch, or go to current state, so
*                                                       ignore and keep checking

* sets transition state
trans12:
                  ldaa              #TRANSTATE121      * set lights to transition state
                  staa              LIGHTS1
                  ldaa              #TRANSTATE122
                  staa              LIGHTS2
                  jsr               delay2            * wait for 2 seconds
                  jmp               gotoState2

* analogous to trans12
trans13:
                  ldaa              #TRANSTATE131
                  staa              LIGHTS1
                  ldaa              #TRANSTATE132
                  staa              LIGHTS2
                  jsr               delay2
                  jmp               gotoState3
                  
* See State 1 for comments, same thing is happening
gotoState2:
                  ldaa              #STATE21
                  staa              LIGHTS1
                  ldaa              #STATE22
                  staa              LIGHTS2                  
                  jsr               delay10
State2Loop:       
                  jsr               resetCOP
                  ldaa              SWITCHES
                  ldab              SWITCHES
                  andb              #$08              * Switch D -> State 3
                  bne               trans23
                  tab
                  andb              #$02              * Switch B -> State 1
                  bne               trans21
                  tab
                  andb              #$04              * Switch C -> State 1
                  bne               trans21
                  bra               State2Loop

* analogous to trans12
trans23:
                  ldaa              #TRANSTATE231
                  staa              LIGHTS1
                  ldaa              #TRANSTATE232
                  staa              LIGHTS2
                  jsr               delay2
                  jmp               gotoState3

* analogous to trans12
trans21:
                  ldaa              #TRANSTATE211
                  staa              LIGHTS1
                  ldaa              #TRANSTATE212
                  staa              LIGHTS2
                  jsr               delay2
                  jmp               gotoState1
                  
* See State 1 for comments, same thing is happening
gotoState3:
                  ldaa              #STATE31
                  staa              LIGHTS1
                  ldaa              #STATE32
                  staa              LIGHTS2                  
                  jsr               delay10
State3Loop:       
                  jsr               resetCOP
                  ldaa              SWITCHES
                  ldab              SWITCHES
                  andb              #$01              * Switch A -> State 2
                  bne               trans32
                  tab
                  andb              #$02              * Switch B -> State 1
                  bne               trans31
                  bra               State3Loop

* analogous to trans12
trans32:
                  ldaa              #TRANSTATE321
                  staa              LIGHTS1
                  ldaa              #TRANSTATE322
                  staa              LIGHTS2
                  jsr               delay2
                  jmp               gotoState2

* analogous to trans12
trans31:
                  ldaa              #TRANSTATE311
                  staa              LIGHTS1
                  ldaa              #TRANSTATE312
                  staa              LIGHTS2
                  jsr               delay2
                  jmp               gotoState1

* subroutine to reset the COP timer. We're doing this periodically
resetCOP:         psha
                  ldaa              $#55
                  staa              COPRST
                  ldaa              #$AA
                  staa              COPRST
                  pula
                  rts

* 2 second delay
delay2:           psha
                  ldaa              #10               * 5*2
delay2_1:         cmpa              #$00
                  beq               delay2_end
                  jsr               delay_small
                  deca
                  bra               delay2_1
delay2_end:       pula
                  rts

* 10 second delay
delay10:          psha
                  ldaa              #50               * 5*10
delay10_1:        cmpa              #00
                  beq               delay10_end
                  jsr               delay_small
                  deca
                  bra               delay10_1
delay10_end:      pula
                  rts


* a small delay of 0.19 seconds, used as a building block
* for the other delays
delay_small:      pshx
                  ldx               #$79E7
delay_small_1:    cpx               #$00
                  beq               delay_small_end
                  dex
                  bra               delay_small_1
delay_small_end:  pulx
                  rts


* ISR to flash red lights on COP error
COPAlert:
                  ldaa              #$00
                  staa              LIGHTS1
                  staa              LIGHTS2
                  jsr               delay2
                  ldaa              #$24
                  staa              LIGHTS1
                  staa              LIGHTS2
                  jsr               delay2
                  bra               COPAlert
* Vectors
                  org               $FFFA
                  fdb               COPAlert

                  org               $FFFE
                  fdb               Init
