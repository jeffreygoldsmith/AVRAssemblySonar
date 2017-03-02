// Purpose    :To demonstrate communication of data to the Serial Monitor in Assembly
// Results    :Currently runs a SRAM dump of the GP, IO and Extended Registers
// Reference1 :https://hekilledmywire.wordpress.com/2011/01/05/using-the-usartserial-tutorial-part-2/
// Reference2 :Page 250 of the ATmega328p datasheet (for data size modes)
// Reference3 :http://nerdralph.blogspot.ca/2013/12/writing-avr-assembler-code-with-arduino.html
// Reference4 :http://www.h-renrew.de/h/avrdump/avrdump.html
// Reference5 :http://maxembedded.com/2013/09/the-usart-of-the-avr/
// Authors    :C. D'Arcy (inspired by M. Blum's Medium ISP Research)
// Date       :2017 02 19
// Status     :Working

#include <avr/io.h>
#include "ASCII.h"
#define BAUD9600 103           //(((F_CPU / (BAUDRATE * 16))) - 1)
#define data 65                //ASCII value translates to 'A' or '\A
// define some null-terminated strings
label:
.asciz "This is a label..."   // 
gpLabel:
.asciz  "32 GP Registers:\n"
ioLabel:
.asciz  "64 IO Registers:\n"
exLabel:
.asciz  "160 Extended Registers: "


.global setup
setup:


  
  ldi r25,BAUD9600 >> 8       ; pass the preferred BAUD rate to the initUART function
  ldi r24,BAUD9600            ;
  call initUART               ;

  call printLn
  ldi r25, 4 //100 works now 
  call printByte
  call printLn
  ldi r25, 164
  call printByte
  call printLn
  ldi r25, 255
  call printByte
  call printLn
  ldi r25, 66
  call printByte
  call printLn
  
  /*
  ldi ZH,hi8(gpLabel)         ; obtain the address of the General Purpose Register label
  ldi ZL,lo8(gpLabel)         ;
  call printStr               ; transmit it...
  
  call printGPRegs            ; transmit contents of GP Registers in a readable format
  call printLn                ;
  
  /*
  ldi ZH,hi8(ioLabel)         ; obtain the address of the Input/Output Register label
  ldi ZL,lo8(ioLabel)         ;
  
  call printStr               ; transmit it
  call printIORegs            ; transmit contents of IO Registers in a readable format
  call printLn                ;
  ldi ZH,hi8(exLabel)         ; obtain the address of the Extended IO Register label
  ldi ZL,lo8(exLabel)         ;
  call printStrLn             ; transmit it 
  call printExRegs            ; transmit contents of Ext. IO Registers in readable format
  call printLn                ;
  //call breakPoint             ;
  
  ldi r25,data                //prep ASCII character for transmission
  call printChar              // TX
  call printCharLn            // TX
  call printLn
  ldi r25,data+1
  call printCharLn            // TX
  ldi ZH,hi8(label)
  ldi ZL,lo8(label)
  call printStr
  ldi r25,colon
  call printChar
  ldi r25,space
  call printChar
  ldi ZH,hi8(label)
  ldi ZL,lo8(label)
  call printStrLn
  ldi r23,255
again:
  mov r25,r23
  call printByte
  ldi r25,'\t
  call printChar
  mov r25,r23
  call printHex
  call printLn
  dec r23
  breq done
  rjmp again
 done:
 */
ret

.global printChar
printChar:
1:
  lds r16, UCSR0A
  sbrs r16, UDRE0
  rjmp 1b
  sts UDR0, r25
ret

.global printCharLn
printCharLn:
  call printChar
  call printLn
ret

.global printByte
printByte:
  //base around GPR 25 
  //subtrack powers of ten to get the indivdual digits 
  //subtrack by 100 for first digit 
  //subtrack by 10 for second 
  //add for 48(other value) to get assci value
  mov r20, r25 //we want another copy 
  clr r21
  clr r23
  clr r24
  
  hundreds: 
  inc r21 //if 1 in reg could mean >100
  subi r20, 100 //repeats subtracking until negitive 
  brcc hundreds //find the right compare 
  
  ldi r22, 100 //this gets the regiter out of negtive but with no 
  add r20, r22 //leading zeros 
  
  tens: 
  inc r23
  subi r20, 10 //does the same as 100
  brcc tens 
  
  ldi r22, 10 //adds 10 to get back 
  add r20, r22 //adding to a negitive number could be a problem
  
  ones:
  inc r24
  subi r20, 1
  brcc ones

  dec r21 //get rid of the extra inc 
  dec r23
  dec r24 
  
  ldi r22, 48 //adds to get the assci vals of these # 
  add r21, r22 //works for some reason 
  add r23, r22
  add r24, r22
  
  mov r25, r21 //uses print char to print number 

  call printChar //these statment no the problem
  skip:
  mov r25, r23

  call printChar
  skip1:
  mov r25, r24
  call printChar
ret

.global printReg
printReg:
  push r25
  ldi r25, 'r
  call printChar
  pop r25
  call printByte
  ldi r25, '=
  call printChar
  mov r25, r24
  call printByte
  ldi r25, tab //'\t
  call printChar
ret

.global printGPRegs
printGPRegs:
  clr ZH //clear high byte of z reg
  clr ZL // 
  mov r25, ZL
  ld r24, Z+
  call printReg
ret


.global printStr
printStr:
1:
  lpm r25, Z+
  cpi r25, 0
  breq out
  call printChar
  call wait
  rjmp 1b
  out:
ret
  
.global printLn
printLn:
  ldi r25, '\n
  call printChar
ret

.global printStrLn
printStrLn:
  call printStr
  call printLn
ret




.global wait
wait:
ret



.global loop
loop:
rjmp loop           
