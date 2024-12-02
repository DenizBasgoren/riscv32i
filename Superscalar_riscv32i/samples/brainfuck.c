
unsigned char memory[100];
const int memoryLength = 100;
char *program = "++++++++[>++++[>++>+++>+++>+<<<<-]>+>+>->>+[<]<-]>>.>---.+++++++..+++.>>.<-.<.+++.------.--------.>>+.>++.";
const int programLength = 106;
int programIndex = 0;
int memoryIndex = 0;

void bracketCheck();

void _start() {

	bracketCheck();

	while (programIndex>=0 && programIndex<programLength) {
		int currentInstruction = program[programIndex];
		if (currentInstruction=='>') {
			memoryIndex++;
			if (memoryIndex==memoryLength) {
				memoryIndex=0;
			}
			programIndex++;
		}
		else if (currentInstruction=='<') {
			memoryIndex--;
			if (memoryIndex==-1) {
				memoryIndex=memoryLength-1;
			}
			programIndex++;
		}
		else if (currentInstruction=='+') {
			memory[memoryIndex]++;
			programIndex++;
		}
		else if (currentInstruction=='-') {
			memory[memoryIndex]--;
			programIndex++;
		}
		else if (currentInstruction=='.') {
			// printf("%c", memory[memoryIndex]);
			*(char*)(0) = memory[memoryIndex]; 
			programIndex++;
		}
		else if (currentInstruction=='[') {
			if (memory[memoryIndex]==0) { // skip forward to matching ]
				int bracketCount = 1;
				while (1) {
					programIndex++;
					if (program[programIndex]=='[') bracketCount++;
					else if (program[programIndex]==']') bracketCount--;
					if (bracketCount==0) break;
				}
			}
			else {
				programIndex++;
			}
		}
		else if (currentInstruction==']') {
			if (memory[memoryIndex]!=0) { // skip backward to matching [
				int bracketCount = 1;
				while (1) {
					programIndex--;
					if (program[programIndex]==']') bracketCount++;
					else if (program[programIndex]=='[') bracketCount--;
					if (bracketCount==0) break;
				}
			}
			else {
				programIndex++;
			}
		}
		else {
			// ignore all other characters
			programIndex++;
		}
	}

	asm("ebreak");
}

void bracketCheck() {
	int bracketCount = 0;
	for (int i = 0; i<programLength; i++) {
		if (program[i] == '[') bracketCount++;
		else if (program[i] == ']') bracketCount--;
		if (bracketCount < 0) {
			asm("ebreak");
		}
	}
	if (bracketCount > 0) {
		asm("ebreak");
	}
}