* ===========
* = Equates =
* ===========
* here are our external devices
LIGHTS1           equ               $B580
LIGHTS2           equ               $B590
SWITCHES          equ               $B5A0             * Switch 0010 and 0100 both request State 1
*                                                       Switch 0001 requests State 2, and 1000 State 3

CUR_STATE         equ               $01D0
COPOPT            equ               $1039
COPRST            equ               $103A


* State 1 is free E-W traffic
STATE11           equ               #$0C              * 00 001 100
STATE12           equ               #$0C              * 00 001 100

* State 2 is free traffic from the South
STATE21           equ               #$24              * 00 100 100
STATE22           equ               #$21              * 00 100 001

* State 3 is turning lane green
STATE31           equ               #$09              * 00 001 001
STATE32           equ               #$24              * 00 100 100

* transition state to and from State 1
TRANSTATE121      equ               #$14              * 00 010 100               
TRANSTATE122      equ               #$12              * 00 010 010               

* transition state to and from State 2
TRANSTATE131      equ               #$0A              * 00 001 010               
TRANSTATE132      equ               #$14              * 00 010 100               

* transition state to and from State 3
TRANSTATE231      equ               #$12              * 00 010 010               
TRANSTATE232      equ               #$22              * 00 100 010               


**************
* Main
**************
                  org               $00             * $E000 w/o Buffalo, $2000 with.
Init:             lds               #$01FF            * init stack pointer
                  ldaa              #$03              * Set COP to ~ 1s timeout
                  oraa              COPOPT
Main:             bra               gotoState1        * start with state 1


gotoState1:
                  ldaa              #$01              * signify we are in State 1
                  staa              CUR_STATE
                  ldaa              STATE11           * get state info from definitions
                  staa              LIGHTS1           * and store into the light ext device
                  ldaa              STATE12
                  staa              LIGHTS2                  
                  jsr               delay10           * then delay for 10 seconds before changing
State1Loop:
                  jsr               resetCOP          * reset the COP
                  ldaa              SWITCHES          * read Switches in
                  ldab              SWITCHES
                  anda              #$01              * Switch A -> State 2
                  bne               trans12
                  tab
                  anda              #$08              * Switch D -> State 3
                  bne               trans13
                  bra               State1Loop        * else no switch, or go to current state, so
*                                                       ignore and keep checking

* See State 1 for comments, same thing is happening
gotoState2:
                  ldaa              #$02
                  staa              CUR_STATE
                  ldaa              STATE21
                  staa              LIGHTS1
                  ldaa              STATE22
                  staa              LIGHTS2                  
                  jsr               delay10
State2Loop:       
                  jsr               resetCOP
                  ldaa              SWITCHES
                  ldab              SWITCHES
                  anda              #$08              * Switch D -> State 3
                  bne               trans23
                  tab
                  anda              #$02              * Switch B -> State 1
                  bne               trans12
                  tab
                  anda              #$04              * Switch C -> State 1
                  bne               trans12
                  bra               State2Loop

* See State 1 for comments, same thing is happening
gotoState3:
                  ldaa              #$04
                  staa              CUR_STATE
                  ldaa              STATE31
                  staa              LIGHTS1
                  ldaa              STATE32
                  staa              LIGHTS2                  
                  jsr               delay10
State3Loop:       
                  jsr               resetCOP
                  ldaa              SWITCHES
                  ldab              SWITCHES
                  anda              #$01              * Switch A -> State 2
                  bne               trans23
                  tab
                  anda              #$02              * Switch B -> State 1
                  bne               trans13
                  tab
                  anda              #$04              * Switch C -> State 1
                  bne               trans13
                  bra               State3Loop

* sets transition state
trans12:
                  ldaa              TRANSTATE121      * set lights to transition state
                  staa              LIGHTS1
                  ldaa              TRANSTATE122
                  staa              LIGHTS2
                  jsr               delay2            * wait for 2 seconds
                  ldaa              CUR_STATE         * check current state and determine correct
*                                                       transition
                  anda              #$01
                  beq               gotoState1        * if 0, cur state = 2, so goto 1
                  bra               gotoState2        * else goto 2

* analogous to trans12
trans13:
                  ldaa              TRANSTATE131
                  staa              LIGHTS1
                  ldaa              TRANSTATE132
                  staa              LIGHTS2
                  jsr               delay2
                  ldaa              CUR_STATE
                  anda              #$01
                  beq               gotoState1        * if 0, cur state = 3, so goto 1
                  bra               gotoState3        * else goto 3

* analogous to trans12
trans23:
                  ldaa              TRANSTATE231
                  staa              LIGHTS1
                  ldaa              TRANSTATE232
                  staa              LIGHTS2
                  jsr               delay2
                  ldaa              CUR_STATE
                  anda              #$04
                  beq               gotoState2        * if 0, cur state = 3, so goto 2
                  bra               gotoState3        * else goto 3

* subroutine to reset the COP timer. We're doing this periodically
resetCOP:         ldaa              $#55
                  staa              COPRST
                  ldaa              #$AA
                  staa              COPRST
                  rts

* 2 second delay
delay2:           psha
                  ldaa              #10               * 5*2
delay2_1:         beq               delay2_end
                  jsr               delay_small
                  deca
                  bra               delay2_1
delay2_end:       pula
                  rts

* 10 second delay
delay10:          psha
                  ldaa              #50               * 5*10
delay10_1:        beq               delay10_end
                  jsr               delay_small
                  deca
                  bra               delay10_1
delay10_end:      pula
                  rts


* a small delay of 0.19 seconds, used as a building block
* for the other delays
delay_small:      pshx
                  ldx               #$FFFF
delay_small_1:    beq               delay_small_end
                  dex
                  jsr               resetCOP
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
*                  org               $FFFA
*                  fdb               COPAlert
*
*                  org               $FFFE
*                  fdb               Init
