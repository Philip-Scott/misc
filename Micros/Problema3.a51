; Problema 3
		ORG 0H;
init:	MOV A, #0H;
		MOV R0, #0AH;
incInit:
		INC A;
		DJNZ R0, incInit;
		JMP init;
		END;