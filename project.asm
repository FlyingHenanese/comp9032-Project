/*
 * project.asm
 *
 *  Created: 2015/10/13 7:15:16
 *   Author: Tengyu Ma
 *  ID: z5004850
 */ 
 .include "m2560def.inc"
	
.def row    =r22		; current row number
.def col    =r17		; current column number
.def rmask  =r18		; mask for current row
.def cmask	=r19		; mask for current column
.def temp1	=r24		; store value read from keypad
.def temp2  =r25		
.def distance = r23		
.def x_position = r20
.def y_position = r21
.def z_position = r26
.def speed = r30
.def duration = r31
.def timerl = r28
.def timerh = r29
.def temp = r27
.equ loop_count =65535
.equ PORTFDIR =0xF0		; use PortD for input/output from keypad: PF7-4, output, PF3-0, input
.equ INITCOLMASK = 0xEF		; scan from the leftmost column, the value to mask output
.equ INITROWMASK = 0x01		; scan from the bottom row
.equ ROWMASK  =0x0F			; low four bits are output from the keypad. This value mask the high 4 bits.
.equ LCD_CTRL_PORT = PORTA	; use porta as control port
.equ LCD_CTRL_DDR = DDRA	
.equ LCD_RS = 7
.equ LCD_E = 6
.equ LCD_RW = 5
.equ LCD_BE = 4


.equ LCD_DATA_PORT = PORTK	;portk is lcd data port
.equ LCD_DATA_DDR = DDRK
.equ LCD_DATA_PIN = PINK


.macro STORE	;stroe value to port
.if @0 > 63
sts @0, @1
.else
out @0, @1
.endif
.endmacro

.macro lcd_set
	sbi LCD_CTRL_PORT, @0		; write set value to lcd_ctrl
.endmacro
.macro lcd_clr
	cbi LCD_CTRL_PORT, @0		; write clr value to lcd_ctrl
.endmacro

.macro oneSecondDelay ; macro used for flash 3 times
ldi r16, low(loop_count)
ldi r17, high(loop_count)
clr r25
clr r24
ldi r23,11				; this value is to control flash frequency
loop:					; loop cycle is set to 0xff
cp r24, r16
cpc r25, r17
brsh done
adiw r25:r24, 1
nop
rjmp loop
done:
	clr r24				; loop the macro inorder to make flash significant
	clr r25
	dec r23
	brne loop
.endmacro
.macro digit				; convert digit to ascII that could display by lcd
	mov temp1, @0
	clr temp2
	cpi temp1, 10
	brsh second_num
	rjmp aaa
	second_num:
		subi temp1, 10
		inc	temp2
		cpi temp1,10
		brsh second_num
	aaa:
		subi temp2,-'0'
		do_lcd_data temp2
		subi temp1,-'0'
		do_lcd_data temp1
.endmacro
.macro dis_crash			; display crash interface
	do_lcd_command 0b00000001
	ldi temp1, 'L'
	do_lcd_data temp1
	ldi temp1, 'o'
	do_lcd_data temp1
	ldi temp1, 'c'
	do_lcd_data temp1
	ldi temp1, 'a'
	do_lcd_data temp1
	ldi temp1, ':'
	do_lcd_data temp1
	digit x_position
	ldi temp1, ','
	do_lcd_data temp1
	digit y_position
	ldi temp1, ','
	do_lcd_data temp1
	digit z_position
.endmacro
.macro dis_success
	do_lcd_command 0b10000000
	ldi temp1, 'D'
	do_lcd_data temp1
	ldi temp1, 'i'
	do_lcd_data temp1
	ldi temp1, 's'
	do_lcd_data temp1
	ldi temp1, 't'
	do_lcd_data temp1
	ldi temp1, 'a'
	do_lcd_data temp1
	ldi temp1, 'n'
	do_lcd_data temp1
	ldi temp1, 'c'
	do_lcd_data temp1
	ldi temp1, 'e'
	do_lcd_data temp1
	ldi temp1, ':'
	do_lcd_data temp1
	digit distance
	ldi temp1, ' '
	do_lcd_data temp1
	ldi temp1, ' '
	do_lcd_data temp1
	ldi temp1, ' '
	do_lcd_data temp1
	ldi temp1, ' '
	do_lcd_data temp1
	ldi temp1, ' '
	do_lcd_data temp1
	do_lcd_command 0b11000000
	ldi temp1,'D'
	do_lcd_data temp1
	ldi temp1, 'u'
	do_lcd_data temp1
	ldi temp1,'r'
	do_lcd_data temp1
	ldi temp1, 'a'
	do_lcd_data temp1
	ldi temp1,'t'
	do_lcd_data temp1
	ldi temp1, 'i'
	do_lcd_data temp1
	ldi temp1,'o'
	do_lcd_data temp1
	ldi temp1, 'n'
	do_lcd_data temp1
	ldi temp1,':'
	do_lcd_data temp1
	digit duration
	ldi temp1, ' '
	do_lcd_data temp1
	ldi temp1, ' '
	do_lcd_data temp1
	ldi temp1, ' '
	do_lcd_data temp1
	ldi temp1, ' '
	do_lcd_data temp1
	ldi temp1, ' '
	do_lcd_data temp1
.endmacro
.macro display				; display flying interface
	do_lcd_command 0b00000001
	ldi temp1, ' '
	do_lcd_data temp1
	ldi temp1, ' '
	do_lcd_data temp1
	ldi temp1, 'p'
	do_lcd_data temp1
	ldi temp1, 'o'
	do_lcd_data temp1
	ldi temp1, 's'
	do_lcd_data temp1
	ldi temp1, 'i'
	do_lcd_data temp1
	ldi temp1, ' '
	do_lcd_data temp1
	ldi temp1, ' '
	do_lcd_data temp1
	ldi temp1, ' '
	do_lcd_data temp1
	ldi temp1, 'd'
	do_lcd_data temp1
	ldi temp1, 'i'
	do_lcd_data temp1
	ldi temp1, 'r'
	do_lcd_data temp1
	ldi temp1, ' '
	do_lcd_data temp1
	ldi temp1, 's'
	do_lcd_data temp1
	ldi temp1, 'p'
	do_lcd_data temp1
	ldi temp1, 'e'
	do_lcd_data temp1
	do_lcd_command 0b11000000
	digit x_position
	ldi temp1, ','
	do_lcd_data temp1
	digit y_position
	ldi temp1, ','
	do_lcd_data temp1
	digit z_position
	ldi temp1, ' '
	do_lcd_data temp1
	ldi temp1, ' '
	do_lcd_data temp1
	ldi temp1, @0
	do_lcd_data temp1
	ldi temp1, ' '
	do_lcd_data temp1
	ldi temp1, ' '
	do_lcd_data temp1
	ldi temp1, ' '
	do_lcd_data temp1
	mov temp1, speed
	subi temp1,-'0'
	do_lcd_data temp1
.endmacro

.macro LOAD		; load value from port
.if @1 > 63
lds @0, @1
.else
in @0, @1
.endif
.endmacro

.macro do_lcd_command  ; write command to lcd ctrl
	ldi r16, @0
	rcall lcd_command
	rcall lcd_wait
.endmacro
.macro do_lcd_data		;write value to	lcd data 
	mov r16, @0
	rcall lcd_data
	rcall lcd_wait
.endmacro

.org 0
	jmp RESET
.org OVF0ADDR
	jmp Timer0OVF
;================================================================================================================
; every second, refresh the lcd, process flying statue flying statue is detemined by moving flag
;================================================================================================================
Timer0OVF:			
	
	adiw r29:r28, 1
	cpi r28, low(7812)
	brne notsec
	ldi temp2, high(7812)
	cpc r29,temp2
	brne notsec
	jmp issec
notsec:		
		reti
issec:
	ldi r28, 1
	add duration, r28
	add distance, speed
	cpi temp, 2		; moving flag is 2, moving foward
	breq go_front
	jmp next5
go_front:
	cpi x_position,50	; if helicopter is out of bound, it will crash
	brsh crash6
	cpi x_position,1
	brlo crash6
	jmp continue7
crash6:				; crash module
	ldi temp, 12
	ldi x_position, 50
	dis_crash	
	ldi temp1,0xFF
	out portc, temp1
	oneSecondDelay
	ldi temp1,0x00
	out portc, temp1
	oneSecondDelay
	rjmp crash6
continue7:
	display 'F'		; if not out of bound, the helicopter will moving foward
	add x_position, speed	; x_position + speed
next5:
	cpi temp, 5		; moving flag is 5, moving backward
	breq go_ba
	jmp next4
go_ba:
	cpi x_position,50
	brsh crash5
	cpi x_position,1
	brlo crash5		; if helicopter is out of bound, it will crash
	jmp continue6

crash5:
	ldi x_position, 0
	ldi temp, 12
	dis_crash
	ldi temp1,0xFF
	out portc, temp1
	oneSecondDelay
	ldi temp1,0x00
	out portc, temp1
	oneSecondDelay
	rjmp crash5
continue6:
	display 'B'		; if not out of bound, the helicopter will moving backward
	sub x_position, speed	; x_position - speed
next4:
	cpi temp, 4
	breq go_le
	jmp next6
go_le:
	cpi y_position,50
	brsh crash4
	cpi y_position,1
	brlo crash4
	jmp continue5

;=============================================================================================
; Send a command to the LCD , placed here inorder to make macros could get access
;=============================================================================================

lcd_command:
	STORE LCD_DATA_PORT, r16	;write r16 to lcd_data
	rcall sleep_1ms
	lcd_set LCD_E			;turn on enable pin
	rcall sleep_1ms		
	lcd_clr LCD_E
	rcall sleep_1ms
	ret

lcd_data:
	STORE LCD_DATA_PORT, r16
	lcd_set LCD_RS			;set for command write
	rcall sleep_1ms
	lcd_set LCD_E			;enable pin
	rcall sleep_1ms
	lcd_clr LCD_E			;enable pin
	rcall sleep_1ms
	lcd_clr LCD_RS			;turn off write
	ret

lcd_wait:				; wait the data
	push r16
	clr r16
	STORE LCD_DATA_DDR, r16
	STORE LCD_DATA_PORT, r16
	lcd_set LCD_RW
lcd_wait_loop:
	rcall sleep_1ms
	lcd_set LCD_E
	rcall sleep_1ms
	LOAD r16, LCD_DATA_PIN
	lcd_clr LCD_E
	sbrc r16, 7
	rjmp lcd_wait_loop
	lcd_clr LCD_RW
	ser r16
	STORE LCD_DATA_DDR, r16
	pop r16
	ret

.equ F_CPU = 16000000
.equ DELAY_1MS = F_CPU / 4 / 1000 - 4
; 4 cycles per iteration - setup/call-return overhead

sleep_1ms:
	push r24
	push r25
	ldi r25, high(DELAY_1MS)
	ldi r24, low(DELAY_1MS)
delayloop_1ms:
	sbiw r25:r24, 1
	brne delayloop_1ms
	pop r25
	pop r24
	ret

sleep_5ms:
	rcall sleep_1ms
	rcall sleep_1ms
	rcall sleep_1ms
	rcall sleep_1ms
	rcall sleep_1ms
	ret
;=============================================================================================
crash4:
	ldi y_position,0
	ldi temp, 12
	dis_crash
	ldi temp1,0xFF
	out portc, temp1
	oneSecondDelay
	ldi temp1,0x00
	out portc, temp1
	oneSecondDelay
	rjmp crash4
continue5:
	display 'L'
	sub y_position, speed
next6:
	cpi temp, 6
	breq go_ri
	jmp next1
go_ri:
	cpi y_position,50
	brsh crash3
	cpi y_position,1
	brlo crash3
	jmp continue4
crash3:
	ldi y_position,50
	ldi temp, 12
	dis_crash
	ldi temp1,0xFF
	out portc, temp1
	oneSecondDelay
	ldi temp1,0x00
	out portc, temp1
	oneSecondDelay
	rjmp crash3
continue4:
	display 'R'
	add y_position, speed
next1:
	cpi temp, 1
	breq go_u
	jmp next3
go_u:
	cpi z_position, 10
	brsh crash2
	jmp continue3
crash2:
	ldi z_position, 10
	ldi temp, 12
	dis_crash
	ldi temp1,0xFF
	out portc, temp1
	oneSecondDelay
	ldi temp1,0x00
	out portc, temp1
	oneSecondDelay
	rjmp crash2
continue3:
	display 'U'
	add z_position, speed
next3:
	cpi temp, 3
	breq go_d
	jmp next_10
go_d:
	cpi z_position, 50
	brsh crash7
	cpi z_position, 1
	brlo crash7
	jmp continue8
crash7:
	ldi z_position, 10
	ldi temp, 12
	dis_crash
	ldi temp1,0xFF
	out portc, temp1
	oneSecondDelay
	ldi temp1,0x00
	out portc, temp1
	oneSecondDelay
	rjmp crash7
continue8:
	display 'D'
	sub z_position, speed
next_10:
	cpi temp,10
	breq taking
	jmp next_11
taking:
	cpi z_position, 10
	brsh crash1
	jmp continue2
crash1:
	ldi z_position, 10
	ldi temp, 12
	dis_crash
	ldi temp1,0xFF
	out portc, temp1
	oneSecondDelay
	ldi temp1,0x00
	out portc, temp1
	oneSecondDelay
	rjmp crash1
continue2:
	display 'T'
	ldi temp2, 2
	add z_position,temp2
next_11:
	cpi temp,11		; moving flag 11 means landing 
	breq land
	jmp next12
land:
	cpi z_position, 1
	brlo success
	cpi z_position,50
	brsh success		; if the helicopter touch the ground
	jmp continue1
success:
	ldi z_position, 0	; display success interface
	ldi temp, 12
	dis_success
	rjmp success
continue1:
	display 'L'
	ldi temp2, 1		; landing speed is 1
	sub z_position,temp2
next12:
	cpi temp, 12
next_position:
	clr r28
	clr r29
	reti



RESET:
	ldi speed, 1
	clr r28
	clr r29
	clr duration
	clr distance
	clr r15
	clr r14
	clr r12
	clr r13
	clr temp
	ldi x_position, 25
	ldi y_position, 25
	clr z_position
	ldi temp1, PORTFDIR			; columns are outputs, rows are inputs
	out	DDRF, temp1
	ser temp1					; PORTC is outputs
	out DDRC, temp1				
	out PORTC, temp1

	ldi r16, low(RAMEND)
	out SPL, r16
	ldi r16, high(RAMEND)
	out SPH, r16

	ser r16					;set lcd data ddr and ctrl ddr as output
	STORE LCD_DATA_DDR, r16	
	STORE LCD_CTRL_DDR, r16
	clr r16
	STORE LCD_DATA_PORT, r16	;set input for data and control 
	STORE LCD_CTRL_PORT, r16

	do_lcd_command 0b00111000 ; 2x5x7
	rcall sleep_5ms
	do_lcd_command 0b00111000 ; 2x5x7
	rcall sleep_1ms
	do_lcd_command 0b00111000 ; 2x5x7
	do_lcd_command 0b00111000 ; 2x5x7
	do_lcd_command 0b00001000 ; display off
	do_lcd_command 0b00000001 ; clear display
	do_lcd_command 0b00000110 ; increment, no display shift
	do_lcd_command 0b00001110 ; Cursor on, bar, no blink
	ldi r16, 's'
	do_lcd_data r16
	ldi r16, 't'
	do_lcd_data r16
	ldi r16, 'a'
	do_lcd_data r16
	ldi r16, 'r'
	do_lcd_data r16
	ldi r16, 't'
	do_lcd_data r16
	ldi r16, 0b00000000 ; Prescale timer value
	out TCCR0A, r16		; to 8 = 256*8/7.3728
	ldi r16, 0b00000010	; = 278 microseconds
	out TCCR0B, r16		; T/C0 interrupt enable
	ldi r16, 1<<TOIE0	; = 278 microseconds
	sts TIMSK0, r16	
	sei					; Enable global interrupts
	clr r16
	rjmp main


judge:						  ; judge wether the button was released
in temp2, pinf				  ; read value from pinf 
andi temp2, 0x0f
cpi temp2, 0x0f
breq main
jmp judge

main:
	ldi cmask, INITCOLMASK		; initial column mask
	clr	col						; initial column
colloop:
	cpi col, 4
	breq main
	out	PORTF, cmask				; set column to mask value (one column off)
	ldi temp1, 0xFF
delay:
	dec temp1
	brne delay

	in	temp1, PINF				; read PORTD
	andi temp1, ROWMASK
	cpi temp1, 0xF				; check if any rows are on
	breq nextcol
								; if yes, find which row is on
	ldi rmask, INITROWMASK		; initialise row check
	clr	row						; initial row
rowloop:
	cpi row, 4
	breq nextcol
	mov temp2, temp1
	and temp2, rmask				; check masked bit
	breq convert 				; if bit is clear, convert the bitcode
	inc row						; else move to the next row
	lsl rmask					; shift the mask to the next bit
	jmp rowloop

nextcol:
	lsl cmask					; else get new mask by shifting and 
	inc cmask
	inc col						; increment column value
	jmp colloop					; and check the next column

convert:
	cpi col, 3					; if column is 3 we have a letter
	breq letters				
	cpi row, 3					; if row is 3 we have a symbol or 0
	breq symbols

	mov temp1, row				; otherwise we have a number in 1-9
	lsl temp1
	add temp1, row				; temp1 = row * 3
	add temp1, col				; add the column address to get the value
	subi temp1, -'1'			; add the value of character '0'
	jmp convert_end

letters:
	ldi temp1, 'A'
	add temp1, row				; increment the character 'A' by the row value
	jmp convert_end

symbols:
	cpi col, 0					; check if we have a star
	breq star
	cpi col, 1					; or if we have zero
	breq zero					
	ldi temp1, '#'				; if not we have hash
	jmp convert_end
star:
	ldi temp1, '*'				; set to star
	jmp convert_end
zero:
	ldi temp1, '0'				; set to zero
;==================================================================================================================
; compare the input with constant, determine what the input is and set button and moving flags
;===================================================================================================================
convert_end:
	cpi temp1, '2'				
	breq foward
	jmp second_convert
foward:
	ldi temp, 2
	rjmp judge
second_convert:
	cpi temp1, '5'
	breq backward
	jmp third_convert
backward:
	ldi temp, 5
	rjmp judge
third_convert:
	cpi temp1, '4'
	breq left
	jmp fourth_convert
left:
	ldi temp, 4
	rjmp judge
fourth_convert:
	cpi temp1, '6'
	breq right
	jmp fifth_convert
right:
	ldi temp, 6
	rjmp judge
fifth_convert:
	cpi temp1, '1'
	breq up
	jmp sixth_convert
up:
	ldi temp, 1
	rjmp judge
sixth_convert:
	cpi temp1, '3'
	breq down
	jmp seventh_convert
down:
	ldi temp,3
	rjmp judge
seventh_convert:
	cpi temp1, '7'
	breq increase
	rjmp eighth_convert
increase:
	ldi temp2,1
	cpi speed,4 
	brsh not_change
	add speed,temp2
not_change:
	rjmp judge
eighth_convert:
	cpi temp1, '9'
	breq decrease
	rjmp ninth_convert
decrease:
	ldi temp2,1
	cpi speed, 2
	brlo not_change1
	sub speed,temp2
not_change1:
	rjmp judge
ninth_convert:
	cpi temp1, '#'
	breq hash
	rjmp tenth_convert
hash:
	out portc, r14		; r14 is button flag for deteming times of press
	ldi temp1, 0		; 0 means first time press
	cp r14, temp1		; 1 means second time press
	breq taking_off
	ldi temp1, 1
	cp r14, temp1
	breq landing
	rjmp judge
taking_off:
	ldi speed,2	
	ldi temp,10 
	ldi temp1,1
	mov r14,temp1
	rjmp judge
landing:
	ldi speed,1
	ldi temp,11
	ldi temp1,0
	mov r14, temp1
	rjmp judge
tenth_convert:
	cpi temp1, '*'
	breq starbutton
	jmp end 
starbutton:
	out portc, r15		; r15 is button flag for deteming times of press
	ldi temp1,0	
	cp r15, temp1
	breq hold
	ldi temp1,1
	cp r15,temp1
	breq release
hold:
	mov r12, temp		; r12 used to store previous flying statues
	ldi temp, 12
	ldi temp1,1
	mov r15,temp1
	rjmp judge
release:
	mov temp, r12
	clr r12
	ldi temp1, 0
	mov r15, temp1
	rjmp judge
end:
	rjmp end




