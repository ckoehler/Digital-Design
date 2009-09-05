****************
* Vars
****************

SCCR2             =                 $102D
SCSR              =                 $102E
SCDR              =                 $102F
BAUD              =                 $102B

BUFFER_BEG        =                 $0190             ;;Starting Point of Buffer
BUFFER_END        =                 $01CC             ;;End of buffer Store 3C for 60
STORE             =                 $01CE


**************
* Main
**************
                  org               $B600

Init:             lds               #$01FF            ;; init stack pointer
                  jsr               SCI_INIT          ;; init SCI subsystem
                  ldx               #Name             ;; Load our names into X
                  jsr               SCI_OUT_MSG       ;; Dispay what's in X
Loop:             ldx               #Prompt           ;; Load the prompt into X...
                  jsr               SCI_OUT_MSG       ;; ...and display it.
                  ldx               #BUFFER_BEG                    
                  jsr               SCI_IN_MSG
                  ldx               #Answer
                  jsr               SCI_OUT_MSG
                  ldx               #BUFFER_BEG
                  jsr               SCI_OUT_MSG
                  ldx               #CR
                  jsr               SCI_OUT_MSG
                  bra               Loop
; Define a few static strings
Name:             fcc               "David Ibach & Christoph Koehler"
                  fcb               13,10,0

Prompt:           fcc               "Enter a message: "
                  fcb               0

Answer:           fcc               "                 After ROT13: "
                  fcb               0

CR:               fcb               13,10,0



***************
* Subs
***************
;Init SCI
SCI_INIT:                           
                  psha            
                  ldaa              #$0C              ; enable Tx and Rx
                  staa              SCCR2
                  ldaa              #$30              ; set BAUD to 9600
                  staa              BAUD
                  pula
                  rts

; work on the byte in X that we get
SCI_OUT_MSG:
                  psha
SCI_OUT_MSG_1:    ldaa               0,x               ; get first byte in X and store into A
                  inx                                 ; increment x to get the next byte next
                  cmpa              #$00              ; did we encounter a 0 char?
                  beq               SCI_OUT_MSG_END   ; if so, end
                  jsr               SCI_Char_OUT      ; otherwise, print the character, from A
                  bra               SCI_OUT_MSG_1     ; and start all over
SCI_OUT_MSG_END:  pula
                  rts

; expects data to send out in A
SCI_Char_OUT:     
                  pshb
SCI_Char_OUT_1:   ldab              SCSR              ; check to see if the transmit register is empty
                  andb              #$80
                  cmpb              #$80
                  bne               SCI_Char_OUT_1    ; if not, keep looping until it is
                  staa              SCDR              ; finally, write the character to the SCI
                  pulb
                  rts

SCI_IN_MSG:                         
                  psha
SCI_IN_MSG_1:     ldaa              SCSR              ; check to see if there is data incoming from the SCI
                  anda              #$20
                  beq               SCI_IN_MSG_1      ; if not, keep checking
                  ldaa              SCDR              ; otherwise read the data into A
                  cmpa              #$0D              ; check for ASCII 13, enter key.
                  beq               SCI_IN_MSG_END    ; if so, finish the message
                  cpx               #BUFFER_END       ; check for end of buffer
                  beq               SCI_IN_MSG_1      ; if we're at the end, loop back
                  jsr               SCI_Char_OUT      ; otherwise, print the character we just received
                  jsr               ROT13_CYPHER      ; now run the rotation cypher on B
                  staa              0,x               ; store the byte we just received from A into X
                  inx                                 ; move address pointer to the next byte in X
                  ldaa              #$00              ; terminate with 0 byte.
                  staa              0,x
                  bra               SCI_IN_MSG_1      ; start over
SCI_IN_MSG_END:   ldaa              #$0D              ; to finish off the input, go to the next line to start fresh
                  jsr               SCI_Char_OUT
                  pula
                  rts

ROT13_CYPHER:     pshb
                  tab
                  cmpb              #$41
                  blo               ROT13_CYPHER_END  ; if the character is lower than ASCII A, end
                  
                  tab
                  cmpb              #$5B
                  blo               ROT13_CYPHER_UP   ; now compare to 5B, one character past Z. If lower, we know
                                                      ; that we have a upper case char.
                  tab
                  cmpb              #$61              
                  blo               ROT13_CYPHER_END  ; now test against a. If we're lower, we have a special char: skip!
                  
                  tab
                  cmpb              #$7B
                  blo               ROT13_CYPHER_LOW  ; check for 7B, one char past z. If we're lower, we know we have
                                                      ; a lower case char
                                                      
                  bra               ROT13_CYPHER_END  ; otherwise we are too high and skip to the end again
ROT13_CYPHER_UP:
                  tab               

                  cmpb              #$4E              ; compare to N. If we're lower, add 13, otherwise, add 13
                  blo               ROT13_CYPHER_ADD13
                  bra               ROT13_CYPHER_SUB13
ROT13_CYPHER_LOW:
                  tab               
                  cmpb              #$6E              ; compare to n. If we're lower, add 13, otherwise, add 13
                  blo               ROT13_CYPHER_ADD13
                  bra               ROT13_CYPHER_SUB13
                  
ROT13_CYPHER_ADD13:
                  adda              #13
                  bra               ROT13_CYPHER_END

ROT13_CYPHER_SUB13:
                  suba              #13
                  bra               ROT13_CYPHER_END
ROT13_CYPHER_END:
                  pulb
                  rts
                                    

                  org               $FFFE
                  dc.w              Init



