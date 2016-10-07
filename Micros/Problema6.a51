		ORG 0h
		MOV R0, #11H
		MOV R1, #11H
		MOV R2, #11H
		MOV R3, #11H
		MOV R4, #11H
		
		
init:   MOV A, #10H;
		MOV A, R1;
		
		ADD A, R0
		ADD A, R1
		ADD A, R2
		ADD A, R3
		ADD A, R4
		RR A
		ANL A, R0
		DEC A
		JMP init;
		END
		