	; Problema 7
	
	MOV R0, #0FAH;
	MOV A, R0
	
	
	ANL A, #0F0H;
	
	RR A
	RR A
	RR A
	RR A
	
	MOV R1, A
	
	MOV A, R0
	ANL A, #0FH;
	
	MOV R2, A;
	
	END;