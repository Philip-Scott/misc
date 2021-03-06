
LCD_RS EQU p3.6  
LCD_E EQU p3.7
KEYBOARD_INPUT EQU p1
ALT_INPUT EQU R5
ALT_BUTTON EQU p3.4
	
SCREEN_DATA_POINTER EQU R0
SEND_BUTTON EQU p3.3

TO_DISP EQU R7

ORG 0H
JMP main;

; extern 0 : Debounced Keyboard signal
ORG 04H
	CLR IE0
	acall decode_key_press;
reti

; Temp0
ORG 0BH;
reti

; Extern 1
ORG 13H
	CLR IE1
	acall serial_main;
reti

; Temp1
ORG 1BH
reti

; Temp2
ORG 2BH
reti

ORG 40H
main:
	acall reset_display
	MOV TO_DISP, #0;
	MOV ALT_INPUT, #0;
	MOV SCREEN_DATA_POINTER, #50h;

	MOV TMOD, #00100001b       ;timer 1 con 8 bits con autorecarga
	MOV SCON, #50H             ;Serial control 
	MOV TCON, #00000101b
	MOV	TH1, #0FDH				;set baudrate to 9600 para poder enviar lo datos
	MOV	TL1, #0FDH				;set baudrate to 9600
	
	SETB TR1

	SETB IT0
	CLR IE0
	MOV IE, #10110111B
jmp $;
	
// Decodes what was pressed and places value on A
// Decoder -> ASCII
decode_key_press:
	MOV A, KEYBOARD_INPUT;
	RR A
	ANL A, #00001111b
	XRL A, #00001111b

	JB ALT_BUTTON, alt_not_pressed;
		XCH A, ALT_INPUT;
		JNZ second_key;
		first_key:
			ret
		second_key:
			RL A
			RL A
			RL A
			RL A
			ADD A, ALT_INPUT
			MOV TO_DISP, A;
			MOV ALT_INPUT, #0;
	jmp decode_send
	
	alt_not_pressed:	
		// BUTTON NOT PRESSED
		MOV dptr, #0EEh
		MOVC A, @A+DPTR
		
		MOV TO_DISP, A;
	decode_send:	
	acall save_data	
	acall send_to_display;
ret

save_data: 
	MOV A, TO_DISP;
	CJNE SCREEN_DATA_POINTER, #60h, next_char
		//NextLine
		clr LCD_RS
		MOV TO_DISP, #0C0H;
		acall send_to_display;
		setb LCD_RS;
	next_char:
	CJNE SCREEN_DATA_POINTER, #70h, dont_clear
		acall reset_display
		MOV SCREEN_DATA_POINTER, #50h;
	dont_clear:
	MOV TO_DISP, A;
	
	MOV @SCREEN_DATA_POINTER, A
	
	INC SCREEN_DATA_POINTER
ret

send_to_display: // Sends what's on R7 to disp
	CLR LCD_E;
	MOV P2, TO_disp;
	
	acall wait;
	
	SETB LCD_E
	nop	
	CLR LCD_E;
ret

wait: 
	MOV R4, #100;
	MOV R6, #100;

	wait_for_disp1:
	wait_for_disp2:
	DJNZ R4, wait_for_disp1;
	DJNZ R6, wait_for_disp2;
ret

serial_main:	
	MOV A, SCREEN_DATA_POINTER
	
	MOV R3, A
	MOV 7Ah, A
	
	MOV A, #50H
	serial_loop:
		CJNE A, 7Ah, not_z
			acall reset_display
			MOV SCREEN_DATA_POINTER, #50h;
			ret
		not_z:
			MOV R1, A
			MOV A, @R1
			MOV TO_DISP, A
			MOV A, R1
			INC A
			acall send_to_serial
	jmp serial_loop
ret

send_to_serial:         
	SETB TI                                 
	MOV SBUF, TO_DISP
	CLR TI
	JNB TI, $
ret

reset_display:	; Clears the screen, 
	CLR LCD_RS
	MOV TO_DISP, #38H;
	acall send_to_display
	MOV TO_DISP, #38H;
	acall send_to_display
	MOV TO_DISP, #38H;
	acall send_to_display
	MOV TO_DISP, #01H; //Borrar DDRM
	acall send_to_display
	MOV TO_DISP, #0EH; Display encendido, cursor activado, parpadeo desactivado.
	acall send_to_display
	MOV TO_DISP, #80H
	setb LCD_RS;
ret

org 0EEh
; Key codes
DB 31H //
DB 32H //1
DB 33H //2
DB 41H //A
DB 34H //4
DB 35H //5
DB 36H //6
DB 42H //B
DB 37H //7
DB 38H //8
DB 39H //9
DB 43H //C
DB 2Ah //*
DB 30H //0
DB 23H //# 
DB 44H //D
end
