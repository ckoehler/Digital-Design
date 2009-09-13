* ===========
* = Equates =
* ===========
* here are our external devices
LIGHTS1           equ               $0100
LIGHTS2           equ               $0101
SWITCHES          equ               $0102

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
                  org               $E000             * $E000 w/o Buffalo, $2000 with.
Init:             lds               #$01FF            * init stack pointer
Loop:             


gotoState1:

gotoState2:

gotoState3:

trans12:

trans13:

trans23: