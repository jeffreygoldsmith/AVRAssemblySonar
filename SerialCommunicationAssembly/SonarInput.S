.global setup
setup:
  clr r16
  sts TCCR1A, r16 // Set timer to normal mode
  sts TCCR1C, r16
  ldi r16, 0b00000001
  sts TIMSK1, r16
  cbi DDRD, 2 // Set pin 2 for input
  ldi r16, 0b00000001
  sts EICRA, r16 // Respond to any change on int0 to trigger interrupt
  out EIMSK, r16 // Enble interrupt on int0
  sbi DDRC, 5 // output Portc5, Arduino pin Analog in 5, trigger the HC-SR04
  sei // Enable interrupts
ret

.global loop
loop:
rjmp loop
