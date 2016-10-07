; Problema 2
		ORG 0H;
		MOV A, #025H;
		MOV R0, #0CH;
		
incInit:INC A;
		DJNZ R0, incInit;
		MOV R0, #0CH;
incDec:
		DEC A;
		DJNZ R0, incDec;
		END;