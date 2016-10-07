; Problema 5
	ORG 0h
	MOV R1, #30H
	MOV R2, #10;
	
	addMem:
	ADD A, @R1;
	INC R1;
	DJNZ R2, addMem;
	MOV 40h, A;
	END
	