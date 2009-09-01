BAUD    EQU     $102B
SCCR2   EQU     $102D
SCSR    EQU     $102E
SCDR    EQU     $102F

        .org    $2000
Start   LDS     #$01FF
        JSR     SCIinit
        LDX     #Msg
        JSR     SCIoutMsg
Loop    JMP     Loop|SWI

Msg     FCC     "Hello there"   // dc.c
        FCB     13,10,0         // dc.b
        
// Entry: X points to message
SCIoutMsg       PSHB
                PSHX
SCIoutMsg1      LDAB    0,X
                CMPB    #0
                BEQ     SCIoutMsg2
                JSR     SCIoutChar
                INX
                BRA     SCIoutMsg1
SCIoutMsg2      PULX
                PULB
                RTS
          
// Entry: B ASCII code to serial      
SCIoutChar      PSHA
SCIoutChar1     LDAA    SCSR
                ANDA    #$80
                CMPA    #$80
                BNE     SCIoutChar1     // if MSB not set, keep waiting
                STAB    SCDR
                PULA
                RTS

// This already done in BUFFALO
SCIinit         
                psha
                ldaa #%00001100
                staa SCCR2
                ldaa #%00110000
                staa BAUD
                pula
                RTS

                org     $fffe
                fdb     Start